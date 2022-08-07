## Presentation

This module manages Quicksight resources for the presentation of shooting drill data. Some of the setup has been done via AWS Console.

* Registering for Quicksight for the AWS Account
* Initial configuration of Quicksight (Identity settings, federation, IAM)
* An IAM role was created as part of the Console setup process and is not managed in this repo at this time
* The actual dashboard configuration is done via console
* Manifest Configuration File manually uploaded
* In the future, it may be good to consider managing all or most of these things via a lambda/API calls so that more of these steps can be done programatically.


### Manifest Configuration File
The manifest file is used to specify data sources for Quicksight. The file `quicksight_mainfest.json` was manually uploaded to the S3 Bucket. If changes need to be made, they should be committed here and then manually re-uploaded.