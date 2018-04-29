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
$ java -jar ESPlorer.jar
```

```lua
# set wifi.sta.mode
wifi.setmode(wifi.STATION);
wifi.sta.config({ssid="ssid-name", pwd="ssid-password"})
print(wifi.sta.getip());
```

```
# STEPS FOR FLASH NODEMCU FIRMWARE TO ESP-01S
# 参考
# https://www.youtube.com/watch?v=Gh_pgqjfeQc
1.准备一款USB转串口模块UART(推荐CP2102模块)
2.接线
  1）下载模式（刷机模式）
     ESP: 3V3  <--> UART:3V3
     ESP: EN   <--> UART:3V3
     ESP: RX   <--> UART:TXD
     ESP: TX   <--> UART:RXD
     ESP: GND  <--> UART:GND
     ESP: IO0  <--> UART:GND (注意这个)
  2) 工作模式
     ESP: 3V3  <--> UART:3V3
     ESP: EN   <--> UART:3V3
     ESP: RX   <--> UART:TXD
     ESP: TX   <--> UART:RXD
     ESP: GND  <--> UART:GND

```
