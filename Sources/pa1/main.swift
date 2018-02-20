#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

if CommandLine.arguments.count != 2 {
    print("Expected sql file as argument.")
} else {
    let sqlFileName = CommandLine.arguments[1]
    let sqlReader = SQLReader(fileName: sqlFileName)
    sqlReader.read()

    if sqlReader.commands.count > 0 {
        let sqlRunner = SQLRunner()
        for command in sqlReader.commands {
            sqlRunner.run(command: command)
        }
    } else {
        print("No commands found in \(sqlFileName)")
    }
}
