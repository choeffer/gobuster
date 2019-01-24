gobuster
========

Shell script which installs needed packages/workarounds/quirks to
properly run Debian Buster on a Surface Go + Surface Dock.

About
-----

The goal of this script is to get Debian Buster running on the
Surface Go without any glitches so that it can be used as a
daily driver.
All changes are just adjusted settings or installed packages etc.
to be as close as possible to original Debian. The goal is
to get the stuff upstream and the issues solved and not to build
something new or reinvent the wheel. Just proper adjustments to 
get Debian working like a charm.

Feedback, issues, ideas, pull request etc. are welcome.

What is working:

* Type-Cover (backlight, FN keys, Touchpad)
* Touchscreen incl. multitouch gestures of GNOME
* Pen (in Wayland even eraser is recognized at least in GNOME Settings)
* Wifi
* Bluetooth (just bluetooth LE devices are not found via GUI)
* Speakers
* Power and Volume buttons
* SD Card Reader
* Hibernate
* Suspend
* Sensors (accelerometer, gyroscope, ambient light sensor)
* Battery Readings
* Docking/Undocking Type-Cover
* Surface Dock_
* USB-C

Not tested but should work:

* DisplayPort

What is not working:

* Cameras

Installation
------------

Before installing Debian, please ensure that secure boot is disabled.

The script is tested with the following settings/versions in UEFI. 
See https://support.microsoft.com/en-us/help/4455978/surface-go-update-history
for latest changes.

* Versions
    
    * System UEFI: 1.0.10
    * Intel Management Engine: 11.8.50.3460
    * System Embedded Controller: 1.0.5.0
    * Touch Firmware: 2D90.6124.0000.2000

The following settings are used and are different to the defaults.

* Security

    * Secure Boot -> Disabled

* Boot configuration

    * Advanced options

        * Enable alternate boot sequence -> Enabled
        * Enable IPv6 for PXE Network boot Option - > Disabled
        * Enable Boot from USB devices -> Enabled
        * Enable Boot Configuration Lock -> Disabled

    * Configure boot device order

        #. USB Storage
        #. Windows Boot Manager
        #. Internal Storage
        #. Network Boot-IPV4
        #. Network Boot-IPV6

    * Kiosk Mode
    
        * Battery Limit -> Enabled

First, download the git folder to your home folder.

The open a terminal and navigate to the gobuster folder.

.. note::

    Before executing the script please ensure that 'contrib non-free' are
    added to /etc/apt/sources.list and that the system has installed 
    latest updates (apt-get update && apt-get dist-upgrade).

Then simple execute the script (as root or with root privileges).

... code-block:: console

    sudo sh ./setup.sh

Tips
----

To connect bluetooth LE devices, first execute in terminal

... code-block:: console

    sudo hcitool lescan

and then the devices are visible via GNOME Settings.

In the UEFI it is possible to set a charging limit 

References
----------

.. target-notes::

.. _Dock: https://www.microsoft.com/en-us/p/surface-dock/8qrh2npz0s0p