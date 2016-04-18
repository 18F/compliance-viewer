# compliance-viewer

A small application to access scan results stored in S3.

[![Build Status](https://travis-ci.org/18F/compliance-viewer.svg?branch=master)](https://travis-ci.org/18F/compliance-viewer)
[![Dependency Status](https://gemnasium.com/18F/compliance-viewer.svg)](https://gemnasium.com/18F/compliance-viewer)
[![Code Climate](https://codeclimate.com/github/18F/compliance-viewer/badges/gpa.svg)](https://codeclimate.com/github/18F/compliance-viewer)
[![Test Coverage](https://codeclimate.com/github/18F/compliance-viewer/badges/coverage.svg)](https://codeclimate.com/github/18F/compliance-viewer/coverage)

## Running The Application

### Setup

Compliance Viewer relies on MyUSA for access control. You will need to **create an application** at https://alpha.my.usa.gov to get it running.

For your new application:

1. The "Redirect uri" should be `https://<compliance-viewer-address>/auth/myusa/callback`.
1. The "Email Address" checkbox under "Identify you by your email address" should be checked.
1. Take note of the generated "MyUSA Consumer Public Key" and "MyUSA Consumer Secret Key", they are `app_id` and `app_secret` in the ENV.

### ENV
#### Production
We provide ENV variables via [User Provided Services](https://docs.cloudfoundry.org/devguide/services/user-provided.html). You can set them all interactively.

`cf cups compliance-viewer-env -p "app_id, app_secret, cookie_secret, aws_access_key, aws_secret_key, aws_bucket, aws_region, results_folder, results_format"`

The `cf env` command can be used to verify that ENV vars have been set.

Use `cf update-user-provided-service` to update existing values.

#### Locally
User Provided Services expose values via CloudFoundry's `VCAP_SERVICES` ENV Variable, in JSON.  In development we mimic this.

`cp env/example.json env/development.json` and fill out the required fields.  This JSON will be parsed the same way `VCAP_SERVICES` are parsed in production.

Tip: you can generate a good `COOKIE_SECRET` with: `ruby -rsecurerandom -e "puts SecureRandom.hex(32)"`

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

You will need to set these values in the `compliance-viewer-env` User Provided Service.

Alternatively, you can use an S3 bucket created directly via AWS.

Compliance Viewer relies on S3 bucket versioning. It can be enabled via:
```
aws s3api put-bucket-versioning --bucket BUCKET_NAME --versioning-configuration Status=Enabled
```
or checked via:
```
aws s3api get-bucket-versioning --bucket BUCKET_NAME
```

### Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
