local LotController = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local Signal = require(ReplicatedStorage.Packages.Signal)
local localPlayer = Players.LocalPlayer
local PlayerBagUtil = require(ReplicatedStorage.Modules.Shared.PlayerData.PlayerBagUtil)
require(ReplicatedStorage.Modules.Shared.Housing.PropertyUtil)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local LandmarkTransferConfirmation = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.LandmarkTransferConfirmation)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local notifyeverywhere = true
local v = nil
LotController.PropertyChangedSignal = Signal.new()
LotController.CooldownStartedSignal = Signal.new()

local function onRequestPermissions(p: number, flag: boolean)
	local propertyRoot = LotUtil.GetPropertyRoot(p)

	if propertyRoot == nil then
		return
	end

	propertyRoot:SetAnimationPermissions(flag)
end

local function onRequestClearCooldowns()
	local playerGui = localPlayer:FindFirstChild("PlayerGui")

	if playerGui == nil then
		return
	end

	local noResetGUIHandler = playerGui:FindFirstChild("NoResetGUIHandler")

	if noResetGUIHandler == nil then
		return
	end

	local localTimerHouse = noResetGUIHandler:FindFirstChild("LocalTimerHouse")

	if localTimerHouse == nil then
		return
	end

	localTimerHouse.Timer.Value = 0
	localTimerHouse.TimerMotel.Value = 0
end

local function onRequestLandmarkClaimed(_: string) end

local function onRequestLandmarkRevoked(p: string, p2: number)
	if notifyeverywhere then
		NotificationController.NotifyCenter(`{p} is available to be claimed!`, 5)
		return
	end

	local propertyRoot = LotUtil.GetPropertyRoot(p2)

	if propertyRoot == nil then
		return
	end

	local landmarkArea = propertyRoot.Instance.LandmarkArea
	local region = Region3.new(
		landmarkArea.Position - landmarkArea.Size / 2,
		landmarkArea.Position + landmarkArea.Size / 2
	)
	local partsInRegion3 = game.Workspace:FindPartsInRegion3WithWhiteList(region, { localPlayer.Character }, 1)

	for _, v2 in partsInRegion3 do
		if v2:FindFirstAncestor(localPlayer.Name) then
			NotificationController.NotifyCenter(`Owner has left! {p} is available to be claimed!`, 5)
		end
	end
end

local function onRequestCooldownStarted()
	LotController.CooldownStartedSignal:Fire()
end

local function onPromptLandmarkSwap(p, p2: string, p3: string)
	if LandmarkTransferConfirmation.IsHiddenForSession() or PanelController.IsOpen(
		"MainGUIHandler",
		"LandmarkTransferConfirmation"
	) then
		return
	end

	LandmarkTransferConfirmation.SetPending(p, p2, p3)
	PanelController.Open("MainGUIHandler", "LandmarkTransferConfirmation")
end

local result = {}

local function mapLotsByType()
	local _001_Lots = workspace:FindFirstChild("001_Lots")

	if not _001_Lots then
		return
	end

	for _, model in _001_Lots:GetChildren() do
		if not model:IsA("Model") then
			continue
		end

		local type = model:GetAttribute("Type")
		local ID = model:GetAttribute("ID")

		if type then
			if ID then
				result[type] = result[type] or {}
				result[type][ID] = model
			else
				warn("Lot has no id attribute")
				print(model)
			end
		else
			warn("Lot has no type attribute")
			print(model)
		end
	end
end

local function renameAllLots()
	for _, v2 in result do
		for k, v3 in v2 do
			local number = v3:FindFirstChild("Number")

			if number then
				local surfaceGUI = number:FindFirstChild("SurfaceGUI")

				if surfaceGUI then
					local frame = surfaceGUI:FindFirstChild("Frame")

					if frame then
						local textLabel = frame:FindFirstChild("TextLabel")

						if textLabel then
							textLabel.Text = " #" .. k
						else
							warn("Lot has no text label child")
							print(v3)
						end
					else
						warn("Lot has no frame child")
						print(v3)
					end
				else
					warn("Lot has no surface gui child")
					print(v3)
				end
			else
				warn("Lot has no number child")
				print(v3)
			end
		end
	end
end

function LotController.FrameworkStart()
	Remotes.connect("Property:Permissions", onRequestPermissions)
	Remotes.connect("Lot:ClearBuildCooldowns", onRequestClearCooldowns)
	Remotes.connect("Lot:LandmarkClaimed", onRequestLandmarkClaimed)
	Remotes.connect("Lot:LandmarkRevoked", onRequestLandmarkRevoked)
	Remotes.connect("Lot:CooldownStarted", onRequestCooldownStarted)
	Remotes.connect("Lot:PromptLandmarkSwap", onPromptLandmarkSwap)
	mapLotsByType()
	local v2, v3 = ABTest.GetExperimentVariables("power-plant-notification", "notify-everywhere"):timeout(3):await()

	if v2 then
		notifyeverywhere = v3["notify-everywhere"] or false
	end

	local v4, v5 = ABTest.GetExperimentVariable("house-cameras-rework", "cameraEnabled"):timeout(5):await()

	if v4 and v5 then
		renameAllLots()
	end
end

function LotController.GetLotsByType(p: string)
	return result[p] or {}
end

function LotController.GetLotsMap()
	return result
end

function LotController.TryClaim(p: number)
	return Remotes.invokeServer("Lot:Claim", p)
end

function LotController.TryBuildProperty(p: number, p2: string, p3)
	local v2, v3, v4 = Remotes.invokeServer("Lot:BuildProperty", p, p2, p3)

	if v2 then
		v = p2
		LotController.PropertyChangedSignal:Fire(p, p2)
	end

	return v2, v3, v4
end

function LotController.Unclaim()
	v = nil
	LotController.PropertyChangedSignal:Fire(nil, nil)
	Remotes.fireServer("Lot:Unclaim")
end

function LotController.GetCurrentLotId()
	local value = PlayerBagUtil.GetPlayerBagInstance(localPlayer, "HouseNumber").Value
	return value or nil
end

function LotController.GetCurrentHouse()
	local currentLotId = LotController.GetCurrentLotId()

	if currentLotId == nil then
		return nil
	end

	return LotUtil.GetPropertyRoot(currentLotId)
end

function LotController.GetCurrentPropertyId()
	return v
end

return LotController