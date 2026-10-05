local Players = game:GetService("Players")
local Grappler = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Grappler)
local object = setmetatable({}, Grappler)
object.__index = object

function object.new(...)
	local self = setmetatable(Grappler.new(...), object)
	self._line_rope = self.ItemModel:WaitForChild("Body"):WaitForChild("Grey"):WaitForChild("Attachment"):WaitForChild("RopeConstraint")
	self:_Init()
	return self
end

function object.PlayShootSounds(object2)
	object2:CreateSound("rbxassetid://71757681243259", 1.5, 0.9 + 0.2 * math.random(), true, 5)
end

function object.PlayPullSounds(object2)
	object2:CreateSound("rbxassetid://133299501943334", 1.5, 0.9 + 0.2 * math.random(), true, 5)
end

function object:_UpdateLine()
	self._line_rope.Enabled = not self.ClientItem:Get("GrapplingHookPartActive")
end

function object:_Init()
	self.ClientItem:GetDataChangedSignal("GrapplingHookPartActive"):Connect(function()
		self:_UpdateLine()
	end)
	self:_UpdateLine()
end

return object