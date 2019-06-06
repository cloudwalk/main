# Main

Funky application responsible for start DaFunk ecosystem.

### 3.20.0 - 2019-06-06

- Update cw_apns.dat;
- Cache applications in memory;
- Update posxml_parser (2.19.0);
- Update funky-emv (0.26.0);
- Update da_funk (3.8.0);
- Update cloudwalk_handshake (1.4.0).

### 3.19.0 - 2019-05-22

- Update funky-emv (0.24.0);
- Refactoring emv Listener supporting Funky-emv (0.24.0), and update emv_enabled flag use to define allowed as default;
- Fix system update package count and improve interruption ux;
- Add backup emv table to support funky-emv (0.24.0);
- Update cloudwalk_handshake (1.3.0).

### 3.18.0 - 2019-05-21

- Update da_funk (3.6.0);
- Do system reload on main thread after communication update.

### 3.17.0 - 2019-05-13

- Update da_funk (3.5.0).

### 3.16.0 - 2019-05-13

- Update da_funk (3.4.0).

### 3.15.0 - 2019-05-12

- Update da_funk (3.3.1).

### 3.14.0 - 2019-05-10

- Add EventHandler for payment_channel at comm thread. This enable payment_channel Listener check;

### 3.13.0 - 2019-05-10

- On communication thread check communication and payment_channel listener;
- Update funky-emv (0.23.5).

### 3.12.0 - 2019-05-07

- Refactoring fallback communication routine. Create another Listener to handle only communication issues;
- Check all possible listener on communication thread;
- Update funky-emv (0.23.4);
- Update da_funk (3.3.0);
- Added emv_wait messages.

### 3.11.0 - 2019-04-16

- Update cloudwalk_handshake (1.2.3).

### 3.10.0 - 2019-04-16

- Update funky-emv (0.23.3).

### 3.9.0 - 2019-04-16

- Update funky-emv (0.23.2).

### 3.8.0 - 2019-04-15

- Update funky-emv (0.23.1).

### 3.7.0 - 2019-04-15

- Update posxml_parser (2.18.0).

### 3.6.0 - 2019-04-11

- Update da_funk (3.2.1);
- Update posxml_parser (2.17.0).

### 3.5.0 - 2019-04-08

- Add keymap.dat;
- Update funky-emv (0.23.0).

### 3.4.0 - 2019-03-28

- Update cw_apns.dat.

### 3.3.0 - 2019-03-27

- Change default application update period to 360 hours;
- Change default application update interval to 120 hours;
- Change system update strategy:
    - Change default interval to 360 hours;
    - If params.dat system_update_interval 0 disable system update;
- Update posxml_parser (2.16.0);
- Update funky-emv (0.22.0);
- Update cloudwalk_handshake (1.2.2).

### 3.2.0 - 2019-03-14

- Update da_funk (3.2.0);
- Update funky-emv (0.21.0).

### 3.1.0 - 2019-03-14

- Bug fix injected keys log typo;
- Add support to params.dat flag log_upload_enabled.
- Update cloudwalk_handshake (1.2.1)
- Update da_funk (3.1.1)
- Execute upload log routine every 24 hours;
- Refactoring upload logs routine:
    - Upload the log from yesterday;
    - User would be able to cancel upload log in 5 seconds;
    - Minimal fixes and typos.

### 3.0.0 - 2019-02-28

- Update posxml_parser (2.15.0);
- Update da_funk (3.0.0);
- Update cloudwalk_handshake (1.0.0);
- Support to close http socket at the end of an event;
- Force http socket creation during write event on thread communication;
- Update README with new parameter transaction_http_enabled.

### 2.14.1 - 2019-02-16

- Bug fix set payment channel limit disable as default;

### 2.14.0 - 2019-02-16

- Adopt GC.start run on status bar thread;
- Bug fix stuck screen before persist new media config;
- Run GC.star every 10 minutes on communication thread;
- Run GC.star every 10 minutes on main thread;
- Reload runtime engine every 24 hours and if memory reaches 14mb;
- Call PaymentChannel.connect on mag and emv listener events, this start the payment channel creation (on communication thread) even if limit is exceed;
- Force payment channel creation if it doesn’t exists on comm thread. Logic is trigged if a write message (from main thread) is queued.

### 2.13.0 - 2019-02-15

- Update posxml_parser (2.14.0).

### 2.12.0 - 2019-02-07

- Bug fix during communication update between threads to only close the socket if media configuration was changed;
- Update da_funk (2.5.1);
- Update posxml_parser (2.13.1).

### 2.11.0 - 2019-02-06

- Update posxml_parser (2.13.0).

### 2.10.0 - 2019-02-05

- Update da_funk (2.5.0);
- Update funky-emv (0.20.2).

### 2.9.0 - 2019-01-23

- Implement CloudwalkUpdate.system routine, first implementation of UX system update improvement process;
- User can cancel automatic update in 10 seconds;
- Update handlers to update and system update; - Set default update interval to 24 hours; - Set default system update interval to 168 (week).

### 2.8.1 - 2019-01-14

- Update posxml_parser.

### 2.8.0 - 2019-01-14

- Add MAC address to communication show;
- Update da_funk (2.4.0);
- fix symbol name on case.

### 2.7.0 - 2019-01-08

- Update da_funk (2.3.0);
- Update posxml_parser (2.11.0);
- Add apps and system update to execute options.

### 2.6.0 - 2018-12-20

- Update posxml_parser (2.10.0).

### 2.5.0 - 2018-12-13

- Update posxml_parser (2.9.0).

### 2.4.0 - 2018-12-04

- Refactoring PAX S920 key map inverting ALPHA by FUNC;
- Update da_funk (2.2.0);
- Update cloudwalk (1.11.4).

### 2.3.0 - 2018-11-28

- Support ThreadScheduler.pause at communication thread to not execute any event handler during other threads connection attempts;
- Move ThreadScheduler to mruby-context;
- Check if communication thread is sleeping before checking any communication object;
- Remove DaFunk::PaymentChannel.client definition at call and move to mruby-context;
- Support to ThreadPubSub subscription performing system reload on communication update event;
- Update da_funk (2.1.0);
- Update posxml_parser (2.8.6).

### 2.2.0 - 2018-10-11

- Update posxml_parser (2.8.5);
- Update da_funk (2.0.4);
- Update funky-emv (0.20.1);
- Review key_main events to link2500 terminals.

### 2.1.4 - 2018-10-05

- Update posxml_parser (2.8.4).

### 2.1.3 - 2018-10-05

- Update funky-emv (0.20.0);
- Update da_funk (2.0.1).

### 2.1.2 - 2018-10-05

- Check if threads were created to stop them at ThreadScheduler;
- ThreadScheduler only start status bar if applicable;
- Support payment channel connect between threads;
- Remove countdown menu from payment channel handler because this handler is being handle in thread;
- Refactoring main execution parser.

### 2.1.1 - 2018-10-03

- Increased timeout on getc during idle key waiting loop.

### 2.1.0 - 2018-10-03

- Remove backlight control in thread;
- Remove notification handler on communication thread;
- Update status bar updating period from 400 to 1000ms;
- Adopt custom notification handle at main thread;
- Fix ThreadScheduler command cache always returning the vale to key value structure;
- Fix fallback communication in thread communication;
- At ThreadChannel handler loop only communicate if string is given;
- Change strategy to thread spawn at thread scheduler to avoid missing loaded libs as da_funk execute create eval string in other scope.

### 2.0.0 - 2018-10-02

- Add ThreadScheduler interface to handle threads on communication and status bar operation;
- Support Thread scheduling on boot;
- Stop/start communication threads between network reconfiguration;
- Add link/unlink image to payment channel status;
- Fix communication thread printing;
- Update da_funk (2.0.0).

### 1.87.0 - 2018-09-21

- Update cloudwalk (1.11.2).
- Update funky-emv (0.19.0).

### 1.86.0 - 2018-09-18

- Update funky-emv (0.18.1).

### 1.85.0 - 2018-09-17

- Update funky-emv (0.18.0).

### 1.84.0 - 2018-09-10

- Update cloudwalk_handshake (0.13.2).
- Update posxml_parser (2.8.3).

### 1.83.0 - 2018-08-30

- Implement communication test at admin menu.
- Update da_funk (1.13.1).
- Update posxml_parser (2.8.0).
- Update cloudwalk_handshake (0.13.1).
- Refactoring media configuration to support device reboot and communication test after configuration.
- Adopt da_funk confirm helper at wizard.
- Refactoring language form at wizard to support exit.

### 1.82.0 - 2018-08-17

- Update cloudwalk_handshake (0.13.0).
- Implement Notification to reboot system.
- Reboot system after remote update.
- Refactoring wizard and application menu check adding application update at the end of wizard and moving crc check from first ENTER press to boot, speeding up key press on idle.
- Support update interval feature, if not configured the default is 7 days interval.
- Update posxml_parser (2.7.0).
- Add admin_communication main entry option.

### 1.81.0 - 2018-08-09

- Update posxml_parser (2.6.1).

### 1.80.0 - 2018-08-09

- Add debug flag as false to compilation config.
- Implement new update strategy that supports multiple files.
- Update cloudwalk (1.10.0).
- Update da_funk (1.12.0).
- Update funky-emv (0.17.2).
- Update posxml_parser (2.6.0).

### 1.79.0 - 2018-07-31

- Update posxml_parser (2.5.0).

### 1.78.0 - 2018-07-03

- Update posxml_parser (2.4.0).

### 1.77.0 - 2018-07-02

- Update funky-emv (0.17.1).

### 1.76.0 - 2018-07-02

- Support selection of operator when dealing with multioperator chip.
- Update da_funk (1.11.2).

### 1.75.1 - 2018-05-22

- Update posxml_parser (2.3.4).
- Update da_funk (1.11.1).

### 1.75.0 - 2018-05-18

- Update da_funk (1.11.0).

### 1.74.0 - 2018-05-18

- Add 3 password attempts to menu.
- Refactoring communication error countdown.
- Update funky-emv (0.17.0).
- Update cloudwalk (1.9.1).

### 1.73.0 - 2018-05-09

- Update posxml_parser (2.3.3).

### 1.72.0 - 2018-04-11

- Check communication before system update.

### 1.71.0 - 2018-03-27

- Update posxml_parser (2.3.2).
- Restart if signature change.

### 1.70.0 - 2018-03-22

- Fix Notification reply.

### 1.69.0 - 2018-03-15

- Update posxml_parser (2.3.1).

### 1.68.0 - 2018-03-15

- Update posxml_parser (2.3.0).

### 1.67.0 - 2018-03-09

- Turn on display if any key is pressed.

### 1.66.0 - 2018-03-02

- Update posxml_parser (2.2.1).

### 1.65.0 - 2018-03-01

- Update posxml_parser (2.2.0).

### 1.64.0 - 2018-03-01

- Update posxml_parser (2.1.1).

### 1.63.0 - 2018-02-15

- Update posxml_parser (1.3.1).

### 1.62.0 - 2018-02-09

- Update da_funk (1.7.1) and remove payment channel files, which was moved to da_funk.
- Support key menu.

### 1.61.0 - 2018-02-05

- Send notification reply to notification.
- Fix “AGUARDE” message during system update.
- Fix system update message.

### 1.60.0 - 2018-01-26

- Update funky-emv (0.16.2).

### 1.59.0 - 2018-01-24

- Update da_funk (1.5.0).

### 1.58.0 - 2018-01-24

- Update da_funk (1.4.4).

### 1.57.0 - 2018-01-22

- Bug fix timeout on APN menu.
- Replace disconnect and power off functions for shutdown at communication menu.
- Support to change terminal signature in about entry.

### 1.56.0 - 2018-01-18

- Update funky-emv (0.16.1).

### 1.55.0 - 2018-01-18

- Update da_funk (1.4.3).

### 1.54.0 - 2018-01-17

- Fix countdown application configuration and implement generic parameter from params.dat.
- Update cloudwalk (1.4.2).
- Update da_funk (1.4.2).
- Update posxml_parser (1.2.2).

### 1.53.0 - 2018-01-17

- Add wait message before EMVTransaction start.
- Update da_funk (1.4.1).
- Update posxml_parser (1.2.1).

### 1.52.0 - 2018-01-16

- Update I18n emv_enter_pin text.
- Update cloudwalk (1.4.0).
- Update da_funk (1.4.0).
- Update funky-emv (0.16.0).
- Update funky-simplehttp (0.5.0).
- Update posxml_parser (1.2.0).

### 1.51.0 - 2018-01-12

- Update posxml_parser (1.1.0).
- Update da_funk(1.3.1).

### 1.50.0 - 2018-01-11

- Update da_funk (1.2.0).

### 1.49.0 - 2018-01-10

-  Main::call receives Json to execute normal or admin menu.
- Add menu option to delete only zip files.
- Update posxml_parser (1.0.0).
- Update cloudwalk (1.1.0).
- Update da_funk (1.1.1).
- Add menu option to delete only zip files.

### 1.48.0 - 2018-01-04

- Implement menu entry to force app update with crc check (without cache) and force update all files.
- Turn on Notification and Notification Callbacks.
- Remove chars no ascii table at i18n.json.
- Fix system update return line display.
- PaymentChannel rescue SocketError and PolarSSL::SSL::Error.
- Implement PaymentChannel::configured? to check error.
- Replace Device:: for DaFunk:: on Transaction, ParamsDat and Notication.
- Receive json on main.
- Update cloudwalk_handshake (0.12.0).
- Update posxml_parser (0.31.0).
- Update funky-emv (0.15.0).
- Update da_funk (1.0.0).

### 1.47.0 - 2017-12-13

- Update posxml_parser (0.30.0).

### 1.46.0 - 2017-12-07

- Add support to backlight control configuration from parameters.
- Add countdown menu entry when communication fail on fallback recovery.
- Update da_funk (0.28.0).

### 1.45.0 - 2017-12-04

- Update da_funk (0.27.0).

### 1.44.0 - 2017-12-01

- Support to display merchant name.

### 1.43.0 - 2017-11-30

- Update posxml_parser (0.29.0).

### 1.42.0 - 2017-11-30

- Check if params.dat exists before return connection_management flag.

### 1.41.0 - 2017-11-28

- Update da_funk (0.26.0).
- Update funky-emv (0.14.0).
- Update posxml_parser (0.28.0).

### 1.40.0 - 2017-11-22

- Check if cw_app_keys has “DEFINIR_APN” for manual entry too.
- Update posxml_parser (0.27.0).

### 1.39.0 - 2017-11-08

- Update da_funk (0.24.0).

### 1.38.0 - 2017-11-08

- Update posxml_parser (0.26.0).
- Update cloudwalk_handshake (0.11.0).
- Update da_funk (0.23.0).

### 1.37.0 - 2017-11-07

- Force close payment channel after communication management fail.

### 1.36.0 - 2017-11-04

- Update da_funk (0.22.0).

### 1.35.0 - 2017-11-03

- Check connection before execute mag or emv transaction.
- Bug fix the primary connection try logic after reboot.
- Update da_funk (0.21.0).
- Update posxml_parser (0.25.0).
- Add all flags to README.

### 1.34.0 - 2017-10-31

- Update posxml_parser (0.24.0).
- Bugfix apn password method call.
- Fix PaymentChannel failure check to remove client instance and try again.
- Adopt connection_management default as 1.
- Update da_funk (0.20.0).

### 1.33.0 - 2017-10-30

- Uodate funky-emv (0.13.0)

### 1.32.0 - 2017-10-23

- Update funky-emv (0.12.0)

### 1.31.0 - 2017-10-10

- Update funky-emv (0.11.0)

### 1.30.0 - 2017-09-26

- Update funky-emv (0.10.0).
- Update da_funk (0.19.0).
- Update cloudwalk (0.9.0).

### 1.29.0 - 2017-09-15

- Add MIT License to README.
- Fix display font setup.

### 1.28.0 - 2017-09-08

- Bug Fix check if font file exist to update it.

### 1.27.0 - 2017-09-06

- Update funky-emv (0.9.1).

### 1.26.0 - 2017-09-06

- Add Flags section at README.
- Update funky-emv (0.9.0).

### 1.25.0 - 2017-09-06

- Update da_funk (0.16.0)

### 1.24.0 - 2017-09-05

- Update posxml_parser (0.23.0).
    - Move EventListener to main application.
- Bug fix logical number form at initialisation flow.
- Support to custom font.

### 1.23.0 - 2017-08-30

- Adopt cloudwlak 0.7.1.
- Update da_funk (0.15.0)

### 1.22.0 - 2017-08-29

- Move cloudwalk.rb to cloudwalk_setup.rb.
- Add cloudwalk gem.
- Update da_funk (0.14.0).

### 1.21.0 - 2017-08-21

- Check if handshake was performed to display successful message on Paymentchannel reconnect.
- Add timeout read loop to payment channel handshake.
- Update posxml_parser (0.22.0).

### 1.20.0 - 2017-08-18

- Update posxml_parser (0.21.0).

### 1.19.0 - 2017-08-16

- Update posxml_parser (0.20.1).

### 1.18.0 - 2017-08-16

- Support disable_datetime flag.
- Update da_funk (0.13.0) and posxml_parser (0.19.0).

### 1.17.0 - 2017-08-14

- Update da_funk (0.12.0).

### 1.16.0 - 2017-08-10

- Decrease getc wait milliseconds of key_main handler from 700 to 200.
- Bug fix, only close PaymentChannel client if it was created.
- Rescue SocketError at PaymentChannel.
- Fix connection management flag.

### 1.15.0 - 2017-08-08

- Update cloudwalk_handshake (0.9.0), da_funk(0.10.0) and posxml_parser (0.16.0).
- Adopt print_last for PaymentChannel displays.
- Check if Device is connected on PaymentChannel life check.
- Refactoring primary_communication label return on PaymentChannel.
- Bug fix set media_primary on media configuration.
- Check if is main connection is running to validate fallback at ConnectionManagement.
- Additional check to ConnectionManagement before try primary connection recovery.
- Adopt Device::Network.shutdown at payment channel handlers and trigger fallback recovery if primary communication try has failed.
- Adopt print_last at CloudWalk and MediaConfiguration.

### 1.14.0 - 2017-08-03

- Create alias for conn_fallback_config as config at ConnectionManagement.

### 1.13.0 - 2017-08-03

- Fix exception when connection management fallback not available.

### 1.12.0 - 2017-08-02

- Update funky-emv (0.7.0).

### 1.11.0 - 2017-07-25

- Update da_funk(0.9.2) posxml_parser(0.15.3) and funky-emv(0.6.0).
- Adopt da_funk 0.9.2: - Device::Setting.wifi_password; - Device::Setting.media_primary; - Bool return for Device::Network.connected?
- Refactoring Connection Management and Payment Channel handlers to support fallback communication.

### 1.10.0 - 2017-07-13

- Update funky-emv (0.5.9).

### 1.9.0 - 2017-07-13

- Add all files from resources to keep in format process.

### 1.8.0 - 2017-07-12

- Update da_funk(0.9.1).
- Do not exclude cw_apns.dat.
- Update funky-tlv (0.2.3).
- Update posxml_parser (0.15.2).

### 1.7.0 - 2017-07-05

- Exclude bmp platform files from format.
- Apply backlight control for all models.
- Turn the backlight after Handler execution.
- Update da_funk (0.9.0).

### 1.6.0 - 2017-06-30

- Update posxml_parser (0.15.1).
- Update da_funk (0.8.6).

### 1.5.0 - 2017-06-22

- Update da_funk (0.8.5).
- Support GPOS400 keys on hide menus.
- Implement backlight control for Gertec.

### 1.4.11 - 2017-06-21

- Update posxml_parser (0.14.10).

### 1.4.10 - 2017-06-20

- Update posxml_parser (0.14.9).

### 1.4.9 - 2017-06-20

- Update posxml_parser (0.14.8).

### 1.4.8 - 2017-06-13

- Update posxml_parser (0.14.7).
- Update funky-emv (0.5.8).
- Increase listener getc timeout to 700 milliseconds.
- Disconnect interface before scanning.
- Update da_funk (0.8.4).

### 1.4.7 - 2017-05-30

- Update posxml_parser (0.14.5).


### 1.4.6 - 2017-05-29

- Update posxml_parser (0.14.3).

### 1.4.5 - 2017-05-29

- Update posxml_parser (0.14.3).

### 1.4.4 - 2017-05-17

- Set Device::Setting.boot = 1 when starting main application.
- Update posxml_parser (0.14.0).

### 1.4.3 - 2017-04-11

- Only configure button to stop engine if Context is in development mode.

### 1.4.2 - 2017-04-05

- Display if communication is successful configured.
- Update posxml_parser (0.13.1).

### 1.4.1 - 2017-03-30

- Check if terminal connected to send log.
- Always set klass main during Engine loop.
- Update funky-emv (0.5.7).

### 1.4.0 - 2017-03-14

- Update posxml_parser 0.13.0.
- Support to cw_apns.dat (api options menu) file.

### 1.3.4 - 2017-03-05

- Refactoring communication configuration flow to try start communication at the end of the flow.
- Update posxml_parser (0.12.4) e da_funk (0.8.1).

### 1.3.3 - 2017-01-26

- Update posxml_parser (0.12.3).
- Update da_unk (0.8.0).

### 1.3.2 - 2017-01-19

- Update posxml_parser (0.12.1).

### 1.3.1 - 2017-01-17

- Fix scan_wifi and language pt-br i18n message.

### 1.3.0 - 2017-01-17

- Update funky-emv (0.5.6) and posxml_parser (0.12.0).

### 1.2.6 - 2017-01-04

- Update posxml_parser (0.11.4).

### 1.2.5 - 2017-01-02

- Bug fix api_token getting at LogsMenu.
- Bug fix LogsMenu.clear entries path.
- Bug fix I18n admin_logs_success typo.

### 1.2.4 - 2016-12-27

- Update funky-emv (0.5.4).

### 1.2.3 - 2016-12-27

- Update funky-emv (0.5.4).

### 1.2.2 - 2016-12-21

- Update posxml_parser (0.11.3).

### 1.2.1 - 2016-12-19

- Refactoring magnetic setup to not call PosxmlParser.setup every check.
- Update posxml_parser (0.11.2).

### 1.2.0 - 2016-12-19

- Added background images for gpos400 and mp20.
- Implement CloudWalk Payment Channel.
- Disable Notifications.
- Abstract smart card insert check to EmvTransaction class.
- Added emv_pin_locked message.
- Always clean, close and open between emv handlers execution.
- Fix typo on i18n admin_update_apps message.
- Update funky-emv(0.5.2).
- Update da_funk(0.7.18).
- Update posxml_parser(0.11.1).
- Update cloudwalk_handshake(0.8.0).

### 1.1.7 - 2016-11-07

- Update posxml_parser(0.9.7).
- Update funky-emv(0.4.3).

### 1.1.6 - 2016-11-03

- Update posxml_parser(0.9.6)

### 1.1.5 - 2016-11-01

- Added EventHandler for magnetic calls.

### 1.1.4 - 2016-10-10

- Bug fix replace class Screen for SDTOUT (instance of Screen) to get max_y.
- Update posxml_parser(0.9.5)

### 1.1.2 - 2016-10-07

- Add gertec main images.
- Remove spaces at time i18n.
- Print date time in the last line available.
- I18n pt:emv_remove_card to RETIRE CARTAO instead of REMOVA CARTAO.

### 1.1.1 - 2016-10-06

- Update da_funk(0.7.9), funky-emv(0.4.0), posxml_parser(0.9.3) and funky-tlv(0.2.2).
- Bug fix timer handler call.
- Refactoring admin menu improving UX and translation.
- EMV Listener only call initialise if icc.detected.
- Enable Notifications
- Display emv password in the next line.

### 1.1.0 - 2016-09-06

- Change max size of logil_number form on admin menu for 15 chars.
- Add Listener for scheduled processes.
- Add emv Listener.
- Change max size of logical number on wizard to 15 chars.
- Add funky-tlv and funky-emv.
- Refactoring EMV Listener adding finish and init data values.
- Check if Magnetic successfully open to start EventListener.
- Check if emv_acquirer_aids_04.dat exists to start emv EventListener.
- Add key_main EventHandler for s920.
- Add i18n for device not configured error.
- Add main image for s920.
- Bug fix the env acquirer id path in EventListener.
- Refactoring CloudwalkWizard adapting new Screenflow syntax.
- add SystemUpdate class and I18n.
- Add SystemUpdat entry in AdminConfiguration.
- Fix setup process of SystemUpdate screen flow.
- Fix serial number activation step.
- Add EMV message to i18n.json.
- Add emv_enter_pin, emv_incorrect_pin and emv_last_chance I18n message and update emv_select_application message.
- Update da_funk(0.7.5), cloudwalk_handshake(0.6.0), funky-emv(0.3.1) and posxml_parser(0.9.11).
- Refactoring env EventListener to always try to load table file.
- Add support to paperfeed key.
- Refactoring key_main EventListener improving the syntax.
- Temporarily remove notifications.

### 1.0.9 - 2016-06-20 - Fix WIFI configuration

- Fix WIFI configuration flow.

### 1.0.8 - 2016-04-18 - Force params dat update on “Update apps”

- Update posxml_parser to version 0.7.11.
- Update da_funk to version 0.7.3.
- Change key_main EventListener timeout to 400 miliseconds.
- Force params dat update on “Update apps” on admin configuration menu.

### 1.0.7 - 2016-03-14 - Update posxml_parser to version 0.7.8

- Update posxml_parser to version 0.7.8.
- Admin password accept more than 5 chars.
- Add locale configuration on About screen.
- Support to configure locale as configure env.
- Support to stop execution as configure env(Call DaFunk::Engine.stop!).

### 1.0.6 - 2016-03-14 - Update da_funk

- Bug fix on environment change restart only if valid
environment selected.
- Add i18n for booting and notification messages.
- etup EventListener and EventHandler, and adopt app_loop from DaFunk::Engine.
- Update da_funk version to 0.7.0 and posxml_parser version to 0.7.7.

### 1.0.5 - 2016-02-29 - Update da_funk

- Update da_funk version to 0.6.7.
- Move walk.bmp to main.bmp and use Dafunk to print bmp image.
- Add status bar icons.
- Implement magstripe menu.

### 1.0.4 - 2016-02-18 - Update da_funk version

- Update da_funk version to 0.6.6.

### 1.0.2 - 2016-02-16 - First stable version

- First stable version.