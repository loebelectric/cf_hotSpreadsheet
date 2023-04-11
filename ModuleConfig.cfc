component
{
    //Module Properties
    this.title          = "cf_hotSpreadsheet";
    this.author         = "Jeff Stevens";
    this.description    = "A Coldfusion module for interacting with Handsontable, a javascript spreadsheet library."
    this.modelNamespace = "cf_hotSpreadsheet";
    this.cfmapping      = "cf_hotSpreadsheet";

    /**
	 * Module Config
	 */
	function configure(){
		// Module Settings
		settings = {};
	}

    function onLoad(){
        binder.map( "cf_hotSpreadsheet" )
		.to( "#moduleMapping#.models.cf_hotSpreadsheet" )
        .asSingleton()
        binder.mapDirectory(
        	packagePath = "#moduleMapping#",
        	namespace = "@cf_hotSpreadsheet"
        );
	}
}