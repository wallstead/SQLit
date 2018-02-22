import PathKit

/* SQLRunner manages the actual running of each SQL command. */
class SQLRunner {

    let initialPath: Path

    init(path: Path) {
        self.initialPath = path
    }

    func run(command: Command) { // route to functions
        switch command.baseCommand {
        case .create:
            create(command)
        case .drop:
            drop(command)
        case .use:
            use(command)
        case .select:
            select(command)
        case .alter:
            alter(command)
        case .exit:
            exit();
        }
    }

    /* CREATE Functions */

    func create(_ command: Command) {

        if let commandModifier = command.commandModifier {
            switch commandModifier {
            case .database:
                createDB(withName: command.commandTextContent![0])
            case .table:
                createTable(withName: command.commandTextContent![0], command: command)
            case .star:
                break;
            }
        }
    }

    func createDB(withName name: String) {
        let newDirPath = Path(name)

        if newDirPath.exists {
            print("!Failed to create database \(name) because it already exists.")
        } else {
            do {
                try newDirPath.mkdir()
                print("Database \(name) created.")
            } catch {
                print("Couldn't make directory for \(name)")
            }
        }
    }

    func createTable(withName name: String, command: Command) {
        let newFilePath = Path(name)
        if newFilePath.exists {
            print("!Failed to create table \(name) because it already exists.")
        } else {
            do {
                //(a1 int, a2 varchar(20))
                let textContentLength = command.commandTextContent!.count
                var rejoinedTextContent = ""
                for index in 1...textContentLength-1 {
                    rejoinedTextContent.append(command.commandTextContent![index] + " ")
                }
                let newTextContent = String(rejoinedTextContent.dropLast().dropLast().dropFirst()).replacingOccurrences(of: ",", with: "") // e.g. 'a3 float, a4 char(20)'
                let newTextContentArray = newTextContent.components(separatedBy: .whitespaces)
                var finalPlainText = ""
                for index in 0...newTextContentArray.count-1 {
                    if index % 2 != 0 { // odd number
                        finalPlainText.append(newTextContentArray[index] + "\n")
                    } else {
                        finalPlainText.append(newTextContentArray[index] + " ")
                    }
                }
                try newFilePath.write(finalPlainText)
                print("Table \(name) created.")
            } catch {
                print("Couldn't write file for \(name)")
            }
        }
    }

    /* DROP Functions */

    func drop(_ command: Command) {
        if let commandModifier = command.commandModifier {
            switch commandModifier {
            case .database:
                dropDB(withName: command.commandTextContent![0])
            case .table:
                dropTable(withName: command.commandTextContent![0])
            case .star:
                break;
            }
        }
    }

    func dropDB(withName name: String) {
        let dirPath = Path(name)

        if !dirPath.exists {
            print("!Failed to delete \(name) because it does not exist.")
        } else {
            do {
                try dirPath.delete()
                print("Database \(name) deleted.")
            } catch {
                print("Couldn't delete directory for \(name)")
            }
        }
    }

    func dropTable(withName name: String) {
        let filePath = Path(name)

        if !filePath.exists {
            print("!Failed to delete \(name) because it does not exist.")
        } else {
            do {
                try filePath.delete()
                print("Table \(name) deleted.")
            } catch {
                print("Couldn't delete file for \(name)")
            }
        }
    }

    /* USE Functions */

    func use(_ command: Command) {
        let dbName = command.commandTextContent![0]
        let dbPath = initialPath + Path(dbName)
        if dbPath.exists {
            Path.current = dbPath
            print("Using database \(dbName).")
        } else {
            print("!Failed to use \(dbName) because it does not exist.")
        }
    }

    func select(_ command: Command) {
        let tablename = command.commandTextContent![0]
        print("selecting \(tablename)")

        let filePath = Path(tablename)

        if !filePath.exists {
            print("!Failed to select \(tablename) because it does not exist.")
        } else {
            do {
                let fileString: String = try filePath.read()
                let stringParts = fileString.components(separatedBy: .newlines)
                var finalPrintString = ""
                for index in 0...stringParts.count-2 {
                    if index < stringParts.count-2 {
                        finalPrintString.append(stringParts[index] + " | ")
                    } else {
                        finalPrintString.append(stringParts[index])
                    }
                }
                print(finalPrintString)
            } catch {
                print("Couldn't read file \(tablename)")
            }
        }
    }

    /* ALTER functions */

    func alter(_ command: Command) {

        let tablename = command.commandTextContent![0]
        let filePath = Path(tablename)

        if !filePath.exists {
            print("!Failed to alter \(tablename) because it does not exist.")
        } else {
            do {
                let fileString: String = try filePath.read()
                var stringParts: [String] = fileString.components(separatedBy: .newlines)
                let newRow: String = "\(command.commandTextContent![2]) \(command.commandTextContent![3])"
                stringParts[2] = newRow

                var finalPlainText: String = ""

                for index in 0...stringParts.count-1 {
                    finalPlainText.append(stringParts[index] + "\n")
                }

                try filePath.write(finalPlainText)
                print("Table \(tablename) altered.")
            } catch {
                print("Couldn't read file \(tablename)")
            }
        }
    }

    /* .EXIT function */

    func exit() {
        print("All done.")
    }
}
