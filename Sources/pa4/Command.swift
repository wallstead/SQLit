/* 
    Command.swift
    Author: Willis Allstead
    Date: 4/14/18
*/

/* This enum is to better organize base commands */
enum BaseCommand: String {
    case create = "CREATE"
    case drop = "DROP"
    case use = "USE"
    case select = "SELECT"
    case alter = "ALTER"
    case insert = "INSERT"
    case update = "UPDATE"
    case delete = "DELETE"
    case exit = ".EXIT"
}

/* This enum is to better organize command modifiers */
enum CommandModifier: String {
    case database = "DATABASE"
    case table = "TABLE"
    case star = "*"
    case into = "INTO"
    case multiselect = "MULTISELECT"
}

/* This enum is to better organize the select command modifiers.. Will probably be changed in future versions */
enum CommandModifierModifier: String {
    case from = "FROM"
}

/* The Command class is used to register command strings in a more programmatic way for running the SQL */
class Command {
    let baseCommand: BaseCommand
    var commandModifier: CommandModifier?
    let commandModifierModifier: CommandModifierModifier?
    let commandTextContent: [String]? // e.g. 'tbl_1 (a1 int);'

    init?(commandString: String) {
        var separatedString = commandString.components(separatedBy: .whitespaces)
        let baseString = separatedString[0].uppercased()
        if separatedString.count > 1 { // the exit string will have only one command
            let modifierString = separatedString[1].uppercased()


            if let baseCmd = BaseCommand(rawValue: baseString) {
                baseCommand = baseCmd

                if baseCmd == .select && modifierString != "*" {

                    commandModifier = .multiselect
                    commandModifierModifier = nil

                    let textContentStartIndex = 1
                    let cmdStringArrayLength = separatedString.count
                    var textContent: [String] = []

                    if cmdStringArrayLength >= textContentStartIndex {
                        for index in textContentStartIndex...cmdStringArrayLength-1 {
                            textContent.append(separatedString[index]) // append parts of command string into a single textContent string
                        }

                        commandTextContent = textContent
                    } else {
                        commandTextContent = nil
                    }

                } else {
                    if let cmdModifier = CommandModifier(rawValue: modifierString) {
                        commandModifier = cmdModifier

                        if cmdModifier == .star { // in the case of '* FROM' and later '<colName> FROM'
                            let modifierModifierString = separatedString[2]

                            if let cmdModifierModifier = CommandModifierModifier(rawValue: modifierModifierString) {
                                commandModifierModifier = cmdModifierModifier
                            } else {
                                commandModifierModifier = nil
                            }

                            let textContentStartIndex = 3
                            let cmdStringArrayLength = separatedString.count
                            var textContent: [String] = []

                            if cmdStringArrayLength >= textContentStartIndex {
                                for index in textContentStartIndex...cmdStringArrayLength-1 {
                                    textContent.append(separatedString[index]) // append parts of command string into a single textContent string
                                }

                                commandTextContent = textContent
                            } else {
                                commandTextContent = nil
                            }
                        } else if cmdModifier == .into {
                            commandModifierModifier = nil

                            let textContentStartIndex = 2

                            let cmdStringArrayLength = separatedString.count
                            var textContent: [String] = []

                            if cmdStringArrayLength >= textContentStartIndex {
                                for index in textContentStartIndex...cmdStringArrayLength-1 {
                                    textContent.append(separatedString[index]) // append parts of command string into a single textContent string
                                }

                                commandTextContent = textContent
                            } else {
                                commandTextContent = nil
                            }
                        } else if cmdModifier == .table {
                            // print("yo")
                            commandModifierModifier = nil

                            // if separatedString looks like this: ["create", "table", "Employee(id", "int,", "name", "varchar(10))"]
                            // change to this: ["create", "table", "Employee", "(id", "int,", "name", "varchar(10))"]


                            let textContentStartIndex = 2

                            let tableNameAndFirstCol = separatedString[textContentStartIndex].components(separatedBy: "(")
                            if tableNameAndFirstCol.count > 1 { // if of the form ["Employee(id"] -> ["Employee", "(id"]
                                separatedString[textContentStartIndex] = tableNameAndFirstCol[0]
                                separatedString.insert("(" + tableNameAndFirstCol[1], at: textContentStartIndex+1)
                            }

                            let cmdStringArrayLength = separatedString.count
                            var textContent: [String] = []

                            if cmdStringArrayLength >= textContentStartIndex {
                                for index in textContentStartIndex...cmdStringArrayLength-1 {
                                    textContent.append(separatedString[index]) // append parts of command string into a single textContent string
                                }

                                commandTextContent = textContent
                            } else {
                                commandTextContent = nil
                            }
                        } else {
                            commandModifierModifier = nil

                            let textContentStartIndex = 2

                            let cmdStringArrayLength = separatedString.count
                            var textContent: [String] = []

                            if cmdStringArrayLength >= textContentStartIndex {
                                for index in textContentStartIndex...cmdStringArrayLength-1 {
                                    textContent.append(separatedString[index]) // append parts of command string into a single textContent string
                                }

                                commandTextContent = textContent
                            } else {
                                commandTextContent = nil
                            }
                        }
                    } else {
                        commandModifier = nil
                        commandModifierModifier = nil

                        if baseCmd == .use || baseCmd == .update || baseCmd == .delete {
                            let textContentStartIndex = 1

                            let cmdStringArrayLength = separatedString.count
                            var textContent: [String] = []

                            if cmdStringArrayLength >= textContentStartIndex {
                                for index in textContentStartIndex...cmdStringArrayLength-1 {
                                    textContent.append(separatedString[index]) // append parts of command string into a single textContent string
                                }

                                commandTextContent = textContent
                            } else {
                                commandTextContent = nil
                            }
                        } else {
                            commandTextContent = nil
                        }
                    }
                }
            } else {
                print("ERROR Creating Base Command With: '\(baseString)'")
                return nil
            }
        } else {
            if let baseCmd = BaseCommand(rawValue: baseString) {
                baseCommand = baseCmd
                commandModifier = nil
                commandModifierModifier = nil
                commandTextContent = nil
            } else {
                return nil
            }
        }
    }
}
