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
to be as close as possible to original Debian. See further down what 
is needed to be fixed and how it is solved at the moment. Also links
to the bug reports are listed there. The goal is
to get the stuff upstream and the issues solved and not to build
something new or reinvent the wheel. Just proper adjustments to 
get Debian working like a charm.

Feedback, issues, ideas, pull request etc. are welcome.

What is working:

* Type-Cover (backlight, FN keys)
* Touchpad (up to four finger gestures tested)
* Touchscreen incl. `multitouch gestures`_ of GNOME
* Pen (in Wayland (Debian Buster default) even eraser is recognized, at least in GNOME Settings)
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

* DisplayPort via USB-C

What is not working:

* Cameras

Installation
------------

Before installing Debian, please ensure that secure boot is disabled.

The script is tested with the following settings/versions in UEFI. 
See `Surface Go update history`_ for latest changes. Also the
Surface Dock is updated to the latest firmware_ .

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

        * Battery Limit -> Enabled , see `Battery`_ what this option does and if you want to enable it.

The following debian installation image was used
``debian-buster-DI-alpha4-amd64-netinst.iso``, see debian-installer_ .
This is the recommended way to install Debian Buster/Testing right now.

After installation, download the git folder to your home folder.

.. code-block:: console

    git clone https://github.com/choeffer/gobuster.git

Then navigate to the gobuster folder

.. code-block::

    cd gobuster

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

.. _`Battery`:

Battery
^^^^^^^

In the UEFI it is possible to set a charging limit, see 
`Battery Limit setting`_ .

Issues and their fixes
----------------------

Wifi (solved)
^^^^^^^^^^^^^

In the latest firmware-atheros package the board data for the used
QCA6174 wifi chip is missing. The needed board.bin is included here
and replaces the one from the debian package to get the wifi chip
working. See https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=919652 
for more information.

Suspend (solved)
^^^^^^^^^^^^^^^^

Default in Debian is to use s2idle instead of deep. This can be seen
via ``cat /sys/power/mem_sleep`` which outputs "[s2idle] deep". The
battery drain was very high with s2idle (25% in 8h). For more
information about the difference, see
https://www.kernel.org/doc/html/v4.19/admin-guide/pm/sleep-states.html .
The device is supporting S3, see ``dmesg | grep ACPI:`` 
outputs "(supports S0 S3 S4 S5)". So via GRUB a kernel parameter 
https://www.kernel.org/doc/html/v4.19/admin-guide/kernel-parameters.html
is passed to the kernel to set "deep" as default which enables str.
Now ``cat /sys/power/mem_sleep`` outputs "s2idle [deep]", so str is
enabled. This leads to a drastically lower battery drain in suspend
(11% in 18h).

Dock Ethernet (solved)
^^^^^^^^^^^^^^^^^^^^^^

By default, the Ethernet chip is recognized but not fully functional.
I turns out that there are some power-management issues, see
https://github.com/jakeday/linux-surface/issues/259. Therefore, via
GRUB a kernel parameter is passed to the kernel to enable a quirk
(USB_QUIRK_NO_LPM (device can't handle Link Power Management)).
After applying this the Dock is fully functional.
Hot plugging is working, so just attach the Dock whenenver
wanted/needed independent of the device is on/str/off. It just
works so far in every situation. E.g. suspending the device, afterwards
attach the dock wich is connected to e.g. a TV via HDMI, and after
resuming it will directly get recognized. See,
https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=919656 for more
information.

Typecover/Touchpad (workaround)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Somehow after str the backlight, CAPSLOCK-light and FN-light of the
typecover are not working. Also the touchpad of the typecover is
sometimes not working after a boot/reboot. It was needed to detach
and then attach the typevover again. This is now implemented as a
systemd service which detachs/unbind the usb typecover/device after
every boot and resuming from suspend. This works because the typecover
automatically reconnects on its own after getting disconnnected and
is working properly again after 2-3 seconds.
See https://askubuntu.com/questions/1036341/unplug-and-plug-in-again-a-usb-device-in-the-terminal/1036410#1036410
for more information.

Touchscreen (workaround)
^^^^^^^^^^^^^^^^^^^^^^^^

Touchscreen is not properly recognizing scroll/swipe input. It is
recognized very often as click input. Also the device in general is
not recognized properly. In GNOME settings a battery of the touchscreen
is shown etc. and other glitches in the logs.  Multitouch and Pen are
working fine, but this is more a hack then a solution right now. But
at least it is now fully functional. The runtime power management is
changed via a systemd service after boot to avoid that the device enters
a lower power state and then comes back which introduced the not
wanted click inputs. See https://www.kernel.org/doc/html/v4.19/driver-api/pm/devices.html#sys-devices-power-control-files
, https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=919648 and
https://github.com/jakeday/linux-surface/issues/251 for more information.

References
----------

.. target-notes::

.. _`multitouch gestures`: https://wiki.gnome.org/Design/OS/Gestures
.. _Dock: https://www.microsoft.com/en-us/p/surface-dock/8qrh2npz0s0p
.. _`Surface Go update history`: https://support.microsoft.com/en-us/help/4455978/surface-go-update-history
.. _firmware: https://docs.microsoft.com/en-us/surface/surface-dock-updater
.. _debian-installer: https://www.debian.org/devel/debian-installer/index.en.html
.. _`Battery Limit setting`: https://docs.microsoft.com/en-us/surface/battery-limit

