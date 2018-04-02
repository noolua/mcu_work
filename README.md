# a RESTFul websvr on ESP8266 

#### 刷新最新的固件

  * 安装TTY的驱动CP2102或者CH340G
  * 安装esptool.py
  * download [ESPlorer](https://esp8266.ru/esplorer/)

```bash
# steps for update firmware from 0.9.6 to master-version
$ ls /dev/tty.*
$ sudo esptool.py --port /dev/tty.SLAB_USBtoUART erase_flash
$ sudo esptool.py -b 921600 --port /dev/tty.SLAB_USBtoUART write_flash -fm dio 0x00000 nodemcu-master-10-modules-2018-04-02-12-46-35-float.bin 
```

```lua
# set wifi.sta.mode
wifi.setmode(wifi.STATION);
wifi.sta.config({ssid="ssid-name", pwd="ssid-password"})
print(wifi.sta.getip());
```
