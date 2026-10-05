game:GetService("TweenService")
local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._gradient1 = {}
	self._gradient2 = {}
	self._solid = {}
	self._vfx = {}
	self:_Init()
	return self
end

function object:Update(_)
	local v = workspace:GetServerTimeNow() / 2
	local v2 = v / 4
	local v3 = (v2 - 0.1) % 1
	local v4 = (v2 + 0.1) % 1

	for _, v5 in pairs(self._gradient1) do
		v5.OffsetStudsU = v % v5.StudsPerTileU
	end

	for _, v5 in pairs(self._gradient2) do
		v5.OffsetStudsU = -(v % v5.StudsPerTileU)
	end

	for _, v5 in pairs(self._solid) do
		local color = Color3.fromHSV((v2 + v5:GetAttribute("Offset")) % 1, 1, 1)
		v5.Color3 = Color3.fromRGB(
			color.R * 255 * 1.5686274509803921,
			color.G * 255 * 1.5686274509803921,
			color.B * 255 * 1.5686274509803921
		)
	end

	for _, v5 in pairs(self._vfx) do
		v5.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(v3, 1, 1)),
			(ColorSequenceKeypoint.new(1, Color3.fromHSV(v4, 1, 1)))
		})
	end
end

function object:_GetOffset(p)
	local size = p.Parent.Size
	return (Vector3.FromNormalId(p.Face) * size).Magnitude / 4 / 2
end

function object:_Setup()
	for _, extraObject in pairs(self.ExtraObjects) do
		if extraObject.Name == "Gradient1" then
			table.insert(self._gradient1, extraObject)
		elseif extraObject.Name == "Gradient2" then
			table.insert(self._gradient2, extraObject)
		elseif extraObject.Name == "SolidBack" or extraObject.Name == "SolidFront" then
			extraObject:SetAttribute("Offset", self:_GetOffset(extraObject))
			table.insert(self._solid, extraObject)
		end
	end

	if self.Object:IsA("ParticleEmitter") or self.Object:IsA("Beam") or self.Object:IsA("Trail") then
		table.insert(self._vfx, self.Object)
	end
end

function object:_Init()
	self:_Setup()
end

return object