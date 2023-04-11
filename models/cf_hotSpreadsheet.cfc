/**
 * This component contains the definition of the cf_hotSpreadsheet object, the core functionality
 * of the cf_hotSpreadsheet module in Coldfusion.
 */
component
{


    //Basic constructor
    cf_hotSpreadsheet function init()
    {
        return this;
    }


    /**
     * Given a string intended to represent a table name in SQL Server, determine if the name of the table
     * is valid and possibly exists in the database.
     *
     * @tableName A string intended to represent a SQL Server table name
     * @checkIfExists A boolean indicating if we would like to check to see if the table exists or not.
     *                By default, it is set to false, meaning that we will not check to see if a table
     *                exists by default.
     *
     *
     * @return Boolean. True if the table name is valid in SQL Server and exists in the database. False otherwise.
     */
    private boolean function validateSQLServerTable(required string tableName, boolean checkIfExists = false)
    {
        if(arguments.checkIfExists)
        {
            //Get the names of all of the tables in the database
            local.tableNameQuery = queryExecute("SELECT name FROM sys.tables");
            local.tableNames = valueArray(local.tableNameQuery, "name");
            //See if the tableName we are validating is in the list of table names
            if(local.tableNames.find(arguments.tableName))
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        return true;
    }


    /**
     * Given an array of strings intending to represent the names of columns in SQL Server, determine if the names
     * of the columns are valid and possibly exist in a given table in the database.
     *
     * @columnNames An array of column names intended to represent names of a table's column in SQL Server.
     * @checkIfInTable A string of the table's name we are checking to see if the column names are a part of.
     *                 An empty string indicates that we don't want to check to see if the column names are part
     *                 of a specific table.
     *
     * @return
     */
    private boolean function validateSQLServerColumns(required array columnNames, string checkIfInTable = "")
    {
        if(arguments.checkIfInTable != "")
        {
            //Query for the table we are checking for columns
            local.queryResult = queryExecute("SELECT * FROM #checkIfInTable#");
            local.qMetaData = local.queryResult.getMetaData();
            //Build an array of columns from the query
            local.queriedColumnNames = [];
            for(local.i = 1; local.i <= local.qMetaData.getColumnCount(); local.i++)
            {
                local.queriedColumnNames.push(local.qMetaData.getColumnName(local.i));
            }
            //Check to see if each column we passed in is found in our queried column name array
            for(local.i = 1; local.i <= arguments.columnNames.len(); local.i++)
            {
                if(!local.queriedColumnNames.find(arguments.columnNames[local.i]))
                {
                    return false;
                }
            }
            return true;
        }

        return true;
    }





    /**
     * Given a variable, determine what data type it should be stored as in a SQL Server table.
     *
     * @var A variable of any type that will be assigned, based on its typing and value,
     *      a SQL Server data type.
     *
     * @return The data type assigned to the parameter var.
     */
    private string function getSQLServerDataType(required var)
    {
        //Get the JVM type of the variable
        local.type = getMetaData(arguments.var).getName()

        //Assign it an SQL Server data type
        if(local.type == "coldfusion.runtime.CFDouble")
        {
            //Double becomes NUMERIC
            return "NUMERIC";
        }
        else if(local.type == "java.lang.Integer")
        {
            //Integer becomes INTEGER
            return "INTEGER";
        }
        else if(local.type == "java.lang.String")
        {
            //String becomes VARCHAR(MAX) (may change later based off of storage needs)
            return "VARCHAR(MAX)";
        }
        else if(local.type == "coldfusion.runtime.CFBoolean")
        {
            //Boolean becomes BIT
            return "BIT";
        }
        else if(local.type == "coldfusion.runtime.OleDateTime")
        {
            //DateTime becomes DATETIME
            return "DATETIME";
        }
        else if(local.type == "coldfusion.runtime.Array")
        {
            //Array becomes VARCHAR(MAX)
            return "VARCHAR(MAX)";
        }
        else if(local.type == "coldfusion.runtime.Struct")
        {
            //Structure becomes VARCHAR(MAX)
            return "VARCHAR(MAX)";
        }
        else
        {
            //Anything else we may have missed becomes a VARCHAR(MAX)
            return "VARCHAR(MAX)";
        }
    }


    /**
     * Given a struct, return an array containing all of its values of its keys.
     *
     * @structParam The struct that we want to get the values of.
     *
     * @return An array of all of the values of the keys in the struct parameter.
     */
    private array function structValueArray(required struct structParam)
    {
        local.keyArray = arguments.structParam.keyArray();
        local.outputArray = [];
        for(local.i = 1; local.i <= local.keyArray.len(); local.i++)
        {
            local.outputArray.push(arguments.structParam[local.keyArray[local.i]]);
        }
        return local.outputArray;
    }


    /**
     * Saves an array of arrays to SQL Server by executing update and insert statements on a
     * a table so that it matches the array of arrays. Intended to be used to save handsontable
     * spreadsheets to the database. In order to work, the table that you are updating must
     * have a primary key/unique column to target individual rows with update statements.
     *
     *
     * @tableName The name of the table in the SQL database that you wish to update with the data from a handsontable instance.
     * @data An array of arrays representing data from a handsontable spreadsheet instance.
     * @columnsToUpdate A struct that describes the relationship between the columns in the data argument and the respective
     *                  tables in the database that you would like them to update. If empty, no columns will be updated.
     *                  To update all columns, pass in a struct containing keys of all of the columns in the data argument
     *                  paired with values that match columns in the SQL Server table you would like to update.
     * @primaryKeyColumn A struct with a single key-value pair that describes the relationship between the column in the
     *                   data argument with the column in the SQL database that hold information about the primary keys.
     * @columnHeaders An array containing the names of the columns of the passed-in handsontable spreadsheet data in order.
     *                If empty, we assume that the first array in the in data array of arrays argument contains the column
     *                headers. Default is an empty array.
     * @skipRows The number of rows from the top of the table to omit updating. Default is 0.
     *
     * @return Void
     */
    void function saveTable(    required string tableName,
                                required array data,
                                required struct columnsToUpdate,
                                required struct primaryKeyColumn,
                                array columnHeaders = [],
                                numeric skipRows = 0    )
    {
        /***** Validate the name of the table and the columns we are passing in *****/
        //Validate the table name we are passing in
        if(!validateSQLServerTable(arguments.tableName, true))
        {
            return;
        }
        //Checks to see if the arguments.columnHeaders array is empty. If so, we treat the first array in
        //arguments.data as the column headers.
        if(arguments.columnHeaders.len() == 0)
        {
            arguments.columnHeaders = arguments.data[arguments.skipRows + 1];
            arguments.skipRows += 1;
        }
        //Validate the column names we are passing in
        if(!validateSQLServerColumns(arguments.columnHeaders, arguments.tableName))
        {
            return;
        }

        /***** Make some necessary preparations before we start building queries *****/
        //Check to see if the user included the primary key column in the columns to be updated
        //We aren't letting users updating primary keys with this function, so we just delete it from the array
        //to eliminate potential problems.
        local.primaryKeyColumn_inData = arguments.primaryKeyColumn.keyArray()[1];
        if(arguments.columnsToUpdate.keyExists(local.primaryKeyColumn_inData))
        {
            arguments.columnsToUpdate.delete(local.primaryKeyColumn_inData);
        }
        //Before we start constructing a query to update our database table, query the database to grab a
        //version of the table pre-update. This way, we'll have a reference for checking to see if certain primary
        //keys exist or not.
        local.tablePreupdate = queryExecute(   "SELECT * FROM #arguments.tableName#;"   );
        local.preupdatePkArray = valueArray(local.tablePreupdate, arguments.primaryKeyColumn[local.primaryKeyColumn_inData]);
        //We do some transformations on the columnsToUpdate structure, just for utility
        local.columnsToUpdateKeys = arguments.columnsToUpdate.keyArray(); //Names of the columns in arguments.data
        local.sqlColumnsToUpdate = structValueArray(arguments.columnsToUpdate); //Names of the columns in SQL Database
        local.sqlColumnsToUpdateList = arrayToList(local.sqlColumnsToUpdate);


        /***** Iteratively build and execute queries ****/
        //Build a chunky query string and an array of parameters for each row we are updating
        local.updateQueryString = "";
        local.updateParameters = [];
        local.rowsPreparedToUpdate = 0;
        //Same as above, but these will be used for insert statements
        local.insertQueryString = "INSERT INTO #tableName# (" & local.sqlColumnsToUpdateList & ")
                                    VALUES";
        local.insertParameters = [];
        local.rowsPreparedToInsert = 0;
        for(local.row = (1 + skipRows); local.row <= arguments.data.len(); local.row++)
        {
            //Give null pks a temporary value that will hopefully never be a PK in any sane table (still a weakness of this project)
            if(!arrayIsDefined(arguments.data[local.row], arguments.columnHeaders.find(local.primaryKeyColumn_inData)))
            {
                local.rowPk = "$null$";
            }
            else
            {
                local.rowPk = arguments.data[local.row][arguments.columnHeaders.find(local.primaryKeyColumn_inData)];
            }
            //Check to see if the row we are looking at has a primary key that exists in the database
            if(local.preupdatePkArray.find(local.rowPk))
            {
                //Found the PK in the pre-update database -- This means we can add to our UPDATE query
                //Check to see if we'll be maxing out our parameters by building this query
                if((local.updateParameters.len() + local.columnsToUpdateKeys.len() + 1) >= 2100)
                {
                    //Check to see if we haven't even prepared a row to update
                    if(local.rowsPreparedToUpdate == 0)
                    {
                        throw(  "You are trying to update #local.columnsToUpdateKeys.len()# columns. cf_hotSpreadsheet can only update a maximum of 2099 columns.",
                                "updateTooLarge"    );
                    }
                    //We've maxed out the number of parameters we can send in one query
                    //Execute the query we've built up thus far
                    //writeOutput(local.queryString);
                    queryExecute(local.updateQueryString, local.updateParameters);
                    //Reset the querystring and the parameters
                    local.updateQueryString = "";
                    local.updateParameters = [];
                    local.rowsPreparedToUpdate = 0;
                }
                //Set up the start of the row update query
                local.updateQueryString &= "
                                    UPDATE #tableName#
                                    SET ";
                //For each column we are updating, add it to the query string
                local.columnsUpdated = 0;
                for(local.col = 1; local.col <= arguments.columnHeaders.len(); local.col++)
                {
                    //Check to see if the column we are looking at is one that is being updated (making sure that it's not the primaryKeyColumn)
                    if( arguments.columnsToUpdate.keyExists(arguments.columnHeaders[local.col]) )
                    {
                        local.updateQueryString &= "#arguments.columnsToUpdate[arguments.columnHeaders[local.col]]# = ?";
                        //Push the parameter that this cell of data is being set to
                        local.updateParameters.push(arguments.data[local.row][local.col]);
                        local.columnsUpdated += 1;
                        //Check to see if we have more columns we are updating (may need to add a comma an newline to the query)
                        if(local.columnsUpdated < local.columnsToUpdateKeys.len())
                        {
                            local.updateQueryString &= ",
                                    ";
                        }
                    }
                }
                //Add a WHERE clause to the SQL statement we just built
                local.updateQueryString &= "
                                    WHERE #arguments.primaryKeyColumn[local.primaryKeyColumn_inData]# = ?";
                local.updateParameters.push(local.rowPk);
                //Add space between the next update statement
                local.updateQueryString &= "
                                ";
                //Increment the current number of rows we are updating
                local.rowsPreparedToUpdate += 1;
            }
            else
            {
                //Did not find the PK in the pre-update database -- This means that we can add to our INSERT query
                //Check to see if we'll be maxing out our parameters by building this query
                if((local.insertParameters.len() + local.columnsToUpdateKeys.len() + 1) >= 2100)
                {
                    if(local.rowsPreparedToInsert == 0)
                    {
                        throw(  "You are trying to insert #local.columnsToUpdateKeys.len()# columns. cf_hotSpreadsheet can only insert a maximum of 2099 columns.",
                                "insertTooLarge"  );
                    }
                    //We've maxed out the number of parameters we can send in one query
                    //Execute the query we've built up thus far
                    queryExecute(local.insertQueryString, local.insertParameters);
                    //Reset the querystring and the parameters
                    local.insertQueryString = "";
                    local.insertParameters = [];
                }
                //Set up the start of the row insert query
                if(local.rowsPreparedToInsert > 0)
                {
                    local.insertQueryString &= ",(";
                }
                else
                {
                    local.insertQueryString &= "(";
                }
                local.columnsInserted = 0;
                //Add the list of columns we are inserting
                for(local.col = 1; local.col <= local.columnsToUpdateKeys.len(); local.col++)
                {
                    local.dataToInsert = arguments.data[local.row][arguments.columnHeaders.find(local.columnsToUpdateKeys[local.col])];
                    local.insertQueryString &= "?";
                    local.insertParameters.push(local.dataToInsert);
                    local.columnsInserted += 1;
                    //Check to see if we have more columns we are inserting (may need to add a comma an newline to the query)
                    if(local.columnsInserted < local.columnsToUpdateKeys.len())
                    {
                        local.insertQueryString &= ",";
                    }
                }
                //Close the current row we are inserting and add some space before we insert the next one
                local.insertQueryString &= ")
                ";
                //Increment the number of rows we have prepared to insert
                local.rowsPreparedToInsert += 1;
            }
        }

        //If we still have a query to execute after going through our main query building loop, we do that here
        if(local.rowsPreparedToUpdate > 0)
        {
            // writeOutput(local.updateQueryString);
            // writeOutput(serializeJSON(local.updateParameters));
            queryExecute(local.updateQueryString, local.updateParameters);
        }
        if(local.rowsPreparedToInsert > 0)
        {
            // writeOutput(local.insertQueryString);
            // writeOutput(serializeJSON(local.insertParameters));
            queryExecute(local.insertQueryString, local.insertParameters);
        }

        return;
    }


    // /**
    //  * Creates a table in your SQL server database by taking an array of arrays, where each array contained
    //  * represents a row in the table, and inserting them into a newly created SQL server table that has
    //  * the properties which you specify as parameters to this function.
    //  *
    //  * @tableName The name of the table that you wish to create.
    //  * @data An array of arrays which represents the rows of data to insert into the SQL table.
    //  * @columnsToCreate An array of names of the columns that you wish to create in the database.
    //  *                  They must match the entries in the column headers array that you wish to
    //  *                  create in the database.
    //  * @primaryKeyColumn The name of column within arguments.columnsToCreate which will serve as the
    //  *                   primary key of the newly created table.
    //  * @columnHeaders   An array of all of the column headers of the data. If empty, then we set this
    //  *                  variable equal to the first array contained in arguments.data.
    //  */
    // void function createTable(  required string tableName,
    //                             required array data,
    //                             required array columnsToCreate,
    //                             required string primaryKeyColumn,
    //                             array columnHeaders = [],
    //                             numeric skipRows = 0 )
    // {
    //     /***** Validate the table name and column names *****/
    //     //Validate the table name we are passing in
    //     if(!validateSQLServerTable(arguments.tableName))
    //     {
    //         return;
    //     }
    //     //Checks to see if the arguments.columnHeaders array is empty. If so, we treat the first array in
    //     //arguments.data as the column headers.
    //     if(arguments.columnHeaders.len() == 0)
    //     {
    //         arguments.columnHeaders = arguments.data[arguments.skipRows + 1];
    //         arguments.skipRows += 1;
    //     }
    //     //Validate the column names we are passing in
    //     if(!validateSQLServerColumns(arguments.columnHeaders))
    //     {
    //         return;
    //     }

    //     /***** Create the table in the database *****/
    //     local.queryString = "CREATE TABLE #arguments.tableName#(";
    //     for(local.col = 1; local.col <= arguments.columnsToCreate.len(); local.col++)
    //     {
    //         //Examine the types of data in the first array of data to decide what the datatypes of the columns
    //         //in the SQL server should be.
    //         local.columnDataType = getSQLServerDataType(arguments.data[1 + arguments.skipRows][arguments.columnHeaders.find(arguments.columnsToCreate[local.col])]);
    //         local.queryString &= columnsToCreate[local.col] & " " & local.columnDataType
    //     }

    //     /*****  We have temporarily halted development of this function as we do not need to make SQL Server tables adhoc *****/
    // }


    /**
     * Converts a query object into an array of arrays, where each row in the query
     * object, starting with the column headers, becomes an array that is pushed to
     * a containing array.
     *
     * For example, a query object that look like this:
     * row      name        job     lightsaber
     * 1        Luke        Jedi    Blue
     * 2        Vader       Sith    Red
     * 3        Mace        Jedi    Purple
     *
     * Will be converted to an array of arrays like this:
     * [[name, job, lightsaber],
     *  [Luke, Jedi, Blue],
     *  [Vader, Sith, Red],
     *  [Mace, Jedi, Purple]]
     *
     * @q The query object you want to convert to an array of arrays.
     * @includeColumnHeadersInData A boolean indicating whether or not to include the headers of columns as the first array
     *
     * @return The array of arrays that represents the converted query object.
     */
    array function convertQueryToArrayOfArrays(query q, boolean includeColumnHeadersInData = true)
    {
        //Declare the array we will eventually return
        local.arrayOfArrays = [];
        local.qMetaData = q.getMetaData();
        //Get an ordered list of the columns of the query to reference when constructing the arrays to push to the array of arrays
        local.orderedColumnLabels = [];
        for(local.i = 1; local.i <= local.qMetaData.getColumnCount(); local.i++)
        {
            local.orderedColumnLabels.push(local.qMetaData.getColumnName(local.i));
        }
        if(arguments.includeColumnHeadersInData)
        {
            local.arrayOfArrays.push(local.orderedColumnLabels);
        }
        //Get the values of each column and store them in an array, then push the array into our array of arrays
        for(local.i = 1; local.i <= q.recordCount(); local.i++)
        {
            //Start with an array of a size equal to the number of columns you have
            local.arrayToPush = [];
            for(local.n = 1; local.n <= local.qMetaData.getColumnCount(); local.n++)
            {
                local.arrayToPush.push("");
            }
            local.row = q.getRow(local.i);
            //Fill the array we intend to push to our array of arrays with values from the query
            for(local.k = 1; local.k <= local.arrayToPush.len(); local.k++)
            {
                local.arrayToPush[local.k] = local.row[local.orderedColumnLabels[local.k]];
            }
            local.arrayOfArrays.push(local.arrayToPush);
        }
        return local.arrayOfArrays;
    }


    /**
     * Converts a coldfusion query object to an array of structures, where each row of the 
     * coldfusion query object becomes a structure pushed to an array in the order which
     * it appears in in the query.
     * 
     * For example, a query object that look like this:
     * row      name        job     lightsaber
     * 1        Luke        Jedi    Blue
     * 2        Vader       Sith    Red
     * 3        Mace        Jedi    Purple
     *
     * Will be converted to an array of arrays like this:
     * [{"name" : "Luke", "job" : "Jedi", "lightsaber" : "Blue"},
     *  {"name" : "Vader", "job" : "Sith", "lightsaber" : "Red"},
     *  {"name" : "Mace", "job" : "Jedi", "lightsaber" : "Purple"},
     *  ]
     * 
     * @q The query object you want to convert to an array of structures.
     * @includeColumnHeadersInData A boolean indicating whether or not to include the headers of columns as the first structure
     * 
     * @return The array of structures that represents the converted query object.
     */
    array function convertQueryToArrayOfStructures(query q, boolean includeColumnHeadersInData = true)
    {
        //Declare the array we will eventually return
        local.arrayOfStructs = [];
        local.qMetaData = q.getMetaData();
        //Get an ordered list of the columns of the query to reference when constructing the arrays to push to the array of structs
        local.orderedColumnLabels = [];
        for(local.i = 1; local.i <= local.qMetaData.getColumnCount(); local.i++)
        {
            local.orderedColumnLabels.push(local.qMetaData.getColumnName(local.i));
        }
        if(arguments.includeColumnHeadersInData)
        {
            //Get the column titles and add them to a struct
            local.columnLabelStruct = {};
            for(local.i = 1; local.i <= local.qMetaData.getColumnCount(); local.i++)
            {
                local.columnLabelStruct[local.orderedColumnLabels[local.i]] = local.orderedColumnLabels[local.i];
            }
            local.arrayOfStructs.push(local.columnLabelStruct);
        }
        //Get the values of each column and store them in a struct, then push the array into our array of struct
        for(local.i = 1; local.i <= q.recordCount(); local.i++)
        {
            //Start with an empty struct
            local.structToPush = {};
            local.row = q.getRow(local.i);
            //Fill the struct we intend to push to our array of structs with values from the query
            for(local.k = 1; local.k <= local.qMetaData.getColumnCount(); local.k++)
            {
                local.structToPush[local.orderedColumnLabels[local.k]] = local.row[local.orderedColumnLabels[local.k]];
            }
            local.arrayOfStructs.push(local.structToPush);
        }
        return local.arrayOfStructs;
    }
}