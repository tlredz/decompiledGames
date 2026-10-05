local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local color = Color3.fromRGB(134, 255, 180)
local color2 = Color3.fromRGB(89, 171, 123)
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._started = 0
	self._lightnings = {}
	self._fade_parts = {}
	self._gradient = {}
	self._gradient_2 = {}
	self._next_strike = 0
	self:_Init()
	return self
end

function object:Update(p)
	self._started += p
	local _started = self._started

	for _, v in self._gradient do
		local offsetStudsU = _started / 2.25 % v.StudsPerTileU

		if v.Face == Enum.NormalId.Top or v.Face == Enum.NormalId.Front then
			offsetStudsU = -offsetStudsU
		end

		v.OffsetStudsU = offsetStudsU
	end

	for _, v in self._gradient_2 do
		local offsetStudsU = -(_started / 2.25) % v.StudsPerTileU

		if v.Face == Enum.NormalId.Top or v.Face == Enum.NormalId.Front then
			offsetStudsU = -offsetStudsU
		end

		v.OffsetStudsU = offsetStudsU
	end

	if _started < self._next_strike then
		return
	end

	self._next_strike = _started + Random.new():NextNumber(0.6, 1.7)

	for _, _lightning in self._lightnings do
		_lightning.Transparency = 0.01
		local tween = TweenService:Create(_lightning, tweenInfo, {
			Transparency = 1
		})
		tween:Play()
		table.insert(self._tweens, tween)
	end

	for _, _fade_part in self._fade_parts do
		_fade_part.Color = color
		local tween = TweenService:Create(_fade_part, tweenInfo, {
			Color = color2
		})
		tween:Play()
		table.insert(self._tweens, tween)
	end
end

function object:_Setup()
	if self.Object:IsA("BasePart") and self.Object:FindFirstChild("Lightning") and self.Object:FindFirstChild("Gradient2") then
		table.insert(self._fade_parts, self.Object)
	end

	for _, texture in pairs(self.ExtraObjects) do
		if texture.Name == "Lightning" then
			table.insert(self._lightnings, texture)
		elseif texture:IsA("Texture") and texture.Name == "Gradient" then
			table.insert(self._gradient, texture)
		elseif texture:IsA("Texture") and texture.Name == "Gradient2" then
			table.insert(self._gradient_2, texture)
		end
	end
end

function object:_Init()
	self:_Setup()
end

return object