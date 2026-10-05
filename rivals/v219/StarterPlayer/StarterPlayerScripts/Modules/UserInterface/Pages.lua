local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadService = game:GetService("GamepadService")
local GuiService = game:GetService("GuiService")
game:GetService("RunService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
require(ReplicatedStorage.Modules.DebugLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ControlsController"))
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
local DuelController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("DuelController"))
local MobileInputs = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("MobileInputs"))
local Teleporting = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Teleporting"))
local Queue = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Queue"))
local PageSystem = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("PageSystem"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.Frame = UILibrary:GetTo("MainFrame", "Pages")
	self.PageSystem = PageSystem.new(self.Frame)
	self._welcomeback_popped_up = false
	self._patchnotes_popped_up = false
	self._mobileduels_popped_up = false
	self._delay_next_popup = nil
	self:_Init()
	return self
end

function class:GetDefaultElement()
	return self.PageSystem:GetDefaultElement()
end

function class:CloseRequest()
	self.PageSystem:CloseRequest()
end

function class:OpenPickWeaponsPage()
	self.PageSystem:OpenPage(
		PlayerDataController:GetSetting("Pick Weapons List") == "List" and "PickWeaponsList" or "PickWeapons",
		true
	)
end

function class:_UpdateVisibility()
	self.Frame.Visible = not GuiService.MenuIsOpen
end

function class:_CheckInterruption()
	if not self.PageSystem.CurrentPage then
		return
	end

	if Queue:IsVisible() and self.PageSystem.CurrentPage.Name ~= "PickEmote" or Teleporting.Enabled or MobileInputs.EditorEnabled then
		self.PageSystem:CloseCurrentPage()
	end
end

function class:_CheckPopUps()
	if self.PageSystem.CurrentPage then
		return
	end

	wait(1)

	if self._delay_next_popup then
		local _ = self._delay_next_popup
		self._delay_next_popup = nil
		wait(self._delay_next_popup)
	end

	if DuelController:GetDuel(Players.LocalPlayer) then
		return
	end

	local statistic = PlayerDataController:GetStatistic("StatisticDuelsPlayed")

	if self._welcomeback_popped_up or not PlayerDataController:Get("WelcomeBackGiftReady") then
		if self._patchnotes_popped_up or PlayerDataController:Get("LastPatchNotesVersion") == CONSTANTS.GAME_VERSION or not (statistic > 3) then
			if self._mobileduels_popped_up or CONSTANTS.IS_MOBILE_SERVER or not (statistic > 0) or not (statistic <= 3) or ControlsController.CurrentControls ~= "Touch" then
				if statistic > 10 and CONSTANTS.IS_HUB_SERVER and (Utility:IsAprilFools() and PlayerDataController:Get("AprilFoolsDialogAcknowledged") == -1 or not Utility:IsAprilFools() and PlayerDataController:Get("AprilFoolsDialogAcknowledged") ~= -1) then
					self.PageSystem:OpenPage("DialogAprilFools", true)
				end
			else
				self._mobileduels_popped_up = true
				self.PageSystem:OpenPage("MobileDuels", true)
			end
		else
			self._patchnotes_popped_up = true
			self.PageSystem:OpenPage("PatchNotes", true)
		end
	else
		self._welcomeback_popped_up = true
		self._delay_next_popup = 9
		self.PageSystem:OpenPage("WelcomeBack", true)
	end

	self._patchnotes_popped_up = true
end

function class:_PickWeapons()
	local fighter = FighterController:GetFighter(Players.LocalPlayer)

	if not fighter then
		return
	end

	local duel = DuelController:GetDuel(Players.LocalPlayer)
	local v

	if #fighter.Items == 0 then
		v = fighter:Get("CanPickWeapons") and fighter:IsAlive()
	else
		v = false
	end

	local staggeredSpawnsTurn = duel and duel.LocalDueler and duel.LocalDueler:GetStaggeredSpawnsTurn()

	if v then
		if not self.PageSystem.CurrentPage then
			self:OpenPickWeaponsPage()
		end
	elseif not staggeredSpawnsTurn then
		for _, v2 in pairs({ "PickWeapons", "PickWeaponsList" }) do
			local page = self.PageSystem:GetPage(v2)

			if page and page:IsOpen() then
				self.PageSystem:CloseCurrentPage()
			end
		end
	end
end

function class:_DuelAdded(object2)
	if not object2:GetDueler(Players.LocalPlayer) then
		return
	end

	object2:GetDataChangedSignal("StaggeredSpawnsOrder"):Connect(function()
		self:_PickWeapons()
	end)
	self:_PickWeapons()
end

function class:_HookLocalFighter()
	local v = FighterController:WaitForLocalFighter()
	v:GetDataChangedSignal("IsInDuel"):Connect(function()
		if v:Get("IsInDuel") and self.PageSystem.CurrentPage then
			self.PageSystem:CloseCurrentPage()
		end
	end)
	v:GetDataChangedSignal("CanPickWeapons"):Connect(function()
		self:_PickWeapons()
	end)
	v.EntityRemoved:Connect(function()
		self:_PickWeapons()
	end)
	v.ItemRemoved:Connect(function()
		self:_PickWeapons()
	end)
	v.ItemAdded:Connect(function()
		self:_PickWeapons()
	end)

	local function entity_added(p)
		p.Died:Connect(function()
			self:_PickWeapons()
		end)
		self:_PickWeapons()
	end

	v.EntityAdded:Connect(entity_added)

	if v.Entity then
		task.defer(entity_added, v.Entity)
	end
end

function class._SweepFromFolder(_)
	local function folder_added(surfaceGui)
		if not surfaceGui:IsA("SurfaceGui") or surfaceGui.Name ~= "PagesFromServer" then
			return
		end

		local function sweep()
			task.defer(function()
				for _, child in pairs(surfaceGui:GetChildren()) do
					child.Parent = Players.LocalPlayer.PlayerScripts.UserInterface.Pages
				end
			end)
		end

		surfaceGui.ChildAdded:Connect(sweep)
		task.defer(function()
			for _, child in pairs(surfaceGui:GetChildren()) do
				child.Parent = Players.LocalPlayer.PlayerScripts.UserInterface.Pages
			end
		end)
	end

	Players.LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
		folder_added(child)
	end)

	for _, child in pairs(Players.LocalPlayer.PlayerGui:GetChildren()) do
		folder_added(child)
	end
end

function class:_Init()
	self.PageSystem.PageOpened:Connect(function()
		GamepadService:EnableGamepadCursor(self:GetDefaultElement())
	end)
	self.PageSystem.PageClosed:Connect(function(p)
		GamepadService:DisableGamepadCursor()
		task.defer(self._CheckPopUps, self)

		if p ~= self.PageSystem:GetPage("PickWeapons") and p ~= self.PageSystem:GetPage("PickWeaponsList") then
			task.defer(self._PickWeapons, self)
		end
	end)
	Queue.VisibilityChanged:Connect(function()
		self:_CheckInterruption()
	end)
	Teleporting.EnabledChanged:Connect(function()
		self:_CheckInterruption()
	end)
	MobileInputs.EditorEnabledChanged:Connect(function()
		self:_CheckInterruption()
	end)
	ControlsController.ControlsChanged:Connect(function()
		self:_CheckPopUps()
	end)
	PlayerDataController:GetDataChangedSignal("StatisticDuelsPlayed"):Connect(function()
		self:_CheckPopUps()
	end)
	PlayerDataController:GetDataChangedSignal("AprilFoolsDialogAcknowledged"):Connect(function()
		self:_CheckPopUps()
	end)
	DuelController.LocalPlayerLeftDuel:Connect(function()
		self:_CheckPopUps()
	end)
	GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
		self:_UpdateVisibility()
	end)
	self:_UpdateVisibility()
	task.defer(self._CheckPopUps, self)
	task.defer(self._SweepFromFolder, self)
	task.defer(self._HookLocalFighter, self)
end

return class._new()