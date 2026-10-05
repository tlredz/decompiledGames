local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local BackActionRouter = require(ReplicatedStorage.Modules.Client.UI.BackActionRouter)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local v = false
local v2 = false
local v3 = false
local v4 = false
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local ZipLineConstants = require(ReplicatedStorage.Modules.Shared.World.ZipLineConstants)
local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
local EstateSurfacingTelemetry = require(ReplicatedStorage.Modules.Client.Houses.ABTests.EstateSurfacingTelemetry)
local v5 = Component.new({
	Tag = "HouseViewCamera"
})
local v6 = {
	"POI",
	"House",
	"Estate",
	"Land",
	"Motel",
	"Apartment",
	"Landmark"
}
local v7 = {
	Island = 37,
	North = 33,
	South = 34
}
local value = Enum.ContextActionPriority.High.Value
local folder = nil

local function buildAltCameraList(child)
	local result = {}

	for _, childName in ipairs(v6) do
		local child2 = child:FindFirstChild(childName)

		if not child2 then
			continue
		end

		local children = child2:GetChildren()
		table.sort(children, function(a, b)
			return (tonumber(a.Name) or 0) < (tonumber(b.Name) or 0)
		end)

		for _, v8 in ipairs(children) do
			table.insert(result, v8)
		end
	end

	return result
end

local function plotCameraHasAngle(instance)
	return instance:FindFirstChild("Angle") ~= nil
end

local function isEstatePlotCamera(instance)
	local estatePass = instance:FindFirstChild("EstatePass")
	return estatePass ~= nil and estatePass:IsA("BoolValue") and estatePass.Value == true
end

function v5.ResolveEstateRegionPlotCamera(childName: string)
	local v8 = v7[childName]

	if v8 == nil then
		return nil
	end

	local workspaceCom = workspace:FindFirstChild("WorkspaceCom")

	if workspaceCom == nil then
		return nil
	end

	local _001_MapCameras_Alt = workspaceCom:FindFirstChild("001_MapCameras_Alt") or workspaceCom:FindFirstChild("001_MapCameras")

	if _001_MapCameras_Alt == nil then
		return nil
	end

	local estate = _001_MapCameras_Alt:FindFirstChild("Estate")

	if estate ~= nil then
		local folder2 = estate:FindFirstChild(childName)

		if folder2 ~= nil then
			if folder2:FindFirstChild("Angle") ~= nil then
				local estatePass = folder2:FindFirstChild("EstatePass")
				local v9

				if estatePass == nil then
					v9 = false
				else
					v9 = estatePass:IsA("BoolValue") and estatePass.Value == true
				end

				if v9 then
					return folder2
				end
			end

			for _, descendant in folder2:GetDescendants() do
				if descendant:FindFirstChild("Angle") == nil then
					continue
				end

				local estatePass = descendant:FindFirstChild("EstatePass")
				local v9

				if estatePass == nil then
					v9 = false
				else
					v9 = estatePass:IsA("BoolValue") and estatePass.Value == true
				end

				if v9 then
					return descendant
				end
			end

			if folder2:FindFirstChild("Angle") ~= nil then
				return folder2
			end
		end
	end

	for _, stringValue in _001_MapCameras_Alt:GetDescendants() do
		if not (stringValue:IsA("StringValue") and stringValue.Value == "House# " .. v8) then
			continue
		end

		local parent = stringValue.Parent

		if not (parent ~= nil and parent:FindFirstChild("Angle") ~= nil) then
			continue
		end

		local estatePass = parent:FindFirstChild("EstatePass")
		local v9

		if estatePass == nil then
			v9 = false
		else
			v9 = estatePass:IsA("BoolValue") and estatePass.Value == true
		end

		if v9 then
			return parent
		end
	end

	return nil
end

function v5:Construct()
	self._Janitor = Janitor.new()
	self.OnVisibleChanged = Signal.new()
	self.OnCameraIndexChanged = Signal.new()
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v = PanelController
	local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
	v2 = NotificationController
	local CameraController = require(ReplicatedStorage.Modules.Client.UI.CameraController)
	v3 = CameraController
	local EventSignupConfig = require(ReplicatedStorage.Modules.Shared.DB.EventSignup.EventSignupConfig)
	v4 = EventSignupConfig
end

function v5:GetCameraCount(instance)
	if self._isAltMapCameras and self._altCameraList then
		return #self._altCameraList
	end

	return #instance:GetChildren()
end

function v5:GetCameraAtIndex(p2, p3)
	if self._isAltMapCameras and self._altCameraList then
		return self._altCameraList[p3]
	end

	return p2["House" .. p3]
end

function v5:GetStartIndexForCategory(p2)
	if not (self._isAltMapCameras and self._mapCameras) then
		return nil
	end

	local total = 1

	for _, childName in ipairs(v6) do
		if childName == p2 then
			return total
		end

		local child = self._mapCameras:FindFirstChild(childName)

		if child then
			total += #child:GetChildren()
		end
	end

	return nil
end

function v5:JumpToCategory(p)
	local startIndexForCategory = self:GetStartIndexForCategory(p)

	if startIndexForCategory and self._mapCameras then
		self.currentCameraIndex = startIndexForCategory
		self:OpenHouseCam(self._mapCameras)
	end
end

function v5:JumpToFirstEstateCamera()
	if not self._mapCameras then
		return
	end

	if self._isAltMapCameras then
		self:JumpToCategory("Estate")
		return
	end

	local _mapCameras = self._mapCameras

	for i = 1, self:GetCameraCount(_mapCameras) do
		local cameraAtIndex = self:GetCameraAtIndex(_mapCameras, i)

		if cameraAtIndex == nil then
			continue
		end

		local estatePass = cameraAtIndex:FindFirstChild("EstatePass")

		if not (estatePass ~= nil and estatePass:IsA("BoolValue") and estatePass.Value == true) then
			continue
		end

		self.currentCameraIndex = i
		self:OpenHouseCam(_mapCameras)
		break
	end
end

function v5:GetCurrentIndexCategory()
	if not (self._isAltMapCameras and self._mapCameras and self.currentCameraIndex) then
		return nil
	end

	local currentCameraIndex = self.currentCameraIndex
	local total = 1

	for _, childName in ipairs(v6) do
		local child = self._mapCameras:FindFirstChild(childName)

		if not child then
			continue
		end

		local count = #child:GetChildren()

		if total <= currentCameraIndex and currentCameraIndex < total + count then
			return childName
		else
			total += count
		end
	end

	return nil
end

function v5:OpenHouseCam(p)
	self:UpdateHouseInfo(p)
	local cameraAtIndex = self:GetCameraAtIndex(p, self.currentCameraIndex)
	local value2 = cameraAtIndex.Angle.Value
	local v8 = CFrame.new(cameraAtIndex.Position) * CFrame.Angles(0, value2, 0)
	v3.SetCustomCamera(v8, cameraAtIndex)
	local value3 = cameraAtIndex.EstatePass.Value
	local value4 = cameraAtIndex.HousePass.Value
	self.OnCameraIndexChanged:Fire(self.currentCameraIndex, value3, value4, not (value3 or value4))
end

function v5:CloseHouseCam()
	v3.SetDefaultCamera()
end

function v5:SetLastCategoryButtonClicked(lastCategoryButtonClicked)
	self.lastCategoryButtonClicked = lastCategoryButtonClicked
end

function v5:UpdateCameraIndex(p, p2)
	self.currentCameraIndex += p2
	local cameraCount = self:GetCameraCount(p)

	if self.currentCameraIndex < 1 then
		self.currentCameraIndex = cameraCount
	elseif cameraCount < self.currentCameraIndex then
		self.currentCameraIndex = 1
	end

	self:OpenHouseCam(p)
end

function v5:UpdateHouseInfo(p)
	local cameraAtIndex = self:GetCameraAtIndex(p, self.currentCameraIndex)
	local text = cameraAtIndex.Number.Value
	local value3 = cameraAtIndex.HouseOwned.Value
	local value4 = cameraAtIndex.HousePass.Value
	local value5 = cameraAtIndex.EstatePass.Value
	local value6 = cameraAtIndex:findFirstChild("IsPOI") and cameraAtIndex.IsPOI.Value
	local text2 = cameraAtIndex.RPInfo.Value

	if self._isAltMapCameras then
		text = cameraAtIndex.Parent.Name .. " #" .. cameraAtIndex.Name
		local gamepassIcon = self.Instance.Frame.GamepassIcon

		if gamepassIcon then
			gamepassIcon.Image = value5 and "rbxassetid://10839391754" or value4 and "rbxassetid://6099855366" or ""
		end
	end

	local frame = self.Instance.Frame
	frame.Teleport.RPInfo.Text = text2
	frame.Teleport.HouseNumber.Text = text
	frame.Teleport.Vaccant.Text = value3 and "Owned" or "Vacant"

	if value6 then
		frame.Teleport.Vaccant.Text = v4.GetConfig().plotCameraText
	end

	local visible

	if value5 then
		visible = value5 and not GamepassController.IsOwned(Gamepasses.ESTATES_UNLOCKED)
	else
		visible = value4 and not GamepassController.IsOwned(Gamepasses.LAND_UNLOCKED)
	end

	local lock = self.Instance.Frame.Lock

	if self._isAltMapCameras then
		visible = false
	end

	lock.Visible = visible
end

function v5:TeleportPlayerToCamera(p)
	local localPlayer = Players.LocalPlayer
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

	if character == nil then
		return
	end

	local position = character:GetPivot().Position
	local cameraAtIndex = self:GetCameraAtIndex(p, self.currentCameraIndex)

	if not v5.TeleportPlayerToCameraStatic(cameraAtIndex) then
		return
	end

	local estatePass = cameraAtIndex:FindFirstChild("EstatePass")

	if estatePass == nil or not estatePass:IsA("BoolValue") or estatePass.Value ~= true or not EstateSurfacingTelemetry.isActive() then
		TelemetryController.SendClientInteraction("teleportLot", {
			lotId = self.currentCameraIndex,
			startLotId = self.startCameraIndex,
			lastCategoryButtonClicked = self.lastCategoryButtonClicked,
			playerLocaition = position
		})
	else
		local estateRegionFromCamera = EstateSurfacingTelemetry.getEstateRegionFromCamera(cameraAtIndex)

		if estateRegionFromCamera ~= nil then
			local pendingHouseIdFromAttribute = EstateSurfacingTelemetry.getPendingHouseIdFromAttribute(self.Instance)
			local houseOwned = cameraAtIndex:FindFirstChild("HouseOwned")
			local v8

			if houseOwned == nil then
				v8 = false
			else
				v8 = houseOwned:IsA("BoolValue") and houseOwned.Value == true
			end

			EstateSurfacingTelemetry.sendTeleportPrompt(pendingHouseIdFromAttribute, estateRegionFromCamera, not v8)
		end
	end

	local v8, v9 = ABTest.GetExperimentVariable("console-controls", "plotUi"):timeout(7):await()

	if v8 and v9 then
		Platform.EndSelection()
	end

	self:CloseHouseCam()
end

function v5.TeleportPlayerToCameraStatic(p)
	local localPlayer = Players.LocalPlayer
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

	if not p then
		v2.Notify("Unable to find teleport location")
		return false
	end

	if not character then
		v2.Notify("Unable to find character")
		return false
	end

	local humanoid = character:WaitForChild("Humanoid")
	local leftHand = character:FindFirstChild("LeftHand")
	local child = character:FindFirstChild(localPlayer.Name .. "Horse")

	if humanoid.Sit then
		v2.Notify("Cannot teleport while sitting")
		return false
	end

	if not leftHand then
		v2.Notify("Unable to perform action")
		return false
	end

	if child then
		v2.Notify("Cannot teleport while mounted")
		return false
	end

	if localPlayer:HasTag(ZipLineConstants.HANDLE_TAG) then
		v2.Notify("Cannot teleport while on a zip line")
		return false
	end

	if leftHand:FindFirstChild("HandFire") then
		v2.Notify("Quantum entanglement error...")
		return false
	end

	v.ToggleGroup("MainView", false)
	local value2 = p.Angle.Value
	local cFrame = CFrame.new(p.Position) * CFrame.Angles(0, value2, 0)
	character.UpperTorso.CFrame = cFrame
	return true
end

function v5.TeleportLot(p)
	if folder == nil then
		return
	end

	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant.className == "StringValue" and descendant.Value == "House# " .. p then
			return v5.TeleportPlayerToCameraStatic(descendant.Parent)
		end
	end

	error("invalid lot " .. p)
end

function v5:Start()
	self.showPOICamera = false
	self.consoleControlsEnabled = true
	local v8, v9 = ABTest.GetExperimentVariables("show-olympics"):await()

	if v8 and v9 and v9.showPOIPlotCam then
		self.showPOICamera = v9.showPOIPlotCam
	elseif v9 and v9.showPOIPlotCam == nil then
		warn("HouseViewCamera.Start: ABTest show-poi is not set, defaulting to false")
	end

	local v10, consoleControlsEnabled = ABTest.GetExperimentVariable("console-controls", "enabled"):timeout(7):await()

	if v10 then
		self.consoleControlsEnabled = consoleControlsEnabled
	end

	local v12 = "001_MapCameras"
	local categoryButtons = self.Instance:FindFirstChild("CategoryButtons")
	categoryButtons.Visible = false
	local v13, v14 = ABTest.GetExperimentVariables("house-cameras-rework"):timeout(5):await()

	if v13 then
		if v14.cameraEnabled then
			self._isAltMapCameras = true
			local frame = self.Instance.Frame
			frame.Teleport.Vaccant.Position = UDim2.new(0.4, 0, 0.331, 0)
			frame.Teleport.Vaccant.TextXAlignment = Enum.TextXAlignment.Left
			self.Instance.Frame.Position = UDim2.new(0.247, 0, 0.25, 0)
			v12 = "001_MapCameras_Alt"
		end

		categoryButtons.Visible = v14.buttonsEnabled and true or false
	end

	local child = game.Workspace.WorkspaceCom:WaitForChild(v12)

	if not child then
		error("HouseViewCamera.Start: Map cameras folder not found")
	end

	self._mapCameras = child
	folder = child

	if self._isAltMapCameras then
		self._altCameraList = buildAltCameraList(child)
	else
		self._altCameraList = nil
	end

	if not self.showPOICamera then
		if self._isAltMapCameras and self._altCameraList then
			for _, v15 in ipairs(self._altCameraList) do
				if v15:GetAttribute("camera_type") == "POI" then
					v15:Destroy()
				end
			end

			self._altCameraList = buildAltCameraList(child)
		else
			for _, child2 in child:GetChildren() do
				if child2:GetAttribute("camera_type") == "POI" then
					child2:Destroy()
				end
			end
		end
	end

	self.startCameraIndex = nil
	local v15 = nil
	local flag = false

	local function unbindBackAction()
		if not v15 then
			return
		end

		v15()
		v15 = nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function bindBackAction()
		if v15 then
			return
		end

		v15 = BackActionRouter.Bind(function()
			self.Instance.Visible = false
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateBackActionBinding()
		if self.Instance.Visible then
			bindBackAction() -- equivalent call inferred; original call site unknown
		else
			if not v15 then
				return
			end

			v15()
			v15 = nil
		end
	end

	self._Janitor:Add(unbindBackAction)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function unbindShoulderActions()
		if not flag then
			return
		end

		ContextActionService:UnbindAction("HouseViewCameraPreviousHouse")
		ContextActionService:UnbindAction("HouseViewCameraNextHouse")
		flag = false
	end

	local function bindShoulderActions()
		if flag then
			return
		end

		ContextActionService:BindActionAtPriority("HouseViewCameraPreviousHouse", function(_, p)
			if p ~= Enum.UserInputState.Begin or not self.Instance.Visible then
				return Enum.ContextActionResult.Pass
			end

			self:UpdateCameraIndex(child, -1)
			return Enum.ContextActionResult.Sink
		end, false, value, Enum.KeyCode.ButtonL1)
		ContextActionService:BindActionAtPriority("HouseViewCameraNextHouse", function(_, p)
			if p ~= Enum.UserInputState.Begin or not self.Instance.Visible then
				return Enum.ContextActionResult.Pass
			end

			self:UpdateCameraIndex(child, 1)
			return Enum.ContextActionResult.Sink
		end, false, value, Enum.KeyCode.ButtonR1)
		flag = true
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateShoulderActionBinding()
		if self.Instance.Visible and self.consoleControlsEnabled then
			bindShoulderActions()
			return
		end

		unbindShoulderActions() -- equivalent call inferred; original call site unknown
	end

	self._Janitor:Add(unbindShoulderActions)
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if self.Instance.Visible and not v.IsOpen("NoResetGUIHandler", "AvatarEditorMenu") then
			self.currentCameraIndex = 34
			local v16 = VehicleController.IsPlayerDriving() and VehicleController.GetVehiclePanel()

			if v16 then
				v16.Instance.Visible = false
			end

			if LotUtil.GetPlayerOwnedLotNumber(Players.LocalPlayer) and not VehicleController.IsPlayerDriving() then
				v.Close("MainGUIHandler", "HouseControlPanel")
			end

			if VehicleController.GetCurrentNonMotorVehicle() then
				v.Close("MainGUIHandler", "NoMotorVehicleControl")
			end

			self:SetLastCategoryButtonClicked(nil)
			self.currentCameraIndex = 1
			self:OpenHouseCam(child)
		else
			if LotUtil.GetPlayerOwnedLotNumber(Players.LocalPlayer) and not VehicleController.IsPlayerDriving() then
				v.Open("MainGUIHandler", "HouseControlPanel")
			end

			local v16 = VehicleController.IsPlayerDriving() and VehicleController.GetVehiclePanel()

			if v16 then
				v16.Instance.Visible = true
			end

			if VehicleController.GetCurrentNonMotorVehicle() then
				v.Open("MainGUIHandler", "NoMotorVehicleControl")
			end

			self:CloseHouseCam()
		end

		updateBackActionBinding() -- equivalent call inferred; original call site unknown
		updateShoulderActionBinding() -- equivalent call inferred; original call site unknown
	end))

	if self.Instance.Visible then
		if not v15 then
			v15 = BackActionRouter.Bind(function()
				self.Instance.Visible = false
			end)
		end
	elseif v15 then
		v15()
		v15 = nil
	end

	if self.Instance.Visible and self.consoleControlsEnabled then
		bindShoulderActions()
	else
		unbindShoulderActions() -- equivalent call inferred; original call site unknown
	end

	local frame = self.Instance:WaitForChild("Frame")
	local left = frame:WaitForChild("Left")
	local right = frame:WaitForChild("Right")
	local teleport = frame:WaitForChild("Teleport")
	local invisibleHouseAreaTeleport = frame:WaitForChild("InvisibleHouseAreaTeleport")
	self._Janitor:Add(left.Activated:Connect(function()
		self:UpdateCameraIndex(child, -1)
	end))
	self._Janitor:Add(right.Activated:Connect(function()
		self:UpdateCameraIndex(child, 1)
	end))
	self._Janitor:Add(teleport.Activated:Connect(function()
		self:TeleportPlayerToCamera(child)
	end))
	self._Janitor:Add(invisibleHouseAreaTeleport.Activated:Connect(function()
		self:TeleportPlayerToCamera(child)
	end))
	Remotes.onInvoke("HouseCameraTeleport", v5.TeleportLot)
	local localPlayer = Players.LocalPlayer
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local humanoid

	if character then
		humanoid = character:FindFirstChild("Humanoid")
	end

	if humanoid then
		self._Janitor:Add(humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
			self.Instance.Visible = false
		end))
		self._Janitor:Add(humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
			self.Instance.Visible = false
		end))
	end
end

function v5:Stop()
	self._Janitor:Destroy()
end

return v5