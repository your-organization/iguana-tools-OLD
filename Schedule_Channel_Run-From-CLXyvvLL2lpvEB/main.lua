-- This scheduler script can be used to run a script at a given time

-- http://help.interfaceware.com/v6/scheduler-example

local store = require 'store2'


local scheduler = {}
scheduler.runAt = require 'scheduler'

local schedule = require 'complexSchedule'
 
-- Within the editor we run the function all the time.
local function DoBatchProcess(Data, Desc, Comment)
   iguana.logInfo('Processed a big batch of data!')
end
 
function main()
   -- The first time the scheduled time is exceeded the function is run
   -- this means the function will run once at (just after) the scheduled time
   scheduler.runAt(11.5, DoBatchProcess)   
   scheduler.runAt(11.5, DoBatchProcess, "Some Argument")   
   
   -- Note: runAt can handle (optional) multiple parameters
   scheduler.runAt(11.5, DoBatchProcess, "Some Argument", "Second Argument", "etc...") 
   
   -- You can schedule multiple times and/or tasks by using multiple runAt() calls
   -- see the example in the local module "complexSchedule.lua"
   schedule()
end