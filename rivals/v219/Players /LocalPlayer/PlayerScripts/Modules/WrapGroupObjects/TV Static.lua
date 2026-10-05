game:GetService("TweenService")
local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local v = { "rbxassetid://76762297951095", "rbxassetid://104650396345178", "rbxassetid://128067608046117" }
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._static = {}
	self._static_dark = {}
	self._elapsed = 0
	self._last_texture = 1
	self:_Init()
	return self
end

function object:Update(p)
	self._elapsed += p
	local transparency = math.sin(workspace:GetServerTimeNow() * 10) / 10 + 0.1
	local texture = v[self._last_texture]

	if self._elapsed >= 0.04 then
		self._elapsed = 0
		local v4 = self._last_texture + 1
		local last_texture = #v < v4 and 1 or v4
		texture = v[last_texture]
		self._last_texture = last_texture
	end

	for _, v4 in pairs(self._static) do
		v4.OffsetStudsU = Random.new():NextInteger(-1, 1) / 250
		v4.OffsetStudsV = Random.new():NextInteger(-1, 1) / 250
		v4.Texture = texture
		v4.Transparency = transparency
	end

	for _, v4 in pairs(self._static_dark) do
		v4.OffsetStudsU = Random.new():NextInteger(-1, 1) / 250
		v4.OffsetStudsV = Random.new():NextInteger(-1, 1) / 250
		v4.Texture = texture
		v4.Transparency = transparency / 1.25 + 0.35
	end
end

function object:_Setup()
	for _, extraObject in pairs(self.ExtraObjects) do
		if extraObject.Name == "Static" then
			table.insert(self._static, extraObject)
		elseif extraObject.Name == "StaticDark" then
			table.insert(self._static_dark, extraObject)
		end
	end
end

function object:_Init()
	self:_Setup()
end

return object