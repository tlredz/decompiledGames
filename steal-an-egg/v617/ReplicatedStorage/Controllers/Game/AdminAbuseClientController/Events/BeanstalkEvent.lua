game:GetService("Debris")
game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
game:GetService("ServerStorage")
game:GetService("Workspace")
local Trove = require(ReplicatedStorage.Packages.Trove)
local v = Trove.new()
local v2 = false
local BeanstalkEvent = {}

function BeanstalkEvent.StartEvent(_, _: number)
	v:Clean()
	v2 = true
end

function BeanstalkEvent.StopEvent(_)
	v:Clean()
	v2 = false
end

return BeanstalkEvent