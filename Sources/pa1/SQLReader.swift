import PathKit

class SQLReader {
    let fileName: String
    var commands: [String]

    init(fileName: String) {
        self.fileName = fileName
        self.commands = []
    }

    func read() {
        let path = Path(fileName) // relative file location (assuming it's in the same directory)

        if path.exists {
            do {
                guard let fileContents: String = try path.read() else {
                    print("Could not read from \(fileName)")
                }

                let rawLines = fileContents.components(separatedBy: .newlines)

                for line in rawLines {
                    if line.hasPrefix("--") || line.count == 0 { /* This line is a comment or an empty line */

                    } else {
                        print(line)
                    }
                }
            } catch {
                print("Could not read from \(fileName)")
            }
        } else {
            print("Cannot find \(fileName) in the current directory.")
        }
    }
}