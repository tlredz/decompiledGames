local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local DuelController = require(Players.LocalPlayer.PlayerScripts.Controllers.DuelController)
local DuelsDisplay = require(Players.LocalPlayer.PlayerScripts.Modules.DuelsDisplay)
local LobbyElement = require(Players.LocalPlayer.PlayerScripts.Modules.LobbyElement)
local object = setmetatable({}, LobbyElement)
object.__index = object

function object._new(...)
	local self = setmetatable(LobbyElement.new(...), object)
	self.Displays = {}
	self:_Init()
	return self
end

function object:_UpdateEnabled()
	local v = not DuelController:GetDuel(Players.LocalPlayer)

	for _, display in pairs(self.Displays) do
		display:SetEnabled(v)
	end
end

function object:_DisplayAdded(p, p2)
	table.insert(self.Displays, DuelsDisplay.new(p))

	if not p2 then
		self:_UpdateEnabled()
	end
end

function object:_Init()
	DuelController.LocalPlayerJoinedOrLeftDuel:Connect(function()
		self:_UpdateEnabled()
	end)
	CollectionService:GetInstanceAddedSignal("DuelsDisplay"):Connect(function(p)
		self:_DisplayAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("DuelsDisplay")) do
		self:_DisplayAdded(v, true)
	end

	self:_UpdateEnabled()
end

return object._new()