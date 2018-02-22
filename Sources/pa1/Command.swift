
/* This enum is to better organize base commands */
enum BaseCommand: String {
    case create = "CREATE"
    case drop = "DROP"
    case use = "USE"
    case select = "SELECT"
    case alter = "ALTER"
    case exit = ".EXIT"
}

/* This enum is to better organize command modifiers */
enum CommandModifier: String {
    case database = "DATABASE"
    case table = "TABLE"
    case star = "*"
}

/* This enum is to better organize the select command modifiers.. Will probably be changed in future versions */
enum CommandModifierModifier: String {
    case from = "FROM"
}

/* The Command class is used to register command strings in a more programmatic way for running the SQL */
class Command {
    let baseCommand: BaseCommand
    let commandModifier: CommandModifier?
    let commandModifierModifier: CommandModifierModifier?
    let commandTextContent: [String]? // e.g. 'tbl_1 (a1 int);'

    init?(commandString: String) {
        let separatedString = commandString.components(separatedBy: .whitespaces)
        let baseString = separatedString[0]

        if separatedString.count > 1 { // the exit string will have only one command
            let modifierString = separatedString[1]

            if let baseCmd = BaseCommand(rawValue: baseString) {
                baseCommand = baseCmd

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

                    if baseCmd == .use {
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
            } else {
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
