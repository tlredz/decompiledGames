local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("Players")
require3(ReplicatedStorage2.Packages.Signal)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v = nil

local function createMockPage(name: string)
	local frame = Instance.new("Frame")
	frame.Name = name
	return frame
end

local ClanPageTestController = {}

function ClanPageTestController.Init(_)
	v = require3(script.Parent)
end

function ClanPageTestController.Start(_) end

return ClanPageTestController