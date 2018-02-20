import PathKit

class SQLRunner {

    // init(fileName: String) {
    //     self.fileName = fileName
    //     self.commands = []
    // }

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
            break;
        }
    }

    /* CREATE Functions */

    func create(_ command: Command) {

        if let commandModifier = command.commandModifier {
            switch commandModifier {
            case .database:
                createDB(withName: command.commandTextContent![0])
            case .table:
                break;
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

    /* DROP Functions */

    func drop(_ command: Command) {
        if let commandModifier = command.commandModifier {
            switch commandModifier {
            case .database:
                dropDB(withName: command.commandTextContent![0])
            case .table:
                break;
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

    /* USE Functions */

    func use(_ command: Command) {
        let dbName = command.commandTextContent![0]
        let currentPath = Path.current
        currentPath.chdir {
          // Path.current would be set to path during execution of this closure
        }
    }

    func select(_ command: Command) {
        // print("selecting")
    }

    func alter(_ command: Command) {
        // print("altering")
    }
}
