game:GetService("Debris")
game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
game:GetService("ServerStorage")
game:GetService("Workspace")
local Trove = require(ReplicatedStorage.Packages.Trove)
local v = Trove.new()
local v2 = false
local Template = {}

function Template.StartEvent(_, _: number)
	v:Clean()
	v2 = true
end

function Template.StopEvent(_)
	v:Clean()
	v2 = false
end

return Template