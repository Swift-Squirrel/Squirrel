//
//  HTMLTemplates.swift
//  Squirrel
//
//  Created by Filip Klembara on 9/18/17.
//

// swiftlint:disable function_body_length
// swiftlint:disable line_length

func htmlTemplate(title: String? = nil, body: String) -> String {
    let pageTitle: String
    let errorName: String
    if let title = title {
        errorName = ": <i>\(title)</i>"
        pageTitle = title
    } else {
        errorName = ""
        pageTitle = "Squirrel error"
    }
    let html = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>\(pageTitle)</title>
        <style>
            body {
                margin: 0;
            }
            #header {
                padding: 15px;
                background: #A26B01; /* For browsers that do not support gradients */
                background: -webkit-linear-gradient(-45deg, #A26B01 5%, #F5C854); /* For Safari 5.1 to 6.0 */
                background: -o-linear-gradient(-45deg, #A26B01 5%, #F5C854); /* For Opera 11.1 to 12.0 */
                background: -moz-linear-gradient(-45deg, #A26B01 5%, #F5C854); /* For Firefox 3.6 to 15 */
                background: linear-gradient(-45deg, #A26B01 5%, #F5C854); /* Standard syntax */
                margin: 0 0 15px 0;
                font-weight: bold;
                color: #AF4B08;
            }
            #header i {
                font-weight: bolder;
            }
            #body {
                padding-left: 15px;
            }
        </style>
    </head>
    <body>
        <h3 id="header">Squirrel Error\(errorName)</h3>
        <div id="body">
            \(body)
        </div>
    </body>
    </html>
    """
    return html
}
