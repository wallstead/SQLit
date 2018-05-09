/*
    main.swift
    Author: Willis Allstead
    Date: 4/14/18
*/

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

// ACID: Atomic, Consistent, Isolation, Durable

import PathKit

let startPath = Path.current

var command = ""
let sqlRunner = SQLRunner(path: startPath)

while let inLine = readLine() { // get the line from stdin

    let lineComponents = inLine.replacingOccurrences(of: ",", with: ", ").components(separatedBy: .whitespaces) // seperate the line by whitespaces
    let cleanLineComponents = cleanCommandTextArr(lineComponents)

    if !inLine.hasPrefix("--") && inLine.count != 0 {

        if inLine.range(of:";") == nil { // doesn't contain semicolon

            for lineComponent in cleanLineComponents {
                command.append(lineComponent + " ")
            }
        } else { // contains semicolon
            for lineComponent in cleanLineComponents {
                command.append(lineComponent + " ")
            }
            /* Register and run the command */
            let commandStringSansSemiColon = command.replacingOccurrences(of: "; ", with: "")

            if let command = Command(commandString: commandStringSansSemiColon) {
                
                sqlRunner.run(command: command)
            } else {
                print("ERROR Parsing Command String: '\(commandStringSansSemiColon)'")
            }

            command = "" // reset command
        }
    }
}
