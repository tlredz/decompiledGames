local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GamepadService = game:GetService("GamepadService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local InputLibrary = require(ReplicatedStorage.Modules.InputLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local userInterface = Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface")
local mainGui = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("MainGui")
local v = {
	"Shutdown",
	"PurchasePrompt",
	"MobileInputs",
	"Inset",
	"SwitchCameraPOV",
	"Pages",
	"Panels",
	"Equipment",
	"Queue",
	"EliminatedEffect",
	"Spectate",
	"HUD",
	"Lobby",
	"Notifications",
	"SideTasks",
	"Teleporting",
	"PlayerList",
	"MatchmakingCountdown",
	"Spotlight",
	"JoystickModal",
	"SideParty",
	"BossHealth",
	"MainGlowyBackground",
	"WarningMessages"
}
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.ElementsLoaded = Signal.new()
	self.PageSystemPagesActivity = Signal.new()
	self.EquipmentOpened = Signal.new()
	self.MainGui = mainGui
	self._are_elements_loaded = false
	self._elements = {}
	self._selected_object_connections = {}
	self._gamepad_connections = {}
	self:_Init()
	return self
end

function class:GetDefaultElement()
	return self._elements.Pages and self._elements.Pages:GetDefaultElement() or nil
end

function class:IsPageOpen(value)
	local _element = self._elements[value or "Pages"]
	return _element and _element.PageSystem and _element.PageSystem.CurrentPage
end

function class:IsEquipmentOpen()
	return self._elements.Equipment and self._elements.Equipment.IsOpen
end

function class:GetPage(...)
	return self._elements.Pages and self._elements.Pages.PageSystem:GetPage(...)
end

function class:OpenPage(...)
	return self._elements.Pages and self._elements.Pages.PageSystem:OpenPage(...)
end

function class:WaitUntilLoaded()
	if not self._are_elements_loaded then
		self.ElementsLoaded:Wait()
	end
end

function class:CloseRequest()
	local isPageOpen = self:IsPageOpen()

	if isPageOpen then
		if not isPageOpen.CantBeClosedFromInputs then
			self._elements.Pages:CloseRequest()
		end
	else
		if self:IsEquipmentOpen() then
			self._elements.Equipment:CloseRequest()
			return
		end

		local _GetSpectatedDuelInterface = self:_GetSpectatedDuelInterface()

		if not (_GetSpectatedDuelInterface and (_GetSpectatedDuelInterface.FinalResults.Buttons.LeaveFrame.Visible or _GetSpectatedDuelInterface.FinalResults.Buttons.ContinueFrame.Visible)) then
			return
		end

		if _GetSpectatedDuelInterface.FinalResults.Buttons.ContinueFrame.Visible then
			_GetSpectatedDuelInterface.FinalResults.Buttons:Continue()
		else
			_GetSpectatedDuelInterface.FinalResults.Buttons:LeaveRequest()
		end
	end
end

function class:PrimaryAction()
	if self._elements.Lobby and self._elements.Lobby.Play and self._elements.Lobby.Play.IsPlayVisible and Utility:IsUIElementVisible(self._elements.Lobby.Play.PlayButton) then
		self._elements.Lobby.Play:OpenPlayPage()
		return
	end

	local _GetSpectatedDuelInterface = self:_GetSpectatedDuelInterface()

	if _GetSpectatedDuelInterface and _GetSpectatedDuelInterface.FinalResults.Buttons.PlayAgainFrame.Visible then
		_GetSpectatedDuelInterface.FinalResults.Buttons:PlayAgain()
	end
end

function class:SecondaryAction()
	if not self._elements.Pages then
		return
	end

	local _GetSpectatedDuelInterface = self:_GetSpectatedDuelInterface()

	if _GetSpectatedDuelInterface then
		if _GetSpectatedDuelInterface.FinalResults.Buttons.RematchFrame.Visible then
			_GetSpectatedDuelInterface.FinalResults.Buttons:Rematch()
		end
	else
		local _GetSpectatedSubject = self:_GetSpectatedSubject()
		local isInShootingRange = _GetSpectatedSubject and (_GetSpectatedSubject:Get("IsInShootingRange") or _GetSpectatedSubject:Get("IsInDuel"))
		local isPageOpen = self:IsPageOpen()

		if not (isPageOpen or isInShootingRange) or isPageOpen and isPageOpen.Name ~= "Party" then
			local isVisible = self._elements.Lobby and self._elements.Lobby.Party and self._elements.Lobby.Party.IsVisible
			local isVisible2 = self._elements.SideParty and self._elements.SideParty.IsVisible

			if isVisible or isVisible2 then
				self._elements.Pages.PageSystem:OpenPage("Party", true)
			end
		end
	end
end

function class:TertiaryAction()
	if self._elements.Lobby and self._elements.Lobby.Play and self._elements.Lobby.Play.IsHubVisible and Utility:IsUIElementVisible(self._elements.Lobby.Play.HubButton) then
		self._elements.Lobby.Play:GoBackToHub()
	end
end

function class:QuaternaryAction()
	if self._elements.Lobby and self._elements.Lobby.Play and self._elements.Lobby.Play.IsRematchVisible and Utility:IsUIElementVisible(self._elements.Lobby.Play.RematchButton) then
		self._elements.Lobby.Play:RematchRequest()
	end
end

function class:_GetSpectatedSubject()
	local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
	return SpectateController.CurrentSubject
end

function class:_GetSpectatedDuelInterface()
	local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
	return SpectateController.CurrentDuelSubject and SpectateController.CurrentDuelSubject.DuelInterface
end

function class:_CheckSelectedObjectVisible()
	if GuiService.SelectedObject and not Utility:IsUIElementVisible(GuiService.SelectedObject) then
		GamepadService:DisableGamepadCursor()
	end
end

function class:_UpdateSelectedObject()
	if not Players.LocalPlayer:FindFirstChild("PlayerGui") then
		return
	end

	if GuiService.SelectedObject then
		for _, _selected_object_connection in pairs(self._selected_object_connections) do
			_selected_object_connection:Disconnect()
		end

		self._selected_object_connections = {}
		table.insert(self._selected_object_connections, GuiService.SelectedObject.AncestryChanged:Connect(function()
			self:_CheckSelectedObjectVisible()
		end))
		table.insert(
			self._selected_object_connections,
			GuiService.SelectedObject:GetPropertyChangedSignal("Visible"):Connect(function()
				self:_CheckSelectedObjectVisible()
			end)
		)
		self:_CheckSelectedObjectVisible()
	else
		local defaultElement = self:GetDefaultElement()
		local selectedObject

		if defaultElement and defaultElement:IsDescendantOf(Players.LocalPlayer.PlayerGui) and defaultElement then
			selectedObject = defaultElement
		end

		if defaultElement then
			GamepadService:EnableGamepadCursor(selectedObject)
			GuiService.SelectedObject = selectedObject
		else
			GamepadService:DisableGamepadCursor()
			GuiService.SelectedObject = nil
		end
	end
end

function class:_UpdateGamepadControls()
	for _, _gamepad_connection in pairs(self._gamepad_connections) do
		_gamepad_connection:Disconnect()
	end

	for _, _selected_object_connection in pairs(self._selected_object_connections) do
		_selected_object_connection:Disconnect()
	end

	self._gamepad_connections = {}
	self._selected_object_connections = {}

	if ControlsController.CurrentControls == "Gamepad" then
	end
end

function class:_Setup()
	task.defer(function()
		for _, childName in pairs(v) do
			local _elements = self._elements
			local module = require(userInterface:WaitForChild(childName))
			_elements[childName] = module
		end

		self._elements.Pages.PageSystem.PagesActivity:Connect(function(...)
			self.PageSystemPagesActivity:Fire(...)
		end)
		self._elements.Equipment.Opened:Connect(function(...)
			self.EquipmentOpened:Fire(...)
		end)
		self._are_elements_loaded = true
		self.ElementsLoaded:Fire()
	end)
	self.MainGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

function class:_Init()
	ControlsController.ControlsChanged:Connect(function()
		self:_UpdateGamepadControls()
	end)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if InputLibrary:InputIs(input, "UICancelAction") then
			self:CloseRequest()
		elseif InputLibrary:InputIs(input, "UIPrimaryAction") then
			self:PrimaryAction()
		elseif InputLibrary:InputIs(input, "UISecondaryAction") then
			self:SecondaryAction()
		elseif InputLibrary:InputIs(input, "UITertiaryAction") then
			self:TertiaryAction()
		elseif InputLibrary:InputIs(input, "UIQuaternaryAction") then
			self:QuaternaryAction()
		end
	end)
	self:_Setup()
	self:_UpdateGamepadControls()
end

return class._new()