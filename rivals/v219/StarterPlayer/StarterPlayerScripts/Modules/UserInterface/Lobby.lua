local Players = game:GetService("Players")
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SpectateController"))
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.Frame = UILibrary:GetTo("MainFrame", "Lobby")
	self.Play = require(script:WaitForChild("Play"))
	self.Party = require(script:WaitForChild("Party"))
	self.Buttons = require(script:WaitForChild("Buttons"))
	self.Currency = require(script:WaitForChild("Currency"))
	self.Requests = require(script:WaitForChild("Requests"))
	self.Matchmaking = require(script:WaitForChild("Matchmaking"))
	self.LocalFighter = nil
	self._duel_connections = {}
	self:_Init()
	return self
end

function class:_UpdateVisibility()
	local visible = self.LocalFighter and not self.LocalFighter:Get("IsInShootingRange") and not (self.LocalFighter:Get("IsInDuel") or SpectateController.CurrentDuelSubject)
	self.Play.Frame.Visible = visible
	self.Buttons.Frame.Visible = visible
	self.Currency.Frame.Visible = visible
	self.Requests.Frame.Visible = visible
	self.Party.BottomDisplayFrame.Visible = visible
end

function class:_UpdateCurrentDuelSubject()
	for _, _duel_connection in pairs(self._duel_connections) do
		_duel_connection:Disconnect()
	end

	self._duel_connections = {}

	if SpectateController.CurrentDuelSubject then
	end

	self:_UpdateVisibility()
end

function class:_HookLocalFighter()
	self.LocalFighter = FighterController:WaitForLocalFighter()
	self.LocalFighter:GetDataChangedSignal("IsInDuel"):Connect(function()
		self:_UpdateVisibility()
	end)
	self.LocalFighter:GetDataChangedSignal("IsInShootingRange"):Connect(function()
		self:_UpdateVisibility()
	end)
	self:_UpdateVisibility()
end

function class:_Init()
	SpectateController.DuelSubjectChanged:Connect(function()
		self:_UpdateCurrentDuelSubject()
	end)
	self:_UpdateVisibility()
	self:_UpdateCurrentDuelSubject()
	task.spawn(self._HookLocalFighter, self)
end

return class._new()