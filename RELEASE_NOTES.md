# Main

Funky application responsible for start DaFunk ecosystem.

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