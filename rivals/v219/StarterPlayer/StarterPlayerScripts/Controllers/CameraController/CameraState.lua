local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local PermissionsLibrary = require(ReplicatedStorage.Modules.PermissionsLibrary)
require(ReplicatedStorage.Modules.DebugLibrary)
local Signal = require(ReplicatedStorage.Modules.Signal)
local PrivateServerController = require(Players.LocalPlayer.PlayerScripts.Controllers.PrivateServerController)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local customFreecam = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("CustomFreecam")
local states = {
	FirstPerson = "FirstPerson",
	ThirdPerson = "ThirdPerson",
	ThirdPersonMirrored = "ThirdPersonMirrored",
	ThirdPersonUnlockedMouse = "ThirdPersonUnlockedMouse",
	CustomFreecam = "CustomFreecam"
}
local CameraState = {}
CameraState.__index = CameraState
CameraState.States = states
CameraState.POVStates = {
	"FirstPerson",
	"ThirdPerson",
	"ThirdPersonMirrored",
	"ThirdPersonUnlockedMouse"
}

function CameraState.new(cameraController)
	local self = setmetatable({}, CameraState)
	self.StateChanged = Signal.new()
	self.FreecamAccessChanged = Signal.new()
	self.CameraController = cameraController
	self._public_state = nil
	self._pov_state = nil
	self._is_active = false
	self._custom_freecam_enabled = false
	self._custom_freecam = customFreecam:Clone()
	self._custom_freecam_script = self._custom_freecam:WaitForChild("LocalScript")
	self:_Init()
	return self
end

function CameraState:GetPublicState()
	return self._public_state
end

function CameraState:HasFreecamAccess()
	return CONSTANTS.IS_STUDIO or CONSTANTS.IS_TESTING_SERVER or PrivateServerController:Get("FreecamEnabled") == "Everyone" or PrivateServerController:Get("FreecamEnabled") == "Server Owner" and CONSTANTS.IS_PRIVATE_SERVER_OWNER(Players.LocalPlayer.UserId) or PermissionsLibrary:HasPermission(
		"permission_freecam",
		PlayerDataController:Get("PermissionsRoles")
	)
end

function CameraState:SetActive(is_active)
	if is_active == self._is_active then
		return
	end

	self._is_active = is_active
	self:_UpdateState()
end

function CameraState:SetCustomFreecamEnabled(custom_freecam_enabled)
	if custom_freecam_enabled == self._custom_freecam_enabled then
		return
	end

	self._custom_freecam_enabled = custom_freecam_enabled
	self:_UpdateState()
	self._custom_freecam_script.Disabled = false
	self._custom_freecam.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	task.defer(
		self._custom_freecam.LocalScript.Toggle.Fire,
		self._custom_freecam.LocalScript.Toggle,
		self._custom_freecam_enabled
	)
end

function CameraState:TogglePOV()
	local hasThirdPersonAccess = self.CameraController:HasThirdPersonAccess()
	local v2 = hasThirdPersonAccess and self.CameraController:HasUnlockedMouseAccess()

	if self._pov_state == self.States.FirstPerson and hasThirdPersonAccess then
		self:_SetPOVState(self.States.ThirdPerson)
	elseif self._pov_state == self.States.ThirdPerson and hasThirdPersonAccess then
		self:_SetPOVState(self.States.ThirdPersonMirrored)
	elseif self._pov_state == self.States.ThirdPersonMirrored and v2 then
		self:_SetPOVState(self.States.ThirdPersonUnlockedMouse)
	elseif self.CameraController:IsSubjectEmoting() then
		self:_SetPOVState(self.States.ThirdPerson)
	else
		self:_SetPOVState(self.States.FirstPerson)
	end
end

function CameraState:VerifyPOV()
	local v2

	if self._pov_state == self.States.FirstPerson then
		v2 = false
	else
		v2 = not self.CameraController:HasThirdPersonAccess()
	end

	local v3

	if self._pov_state == self.States.ThirdPersonUnlockedMouse then
		v3 = not self.CameraController:HasUnlockedMouseAccess()
	else
		v3 = false
	end

	if v3 then
		if v2 then
			self:_SetPOVState(self.States.FirstPerson)
		else
			self:_SetPOVState(self.States.ThirdPerson)
		end
	elseif v2 then
		self:_SetPOVState(self.States.FirstPerson)
	end
end

function CameraState:_SetState(public_state)
	assert(not public_state or states[public_state], public_state)

	if public_state == self._public_state then
		return
	end

	local _public_state = self._public_state
	self._public_state = public_state
	self.StateChanged:Fire(self._public_state, _public_state)
end

function CameraState:_UpdateState()
	self.CameraController:GetCurrentSubject()
	local customFreecam2

	if self._custom_freecam_enabled then
		customFreecam2 = self.States.CustomFreecam
	elseif self._is_active then
		customFreecam2 = self._pov_state
	end

	self:_SetState(customFreecam2)
end

function CameraState:_SetPOVState(pov_state)
	assert(not pov_state or states[pov_state], pov_state)

	if pov_state == self._pov_state then
		return
	end

	self._pov_state = pov_state
	self:_UpdateState()
end

function CameraState:_SetupEmoteLogic()
	local v2 = nil
	local connections = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function check()
		task.defer(function()
			if self.CameraController:IsSubjectEmoting() then
				v2 = v2 or self._pov_state
				self:_SetPOVState(self.States.ThirdPersonUnlockedMouse)
			else
				if v2 then
					self:_SetPOVState(v2)
					v2 = nil
				end

				self:VerifyPOV()
			end
		end)
	end

	local function subject_changed()
		for _, connection in pairs(connections) do
			connection:Disconnect()
		end

		connections = {}
		local currentSubject = self.CameraController:GetCurrentSubject()

		if not currentSubject then
			return
		end

		table.insert(connections, currentSubject.EntityRemoved:Connect(check))

		-- equivalent calls inferred from this helper; original call sites unknown
		local function entity_added(entity)
			table.insert(connections, entity.EmoteStatusChanged:Connect(check))
			check() -- equivalent call inferred; original call site unknown
		end

		table.insert(connections, currentSubject.EntityAdded:Connect(entity_added))

		if currentSubject.Entity then
			entity_added(currentSubject.Entity) -- equivalent call inferred; original call site unknown
		end
	end

	self.CameraController.SubjectChanged:Connect(subject_changed)
	subject_changed()
end

function CameraState:_SetupFreecam()
	task.spawn(function()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function child_added(screenGui)
			if screenGui:IsA("ScreenGui") and screenGui.Name == "Freecam" then
				task.defer(screenGui.Destroy, screenGui)
			end
		end

		Players.LocalPlayer:WaitForChild("PlayerGui").ChildAdded:Connect(child_added)

		for _, child in pairs(Players.LocalPlayer.PlayerGui:GetChildren()) do
			child_added(child) -- equivalent call inferred; original call site unknown
		end
	end)
	UserInputService.InputBegan:Connect(function(input, _)
		if input.KeyCode == Enum.KeyCode.P and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and self:HasFreecamAccess() then
			self:SetCustomFreecamEnabled(not self._custom_freecam_enabled)
		end
	end)
end

function CameraState:_Setup()
	if self.CameraController:HasThirdPersonAccess() then
		self:_SetPOVState(self.States.FirstPerson)
	end
end

function CameraState:_Init()
	ControlsController.ControlsChanged:Connect(function()
		self:VerifyPOV()
	end)
	PrivateServerController:GetDataChangedSignal("FreecamEnabled"):Connect(function()
		self.FreecamAccessChanged:Fire()
	end)
	PlayerDataController:GetDataChangedSignal("PermissionsRoles"):Connect(function()
		self.FreecamAccessChanged:Fire()
	end)
	self:_Setup()
	self:_UpdateState()
	task.defer(self._SetupFreecam, self)
	task.defer(self._SetupEmoteLogic, self)
end

return CameraState