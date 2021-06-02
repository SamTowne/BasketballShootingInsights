// When Form Gets submitted

function onFormSubmit(e) {

  // Make a POST request with form data.
  var payload = JSON.stringify(e.response);
  var options = {
    'method' : 'post',
    'payload' : payload
  };
  UrlFetchApp.fetch('https://whmhl1hgge.execute-api.us-east-1.amazonaws.com/si/submit', options);
  }
  