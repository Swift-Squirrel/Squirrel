//
//  JSONCodingTests.swift
//  Micros
//
//  Created by Filip Klembara on 7/25/17.
//
//

import XCTest
import Test
@testable import SquirrelJSONEncoding


class JSONCodingTests: XCTestCase {
    struct User {
        let id: UInt
        var name: String
        var age: UInt
    }

    struct TestS1 {
        var a = 3
        var b: UInt?
        struct SubStruct1 {
            var a: String
        }
        var c: SubStruct1
    }

    func testEncodeJSON() {
        let user = User(id: 1, name: "Thom", age: 21)

        assertNoThrow(try JSONCoding.encodeJSON(object: user))

        if let result = try? JSONCoding.encodeJSON(object: user) {
            assertEqual(result.count, "{\"id\":1,\"name\":\"Thom\",\"age\":21}".count)
            assert(result.contains("\"id\":1"))
            assert(result.contains("\"name\":\"Thom\""))
            assert(result.contains("\"age\":21"))
            assert(result.hasPrefix("{"))
            assert(result.hasSuffix("}"))
        }

        let ss = TestS1.SubStruct1(a: "SubStruct")
        let s1 = TestS1(a: 3, b: nil, c: ss)
        assertNoThrow(try JSONCoding.encodeJSON(object: s1))

        if let result = try? JSONCoding.encodeJSON(object: s1) {
            assertEqual(result.count, "{\"a\":3,\"c\":{\"a\":\"SubStruct\"}}".count,"got: \(result)")
            assert(result.contains("\"a\":3"))
            assert(result.contains("\"c\":{\"a\":\"SubStruct\"}"))
            assert(result.hasPrefix("{"))
            assert(result.hasSuffix("}"))
        }
    }

    func testJSONValidity() {
        let validJSON: [String] = [
            "{\"books\":{\"book\":[{\"title\":\"CPP\",\"author\":\"Milton\",\"year\":\"2008\",\"price\":\"456.00\"},{\"title\":\"JAVA\",\"author\":\"Gilson\",\"year\":\"2002\",\"price\":\"456.00\"}," +
            "{\"title\":\"AdobeFlex\",\"author\":\"Johnson\",\"year\":\"2010\",\"price\":\"566.00\"}]}}",

"{\"menu\":{\"id\":\"file\",\"value\":\"File\",\"popup\":{\"menuitem\":[{\"value\":\"New\",\"onclick\":\"CreateNewDoc()\"},{\"value\":\"Open\",\"onclick\":\"OpenDoc()\"},{\"value\":\"Close\",\"onclick\":\"CloseDoc()\"}]}}}",

"{\"web-app\":{\"servlet\":[{\"servlet-name\":\"cofaxCDS\",\"servlet-class\":\"org.cofax.cds.CDSServlet\",\"init-param\":{\"configGlossary:installationAt\":\"Philadelphia, PA\",\"configGlossary:adminEmail\":\"ksm@pobox.com\",\"configGlossary:poweredBy\":\"Cofax\",\"configGlossary:poweredByIcon\":\"/images/cofax.gif\",\"configGlossary:staticPath\":\"/content/static\",\"templateProcessorClass\":\"org.cofax.WysiwygTemplate\",\"templateLoaderClass\":\"org.cofax.FilesTemplateLoader\",\"templatePath\":\"templates\",\"templateOverridePath\":\"\",\"defaultListTemplate\":\"listTemplate.htm\",\"defaultFileTemplate\":\"articleTemplate.htm\",\"useJSP\":false,\"jspListTemplate\":\"listTemplate.jsp\",\"jspFileTemplate\":\"articleTemplate.jsp\",\"cachePackageTagsTrack\":200,\"cachePackageTagsStore\":200,\"cachePackageTagsRefresh\":60,\"cacheTemplatesTrack\":100,\"cacheTemplatesStore\":50,\"cacheTemplatesRefresh\":15,\"cachePagesTrack\":200,\"cachePagesStore\":100,\"cachePagesRefresh\":10,\"cachePagesDirtyRead\":10,\"searchEngineListTemplate\":\"forSearchEnginesList.htm\",\"searchEngineFileTemplate\":\"forSearchEngines.htm\",\"searchEngineRobotsDb\":\"WEB-INF/robots.db\",\"useDataStore\":true,\"dataStoreClass\":\"org.cofax.SqlDataStore\",\"redirectionClass\":\"org.cofax.SqlRedirection\",\"dataStoreName\":\"cofax\",\"dataStoreDriver\":\"com.microsoft.jdbc.sqlserver.SQLServerDriver\",\"dataStoreUrl\":\"jdbc:microsoft:sqlserver://LOCALHOST:1433;DatabaseName=goon\",\"dataStoreUser\":\"sa\",\"dataStorePassword\":\"dataStoreTestQuery\",\"dataStoreTestQuery\":\"SET NOCOUNT ON;select test='test';\",\"dataStoreLogFile\":\"/usr/local/tomcat/logs/datastore.log\",\"dataStoreInitConns\":10,\"dataStoreMaxConns\":100,\"dataStoreConnUsageLimit\":100,\"dataStoreLogLevel\":\"debug\",\"maxUrlLength\":500}},{\"servlet-name\":\"cofaxEmail\",\"servlet-class\":\"org.cofax.cds.EmailServlet\",\"init-param\":{\"mailHost\":\"mail1\",\"mailHostOverride\":\"mail2\"}},{\"servlet-name\":\"cofaxAdmin\",\"servlet-class\":\"org.cofax.cds.AdminServlet\"},{\"servlet-name\":\"fileServlet\",\"servlet-class\":\"org.cofax.cds.FileServlet\"},{\"servlet-name\":\"cofaxTools\",\"servlet-class\":\"org.cofax.cms.CofaxToolsServlet\",\"init-param\":{\"templatePath\":\"toolstemplates/\",\"log\":1,\"logLocation\":\"/usr/local/tomcat/logs/CofaxTools.log\",\"logMaxSize\":\"\",\"dataLog\":1,\"dataLogLocation\":\"/usr/local/tomcat/logs/dataLog.log\",\"dataLogMaxSize\":\"\",\"removePageCache\":\"/content/admin/remove?cache=pages&id=\",\"removeTemplateCache\":\"/content/admin/remove?cache=templates&id=\",\"fileTransferFolder\":\"/usr/local/tomcat/webapps/content/fileTransferFolder\",\"lookInContext\":1,\"adminGroupID\":4,\"betaServer\":true}}],\"servlet-mapping\":{\"cofaxCDS\":\"/\",\"cofaxEmail\":\"/cofaxutil/aemail/*\",\"cofaxAdmin\":\"/admin/*\",\"fileServlet\":\"/static/*\",\"cofaxTools\":\"/tools/*\"},\"taglib\":{\"taglib-uri\":\"cofax.tld\",\"taglib-location\":\"/WEB-INF/tlds/cofax.tld\"}}}"
        ]

        var i = 0
        validJSON.forEach { (json) in
            var result = JSONCoding.isValid(json: json)
            assertTrue(result, "Error on valid json with index \(i)!")

            result = JSONCoding.isValid(json: "}" + json)
            assertFalse(result, "Error on invalid json with index \(i)!")
            i += 1
        }
    }

    func testObjArr() {
        let users = [
            User(id: 1, name: "Tom", age: 10),
            User(id: 2, name: "Ben", age: 12),
            User(id: 3, name: "Jenny", age: 9)
        ]

        guard let jsonData = JSONCoding.encodeSerializeJSON(object: users) as? [String: Any] else {
            XCTFail()
            return
        }

        XCTAssert(jsonData.count == 1)
        XCTAssertNotNil(jsonData["users"])

        // TODO beter encode
    }

    static var allTests = [
        ("testEncodeJSON", testEncodeJSON),
        ("testJSONValidity", testJSONValidity),
        ("testObjArr", testObjArr)
    ]
}
