# compliance-viewer

A small application to access scan results stored in S3.

[![Build Status](https://travis-ci.org/18F/compliance-viewer.svg?branch=develop)](https://travis-ci.org/18F/compliance-viewer)
[![Dependency Status](https://gemnasium.com/18F/compliance-viewer.svg)](https://gemnasium.com/18F/compliance-viewer)
[![Code Climate](https://codeclimate.com/github/18F/compliance-viewer/badges/gpa.svg)](https://codeclimate.com/github/18F/compliance-viewer)
[![Test Coverage](https://codeclimate.com/github/18F/compliance-viewer/badges/coverage.svg)](https://codeclimate.com/github/18F/compliance-viewer/coverage)

## Running The Application

### Setup

Compliance Viewer relies on MyUSA for access control. You will need to create an application at https://staging.my.usa.gov to get it running.

Create `config/production.yml` and `config/development.yml` based on the `config/example.yml`. This contains the configuration info for your AWS bucket as well as a few other application options.

### Locally

Create the following environment variables:

`APP_ID`: MyUSA Consumer Public Key 
`APP_SECRET`: MyUSA Consumer Secret Key 
`COOKIE_SECRET`: A secret for your encrypted cookies.

You can generate a good secret with:
```
ruby -rsecurerandom -e "puts SecureRandom.hex(32)"
```

Run the application with `rackup`.

### On Cloud.gov

The 18F instance of Compliance Viewer is deployed to cloud.gov in the `cf` organization and `toolkit` space.

Compliance Viewer currently uses an s3 bucket provided by cloud.gov. After pushing the application, you can create the s3 bucket with:
```
cf create-service s3 basic s3-compliance-toolkit
cf bind-service compliance-viewer s3-compliance-toolkit
cf env compliance-viewer
```

The `cf env` command will return the environment for `compliance-viewer`, including the information for the newly created bucket:
```
"s3": [
  {
    "credentials": {
     "access_key_id": "ACCESS_KEY",
     "bucket": "BUCKET_NAME",
     "secret_access_key": "SECRET_KEY",
     "username": "USERNAME"
  },
...
```

You can update your credentials file with the first three pieces of information, and then re-push the app with `cf push`.

Alternatively, you can use an S3 bucket created directly via AWS.

Compliance Viewer relies on S3 bucket versioning. It can be enabled via:
```
aws s3api put-bucket-versioning --bucket BUCKET_NAME --versioning-configuration Status=Enabled
```
or checked via:
```
aws s3api get-bucket-versioning --bucket BUCKET_NAME 
```

To use MyUSA for authentication, you need to run:
```
cf set-env app-name APP_ID your_myusa_public_key
cf set-env app-name APP_SECRET your_myusa_secret_key
cf set-env app-name COOKIE_SECRET your_cookie_secret
cf restage app-name 
```

### Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
