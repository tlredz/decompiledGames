local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Emote = require(ReplicatedStorage.Modules.Emote)
Color3.fromRGB(20, 82, 214)
Color3.fromRGB(202, 42, 42)
local object = setmetatable({}, Emote)
object.__index = object

function object.new(...)
	local self = setmetatable(Emote.new(nil, script.Name, ...), object)
	self:_Init()
	return self
end

function object:PlayClient(...)
	Emote.PlayClient(self, ...)
	local _SetupMultipleProps = self:_SetupMultipleProps(script.CarProp)
	self:_PlayAnimation("rbxassetid://131715664984592", "rbxassetid://121062198562083", 3.15)
	local createSound = self:CreateSound("rbxassetid://139395743852964", 1, 1, nil, true)
	createSound.Looped = true
	local createSound_2 = self:CreateSound("rbxassetid://77259408745181", 0.75, 1, nil, true)
	createSound_2.Looped = true
	local _ = _SetupMultipleProps.Base.Frame.vfx
	local _ = _SetupMultipleProps.Base.RedLights
	local _ = _SetupMultipleProps.Base.BlueLights
	local _ = tick() + 4

	for i = 1, 1e999 do
		if self._destroyed then
			break
		end

		local _ = i % 2 == 1
		wait(0.5)
	end
end

function object:_Init() end

return object