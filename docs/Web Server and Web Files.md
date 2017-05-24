**Installation of web files**

You will need a web server (IIS Server) with application pool running .NET V4.0.

There are different ways to set this up for varying OS.
Google is our friend-

How to install IIS 7 to Windows server 2008
[https://technet.microsoft.com/en-us/library/cc771209(v=ws.11).aspx](https://technet.microsoft.com/en-us/library/cc771209(v=ws.11).aspx)

How to specify the App Pool .NET framework
[https://technet.microsoft.com/en-us/library/cc754523(v=ws.10).aspx](https://technet.microsoft.com/en-us/library/cc754523(v=ws.10).aspx)


Expand the web files into a website folder as follows:

* ~Root\
	* Timetable.html
	* Data\statimetable.xml
	* Data\stutimetable.xml
	* Images\small.gif
	* Images\small_asc.gif
	* Images\small_desc.gif
	* Js\jquery-print.js
	* Js\jquery-1.12.3.min.js
	* Js\search.js
	* Js\tablesorter.js
	* Js\week.js
	* Style\timetable.css

If the IIS settings are correct and the files are expanded correctly you should now be able to run the pre-populated data and see timetable as a user by browsing to Timetable.html.


**Editing to your timetable needs**

**Editing - Timetable.html**
This is the main webpage that pulls together the search feature. The HTML code is commented line by line.
Unless you are intending to change the search criteria. there isn't much in timetable.html to edit which will need changing between timetables. There are headers and usage details which you may wish to change. For example, we have a date where we say which data is live once we have updated the XML files.


**Editing. - Search.js**
This script is also commented and here is a brief detail of its operation:
# List global variables
# Get detail from controller div
# Reset error message and pub variables which are used to pass information through the script.
# Lookup which xml file to use (staff or student) and begin processing for either selection. If there is an error output to results div.
# Process search – Lookup xml and get each variable
# Search variables against users input and build table of positive results
# Output error if no results found
# Populate final table with headings and create a tablesort thread.
# Output to results div
From step 4 the script looks to be duplicated, this is because the script is very similar for staff or students however it only runs the part it requires as selected by the criteria in the form.

There arent changes to be made to this script if you arent changing the search criteria in timetable.html or variables in the XML files. If you change these you will need to match them up in the search.js.


**Editing - Timetable.css**
This is a straight forward CSS that links into the div and feature ID’s to give correct styling. You can pretty up the timetable somewhat here.


* [Documentation](Documentation)
	* [SIMS Export and XML Creation](SIMS-Export-and-XML-Creation) 


