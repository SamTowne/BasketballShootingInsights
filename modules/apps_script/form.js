// This is the node.js to build the form. It is not managed by terraform.
var form = FormApp.create('3 Point Shooting Drill');

form.setTitle('3 Point Shooting Drill')
    .setDescription('Attempt 10 shots from each location. Submit the results to measure progress over time.')
    .setConfirmationMessage('Your response has been recorded.')
    .setAllowResponseEdits(true)
    .setAcceptingResponses(true);

form.addImageItem()
    .setTitle("Shot Locations")
    .setHelpText("Image of the 11 shot locations.")
    .setImage("../img/half_court.png");

Logger.log('Published URL: ' + form.getPublishedUrl());
Logger.log('Editor URL: ' + form.getEditUrl());