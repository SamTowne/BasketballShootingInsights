// This is the node.js to build the form. It is not managed by terraform.

function createForm() {

    var form = FormApp.create('3 Point Shooting Drill');

    form.setTitle('3 Point Shooting Drill')
        .setDescription('Attempt 10 shots from each location. Submit the results to measure progress over time.')
        .setConfirmationMessage('Your response has been recorded.')
        .setAllowResponseEdits(true)
        .setAcceptingResponses(true);
    
    //place holder image. replace it with ../img/half_court.png
    var img = UrlFetchApp.fetch('https://www.google.com/images/srpr/logo4w.png');

    form.addImageItem()
        .setTitle("Shot Locations")
        .setHelpText("Image of the shot locations.")
        .setImage(img);
    
    Logger.log('Published URL: ' + form.getPublishedUrl());
    Logger.log('Editor URL: ' + form.getEditUrl());
}

/*
3:08:41 PM	Info	Published URL: https://docs.google.com/forms/d/e/1FAIpQLScNSWSGfUbGOnuqpee249apfmNzX3vO7c_G9WL6pndUZ8dBxQ/viewform
3:08:41 PM	Info	Editor URL: https://docs.google.com/forms/d/1s6AMfIuYqMPl3Yl5N1GrPdUmgEy0YXd4ihNVvcWzS1w/edit
*/