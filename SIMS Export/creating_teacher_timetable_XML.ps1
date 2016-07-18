# creating_teacher_timetable_XML.ps1
#
# PowerShell script to read in the data contained in raw-timetable.csv and change it into
# text (stored within script_out.txt) that resembles the template provided by timetable.xml
# (but it isn't actually linked to that file). This text file can then be saved as an xml file
# and used by HAP in order to provide a teacher timetable in school or out.
#
# Originally written by Callum McCormick - 6th May 2016.
# Based upon 'Creating_Student_Timetable_XML.ps1' - written by Callum McCormick on 25th April 2016.
# Last edited: 25th May 2016
# Reason for edit: Ensuring output and log files are present, swapped some 'do-while' loops for
# 'for' loops, updated commenting.
#
# Version 3.0



# Location of the folder containing the input csv file along with the output and log files (if previously created)
# Directory should NOT end with a backslash
$Directory = 'S:\ICT-Support\Systems_Development\CMC\PowerShell\Final Version'
# Name of the csv file containing the required user data. Must be in the location mentioned above.
$InputFileName = 'teacher_timetables.csv'
# Names of the text files used for output and log info. These do not have to be pre-existing, but if they are then
# they will be wiped clean and the contents written afresh.
$OutputFileName = 'script_out.txt'
$LogFileName = 'log_file.txt'

# **********************************************************************************************************************

# This is a snippet of text added to the output file before anything else.
# Text is derived from original xml template
$SnippetA = '<?xml version="1.0" encoding="utf-8"?><report source="ExportTimetable">
<SingleTimeTablesReport>
<Title>Teacher Timetable</Title>
<TimeTables>'

# The next three snippets are pieces of text that must be inserted into the file at the correct point for each user.
# Text is derived from original xml template
$SnippetB = '<TimetableData>
<Comment />'

$SnippetC = '<TableRow>
<![CDATA[ <table class="time">
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
function FindPeriodData ($FullName, $Init, $PeriodRawData, $Pnumber)
{
    # A function for manipulating text from arrays and puts it in the output file. Called multiple times within
    # the main body of code (specifically part B) as it is used for each of the six periods of the day.
    #
    # First it generates an array containing ten underscores; Each of these will be replaced by the correct
    # period data.
    #
    # $PeriodData is a massive array containing all the lessons being had by each teacher during that period
    # of the school day. This is for each day of the two week timetable (10 days total), not just one.
    #
    # It also receives a teacher's name ($FullName) and initials ($Init), which it uses as key fields to find the
    # required data within the large array.
    #
    # It then uses the period data, originally in a form similar to '1Mon:1' (week 1 or 2, 3 letter day code,
    # period of day [laregly redundant here]) and figures out which day of the 10 day timetable this is meant
    # to be, before replacing one of the ten underscores with that data.
    #
    # Finally it loops through all ten elements of the array and enters the data into the output file in the
    # desired manner.
    #
    # The Pnumber is just required for one piece of text and as such was inputted rather than calculated.

    # Sets up a 10 element array that initially contains underscores. These will be maintained in the final
    # output text file if the teacher is lacking data for the corresponding lesson (either accidentally or
    # because they have a free period).
    $orderedPeriod = @("_","_","_","_","_","_","_","_","_","_")

    # Checks if the period number is AM or PM and if so makes sure it is upper case. Otherwise it adds a "P" to
    # the front so it will print out as 'P1' etc. Then writes it to the output file with the desired formatting.
    if ($Pnumber -eq "am" -or $Pnumber -eq "pm")
    {
        $Pnumber = $Pnumber.ToUpper()
    }
    else
    {
        $Pnumber = "P" + $Pnumber
    }
    $TextOut = "<tr><td>" + $Pnumber + "</td>"; Add-Content $OutputFile $TextOut

    # This do-while loop must run for every element of the $PeriodRawData array. It uses counter c to keep
    # track of where in the array it is.
    # It tries to find elements containing both of the key fields (name and reg) that were provided to it
    # and if it does so then figures out where in the $orderedPeriod array it should be positioned.
    for($counter_c = 0; $counter_c -lt $PeriodRawData.count; $counter_c++)
    {
        # $Catch will be set to 1 if there is a problem finding the correct position for the lesson data.
        $Catch = 0
        # Compares positions c,0 and c,1 within the two dimensional array fed to the function and compares
        # them both to see whether they match the user data.
        if ($PeriodRawData[$counter_c][0] -eq $FullName -And $PeriodRawData[$counter_c][1] -eq $Init)
        {
            #Takes the lesson time data from c,5 of the array ('1Mon:1') and puts it into a string.
            [string]$rawTime = $PeriodRawData[$counter_c][5]
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
                $orderedPeriod[$dayNo] = ($PeriodRawData[$counter_c][2],$PeriodRawData[$counter_c][3],$PeriodRawData[$counter_c][4])
            }
            else
            {
                $TextOut = "ERROR: Unable to determine which day of the week " + $day + " refers to; This lesson will not be included with " + $FullName + "'s other lessons"
                Add-Content $LogFile $TextOut
            }
        }
        else
        {
            # if this element of the array does not match the identifying data provided, skip it and move on.
        }
    }

    # Having now filled the $orderedPeriod array with relevant timetable data, this 'for' loop runs through each
    # element and writes the data within to the output file.
    for($i = 0; $i -lt 10;$i++)
    {
        $TextOut = "<td>" + $orderedPeriod[$i][0] + "<br>" + $orderedPeriod[$i][1] + " " + $orderedPeriod[$i][2] + "</td>"
        Add-Content $OutputFile $TextOut
    }
    # Just adds one list bit of text after all that lesson data
    $TextOut = "</tr>"; Add-Content $OutputFile $TextOut
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

# A simple integer that lets us keep track of which row of the csv we are on
$counter_a = 0

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

# Checks that the input file is there. If not then jumps to else at bottom
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
        $Title = $_."Title"
        $Surname = $_."Preferred Surname"
        $Initials = ($_."Initials").Trim()
        $Subject = ($_."Subject code").Trim()
        $Class = ($_."Class").Trim()
        $Room = ($_."Room").Trim()
        $Time = ($_."Period").Trim()

        # Combines these together into their name as known by the students, who will have access to the final product.
        $Name = $Title + " " + $Surname

        # First the $namesArray is populated. This will be used to find all the unique teachers, so both their
        # name and initials are used. All unique teachers within this array will have timetables generated, even
        # if they are empty timetables.
        #
        # You cannot directly make an element of an array another array, but you can put a placeholder in first
        # and then overwrite it with an array.
        $namesArray += $counter_a
        $namesArray[$counter_a] = ($Name,$Initials)

        # The variable time looks something like '1Mon:1' but we just want to check the part after the colon
        # which could be a number or am/pm. So we use split to find just that part.
        $timeLength = $Time -split ":"
        $periodNo = $timeLength[1]

        # Some output to just visually show that it is running, as the csv is very large and it can take a
        # long time to run this part, so you can see it hasn't crashed and how far it has progressed.
        Write-Host Reading lesson data for $Initials during period $periodNo

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
            $periodAM[$posTemp] = ($Name,$Initials,$Subject,$Class,$Room,$Time)
        }
        elseif ($periodNo -eq 1)
        {
            $posTemp = $period1.count
            $period1 += $posTemp
            $period1[$posTemp] = ($Name,$Initials,$Subject,$Class,$Room,$Time)
        }
        elseif ($periodNo -eq 2)
        {
            $posTemp = $period2.count
            $period2 += $posTemp
            $period2[$posTemp] = ($Name,$Initials,$Subject,$Class,$Room,$Time)
        }
        elseif ($periodNo -eq 3)
        {
            $posTemp = $period3.count
            $period3 += $Temp
            $period3[$posTemp] = ($Name,$Initials,$Subject,$Class,$Room,$Time)
        }
        elseif ($periodNo -eq 4)
        {
            $posTemp = $period4.count
            $period4 += $posTemp
            $period4[$posTemp] = ($Name,$Initials,$Subject,$Class,$Room,$Time)
        }
        elseif ($periodNo -eq "pm")
        {
            $posTemp = $periodPM.count
            $periodPM += $posTemp
            $periodPM[$posTemp] = ($Name,$Initials,$Subject,$Class,$Room,$Time)
        }
        elseif ($periodNo -eq 5)
        {
            $posTemp = $period5.count
            $period5 += $posTemp
            $period5[$posTemp] = ($Name,$Initials,$Subject,$Class,$Room,$Time)
        }
        elseif ($periodNo -eq 6)
        {
            $posTemp = $period6.count
            $period6 += $posTemp
            $period6[$posTemp] = ($Name,$Initials,$Subject,$Class,$Room,$Time)
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
    # teacher and using the FindPeriodData function to discover their lesson data and correctly order and
    # write it out to the file.

    # Adds SnippetA to the top of the file before anything else happens.
    Add-Content $OutputFile $SnippetA

    # This 'for' loop will repeat for each entry in $namesArray.
    # All text outputted to file within this is repeated for each user.
    for($counter_b = 0; $counter_b -lt $namesArray.count; $counter_b++)
    {
        # Adding another pre-made text snippet 
        Add-Content $OutputFile $SnippetB
        # Takes the values of positions b,0 and b,1 within the two-dimensional $namesArray
        $tempName = $namesArray[$counter_b][0]
        $tempInitials = $namesArray[$counter_b][1]
        # Creating a specific line using these determined values and outputting to the file
        $TextOut = "<ResourceName>" + $tempName + "</ResourceName><Initials>" + $tempInitials + "</Initials>"; Add-Content $OutputFile $TextOut
        # Adding another pre-made text snippet 
        Add-Content $OutputFile $SnippetC

        # Just some output to show the operator how far the script has got.
        Write-Host Compiling timetable for $tempName

        # This runs the FindPeriodData function for each period of the school day.
        # The $tempName and $tempInitials values from above, along with the array matching that
        # period (populated with all the data we read in to it previously) are inputted.
        # Pnumber is only needed for one bit of text, but it seemed just as efficient to pass
        # it and write the line of code to output it once than to write it six times here.
        FindPeriodData -FullName $tempName -Init $tempInitials -PeriodRawData $periodAM -Pnumber "am"
        FindPeriodData -FullName $tempName -Init $tempInitials -PeriodRawData $period1 -Pnumber 1
        FindPeriodData -FullName $tempName -Init $tempInitials -PeriodRawData $period2 -Pnumber 2
        FindPeriodData -FullName $tempName -Init $tempInitials -PeriodRawData $period3 -Pnumber 3
        FindPeriodData -FullName $tempName -Init $tempInitials -PeriodRawData $period4 -Pnumber 4
        FindPeriodData -FullName $tempName -Init $tempInitials -PeriodRawData $periodPM -Pnumber "pm"
        FindPeriodData -FullName $tempName -Init $tempInitials -PeriodRawData $period5 -Pnumber 5
        FindPeriodData -FullName $tempName -Init $tempInitials -PeriodRawData $period6 -Pnumber 6

        # Adding another pre-made text snippet 
        Add-Content $OutputFile $SnippetD
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