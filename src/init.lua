local app = {
  LED_R = 0,
  LED_G = 3,
  LED_B = 4,
  SYS_TIMER_TICK_ID = 0,
  SYS_TIMER_ID = 1,
  SYS_INTERVAL = 10,
  timers = {},
  web_cos = {},
}

local __tm_ticks__ = 0;
local __EN_HIGH__ = 1;
local EN_ON = (__EN_HIGH__ == 1 ) and gpio.HIGH or gpio.LOW;
local EN_OFF = (__EN_HIGH__ == 1 ) and gpio.LOW or gpio.HIGH;

local function tickcount()
  return __tm_ticks__;
end

local function co_timers_check()
  local rms = {};
  local now = tickcount();
  for idx, t in ipairs(app.timers) do
    if now > t.timeout then
      coroutine.resume(t.co);
      table.insert(rms, idx);
    end
  end
  r = table.remove(rms);
  while r do
    table.remove(app.timers, r);
    r = table.remove(rms);
  end
end

local function async_sleep(miseconds)
  local co = coroutine.running();
  if co then
    local now = tickcount();
    local r = {timeout = now + miseconds, co = co};
    table.insert(app.timers, r);
    coroutine.yield();
  end
end

local function blink(ms)
  gpio.write(app.LED_B, EN_ON);
  async_sleep(ms);
  gpio.write(app.LED_B, EN_OFF);
  async_sleep(ms);
end

local function color(r, g, b, ms)
  if r == 1 then gpio.write(app.LED_R, EN_ON) end
  if g == 1 then gpio.write(app.LED_G, EN_ON) end
  if b == 1 then gpio.write(app.LED_B, EN_ON) end
  async_sleep(ms)
  if r == 1 then gpio.write(app.LED_R, EN_OFF) end
  if g == 1 then gpio.write(app.LED_G, EN_OFF) end
  if b == 1 then gpio.write(app.LED_B, EN_OFF) end
  async_sleep(ms)
end

local function style_RGB(interval)
  color(1, 0, 0, interval)
  color(0, 1, 0, interval)
  color(0, 0, 1, interval)
end

local function style_FULL(interval)
  color(0, 0, 1, interval)
  color(0, 1, 0, interval)
  color(0, 1, 1, interval)
  color(1, 0, 0, interval)
  color(1, 0, 1, interval)
  color(1, 1, 0, interval)
  color(1, 1, 1, interval)
end

function frames_style(tick, interval, style)
  for i=1, tick do
    style(interval)
  end
end


local function task()
  for i=1, 1 do
    frames_style(3, 50, style_RGB)
    frames_style(2, 500, style_RGB)
    frames_style(1, 1000, style_RGB)
    frames_style(3, 50, style_FULL)
    frames_style(2, 500, style_FULL)
    frames_style(1, 1000, style_FULL)
  end
end

local function run_idle()
  local ticks = 0;
  while 1 do
    local empty = true;
    for k, co in pairs(app.web_cos) do
      if coroutine.status(co) ~= 'dead' then
        empty = false;
        break;
      end
    end
    if empty == true then
      blink(1000);
      ticks = ticks - 1;
      if ticks == 0 then
        print('clear web_cos');
        app.web_cos = {};
      end
    else
      ticks = 5;
      print('busyyyy');
      async_sleep(1000);
    end
  end
  print('run_idle exit....');
end

local function async_send(sck, data)
  local co = coroutine.running();
  sck:on("sent", function(s)
    coroutine.resume(co)
  end)
  sck:send(data)
  coroutine.yield()
end

local function make_response(sck, data)
  print(data);
  async_send(sck, 'hello - world\r\nauthor: rockee \r\n');
  sck:close();
  task();
  async_sleep(5000);
  print('make_response done');
end

local function entry()
  local co = coroutine.create(function()
    print('setup-TIMERS')
    tmr.alarm(app.SYS_TIMER_TICK_ID, 1, 1, function ()
      __tm_ticks__ = __tm_ticks__ + 1;
    end)
    tmr.alarm(app.SYS_TIMER_ID, app.SYS_INTERVAL, 1, co_timers_check);

    print('setup-LEDRGB');
    gpio.mode(app.LED_R, gpio.OUTPUT);
    gpio.mode(app.LED_G, gpio.OUTPUT);
    gpio.mode(app.LED_B, gpio.OUTPUT);

    while wifi.sta.getip() == nil do
      -- print('blink ...')
      blink(100);
    end
    print('startup-websvr: ', wifi.sta.getip());
    srv = net.createServer(net.TCP)
    srv:listen(80, function(conn)
      conn:on("receive", function (sck, data)
        local wc = coroutine.create(make_response);
        table.insert(app.web_cos, wc);
        coroutine.resume(wc, sck, data);
      end);
    end)
    print('running idle')
    run_idle();
  end);
  coroutine.resume(co)
end

entry();


