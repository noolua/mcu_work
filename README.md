# a RESTFul websvr on ESP8266 

#### 刷新最新的固件

  * 安装TTY的驱动CP2102或者CH340G
  * 安装esptool.py

```bash
$ ls /dev/tty.*
$ sudo esptool.py --port /dev/tty.SLAB_USBtoUART erase_flash
$ sudo esptool.py --port /dev/tty.SLAB_USBtoUART write_flash -fm qio 0x00000 nodemcu_float_0.9.6-dev_20150704.bin
```
