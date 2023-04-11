<cfoutput>
	<!---
		In this example, we'll show you how to load make a button that lets
		a user upload a .csv file from their computer to your server, which
		can then load all of the data from the .csv into your handsontable
		instance.
	--->

	<!--- HTML:
		Create a form which will let users upload files to the server. We will
		manage the target of the submission in javascript, so don't worry about
		that for now. We will also need to create a div to contain our handsontable
		spreadsheet instance.
	--->
	<h2 align="center">Loading a .csv file into Handsontable</h2>
    <br/>
    <form method="post" id="fileUploadForm">
        <input type="file" id="fileUploadInput">
        <button id="loadCsvToHot" type="button" class="btn btn-primary">
            Load .csv
        </button>
    </form>
	<br/>
	<div id="handsontable-div">
	</div>


	<!--- Javascript:
		Import the handsontable javascript library and css files, and then instantiate
		the handsontable table instance on the div we defined above. We also add code
		below the table instantiation to handle the submission of the .csv file to the
		server.
	--->
	<!--- Get Handsontable's script and style files via CDN links --->
    <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/handsontable/dist/handsontable.full.min.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/handsontable/dist/handsontable.full.min.css">
    <!--- Make our table within the following javascript --->
    <script>
        //Find the div that our hands on table instance is going live inside of
        const container = document.querySelector('##handsontable-div');
        //Create the handsontable object with no data currently inside of it
        const hot = new Handsontable(container, {
            rowHeaders: true,
            search: true,
            contextMenu: true,
            height: 'auto',
            width: 'auto',
            licenseKey: 'non-commercial-and-evaluation' // for non-commercial use only
        });

		/**
		 * Add an event listener to the submit button on the file upload form. Here, we'll make it
		 * so that when someone clicks on the submit button, we grab the file they have currently
		 * chosen for upload and use an asynchronous fetch request to send it to the server. On a
		 * successful upload, the server will return the data from the spreadsheet in the form of
		 * an array of arrays. We'll pass that array of arrays as a parameter into the loadData()
		 * method of our handsontable instance.
		 */
		var uploadSpreadsheetButton = document.getElementById("loadCsvToHot");
		uploadSpreadsheetButton.addEventListener('click', async () => {
            // Get the input from the file upload element
            var fileUploadElement = document.getElementById("fileUploadInput");
            // Check to see if we actually uploaded any files to the element
            if(fileUploadElement.files.length <= 0)
            {
                console.log("No file has been chosen for upload");
                return;
            }
            //Create a formdata object that will contain the file we are submitting to the server
            var formData = new FormData();
            formData.append("file", fileUploadElement.files[0]);
            //Send a fetch request
			/**
			 * !!!!!!!!!!!!!!!!!
			 * Put the url of cf_hotSpreadsheet/examples/loading_a_csv_handler.cfc as the first argument
			 * of the fetch function below, targeting the load_csv method. The current way this is written
			 * assumes that loading_a_csv_handler.cfc exists in a coldbox application's handlers folder. An
			 * easy way to handler this issue is just to move loading_a_csv_handler.cfc to your coldbox
			 * app's handlers folder. If you're not working with coldbox, you can try writing the URL as
			 * a literal. For example:
			 *
			 * If the file lives in your webroot, you could write it in the following way:
			 *
			 * "hostNameHere:portNumberHere/hot_loading_a_csv_handler.cfc?method=load_csv"
			 * !!!!!!!!!!!!!!!!!
			 */
            await fetch('#event.buildLink("hot_loading_a_csv_handler.load_csv")#',
                {
                    method: 'POST',
                    mode: 'no-cors',
                    headers: {
                    'Content-Type': 'application/json'
                    },
                    body: formData
                }
            )
            .then(response => {
                var responseJsonPromise = response.json();
                responseJsonPromise.then((responseJson) => {
                    console.log("Response from load_csv():", responseJson);
                    if(responseJson["success"])
                    {
						//On a successful upload, load the data into the handsontable instance we defined above
                        hot.loadData(responseJson["data"]);
                    }
                    else
                    {
						//If an error occurs during upload, log the error message to the console
                        console.log("There was an error running load_csv():",
                                    responseJson["errorMessage"],
                                    responseJson["errorDetail"]
                        );
                    }
                });
            });
        });
	</script>


</cfoutput>