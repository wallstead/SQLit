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
                var fullCommand = "" // because some commands will be split into multiple lines
                for line in rawLines {
                    if line.hasPrefix(".exit") {
                        if let command = Command(commandString: ".EXIT") {
                            commands.append(command)
                        }
                    } else if !line.hasPrefix("--") && line.count != 0 { /* This line is not a comment and not an empty line */

                        let lineComponents = line.components(separatedBy: .whitespaces) // seperate the line by whitespaces
                        let cleanLineComponents = cleanCommandTextArr(lineComponents)

                        if line.range(of:";") == nil { // doesn't contain semicolon

                            for lineComponent in cleanLineComponents {
                                fullCommand.append(lineComponent + " ")
                            }
                        } else { // contains semicolon
                            for lineComponent in cleanLineComponents {
                                fullCommand.append(lineComponent + " ")
                            }

                            /* Register the command */
                            let commandStringSansSemiColon = fullCommand.replacingOccurrences(of: "; ", with: "")
                            if let command = Command(commandString: commandStringSansSemiColon) {
                                commands.append(command)
                            } else {
                                print("ERROR Parsing Command String: '\(commandStringSansSemiColon)'")
                            }

                            fullCommand = "" // reset
                        }
                    }
                }

                /* on each line */
                /* if line doesn't start with comment and it isn't empty
                        if there isn't a ; on the line
                                append the content (without comments) to the command string
                        else (there is a ;)
                                append the content (without comments) to the command string and append it to commands and clear the fullCommand
                                */
            } catch {
                print("Could not read from \(fileName)")
            }
        } else {
            print("Cannot find \(fileName) in the current directory.")
        }
    }
}
