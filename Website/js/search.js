// Sampled from blencorp.com
// Adapted by T.Clay - Queen Elizabeth's High School 05/2016

$(document).ready(function () {

    //GLOBAL VAR
    var stuXMLSource = $('#data').attr('stuData');
    var staXMLSource = $('#data').attr('staData');
    var keyword = '';
    var catType = '';
    var pub = '';

    var i = 0;

    $("#searchButton").click(function () {
        keyword = $("input#term").val();
        catType = $("#category option:selected").val();

        //Reset any message
        var errMsg = '';
        pub = '';

        //Pick student or staff data file and result set or display error

        if (keyword == '') { errMsg += 'Please enter a search value!' + '\n'; }
        else if (catType == 'none') { errMsg += 'Please select a search criteria!' + '\n'; }
        else if (catType == 'StaffN' || catType == 'StaffI') { stasearchThis(); }
        else { stusearchThis(); }

        if (errMsg != '') {
            pub += '<div class="error">' + '\n';
            pub += errMsg;
            pub += '</div>' + '\n';
        }

        //Show error
        $('#result').html(pub);

    });

    
    //If staff - get Staff XML, search and output results set
    
        function stasearchThis() {
            $.ajax({
                type: "GET",
                url: staXMLSource,
                dataType: "xml",
                success: function (xml) { staloadPublication(xml) }
            });
        }


        function staloadPublication(staData) {
            i = 0;
            var row;

            var searchExp = "";

            $(staData).find('TimetableData').each(function () {

                var ResourceName = $(this).find('ResourceName').text();
                var Initials = $(this).find('Initials').text();
                var TableRow = $(this).find('TableRow').text();
                var ID = $(this).find('id').text();

                //Format the keyword expression
                var exp = new RegExp(keyword, "gi");

                //Check if there is a category selected; 
                //Use Staff Name for StaffN and Initials for StaffI
                if (catType == 'StaffN') { searchExp = ResourceName.match(exp); }
                else if (catType == 'StaffI') { searchExp = Initials.match(exp); }
                
                if (searchExp != null) {

                    //Start building the result
                    if ((i % 2) == 0) { row = 'even'; }
                    else { row = 'odd'; }

                    i++;

                    // Build table
                    // Row shading and ID
                    pub += '<tr id="TTID'+ID+'" class="row ' + row + '" style="border-style:solid;border-width:1px;overflow:hidden;word-break:normal;">' + '\n';
                    // First column data- Staff Name
                    pub += '<td valign="top" class="staname">' + ResourceName + '</td>' + '\n';
                    // Second column data- Staff Initials
                    pub += '<td valign="top" class="staname">' + Initials + '</td>' + '\n';
                    // Second column data- Timetable in full with print button by ID
                    pub += '<td valign="top" class="timec">' + TableRow + '<p class="no-print"><button type="button" class="print-link no-print" onclick="jQuery('+"'#TTID"+ID+"'"+').print()">Print Timetable</button></p></td>' + '\n';
                    // Close row
                    pub += '</tr>' + '\n';
                }
            });
            //If no results -display error
            if (i == 0) {
                pub += '<div class="error">' + '\n';
                pub += 'No matching Staff found. Please check your search value and criteria.' + '\n';
                pub += '</div>' + '\n';

                //Populate the result
                $('#result').html(pub);
            }
            else {
                //Pass the result set
                stashowResult(pub);
            }
        }

        function stashowResult(resultSet) {

            //Show the result here
            // Build table headings
            pub = '<div class="message">Matched ' + i + ' Timetables!</div>';
            pub += '<table id="grid" border="0">' + '\n';
            pub += '<thead><tr>' + '\n';
            pub += '<th class="staname">Staff Name</th>' + '\n';
            pub += '<th class="staname">Staff Initials</th>' + '\n';
            pub += '<th class="timeh">Timetable</th>' + '\n';
            pub += '</tr></thead>' + '\n';
            pub += '<tbody>' + '\n';
            //Add search result set to table
            pub += resultSet;

            pub += '</tbody>' + '\n';
            pub += '</table>' + '\n';

            //output to html for user to view
            $('#result').html(pub)

            $('#grid').tablesorter();
        }

    
        // If student not staff -> Get Student XML, search and output results set

       function stusearchThis() {
            $.ajax({
                type: "GET",
                url: stuXMLSource,
                dataType: "xml",
                success: function (xml) { stuloadPublication(xml) }
            });
        }


        function stuloadPublication(stuData) {
            i = 0;
            var row;

            var searchExp = "";

            $(stuData).find('TimetableData').each(function () {

                var ResourceName = $(this).find('ResourceName').text();
                var Reg = $(this).find('Reg').text();
                var TableRow = $(this).find('TableRow').text();
                var Email = $(this).find('email').text();
                var ID = $(this).find('id').text();

                //Format the keyword expression
                var exp = new RegExp(keyword, "gi");

                //Check if there is a category selected; 
                //if not, StudentF use Form, if StudentN use Student Name
                if (catType == 'StudentF') { searchExp = Reg.match(exp); }
                else if (catType == 'StudentN') { searchExp = ResourceName.match(exp); }
               
                if (searchExp != null) {

                    //Start building the result
                    if ((i % 2) == 0) { row = 'even'; }
                    else { row = 'odd'; }

                    i++;

                    // Build table
                    // Row shading and ID
                    pub += '<tr id="TTID'+ID+'" class="row ' + row + '">' + '\n';
                    // First column data- Student Name
                    pub += '<td valign="top" class="stuname">' + ResourceName + '</td>' + '\n';
                    // Second column data- Student Form Group
                    pub += '<td valign="top" class="reg">' + Reg + '</td>' + '\n';
                    // Third column data- Timetable in full with print button and email link
                    pub += '<td valign="top" class="timec">' + TableRow + '<p class="no-print"> <button type="button" class="print-link no-print" onclick="jQuery('+"'#TTID"+ID+"'"+').print()">Print Timetable</button> <input class="no-print" type="button" value="Email Teachers" onClick="parent.location='+"'"+'mailto:'+Email+"'"+'"></input> Please note - Subject teachers only. Excludes form tutors & HOH!</p></td>' + '\n';
                    // Close row
                    pub += '</tr>' + '\n';
                }
            });
            //If no results -display error
            if (i == 0) {
                pub += '<div class="error">' + '\n';
                pub += 'No matching Students found. Please check your search value and criteria.' + '\n';
                pub += '</div>' + '\n';

                //Populate the result
                $('#result').html(pub);
            }
            else {
                //Pass the result set
                stushowResult(pub);
            }
        }

        function stushowResult(resultSet) {

            //Show the result
            pub = '<div class="message">Matched ' + i + ' Timetables!</div>';
            pub += '<table id="grid" border="0">' + '\n';
            pub += '<thead><tr>' + '\n';
            pub += '<th class="stuname">Student</th>' + '\n';
            pub += '<th class="reg">Form</th>' + '\n';
            pub += '<th class="timeh">Timetable</th>' + '\n';
            pub += '</tr></thead>' + '\n';
            pub += '<tbody>' + '\n';

            pub += resultSet;

            pub += '</tbody>' + '\n';
            pub += '</table>' + '\n';

            //Populate 
            $('#result').html(pub)

            $('#grid').tablesorter();
        }
    }); 