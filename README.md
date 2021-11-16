# raspbx-unofficial
How to run the container:

docker run --name=raspbx-unofficial --net=macvlan_network --ip=192.00.00.00 -itd --privileged --restart unless-stopped sohojmanush/raspbx-unofficial
I use macvlan, your's might vary.

#Accessing the USB modem:
You need to use sudo chmod 777 /dev/ttyUSB* on the host machine. But, this is not persistent after reboot. To make it persistent after boot on your host machine

sudo nano /etc/udev/rules.d/92-dongle.rules and add

KERNEL=="ttyUSB*"
MODE="0666"
OWNER="asterisk"
GROUP="uucp"
This will make the permission persistent. Source: https://wiki.e1550.mobi/doku.php?id=troubleshooting#

But, in case you multiple types of devices connected to your host and only want to give dongle access to the container then on your host machine:

lsusb -vvv
Note the idVendor(e.g.,067b) & idProduct(e.g.,2303). then again on the host

sudo nano /etc/udev/rules.d/50-dongle.rules
and paste

SUBSYSTEMS=="usb"
ATTRS{idVendor}=="067b"
ATTRS{idProduct}=="2303"
GROUP="uucp" 
MODE="0666"
and

sudo udevadm control --reload
or reboot.

At this point your container should've access to the dongle.

Now, you need to shell into the container and run

$ install-dongle

To get container ID

'docker ps' list container ID 'docker exec -it /bin/bash

Now,

$ lsusb
$ asterisk -rvvv
$ dongle discovery

This will output the IMEI & IMSI number of the dongle. Now, type 'exit' in asterisk CLI.

$ cd /etc/asterisk/
$ ls
$ nano dongle.conf
Sample, dongle.conf:

[general]

interval=15			; Number of seconds between trying to connect to devices
smsdb=/var/lib/asterisk/smsdb
csmsttl=600

;------------------------------ JITTER BUFFER CONFIGURATION --------------------------
;jbenable = yes			; Enables the use of a jitterbuffer on the receiving side of a
				; Dongle channel. Defaults to "no". An enabled jitterbuffer will
				; be used only if the sending side can create and the receiving
				; side can not accept jitter. The Dongle channel can't accept jitter,
				; thus an enabled jitterbuffer on the receive Dongle side will always
				; be used if the sending side can create jitter.

;jbforce = no			; Forces the use of a jitterbuffer on the receive side of a Dongle
				; channel. Defaults to "no".

;jbmaxsize = 200		; Max length of the jitterbuffer in milliseconds.

;jbresyncthreshold = 1000	; Jump in the frame timestamps over which the jitterbuffer is
				; resynchronized. Useful to improve the quality of the voice, with
				; big jumps in/broken timestamps, usually sent from exotic devices
				; and programs. Defaults to 1000.

;jbimpl = fixed			; Jitterbuffer implementation, used on the receiving side of a Dongle
				; channel. Two implementations are currently available - "fixed"
				; (with size always equals to jbmaxsize) and "adaptive" (with
				; variable size, actually the new jb of IAX2). Defaults to fixed.

;jbtargetextra = 40		; This option only affects the jb when 'jbimpl = adaptive' is set.
				; The option represents the number of milliseconds by which the new jitter buffer
				; will pad its size. the default is 40, so without modification, the new
				; jitter buffer will set its size to the jitter value plus 40 milliseconds.
				; increasing this value may help if your network normally has low jitter,
				; but occasionally has spikes.

;jblog = no			; Enables jitterbuffer frame logging. Defaults to "no".
;-----------------------------------------------------------------------------------

[defaults]
; now you can set here any not required device settings as template
;   sure you can overwrite in any [device] section this default values

context=default			; context for incoming calls
group=0				; calling group
rxgain=0			; increase the incoming volume; may be negative
txgain=0			; increase the outgoint volume; may be negative
autodeletesms=yes		; auto delete incoming sms
resetdongle=yes			; reset dongle during initialization with ATZ command
u2diag=-1			; set ^U2DIAG parameter on device (0 = disable everything except modem function) ; -1 not use ^U2DIAG command
usecallingpres=yes		; use the caller ID presentation or not
callingpres=allowed_passed_screen ; set caller ID presentation		by default use default network settings
disablesms=no			; disable of SMS reading from device when received
				;  chan_dongle has currently a bug with SMS reception. When a SMS gets in during a
				;  call chan_dongle might crash. Enable this option to disable sms reception.
				;  default = no

language=en			; set channel default language
mindtmfgap=45			; minimal interval from end of previews DTMF from begining of next in ms
mindtmfduration=80		; minimal DTMF tone duration in ms
mindtmfinterval=200		; minimal interval between ends of DTMF of same digits in ms

callwaiting=auto		; if 'yes' allow incoming calls waiting; by default use network settings
				; if 'no' waiting calls just ignored
disable=no			; OBSOLETED by initstate: if 'yes' no load this device and just ignore this section

initstate=start			; specified initial state of device, must be one of 'stop' 'start' 'remote'
				;   'remove' same as 'disable=yes'

exten=+1234567890		; exten for start incoming calls, only in case of Subscriber Number not available!, also set to CALLERID(ndid)

dtmf=relax			; control of incoming DTMF detection, possible values:
				;   off	   - off DTMF tones detection, voice data passed to asterisk unaltered
				;              use this value for gateways or if not use DTMF for AVR or inside dialplan
				;   inband - do DTMF tones detection
				;   relax  - like inband but with relaxdtmf option
				;  default is 'relax' by compatibility reason

; dongle required settings
[dongle0]
audio=/dev/ttyUSB1		; tty port for audio connection; 	no default value
data=/dev/ttyUSB2		; tty port for AT commands; 		no default value

; or you can omit both audio and data together and use imei=123456789012345 and/or imsi=123456789012345
;  imei and imsi must contain exactly 15 digits !
;  imei/imsi discovery is available on Linux only
imei=123456789012345
imsi=123456789012345

; if audio and data set together with imei and/or imsi audio and data has precedence
;   you can use both imei and imsi together in this case exact match by imei and imsi required
See, at the bottom there two type of options audio,data and IMEI,IMSI. If you have multiple dongles then fill in the IMEI, IMSI field.

Credits: https://github.com/tiredofit/docker-freepbx

https://wiki.e1550.mobi/doku.php?id=troubleshooting#

https://www.xmodulo.com/change-usb-device-permission-linux.html
