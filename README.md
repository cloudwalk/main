# Funky Main App

Funky application responsible for start DaFunk ecosystem.

## What's inside?

- A small Ruby application that uses [da_funk](https://github.com/cloudwalkio/da_funk).
- Example test cases.
- All the scripts needed to make it work.

## Flags from params.dat

- `emv_application_name_table` - If 1 display application name by params.dat;
- `connection_management` (Default 1) - If 1 connection management will be turned on and the main application will keep the communication up based on the last configuration. If any communication issue the main application will attempt in loop;
- `conn_fallback_drops_limit` (Default 0: disable) - Drop limit of primary connection to start a fallback;
- `conn_fallback_config` (Default "": disable) - Fallback configuration, ei.: `GPRS|chili|chili|`;
- `conn_fallback_timer` (Default 0: disable) - Time until try the primary connection again (seconds);
- `api_token` (Default "": disable) - Manager api token to upload any log file;
- `disable_datetime` (Default 0: disable) - If 1 Disable date time display at main idle screen;
- `emv_enabled` (Default 0: disable) - If 1 module EMV will be loaded and EMV transactions will be accepted;
- `transaction_conn_check` (Default 0: disable) - If 1 check if terminal is connected to perform transactions (Mag or EMV) and reversals;
- `access_token` (Default "": disable) - Payment channel access token;
- `payment_channel_enabled` (Default 0: disable) - If 1 payment channel will be handle by the main application, access_token must to exist.
- `encrypt_card` (Default 0: disable) - If 1 the PAN will be encrypted using 3DES injected keys to share between modules;
- `emv_application` (Default "": disable) - Application that will be called after a EMV(insert card) input;
- `attach_gprs_timeout` (Default "": disable) - timeout in miliseconds
- `backlight_control` (Default "120": enable, seconds) - If enable ( > 0) perform backlight control and turn off the backlight based on the time in seconds of this parameter if any event happen, if disable (0) keep backlight always on.
- `countdown_application` (Default "": AdministrationMenu) - Application to be called if communication failure countdown.

## Setup

1. Install Ruby
2. Bundle `bundle install`

## Running

Make sure you have either mruby or the CloudWalk CLI tool, then run `rake` to build the app, and one of the following commands to see it working, depending on your interests:

- `cloudwalk emulate`: to run the application in a graphical emulator in a separated window.
- `cloudwalk run`: to run the application in text mode in the same window.

## Deploying

In case you're using this skeleton from a new application created by our CLI, your application will be deployed to our servers after `git push`. Be sure to add all the files you require and to test everything before pushing, otherwise the deploy will be rejected.

## Test

1. Unit `rake test:unit`
2. Integration `rake test:integration`
3. All `rake test`

## Customizing the app

To customize the application, read our docs at <https://docs.cloudwalk.io/en/cli> or check [da_funk's source code](https://github.com/cloudwalkio/da_funk).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

```
The MIT License (MIT)

Copyright (c) 2016 CloudWalk, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
### 
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
