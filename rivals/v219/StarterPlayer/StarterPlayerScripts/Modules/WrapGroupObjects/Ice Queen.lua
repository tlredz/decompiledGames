local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local v = {
	"rbxassetid://138393431257124",
	"rbxassetid://107051054528784",
	"rbxassetid://125054446055112",
	"rbxassetid://110582063087757",
	"rbxassetid://119507229017142",
	"rbxassetid://97696327350095",
	"rbxassetid://108305398626234",
	"rbxassetid://107586098443052",
	"rbxassetid://102752148910886",
	"rbxassetid://96190250840477",
	"rbxassetid://83191963862467",
	"rbxassetid://101078325262094"
}
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._arrows1 = {}
	self._arrows2 = {}
	self._snowflakes = {}
	self._frame = 0
	self._next_update = 0
	self:_Init()
	return self
end

function object:Update(_)
	local serverTimeNow = workspace:GetServerTimeNow()

	for _, v2 in pairs(self._arrows1) do
		v2.OffsetStudsU = -(serverTimeNow * 2 % v2.StudsPerTileU)
	end

	for _, v2 in pairs(self._arrows2) do
		v2.OffsetStudsU = serverTimeNow * 2 % v2.StudsPerTileU
	end

	if tick() < self._next_update then
		return
	end

	self._next_update = tick() + 0.03
	self._frame = self._frame % #v + 1

	for _, _snowflake in pairs(self._snowflakes) do
		_snowflake.Texture = v[self._frame]
	end
end

function object:_Setup()
	for _, extraObject in pairs(self.ExtraObjects) do
		if extraObject.Name == "TopArrows" then
			table.insert(self._arrows1, extraObject)
		elseif extraObject.Name == "BottomArrows" then
			table.insert(self._arrows2, extraObject)
		elseif extraObject.Name == "Snowflake" then
			table.insert(self._snowflakes, extraObject)
		end
	end
end

function object:_Init()
	self:_Setup()
end

return object