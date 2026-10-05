local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local LeaderboardController = require(Players.LocalPlayer.PlayerScripts.Controllers.LeaderboardController)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local MobileInputs = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.MobileInputs)
local Teleporting = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Teleporting)
local Shutdown = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Shutdown)
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Pages)
local Nametag = require(Players.LocalPlayer.PlayerScripts.Modules.Nametag)
local CustomNametag = {}
CustomNametag.__index = CustomNametag

function CustomNametag.new(clientFighterCharacter)
	local self = setmetatable({}, CustomNametag)
	self.ClientFighterCharacter = clientFighterCharacter
	self._destroyed = false
	self._nametag = nil
	self:_Init()
	return self
end

function CustomNametag.Update(_, _, _) end

function CustomNametag:Destroy()
	self._destroyed = true

	if self._nametag then
		self._nametag:Destroy()
	end
end

function CustomNametag:_Refresh()
	if self._nametag then
		self._nametag:Destroy()
		self._nametag = nil
	end

	if Pages.PageSystem.CurrentPage or MobileInputs.EditorEnabled or Teleporting.Enabled or Shutdown.Enabled or GuiService.MenuIsOpen or PlayerDataController:GetSetting("Hide HUD") then
		return
	end

	if self._destroyed or not self.ClientFighterCharacter:IsInWorld() or self.ClientFighterCharacter.ClientFighter:IsActuallyFirstPerson() or self.ClientFighterCharacter.ClientFighter:Get("IsInDuel") then
		return
	end

	self._nametag = Nametag.new(
		self.ClientFighterCharacter.Player,
		self.ClientFighterCharacter.ClientFighter:Get("Controls"),
		self.ClientFighterCharacter.ClientFighter.Player:GetAttribute("StatisticDuelsWinStreak"),
		self.ClientFighterCharacter.ClientFighter.Player:GetAttribute("Level"),
		self.ClientFighterCharacter.ClientFighter.Player:GetAttribute("DisplayELO"),
		self.ClientFighterCharacter.ClientFighter.Player:GetAttribute("PlayerStatus"),
		self.ClientFighterCharacter.ClientFighter:Get("IsMatchmaking")
	)
	self._nametag:SetParent(self.ClientFighterCharacter.RootPart)
end

function CustomNametag:_Init()
	self.ClientFighterCharacter.EnteredWorld:Connect(function()
		self:_Refresh()
	end)
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter:GetDataChangedSignal("IsSpectating"):Connect(function()
		self:_Refresh()
	end))
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter:GetDataChangedSignal("IsInDuel"):Connect(function()
		self:_Refresh()
	end))
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter:GetDataChangedSignal("Controls"):Connect(function()
		self:_Refresh()
	end))
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter:GetDataChangedSignal("IsInDuel"):Connect(function()
		self:_Refresh()
	end))
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter:GetDataChangedSignal("IsMatchmaking"):Connect(function()
		self:_Refresh()
	end))
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter.Player:GetAttributeChangedSignal("StatisticDuelsWinStreak"):Connect(function()
		self:_Refresh()
	end))
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter.Player:GetAttributeChangedSignal("Level"):Connect(function()
		self:_Refresh()
	end))
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter.Player:GetAttributeChangedSignal("DisplayELO"):Connect(function()
		self:_Refresh()
	end))
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter.Player:GetAttributeChangedSignal("PlayerStatus"):Connect(function()
		self:_Refresh()
	end))
	self.ClientFighterCharacter:AddConnection(PlayerDataController:GetSettingChangedSignal("Hide HUD"):Connect(function()
		self:_Refresh()
	end))
	self.ClientFighterCharacter:AddConnection(PlayerDataController:GetSettingChangedSignal("PlayerList Leaderstat"):Connect(function()
		self:_Refresh()
	end))
	self.ClientFighterCharacter:AddConnection(LeaderboardController:GetLeaderboardRefreshedSignal("Highest ELO"):Connect(function()
		self:_Refresh()
	end))
	self.ClientFighterCharacter:AddConnection(CameraController.StateChanged:Connect(function()
		self:_Refresh()
	end))
	self.ClientFighterCharacter:AddConnection(Pages.PageSystem.PagesActivity:Connect(function()
		self:_Refresh()
	end))
	self.ClientFighterCharacter:AddConnection(MobileInputs.EditorEnabledChanged:Connect(function()
		self:_Refresh()
	end))
	self.ClientFighterCharacter:AddConnection(Teleporting.EnabledChanged:Connect(function()
		self:_Refresh()
	end))
	self.ClientFighterCharacter:AddConnection(Shutdown.EnabledChanged:Connect(function()
		self:_Refresh()
	end))
	self.ClientFighterCharacter:AddConnection(GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
		self:_Refresh()
	end))
	self:_Refresh()
end

return CustomNametag