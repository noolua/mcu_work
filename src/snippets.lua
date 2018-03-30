
--[[
sudo esptool.py --port /dev/tty.SLAB_USBtoUART write_flash -fm qio 0x00000 nodemcu_float_0.9.6-dev_20150704.bin
sudo esptool.py --port /dev/tty.SLAB_USBtoUART erase_flash
/dev/tty.wchusbserial1410
--]]

srv = net.createServer(net.TCP)

function receiver(sck, data)
  print(data)
  local resp = 'hello - world\r\nauthor: rockee \r\n'

  sck:on("sent", function(s)
    s:close()
    resp = nil
  end)
  sck:send(resp)
end

srv:listen(80, function(conn)
  conn:on("receive", receiver)
end)



local LED0 = 0

LED_R = 2
LED_G = 0
LED_B = 1

function setup()
  gpio.mode(LED_R, gpio.OUTPUT)
  gpio.mode(LED_G, gpio.OUTPUT)
  gpio.mode(LED_B, gpio.OUTPUT)
end

function color(r, g, b, ms)
  local interval = ms * 1000
  if r == 1 then
    gpio.write(LED_R, gpio.LOW)
  end
  if g == 1 then
    gpio.write(LED_G, gpio.LOW)
  end
  if b == 1 then
    gpio.write(LED_B, gpio.LOW)
  end
  tmr.delay(interval)
  if r == 1 then
    gpio.write(LED_R, gpio.HIGH)
  end
  if g == 1 then
    gpio.write(LED_G, gpio.HIGH)
  end
  if b == 1 then
    gpio.write(LED_B, gpio.HIGH)
  end
  tmr.delay(interval)
end



function style_RGB(interval)
  color(1, 0, 0, interval)
  color(0, 1, 0, interval)
  color(0, 0, 1, interval)
end

function style_FULL(interval)
  color(0, 0, 1, interval)
  color(0, 1, 0, interval)
  color(0, 1, 1, interval)
  color(1, 0, 0, interval)
  color(1, 0, 1, interval)
  color(1, 1, 0, interval)
  color(1, 1, 1, interval)
end

function frames_style(tick, interval, fn_style)
  for i=1, tick do
    fn_style(interval)
  end
end

TICKS = 20000000
function main()
  local tick = TICKS
  while tick > 0 do
    frames_style(15, 50, style_RGB)
    -- frames_style(30, 100, style_RGB)
    frames_style(5, 500, style_RGB)
    frames_style(3, 1000, style_RGB)
    -- style_RGB(5000)
    frames_style(10, 50, style_FULL)
    -- frames_style(30, 100, style_FULL)
    frames_style(5, 500, style_FULL)
    frames_style(3, 1000, style_FULL)
    -- style_FULL(5000)
    tick = tick - 1
  end
end


if not tmr.create():alarm(15000, tmr.ALARM_SINGLE, function()
  print('fireddd')
  setup()
  main()
end)
then
  print("whoopsie")
end
print('wait for 15 seconds: file.remove("init.lua")')
print('set TICKS=0 to disable one time')




