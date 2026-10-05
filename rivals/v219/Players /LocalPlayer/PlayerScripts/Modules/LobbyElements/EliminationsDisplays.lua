game:GetService("CollectionService")
local Players = game:GetService("Players")
require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local EliminationsDisplay = require(Players.LocalPlayer.PlayerScripts.Modules.EliminationsDisplay)
local LobbyElement = require(Players.LocalPlayer.PlayerScripts.Modules.LobbyElement)
local object = setmetatable({}, LobbyElement)
object.__index = object

function object._new(...)
	local self = setmetatable(LobbyElement.new(...), object)
	self.Displays = {}
	self:_Init()
	return self
end

function object._DisplayAdded(p, p2)
	table.insert(p.Displays, EliminationsDisplay.new(p2))
end

function object._ClientFighterAdded(p, p2)
	p2.Elimination:Connect(function(...)
		for _, display in pairs(p.Displays) do
			display:NewElimination(...)
		end
	end)
end

function object:_Init() end

return object._new()