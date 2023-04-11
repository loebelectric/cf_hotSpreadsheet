# cf_hotSpreadsheet

Welcome to cf_hotSpreadsheet, a coldfusion module designed to give you the tools to interact easily with the handsontable (hot) javascript library: https://handsontable.com/docs/javascript-data-grid/


As handsontable is already a feature rich javascript library, this module does not extend its capabilities, but rather gives you useful functions that allow you to easily convert your coldfusion query objects to be compatible input for handsontable instances, makes saving your handsontable instances to your database tables simple, and has plenty of examples for you to base your implementations of handsontable in your own coldfusion server off of.

## Contents
1. Getting started
2. Available methods
3. Examples


## Getting started

To begin using cf_hotSpreadsheet, you need to first install it in commandbox with `install cf_hotSpreadsheet`. Next, you need to instantiate the cf_hotSpreadsheet model defined in `cf_hotSpreadsheet.cfc`. You can do this in a variety of different ways in coldfusion, but two of the easiest ways are using wirebox injections or using the `New` keyword.

### Instantiating cf_hotSpreadsheet with wirebox

First, make sure you have wirebox installed in your application. All Coldbox apps have wirebox already installed. If you don't have wirebox, please refer to the wirebox install guide here: https://wirebox.ortusbooks.com/getting-started/installing-wirebox

Once you've made sure that you have wirebox, open up the model or handler you would like to use cf_hotSpreadsheet within. At the top of your Coldfusion component that you use to define you handler, set cf_hotSpreadsheet as a property with an injection parameter, like so:
```
//Your Coldfusion component:
component
{
	property name="cf_hotSpreadsheet"	inject="cf_hotSpreadsheet";

	.
	.
	.
}
```

After you've defined cf_hotSpreadsheet as a property here, wirebox will know that you want to be able to use its functions. Now you can begin calling the functions of cf_hotSpreadsheet by referencing the following object: `variables.cf_hotSpreadsheet`

### Instantiating cf_hotSpreadsheet with `new`

If you don't have wirebox or don't care to use it, another way to instantiate cf_hotSpreadsheet is through coldfusion's `new` keyword. You can do this in the following way:

```
variables.cf_hotSpreadsheet = new path.to.cf_hotSpreadsheet.models.cf_hotSpreadsheet();
```

In this example, you need to define a dot-separated path to find the model you want to instantiate. If you installed cf_hotSpreadsheet with commandbox, it would look something more like:

```
variables.cf_hotSpreadsheet = new modules.cf_hotSpreadsheet.models.cf_hotSpreadsheet();
```

Once you've created your instance of cf_hotspreadsheet and named it what you like, you can begin to reference it!

### Calling methods

Now that you've got cf_hotSpreadsheet installed in your application and you've got an instance of it created, you can now start using it. To test out callling a method from cf_hotSpreadsheet, try running the following code in your application.

```
//Programatically define a simple query
myQuery = queryNew("developer,language","varchar,varchar,varchar");
queryAddRow(myQuery);
querySetCell(myQuery, "developer", "Gary");
querySetCell(myQuery, "language", "Coldfusion");
queryAddRow(myQuery);
querySetCell(myQuery, "developer", "Jeff");
querySetCell(myQuery, "language", "Python");

//Convert the query to an array of a arrays -- a format used for loading data into spreadsheets in handsontable.
writeDump(variables.cf_hotSpreadsheet.convertQueryToArrayOfArrays());
```

Printed to your webpage, you should get an array of arrays object that looks like:

[['Gary','Coldfusion'],['Jeff','Python']].


## Available Methods

The following is a fully documented list of methods available for you to use within the cf_hotSpreadsheet module.

### saveTable()
This will be the function that you will use to update your SQL database tables using arrays of arrays that come from handsontable's getData() function.

### convertQueryToArrayOfArrays()
If you have a query object representing a table in your database that you would like to display in a handsontable spreadsheet, then you can use this function to convert it to an array of arrays -- the format which handsontable understands.

### convertQueryToArrayOfStructures()
Handsontable also understands arrays of structures when loading data, so you can also use this method for the same purposes as `convertQueryToArrayOfArrays()`.


## Examples

Here are all the examples of use-cases you may have for using handsontable with coldfusion and how to go about accomplishing them! We make the assumption in these examples that you are using Coldbox with a SQL database,
specifically for the purposes of pathing, using wirebox dependency injection, and querying the database. So if you'd
like to follow the examples outside of a coldbox and/or SQL environment, we recommend that you instantiate the objects necessary in a way you find preferable, and you modify the queries to fit your needs.

Also! We use the spreadsheet-cfml module in one of our examples. If you'd like to interface with spreadsheet files on your server and use that example, we highly recommend installing the spreadsheet-cfml module. You can do this in commandbox with the following command:
`install spreadsheet-cfml`

1. Basic implementation
2. Loading a .csv file into handsontable
3. Saving changes made to a handsontable spreadsheet to the database

### Basic implementation

The files required for this example are stored in the `examples/basic_implementation` folder.

In this example we show you how to use data that comes from Coldfusion in your handsontable instances. Included is a .cfm file that creates a query object, converts it to an array of arrays, and then converts the colfusion array of arrays into a javascript array of arrays to be loaded into the handsontable instance. Additionally, comments are included with explanations and links to the documentation for you to customize how the table is formatted. Try using own query objects in this file so you can get an idea of what your table looks like as a handsontable spreadsheet! Although not essential, there's also a bit about adding a search bar and a button to export the data in the table to a csv.

When you are ready to access this example page, you can either copy and paste the following relative path to your server root in a browser: `modules/cf_hotspreadsheet/examples/basic_implementation/hot_basic_implementation.cfm`

Or you can move the `hot_basic_implementation.cfm` file to your views folder and access it there directly.



### Loading a .csv file into handsontable

The files required for this example are stored in the `examples/loading_a_csv` folder.

Here we demonstrate how to take a .csv file as input from a user, receive it on your server, and then seamlessly load it into a handsontable instance without refreshing the page.

This example involves uploading files to your app and making ajax requests to methods of an example handler, so file pathing is an issue here. In order for this example to work correctly, you need to `examples/loading_a_csv/hot_loading_a_csv_handler.cfc` to your handlers folder and `examples/loading_a_csv/hot_loading_a_csv.cfm` to your views folder. Otherwise, you will have to adjust some of the URLs in the example for them to work in your app.

Once you have the files moved, you can access the example in the browser by going to the following URL:
`{yourHostNameHere}:{yourPortNumberHere}/hot_loading_a_csv_handler/view_example`



### Saving changes made to a handsontable spreadsheet to the database

The files required for this example are stored in the `examples/saving_changes` folder.

If you want to learn about saving the changes you have in your handsontable instance to a SQL table, this example is for you. This example involves using ajax requests and making queries to a SQL database, so this makes correct URL paths a necessity for this example to work.

Please move the `examples/saving_changes/hot_saving_changes_handler.cfc` to your handlers folder and the `examples/saving_changes/hot_saving_changes.cfm` to your views folder. Otherwise, you will have to adjust some of the URLs in the example for them to work in your app.

Lastly, you will have to create a table in your database to save your spreadsheet data to. A SQL script is provided for you to create a table that will run the example: `examples/saving_changes/create_example_table.sql`. Run this script on the database that your server is connected to and then you should be all set.

Once you have the files moved and the database table created, you can access the example in the browser by going to the following URL:
`{yourHostNameHere}:{yourPortNumberHere}/hot_saving_changes_handler/view_example`