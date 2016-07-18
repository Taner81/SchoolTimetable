# Create_Student_Timetable_XML.ps1
#
# PowerShell script to read in the data contained in raw-timetable.csv and change it into
# text (stored within script_out.txt) that resembles the template provided by timetable.xml
# (but it isn't actually linked to that file). This text file can then be saved as an xml file
# and used by HAP in order to provide a student timetable in school or out.
#
# Originally written by Callum McCormick - 25th April 2016.
# Last edited: 24th May 2016
# Reason for edit: Ensuring output and log files are present, updating commenting.
#
# Version 12.1



# Location of the folder containing the input csv file along with the output and log files (if previously created)
# Directory should NOT end with a backslash
$Directory = 'S:\ICT-Support\Systems_Development\CMC\PowerShell\Final Version'
# Name of the csv file containing the required user data. Must be in the location mentioned above.
$InputFileName = 'student_timetables.csv'
# Names of the text files used for output and log info. These do not have to be pre-existing, but if they are then
# they will be wiped clean and the contents written afresh.
$OutputFileName = 'script_out.txt'
$LogFileName = 'log_file.txt'

# Refers to the expected length of the teachers' initials in the data being imported.
# Likely rarely changed.
$initial_length = 3
# Prefix and suffix used to create all teacher email addresses based upon their initials in the csv input file.
$teacher_prefix = "staff"
$teacher_suffix = "@email.our.sch.uk"

# **********************************************************************************************************************

# This is a snippet of text added to the output file before anything else.
# Text is derived from original xml template
$SnippetA = '<?xml version="1.0" encoding="utf-8"?><report source="ExportTimetable">
<SingleTimeTablesReport>
<Title>Student Timetable</Title>
<TimeTables>'

# The next three snippets are pieces of text that must be inserted into the file at the correct point for each user.
# Text is derived from original xml template
$SnippetB = '<TimetableData>
<Comment />'

$SnippetC = '<TableRow>
<![CDATA[ <table class="time" border="1" cellpadding="1" cellspacing="0">
<tr>
<th>Period</th>
<th>1Mon</th>
<th>1Tue</th>
<th>1Wed</th>
<th>1Thu</th>
<th>1Fri</th>
<th>2Mon</th>
<th>2Tue</th>
<th>2Wed</th>
<th>2Thu</th>
<th>2Fri</th>
</tr>'

$SnippetD = '</table>]]>
</TableRow>
</TimetableData>'

# Final snippet of text is added to the end of the output file.
# Text is derived from original xml template
$SnippetE = '</TimeTables>
</SingleTimeTablesReport>
</report>'

# *************************************************************
# ***FUNCTIONS - CALLED AS REQUIRED WITHIN MAIN BODY OF CODE***
# *************************************************************
function FindPeriodData ($FullName, $RegForm, $PeriodRawData, $Pnumber)
{
    # A function for manipulating text from arrays and puts it in the output file. Called multiple times within
    # the main body of code (specifically part B) as it is used for each period of the day.
    #
    # The Pnumber is just required for one piece of text and as such was inputted rather than calculated.
    #
    # First it generates an array containing ten underscores; Each of these will be replaced by the correct
    # period data.
    #
    # $PeriodData is a massive array containing all the lessons being had by each student during that period
    # of the school day. This is for each day of the two week timetable (10 days total), not just one.
    #
    # It also receives a student's $FullName and $RegForm, which is what it uses as key fields to find the
    # required data within the large array.
    #
    # It then uses the period data, originally in a form similar to '1Mon:1' (week 1 or 2, 3 letter day code,
    # period of day) and figures out which day of the 10 day timetable this is meant to be, before replacing
    # one of the ten underscores with that data.
    #
    # Finally it loops through all ten elements of the array and populates another array with all the required
    # formatting data along with the actual data. This is then passed back up to the main script.
    #
    # Also passes back an array containing all teacher initials that match the length requirements.

    # Variables used for separately counting and storing teacher initials
    $counter_f = 0
    $staffHold = @()

    # An array that will hold all of the lesson data once it has been re-ordered and had all relevant prefix and
    # suffix text added.
    $processedTTdata = @()

    # Sets up a 10 element array that initially contains underscores. These will be maintained in the final
    # output text file if the student is lacking data for the corresponding lesson (either accidentally or
    # because they have a free period).
    $orderedPeriod = @("_","_","_","_","_","_","_","_","_","_")

    # Checks if the period number is AM or PM and if so makes sure it is upper case. Otherwise it adds a "P" to
    # the front so it will print out as 'P1' etc. Then writes it to the output array with the desired formatting.
    if ($Pnumber -eq "am" -or $Pnumber -eq "pm")
    {
        $Pnumber = $Pnumber.ToUpper()
    }
    else
    {
        $Pnumber = "P" + $Pnumber
    }
    $TextOut = "<tr><td>" + $Pnumber + "</td>"
    $processedTTdata += $TextOut

    # This 'for' loop runs for every element of the $PeriodRawData array. It uses counter e to keep track
    # of where in the array it is. It tries to find elements containing both of the key fields (name and
    # reg) that were provided to it and when it does it then figures out where in the $orderedPeriod array
    # it should be positioned and writes it there.
    for($counter_e = 0; $counter_e -lt $PeriodRawData.count; $counter_e++)
    {
        # $Catch will be set to 1 if there is a problem finding the correct position for the lesson data.
        $Catch = 0
        # Compares positions d,0 and d,1 within the two dimensional array fed to the function and compares
        # them both to see whether they match the user data.
        if ($PeriodRawData[$counter_e][0] -eq $FullName -And $PeriodRawData[$counter_e][1] -eq $RegForm)
        {
            # Takes the lesson time data from e,5 of the array ('1Mon:1') and puts it into a string.
            [string]$rawTime = $PeriodRawData[$counter_e][5]
            # Takes that string and uses the first character as a week number.
            [int]$week = $rawTime.substring(0,1)
            # Finds the three character day identifier within that string.
            $day = $rawTime.substring(1,3)
            # This is the variable that corresponds to the day of the 10 day timetable. It starts on zero
            # (Monday of week 1) and the following 'if' statements change it to a different value depending upon
            # the day of the week.
            [int]$dayNo = 0
            if ($day -eq "Mon")
            {
                $dayNo = 0
            }
            elseif($day -eq "Tue")
            {
                $dayNo = 1
            }
            elseif($day -eq "Wed")
            {
                $dayNo = 2
            }
            elseif($day -eq "Thu")
            {
                $dayNo = 3
            }
            elseif($day -eq "Fri")
            {
                $dayNo = 4
            }
            else
            {
                # Changing $Catch to 1 will change how it outputs this data.
                $Catch = 1
            }
            # Week one corresponds to positions 0-4 of the array, and week two corresponds to positions 5-9.
            # As the day of the week sets things up correctly for week one, adding five puts you on the correct day
            # for week two, if this determins that the data refers to week two.
            if($week -eq 2)
            {
                $dayNo = $dayNo + 5
            }
            else
            {
            }
            # A quick check as we don't want to overwrite good data if the correct day couldn't be properly found.
            # Any "bad" data will be put in the log instead.
            if($Catch -eq 0)
            {              
                # Having now determined which element of the $orderedPeriod array needs overwriting with lesson data,
                # it is duly inputted.
                $orderedPeriod[$dayNo] = ($PeriodRawData[$counter_e][2],$PeriodRawData[$counter_e][3],$PeriodRawData[$counter_e][4])

                # Checks that the initials are the same length as the global variable $initial_length
                # If it is, adds it to the array $staffHold and adds one to $counter_f
                # Otherwise this does nothing.
                if(($PeriodRawData[$counter_e][3]).length -eq $initial_length)
                {
                    $staffHold += $counter_f
                    $staffHold[$counter_f] = $PeriodRawData[$counter_e][3]
                    $counter_f++
                }
                else
                {
                }
            }
            else
            {
                $TextOut = "ERROR: Unable to determine which day of the week " + $day + " refers to; This lesson will not be included with " + $FullName + "'s (" + $RegForm + ") other lessons"
                Add-Content $LogFile $TextOut
            }
        }
        else
        {
            # If this element of the array does not match the identifying data provided, skip it and move on.
        }
    }

    # Having now filled the $orderedPeriod array with relevant timetable data, this 'for' loop runs through each
    # element and writes the data within to the $processedTTdata array.
    for($i = 0; $i -lt 10;$i++)
    {
        $TextOut = "<td>" + $orderedPeriod[$i][0] + "<br>" + $orderedPeriod[$i][1] + " " + $orderedPeriod[$i][2] + "</td>"
        $processedTTdata += $TextOut
    }
    # Just adds one list bit of text after all that lesson data
    $processedTTdata += "</tr>"

    # Sends the variables back up to the main script.
    Set-Variable -Name processedPeriodData -Value $processedTTdata -Scope 1
    Set-Variable -Name periodTeachers -Value $staffHold -Scope 1
}

function CheckFileExists ($Dir,$FileName)
{
    # A pretty simple function that check whether a specific text file exists within the location specified.
    # If it does, it clears the contents of that file. If not, it creates it. Either way it then returns the
    # filepath back up to the main script.
    $filepath = $Dir + '\' + $FileName
    if (Test-path $filepath)
    {
        Clear-Content $filepath
    }
    else
    {
        New-Item $filepath -type file
    }
    Set-Variable -Name returnFilePath -Value $filepath -Scope 1
}



# ***********************************
# ***MAIN BODY OF CODE BEGINS HERE***
# ***********************************

# Sets up the arrays that will hold the data read from the csv file.
$namesArray = @()
$periodAM = @()
$period1 = @()
$period2 = @()
$period3 = @()
$period4 = @()
$periodPM = @()
$period5 = @()
$period6 = @()

# Just some output to show it is running
Write-Host STARTING SCRIPT
# Logs the time that the script begins running so that it can be compared to the finish time.
$DateTime = Get-Date

# Checks whether the log file exists and empties any prior data. The full filepath is stored as $LogFile
# for when we want to write to the log.
#
# This is checked first because if the input file is missing it will put this in the log, so obviously the
# log needs to exist.
CheckFileExists -Dir $Directory -FileName $LogFileName
$LogFile = $returnFilePath

# Writes the script's start time to the log.
$TextOut = "Script began running at " + $DateTime ; Add-Content $LogFile $TextOut



# **********************************************
# ***PART A - IMPORTING THE DATA FROM THE CSV***
# **********************************************
# This goes through each row of the csv file. It will put the name and reg into the $namesArray (which
# will be used separately later) and puts all the info into arrays based upon the period of the day.
# It is essentially creating a lot of two dimensional arrays, which powershell just reads as a flat
# array that happens to have an array in each element.

# A simple integer that lets us keep track of which row of the csv we are on
$counter_a = 0

# Creates the full filepath for the input file.
$InputFile = $Directory + '\' + $InputFileName

# Checks that the input file is there. If not then jumps to the 'else' at the bottom of the script.
if (Test-path $InputFile)
{
    # Checks whether the output file exists and empties any prior data. The full filepath is stored as $OutputFile
    # for when we want to write to it later.
    CheckFileExists -Dir $Directory -FileName $OutputFileName
    $OutputFile = $returnFilePath
    # Just some output to keep track of where the script is.
    Write-Host Processing input.
    # Opens the specified csv file and runs the script within the curly brackets for each record (row) in that csv
    Import-Csv $InputFile | ForEach-Object {

        # Imports the data in the columns from the csv file into variables.
        # The trim command ensures that any spaces at the beginning or end are removed.
        $Name = ($_."Name").Trim()
        $Reg = ($_."Reg").Trim()
        $Subject = ($_."Subject code").Trim()
        $Staff = ($_."Initials").Trim()
        $Room = ($_."Room").Trim()
        $Time = ($_."Period").Trim()

        # First the $namesArray is populated. This will be used to find all the unique students, so both their
        # name and form are used. All unique students within this array will have timetables generated, even
        # if they are empty timetables.
        #
        # You cannot directly make an element of an array another array, but you can put a placeholder in first
        # and then overwrite it with an array.
        $namesArray += $counter_a
        $namesArray[$counter_a] = ($Name,$Reg)

        # The variable $Time looks something like '1Mon:1' but we just want to check the part after the colon
        # which could be a number or am/pm. So we use split to find just that part.
        $timeLength = $Time -split ":"
        $periodNo = $timeLength[1]

        # We want to put the data from that row of the csv file into the correct array depending upon which
        # period of the day it takes place in. The 'if' statements are all the same, it just runs in the one
        # that matches the determined period number. Any lesson where the period is not am/pm or 1-6 ends up
        # being skipped.
        #
        # The 'if' statements work by initially putting a paceholder digit in to create the element in the array
        # before overriding it with the desired information, as you cannot create a new element directly as an array.
        if ($periodNo -eq "am")
        {
            $posTemp = $periodAM.count
            $periodAM += $posTemp
            $periodAM[$posTemp] = ($Name,$Reg,$Subject,$Staff,$Room,$Time)
        }
        elseif ($periodNo -eq 1)
        {
            $posTemp = $period1.count
            $period1 += $posTemp
            $period1[$posTemp] = ($Name,$Reg,$Subject,$Staff,$Room,$Time)
        }
        elseif ($periodNo -eq 2)
        {
            $posTemp = $period2.count
            $period2 += $posTemp
            $period2[$posTemp] = ($Name,$Reg,$Subject,$Staff,$Room,$Time)
        }
        elseif ($periodNo -eq 3)
        {
            $posTemp = $period3.count
            $period3 += $posTemp
            $period3[$posTemp] = ($Name,$Reg,$Subject,$Staff,$Room,$Time)
        }
        elseif ($periodNo -eq 4)
        {
            $posTemp = $period4.count
            $period4 += $posTemp
            $period4[$posTemp] = ($Name,$Reg,$Subject,$Staff,$Room,$Time)
        }
        elseif ($periodNo -eq "pm")
        {
            $posTemp = $periodPM.count
            $periodPM += $posTemp
            $periodPM[$posTemp] = ($Name,$Reg,$Subject,$Staff,$Room,$Time)
        }
        elseif ($periodNo -eq 5)
        {
            $posTemp = $period5.count
            $period5 += $posTemp
            $period5[$posTemp] = ($Name,$Reg,$Subject,$Staff,$Room,$Time)
        }
        elseif ($periodNo -eq 6)
        {
            $posTemp = $period6.count
            $period6 += $posTemp
            $period6[$posTemp] = ($Name,$Reg,$Subject,$Staff,$Room,$Time)
        }
        else
        {
        }

        # 'If' statement that outputs a message every 5000 interations just to show it's still working
        $num = $counter_a
        $num %= 5000
        if ($num -eq 0)
        {
            Write-Host The last record read was number $counter_a
        }
        else
        {
        }

        # Adds one to the counter so that the next row ends up in the next element of $namesArray
        # This has to be entered like this as we're in a "for each element" loop rather than a simple
        # 'for' loop.
        $counter_a++
    }

    # More output just to monitor the time each section takes.
    $DateTime = Get-Date
    $TextOut = "CSV file fully read at " + $DateTime + "; " + $counter_a + " records discovered."; Add-Content $LogFile $TextOut
    Write-Host CSV file read complete. $counter_a records found.
    


    # *************************************************
    # ***PART B - FILTERING ARRAYS FOR UNIQUE VALUES***
    # *************************************************
    # Identifies all the unique entries within the $namesArray to give our final list of all the users we
    # need to find data for.

    # Removes all duplicate values from this array.
    $namesArray = $namesArray | Get-Unique
    # Another log entry just to monitor the time each section takes.
    $DateTime = Get-Date
    $TextOut = "Data filtered for unique values at " + $DateTime + "; " + $namesArray.count + " unique users discovered."; Add-Content $LogFile $TextOut
    # Some output to see how it's progressing.
    Write-Host $namesArray.count unique users discovered.
    Write-Host Processing timetable data...

    # ******************************************
    # ***PART C - COMPILING & OUTPUTTING DATA***
    # ******************************************
    # Writing data into the output file. The main body of output text is formed by looping through each unique
    # student and using the FindPeriodData function to discover their lesson data & initials of their teachers.
    # This data is returned to be added to storage arrays. The teacher info is then filtered into unique values
    # (a teacher may teach multiple lessons but only needs to receive one email concerning a student) and both
    # arrays are outputted to the waiting text file

    # Adds SnippetA to the top of the file before anything else happens.
    Add-Content $OutputFile $SnippetA

    # This 'for' loop will repeat for each entry in $namesArray.
    # All text outputted to file within this is repeated for each user.
    for($counter_b = 0; $counter_b -lt $namesArray.count; $counter_b++)
    {
        # This array will be populated with the timetable data in the order required for the final XML.
        $orderedTT = @()
        # An array initially used to hold teacher initials, and then a string that will be populated
        # with all the final email addresses.
        $teachersOfStudent = @()
        $teacher_emails = "<email>"

        # Takes the values of positions b,0 and b,1 within the two-dimensional array $namesArray
        $tempName = $namesArray[$counter_b][0]
        $tempReg = $namesArray[$counter_b][1]

        # Adding another pre-made text snippet 
        Add-Content $OutputFile $SnippetB
        # Creating a specific line using these determined values and outputting to the file
        $TextOut = "<ResourceName>" + $tempName + "</ResourceName><Reg>" + $tempReg + "</Reg><id>" + $counter_b + "</id>"; Add-Content $OutputFile $TextOut

        # This runs the FindPeriodData function for each period of the school day.
        #
        # The $tempName and $tempReg values from above, along with the array matching that
        # period (populated with all the data we read in to it previously) are inputted.
        #
        # Pnumber is only needed for one bit of text, but it seemed just as efficient to pass
        # it and write the line of code to output it once than to write it eight times here.
        #
        # The function returns an array variable called $processedPeriodData, and appends it's
        # contents to the $orderedTT array. The function could have been made to write this data
        # directly but as we want the output to contain the teacher emails first it brings it
        # back here instead.
        #
        # It also returns an array variable called $periodTeacher, which is added to the
        # $teachersOfStudent array.
        FindPeriodData -FullName $tempName -RegForm $tempReg -PeriodRawData $periodAM -Pnumber "am"
        $orderedTT = $orderedTT + $processedPeriodData
        $teachersOfStudent = $teachersOfStudent + $periodTeachers
        FindPeriodData -FullName $tempName -RegForm $tempReg -PeriodRawData $period1 -Pnumber 1
        $orderedTT = $orderedTT + $processedPeriodData
        $teachersOfStudent = $teachersOfStudent + $periodTeachers
        FindPeriodData -FullName $tempName -RegForm $tempReg -PeriodRawData $period2 -Pnumber 2
        $orderedTT = $orderedTT + $processedPeriodData
        $teachersOfStudent = $teachersOfStudent + $periodTeachers
        FindPeriodData -FullName $tempName -RegForm $tempReg -PeriodRawData $period3 -Pnumber 3
        $orderedTT = $orderedTT + $processedPeriodData
        $teachersOfStudent = $teachersOfStudent + $periodTeachers
        FindPeriodData -FullName $tempName -RegForm $tempReg -PeriodRawData $period4 -Pnumber 4
        $orderedTT = $orderedTT + $processedPeriodData
        $teachersOfStudent = $teachersOfStudent + $periodTeachers
        FindPeriodData -FullName $tempName -RegForm $tempReg -PeriodRawData $periodPM -Pnumber "pm"
        $orderedTT = $orderedTT + $processedPeriodData
        $teachersOfStudent = $teachersOfStudent + $periodTeachers
        FindPeriodData -FullName $tempName -RegForm $tempReg -PeriodRawData $period5 -Pnumber 5
        $orderedTT = $orderedTT + $processedPeriodData
        $teachersOfStudent = $teachersOfStudent + $periodTeachers
        FindPeriodData -FullName $tempName -RegForm $tempReg -PeriodRawData $period6 -Pnumber 6
        $orderedTT = $orderedTT + $processedPeriodData
        $teachersOfStudent = $teachersOfStudent + $periodTeachers

        # The contents of the array $teachersOfStudent are sorted alphabetically and filtered
        # for unique values.
        $teachersOfStudent = $teachersOfStudent | Sort-Object | Get-Unique
        # Goes through all the values in the array and adds the prefix and suffix to create a full
        # email address, then appends it to the $teacher_emails string.
        #
        # It also adds a semi-colon between each entry so that Outlook (and other email applications?)
        # will be able to differentiate between each one (and the "Check Names" button will function.
        for($counter_c = 0; $counter_c -lt $teachersOfStudent.count; $counter_c++)
        {
            $teacher_emails += $teacher_prefix + $teachersOfStudent[$counter_c] + $teacher_suffix + ";"
        }
        # Adds the closing statement to the end of the string.
        $teacher_emails += "</email>"
        # The entire long string is added to the output file.
        Add-Content $OutputFile $teacher_emails

        # Adding another pre-made text snippet
        Add-Content $OutputFile $SnippetC

        # Goes through this array outputting every entry in order.
        for($counter_d = 0; $counter_d -lt $orderedTT.count; $counter_d++)
        {
            Add-Content $OutputFile $orderedTT[$counter_d]
        }

        # Adding another pre-made text snippet 
        Add-Content $OutputFile $SnippetD

        # Another 'if' statement that will print a message with every 100 students just to show
        # how the script is progressing
        $num = $counter_b
        $num %= 100
        if ($num -eq 0)
        {
            Write-Host Compiled timetable for student number $counter_b and continuing.
        }
        else
        {
        }
    }

    # Adds the final closing bit of text to the output file.
    Add-Content $OutputFile $SnippetE
}
# If the input file cannot be found, log the error and do nothing else.
else{
    Write-Host Cannot find $InputFile
    $TextOut = "ERROR: Cannot find " + $InputFile ; Add-Content $LogFile $TextOut
}

# Logs the time that the script ends so that it can be compared to the finish time.
$DateTime = Get-Date
$TextOut = "Finished running script at " + $DateTime ; Add-Content $LogFile $TextOut

# Final output to confirm it's over.
Write-Host SCRIPT FINISHED