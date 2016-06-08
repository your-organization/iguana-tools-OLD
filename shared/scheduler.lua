-- This scheduler module can be used to run a script at a given time
-- first version that allows multiple schedules = ROUGH

-- http://help.interfaceware.com/v6/scheduler-example

local store = require 'store2'
local sDb = store.connect('schedule')
sDb:reset() -- delete all entries when we restart channel

local LastRunTimes = {}
local ScheduledRunTimes = {}

local function NextRunTime(Hour, LastRunTime)
   local T = os.ts.date('*t')
   T.hour = Hour
   T.min = (Hour - math.floor(Hour)) * 60
   T.sec = 0
   local NextTime = os.ts.time(T)
   local LastT = os.ts.date('*t', LastRunTime)
   os.ts.date("%c", LastRunTime)
   if os.ts.difftime(LastRunTime, NextTime) > 0 then
      NextTime = NextTime + 24*60*60
   end
   return NextTime, os.ts.date("%c", NextTime)
end

local function NextRunTime(Hour, LastRunTime)
   local T = os.ts.date('*t')
   T.hour = Hour
   T.min = (Hour - math.floor(Hour)) * 60
   T.sec = 0
   local NextTime = os.ts.time(T)
   local LastT = os.ts.date('*t', LastRunTime)
   os.ts.date("%c", LastRunTime)
   if (os.ts.difftime(LastRunTime, NextTime) > 0) then
      NextTime = NextTime + 24*60*60
   end
   return NextTime, os.ts.date("%c", NextTime)
end

local function RunKeyName(Time, func)
   return iguana.channelName():gsub('%s','_')..
      tostring(func)..' + Time: '..tostring(Time)..'_LastScheduledTime.txt'
end

local function LastRun(Time, func)
   local T = sDb:get(RunKeyName(Time, func))
   trace (T)	
   if not T then
      return 0, 'No recorded run'
   end
   local Last = 'Last run '..tostring(func)..' at '..os.ts.date('%c', tonumber(T))
   return tonumber(T), 'Last run at '..Last
end

local function Status(LastRun, ScheduledTime, func)
   local R
   if LastRun ~= 0 then
      R = 'Last run '..tostring(func)..' at '..os.ts.date('%c', LastRun)
   else
      R = 'Has not run '..tostring(func)..' yet.'
   end
   R = R..'\nScheduled to run at '..os.ts.date('%c',ScheduledTime)

   iguana.setChannelStatus{color='green', text=R}

   return R
end

local function RecordRun(ScheduledHour, func)
   if iguana.isTest() then return end
   local R = os.ts.time()
   sDb:put(RunKeyName(ScheduledHour, func), R)   
   local LastRunTime = R
   ScheduledRunTime = NextRunTime(ScheduledHour, LastRunTime)
   local R  = Status(LastRunTime, ScheduledRunTime, func)
   iguana.logInfo(R)
end

local function Init(Time, func)
   LastRunTimes[tostring(func)..' + Time: '..tostring(Time)] 
      = LastRun(Time, func)
   trace(LastRunTimes)
   local LastRunTime = LastRunTimes[tostring(func)..' + Time: '..tostring(Time)]
   ScheduledRunTimes[tostring(func)..' + Time: '..tostring(Time)]
      = NextRunTime(Time, LastRunTime)
	trace(ScheduledRunTimes)
   ScheduledRunTime = ScheduledRunTimes[tostring(func)..' + Time: '..tostring(Time)]
   local R = Status(LastRunTime, ScheduledRunTime, func)
   iguana.logInfo(R)
   return R, LastRunTime
end

-- the "..." syntax means multiple functions that multiple
-- (optional) parameters can be passed to the function in 
-- a table named "arg" - these are passed to the function
-- by converting them using the "unpack" function
local function runAt(scheduledHour, func, ...)
   local R
   local LastRunTime = LastRunTimes[tostring(func)..' + Time: '..tostring(scheduledHour)]
   trace(LastRunTime) 
   if LastRunTime == 0 or LastRunTime == nil or iguana.isTest() then
      -- We need to do one time initialization
      R, LastRunTime = Init(scheduledHour, func)
   end
   ScheduledRunTime = ScheduledRunTimes[tostring(func)..' + Time: '..tostring(scheduledHour)]
   local WouldRun = (os.ts.time() > ScheduledRunTime and LastRunTime <= ScheduledRunTime)
   trace("Would run = "..tostring(WouldRun))

   trace(os.ts.time(), ScheduledRunTime )
   trace(os.ts.date('%c',os.ts.time()), os.ts.date('%c',ScheduledRunTime ))
   local WouldRun = ( os.ts.time() > ScheduledRunTime )
   trace("Would run = "..tostring(WouldRun))

   if WouldRun then
      iguana.logInfo('Kicking off batch process')
      func(unpack(arg))
      RecordRun(scheduledHour, func)
      return R
   end
   if iguana.isTest() then
      func(unpack(arg))
      return R
   end

   return R
end

-- the "..." syntax means multiple functions that multiple
-- (optional) parameters can be passed to the function in 
-- a table named "arg" - these are passed to the function
-- by converting them using the "unpack" function
local function runAt2(scheduledHour, scheduledEnd, func, period, ...)
	-- manually allow for optional "scheduledEnd"
   if not func then
      func = scheduledEnd
      scheduledEnd = scheduledHour
   end
   local R
   local LastRunTime = LastRunTimes[tostring(func)..' + Time: '..tostring(scheduledHour)]
   trace(LastRunTime) 
   if LastRunTime == 0 or LastRunTime == nil or iguana.isTest() then
      -- We need to do one time initialization
      R, LastRunTime = Init(scheduledHour, func)
   end
   ScheduledRunTime = ScheduledRunTimes[tostring(func)..' + Time: '..tostring(scheduledHour)]
   local WouldRun = (os.ts.time() > ScheduledRunTime and LastRunTime <= ScheduledRunTime)
   trace("Would run = "..tostring(WouldRun))

   trace(os.ts.time(), ScheduledRunTime )
   trace(os.ts.date('%c',os.ts.time()), os.ts.date('%c',ScheduledRunTime ))
   local WouldRun = ( os.ts.time() > ScheduledRunTime )
   trace("Would run = "..tostring(WouldRun))

   if WouldRun then
      iguana.logInfo('Kicking off batch process')
      func(unpack(arg))
      RecordRun(scheduledHour, func)
      return R
   end
   if iguana.isTest() then
      func(unpack(arg))
      return R
   end

   return R
end

local HELP_DEF={
   SummaryLine = "Run a channel at a scheduled time",
   Desc =[[Runs a channel once at the specified scheduled time (actually runs
it the first time that the scheduled time is exceeded)]],
   Usage = "scheduler.runAt(scheduledHour, ...)",
   ParameterTable=false,
   Parameters ={
      {scheduledHour={Desc='The hour to run the function <u>number</u>.'}}, 
      {func={Desc='The function to call <u>function</u>.'}}, 
      {['...']={Desc='One or more arguments to the function <u>any type</u>.', Opt=true}},
   },
   Returns ={{Desc='Status message indicating schedule time and when/whether the function was run <u>string</u>.'}},
   Title = 'scheduler.runAt',  
   SeeAlso = {{Title='scheduler.lua module on github', Link='https://github.com/interfaceware/iguana-tools/blob/master/Schedule_Channel_Run-From-CLXyvvLL2lpvEB/main.lua'},
      {Title='Schedule Channel Run', Link='http://help.interfaceware.com/v6/scheduler-example'}},
   Examples={'scheduler.runAt(11.5, DoBatchProcess")',
      'scheduler.runAt(11.5, DoBatchProcess, "Some Argument")',
      [[-- Note: runAt can handle (optional) multiple parameters
scheduler.runAt(11.5, DoBatchProcess, 'Some Argument', "Second Argument", "etc...")]],
   }
}
 
help.set{input_function=runAt,help_data=HELP_DEF}

return runAt