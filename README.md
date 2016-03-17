# compliance-viewer

A small application to access scan results stored in S3.

[![Build Status](https://travis-ci.org/18F/compliance-viewer.svg?branch=master)](https://travis-ci.org/18F/compliance-viewer)
[![Dependency Status](https://gemnasium.com/18F/compliance-viewer.svg)](https://gemnasium.com/18F/compliance-viewer)
[![Code Climate](https://codeclimate.com/github/18F/compliance-viewer/badges/gpa.svg)](https://codeclimate.com/github/18F/compliance-viewer)
[![Test Coverage](https://codeclimate.com/github/18F/compliance-viewer/badges/coverage.svg)](https://codeclimate.com/github/18F/compliance-viewer/coverage)

## Running The Application

### Setup

Compliance Viewer relies on MyUSA for access control. You will need to create an application at https://staging.my.usa.gov to get it running.

Create a `credentials.yml` based on the `credentials.example.yml`. This contains the configuration info for your AWS bucket.

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

After doing a `cf push`, you will need to run:
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
