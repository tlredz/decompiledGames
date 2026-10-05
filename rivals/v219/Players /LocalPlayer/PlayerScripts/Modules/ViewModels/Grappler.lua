local Players = game:GetService("Players")
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self:_Init()
	return self
end

function object.HideHookSubModel(object2, p)
	object2:HideSubModel("Hook", p)
end

function object.PlayShootSounds(object2)
	object2:CreateSound("rbxassetid://92178332551602", 1, 0.9 + 0.2 * math.random(), true, 5)
end

function object.PlayPullSounds(object2)
	object2:CreateSound("rbxassetid://105623111691289", 1.25, 0.9 + 0.2 * math.random(), true, 5)
end

function object:_Init() end

return object