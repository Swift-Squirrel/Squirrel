#!/usr/bin/env python3
import time


class RouteParam:
    def __init__(self, name: str, type_name: str, doc: str, protocols=None, builder=None, generic_name=None,
                 is_builder=False, builded_variable_name=None):
        self.is_builder = is_builder
        self.name = name
        self.type_name = type_name
        self.doc = doc
        if builder is not None:
            self.__is_buildable = True
            self.builder = builder
        else:
            self.__is_buildable = False
            self.builder = None

        self.protocols = []
        if protocols is not None:
            self.__generic = True
            if isinstance(protocols, list):
                self.protocols = protocols
            else:
                self.protocols = [protocols]
            self.generic_name = self.type_name
        else:
            self.__generic = False

        self.var_type = self.type_name

        if generic_name is not None:
            self.__generic = True
            self.generic_name = generic_name
            self.var_type = self.generic_name
        self.builded_variable_name = builded_variable_name
        self.var_name = "_" + self.name

    def get_signature(self):
        if self.is_generic():
            filler = ", ".join(self.protocols)
        else:
            filler = self.name

        return "<{}>".format(filler)

    def is_generic(self):
        return self.__generic

    def is_buildable(self):
        return self.__is_buildable

    def generic_description(self):
        return self.generic_name if len(self.protocols) == 0 else "{}: {}".format(self.generic_name,
                                                                                  ", ".join(self.protocols))

    def __str__(self):
        if self.is_generic():
            return "<{} - {}: {}>".format(self.type_name, self.name, ", ".join(self.protocols))
        return "{}: {}".format(self.name, self.type_name)

    def __repr__(self):
        return str(self)


RESULT_FILE = "Router+routing.swift"
RESULT_FILE_PATH = "../Sources/Squirrel/{}".format(RESULT_FILE)

print("Result file path: {}".format(RESULT_FILE_PATH))

convert_builder = "try ResponseManager.convertParameters(request: request)"
convert_body_builder = "try ResponseManager.convertBodyParameters(request: request)"
session_convert_builder = "try ResponseManager.convertSessionParameters(request: request)"
session_builder = "try request.session()"

TYPES = [
    RouteParam(name="request", type_name="Request", doc="Request class"),
    RouteParam(name="params", type_name="T", doc="struct/class created from request query patameters", protocols="Decodable",
               builder=convert_builder),
    RouteParam(name="bodyParams", type_name="B", doc="struct/class created from request body", protocols="BodyDecodable",
               builder=convert_body_builder),
    RouteParam(name="session", type_name="Session", doc="Session class", builder=session_builder),
    RouteParam(name="sessionParams", type_name="S", doc="struct/class created from session",
               protocols="SessionDecodable", builder=session_convert_builder),
    RouteParam(name="builder", type_name="@escaping (_ request: Request) throws -> C",
               doc="builder for custom struct/class created from request", generic_name="C",
               builder="try builder(request)", is_builder=True, builded_variable_name="customParam"),
]


def all_subsets(lst):
    res = [[]]
    for element in lst:
        res.extend([x + [element] for x in res])
    return sorted(res, key=lambda l: len(l))


type_combinations = all_subsets(TYPES)

METHODS = ["get", "post", "put", "delete", "patch"]

print("Used methods: {}".format("".join(["\n\t{}".format(x) for x in METHODS])))
print("Function paramters: {}".format("".join(["\n\t{}".format(x) for x in TYPES])))


def temp_func(method: str, type_combination: list) -> str:
    params = "" if len(type_combination) == 0 else ", ".join(
        "_ {}: {}".format(x.name if not x.is_builder else x.builded_variable_name, x.var_type) for x in
        type_combination)
    params_doc = "".join(["\n    ///   - {}: {}".format(x.name, x.doc) for x in type_combination])
    builtable = [x for x in type_combination if x.is_buildable()]
    temp = """
    /// Add route for {} method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler{}""".format(method, params_doc)

    generics_arr = [x for x in type_combination if x.is_generic()]
    generics = "" if len(generics_arr) == 0 else "<{}>".format(
        ", ".join([x.generic_description() for x in generics_arr]))
    builders = [x for x in type_combination if x.is_builder]
    builders_sig = "".join(["\n        {}: {},".format(x.name, x.type_name) for x in builders])
    temp += """
    public func {}{}(
        _ url: String,
        middlewares: [Middleware] = [],{}
        handler: @escaping ({}) throws -> Any) {{\n""".format(method, generics, builders_sig, params)

    closure_param = "request" if len(type_combination) > 0 else "_"
    builded_variables = "".join(
        ["\n                let {}: {} = {}".format(x.var_name if x.is_builder else x.name, x.var_type, x.builder) for x
         in builtable])
    names = ", ".join([x.var_name if x.is_builder else x.name for x in type_combination])
    temp += """
        ResponseManager.sharedInstance.route(
            method: .{},
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) {{ {} in
                {}
                return try handler({})
        }}
    }}\n""".format(method, closure_param, builded_variables, names)
    return temp


with open(RESULT_FILE_PATH, "w") as file:
    m = int(time.strftime("%m"))
    d = int(time.strftime("%d"))
    y = int(time.strftime("%y"))
    t = "{}/{}/{}".format(m, d, y)
    file.write("//\n"
               "//  {}\n"
               "//  Squirrel'n"
               "//\n"
               "//  Created by Filip Klembara on {}.\n"
               "//\n\n"
               "// swiftlint:disable trailing_whitespace\n"
               "// swiftlint:disable line_length\n"
               "// swiftlint:disable identifier_name\n"
               "// swiftlint:disable file_length\n"
               "\n".format(RESULT_FILE, t))
    file.write("// MARK: - routes\nextension Router {")
    used_signatures = set()
    tmp = [(method, tc) for method in METHODS for tc in type_combinations]
    lst = []
    for method, type_combination in tmp:
        signature = method + ", ".join([x.get_signature() for x in type_combination])
        if signature not in used_signatures:
            used_signatures.add(signature)
            lst.append((method, type_combination))

    for method, type_combination in lst:
        file.write(temp_func(method, type_combination))
        # file.write(temp_builder_func(method, type_combination, builders_count=1))
        # pass
    file.write("}")
    print("Generated functions count: {}".format(len(lst)))
print("Done")
