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
* Suspend (in 18h just 11% battery drain; one test run)
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
See `Surface Go update history`_ for latest changes.

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

        * USB Storage
        * Windows Boot Manager
        * Internal Storage
        * Network Boot-IPV4
        * Network Boot-IPV6

    * Kiosk Mode
    
        * Battery Limit -> Enabled

The following debian installation image was used
``debian-buster-DI-alpha4-amd64-netinst.iso``, see debian-installer_ .
This is the recommended way to install Debian Buster/Testing right now.

After installation, download the git folder to your home folder.

.. code-block:: console

    git clone https://github.com/choeffer/gobuster.git

Then navigate to the gobuster folder

.. code-block::

    cd gobuster

.. note::

    Before executing the script please ensure that 'contrib non-free' are
    added to /etc/apt/sources.list and that the system has installed 
    latest updates (apt-get update && apt-get dist-upgrade).

and simple execute the script (as root or with root privileges).

.. code-block:: console

    sudo sh ./setup.sh

Tips
----

Bluetooth
^^^^^^^^^

To connect bluetooth LE devices, first execute in terminal

.. code-block:: console

    sudo hcitool lescan

and then the devices are visible via GNOME Settings.

Battery
^^^^^^^

In the UEFI it is possible to set a charging limit, see 
`Battery Limit setting`_ .

References
----------

.. target-notes::

.. _Dock: https://www.microsoft.com/en-us/p/surface-dock/8qrh2npz0s0p
.. _`Surface Go update history`: https://support.microsoft.com/en-us/help/4455978/surface-go-update-history
.. _debian-installer: https://www.debian.org/devel/debian-installer/index.en.html
.. _`Battery Limit setting`: https://docs.microsoft.com/en-us/surface/battery-limit
