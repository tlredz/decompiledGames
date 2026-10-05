local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local SkinHologram = require(Players.LocalPlayer.PlayerScripts.Modules.SkinHologram)
local LobbyElement = require(Players.LocalPlayer.PlayerScripts.Modules.LobbyElement)
local object = setmetatable({}, LobbyElement)
object.__index = object

function object._new(...)
	local self = setmetatable(LobbyElement.new(...), object)
	self.Holograms = {}
	self:_Init()
	return self
end

function object:Update(p2)
	for _, hologram in pairs(self.Holograms) do
		hologram:Update(p2)
	end
end

function object:_ObjectAdded(p2)
	local v = SkinHologram.new(p2)
	table.insert(self.Holograms, v)
end

function object:_Init()
	CollectionService:GetInstanceAddedSignal("LobbyDailyShopSkinHologram"):Connect(function(p)
		self:_ObjectAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("LobbyDailyShopSkinHologram")) do
		task.defer(self._ObjectAdded, self, v)
	end
end

return object._new()