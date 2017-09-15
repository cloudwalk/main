# Funky Main App

Funky application responsible for start DaFunk ecosystem.

## What's inside?

- A small Ruby application that uses [da_funk](https://github.com/cloudwalkio/da_funk).
- Example test cases.
- All the scripts needed to make it work.

## Flags

- emv_application_name_table - If "1" display application name by params.dat

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
