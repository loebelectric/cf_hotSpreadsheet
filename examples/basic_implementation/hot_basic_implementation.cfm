<cfoutput>
    <!---
        Here, we'll demonstrate a basic implmentation of handsontable's spreadsheet viewer
        using data from ColdFusion.
        Docs used: https://handsontable.com/docs/javascript-data-grid/
    --->
    <!--- ColdFusion: Here, we create our data, an array of arrays, which we will send to javascript  --->
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
        //We'll convert this query using cf_hotSpreadsheet to an array of arrays; the format used by handsontable
        variables.cf_hotSpreadsheet = new modules.cf_hotSpreadsheet.models.cf_hotSpreadsheet();
        variables.cf_data = variables.cf_hotSpreadsheet.convertQueryToArrayOfArrays(variables.query);
    </cfscript>


    <!--- HTML:
        Create a div to contain our Handsontable spreadsheet instance, as well as
        a search field and a button to export the spreadsheet as a .csv file.
    --->
    <h2 align="center">Basic implementation of handsontable</h2>
    <br/>
    <input id="hotSearchField" type="search" placeholder="Search">
    <button id="exportCsvButton" type="button" class="btn btn-primary">
        Export as .csv
    </button>
    <br/>
    <div id="handsontable-div">
    </div>


    <!--- Javascript: Import the handsontable libraries and create the handsontable instance --->
    <!--- Get Handsontable's script and style files via CDN links --->
    <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/handsontable/dist/handsontable.full.min.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/handsontable/dist/handsontable.full.min.css">
    <!--- Make our table within the following javascript --->
    <script>
        //Find the div that our hands on table instance is going live inside of
        const container = document.querySelector('##handsontable-div');
        //Cast our Coldfusion data structure to a javascript object
        var #toScript(variables.cf_data, "js_data")#;
        //Create the handsontable object
        const hot = new Handsontable(container, {
            data: js_data,
            rowHeaders: true,
            colHeaders: true,
            height: 'auto',
            search: true,
            contextMenu: true,
            licenseKey: 'non-commercial-and-evaluation' // for non-commercial use only
        });
        // To customize the configuration of the handsontable instance you created above, please
        // refer to the following documentation:
        // https://handsontable.com/docs/javascript-data-grid/configuration-options/


        // By adding an event listener to the search field element, we can make our spreadsheet searchable
        searchField = document.getElementById("hotSearchField");
        searchField.addEventListener('keyup', function(event) {
            // get the `Search` plugin's instance
            const search = hot.getPlugin('search');
            // use the `Search` plugin's `query()` method
            const queryResult = search.query(event.target.value);
            //Render the cells of the spreadsheet highlighted by the query
            hot.render();
        });


        // Add an event listener to the exportCsvButton, allowing us to export our handsontable spreadsheet
        // to a csv file that the user can download.
        const exportPlugin = hot.getPlugin('exportFile');
        var exportCsvButton = document.getElementById("exportCsvButton");
        exportCsvButton.addEventListener('click', () => {
            exportPlugin.downloadFile('csv', {
                bom: false,
                columnDelimiter: ',',
                columnHeaders: false,
                exportHiddenColumns: true,
                exportHiddenRows: true,
                fileExtension: 'csv',
                filename: 'Handsontable-CSV-file_[YYYY]-[MM]-[DD]',
                mimeType: 'text/csv',
                rowDelimiter: '\r\n',
                rowHeaders: true
            });
        });
    </script>

</cfoutput>