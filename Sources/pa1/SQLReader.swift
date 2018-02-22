import PathKit

/* SQLReader manages the reading of an SQL file and converting the lines to commands that can be executed easily */
class SQLReader {
    let fileName: String
    var commands: [Command]

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
                    if !line.hasPrefix("--") && line.count != 0 { /* This line is not a comment and not an empty line */
                        let lineSansSemiColon = line.replacingOccurrences(of: ";", with: "")
                        if let command = Command(commandString: lineSansSemiColon) {
                            commands.append(command)
                        }
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
