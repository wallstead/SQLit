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
        case .insert:
            insert(command)
        case .update:
            update(command)
        case .delete:
            delete(command)
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
            case .star, .into, .multiselect:
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
                finalPlainText.append("----------") // to seperate attribute info from the actual data
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
            case .star, .into, .multiselect:
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
        var tablename = ""
        if command.commandModifier == .multiselect {
            tablename = command.commandTextContent![3]
        } else {
            tablename = command.commandTextContent![0]
        }

        let filePath = Path(tablename)

        if !filePath.exists {
            print("!Failed to select \(tablename) because it does not exist.")
        } else {
            do {
                let fileString: String = try filePath.read()
                let attributeMeta = fileString.components(separatedBy: "----------")[0]

                if command.commandModifier == .multiselect {
                    /* first get names of cols being selected */
                    var selectedColumnNames: [String] = []
                    var columnIndex = 0
                    while command.commandTextContent![columnIndex] != "from" { // extract the column names we're looking for
                        let columnNameClean = command.commandTextContent![columnIndex].deletingSuffix(",")
                        selectedColumnNames.append(columnNameClean)
                        columnIndex = columnIndex + 1
                    }


                    /* print the attribute metadata */
                    var indexesToBePrinted: [Int] = []
                    let stringParts = attributeMeta.components(separatedBy: .newlines)
                    var finalPrintString = ""
                    for index in 0...stringParts.count-2 {
                        let attributeNameAndType = stringParts[index]
                        let attributeName = attributeNameAndType.components(separatedBy: " ")[0]

                        for selectedColumnName in selectedColumnNames {
                            if attributeName == selectedColumnName { // check if attribute name = one of the ones needed to be printed
                                indexesToBePrinted.append(index)
                                if index < stringParts.count-2 {
                                    finalPrintString.append(attributeNameAndType + "|")
                                } else {
                                    finalPrintString.append(attributeNameAndType)
                                }
                            }
                        }

                    }
                    print(finalPrintString)

                    let cleanCommandTextArray = cleanCommandTextArr(command.commandTextContent!)
                    let findWhereInfo = findWhere(cleanCommandTextArray, fileString: fileString, setting: false)
                    let printRows = findWhereInfo.0

                    let fileData = fileString.components(separatedBy: "----------")
                    if fileData.count > 1 {
                        let attributeData = fileData[1]
                        var rows = attributeData.components(separatedBy: .newlines)
                        rows.removeFirst()
                        for rowToPrint in printRows {
                            /* printing the chosen values from the row at rows[rowToPrint] */

                            let rowText = rows[rowToPrint]
                            let rowParts = rowText.components(separatedBy: "|")
                            /* create new array with only queried column data */
                            var newRowParts: [String] = []
                            for indexToBePrinted in indexesToBePrinted {
                                newRowParts.append(rowParts[indexToBePrinted])
                            }
                            /* create the final print string */
                            var rowString: String = ""
                            for dataIndex in 0...newRowParts.count-1 {
                                let cleanString = newRowParts[dataIndex].deletingPrefix("\'").deletingSuffix("\'") // removing the quotes from strings
                                if dataIndex < newRowParts.count-1 {
                                    rowString.append(cleanString + "|")
                                } else {
                                    rowString.append(cleanString)
                                }
                            }

                            print(rowString)
                        }
                    }


                } else {
                    /* print the attribute metadata */
                    let stringParts = attributeMeta.components(separatedBy: .newlines)
                    var finalPrintString = ""
                    for index in 0...stringParts.count-2 {
                        if index < stringParts.count-2 {
                            finalPrintString.append(stringParts[index] + "|")
                        } else {
                            finalPrintString.append(stringParts[index])
                        }
                    }
                    print(finalPrintString)
                    /* print the rows */
                    let fileData = fileString.components(separatedBy: "----------")
                    if fileData.count > 1 {
                        let attributeData = fileString.components(separatedBy: "----------")[1]
                        var rows = attributeData.components(separatedBy: .newlines)
                        rows.removeFirst()
                        for index in 0...rows.count-1 {
                            let rowDataArray = rows[index].components(separatedBy: "|")
                            var rowString: String = ""
                            for dataIndex in 0...rowDataArray.count-1 {
                                let cleanString = rowDataArray[dataIndex].deletingPrefix("\'").deletingSuffix("\'") // removing the quotes from strings
                                if dataIndex < rowDataArray.count-1 {
                                    rowString.append(cleanString + "|")
                                } else {
                                    rowString.append(cleanString)
                                }
                            }
                            print(rowString)

                        }
                    }
                }
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

    /* INSERT functions */

    func insert(_ command: Command) {
        let tablename = command.commandTextContent![0]
        let filePath = Path(tablename)

        if !filePath.exists {
            print("!Failed to insert into \(tablename) because it does not exist.")
        } else {
            do {
                let fileString: String = try filePath.read()
                var stringParts: [String] = fileString.components(separatedBy: "----------")
                let rows = stringParts[1]

                let cleanCommandTextArray = cleanCommandTextArr(command.commandTextContent!) // e.g. ["Product", "values(1,", "\'Gizmo\',", "19.99)"]
                var commandTextIndex = 1 // start at the second done
                var columnDataArray: [String] = []

                while (commandTextIndex < cleanCommandTextArray.count) {
                    let cleanColumn = cleanCommandTextArray[commandTextIndex].deletingPrefix("values(").deletingSuffix(")").deletingSuffix(",")
                    columnDataArray.append(cleanColumn)
                    commandTextIndex = commandTextIndex + 1
                }

                var newRow: String = ""
                for index in 0...columnDataArray.count-1 {
                    let columnData = columnDataArray[index]
                    if index == columnDataArray.count-1 {
                        newRow.append(columnData)
                    } else {
                        newRow.append(columnData + "|") // seperate columns by the pipe
                    }
                }

                let newRows = rows + "\n" + newRow
                stringParts[1] = "----------\n"
                stringParts.append(newRows.deletingPrefix("\n"))

                var finalPlainText: String = ""

                for index in 0...stringParts.count-1 {
                    finalPlainText.append(stringParts[index])
                }

                try filePath.write(finalPlainText)
                print("1 new record inserted.")

            } catch {
                print("Couldn't read table \(tablename)")
            }
        }

        // print(command.commandTextContent)
    }

    /* UPDATE functions */

    func update(_ command: Command) {
        let tablename = command.commandTextContent![0]
        let filePath = Path(tablename)

        if !filePath.exists {
            print("!Failed to update \(tablename) because it does not exist.")
        } else {
            do {
                let fileString: String = try filePath.read()


                let cleanCommandTextArray = cleanCommandTextArr(command.commandTextContent!)
                let findWhereInfo = findWhere(cleanCommandTextArray, fileString: fileString, setting: true)
                let affectedRows = findWhereInfo.0
                let attributeNewIndex = findWhereInfo.1
                let attributeNewValue = findWhereInfo.2

                var stringParts: [String] = fileString.components(separatedBy: "----------")
                let rows = stringParts[1]
                var rowsArray: [String] = rows.components(separatedBy: "\n")
                rowsArray.removeFirst()

                for affectedRow in affectedRows {


                    var rowDataArray = rowsArray[affectedRow].components(separatedBy: "|")
                    rowDataArray[attributeNewIndex] = attributeNewValue

                    var newRow: String = ""
                    for index in 0...rowDataArray.count-1 {
                        let rowData = rowDataArray[index]
                        if index == rowDataArray.count-1 {
                            newRow.append(rowData)
                        } else {
                            newRow.append(rowData + "|") // seperate columns by the pipe
                        }
                    }

                    rowsArray[affectedRow] = newRow
                    var rowsFinalText = ""
                    for index in 0...rowsArray.count-1 {
                        if index == rowsArray.count-1 {
                            rowsFinalText.append(rowsArray[index])
                        } else {
                            rowsFinalText.append(rowsArray[index] + "\n")
                        }
                    }

                    let finalFileString = stringParts[0] + "----------" + "\n" + rowsFinalText
                    _ = finalFileString.deletingSuffix("\n")

                    try filePath.write(finalFileString)
                }

                if affectedRows.count > 0 {
                    if affectedRows.count == 1 {
                        print("1 record modified.")
                    } else {
                        print("\(affectedRows.count) records modified.")
                    }
                } else {
                    print("0 records modified.")
                }
            } catch {
                print("Couldn't read table \(tablename)")
            }
        }
    }

    /* DELETE functions */

    func delete(_ command: Command) {
        let tablename = command.commandTextContent![1]
        let filePath = Path(tablename)

        if !filePath.exists {
            print("!Failed to delete from \(tablename) because it does not exist.")
        } else {
            do {

                let fileString: String = try filePath.read()
                let cleanCommandTextArray = cleanCommandTextArr(command.commandTextContent!)
                let findWhereInfo = findWhere(cleanCommandTextArray, fileString: fileString, setting: false)
                let rowsToDelete = findWhereInfo.0.reversed() // reversed to aid in deletion


                var stringParts: [String] = fileString.components(separatedBy: "----------")
                let rows = stringParts[1]
                var rowsArray: [String] = rows.components(separatedBy: "\n")
                rowsArray.removeFirst()

                for rowToDeleteIndex in rowsToDelete {
                    rowsArray.remove(at: rowToDeleteIndex)
                }

                var rowsFinalText = ""
                for index in 0...rowsArray.count-1 {
                    if index == rowsArray.count-1 {
                        rowsFinalText.append(rowsArray[index])
                    } else {
                        rowsFinalText.append(rowsArray[index] + "\n")
                    }
                }

                let finalFileString = stringParts[0] + "----------" + "\n" + rowsFinalText
                _ = finalFileString.deletingSuffix("\n")

                try filePath.write(finalFileString)

                if rowsToDelete.count > 0 {
                    if rowsToDelete.count == 1 {
                        print("1 record deleted.")
                    } else {
                        print("\(rowsToDelete.count) records deleted.")
                    }
                } else {
                    print("0 records deleted.")
                }

            } catch {
                print("Couldn't read table \(tablename)")
            }
        }
    }

    /* .EXIT function */

    func exit() {
        print("All done.")
    }

    /* WHERE helper */

    func findWhere(_ cleanCommandTextArray: [String], fileString: String, setting: Bool) -> ([Int], Int, String) { // returns (row indexes that apply to where comparison, new attribute index, new value)
        var stringParts: [String] = fileString.components(separatedBy: "----------")
        let attributeInfo = stringParts[0]
        let rows = stringParts[1]
        var affectedRowIndeces: [Int] = []

        /* Find the index of the where keyword */
        var whereIndex = 0
        while cleanCommandTextArray[whereIndex].uppercased() != "WHERE" {
            whereIndex = whereIndex + 1
        }


        let attributeNameIndex = whereIndex + 1
        let attributeName = cleanCommandTextArray[attributeNameIndex]

        var attributeInfoArray = attributeInfo.components(separatedBy: "\n")
        attributeInfoArray.removeLast()


        var attributeIndex = 0; // to keep track of which attribute to change
        for index in 0...attributeInfoArray.count-1 {
            if attributeName == attributeInfoArray[index].components(separatedBy: " ")[0] {
                attributeIndex = index // found match
            }
        }

        /* Find the index of the where keyword */
        var rowsArray: [String] = rows.components(separatedBy: "\n")
        rowsArray.removeFirst()

        let attributeComparatorIndex = attributeNameIndex + 1
        let attributeComparator = cleanCommandTextArray[attributeComparatorIndex] // e.g. '='

        let attributeSelectorIndex = attributeComparatorIndex + 1
        let attributeSelector = cleanCommandTextArray[attributeSelectorIndex] // e.g. '29'

        let attributeNewValIndex = whereIndex - 1
        let attributeNewVal = cleanCommandTextArray[attributeNewValIndex] // e.g. '22'

        for index in 0...rowsArray.count-1 {
            let row = rowsArray[index]
            let rowDataArray = row.components(separatedBy: "|")

            if attributeComparator == "=" {
                if rowDataArray[attributeIndex] == attributeSelector {
                    affectedRowIndeces.append(index)
                }
            } else if attributeComparator == ">" {
                if let attributeSelectorToTest = Float(rowDataArray[attributeIndex]) {
                    if let attributeSelectorFloat = Float(attributeSelector) {
                        // print("\(attributeSelectorToTest) and \(attributeSelectorFloat)")
                        if attributeSelectorToTest > attributeSelectorFloat {
                            // print("\(rowDataArray[attributeIndex]) > \(attributeSelector)")
                            affectedRowIndeces.append(index)
                        }
                    }
                }

            } else if attributeComparator == "!=" {
                if rowDataArray[attributeIndex] != attributeSelector {
                    affectedRowIndeces.append(index)
                }
            }
        }
        /* Find the index of the set keyword */
        if setting {
            let attributeSetIndex = attributeNewValIndex - 2
            let attributeToSet = cleanCommandTextArray[attributeSetIndex]


            var attributeToChangeIndex = 0; // to keep track of which attribute to change
            for index in 0...attributeInfoArray.count-1 {
                if attributeToSet == attributeInfoArray[index].components(separatedBy: " ")[0] {
                    attributeToChangeIndex = index // found match
                }
            }

            return (affectedRowIndeces, attributeToChangeIndex, attributeNewVal)
        }

        return (affectedRowIndeces, 0, "")
    }

}

/* Misc other funcitons */

func cleanCommandTextArr(_ originalCommandTextArr: [String]) -> [String] {
    var newCommandTextArr: [String] = []
    var index = 0;
    while ((index < originalCommandTextArr.count) && (originalCommandTextArr[index] != "--")) { // go until end of string array or until comments
        if originalCommandTextArr[index] != "" { // ignore empty strings
            newCommandTextArr.append(originalCommandTextArr[index])
        }
        index = index + 1
    }

    return newCommandTextArr
}

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }

    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
}
