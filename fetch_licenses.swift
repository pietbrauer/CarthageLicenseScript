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
    let name: String, version: String
    var license: String?

    init(line: String) {
        let line = line.stringByReplacingOccurrencesOfString("github ", withString: "")
        let components = line.componentsSeparatedByString("\" \"")
        name = components[0].stringByReplacingOccurrencesOfString("\"", withString: "")
        version = components[1].stringByReplacingOccurrencesOfString("\"", withString: "")
    }

    var projectName: String {
        return name.componentsSeparatedByString("/")[1]
    }

    var description: String {
        return join(" ", [name, version] + licenseURLStrings)
    }

    var licenseURLStrings: [String] {
        return ["Source/License.txt", "License.md", "LICENSE.md", "LICENSE", "License.txt"].map { "https://github.com/\(self.name)/raw/\(self.version)/\($0)" }
    }

    func fetchLicense(outputDir: String) -> String {
        var license = ""
        let urls = licenseURLStrings.map({ NSURL(string: $0)! })
        for url in urls {
            let semaphore = dispatch_semaphore_create(0)

            let request = NSURLRequest(URL: url)
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                if let response = response as? NSHTTPURLResponse {
                    if response.statusCode == 404 {
                        println("Wasn't \(url)")
                    }
                }

                let string = NSString(data: data, encoding: NSUTF8StringEncoding)
                if let string = string {
                    if string != "{\"error\":\"Not Found\"}" {
                        license = string as String
                    }
                }
                dispatch_semaphore_signal(semaphore);
            })
            task.resume()
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
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
        let licenses = entries.map { ["title": $0.name, "text": $0.fetchLicense(outputDirectory)] }
        let fileName = outputDirectory.stringByAppendingPathComponent("Licenses.plist")
        (licenses as NSArray).writeToFile(fileName, atomically: true)
    }
} else {
    println("USAGE: ./fetch_licenses Cartfile.resolved output_directory/")
}
