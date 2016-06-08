-- This example shows how to schedule multiple times
-- and/or multiple tasks

-- http://help.interfaceware.com/v6/scheduler-example

local scheduler = {}
scheduler.runAt = require 'scheduler'
 
local function DoBatchProcess1(Data, Desc, Comment)
   iguana.logInfo('Processed a big batch of data!')
end
 
local function DoBatchProcess2(Data, Desc, Comment)
   iguana.logInfo('Processed another big batch of data!')
end

local function DoBatchProcess3(Data, Desc, Comment)
   iguana.logInfo('Processed yet another big batch of data!')
end
 
local function Schedule()

   -- schedule the same task at several different times
   scheduler.runAt(01.1, DoBatchProcess1)   
   scheduler.runAt(06.5, DoBatchProcess1)   
   scheduler.runAt(11.0, DoBatchProcess1)   
   scheduler.runAt(21.5, DoBatchProcess1)   
   scheduler.runAt(22.0, DoBatchProcess1)   
   scheduler.runAt(23.5, DoBatchProcess1)   
   scheduler.runAt(15.25, DoBatchProcess1)   
   scheduler.runAt(15.29, DoBatchProcess1)   
   
   -- schedule several different tasks
   scheduler.runAt(11.5, DoBatchProcess1)   
   scheduler.runAt(20.24, DoBatchProcess2)   
   scheduler.runAt(20.27, DoBatchProcess2)   
   scheduler.runAt(11.5, DoBatchProcess3)   
   scheduler.runAt(21.5, DoBatchProcess1)   
   scheduler.runAt(21.5, DoBatchProcess2)   
   scheduler.runAt(21.5, DoBatchProcess3)         
end

return Schedule