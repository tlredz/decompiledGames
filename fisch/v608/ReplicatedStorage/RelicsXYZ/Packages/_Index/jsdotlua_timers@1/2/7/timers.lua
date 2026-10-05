local collections = require(script.Parent:WaitForChild("collections"))
local object = collections.Object
local makeTimerImpl = require(script:WaitForChild("makeTimerImpl"))
local makeIntervalImpl = require(script:WaitForChild("makeIntervalImpl"))
return object.assign({}, makeTimerImpl(task.delay), makeIntervalImpl(task.delay))