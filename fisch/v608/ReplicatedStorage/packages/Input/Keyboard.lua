local Trove = require(script.Parent.Parent.Trove)
local Signal = require(script.Parent.Parent.Signal)
local UserInputService = game:GetService("UserInputService")
local Keyboard = {}
Keyboard.__index = Keyboard

function Keyboard.new(flag: boolean?)
	local self = setmetatable({}, Keyboard)
	self._trove = Trove.new()
	self.IgnoreProcessed = flag == true
	self.KeyDown = self._trove:Construct(Signal)
	self.KeyUp = self._trove:Construct(Signal)
	self:_setup()
	return self
end

function Keyboard:IsKeyDown(p)
	return UserInputService:IsKeyDown(p)
end

function Keyboard:AreKeysDown(p, p2)
	return self:IsKeyDown(p) and self:IsKeyDown(p2)
end

function Keyboard:AreEitherKeysDown(p, p2)
	return self:IsKeyDown(p) or self:IsKeyDown(p2)
end

function Keyboard:_setup()
	self._trove:Connect(UserInputService.InputBegan, function(p, p2)
		if p2 and not self.IgnoreProcessed then
			return
		end

		if p.UserInputType == Enum.UserInputType.Keyboard then
			self.KeyDown:Fire(p.KeyCode)
		end
	end)
	self._trove:Connect(UserInputService.InputEnded, function(p, p2)
		if p2 and not self.IgnoreProcessed then
			return
		end

		if p.UserInputType == Enum.UserInputType.Keyboard then
			self.KeyUp:Fire(p.KeyCode)
		end
	end)
end

function Keyboard:Destroy()
	self._trove:Destroy()
end

return Keyboard