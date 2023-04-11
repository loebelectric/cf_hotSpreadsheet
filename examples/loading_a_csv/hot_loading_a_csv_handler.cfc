/**
 * This is an example handler we have defined to handle ajax requests for the purpose of
 * showing how to upload csv data to handsontable in using Coldfusion.
 *
 * N.B.
 * In your own production apps, please remember to add authorization and validation upon receiving
 * file uploads. For sake of brevity, authorization and validation are not included in this
 * handler.
 */
component
{
    //Here, we use wirebox load our cf_hotSpreadsheet and spreadsheet-cfml dependencies for use.
	//If you're not using coldbox or wirebox, you'll need to instantiate the cf_hotSpreadsheet
	//and spreadsheet-cfml objects in a different way.
    property name="cf_hotSpreadsheet"           inject="cf_hotSpreadsheet";
    property name="spreadsheet_cfml"            inject="Spreadsheet@spreadsheet-cfml";


    /**
     * This is the handler method that shows the page for the loading a csv example.
     */
    function view_example(event, rc, prc)
    {
        event.setView("hot_loading_a_csv");
    }


	/**
	 * A function that can be remotely targeted for the purpose of uploading csv files and returning
	 * their data as an array of arrays to the source that called them. We use this in cf_hotSpreadsheet's
	 * loading_a_csv example.
	 *
	 * This is the function that is called when a user clicks the load .csv button on the hot_loading_a_csv.cfm
	 * page.
	 */
	remote struct function load_csv()
    {
        try
        {
            //Upload the .csv file included in the formData that was sent to this handler under the key "file"
			//to the webroot.
            local.uploadedFile = fileUpload(    ExpandPath('/'),
                                                "file",
                                                "text/plain,text/csv",
                                                "makeUnique"    );
            local.fileName = expandPath(local.uploadedFile.serverFile);
            //Read the contents of the .csv file that was just uploaded and store them in a query object. (spreadsheet-cfml is required here)
            local.fileAsQuery = variables.spreadsheet_cfml.csvToQuery(filepath = local.fileName);
            //Convert the query object to a format we can load into our handsontable instance (array of arrays)
            local.fileAsArrayofArrays = variables.cf_hotSpreadsheet.convertQueryToArrayOfArrays(local.fileAsQuery);
			//Return a struct indicating success of the .csv upload its contents to javascript
            return {    "success"   : true,
                        "data"      : local.fileAsArrayOfArrays	};
        }
        catch (any e)
        {
			//Return a struct indicating that an error has taken place and its details
            return {    "success"       : false,
                        "data"          : [],
                        "errorMessage"  : e.message,
                        "errorDetail"   : e.detail	};
        }
    }


}