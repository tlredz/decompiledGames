local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._overlays = {}
	self._overlays2 = {}
	self:_Init()
	return self
end

function object:Update(_)
	local serverTimeNow = workspace:GetServerTimeNow()

	for _, _overlay in pairs(self._overlays) do
		local v = serverTimeNow / 15
		local offsetStudsU = v % _overlay.StudsPerTileU
		local offsetStudsV = v % _overlay.StudsPerTileV
		_overlay.OffsetStudsU = offsetStudsU
		_overlay.OffsetStudsV = offsetStudsV
		_overlay.Transparency = math.sin(serverTimeNow * 1.25) / 7 + 0.25
	end

	for _, v in pairs(self._overlays2) do
		local v2 = (math.sin(serverTimeNow / 2.5) / 1.2 + 2) / 6 + 2
		v.StudsPerTileU = v2
		v.StudsPerTileV = v2
	end
end

function object:_Setup()
	for _, extraObject in pairs(self.ExtraObjects) do
		if extraObject.Name == "WeirdPaintOverlay" then
			table.insert(self._overlays, extraObject)
		elseif extraObject.Name == "WeirdPaintOverlay2" then
			table.insert(self._overlays2, extraObject)
		end
	end
end

function object:_Init()
	self:_Setup()
end

return object