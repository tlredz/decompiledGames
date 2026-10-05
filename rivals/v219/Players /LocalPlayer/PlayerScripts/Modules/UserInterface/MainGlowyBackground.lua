local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SpectateController"))
local MobileInputs = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("MobileInputs"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Pages"))
local GlowyBackground = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("GlowyBackground"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.Frame = UILibrary:GetTo("MainFrame", "MainGlowyBackground")
	self._glowy_background = GlowyBackground.new("MainGui")
	self._current_duel_subject = nil
	self._current_duel_subject_connections = {}
	self:_Init()
	return self
end

function class:_Update()
	local v = self._current_duel_subject and self._current_duel_subject.DuelInterface and self._current_duel_subject.DuelInterface.Voting:IsOpen()
	self._glowy_background:SetBackdropTransparency(v and 0 or 1)
	self._glowy_background:DisableElement("Black", MobileInputs.EditorEnabled)
	self._glowy_background:SetEnabled(Pages.PageSystem.CurrentPage or MobileInputs.EditorEnabled or GuiService.MenuIsOpen or v)
	self._glowy_background:SetBlurEnabled(not GuiService.MenuIsOpen)
end

function class:_UpdateClientDuelSubject()
	for _, _current_duel_subject_connection in pairs(self._current_duel_subject_connections) do
		_current_duel_subject_connection:Disconnect()
	end

	self._current_duel_subject_connections = {}
	self._current_duel_subject = nil

	if not SpectateController.CurrentDuelSubject then
		self:_Update()
		return
	end

	self._current_duel_subject = SpectateController.CurrentDuelSubject
	table.insert(
		self._current_duel_subject_connections,
		self._current_duel_subject.DuelInterface.Voting.VisibilityChanged:Connect(function()
			self:_Update()
		end)
	)
	self:_Update()
end

function class:_Setup()
	self._glowy_background:SetParent(self.Frame)
end

function class:_Init()
	Pages.PageSystem.PagesActivity:Connect(function()
		self:_Update()
	end)
	MobileInputs.EditorEnabledChanged:Connect(function()
		self:_Update()
	end)
	GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
		self:_Update()
	end)
	SpectateController.DuelSubjectChanged:Connect(function()
		self:_UpdateClientDuelSubject()
	end)
	self:_Setup()
	task.defer(self._Update, self)
	task.defer(self._UpdateClientDuelSubject, self)
end

return class._new()