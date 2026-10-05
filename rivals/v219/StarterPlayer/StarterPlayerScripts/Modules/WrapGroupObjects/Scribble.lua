local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local v = { "rbxassetid://112448109089773", "rbxassetid://85215887790060" }
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._textures1 = {}
	self._textures2 = {}
	self._texture_index = 0
	self._next_tick = 0
	self:_Init()
	return self
end

function object:Update(_)
	local serverTimeNow = workspace:GetServerTimeNow()

	if serverTimeNow < self._next_tick then
		return
	end

	self._next_tick = serverTimeNow + 0.15
	self._texture_index += 1
	local v2 = self._texture_index % 2 + 1
	local v3 = 3 - v2

	for _, v4 in pairs(self._textures1) do
		v4.Texture = v[v2]
	end

	for _, v4 in pairs(self._textures2) do
		v4.Texture = v[v3]
	end
end

function object:_Setup()
	for _, extraObject in pairs(self.ExtraObjects) do
		if extraObject.Name == "Scribbles" then
			table.insert(self._textures1, extraObject)
		elseif extraObject.Name == "Scribbles2" then
			table.insert(self._textures2, extraObject)
		end
	end
end

function object:_Init()
	self:_Setup()
end

return object