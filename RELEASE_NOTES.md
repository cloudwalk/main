# Main

Funky application responsible for start DaFunk ecosystem.

### 3.65.0 - 2021-02-19

- Added new handler to check if emv_table_reload file exists, it means InfinitePay payment application has updated the table and main application needs to reload it;
- Map menu# button to access payment application, only for versions >= 8.1 and S920 model;
- Added :main_menu option which access main menu without password, because in this case the password was validated in another process;
- Added possibility to schedule tasks in minutes and hours for ruby applications;
- Update da_funk (3.33.1)

### 3.64.0 - 2021-02-08

- Update da_funk (3.33.0);
- Added support to images on CloudwalkUpdate#system and CloudwalkUpdate#application;
- Added support to images on system update process.

### 3.63.3 - 2021-01-20

- Added PATH_UPDATE_DONE constant on SystemUpdate class;
- Delete PATH_UPDATE_DONE file if device is up to date.

### 3.63.2 - 2021-01-14

- Added log of pusbsub id registered;
- Close socket on communication thread after media switch only in case media changed and socket is connected.

### 3.63.1 - 2021-01-07

- Added workaround to solve system update error. There's a bug in the PAX::System#update method which returns a wrong result that causes an error in the system update flow, this change workaround this error.

### 3.63.0 - 2021-01-04

- Update keyboard screens;
- Call to thread pause before configuring communication;
- Reload metadata after switching communication;
- Added log in order to know that communication config was updated;
- Set statusbar attributes as nil if thread is paused;
- Update da_funk (3.32.0).

### 3.62.1 - 2020-11-27

- Send all logs when executed manually.

### 3.62.0 - 2020-11-27

- Added new battery percentage icons;
- Update cloudwalk_handshake (1.22.0);
- Enable touchscreen application config on 8.X.X runtime version only;
- Update da_funk (3.31.0).

### 3.61.0 - 2020-11-16

- Added new icon for 3G connection;
- Added new s920 main screen image;
- Added support to touchscreen events which executes other apps;
- Added support to send additional parameters in the function executed from scheduler;
- Update da_funk (3.30.0).

### 3.60.2 - 2020-11-04

- Update cloudwalk_handshake (1.21.3);
- Update da_funk (3.29.1).

### 3.60.1 - 2020-10-26

- Added device was restarted info on log.

### 3.60.0 - 2020-10-07

- Update da_funk (3.28.2);
- Update some images;
- Added new handler to check params.dat status each 60 minutes;
- Update cloudwalk_handshake (1.21.1).

### 3.59.3 - 2020-09-29

- Concatenate and send all logs at once;
- Fixed filename. Log txt should have the date of the day that is being sent;
- Do not send full path as LogsMenu#send_file is already adding path;
- Send all log files separated;
- Moved logs ui feedback to LogsMenu#send_file_menu and LogControl#upload;
- LogsMenu#send_file return booleam as result;
- Store return of each log send.

### 3.59.2 - 2020-09-29

- Update cloudwalk_handshake (1.21.0)

### 3.59.1 - 2020-09-26

- Do not try to download system parts if update file does not exists;
- Check if update dat object exists on SystemUpdate#done? before start it;
- Update da_funk (3.28.1).

### 3.59.0 - 2020-09-25

- Add main application version on config.dat file;
- Move thread loop process to Main#thread_loop metohod, also added rescue on Main#thread_loop;
- Update cloudwalk_handshake (1.20.1);
- Update da_funk (3.27.0);
- Improved system update messages;
- Show system update message at line 0 and alway clear it before;
- Added system_update_start message;
- Check system update status at zero position of string array;
- Print system update message after device restart, in case system update is in progress;
- Added additional information in the system update file in order to know that the device needs to restart before proceed with the system update;
- Added CloudwalkUpdate#wait_connection method;
- Added CloudwalkUpdate#count_down method;
- Added CloudwalkUpdate#system_in_progress? method;
- Wait terminal to connect before start system update in case device has restarted;
- Added system update management file on CloudwalkUpdate;
- Fixed display messages on application update proccess;
- Update da_funk (3.28.0).

### 3.58.0 - 2020-09-14

- Update cloudwalk_handshake (1.20.0);
- Update da_funk (3.26.0);
- Update virtual keyboard images.

### 3.57.0 - 2020-08-28

- Update da_funk (3.25.1);
- Call to CloudwalkUpdate#system instead of SystemUpdate#start so the user can cancel the update process if he wants;
- Added new parameter system_update_main_enabled to enable system update with UI;
- Added system_update_interval scheduler on communication thread in order to download all pieces in background;
- Added system_update_thread_enable parameter to enable/disable update with thread;
- Turn backlight on in the update process;
- Delete system_update file if user cancel update process;
- Start connection on input amount to make contactless transactions a bit faster;
- Added SystemUpdate#done? method in order to check if all pieces were downloaded and to add system_update file again if user has canceled it before.

### 3.56.0 - 2020-08-25

- Added InputTransactionAmount#contactless_minimum_amount_permited;
- Added InputTransactionAmount#contactless_amount_under_permited;
- Display amount bitmap inside loop;
- Added InputTransactionAmount#amount_under_minimum_not_permitted;
- Show amount under minimum permitted message on screen;
- Fixed i18n message symbol;
- Added new i18n text message;
- Added new image on resources.

### 3.55.0 - 2020-08-25

- Only save media on config.dat file if sim_id is not nil;
- Convert sim_id to String before access characters;
- Only try to send log if socket is connected, also display images to show operation result.
- Added support to send logs from another app call;
- Added images to be used on log send process;
- Do not perform default gprs config if network_configured is 1.

### 3.54.0 - 2020-08-18

- Change thread execution and status bar check order, Necessary to not free CPU processing time on transaction execution;
- Added CloudwalkSetup#resume_update;
- Moved CloudwalkSetup#resume_update to AdminConfiguration#configure;
- Implemented AdminConfiguration#device_activated?;
- Perform device configs in case device is not activated;
- Rename method AdminConfiguration#configure to AdminConfiguration#configure_payment_application;
- Update cloudwalk_handshake (1.19.0);
- Update da_funk (3.25.0).

### 3.53.0 - 2020-08-07

- MediaConfiguration defensive code with gsub;
- Update da_funk (3.24.4).

### 3.52.0 - 2020-08-03

- Update da_funk (3.24.3).

### 3.51.0 - 2020-08-01

- Update da_funk (3.24.2).

### 3.50.0 - 2020-07-29

- Update da_funk (3.24.1);
- Update array list of files that shouldn't be removed on clear;
- Added new layout to be used on log send process;
- Added LogContol#layout_exists?;
- Refactor on LogControl#upload;
- Removed LogControl#layout_exists?;
- LogControl#layout;
- Present better interface in the log send;
- Avoiding user to input zero amount;
- Implemented MediaConfiguration#gprs_default.

### 3.49.0 - 2020-07-25

- Validates if menu returned KEY_TIMEOUT to avoid crash app;
- Fixed title on logs menu;
- Removed LogControl#enabled;
- Fixed call to LogControl#write_keys;
- Keep maximum 7 log files;
- Delete log in case user has canceled send;
- Update cloudwalk_handshake (1.16.0);
- Added ability of dynamic log interval send definition;
- Do not return nil on Fixnum comparison to avoid exception;
- Fixed date comparison on LogControl#purge;
- Emit sound to warning the user that logs are about to be send;
- Check if file exists before trying to delete or send it;
- Fixed log file path;
- Fixed handler to check battery level;
- Added new status bar images;
- Added method CloudwalkSetup#update_process_in_progess?;
- Added CloudwalkSetup#boot_layout method;
- Fixed file path on :file_exists handler;
- Call to LogControl purge in the end of handler execution;
- Added layout files to 6 steps update process;
- Call to cw_infinitepay_app to complete update;
- Updated emv table backup;
- Fixed app crash on LogsMenu;
- Update cloudwalk_handshake (1.18.0);
- Update da_funk (3.24.0).

### 3.48.1 - 2020-06-23

- Update cloudwalk_handshake (1.15.0)

### 3.48.0 - 2020-06-22

- Do not stop ThreadScheduler on media configuration;
- Cache ThreadPubSub id on payment_channel listener;
- Update some header images;
- Only clear display on ctls amount if timeout or user cancel;
- Reboot emv interface on magnetic finish;
- Update funky-emv (1.4.1);
- Update da_funk (3.23.0).

### 3.47.0 - 2020-06-18

- Update libs
 - cloudwalk_handshake (1.14.0);
 - da_funk (3.22.0);
 - funky-emv (1.4.0).

### 3.46.1 - 2020-06-16

- Update libs
  - da_funk (3.21.2);
  - funky-emv (1.3.1);
- Fixed app crash if timeout or cancel is returned on LogsMenu.

### 3.46.0 - 2020-06-15

- Updated status bar images;
- Removed unnecessary images from resources/shared;
- Updated AdminConfiguration::KEEP_FILES;
- Added boot welcome image;
- Added support to emv contactless timeout and user canceled messages;
- Update da_funk (3.21.0).

### 3.45.1 - 2020-06-01

- Update funky-emv (1.3.0)

### 3.44.0 - 2020-05-28

- Support new ThreadChannel interface (only read/write);
- Change GC strategy to freak mode (execute every 2 minutes a full GC in all threads);
- Remove stop of engine if memory consumption is to high;
- Remove stop of engine if every 1440 minutes;
- Remove thread status bar;
- Rename PaymentChannel::client to PaymentChannel::current;
- Cache CwMetadata on boot time;
- Check status bar on communication thread;
- Update da_funk (3.20.0);
- Refactoring communication thread loop:
    - Adopt new ThreadScheduler.execute interface (without sending thread id);
    - Do not call Listener if payment channel connected.

### 3.43.1 - 2020-05-14

- Update cloudwalk_handshake (1.13.1)

### 3.43.0 - 2020-04-17

- Update rake from 10.5.0 to 12.3.3;
- Refactor on logs send mechanism, it's not necessary to proxy with switch anymore;
- Update da_funk (3.18.0).

### 3.42.0 - 2020-03-25

- Change reboot timeout to 1440 minutes;

### 3.41.0 - 2020-03-17

- Adopt new THREAD_* flags and pause timeout (200 mesa).

### 3.40.0 - 2020-02-17

- Added handler to also start ctls transaction pressing key number.

### 3.39.0 - 2020-02-11

- Added support of infinitepay endpoint config;
- Update cloudwalk_handshake (1.13.0);
- Update da_funk (3.17.0);
- Clear queue of touch events and increase timeout on getxy_stream to avoid execute handler twice;
- Increase range of touch to start contactless transaction;
- Check if amount is not KEY_TIMEOUT on InputTransactionAmount;
- Check battery level each 5 minutes in order to warning the user that the battery is low when it's in idle status.

### 3.38.0 - 2020-01-31

- Update cloudwalk (1.15.0);
- Update cloudwalk_handshake (1.12.0);
- da_funk (3.16.3);

### 3.37.0 - 2020-01-31

- Use infinitepay logo as default image;
- Removed amount text from main display when ctls is enabled;
- Added :touchscreen event listener;
- Refactored InputTransactionAmount class. CTLS Amount is not being captured from idle anymore, now this call is based on a touch screen event;
- Added event handler for contactless transactions;
- Set getc and with getxy_stream timeout to 100ms to have a better UX;
- Change reset time from 24hrs to 5hrs;

### 3.36.0 - 2020-01-17

- Simple bump version.

### 3.35.0 - 2020-01-17

- Update da_funk (3.15.1).

### 3.34.0 - 2020-01-16

- Update da_funk (3.15.0);
- Update cloudwalk_handshake (1.11.0);

### 3.33.0 - 2020-01-06

- Update da_funk (3.14.0);
- Update posxml_parser (2.26.0);
- Added ruby apps tasks scheduler handler;
- Changed method name setup_app_events to setup_keyboard_events_from_rb_apps;
- Changed file name CwKeys.json to cw_keys.json to have a pattern name;
- Added :boot handler event listener;

### 3.32.0 - 2019-12-30

- Update cloudwalk_handshake (1.10.0);
- Create $thread_name global variable;
- Display message before wait to stop communication on network configuration;

### 3.31.0 - 2019-12-20

- Update da_funk (3.13.1).

### 3.30.1 - 2019-12-18

- Update funky-emv (1.2.2).

### 3.30.0 - 2019-12-03

- Update cloudwalk_handshake (1.9.0).

### 3.29.0 - 2019-12-03

- Update da_funk (3.13.0);
- posxml_parser (2.25.0);
- Added new :file_exists handler to update applications;
- Add system update icon message;
- Add support to system update in background.

### 3.28.0 - 2019-11-22

- Update da_funk (3.12.3).

### 3.27.0 - 2019-11-18

- Update da_funk (3.12.2).

### 3.26.0 - 2019-11-18

- Add ruby application cache;
- Remove possible memory leak on ThreadScheduler inheritance calling.

### 3.25.1 - 2019-10-30

- Update dependencies
 - da_funk (3.11.1)
 - posxml_parser (2.24.1)

### 3.25.0 - 2019-09-27

- Removed cache ruby applications mechanism
- Update cloudwalk_handshake (1.8.1);
- Update posxml_parser (2.24.0);
- Update da_funk (3.11.0)

### 3.24.0 - 2019-07-09

- Update cloudwalk_handshake (1.6.0);
- Update da_funk (3.10.2);
- Update funky-emv (1.2.1);
- Update posxml_parser (2.22.0);
- Send Magnetic object instead track2 only on Magnetic Handler triggering.

### 3.23.0 - 2019-06-19

- Added InputTransactionAmount class to handle input amount on the idle screen and support CTLS from idle.

### 3.22.0 - 2019-06-18

- Replaced executable_apps for ruby_executable_apps that only pre loads ruby applications;
- Add main to manager with the version 1.0.0;
- Add message to main application update reboot;
- Update da_funk (3.8.1, 3.8.2, 3.8.3, 3.9.0);
- Update posxml_parser (2.19.0, 2.20.0, 2.21.0);
- Update funky-emv (1.0.0, 1.1.0);
- Update cloudwalk_handshake (1.4.2).

### 3.21.0 - 2019-06-13

- Update cloudwalk_handshake (1.4.1).

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