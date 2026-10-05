local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true)
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._tape1 = {}
	self._tape2 = {}
	self._glowred = {}
	self._glowblue = {}
	self._vfx = {}
	self._elapsed = 0
	self:_Init()
	return self
end

function object:Update(p)
	self._elapsed += p
	local serverTimeNow = workspace:GetServerTimeNow()

	for _, v in pairs(self._tape1) do
		local v2 = serverTimeNow / 5
		local v3 = v2 % v.StudsPerTileU
		local offsetStudsV = v2 % v.StudsPerTileV
		v.OffsetStudsU = -v3
		v.OffsetStudsV = offsetStudsV
	end

	for _, v in pairs(self._tape2) do
		local v2 = serverTimeNow / 5
		local v3 = v2 % v.StudsPerTileU
		local offsetStudsV = v2 % v.StudsPerTileV
		v.OffsetStudsU = v3 + 0.5
		v.OffsetStudsV = offsetStudsV
	end

	for _, v in pairs(self._vfx) do
		local v2 = self._elapsed % 2

		if v2 > 1 then
			v2 = 2 - v2
		end

		v.Color = ColorSequence.new(Color3.fromRGB(50, 62, 255):Lerp(Color3.fromRGB(255, 47, 47), v2))
	end
end

function object:_Setup()
	for _, effect in pairs(self.ExtraObjects) do
		if effect.Name == "PoliceTape1" then
			table.insert(self._tape1, effect)
		elseif effect.Name == "PoliceTape2" then
			table.insert(self._tape2, effect)
		elseif effect.Name == "GlowRed" then
			table.insert(self._glowred, effect)
		elseif effect.Name == "GlowBlue" then
			table.insert(self._glowblue, effect)
		elseif effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail") then
			table.insert(self._vfx, effect)
		end
	end

	if self.Object:IsA("ParticleEmitter") or self.Object:IsA("Beam") or self.Object:IsA("Trail") then
		table.insert(self._vfx, self.Object)
	end

	self._elapsed = workspace:GetServerTimeNow()

	for _, v in pairs(self._glowred) do
		local tween = TweenService:Create(v, tweenInfo, {
			Color3 = Color3.fromRGB(50, 62, 225)
		})
		tween:Play()
		table.insert(self._tweens, tween)
	end

	for _, v in pairs(self._glowblue) do
		local tween = TweenService:Create(v, tweenInfo, {
			Color3 = Color3.fromRGB(225, 47, 47)
		})
		tween:Play()
		table.insert(self._tweens, tween)
	end
end

function object:_Init()
	self:_Setup()
end

return object