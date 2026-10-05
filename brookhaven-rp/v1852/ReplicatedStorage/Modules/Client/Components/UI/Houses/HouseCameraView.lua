local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "HouseCameraView"
})
local LotController = require(ReplicatedStorage.Modules.Client.Lot.LotController)
local CameraController = require(ReplicatedStorage.Modules.Client.UI.CameraController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local HousePanel = require(ReplicatedStorage.Modules.Client.Components.UI.Houses.HousePanel)
local PropertyRoot = require(ReplicatedStorage.Modules.Shared.Components.Housing.PropertyRoot)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local HouseInteriorConstants = require(ReplicatedStorage.Modules.Shared.Housing.HouseInteriorConstants)
local CameraLazyLoadUtil = require(ReplicatedStorage.Modules.Shared.World.CameraLazyLoadUtil)
local LazyLoadModelController = require(ReplicatedStorage.Modules.Client.LazyLoad.LazyLoadModelController)
local cframe = CFrame.Angles(0, 0, 3.141592653589793)

local function isDoorbellCamera(p)
	if p == nil then
		return false
	end

	local parent = p.Parent
	return parent ~= nil and parent:HasTag("CameraDoorbell")
end

local function getCameraViewCFrame(instance)
	local v2

	if instance == nil then
		v2 = false
	else
		local parent = instance.Parent

		if parent == nil then
			v2 = false
		else
			v2 = parent:HasTag("CameraDoorbell")
		end
	end

	if v2 then
		return instance.CFrame * cframe
	end

	return instance.CFrame
end

local function toCameraRef(instance)
	local v3

	if instance == nil then
		v3 = false
	else
		local parent = instance.Parent

		if parent == nil then
			v3 = false
		else
			v3 = parent:HasTag("CameraDoorbell")
		end
	end

	local cFrame

	if v3 then
		cFrame = instance.CFrame * cframe
	else
		cFrame = instance.CFrame
	end

	return {
		CFrame = cFrame,
		Instance = instance
	}
end

local function getDoorbellCamera(object)
	for _, descendant in object.Instance:GetDescendants() do
		if not descendant:HasTag("CameraDoorbell") then
			continue
		end

		local camera = descendant:FindFirstChild("Camera")

		if camera ~= nil and camera:IsA("BasePart") then
			return camera
		end
	end

	return nil
end

local function getMaxCameraIndex(items)
	local v2 = 0

	for k in items do
		if type(k) == "number" and v2 < k then
			v2 = k
		end
	end

	return v2
end

local function buildOrderedCameras(object, instance)
	local v2 = {}
	local v3 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function addCameraRef(p)
		if p == nil then
			return
		end

		local instance2 = p.Instance or p

		if v3[instance2] == true then
			return
		end

		v3[instance2] = true
		table.insert(v2, p)
	end

	if instance ~= nil then
		local v5

		if instance == nil then
			v5 = false
		else
			local parent = instance.Parent

			if parent == nil then
				v5 = false
			else
				v5 = parent:HasTag("CameraDoorbell")
			end
		end

		local cFrame

		if v5 then
			cFrame = instance.CFrame * cframe
		else
			cFrame = instance.CFrame
		end

		addCameraRef({
			CFrame = cFrame,
			Instance = instance
		}) -- equivalent call inferred; original call site unknown
	end

	local doorbellCamera = getDoorbellCamera(object)

	if doorbellCamera ~= nil then
		local v5

		if doorbellCamera == nil then
			v5 = false
		else
			local parent = doorbellCamera.Parent

			if parent == nil then
				v5 = false
			else
				v5 = parent:HasTag("CameraDoorbell")
			end
		end

		local cFrame

		if v5 then
			cFrame = doorbellCamera.CFrame * cframe
		else
			cFrame = doorbellCamera.CFrame
		end

		addCameraRef({
			CFrame = cFrame,
			Instance = doorbellCamera
		}) -- equivalent call inferred; original call site unknown
	end

	local cameras = object:GetCameras()
	local v4 = 0

	for k in cameras do
		if type(k) == "number" and v4 < k then
			v4 = k
		end
	end

	for i = 1, v4 do
		addCameraRef(cameras[i]) -- equivalent call inferred; original call site unknown
	end

	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function syncDoorbellCameraEffects(p)
	local CameraDoorbell = require(ReplicatedStorage.Modules.Client.Components.Housing.CameraDoorbell)
	local setSharedViewEffects = CameraDoorbell.SetSharedViewEffects
	local v2

	if p == nil then
		v2 = false
	else
		local parent = p.Parent

		if parent == nil then
			v2 = false
		else
			v2 = parent:HasTag("CameraDoorbell")
		end
	end

	setSharedViewEffects(v2)
end

function v:SetInteriorForced(flag: boolean)
	if flag then
		local currentLotId = LotController.GetCurrentLotId()

		if currentLotId == nil or currentLotId == self.forcedLotId then
			return
		end

		self.forcedLotId = currentLotId
		Remotes.fireServer(HouseInteriorConstants.ForceInterior, currentLotId, true)
	elseif self.forcedLotId ~= nil then
		Remotes.fireServer(HouseInteriorConstants.ForceInterior, self.forcedLotId, false)
		self.forcedLotId = nil
	end
end

function v:GetCameraIndex()
	return self.cameraIndex
end

function v:SetCameraIndex(cameraIndex: number)
	self.cameraIndex = cameraIndex
end

function v:GetActiveCameras()
	if self.overrideCameras ~= nil then
		return self.overrideCameras
	end

	if self.propertyRoot == nil then
		return {}
	end

	return (buildOrderedCameras(self.propertyRoot, nil))
end

function v:SyncDoorbellCameraEffects(p)
	syncDoorbellCameraEffects(p) -- equivalent call inferred; original call site unknown
end

function v:ApplyCameraAtIndex()
	local activeCameras = self:GetActiveCameras()
	local activeCamera = activeCameras[self:GetCameraIndex()]

	if activeCamera == nil then
		warn("No camera found")
		return
	end

	if activeCamera.Instance ~= nil and activeCamera.Instance.Parent ~= nil then
		local instance = activeCamera.Instance
		local v2

		if instance == nil then
			v2 = false
		else
			local parent = instance.Parent

			if parent == nil then
				v2 = false
			else
				v2 = parent:HasTag("CameraDoorbell")
			end
		end

		local cFrame

		if v2 then
			cFrame = instance.CFrame * cframe
		else
			cFrame = instance.CFrame
		end

		activeCamera.CFrame = cFrame
	end

	self.camera = activeCamera
	CameraController.SetCustomCamera(activeCamera.CFrame, activeCamera.Instance, nil, true)
	local lastCameraIndex = 0

	for k in activeCameras do
		if type(k) == "number" and lastCameraIndex < k then
			lastCameraIndex = k
		end
	end

	self.lastCameraIndex = lastCameraIndex
	self:SyncDoorbellCameraEffects(activeCamera.Instance)
	self:_syncForcedLazyLoadWindow()
end

function v:_syncForcedLazyLoadWindow()
	if self.lastCameraIndex == nil or self.propertyRoot == nil then
		return
	end

	LazyLoadModelController.SetForcedCameraWindow(CameraLazyLoadUtil.SOURCE_HOUSE, self:GetCameraIndex())
end

function v:NextCamera(p: number)
	self:SetCameraIndex(self:GetCameraIndex() + p)

	if not self.lastCameraIndex then
		return
	end

	if self:GetCameraIndex() > self.lastCameraIndex then
		self:SetCameraIndex(1)
	end

	if self:GetCameraIndex() < 1 then
		self:SetCameraIndex(self.lastCameraIndex)
	end

	self:ApplyCameraAtIndex()
end

local function failOpen(callback)
	if callback ~= nil then
		callback()
	end

	return false
end

function v.OpenWithCamera(instance, onOverrideExit)
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
		instance,
		"PropertyRoot",
		PropertyRoot
	)

	if waitForAncestorComponent == nil then
		if onOverrideExit ~= nil then
			onOverrideExit()
		end

		return false
	else
		local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")

		if playerGui == nil then
			if onOverrideExit ~= nil then
				onOverrideExit()
			end

			return false
		else
			local v2 = nil

			for _, v4 in v:GetAll() do
				if not v4.Instance:IsDescendantOf(playerGui) then
					continue
				end

				v2 = v4
				break
			end

			if v2 == nil then
				if onOverrideExit ~= nil then
					onOverrideExit()
				end

				return false
			else
				local waitForAncestorComponent2 = ComponentUtil.FindAndWaitForAncestorComponent(
					v2.Instance,
					"HousePanel",
					HousePanel
				)

				if waitForAncestorComponent2 == nil then
					if onOverrideExit ~= nil then
						onOverrideExit()
					end

					return false
				else
					v2.propertyRoot = waitForAncestorComponent
					v2.overrideCameras = buildOrderedCameras(waitForAncestorComponent, instance)
					v2.onOverrideExit = onOverrideExit
					v2:SetCameraIndex(1)

					if v2.Instance.Visible then
						v2:ApplyCameraAtIndex()
					else
						PanelController.ToggleGroup("HousePanels", false)
						waitForAncestorComponent2:SetCurrentOpenPanel(v2.Instance)
					end

					return true
				end
			end
		end
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
	self.overrideCameras = nil
	self.onOverrideExit = nil
	self.forcedLotId = nil
end

function v:Start()
	self:SetCameraIndex(1)
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if self.Instance.Visible then
			self:SetInteriorForced(true)

			if self.overrideCameras == nil then
				self.propertyRoot = LotController.GetCurrentHouse()

				if not self.propertyRoot then
					return
				end
			end

			local activeCameras = self:GetActiveCameras()

			if activeCameras and activeCameras[self:GetCameraIndex()] ~= nil then
				self:ApplyCameraAtIndex()
			else
				warn("No reference cameras found")
			end
		else
			self.overrideCameras = nil
			self:SetInteriorForced(false)
			LazyLoadModelController.ClearForcedCameraWindow()
			CameraController.SetDefaultCamera()
			self:SyncDoorbellCameraEffects(nil)
			local onOverrideExit = self.onOverrideExit
			self.onOverrideExit = nil

			if onOverrideExit ~= nil then
				onOverrideExit()
			end
		end
	end))
end

function v:Stop()
	self:SetInteriorForced(false)
	LazyLoadModelController.ClearForcedCameraWindow()
	self._Janitor:Destroy()
end

return v