//TODO: output api gateway endpoint and insert here so it is dynamic at app standup
var post_url = "https://whmhl1hgge.execute-api.us-east-1.amazonaws.com/si/submit"

function onFormSubmit(e) {

  console.log('form submitted');

  var form = FormApp.getActiveForm();
  var allResponses = form.getResponses();
  var latestResponse = allResponses[allResponses.length - 1];
  var response = latestResponse.getItemResponses();

  //shots made from each position in the shooting drill
  var shots_made_spot_1 = response[0].getResponse();
  var shots_made_spot_2 = response[1].getResponse();
  var shots_made_spot_3 = response[2].getResponse();
  var shots_made_spot_4 = response[3].getResponse();
  var shots_made_spot_5 = response[4].getResponse();
  var shots_made_spot_6 = response[5].getResponse();
  var shots_made_spot_7 = response[6].getResponse();
  var shots_made_spot_8 = response[7].getResponse();
  var shots_made_spot_9 = response[8].getResponse();
  var shots_made_spot_10 = response[9].getResponse();
  var shots_made_spot_11 = response[10].getResponse();

  var headers = {
    "Content-Type": "application/json",
  };

  var options = {
    "method": "post",
    "headers": headers,
    "payload": JSON.stringify(
      {
        "shots_made_spot_1":shots_made_spot_1,
        "shots_made_spot_2":shots_made_spot_2,
        "shots_made_spot_3":shots_made_spot_3,
        "shots_made_spot_4":shots_made_spot_4,
        "shots_made_spot_5":shots_made_spot_5,
        "shots_made_spot_6":shots_made_spot_6,
        "shots_made_spot_7":shots_made_spot_7,
        "shots_made_spot_8":shots_made_spot_8,
        "shots_made_spot_9":shots_made_spot_9,
        "shots_made_spot_10":shots_made_spot_10,
        "shots_made_spot_11":shots_made_spot_11
      }
    )
  };

  UrlFetchApp.fetch(post_url, options)

};