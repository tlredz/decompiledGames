local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local BackActionRouter = require(ReplicatedStorage.Modules.Client.UI.BackActionRouter)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local InteractableItem = require(ReplicatedStorage.Modules.Shared.Item.InteractableItem)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local RequirementBehaviors = require(ReplicatedStorage.Modules.Shared.RequirementBehaviors)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
local LotController = require(ReplicatedStorage.Modules.Client.Lot.LotController)
local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
local DisasterControls = require(ReplicatedStorage.Modules.Client.Components.Houses.Modal.DisasterControls)
local PropertyConfig = require(ReplicatedStorage.Modules.Shared.DB.Housing.PropertyConfig)
local FilterMenu = require(ReplicatedStorage.Modules.Client.Components.UI.Filter.FilterMenu)
local PlayerLocalizationController = require(ReplicatedStorage.Modules.Client.Player.PlayerLocalizationController)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
require(ReplicatedStorage.Modules.Shared.Item.Items.DevProductItem)
local QuickSurfaceButton = require(ReplicatedStorage.Modules.Client.Components.UI.Breadcrumbs.QuickSurfaceButton)
local HouseCooldownUI = require(ReplicatedStorage.Modules.Client.Components.UI.HouseCooldownUI)
local HouseMailBox = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.House.HouseMailBox)
local HouseSaveStates = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.House.HouseSaveStates)
local HouseSaveSlotsABTest = require(ReplicatedStorage.Modules.Client.Houses.ABTests.HouseSaveSlotsABTest)
require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
local HousePartyConfirm = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Party.HousePartyConfirm)
local LoadableEntriesFilter = require(ReplicatedStorage.Modules.Client.Components.UI.Utils.Loadables.LoadableEntriesFilter)
local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local PlayerFlag = require(ReplicatedStorage.Modules.Client.PlayerFlags.PlayerFlag)
local NewEstatesSurfacingAbTestController = require(ReplicatedStorage.Modules.Client.Houses.ABTests.NewEstatesSurfacingAbTestController)
local EstateSurfacingTelemetry = require(ReplicatedStorage.Modules.Client.Houses.ABTests.EstateSurfacingTelemetry)
local Mansions = require(ReplicatedStorage.Modules.Client.UI.LoadableEntries.Mansions)
local HouseViewCamera = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.House.HouseViewCamera)
local EstatePlotPickerPopup = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.House.EstatePlotPickerPopup)
local HouseMenuABTest = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.House.HouseMenuABTest)
local UIGridPosition = require(ReplicatedStorage.Modules.Shared.Utils.UIGridPosition)
local v = Component.new({
	Tag = "HouseMenu"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.OnHouseSelected = Signal.new()
	self.selectedHouseId = nil
	self.pendingSpawnUiPosition = nil
	local menu = self.Instance:WaitForChild("Menu")
	self.confirmHouseFrame = menu:WaitForChild("HouseCoolConfirm")
	self.deleteHouseFrame = menu:WaitForChild("HouseCoolDelete")
	self.cooldownWaitingFrame = menu:WaitForChild("HouseCooldownWaiting")
	self.filters = ComponentUtil.GetComponentFromInstance(
		self.Instance:WaitForChild("Catalog"):WaitForChild("Container"):WaitForChild("ScrollGroup"):WaitForChild("FilterGroup"):WaitForChild("Filters"),
		FilterMenu
	)
	self.categoryTabs = self.Instance:WaitForChild("Catalog"):WaitForChild("Header"):WaitForChild("CategoryTabs")
	local cooldown = self.categoryTabs:WaitForChild("Cooldown")
	local quickSurface = self.Instance:WaitForChild("Catalog"):WaitForChild("Header"):WaitForChild("CategoryTabs"):FindFirstChild("QuickSurface")
	self.quickSurfaceButton = quickSurface
	self.quickSurfaceButtonComponent = QuickSurfaceButton:WaitForInstance(quickSurface):expect()
	local component = ComponentUtil.GetComponentFromInstance(cooldown, HouseCooldownUI)

	if not component then
		return
	end

	self.houseCooldownUIComponent = component
	self.leaveHomeButton = self.categoryTabs:WaitForChild("LeaveHome")
	self.houseType = "House"
	self._pendingSurfacedEstateSelection = nil
	self._pendingEstatePlotPickEstateName = nil
	self._estatePlotPickConfirmActive = false
	self._confirmHousePromptDefaultText = nil
	self._estateSurfacingPlotPickGeneration = 0
	self._estateNewPopupPlotPickActive = false
	self._estateSurfacingAwaitingClaimPlotTelemetry = false
	self._houseMenuWasOpenForEstatePopup = false
end

function v:resetEstateSurfacingTelemetryState()
	self._estateSurfacingAwaitingClaimPlotTelemetry = false
end

function v:getConfirmHousePromptLabel()
	local houseCoolDown = self.confirmHouseFrame:FindFirstChild("HouseCoolDown", true)

	if houseCoolDown ~= nil and houseCoolDown:IsA("TextLabel") then
		return houseCoolDown
	end

	for _, label in self.confirmHouseFrame:GetDescendants() do
		if not label:IsA("TextLabel") then
			continue
		end

		local parent = label.Parent

		if parent == nil or parent.Name ~= "Yes" and parent.Name ~= "No" then
			return label
		end
	end

	return nil
end

function v:setEstatePlotPickConfirmPrompt()
	local confirmHousePromptLabel = self:getConfirmHousePromptLabel()

	if confirmHousePromptLabel == nil then
		return
	end

	if self._confirmHousePromptDefaultText == nil then
		self._confirmHousePromptDefaultText = confirmHousePromptLabel.Text
	end

	confirmHousePromptLabel.Text = LotController.GetCurrentHouse() == nil and "Choose selected estate?" or "Choose selected estate? Your current house will be unowned."
end

function v:restoreConfirmHousePrompt()
	if self._confirmHousePromptDefaultText == nil then
		return
	end

	local confirmHousePromptLabel = self:getConfirmHousePromptLabel()

	if confirmHousePromptLabel ~= nil then
		confirmHousePromptLabel.Text = self._confirmHousePromptDefaultText
	end
end

function v:cancelEstatePlotPickConfirm()
	self._estatePlotPickConfirmActive = false
	self._pendingEstatePlotPickEstateName = nil
	self:restoreConfirmHousePrompt()
	self.confirmHouseFrame.Visible = false
	self:ClearCheackMarks()
end

function v:cancelEstateSurfacingPlotPick()
	self._estateSurfacingPlotPickGeneration += 1
	self._pendingSurfacedEstateSelection = nil
	self:resetEstateSurfacingTelemetryState()
	PanelController.Close("MainGUIHandler", "HouseCam")
end

function v:restoreHouseMenuAfterEstatePopup()
	if self._houseMenuWasOpenForEstatePopup then
		self._houseMenuWasOpenForEstatePopup = false
		PanelController.Open("MainGUIHandler", "MainHouseMenu")
	end
end

function v:cancelEstateNewPopupPlotPick()
	self._estateNewPopupPlotPickActive = false
	self._pendingSurfacedEstateSelection = nil
	self:resetEstateSurfacingTelemetryState()

	if PanelController.IsOpen("MainGUIHandler", "EstatePlotPickerPopup") then
		PanelController.Close("MainGUIHandler", "EstatePlotPickerPopup")
	end

	self:restoreHouseMenuAfterEstatePopup()
end

function v:reopen()
	if PanelController.IsOpen("MainGUIHandler", "MainHouseMenu") then
		return true
	end

	return false
end

function v:openEstatePlotPickerPopup()
	if PanelController.IsOpen("MainGUIHandler", "MainHouseMenu") then
		self._houseMenuWasOpenForEstatePopup = true
		PanelController.Close("MainGUIHandler", "MainHouseMenu")
	else
		self._houseMenuWasOpenForEstatePopup = false
	end

	local v2 = PanelController.WaitForPanel("MainGUIHandler", "EstatePlotPickerPopup")

	if v2 == nil then
		self:restoreHouseMenuAfterEstatePopup()
		return
	end

	if self._pendingSurfacedEstateSelection ~= nil then
		v2:GetInstance():SetAttribute("PendingEstateName", self._pendingSurfacedEstateSelection)
	end

	local component = ComponentUtil.GetComponentFromInstance(v2:GetInstance(), EstatePlotPickerPopup)

	if component == nil then
		EstatePlotPickerPopup:WaitForInstance(v2:GetInstance()):andThen(function(object2)
			object2:Open()
		end)
	else
		component:Open()
	end
end

function v:beginNewPopupSurfacedEstateFlow(pendingSurfacedEstateSelection: string)
	self:releaseOwnedHouseForEstateSelection()
	self._pendingSurfacedEstateSelection = pendingSurfacedEstateSelection
	self._estateNewPopupPlotPickActive = true
	self:resetEstateSurfacingTelemetryState()
	self.selectedHouseId = nil
	self.confirmHouseFrame.Visible = false
	self.cooldownWaitingFrame.Visible = false
	self.deleteHouseFrame.Visible = false
	self:ClearCheackMarks()
	self:openEstatePlotPickerPopup()
end

function v:promptEstatePlotPickConfirm(pendingEstatePlotPickEstateName: string, instance)
	self._pendingEstatePlotPickEstateName = pendingEstatePlotPickEstateName
	self._estatePlotPickConfirmActive = true
	self:rememberSpawnUiPosition(instance)
	self.selectedHouseId = nil
	self.cooldownWaitingFrame.Visible = false
	self.deleteHouseFrame.Visible = false
	self:ClearCheackMarks()
	instance:AddTag("Checked")
	self:setEstatePlotPickConfirmPrompt()
	self.Instance.Catalog.Container.Disclaimer.Visible = false
	self.confirmHouseFrame.Visible = true
end

function v:ClearCheackMarks()
	for _, button in self.Instance:WaitForChild("Catalog"):WaitForChild("Container"):WaitForChild("ScrollGroup"):WaitForChild("ScrollingFrame"):GetChildren() do
		if button:IsA("ImageButton") then
			button:RemoveTag("Checked")
		end
	end
end

function v:dismissPendingHouseSelection()
	if self._estatePlotPickConfirmActive then
		self:cancelEstatePlotPickConfirm()
	else
		self:restoreConfirmHousePrompt()
		self.confirmHouseFrame.Visible = false
		self.selectedHouseId = nil
		self:ClearCheackMarks()
	end

	self.deleteHouseFrame.Visible = false
	self.cooldownWaitingFrame.Visible = false
end

function v:OpenAsHouseType(p: string, lotId: number)
	local houseType

	if p == "Mansion" then
		houseType = "Mansions"
	elseif p == "House" then
		houseType = "Houses"
	elseif p == "Motel" then
		houseType = "Motels"
	elseif p == "Apartment" then
		houseType = "Apartments"
	elseif p == "Landmark" then
		houseType = "Landmarks"
	else
		houseType = p
	end

	self.houseType = houseType
	self.lotId = lotId
	local houseCooldownUIComponent = self.houseCooldownUIComponent

	if houseCooldownUIComponent then
		houseCooldownUIComponent:SetActiveHouseType(self.houseType)
	end

	local scrollingFrame = self.Instance:WaitForChild("Catalog"):WaitForChild("Container"):WaitForChild("ScrollGroup"):WaitForChild("ScrollingFrame")
	scrollingFrame:SetAttribute("ItemType", houseType)
	scrollingFrame:SetAttribute("LoadableEntriesModuleName", houseType)
	scrollingFrame.CanvasPosition = Vector2.new(0, 0)
	self.selectedHouseId = nil
	local component = ComponentUtil.GetComponentFromInstance(scrollingFrame, LoadableEntriesFilter)
	component:Unload()
	component:SetCategory(nil)
	component:SetTargetModule(houseType)
	component:ReloadFromModule()

	if self.quickSurfaceButton and self.quickSurfaceButtonComponent then
		self.quickSurfaceButton:SetAttribute("ItemType", houseType)

		if self.quickSurfaceButtonComponent and self.quickSurfaceButtonComponent:IsActiveIsolating() then
			self.quickSurfaceButtonComponent:ToggleOff()
		end

		self.quickSurfaceButtonComponent:RefreshVisibility()
	end
end

function v:applySurfacedEstateSelection(childName: string, p: number?)
	if p ~= nil then
		self:OpenAsHouseType("Mansion", p)
	end

	local scrollingFrame = self.Instance:WaitForChild("Catalog"):WaitForChild("Container"):WaitForChild("ScrollGroup"):WaitForChild("ScrollingFrame")
	local component = ComponentUtil.GetComponentFromInstance(scrollingFrame, LoadableEntriesFilter)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function trySelectEstate()
		local button = scrollingFrame:FindFirstChild(childName)

		if button == nil or not button:IsA("ImageButton") then
			return false
		end

		self:restoreConfirmHousePrompt()
		self._estatePlotPickConfirmActive = false
		self:SetSelection(button, true)
		return true
	end

	if not component:IsLoaded() then
		component:Load()
	end

	-- equivalent call inferred; original call site unknown
	if trySelectEstate() then
		return
	end

	local maid = Janitor.new()
	maid:Add(component.Loaded:Connect(function()
		-- equivalent call inferred; original call site unknown
		if trySelectEstate() then
			maid:Destroy()
		end
	end))
	maid:Add(scrollingFrame.ChildAdded:Connect(function(button)
		if button.Name == childName and button:IsA("ImageButton") then
			self:SetSelection(button, true)
			maid:Destroy()
		end
	end))
end

function v:releaseOwnedHouseForEstateSelection()
	if LotUtil.GetPlayerOwnedLotNumber(Players.LocalPlayer) == nil then
		return
	end

	LotController.Unclaim()
	local panel = PanelController.GetPanel("NoResetGUIHandler", "HouseKey")

	if panel ~= nil then
		local instance = panel:GetInstance()
		instance.House.Value.SettingsLabel.Text = "Picking Style"
	end

	PanelController.Close("MainGUIHandler", "HouseControlPanel")
	task.spawn(function()
		for _, v2 in DisasterControls:GetAll() do
			v2:Reset()
		end
	end)
	PanelController.ToggleGroup("HouseModal", false)
	local v2 = HouseMailBox:GetAll()[1]

	if v2 ~= nil then
		v2:ClearMail()
	end
end

function v:beginExistingViewSurfacedEstateFlow(p: string)
	self:releaseOwnedHouseForEstateSelection()
	self:resetEstateSurfacingTelemetryState()
	self:OpenExistingEstateCameraView(p)
end

function v:OpenExistingEstateCameraView(pendingSurfacedEstateSelection: string)
	self._estateSurfacingPlotPickGeneration += 1
	local _estateSurfacingPlotPickGeneration = self._estateSurfacingPlotPickGeneration
	self._pendingSurfacedEstateSelection = pendingSurfacedEstateSelection
	self.selectedHouseId = nil
	self.confirmHouseFrame.Visible = false
	self.cooldownWaitingFrame.Visible = false
	self.deleteHouseFrame.Visible = false
	self:ClearCheackMarks()
	PanelController.Close("MainGUIHandler", "MainHouseMenu")
	PanelController.Open("MainGUIHandler", "HouseCam")
	local v2 = PanelController.WaitForPanel("MainGUIHandler", "HouseCam")

	if v2 == nil then
		return
	end

	v2:GetInstance():SetAttribute("PendingEstateName", pendingSurfacedEstateSelection)

	local function applyFirstEstateCamera(object2)
		task.defer(function()
			if not (_estateSurfacingPlotPickGeneration == self._estateSurfacingPlotPickGeneration and PanelController.IsOpen(
				"MainGUIHandler",
				"HouseCam"
			)) then
				return
			end

			object2:JumpToFirstEstateCamera()
		end)
	end

	local component = ComponentUtil.GetComponentFromInstance(v2.Instance, HouseViewCamera)

	if component == nil then
		HouseViewCamera:WaitForInstance(v2.Instance):andThen(applyFirstEstateCamera)
	else
		task.defer(function()
			if not (_estateSurfacingPlotPickGeneration == self._estateSurfacingPlotPickGeneration and PanelController.IsOpen(
				"MainGUIHandler",
				"HouseCam"
			)) then
				return
			end

			component:JumpToFirstEstateCamera()
		end)
	end
end

function v:rememberSpawnUiPosition(p2)
	self.pendingSpawnUiPosition = UIGridPosition.fromButton(p2)
end

function v:SetSelection(instance, flag: boolean?)
	if instance.Parent == nil then
		return
	end

	if self._estatePlotPickConfirmActive then
		self:cancelEstatePlotPickConfirm()
	end

	self:restoreConfirmHousePrompt()
	self.selectedHouseId = instance.Name

	if flag ~= true then
		self:rememberSpawnUiPosition(instance)
	end

	self.cooldownWaitingFrame.Visible = false
	self.deleteHouseFrame.Visible = false
	self.confirmHouseFrame.Visible = true
	self.Instance.Catalog.Container.Disclaimer.Visible = false
	self:ClearCheackMarks()
	instance:AddTag("Checked")
end

function v:HouseCooldownWarning()
	task.spawn(function()
		local isFeatureUnlocked = UnlockableController.IsFeatureUnlocked(
			AdFeatures.VIP_HOUSE_COOLDOWN.id,
			Gamepasses.VIP
		)
		local isPrivateServer = GameUtil.IsPrivateServer()

		if isFeatureUnlocked or isPrivateServer then
			self.cooldownWaitingFrame.HouseCoolDown.Text = "Please wait for the house to spawn..."
		else
			self.cooldownWaitingFrame.HouseCoolDown.Text = "House timer has not ended..."
			local houseCooldownUIComponent = self.houseCooldownUIComponent

			if houseCooldownUIComponent:IsOnCooldown(self.houseType) then
				houseCooldownUIComponent.Instance.Visible = true
			end
		end

		if self.cooldownWaitingFrame.Visible == false then
			self.deleteHouseFrame.Visible = false
			self.cooldownWaitingFrame.Visible = true
			self.Instance.Catalog.Container.Disclaimer.Visible = false
			task.wait(5)
			self.cooldownWaitingFrame.Visible = false

			if self._disclaimerVisible then
				self.Instance.Catalog.Container.Disclaimer.Visible = true
			end
		end
	end)
end

function v:ConfirmHouse()
	self:TrySpawn(self.selectedHouseId, self.pendingSpawnUiPosition)
end

function v:TrySpawn(p: string, p2)
	if self.houseCooldownUIComponent:IsOnCooldown() then
		self:HouseCooldownWarning()
		return false
	end

	local panel = PanelController.GetPanel("NoResetGUIHandler", "HouseKey")

	if not panel then
		warn("HouseLeaveHome: HouseKey panel not found, why?")
		return false
	end

	local instance = panel:GetInstance()
	local value = instance.House.Value.Key.HouseKeyNumber.Value
	local v2, v3, v4 = LotController.TryBuildProperty(value, p, p2)

	if v2 then
		self.dbConfirmYes = true
		self.pendingSpawnUiPosition = nil
		instance.House.Value.SettingsLabel.Text = "Controls"
		PanelController.Close("MainGUIHandler", "MainHouseMenu")
		PanelController.Close("MainGUIHandler", "HouseControlPanel")
		self.confirmHouseFrame.Visible = false
		self.leaveHomeButton.Visible = false

		if self._disclaimerVisible then
			self.Instance.Catalog.Container.Disclaimer.Visible = true
		end

		local v5, v6 = ABTest.GetExperimentVariable("console-controls", "plotUi"):timeout(7):await()

		if v5 and v6 then
			Platform.EndSelection()
		end

		task.spawn(function()
			for _, v7 in DisasterControls:GetAll() do
				v7:Reset()
			end
		end)
		PanelController.ToggleGroup("HouseModal", false)
		HouseMailBox:GetAll()[1]:ClearMail()
		task.wait(1)
		local isFeatureUnlocked = UnlockableController.IsFeatureUnlocked(
			AdFeatures.VIP_HOUSE_COOLDOWN.id,
			Gamepasses.VIP
		)
		local isPrivateServer = GameUtil.IsPrivateServer()

		if not (isFeatureUnlocked or isPrivateServer) then
			self.houseCooldownUIComponent:StartTimer(self.houseType)
		end

		self.dbConfirmYes = false
		return true
	else
		if v4 then
			PanelController.Close("MainGUIHandler", "MainHouseMenu")
			PanelController.Close("MainGUIHandler", "HouseControlPanel")
			self.confirmHouseFrame.Visible = false
			PanelController.ToggleGroup("HouseModal", false)
			local v5, v6 = ABTest.GetExperimentVariable("console-controls", "plotUi"):timeout(7):await()

			if v5 and v6 then
				Platform.EndSelection()
			end
		end

		task.spawn(function()
			NotificationController.Notify(not v3 and "Please wait for house to spawn" or v3, 4)
		end)
		self.dbConfirmYes = false
		return false
	end
end

function v:DeleteHouse()
	local panel = PanelController.GetPanel("NoResetGUIHandler", "HouseKey")

	if not panel then
		warn("HouseLeaveHome: HouseKey panel not found, why?")
		return false
	end

	local panel2 = PanelController.GetPanel("MainGUIHandler", "MainAudio")

	if not panel2 then
		warn("HouseLeaveHome: MainAudio panel not found, why?")
		return false
	end

	local instance = panel2:GetInstance()
	local instance2 = panel:GetInstance()
	LotController.Unclaim()
	instance2.Visible = false
	instance.Visible = false
	PanelController.Close("MainGUIHandler", "MainHouseMenu")
	PanelController.Close("MainGUIHandler", "HouseControlPanel")
	instance2.House.Value.SettingsLabel.Text = "Picking Style"
	self.confirmHouseFrame.Visible = false
	self.deleteHouseFrame.Visible = false

	if self._disclaimerVisible then
		self.Instance.Catalog.Container.Disclaimer.Visible = true
	end

	task.spawn(function()
		for _, v2 in DisasterControls:GetAll() do
			v2:Reset()
		end
	end)
	PanelController.ToggleGroup("HouseModal", false)
	HouseMailBox:GetAll()[1]:ClearMail()
	self:ClearCheackMarks()
	return true
end

function v:Start()
	local instance = self.Instance
	local scrollingFrame = instance:WaitForChild("Catalog"):WaitForChild("Container"):WaitForChild("ScrollGroup"):WaitForChild("ScrollingFrame")
	local component = ComponentUtil.GetComponentFromInstance(scrollingFrame, LoadableEntriesFilter)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refreshEstatesSurfacingCatalog()
		if scrollingFrame:GetAttribute("LoadableEntriesModuleName") ~= "Houses" then
			return
		end

		if component:IsLoaded() then
			component:RefreshFilter()
		else
			component:RebuildEntryValues()
		end
	end

	if NewEstatesSurfacingAbTestController.IsReady() then
		refreshEstatesSurfacingCatalog() -- equivalent call inferred; original call site unknown
	else
		task.spawn(function()
			while not NewEstatesSurfacingAbTestController.IsReady() do
				task.wait()
			end

			refreshEstatesSurfacingCatalog() -- equivalent call inferred; original call site unknown
		end)
	end

	for _, button in self.categoryTabs:GetChildren() do
		if button:IsA("TextButton") or button:IsA("ImageButton") then
			button.SelectionOrder = 2000
		end
	end

	local v2 = false
	self.dbConfirmYes = false
	local close = self.categoryTabs:WaitForChild("Close")
	local _1Gettin1gHous1e = ReplicatedStorage.RE:WaitForChild("1Gettin1gHous1e")
	self._Janitor:Add(_1Gettin1gHous1e.OnClientEvent:Connect(function(p: string, p2: number, p3: string)
		if p ~= "BuyHouseSetUpUI" then
			return
		end

		local _pendingSurfacedEstateSelection = self._pendingSurfacedEstateSelection

		if _pendingSurfacedEstateSelection == nil then
			return
		end

		if self._estateSurfacingAwaitingClaimPlotTelemetry then
			EstateSurfacingTelemetry.sendClaimPlot(_pendingSurfacedEstateSelection, p2)
			self:resetEstateSurfacingTelemetryState()
		end

		if p3 == "Mansion" then
			local _estateNewPopupPlotPickActive = self._estateNewPopupPlotPickActive
			self._estateNewPopupPlotPickActive = false
			self._pendingSurfacedEstateSelection = nil

			if _estateNewPopupPlotPickActive then
				PanelController.Close("MainGUIHandler", "EstatePlotPickerPopup")
			else
				self._estateSurfacingPlotPickGeneration += 1
				PanelController.Close("MainGUIHandler", "HouseCam")
			end

			task.defer(function()
				self:applySurfacedEstateSelection(_pendingSurfacedEstateSelection, p2)
			end)
		else
			if self._estateNewPopupPlotPickActive then
				return
			end

			self:cancelEstateSurfacingPlotPick()
			self:cancelEstateNewPopupPlotPick()
		end
	end))
	self._Janitor:Add(EstateSurfacingTelemetry.OnPlotTeleported:Connect(function()
		self._estateSurfacingAwaitingClaimPlotTelemetry = true
	end))
	self._Janitor:Add(EstatePlotPickerPopup.OnDismissed:Connect(function(flag: boolean)
		if not self._estateNewPopupPlotPickActive then
			return
		end

		self._estateNewPopupPlotPickActive = false
		self._pendingSurfacedEstateSelection = nil
		self:resetEstateSurfacingTelemetryState()

		if flag then
			self:restoreHouseMenuAfterEstatePopup()
		else
			self._houseMenuWasOpenForEstatePopup = false
		end
	end))
	self._Janitor:Add(EstateSurfacingTelemetry.OnOccupiedEstateTeleported:Connect(function()
		self._estateNewPopupPlotPickActive = false
		self._pendingSurfacedEstateSelection = nil
		self:resetEstateSurfacingTelemetryState()
		self._houseMenuWasOpenForEstatePopup = false
	end))

	if not close:HasTag("HouseCloseMenu") then
		close:RemoveTag("ClosePanelButton")
		close:AddTag("HouseCloseMenu")
	end

	LotController.CooldownStartedSignal:Connect(function()
		local houseCooldownUIComponent = self.houseCooldownUIComponent

		if not houseCooldownUIComponent:IsOnCooldown(self.houseType) then
			houseCooldownUIComponent:StartTimer(self.houseType)
		end

		houseCooldownUIComponent.Instance.Visible = true
	end)
	local v3 = PanelController.WaitForPanel("MainGUIHandler", "MainHouseMenu")

	if v3 == nil then
		error("HouseMenu Close: Panel not found")
	end

	local v4 = false
	v3:RegisterListener(self, v3.Events.Opening, function(_)
		v4 = true
		self.Instance.Catalog.Visible = true
		local saveCatalog = self.Instance:FindFirstChild("SaveCatalog")

		if saveCatalog ~= nil then
			saveCatalog.Visible = false
			local expect = HouseSaveStates:WaitForInstance(self.Instance.SaveCatalog.Container.ScrollingFrame):now():expect()

			if expect then
				expect:SetSource("MainButton")
			end
		end
	end)
	v3:RegisterListener(self, v3.Events.Closing, function(_)
		local currentHouse = LotController.GetCurrentHouse()

		if v4 and not self.dbConfirmYes then
			if currentHouse == nil then
				LotController.Unclaim()
			elseif self.houseType == "Landmarks" then
				local owner = currentHouse:GetOwner()

				if owner ~= nil and owner ~= Players.LocalPlayer then
					LotController.Unclaim()
				end
			end
		end

		v4 = false
	end)
	self._Janitor:Add(function()
		v3:UnregisterListener(self, v3.Events.Opening)
		v3:UnregisterListener(self, v3.Events.Closing)
	end, true)

	if PlayerFlag.IsEnabled("save-catalog") then
		local saveStates = self.categoryTabs.SaveStates
		saveStates.Visible = true
		self._Janitor:Add(saveStates.Activated:Connect(function()
			self:ShowSaves()
		end))
		HouseSaveStates:WaitForInstance(self.Instance.SaveCatalog.Container.ScrollingFrame):andThen(function(object2)
			object2:SetReturnCallback(function()
				self.Instance.Catalog.Visible = true
				self.Instance.SaveCatalog.Visible = false
			end, function(p: string)
				return self:TrySpawn(p)
			end)
		end)
		local categoryTabs = self.Instance.SaveCatalog.Header.CategoryTabs
		self._Janitor:Add(categoryTabs.BackButton.Activated:Connect(function()
			self.Instance.Catalog.Visible = true
			self.Instance.SaveCatalog.Visible = false
		end))
		local subtleSaleButton = self.Instance.SaveCatalog.Header.CategoryTabs:FindFirstChild("SubtleSaleButton")

		if subtleSaleButton ~= nil then
			self._Janitor:AddPromise(HouseSaveSlotsABTest.WaitForReady():andThen(function()
				if HouseSaveSlotsABTest.IsSubtleSale() then
					self._Janitor:Add(subtleSaleButton.Activated:Connect(function()
						HouseSaveStates.PromptNextSlotPurchase()
					end))
				end
			end))
		end
	else
		self.Instance.SaveCatalog:Destroy()
	end

	self.leaveHomeButton.MouseButton1Click:connect(function()
		if self.houseCooldownUIComponent:IsOnCooldown() then
			self.cooldownWaitingFrame.Visible = false
			self.confirmHouseFrame.Visible = false
			self.deleteHouseFrame.Visible = true
			self.Instance.Catalog.Container.Disclaimer.Visible = false
		else
			local v5, v6 = ReplicatedDataController.GetSessionReplicaPromise():now():await()

			if v5 and v6.Data.Party then
				HousePartyConfirm.SetData(function()
					self:DeleteHouse()
				end)
				PanelController.Open("MainGUIHandler", "HousePartyConfirm")
			else
				self:DeleteHouse()
			end
		end
	end)
	self.confirmHouseFrame.Yes.MouseButton1Click:connect(function()
		if self._estatePlotPickConfirmActive then
			local _pendingEstatePlotPickEstateName = self._pendingEstatePlotPickEstateName
			self:cancelEstatePlotPickConfirm()

			if _pendingEstatePlotPickEstateName == nil then
				return
			end

			if NewEstatesSurfacingAbTestController.IsNewPopupPanel() then
				self:beginNewPopupSurfacedEstateFlow(_pendingEstatePlotPickEstateName)
			else
				self:beginExistingViewSurfacedEstateFlow(_pendingEstatePlotPickEstateName)
			end
		elseif self.dbConfirmYes == false then
			self.dbConfirmYes = true
			local v5, v6 = ReplicatedDataController.GetSessionReplicaPromise():now():await()

			if v5 and v6.Data.Party then
				HousePartyConfirm.SetData(function()
					self:ConfirmHouse()
				end)
				PanelController.Open("MainGUIHandler", "HousePartyConfirm")
				task.wait(0.5)
				self.dbConfirmYes = false
			else
				self:ConfirmHouse()
				task.wait(0.5)
				self.dbConfirmYes = false
			end
		end
	end)
	self.deleteHouseFrame.Yes.MouseButton1Click:connect(function()
		local v5, v6 = ReplicatedDataController.GetSessionReplicaPromise():now():await()

		if v5 and v6.Data.Party then
			HousePartyConfirm.SetData(function()
				self:DeleteHouse()
			end)
			PanelController.Open("MainGUIHandler", "HousePartyConfirm")
		else
			self:DeleteHouse()
		end
	end)
	self._Janitor:Add(self.deleteHouseFrame.No.MouseButton1Click:Connect(function()
		self.deleteHouseFrame.Visible = false
		self.selectedHouseId = nil

		if self._disclaimerVisible then
			self.Instance.Catalog.Container.Disclaimer.Visible = true
		end
	end))
	self._Janitor:Add(self.confirmHouseFrame.No.MouseButton1Click:connect(function()
		if self._estatePlotPickConfirmActive then
			self:cancelEstatePlotPickConfirm()

			if self._disclaimerVisible then
				self.Instance.Catalog.Container.Disclaimer.Visible = true
			end
		elseif v2 == false then
			v2 = true
			self:ClearCheackMarks()
			self.confirmHouseFrame.Visible = false

			if self._disclaimerVisible then
				self.Instance.Catalog.Container.Disclaimer.Visible = true
			end

			wait(0.5)
			v2 = false
		end
	end))
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if not self.Instance.Visible then
			if self._estatePlotPickConfirmActive then
				self:cancelEstatePlotPickConfirm()
			end

			self.confirmHouseFrame.Visible = false
			self.deleteHouseFrame.Visible = false
			self.cooldownWaitingFrame.Visible = false
			self.selectedHouseId = nil
			self:ClearCheackMarks()

			if self._disclaimerVisible then
				self.Instance.Catalog.Container.Disclaimer.Visible = true
			end

			self.filters:Reset()
		end
	end))
	local backButton = instance.Catalog.Header.CategoryTabs.BackButton
	local v5 = nil

	local function unbindBackAction()
		if not v5 then
			return
		end

		v5()
		v5 = nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function bindBackAction()
		if v5 then
			return
		end

		v5 = BackActionRouter.Bind(function()
			component:SetCategory(nil)
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateBackActionBinding()
		if instance.Visible and backButton.Visible then
			bindBackAction() -- equivalent call inferred; original call site unknown
		else
			if not v5 then
				return
			end

			v5()
			v5 = nil
		end
	end

	self._Janitor:Add(unbindBackAction)
	self._Janitor:Add(instance.Catalog.Header.CategoryTabs.BackButton.MouseButton1Click:Connect(function()
		component:SetCategory(nil)
	end))
	local maid = Janitor.new()
	local localPlayer = Players.LocalPlayer
	local v6 = {}
	local v7 = false

	for _, v8 in component:GetConfigTable() do
		v6[v8.Name] = v8
	end

	local function findMansionConfig(p: string)
		for _, entry in Mansions.Entries do
			if entry.Name == p then
				return entry
			end
		end

		return nil
	end

	local function HouseButtonAdded(button)
		if not button:IsA("ImageButton") or button.Name == "Template" or button:HasTag("LoadTestHouseButton") then
			return
		end

		local v8 = v6[button.Name]

		if v8 == nil and button:GetAttribute("IsEstateEntry") == true then
			local name = button.Name

			for _, entry in Mansions.Entries do
				if entry.Name ~= name then
					continue
				end

				v8 = entry
				break
			end
		end

		if not (v8 ~= nil and button:GetAttribute("AttachedConnection") == nil) then
			return
		end

		button:SetAttribute("AttachedConnection", true)

		if v8.IsCategory then
			local v9 = false

			for _, v11 in v6 do
				if not (v11.Name ~= v8.Name and v11.Category and v11.Category == v8.Name) then
					continue
				end

				if not (v11.RequirementBehaviorData == nil or RequirementBehaviors.IsVisible(
					localPlayer,
					v11.RequirementBehaviorData.Behavior,
					unpack(v11.RequirementBehaviorData.Arguments)
				) or RequirementBehaviors.PassesRequirementCheck(
					localPlayer,
					v11.RequirementBehaviorData.Behavior,
					unpack(v11.RequirementBehaviorData.Arguments)
				)) then
					continue
				end

				v9 = true
				break
			end

			if not v9 then
				button.Visible = false
				return
			end
		elseif v8 and v8.RequirementBehaviorData and not (RequirementBehaviors.IsVisible(
			localPlayer,
			v8.RequirementBehaviorData.Behavior,
			unpack(v8.RequirementBehaviorData.Arguments)
		) or RequirementBehaviors.PassesRequirementCheck(
			localPlayer,
			v8.RequirementBehaviorData.Behavior,
			unpack(v8.RequirementBehaviorData.Arguments)
		)) then
			button.Visible = false
			return
		end

		if v8.ComingSoon then
			button.Interactable = false
			button.Selectable = false

			for _, guiObject in { button, unpack(button:GetDescendants()) } do
				if guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton") then
					guiObject.ImageColor3 = Color3.new(
						guiObject.ImageColor3.R * 0.5,
						guiObject.ImageColor3.G * 0.5,
						guiObject.ImageColor3.B * 0.5
					)
				end
			end

			local frame = Instance.new("Frame")
			frame.Name = "GreyFrame"
			frame.BackgroundTransparency = 0.5
			frame.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
			frame.Size = UDim2.new(1, 0, 1, 0)
			frame.Parent = button
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "ComingSoonLabel"
			textLabel.Text = "Coming Soon!"
			textLabel.BackgroundTransparency = 1
			textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
			textLabel.TextStrokeTransparency = 0.5
			textLabel.TextScaled = true
			textLabel.Font = Enum.Font.Nunito
			textLabel.TextXAlignment = Enum.TextXAlignment.Center
			textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			textLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
			textLabel.Size = UDim2.new(0.75, 0, 0.5, 0)
			textLabel.Parent = button
		end

		if self.selectedHouseId and self.selectedHouseId == button.Name then
			button:AddTag("Checked")
		end

		maid:Add(button.MouseButton1Click:Connect(function()
			if v7 == false then
				TelemetryController.SendClientInteraction("filterClick", {
					filter = button.Parent:GetAttribute("CurrentFilter"),
					itemType = button.Parent:GetAttribute("ItemType"),
					name = button.Name
				})

				if v8.IsCategory then
					if v8 and v8.CategoryDisclaimer and (not v8.USOnlyDisclaimer or PlayerLocalizationController.GetCountryRegion() == "US") then
						self._disclaimerVisible = true
						instance.Catalog.Container.Disclaimer.Visible = true
						instance.Catalog.Container.Disclaimer.DisclaimerText.Text = v8.CategoryDisclaimer
					end

					local quickSurfaceButtonComponent = self.quickSurfaceButtonComponent

					if quickSurfaceButtonComponent and quickSurfaceButtonComponent:IsActiveIsolating() then
						quickSurfaceButtonComponent:ToggleOff()
					end

					component:SetCategory(v8.Name)
					return
				else
					local isEstateEntry = button:GetAttribute("IsEstateEntry") == true

					if self._estatePlotPickConfirmActive and (not (isEstateEntry and NewEstatesSurfacingAbTestController.IsSurfacingEnabled()) or not (NewEstatesSurfacingAbTestController.IsExistingCameraViewPanel() or NewEstatesSurfacingAbTestController.IsNewPopupPanel()) or self.houseType ~= "Houses") then
						self:cancelEstatePlotPickConfirm()
					end

					local v9 = PropertyConfig.GetConfig()[button.Name]

					if v9 ~= nil and v9.LotIdRestrictions ~= nil and not table.find(v9.LotIdRestrictions, self.lotId) then
						NotificationController.NotifyCenter("Cannot spawn here.")
						return
					end

					v7 = true
					local v10 = nil

					if isEstateEntry or self.houseType == "Mansions" then
						v10 = AdFeatures.Estates()
					elseif self.houseType == "Houses" then
						v10 = AdFeatures.Houses()
					elseif self.houseType == "Motels" then
						v10 = AdFeatures.Motels()
					elseif self.houseType == "Apartments" then
						v10 = AdFeatures.Penthouses()
					elseif self.houseType == "Landmarks" then
						v10 = AdFeatures.Landmarks()
					end

					if isEstateEntry or self.houseType == "Mansions" then
						local name = button.Name
						local success, result = pcall(function()
							if isEstateEntry then
								EstateSurfacingTelemetry.sendHouseInventory(name)
							end

							local continueMansionOrEstateSelection

							continueMansionOrEstateSelection = function(flag: boolean)
								if self.houseCooldownUIComponent:IsOnCooldown() then
									self:HouseCooldownWarning()

									if not UnlockableController.IsFeatureUnlocked(
										AdFeatures.VIP_HOUSE_COOLDOWN.id,
										Gamepasses.VIP
									) then
										GamepassController.Show(
											Gamepasses.VIP,
											button.Icon.Image,
											"house cooldown",
											nil,
											AdFeatures.VIP_HOUSE_COOLDOWN,
											"Estate cooldown timer active: buy VIP Gamepass to remove",
											"Estate Inventory",
											button.Name,
											function()
												if self:reopen() then
													continueMansionOrEstateSelection(flag)
												end
											end
										)
									end
								elseif isEstateEntry and NewEstatesSurfacingAbTestController.IsSurfacingEnabled() and NewEstatesSurfacingAbTestController.IsNewPopupPanel() then
									if not flag then
										self:promptEstatePlotPickConfirm(name, button)
										return
									end

									self:rememberSpawnUiPosition(button)
									self:beginNewPopupSurfacedEstateFlow(name)
								else
									if not (isEstateEntry and NewEstatesSurfacingAbTestController.IsSurfacingEnabled() and NewEstatesSurfacingAbTestController.IsExistingCameraViewPanel()) then
										self:SetSelection(button)
										return
									end

									if not flag then
										self:promptEstatePlotPickConfirm(name, button)
										return
									end

									self:rememberSpawnUiPosition(button)
									self:beginExistingViewSurfacedEstateFlow(name)
								end
							end

							if UnlockableController.IsFeatureUnlocked(button.Name, Gamepasses.ESTATES_UNLOCKED) or button.Name == "001_Mansion" and UnlockableController.IsFeatureUnlocked(
								"Lot_" .. self.lotId,
								Gamepasses.ESTATES_UNLOCKED
							) then
								continueMansionOrEstateSelection(false)
								return
							end

							local v11

							if not (v8 == nil or not v8.Item) then
								v11 = ItemRegistry.GetItem(v8.Item, InteractableItem)
							end

							local v12 = self.houseType == "Mansions" and "EstatesMenu" or "HouseMenu"

							if v11 ~= nil and not v11:IsUnlockedClient() then
								v11:OnDenied(function(p)
									task.spawn(NotificationController.NotifyCenter, p, 3)
								end, v12, function()
									if self:reopen() then
										continueMansionOrEstateSelection(true)
									end
								end)
								return
							end

							local v13

							if v10 ~= nil then
								v13 = v10[button.Name]
							end

							GamepassController.Show(
								Gamepasses.ESTATES_UNLOCKED,
								button.Icon.Image,
								v12,
								nil,
								v13,
								nil,
								"House Inventory",
								button.Name,
								function()
									if self:reopen() then
										continueMansionOrEstateSelection(true)
									end
								end
							)
						end)

						if success ~= true then
							warn("[HouseMenu] mansion/estate click failed: " .. tostring(result))
						end

						v7 = false
						return
					elseif button:FindFirstChild("Penthouse") and self.lotId == 7 then
						if UnlockableController.IsFeatureUnlocked(button.Name, Gamepasses.PENTHOUSE) then
							if self.houseCooldownUIComponent:IsOnCooldown() then
								self:HouseCooldownWarning()

								if not UnlockableController.IsFeatureUnlocked(
									AdFeatures.VIP_HOUSE_COOLDOWN.id,
									Gamepasses.VIP
								) then
									GamepassController.Show(
										Gamepasses.VIP,
										button.Icon.Image,
										"penthouse cooldown",
										nil,
										AdFeatures.VIP_HOUSE_COOLDOWN,
										"Apartment cooldown timer active: buy VIP Gamepass to remove",
										"Apartment Inventory",
										button.Name,
										function()
											if not self.houseCooldownUIComponent:IsOnCooldown() and self:reopen() then
												self:SetSelection(button)
											end
										end
									)
								end
							else
								self:SetSelection(button)
							end
						else
							GamepassController.Show(
								Gamepasses.PENTHOUSE,
								button.Icon.Image,
								"penthouse",
								nil,
								assert(v10[button.Name], button.Name),
								nil,
								"Apartment Inventory",
								button.Name,
								function()
									if not self.houseCooldownUIComponent:IsOnCooldown() and self:reopen() then
										self:SetSelection(button)
									end
								end
							)
						end
					elseif self.houseType == "Motels" and button:FindFirstChild("VIP") then
						if UnlockableController.IsFeatureUnlocked(button.Name, Gamepasses.VIP) then
							if self.houseCooldownUIComponent:IsOnCooldown() then
								self:HouseCooldownWarning()

								if not UnlockableController.IsFeatureUnlocked(
									AdFeatures.VIP_HOUSE_COOLDOWN.id,
									Gamepasses.VIP
								) then
									GamepassController.Show(
										Gamepasses.VIP,
										nil,
										"house cooldown",
										nil,
										AdFeatures.VIP_HOUSE_COOLDOWN,
										"House cooldown timer active: buy VIP Gamepass to remove",
										self.houseType .. " Inventory",
										button.Name,
										function()
											if not self.houseCooldownUIComponent:IsOnCooldown() and self:reopen() then
												self:SetSelection(button)
											end
										end
									)
								end
							else
								self:SetSelection(button)
							end
						else
							GamepassController.Show(
								Gamepasses.VIP,
								button.Icon.Image,
								"vip house",
								nil,
								assert(v10[button.Name], button.Name),
								nil,
								self.houseType .. " Inventory",
								button.Name,
								function()
									if not self.houseCooldownUIComponent:IsOnCooldown() and self:reopen() then
										self:SetSelection(button)
									end
								end
							)
						end
					elseif self.houseType == "Landmarks" and button:FindFirstChild("RobuxPass") then
						if UnlockableController.IsFeatureUnlocked(button.Name, Gamepasses.PRISON_LANDMARK) then
							if self.houseCooldownUIComponent:IsOnCooldown() then
								self:HouseCooldownWarning()

								if not UnlockableController.IsFeatureUnlocked(
									AdFeatures.VIP_HOUSE_COOLDOWN.id,
									Gamepasses.VIP
								) then
									GamepassController.Show(
										Gamepasses.VIP,
										nil,
										"house cooldown",
										nil,
										AdFeatures.VIP_HOUSE_COOLDOWN,
										"House cooldown timer active: buy VIP Gamepass to remove",
										self.houseType .. " Inventory",
										button.Name,
										function()
											if not self.houseCooldownUIComponent:IsOnCooldown() and self:reopen() then
												self:SetSelection(button)
											end
										end
									)
								end
							else
								self:SetSelection(button)
							end
						else
							GamepassController.Show(
								Gamepasses.PRISON_LANDMARK,
								button.Icon.Image,
								"prison landmark",
								nil,
								v10[button.Name],
								nil,
								self.houseType .. " Inventory",
								button.Name,
								function()
									if not self.houseCooldownUIComponent:IsOnCooldown() and self:reopen() then
										self:SetSelection(button)
									end
								end
							)
						end
					elseif button:FindFirstChild("Silver") then
						if UnlockableController.IsFeatureUnlocked(button.Name, Gamepasses.PREMIUM) then
							if self.houseCooldownUIComponent:IsOnCooldown() then
								self:HouseCooldownWarning()

								if not UnlockableController.IsFeatureUnlocked(
									AdFeatures.VIP_HOUSE_COOLDOWN.id,
									Gamepasses.VIP
								) then
									GamepassController.Show(
										Gamepasses.VIP,
										nil,
										"house cooldown",
										nil,
										AdFeatures.VIP_HOUSE_COOLDOWN,
										"House cooldown timer active: buy VIP Gamepass to remove",
										self.houseType .. " Inventory",
										button.Name,
										function()
											if not self.houseCooldownUIComponent:IsOnCooldown() and self:reopen() then
												self:SetSelection(button)
											end
										end
									)
								end
							else
								self:SetSelection(button)
							end
						else
							GamepassController.Show(
								Gamepasses.PREMIUM,
								button.Icon.Image,
								"premium house",
								nil,
								v10[button.Name],
								nil,
								self.houseType .. " Inventory",
								button.Name,
								function()
									if not self.houseCooldownUIComponent:IsOnCooldown() and self:reopen() then
										self:SetSelection(button)
									end
								end
							)
						end
					elseif not button:FindFirstChild("Silver") then
						if v8 and v8.Item then
							local item = ItemRegistry.GetItem(v8.Item, InteractableItem)

							if not item:IsUnlockedClient() then
								item:OnDenied(function(p)
									task.spawn(NotificationController.NotifyCenter, p, 3)
								end, "HouseMenu", function()
									if not self.houseCooldownUIComponent:IsOnCooldown() and self:reopen() then
										self:SetSelection(button)
									end
								end)
								wait(0.2)
								v7 = false
								return
							end
						elseif v8 and v8.RequirementBehaviorData and not RequirementBehaviors.PassesRequirementCheck(
							localPlayer,
							v8.RequirementBehaviorData.Behavior,
							unpack(v8.RequirementBehaviorData.Arguments)
						) then
							local deniedMessage = RequirementBehaviors.GetDeniedMessage(
								localPlayer,
								v8.RequirementBehaviorData.Behavior,
								unpack(v8.RequirementBehaviorData.Arguments)
							)
							task.spawn(NotificationController.NotifyCenter, deniedMessage, 3)
							wait(0.2)
							v7 = false
							return
						end

						if self.houseCooldownUIComponent:IsOnCooldown() then
							self:HouseCooldownWarning()

							if not UnlockableController.IsFeatureUnlocked(
								AdFeatures.VIP_HOUSE_COOLDOWN.id,
								Gamepasses.VIP
							) then
								GamepassController.Show(
									Gamepasses.VIP,
									nil,
									"house cooldown",
									nil,
									AdFeatures.VIP_HOUSE_COOLDOWN,
									"House cooldown timer active: buy VIP Gamepass to remove",
									self.houseType .. " Inventory",
									button.Name,
									function()
										if not self.houseCooldownUIComponent:IsOnCooldown() and self:reopen() then
											self:SetSelection(button)
										end
									end
								)
							end
						else
							self:SetSelection(button)
						end
					end
				end
			end

			v7 = false
		end))
	end

	self._Janitor:Add(component.OnTargetModuleChanged:Connect(function(p: string)
		v6 = {}

		for _, v8 in component:GetConfigTable() do
			v6[v8.Name] = v8
		end

		if p == "Houses" then
			refreshEstatesSurfacingCatalog() -- equivalent call inferred; original call site unknown
		end
	end))
	self._Janitor:Add(component.Loaded:Connect(function()
		for _, child in scrollingFrame:GetChildren() do
			HouseButtonAdded(child)
		end

		maid:Add(scrollingFrame.ChildAdded:Connect(HouseButtonAdded))
	end))

	if component:IsLoaded() then
		for _, child in scrollingFrame:GetChildren() do
			child:SetAttribute("AttachedConnection", nil)
			HouseButtonAdded(child)
		end

		maid:Add(scrollingFrame.ChildAdded:Connect(HouseButtonAdded))
	end

	self._Janitor:Add(component.Added:Connect(function(items)
		for _, item in items do
			HouseButtonAdded(item)
		end
	end))
	self._Janitor:Add(component.Unloaded:Connect(function()
		maid:Cleanup()

		for _, child in scrollingFrame:GetChildren() do
			child:SetAttribute("AttachedConnection", nil)
		end
	end))
	self._Janitor:Add(component.CategoryChanged:Connect(function(p)
		instance.Catalog.Header.CategoryTabs.BackButton.Visible = p ~= nil
		updateBackActionBinding() -- equivalent call inferred; original call site unknown
		local v8 = v6[p]

		if v8 and v8.CategoryDisclaimer and (not v8.USOnlyDisclaimer or PlayerLocalizationController.GetCountryRegion() == "US") then
			self._disclaimerVisible = true
			instance.Catalog.Container.Disclaimer.Visible = true
			instance.Catalog.Container.Disclaimer.DisclaimerText.Text = v8.CategoryDisclaimer
		else
			self._disclaimerVisible = false
			instance.Catalog.Container.Disclaimer.Visible = false
		end
	end))
	self._Janitor:Add(instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if instance.Visible and backButton.Visible then
			bindBackAction() -- equivalent call inferred; original call site unknown
		else
			if not v5 then
				return
			end

			v5()
			v5 = nil
		end
	end))

	if instance.Visible and backButton.Visible then
		if not v5 then
			v5 = BackActionRouter.Bind(function()
				component:SetCategory(nil)
			end)
		end
	elseif v5 then
		v5()
		v5 = nil
	end

	self._Janitor:Add(self.OnHouseSelected:Connect(function(childName: string)
		local child = scrollingFrame:FindFirstChild(childName)

		if not child then
			return
		end

		child:AddTag("Checked")
	end))
	HouseMenuABTest.Apply(self.Instance)
end

function v:ShowSaves(p)
	self:dismissPendingHouseSelection()
	HouseSaveStates:WaitForInstance(self.Instance.SaveCatalog.Container.ScrollingFrame):andThen(function(object2)
		if p ~= nil then
			object2:SetSource(p)
		end

		object2:Refresh()
	end)
	self.Instance.Catalog.Visible = false
	self.Instance.SaveCatalog.Visible = true
end

function v:Stop()
	self._Janitor:Destroy()
end

return v