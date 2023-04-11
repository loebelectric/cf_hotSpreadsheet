<cfoutput>
	<!---
		In this example, we show you how to save the data from your handsontable
		instances to existing tables in SQL databases. You can modify the existing
		code to support other databases, but it only supports SQL at the moment.
		(Tested using SQL Server)
	--->


	<!--- Coldfusion:
		Create a query that we will convert into an array of structures. We can use
		arrays of arrays or arrays of structures for our data parameter when creating
		a handsontable instance, and this is just an example for using arrays of structures.
	--->
	<cfscript>
		//Here's an example query that we're constructing programmatically
        variables.query = queryNew("id,name", "integer,varchar");
        queryAddRow(variables.query);
        querySetCell(variables.query, "id", "1");
        querySetCell(variables.query, "name", "Gary");
        queryAddRow(variables.query);
        querySetCell(variables.query, "id", "2");
        querySetCell(variables.query, "name", "Andrew");
        queryAddRow(variables.query);
        querySetCell(variables.query, "id", "3");
        querySetCell(variables.query, "name", "Debbie");
        //We'll convert this query using cf_hotSpreadsheet to an array of structures;
		//one of the formats used by handsontable
        variables.cf_hotSpreadsheet = new modules.cf_hotSpreadsheet.models.cf_hotSpreadsheet();
        variables.cf_data = variables.cf_hotSpreadsheet.convertQueryToArrayOfStructures(variables.query);
	</cfscript>


    <!--- HTML:
		Define a save button right above the div that
		will store our handsontable instance.
	--->
    <h2 align="center">Saving a table to a SQL Database</h2>
    <br/>
    <button id="saveHotButton" type="button" class="btn btn-primary">
        Save
    </button>
    <br/>
    <div id="handsontable-div">
    </div>


	<!---
		Javascript:
		Import the libraries and styles for handsontable and create our handsontable
		instance. In addition, define an event for clicking the save button.
	--->
    <!--- Get Handsontable's script and style files via CDN links --->
    <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/handsontable/dist/handsontable.full.min.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/handsontable/dist/handsontable.full.min.css">
    <!--- Make our table within the following javascript --->
    <script>
        //Find the div that our hands on table instance is going live in
        const container = document.querySelector('##handsontable-div');
        //Cast our Coldfusion data structure to a javascript object
        var #toScript(variables.cf_data, "js_data_arrayOfObjects")#;
        //Create the handsontable object
        const hot = new Handsontable(container, {
            data: js_data_arrayOfObjects,
            rowHeaders: true,
            colHeaders: ["id", "name"],
            columns: [
                        { data: "id" },
                        { data: "name" },
                    ],
            contextMenu: true,
            height: 'auto',
            width: 'auto',
            licenseKey: 'non-commercial-and-evaluation' // for non-commercial use only
        });


        //Set up the save button's onclick event
        var saveButton = document.getElementById("saveHotButton");
        saveButton.addEventListener('click', () => {
        // save all cell's data
        fetch('#event.buildLink("hot_saving_changes_handler.save")#', {
            method: 'POST',
            mode: 'no-cors',
            headers: {
            'Content-Type': 'application/json'
            },
            body: JSON.stringify({  "tableName"         : "example_table",
                                    "data"              : hot.getData(),
                                    "columnsToUpdate"   : { "name" : "name" },
                                    "primaryKeyColumn"  : {"id" : "id"}
                                })
        })
            .then(response => {
                var responseJsonPromise = response.json();
                responseJsonPromise.then((responseJson) => {
                    console.log("Response from save():", responseJson);
                    if(responseJson["success"])
                    {
						//On a success, send an alert
                        console.log("Successful save of handsontable spreadsheet");
                        alert("Table save successfully -- check your database table to verify!")
                    }
                    else
                    {
						//If an error occurs during upload, log the error message to the console
                        console.log("There was an error running save():",
                                    responseJson["errorMessage"],
                                    responseJson["errorDetail"]
                        );
                        alert("There was a problem saving to your database table: " + responseJson["errorMessage"]);
                    }
                });
            });
        });
    </script>

</cfoutput>