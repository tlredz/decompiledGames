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
game:GetService("StarterPlayer")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local CameraUtils = require(script:WaitForChild("CameraUtils"))
local ClassicCamera = require(script:WaitForChild("ClassicCamera"))
local OrbitalCamera = require(script:WaitForChild("OrbitalCamera"))
local LegacyCamera = require(script:WaitForChild("LegacyCamera"))
local Invisicam = require(script:WaitForChild("Invisicam"))
local success, result = pcall(UserSettings().IsUserFeatureEnabled, UserSettings(), "UserNewPoppercam4")
local Poppercam

if success and result then
	Poppercam = require(script:WaitForChild("Poppercam"))
else
	Poppercam = require(script:WaitForChild("Poppercam_Classic"))
end

local TransparencyController = require(script:WaitForChild("TransparencyController"))
local MouseLockController = require(script:WaitForChild("MouseLockController"))
local v3 = {}
local activeOcclusionModules = {}
local playerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts")
playerScripts:RegisterTouchCameraMovementMode(Enum.TouchCameraMovementMode.Default)
playerScripts:RegisterTouchCameraMovementMode(Enum.TouchCameraMovementMode.Follow)
playerScripts:RegisterTouchCameraMovementMode(Enum.TouchCameraMovementMode.Classic)
playerScripts:RegisterComputerCameraMovementMode(Enum.ComputerCameraMovementMode.Default)
playerScripts:RegisterComputerCameraMovementMode(Enum.ComputerCameraMovementMode.Follow)
playerScripts:RegisterComputerCameraMovementMode(Enum.ComputerCameraMovementMode.Classic)

function class.new()
	local object = setmetatable({}, class)
	object.activeCameraController = nil
	object.activeOcclusionModule = nil
	object.activeTransparencyController = nil
	object.activeMouseLockController = nil
	object.currentComputerCameraMovementMode = nil
	object.cameraSubjectChangedConn = nil
	object.cameraTypeChangedConn = nil

	for _, v4 in pairs(Players:GetPlayers()) do
		object:OnPlayerAdded(v4)
	end

	Players.PlayerAdded:Connect(function(player)
		object:OnPlayerAdded(player)
	end)
	object.activeTransparencyController = TransparencyController.new()
	object.activeTransparencyController:Enable(true)
	object.activeMouseLockController = MouseLockController.new()
	local bindableToggleEvent = object.activeMouseLockController:GetBindableToggleEvent()

	if bindableToggleEvent then
		bindableToggleEvent:Connect(function()
			object:OnMouseLockToggled()
		end)
	end

	object:ActivateCameraController(object:GetCameraControlChoice())
	object:ActivateOcclusionModule(Players.LocalPlayer.DevCameraOcclusionMode)
	object:OnCurrentCameraChanged()
	RunService:BindToRenderStep("cameraRenderUpdate", Enum.RenderPriority.Camera.Value, function(p)
		object:Update(p)
	end)

	for _, propertyName in pairs(v) do
		local v4 = propertyName
		Players.LocalPlayer:GetPropertyChangedSignal(propertyName):Connect(function()
			object:OnLocalPlayerCameraPropertyChanged(v4)
		end)
	end

	for _, propertyName in pairs(v2) do
		local v4 = propertyName
		UserGameSettings:GetPropertyChangedSignal(propertyName):Connect(function()
			object:OnUserGameSettingsPropertyChanged(v4)
		end)
	end

	game.Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		object:OnCurrentCameraChanged()
	end)
	object.lastInputType = UserInputService:GetLastInputType()
	UserInputService.LastInputTypeChanged:Connect(function(lastInputType)
		object.lastInputType = lastInputType
	end)
	return object
end

function class:GetCameraMovementModeFromSettings()
	if Players.LocalPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
		return CameraUtils.ConvertCameraModeEnumToStandard(Enum.ComputerCameraMovementMode.Classic)
	end

	local selected, v5

	if UserInputService.TouchEnabled then
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

function class:ActivateOcclusionModule(p2)
	local v4

	if p2 == Enum.DevCameraOcclusionMode.Zoom then
		v4 = Poppercam
	elseif p2 == Enum.DevCameraOcclusionMode.Invisicam then
		v4 = Invisicam
	else
		warn("CameraScript ActivateOcclusionModule called with unsupported mode")
		return
	end

	if self.activeOcclusionModule and self.activeOcclusionModule:GetOcclusionMode() == p2 then
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
			if self.activeOcclusionModule:GetOcclusionMode() ~= p2 then
				warn(
					"CameraScript ActivateOcclusionModule mismatch: ",
					self.activeOcclusionModule:GetOcclusionMode(),
					"~=",
					p2
				)
			end

			if activeOcclusionModule then
				if activeOcclusionModule == self.activeOcclusionModule then
					warn("CameraScript ActivateOcclusionModule failure to detect already running correct module")
				else
					activeOcclusionModule:Enable(false)
				end
			end

			if p2 == Enum.DevCameraOcclusionMode.Invisicam then
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

function class:ActivateCameraController(cameraMovementModeFromSettings, p)
	local v4 = nil

	if p ~= nil then
		if p == Enum.CameraType.Scriptable then
			if self.activeCameraController then
				self.activeCameraController:Enable(false)
				self.activeCameraController = nil
				return
			end
		elseif p == Enum.CameraType.Custom then
			cameraMovementModeFromSettings = self:GetCameraMovementModeFromSettings()
		elseif p == Enum.CameraType.Track then
			cameraMovementModeFromSettings = Enum.ComputerCameraMovementMode.Classic
		elseif p == Enum.CameraType.Follow then
			cameraMovementModeFromSettings = Enum.ComputerCameraMovementMode.Follow
		elseif p == Enum.CameraType.Orbital then
			cameraMovementModeFromSettings = Enum.ComputerCameraMovementMode.Orbital
		elseif p == Enum.CameraType.Attach or p == Enum.CameraType.Watch or p == Enum.CameraType.Fixed then
			v4 = LegacyCamera
		else
			warn("CameraScript encountered an unhandled Camera.CameraType value: ", p)
		end
	end

	if not v4 then
		if cameraMovementModeFromSettings == Enum.ComputerCameraMovementMode.Classic or cameraMovementModeFromSettings == Enum.ComputerCameraMovementMode.Follow or cameraMovementModeFromSettings == Enum.ComputerCameraMovementMode.Default then
			v4 = ClassicCamera
		elseif cameraMovementModeFromSettings == Enum.ComputerCameraMovementMode.Orbital then
			v4 = OrbitalCamera
		else
			return
		end
	end

	local activeCameraController

	if v3[v4] then
		activeCameraController = v3[v4]
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
			self.activeCameraController:Enable(false)
			self.activeCameraController = activeCameraController
			self.activeCameraController:Enable(true)
		end
	elseif activeCameraController ~= nil then
		self.activeCameraController = activeCameraController
		self.activeCameraController:Enable(true)
	end

	if self.activeCameraController then
		if cameraMovementModeFromSettings == nil then
			if p ~= nil then
				self.activeCameraController:SetCameraType(p)
			end
		else
			self.activeCameraController:SetCameraMovementMode(cameraMovementModeFromSettings)
		end
	end
end

function class:OnCameraSubjectChanged()
	if self.activeTransparencyController then
		self.activeTransparencyController:SetSubject(game.Workspace.CurrentCamera.CameraSubject)
	end

	if self.activeOcclusionModule then
		self.activeOcclusionModule:OnCameraSubjectChanged(game.Workspace.CurrentCamera.CameraSubject)
	end
end

function class:OnCameraTypeChanged(p)
	if p == Enum.CameraType.Scriptable and UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end

	self:ActivateCameraController(nil, p)
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
		self:OnCameraSubjectChanged(currentCamera.CameraSubject)
	end)
	self.cameraTypeChangedConn = currentCamera:GetPropertyChangedSignal("CameraType"):Connect(function()
		self:OnCameraTypeChanged(currentCamera.CameraType)
	end)
	self:OnCameraSubjectChanged(currentCamera.CameraSubject)
	self:OnCameraTypeChanged(currentCamera.CameraType)
end

function class:OnLocalPlayerCameraPropertyChanged(p)
	if p == "CameraMode" then
		if Players.LocalPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
			if not self.activeCameraController or self.activeCameraController:GetModuleName() ~= "ClassicCamera" then
				self:ActivateCameraController(CameraUtils.ConvertCameraModeEnumToStandard(Enum.DevComputerCameraMovementMode.Classic))
			end

			if self.activeCameraController then
				self.activeCameraController:UpdateForDistancePropertyChange()
			end
		else
			if Players.LocalPlayer.CameraMode ~= Enum.CameraMode.Classic then
				warn("Unhandled value for property player.CameraMode: ", Players.LocalPlayer.CameraMode)
				return
			end

			local cameraMovementModeFromSettings = self:GetCameraMovementModeFromSettings()
			self:ActivateCameraController(CameraUtils.ConvertCameraModeEnumToStandard(cameraMovementModeFromSettings))
		end
	elseif p == "DevComputerCameraMode" or p == "DevTouchCameraMode" then
		local cameraMovementModeFromSettings = self:GetCameraMovementModeFromSettings()
		self:ActivateCameraController(CameraUtils.ConvertCameraModeEnumToStandard(cameraMovementModeFromSettings))
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

function class:OnUserGameSettingsPropertyChanged(p)
	if p == "ComputerCameraMovementMode" then
		local cameraMovementModeFromSettings = self:GetCameraMovementModeFromSettings()
		self:ActivateCameraController(CameraUtils.ConvertCameraModeEnumToStandard(cameraMovementModeFromSettings))
	end
end

function class:Update(p)
	if self.activeCameraController then
		local cFrame, focus = self.activeCameraController:Update(p)
		self.activeCameraController:ApplyVRTransform()

		if self.activeOcclusionModule then
			cFrame, focus = self.activeOcclusionModule:Update(p, cFrame, focus)
		end

		game.Workspace.CurrentCamera.CFrame = cFrame
		game.Workspace.CurrentCamera.Focus = focus

		if self.activeTransparencyController then
			self.activeTransparencyController:Update()
		end
	end
end

function class:GetCameraControlChoice()
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	if self.lastInputType == Enum.UserInputType.Touch or UserInputService.TouchEnabled then
		if localPlayer.DevTouchCameraMode == Enum.DevTouchCameraMovementMode.UserChoice then
			return CameraUtils.ConvertCameraModeEnumToStandard(UserGameSettings.TouchCameraMovementMode)
		end

		return CameraUtils.ConvertCameraModeEnumToStandard(localPlayer.DevTouchCameraMode)
	else
		if localPlayer.DevComputerCameraMode ~= Enum.DevComputerCameraMovementMode.UserChoice then
			return CameraUtils.ConvertCameraModeEnumToStandard(localPlayer.DevComputerCameraMode)
		end

		local convertCameraModeEnumToStandard = CameraUtils.ConvertCameraModeEnumToStandard(UserGameSettings.ComputerCameraMovementMode)
		return CameraUtils.ConvertCameraModeEnumToStandard(convertCameraModeEnumToStandard)
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

function class:OnPlayerAdded(p)
	p.CharacterAdded:Connect(function(character)
		self:OnCharacterAdded(character, p)
	end)
	p.CharacterRemoving:Connect(function(character)
		self:OnCharacterRemoving(character, p)
	end)
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

return class.new()