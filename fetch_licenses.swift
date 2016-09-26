#!/usr/bin/env xcrun swift

import Cocoa

func loadResolvedCartfile(file: String) throws -> String {
    let string = try String(contentsOfFile: file, encoding: String.Encoding.utf8)
    return string
}

func parseResolvedCartfile(contents: String) -> [CartfileEntry] {
    let lines = contents.components(separatedBy: "\n")
    return lines.filter({ $0.utf16.count > 0 }).map { CartfileEntry(line: $0) }
}

struct CartfileEntry: CustomStringConvertible {
    let name: String, version: String
    var license: String?

    init(line: String) {
        let line = line.replacingOccurrences(of: "github ", with: "")
        let components = line.components(separatedBy: "\" \"")
        name = components[0].replacingOccurrences(of: "\"", with: "")
        version = components[1].replacingOccurrences(of: "\"", with: "")
    }

    var projectName: String {
        return name.components(separatedBy: "/")[1]
    }

    var description: String {
        return ([name, version] + licenseURLStrings).joined(separator: " ")
    }

    var licenseURLStrings: [String] {
        return ["Source/License.txt", "License.md", "LICENSE.md", "LICENSE", "License.txt"].map { "https://github.com/\(self.name)/raw/\(self.version)/\($0)" }
    }

    func fetchLicense(outputDir: String) -> String {
        var license = ""
        let urls = licenseURLStrings.map({ URL(string: $0)! })
        print("Fetching licenses for \(name) ...")
        for url in urls {
            let semaphore = DispatchSemaphore(value: 0)

            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                semaphore.signal()
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 404 {
                        return
                    }
                }

                let string = String(data: data!, encoding: .utf8)
                if let string = string {
                    license = string as String
                }
            })
            task.resume()
            _ = semaphore.wait(timeout: .distantFuture)
        }

        return license
    }
}

var c = 0;
if CommandLine.arguments.count == 3 {
    let resolvedCartfile = CommandLine.arguments[1]
    let outputDirectory = CommandLine.arguments[2]
    var error: NSError?
    do {
        let content = try loadResolvedCartfile(file: resolvedCartfile)
        let entries = parseResolvedCartfile(contents: content)
        let licenses = entries.map { ["title": $0.projectName, "text": $0.fetchLicense(outputDir: outputDirectory)] }
        let fileName = (outputDirectory as NSString).appendingPathComponent("Licenses.plist")
        (licenses as NSArray).write(toFile: fileName, atomically: true)
        print("Super awesome! Your licenses are at \(fileName) 🍻")
    } catch {
        print(error)
    }
} else {
    print("USAGE: ./fetch_licenses Cartfile.resolved output_directory/")
}

