local class = {}
class.__index = class
local v = {
	"CameraMinZoomDistance",
	"CameraMaxZoomDistance",
	"CameraMode",
	"DevCameraOcclusionMode",
	"DevComputerCameraMode",
	"DevTouchCameraMode",
	"DevComputerMovementMode",
	"DevTouchMovementMode",
	"DevEnableMouseLock"
}
local v2 = {
	"ComputerCameraMovementMode",
	"ComputerMovementMode",
	"ControlMode",
	"GamepadCameraSensitivity",
	"MouseSensitivity",
	"RotationType",
	"TouchCameraMovementMode",
	"TouchMovementMode"
}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local commonUtils = script.Parent:WaitForChild("CommonUtils")
local ConnectionUtil = require(commonUtils:WaitForChild("ConnectionUtil"))
local FlagUtil = require(commonUtils:WaitForChild("FlagUtil"))
local CameraUtils = require(script:WaitForChild("CameraUtils"))
local CameraInput = require(script:WaitForChild("CameraInput"))
local ClassicCamera = require(script:WaitForChild("ClassicCamera"))
local OrbitalCamera = require(script:WaitForChild("OrbitalCamera"))
local LegacyCamera = require(script:WaitForChild("LegacyCamera"))
local VehicleCamera = require(script:WaitForChild("VehicleCamera"))
local VRCamera = require(script:WaitForChild("VRCamera"))
local VRVehicleCamera = require(script:WaitForChild("VRVehicleCamera"))
local Invisicam = require(script:WaitForChild("Invisicam"))
local Poppercam = require(script:WaitForChild("Poppercam"))
local TransparencyController = require(script:WaitForChild("TransparencyController"))
local MouseLockController = require(script:WaitForChild("MouseLockController"))
local v3 = {}
local activeOcclusionModules = {}

if not Players.LocalPlayer then
	return {}
end

assert(Players.LocalPlayer, "Strict typing check")
local playerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts")
playerScripts:RegisterTouchCameraMovementMode(Enum.TouchCameraMovementMode.Default)
playerScripts:RegisterTouchCameraMovementMode(Enum.TouchCameraMovementMode.Follow)
playerScripts:RegisterTouchCameraMovementMode(Enum.TouchCameraMovementMode.Classic)
playerScripts:RegisterComputerCameraMovementMode(Enum.ComputerCameraMovementMode.Default)
playerScripts:RegisterComputerCameraMovementMode(Enum.ComputerCameraMovementMode.Follow)
playerScripts:RegisterComputerCameraMovementMode(Enum.ComputerCameraMovementMode.Classic)
playerScripts:RegisterComputerCameraMovementMode(Enum.ComputerCameraMovementMode.CameraToggle)
local userFlag = FlagUtil.getUserFlag("UserPlayerConnectionMemoryLeak")
local userFlag2 = FlagUtil.getUserFlag("UserPSFixCameraControllerReset")

function class.new()
	local v4 = {
		activeTransparencyController = TransparencyController.new(),
		connectionUtil = 0
	}
	local connectionUtil

	if userFlag then
		connectionUtil = ConnectionUtil.new()
	end

	v4.connectionUtil = connectionUtil
	local object = setmetatable(v4, class)
	object.activeCameraController = nil
	object.activeOcclusionModule = nil
	object.activeMouseLockController = nil
	object.currentComputerCameraMovementMode = nil
	object.cameraSubjectChangedConn = nil
	object.cameraTypeChangedConn = nil

	for _, v6 in pairs(Players:GetPlayers()) do
		object:OnPlayerAdded(v6)
	end

	Players.PlayerAdded:Connect(function(player)
		object:OnPlayerAdded(player)
	end)

	if userFlag then
		Players.PlayerRemoving:Connect(function(player)
			object:OnPlayerRemoving(player)
		end)
	end

	object.activeTransparencyController:Enable(true)
	object.activeMouseLockController = MouseLockController.new()
	assert(object.activeMouseLockController, "Strict typing check")
	local bindableToggleEvent = object.activeMouseLockController:GetBindableToggleEvent()

	if bindableToggleEvent then
		bindableToggleEvent:Connect(function()
			object:OnMouseLockToggled()
		end)
	end

	object:ActivateCameraController()
	object:ActivateOcclusionModule(Players.LocalPlayer.DevCameraOcclusionMode)
	object:OnCurrentCameraChanged()
	RunService:BindToRenderStep("cameraRenderUpdate", Enum.RenderPriority.Camera.Value, function(p)
		object:Update(p)
	end)

	for _, propertyName in pairs(v) do
		local v6 = propertyName
		Players.LocalPlayer:GetPropertyChangedSignal(propertyName):Connect(function()
			object:OnLocalPlayerCameraPropertyChanged(v6)
		end)
	end

	for _, propertyName in pairs(v2) do
		local v6 = propertyName
		UserGameSettings:GetPropertyChangedSignal(propertyName):Connect(function()
			object:OnUserGameSettingsPropertyChanged(v6)
		end)
	end

	game.Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		object:OnCurrentCameraChanged()
	end)
	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		object:OnPreferredInputChanged()
	end)
	return object
end

function class:GetCameraMovementModeFromSettings()
	if Players.LocalPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
		return CameraUtils.ConvertCameraModeEnumToStandard(Enum.ComputerCameraMovementMode.Classic)
	end

	local selected, v5

	if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
		selected = CameraUtils.ConvertCameraModeEnumToStandard(Players.LocalPlayer.DevTouchCameraMode)
		v5 = CameraUtils.ConvertCameraModeEnumToStandard(UserGameSettings.TouchCameraMovementMode)
	else
		selected = CameraUtils.ConvertCameraModeEnumToStandard(Players.LocalPlayer.DevComputerCameraMode)
		v5 = CameraUtils.ConvertCameraModeEnumToStandard(UserGameSettings.ComputerCameraMovementMode)
	end

	if selected == Enum.DevComputerCameraMovementMode.UserChoice then
		return v5
	end

	return selected
end

function class:ActivateOcclusionModule(occlusionMode)
	local v4

	if occlusionMode == Enum.DevCameraOcclusionMode.Zoom then
		v4 = Poppercam
	elseif occlusionMode == Enum.DevCameraOcclusionMode.Invisicam then
		v4 = Invisicam
	else
		warn("CameraScript ActivateOcclusionModule called with unsupported mode")
		return
	end

	self.occlusionMode = occlusionMode

	if self.activeOcclusionModule and self.activeOcclusionModule:GetOcclusionMode() == occlusionMode then
		if not self.activeOcclusionModule:GetEnabled() then
			self.activeOcclusionModule:Enable(true)
		end
	else
		local activeOcclusionModule = self.activeOcclusionModule
		self.activeOcclusionModule = activeOcclusionModules[v4]

		if not self.activeOcclusionModule then
			self.activeOcclusionModule = v4.new()

			if self.activeOcclusionModule then
				activeOcclusionModules[v4] = self.activeOcclusionModule
			end
		end

		if self.activeOcclusionModule then
			if self.activeOcclusionModule:GetOcclusionMode() ~= occlusionMode then
				warn(
					"CameraScript ActivateOcclusionModule mismatch: ",
					self.activeOcclusionModule:GetOcclusionMode(),
					"~=",
					occlusionMode
				)
			end

			if activeOcclusionModule then
				if activeOcclusionModule == self.activeOcclusionModule then
					warn("CameraScript ActivateOcclusionModule failure to detect already running correct module")
				else
					activeOcclusionModule:Enable(false)
				end
			end

			if occlusionMode == Enum.DevCameraOcclusionMode.Invisicam then
				if Players.LocalPlayer.Character then
					self.activeOcclusionModule:CharacterAdded(Players.LocalPlayer.Character, Players.LocalPlayer)
				end
			else
				for _, v5 in pairs(Players:GetPlayers()) do
					if v5 and v5.Character then
						self.activeOcclusionModule:CharacterAdded(v5.Character, v5)
					end
				end

				self.activeOcclusionModule:OnCameraSubjectChanged(game.Workspace.CurrentCamera.CameraSubject)
			end

			self.activeOcclusionModule:Enable(true)
		end
	end
end

function class:ShouldUseVehicleCamera()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return false
	end

	local cameraType = currentCamera.CameraType
	local cameraSubject = currentCamera.CameraSubject
	local v4 = cameraType == Enum.CameraType.Custom or cameraType == Enum.CameraType.Follow
	local v5 = cameraSubject and cameraSubject:IsA("VehicleSeat") or false
	local v6 = self.occlusionMode ~= Enum.DevCameraOcclusionMode.Invisicam
	return v5 and v4 and v6
end

function class:ActivateCameraController()
	local cameraType = workspace.CurrentCamera.CameraType
	local cameraMovementModeFromSettings = self:GetCameraMovementModeFromSettings()
	local v4 = nil

	if cameraType == Enum.CameraType.Scriptable then
		if self.activeCameraController then
			self.activeCameraController:Enable(false)
			self.activeCameraController = nil
		end
	else
		if cameraType == Enum.CameraType.Custom then
			cameraMovementModeFromSettings = self:GetCameraMovementModeFromSettings()
		elseif cameraType == Enum.CameraType.Track then
			cameraMovementModeFromSettings = Enum.ComputerCameraMovementMode.Classic
		elseif cameraType == Enum.CameraType.Follow then
			cameraMovementModeFromSettings = Enum.ComputerCameraMovementMode.Follow
		elseif cameraType == Enum.CameraType.Orbital then
			cameraMovementModeFromSettings = Enum.ComputerCameraMovementMode.Orbital
		elseif cameraType == Enum.CameraType.Attach or cameraType == Enum.CameraType.Watch or cameraType == Enum.CameraType.Fixed then
			v4 = LegacyCamera
		else
			warn("CameraScript encountered an unhandled Camera.CameraType value: ", cameraType)
		end

		if not v4 then
			if VRService.VREnabled then
				v4 = VRCamera
			elseif cameraMovementModeFromSettings == Enum.ComputerCameraMovementMode.Classic or cameraMovementModeFromSettings == Enum.ComputerCameraMovementMode.Follow or cameraMovementModeFromSettings == Enum.ComputerCameraMovementMode.Default or cameraMovementModeFromSettings == Enum.ComputerCameraMovementMode.CameraToggle then
				v4 = ClassicCamera
			elseif cameraMovementModeFromSettings == Enum.ComputerCameraMovementMode.Orbital then
				v4 = OrbitalCamera
			else
				warn("ActivateCameraController did not select a module.")
				return
			end
		end

		if self:ShouldUseVehicleCamera() then
			if VRService.VREnabled then
				v4 = VRVehicleCamera
			else
				v4 = VehicleCamera
			end
		end

		local activeCameraController

		if v3[v4] then
			activeCameraController = v3[v4]

			if userFlag2 then
				if activeCameraController.Reset and self.activeCameraController ~= activeCameraController then
					activeCameraController:Reset()
				end
			elseif activeCameraController.Reset then
				activeCameraController:Reset()
			end
		else
			activeCameraController = v4.new()
			v3[v4] = activeCameraController
		end

		if self.activeCameraController then
			if self.activeCameraController == activeCameraController then
				if not self.activeCameraController:GetEnabled() then
					self.activeCameraController:Enable(true)
				end
			else
				if activeCameraController.HandleSubjectDistance then
					activeCameraController:HandleSubjectDistance(self.activeCameraController)
				end

				self.activeCameraController:Enable(false)
				self.activeCameraController = activeCameraController
				self.activeCameraController:Enable(true)
			end
		elseif activeCameraController ~= nil then
			self.activeCameraController = activeCameraController
			assert(self.activeCameraController, "Strict typing check")
			self.activeCameraController:Enable(true)
		end

		if self.activeCameraController then
			self.activeCameraController:SetCameraMovementMode(cameraMovementModeFromSettings)
			self.activeCameraController:SetCameraType(cameraType)
		end
	end
end

function class:OnCameraSubjectChanged()
	local currentCamera = workspace.CurrentCamera
	local cameraSubject

	if currentCamera then
		cameraSubject = currentCamera.CameraSubject
	end

	if self.activeTransparencyController then
		self.activeTransparencyController:SetSubject(cameraSubject)
	end

	if self.activeOcclusionModule then
		self.activeOcclusionModule:OnCameraSubjectChanged(cameraSubject)
	end

	self:ActivateCameraController()
end

function class:OnCameraTypeChanged(p)
	if p == Enum.CameraType.Scriptable and UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
		CameraUtils.restoreMouseBehavior()
	end

	self:ActivateCameraController()
end

function class:OnCurrentCameraChanged()
	local currentCamera = game.Workspace.CurrentCamera

	if not currentCamera then
		return
	end

	if self.cameraSubjectChangedConn then
		self.cameraSubjectChangedConn:Disconnect()
	end

	if self.cameraTypeChangedConn then
		self.cameraTypeChangedConn:Disconnect()
	end

	self.cameraSubjectChangedConn = currentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
		self:OnCameraSubjectChanged()
	end)
	self.cameraTypeChangedConn = currentCamera:GetPropertyChangedSignal("CameraType"):Connect(function()
		self:OnCameraTypeChanged(currentCamera.CameraType)
	end)
	self:OnCameraSubjectChanged()
	self:OnCameraTypeChanged(currentCamera.CameraType)
end

function class:OnLocalPlayerCameraPropertyChanged(p: string)
	if p == "CameraMode" then
		if Players.LocalPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
			if not self.activeCameraController or self.activeCameraController:GetModuleName() ~= "ClassicCamera" then
				self:ActivateCameraController()
			end

			if self.activeCameraController then
				self.activeCameraController:UpdateForDistancePropertyChange()
			end
		elseif Players.LocalPlayer.CameraMode == Enum.CameraMode.Classic then
			self:ActivateCameraController()
		else
			warn("Unhandled value for property player.CameraMode: ", Players.LocalPlayer.CameraMode)
		end
	elseif p == "DevComputerCameraMode" or p == "DevTouchCameraMode" then
		self:ActivateCameraController()
	elseif p == "DevCameraOcclusionMode" then
		self:ActivateOcclusionModule(Players.LocalPlayer.DevCameraOcclusionMode)
	elseif p == "CameraMinZoomDistance" or p == "CameraMaxZoomDistance" then
		if self.activeCameraController then
			self.activeCameraController:UpdateForDistancePropertyChange()
		end
	elseif p == "DevTouchMovementMode" then
		return
	elseif p == "DevComputerMovementMode" then
		return
	end
end

function class:OnUserGameSettingsPropertyChanged(p: string)
	if p == "ComputerCameraMovementMode" or p == "TouchCameraMovementMode" then
		self:ActivateCameraController()
	end
end

function class:OnPreferredInputChanged()
	self:ActivateCameraController()
end

function class:Update(p)
	if self.activeCameraController then
		self.activeCameraController:UpdateMouseBehavior()
		local cFrame, focus = self.activeCameraController:Update(p)

		if self.activeOcclusionModule and not self.activeCameraController.skipOcclusion then
			cFrame, focus = self.activeOcclusionModule:Update(p, cFrame, focus)
		end

		local currentCamera = game.Workspace.CurrentCamera
		currentCamera.CFrame = cFrame
		currentCamera.Focus = focus

		if self.activeTransparencyController then
			self.activeTransparencyController:Update(p)
		end

		if CameraInput.getInputEnabled() then
			CameraInput.resetInputForFrameEnd()
		end
	end
end

function class:OnCharacterAdded(p2, p3)
	if self.activeOcclusionModule then
		self.activeOcclusionModule:CharacterAdded(p2, p3)
	end
end

function class:OnCharacterRemoving(p2, p3)
	if self.activeOcclusionModule then
		self.activeOcclusionModule:CharacterRemoving(p2, p3)
	end
end

function class:OnPlayerAdded(data)
	if userFlag then
		if self.connectionUtil then
			self.connectionUtil:trackConnection(
				`{data.UserId}CharacterAdded`,
				data.CharacterAdded:Connect(function(character)
					self:OnCharacterAdded(character, data)
				end)
			)
			self.connectionUtil:trackConnection(
				`{data.UserId}CharacterRemoving`,
				data.CharacterRemoving:Connect(function(character)
					self:OnCharacterRemoving(character, data)
				end)
			)
		end
	else
		data.CharacterAdded:Connect(function(character)
			self:OnCharacterAdded(character, data)
		end)
		data.CharacterRemoving:Connect(function(character)
			self:OnCharacterRemoving(character, data)
		end)
	end
end

function class:OnPlayerRemoving(p2)
	if self.connectionUtil then
		self.connectionUtil:disconnect((`{p2.UserId}CharacterAdded`))
		self.connectionUtil:disconnect((`{p2.UserId}CharacterRemoving`))
	end
end

function class:OnMouseLockToggled()
	if self.activeMouseLockController then
		local isMouseLocked = self.activeMouseLockController:GetIsMouseLocked()
		local mouseLockOffset = self.activeMouseLockController:GetMouseLockOffset()

		if self.activeCameraController then
			self.activeCameraController:SetIsMouseLocked(isMouseLocked)
			self.activeCameraController:SetMouseLockOffset(mouseLockOffset)
		end
	end
end

class.new()
return {}