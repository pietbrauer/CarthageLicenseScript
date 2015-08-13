#!/usr/bin/env xcrun swift
import Cocoa

func loadResolvedCartfile(file: String, error: NSErrorPointer) -> String? {
    let string = String(contentsOfFile: file, encoding: NSUTF8StringEncoding, error: error)
    return string
}

func parseResolvedCartfile(contents: String) -> [CartfileEntry] {
    let lines = contents.componentsSeparatedByString("\n")
    return lines.filter({ count($0) > 0 }).map { CartfileEntry(line: $0) }
}

struct CartfileEntry: Printable {
    let name: String
    var license: String?

    init(line: String) {
        let line = line.stringByReplacingOccurrencesOfString("github ", withString: "")
        let components = line.componentsSeparatedByString("\" \"")
        name = components[0].stringByReplacingOccurrencesOfString("\"", withString: "")
    }

    var projectName: String {
        return name.componentsSeparatedByString("/")[1]
    }

    var description: String {
        return join(" ", [name])
    }

    func fetchLicense() -> String {
        var license = ""
        let url = NSURL(string: "https://api.github.com/repos/\(name)/license")
        if let url = url {
            println("Fetching license for \(name) ...")
            let semaphore = dispatch_semaphore_create(0)

            let request = NSMutableURLRequest(URL: url)
            request.setValue("application/vnd.github.drax-preview+json", forHTTPHeaderField: "Accept")
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                let json = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: nil) as? [String: AnyObject]
                if let response = response as? NSHTTPURLResponse {
                    if response.statusCode != 200 {
                        if let json = json, message = json["message"] as? String {
                            println("\(message)")
                        }
                    }
                }
                if let json = json,
                    content = json["content"] as? String,
                    decodedData = NSData(base64EncodedString: content, options: .IgnoreUnknownCharacters),
                    decodedString = NSString(data: decodedData, encoding: NSUTF8StringEncoding) {
                        license = decodedString as String
                }
                dispatch_semaphore_signal(semaphore)
            })
            task.resume()
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        }

        return license
    }
}

if Process.arguments.count == 3 {
    let resolvedCartfile = Process.arguments[1]
    let outputDirectory = Process.arguments[2]
    var error: NSError?
    let content = loadResolvedCartfile(resolvedCartfile, &error)
    if let error = error {
        println(error)
    }

    if let content = content {
        let entries = parseResolvedCartfile(content)
        let licenses = entries.map { ["title": $0.projectName, "text": $0.fetchLicense()] }
        let fileName = outputDirectory.stringByAppendingPathComponent("Licenses.plist")
        (licenses as NSArray).writeToFile(fileName, atomically: true)
        println("Super awesome! Your licenses are at \(fileName) 🍻")
    }
} else {
    println("USAGE: ./fetch_licenses Cartfile.resolved output_directory/")
}
