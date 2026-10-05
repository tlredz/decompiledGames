local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local LeaderboardDisplay = require(Players.LocalPlayer.PlayerScripts.Modules.LeaderboardDisplay)
local LobbyElement = require(Players.LocalPlayer.PlayerScripts.Modules.LobbyElement)
local object = setmetatable({}, LobbyElement)
object.__index = object

function object._new(...)
	local self = setmetatable(LobbyElement.new(...), object)
	self.Displays = {}
	self:_Init()
	return self
end

function object:_DisplayAdded(p2)
	local v = LeaderboardDisplay.new(p2)
	table.insert(self.Displays, v)
end

function object:_Init()
	CollectionService:GetInstanceAddedSignal("LeaderboardDisplay"):Connect(function(p)
		self:_DisplayAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("LeaderboardDisplay")) do
		task.defer(self._DisplayAdded, self, v)
	end
end

return object._new()