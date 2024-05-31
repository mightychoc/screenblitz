
```

      ,/                                                                  ,/
    ,'/         _____                          _     _ _ _              ,'/
  ,' /         / ____|                        | |   | (_) |           ,' /
,'  /_____,   | (___   ___ _ __ ___  ___ _ __ | |__ | |_| |_ ____   ,'  /_____,
.'____    ,'   \___ \ / __| '__/ _ \/ _ \ '_ \| '_ \| | | __|_  /   .'____    ,'
     /  ,'     ____) | (__| | |  __/  __/ | | | |_) | | | |_ / /         /  ,'
    / ,'      |_____/ \___|_|  \___|\___|_| |_|_.__/|_|_|\__/___|       / ,'
   /,'                                                                 /,'
  /'                                                                  /'

Screenblitz by mightychoc
github.com/mightychoc/screenblitz 

```

[![Github release](https://img.shields.io/github/release/mightychoc/screenblitz\?style\=for-the-badge&logo\=github&color\=008000)](https://github.com/mightychoc/screenblitz/releases/)
![In development](https://img.shields.io/badge/Under_Construction!-red?style\=for-the-badge&logo\=adblock)

<!-- [![Github all downloads](https://img.shields.io/github/downloads/mightychoc/screenblitz/total\?style\=for-the-badge)](https://GitHub.com/mightychoc/screenblitz/) -->

`screenblitz` is an addon to the Hak5 [Screen Crab](https://shop.hak5.org/products/screen-crab), a video man-in-the-middle implant. To gain access to the captured screen recordings, we either need to use the Hak5 Cloud C2 service for remote access or grab the microSD card from the device. `screenblitz` now offers a third option: Comfortably access your screen captures by using `blitz` over the Global Socket Relay Network (GSRN).

### About Global Socket

Global Socket is a toolkit developed by [@hackerschoice](https://github.com/hackerschoice). It replaces the IP-Layer by its own Gsocket-Layer in order to allow two users to connect via TCP, even if they are behind a firewall. Gsocket uses the GSRN to connect the clients using locally derived temporary session keys and IDs based on a secret given by the user. Although you can use the GSRN for free, you can also route the traffic from your connections through your own infrastructure using [Global Socket Relay](https://github.com/hackerschoice/gsocket-relay/). For more information on Gsocket, see the [official website](https://www.gsocket.io/) or the [github repo](https://github.com/hackerschoice/gsocket).

# TLDR

If you just want to get started using `screenblitz` quickly, follow these steps.

- Adapt the `config.txt` file generated on the first boot of the Screen Crab. Make sure it can connect to the Internet and set `CAPTURE_MODE IMAGE`and `STORAGE ROTATE`.

- Adapt `SECRET`, `TIMEOUT` and (if applicable) `GSOCKET_IP` in`screenblitz/.env`
    - `SECRET` defines the password used to connect the clients
    - The captured files are transfered every `TIMEOUT` seconds
    - `GSOCKET_IP` specifies the IP address of your self-hosted GSRN-server. Leave blank if you want to use the public GSRN.

- Copy the `screenblitz` directory to your microSD card

- Get a shell running on your crab and run:
    ```bash
    cd /mnt/media_rw/<your-microSD>/screenblitz
    ./install.sh
    ```

![In development](https://img.shields.io/badge/Is_Client_listening_needed-red?style\=for-the-badge&logo\=adblock)
![In development](https://img.shields.io/badge/Check_if_chmod_is_necessary-red?style\=for-the-badge&logo\=adblock)

- Wait for the installation to finish, then reboot
- Connect the Screen Crab to the target device
- Grab your loot using `blitz -s <your-secret> -l` inside your destination folder

# Installation

### Preparing the Screen Crab

The first thing we need is an empty microSD card, which is used to save the captured data locally, hold all necessary configuration files and to transfer the `screenblitz` binaries onto the crab. Make sure the card is **exFAT** formated, then plug it into your Screen Crab and boot the device. After approximately 30 seconds, the boot process is finished and the Crab's LED turns white. Eject the microSD card or remove it after shutting down the Screen Crab. This initial boot process generates a `config.txt` file on the microSD card. Open the `config.txt` file in your favourite text editor and edit the file like so:

* Ensure that `CAPTURE_MODE IMAGE` and `STORAGE ROTATE` are set.
* Choose a `CAPTURE_INTERVAL` (in seconds) which suits your needs.
* Uncomment the `WIFI_SSID` and `WIFI_PASS` fields and enter your network credentials.

> [!WARNING]
> Make sure to put your credentials in quotation marks and to escape special characters ([Docs](https://docs.hak5.org/screen-crab/getting-started/configuring-cloud-c#wifi-configuration)).

You should end up with something like this:

```yaml
#################################################################################
#             ____   ____ ____  _____ _____ _   _    ____ ____      _    ____   #
#            / ___| / ___|  _ \| ____| ____| \ | |  / ___|  _ \    / \  | __ )  #
# (\/)  (\/) \___ \| |   | |_) |  _| |  _| |  \| | | |   | |_) |  / _ \ |  _ \  #
#  ||'°°'//   ___) | |___|  _ <| |___| |___| |\  | | |___|  _ <  / ___ \| |_) | #
# ./ W  W \. |____/ \____|_| \_\_____|_____|_| \_|  \____|_| \_\/_/   \_\____/  #
#            Screen Crab by Hak5                                           v1   #
#################################################################################

LED ON
CAPTURE_MODE IMAGE
CAPTURE_INTERVAL 5
STORAGE ROTATE
BUTTON EJECT

### CONFIGURATION OPTIONS ###
# LED [ON, OFF]
#
# CAPTURE_MODE [IMAGE, VIDEO, OFF]
#   (LED indication: Image=Blue, Video=Yellow, Off=Off)
#
# DEDUPLICATE [ON, OFF]
#   (Only for IMAGE CAPTURE_MODE)
#
# CAPTURE_INTERVAL [N]
#   (in N seconds)
#
# STORAGE [ROTATE or FILL]
#
# BUTTON [EJECT, OFF]
#
# VIDEO_BITRATE [LOW, MEDIUM, HIGH]
#   (low 2Mbps, medium 4Mbps, high 16Mbps)
#
WIFI_SSID "MyWifiName"
#
WIFI_PASS "MySecretPassword"
#   (Omit WIFI_PASS for open networks)
#   (Omit BOTH WIFI_PASS and WIFI_SSID to disable wireless)
#
# ### ADDITIONAL HELP ###
# https://www.hak5.org/crab-help
``` 

### Set Up `screenblitz`

The configuration of `screenblitz` is pretty straight forward. Once you downloaded the code, open the `screenblitz/.env` file in your favourite text editor and specify your desired configuration:

```yaml
SECRET=<your-secret>
TIMEOUT=30
GSOCKET_IP=XXX.XXX.XXX.XXX
```

- `SECRET` defines the password used to connect the clients. Default is `screenblitz`.
- The captured files are transfered every `TIMEOUT` seconds. Default is `30`.
- `GSOCKET_IP` specifies the IP address of your self-hosted GSRN-server. Leave blank if you want to use the public GSRN. Default is `blank`.

> [!NOTE]
> Don't confuse `TIMEOUT` in `screenblitz/.env` with the `CAPTURE_INTERVAL` from the Screen Crab's `config.txt`. `CAPTURE_INTERVAL` defines how often an image of the screen is saved to the microSD card. `TIMEOUT` defines the timeout between two synchronisations between the Crab and the listening server. So for example if `CAPTURE_INTERVAL` is set to `5` and and `TIMEOUT` is set to `30`, then every thirty seconds the six pictures captured during that time will get transmitted to the listener.

Next, copy the entire `screenblitz` directory to the root directory of your microSD card:

```bash
cp -r screenblitz /path/to/sd-card/mountpoint
```

![In development](https://img.shields.io/badge/Check_if_chmod_is_necessary-red?style\=for-the-badge&logo\=adblock)

> [!CAUTION]
> The installer script is expecting to find a directory called `screenblitz` on the microSD card. Make sure to copy the whole directory and not just its contents!

### Getting a Shell on the Screen Crab

![In development](https://img.shields.io/badge/Check_warranty-red?style\=for-the-badge&logo\=adblock)


In order to install `screenblitz` we need to have a terminal on the Screen Crab. In order to get there, start by removing the top cover of your Screen Crab (other side of where you plug in your microSD). Wire the Crab to a serial bus adapter by connecting **RX <-> TX**, **TX <-> RX** and **GND <-> GND** but do not yet plug the adapter into your machine. Run `sudo dmesg -w` on your machine and plug the adapter into your device. You should see something like this:

```yaml
[100.000000] usb 1-3: new full-speed USB device number 20 using xhci_hcd
[100.000000] usb 1-3: New USB device found, idVendor=XXXX, idProduct=XXXX, bcdDevice= 6.00
[100.000000] usb 1-3: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[100.000000] usb 1-3: Product: XXXX
[100.000000] usb 1-3: Manufacturer: XXXX
[100.000000] usb 1-3: SerialNumber: XXXX
[100.000000] ftdi_sio 1-3:1.0: FTDI USB Serial Device converter detected
[100.000000] usb 1-3: Detected FT232R
[100.000000] usb 1-3: FTDI USB Serial Device converter now attached to ttyUSB0
```

As we can see from the last line, we have a connection to the serial bus on `/dev/ttyUSB0`. Run `sudo screen /dev/ttyUSB0 115200`, then plug your microSD card into the Crab and connect it to power. You should now see the Screen Crab booting up. Again, wait for about 30 seconds until the output stops, then press <kbd>Enter</kbd> to see a prompt.

### Check Internet Connection

On the Crab terminal, run `ip a` and look for an output like this:

```yaml
wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
 link/ether XX:XX:XX:XX:XX:XX brd XX:XX:XX:XX:XX:XX
 inet XXX.XXX.XXX.XXX/24 brd XXX.XXX.XXX.XXX scope global wlan0
    valid_lft forever preferred_lft forever
 inet6 XXXX::XXXX:XXXX:XXXX:XXXX/64 scope link 
    valid_lft forever preferred_lft forever
```
To check that your connection is working, just `ping -c 5` your favourite wepage. Ensure that you're able to receive packets and don't suffer any packet loss:

```shell
--- forums.hak5.com ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4000ms
rtt min/avg/max/mdev = 149.790/224.146/445.605/112.644 ms
```

### Set Up Folder Watcher


Before we can start using our modified Screen Crab, we need to get the listening server up and running. If you have your own GSRN-server, don't forget to specify the `GSOCKET_IP` before starting the listener:

```bash
#Only run this line if you have your own Gsocket relay
export GSOCKET_IP=<your-ip>

cd /path/to/destination/directory
blitz -s <your-secret> -l
```

![In development](https://img.shields.io/badge/Is_Client_listening_needed-red?style\=for-the-badge&logo\=adblock)

>[!CAUTION]
> It is crucial that the listener is running before the Screen Crab is booted up and trying to transfer captured files!

> If you forgot to start the listener early, just start it and then reboot the Screen Crab. However, by nature of the intended usage of the Screen Crab, this can be tricky.

### Finish Installation








# Troubleshooting

- Is GSOCKET_IP exported?
- Is listener running before the crab?
- use svc to enable/disable wifi card

--> Maybe to a separate Markdown file?