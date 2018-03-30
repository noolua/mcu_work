app = {
  LED = 1,
  SYS_TIMER_TICK_ID = 0,
  SYS_TIMER_ID = 1,
  SYS_INTERVAL = 10,
  timers = {},
  web_cos = {},
}

__tm_ticks__ = 0;

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
  gpio.write(app.LED, gpio.HIGH);
  async_sleep(ms);
  gpio.write(app.LED, gpio.LOW);
  async_sleep(ms);
end

local function task()
  for i=1, 30 do
    blink(50);
  end
end

local function web_in_idle()
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
  print('web_in_idle exit....');
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

local function setup()
  print('setup-CO-TIMERS')
  tmr.alarm(app.SYS_TIMER_TICK_ID, 1, 1, function ()
    __tm_ticks__ = __tm_ticks__ + 1;
  end)
  tmr.alarm(app.SYS_TIMER_ID, app.SYS_INTERVAL, 1, co_timers_check);

  print('setup-LED');
  gpio.mode(app.LED, gpio.OUTPUT)
  print('setup-websvr: ', wifi.sta.getip());
  srv = net.createServer(net.TCP)
  srv:listen(80, function(conn)
    conn:on("receive", function (sck, data)
      local co = coroutine.create(make_response);
      table.insert(app.web_cos, co);
      coroutine.resume(co, sck, data);
    end);
  end)
end

local function entry()
  setup();
  local co = coroutine.create(web_in_idle);
  coroutine.resume(co)
end

entry();


