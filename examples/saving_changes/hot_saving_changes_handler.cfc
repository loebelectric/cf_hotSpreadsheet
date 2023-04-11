component
{
	//Here, we use wirebox load our cf_hotSpreadsheet and spreadsheet-cfml dependencies for use.
	//If you're not using coldbox or wirebox, you'll need to instantiate the cf_hotSpreadsheet
	//object in a different way.
    property name="cf_hotSpreadsheet"           inject="cf_hotSpreadsheet";


    /**
     * This is the handler method that shows the example for saving changes in handsontable.
     */
    function view_example(event, rc, prc)
    {
        event.setView("hot_saving_changes");
    }


	/**
     * The coldfusion handler targeted remotely by a javascript fetch call when saving data to the
     * database from changes made on a handsontable spreadsheet.
     */
    remote struct function save()
    {
        try
        {
            local.requestDataStruct = deserializeJSON(getHTTPRequestData().content);
            variables.cf_hotSpreadsheet.saveTable(  tableName           = local.requestDataStruct["tableName"],
                                                    data                = local.requestDataStruct["data"],
                                                    columnsToUpdate     = local.requestDataStruct["columnsToUpdate"],
                                                    primaryKeyColumn    = local.requestDataStruct["primaryKeyColumn"],
                                                    skipRows            = 0   );
            return {    "success"   : true  };
        }
        catch(any e)
        {
            return {    "success"       : false
                        "errorMessage"  : e.message,
                        "errorDetail"   : e.detail  };
        }
    }
}