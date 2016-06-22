// Created by T.Clay - Queen Elizabeth's High School 05/2016
// Script to output week number.
// Create fuction to calculate the week number from 52 week calendar
Date.prototype.getWeek = function() {
    var onejan = new Date(this.getFullYear(),0,1);
    var today = new Date(this.getFullYear(),this.getMonth(),this.getDate());
    var dayOfYear = ((today - onejan +1)/86400000);
    return Math.ceil(dayOfYear/7)
};

// Create array for if calendar week number and week 1, 2 or holiday.
jQuery(function () {
    var today = new Date();
    var weekno = new Array();
    weekno[1] = "Week 2";
    weekno[2] = "Week 1";
    weekno[3] = "Week 2";
    weekno[4] = "Week 1";
    weekno[5] = "Week 2";
    weekno[6] = "Week 1";
    weekno[7] = "Holidays!";
    weekno[8] = "Week 1";
    weekno[9] = "Week 2";
    weekno[10] = "Week 1";
    weekno[11] = "Week 2";
    weekno[12] = "Week 1";
    weekno[13] = "Holidays!";
    weekno[14] = "Holidays!";
    weekno[15] = "Week 1";
    weekno[16] = "Week 2";
    weekno[17] = "Week 1";
    weekno[18] = "Week 2";
    weekno[19] = "Week 1";
    weekno[20] = "Week 2";
    weekno[21] = "Week 1";
    weekno[22] = "Holidays!";
    weekno[23] = "Week 2";
    weekno[24] = "Week 1";
    weekno[25] = "Week 2";
    weekno[26] = "Week 1";
    weekno[27] = "Week 2";
    weekno[28] = "Week 1";
    weekno[29] = "Week 2";
    weekno[30] = "Holidays!";
    weekno[31] = "Holidays!";
    weekno[32] = "Holidays!";
    weekno[33] = "Holidays!";
    weekno[34] = "Holidays!";
    weekno[35] = "Week 1";
    weekno[36] = "Week 2";
    weekno[37] = "Week 1";
    weekno[38] = "Week 2";
    weekno[39] = "Week 1";
    weekno[40] = "Week 2";
    weekno[41] = "Week 1";
    weekno[42] = "Week 2";
    weekno[43] = "Holidays!";
    weekno[44] = "Week 1";
    weekno[45] = "Week 2";
    weekno[46] = "Week 1";
    weekno[47] = "Week 2";
    weekno[48] = "Week 1";
    weekno[49] = "Week 2";
    weekno[50] = "Week 1";
    weekno[51] = "Holidays!";
    weekno[52] = "Holidays!";
    
    //Lookup week number against array
    var weeknoresult = weekno[today.getWeek()];
    //Return result to id=week
    $("#week").html(weeknoresult);
});