local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Input = require(ReplicatedStorage.Packages.Input)
local PlayerModule = require((Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")))
local controls = PlayerModule:GetControls()
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local HelicopterControl = require(ReplicatedStorage.Modules.Client.Components.UI.Vehicles.HelicopterControl)
local preferredInput = Input.PreferredInput
local keyboard = Input.Keyboard
local gamepad = Input.Gamepad
local v = Component.new({
	Tag = "Helicopter"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._controlJanitor = self._Janitor:Add(Janitor.new())
	self._gamepad = self._Janitor:Add(gamepad.new())
	self._keyboard = self._Janitor:Add(keyboard.new())
	self._mainPart = self.Instance:WaitForChild("Main")
	self._alignOrientation = self._mainPart:WaitForChild("AlignOrientation")
	self._linearVelocity = self._mainPart:WaitForChild("LinearVelocity")
	self._engineLoop = self._mainPart:WaitForChild("EngineLoop")
	self._lookAtCameraDirection = self.Instance:GetAttribute("LookAtCameraDirection")
	self._controlledCFrame = self._alignOrientation.CFrame
	self._controlling = false
	self._upButtonDown = false
	self._downButtonDown = false
	self._forceAttached = false
	self._raycastParams = RaycastParams.new()
	self._raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	self._raycastParams.FilterDescendantsInstances = { self.Instance }
end

function v:Start()
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "TakeControl", function()
		self:TakeControl()
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "ReleaseControl", function()
		self:ReleaseControl()
	end))
end

function v:TakeControl()
	if self._controlling then
		return
	end

	self._controlling = true
	PanelController.ToggleGroup("TopArea", false)
	PanelController.Open("HelicopterControl", "HelicopterControl")
	HelicopterControl:WaitForInstance(PanelController.GetPanel("HelicopterControl", "HelicopterControl").Instance):andThen(function(helicopterControl)
		self._helicopterControl = helicopterControl
		self._helicopterControl:SetMaxSpeed(self.Instance:GetAttribute("MaxSpeed"))
		self._controlledCFrame = self._alignOrientation.CFrame
		self._controlJanitor:Add(self._helicopterControl.OnVerticalUpStarted:Connect(function()
			self._upButtonDown = true
		end))
		self._controlJanitor:Add(self._helicopterControl.OnVerticalUpEnded:Connect(function()
			self._upButtonDown = false
		end))
		self._controlJanitor:Add(self._helicopterControl.OnVerticalDownStarted:Connect(function()
			self._downButtonDown = true
		end))
		self._controlJanitor:Add(self._helicopterControl.OnVerticalDownEnded:Connect(function()
			self._downButtonDown = false
		end))
		self._helicopterControl:SetHoistButtonVisible(self.Instance:GetAttribute("HasHoists"))
	end)
	local pilotSeat = self.Instance:FindFirstChild("PilotSeat")

	if self.Instance:GetAttribute("LookAtCameraDirection") and pilotSeat then
		local currentCamera = workspace.CurrentCamera

		repeat
			task.wait()
		until currentCamera.CameraSubject == pilotSeat

		currentCamera.CameraType = Enum.CameraType.Track
	end
end

function v:ReleaseControl()
	if not self._controlling then
		return
	end

	self._controlling = false
	PanelController.Close("HelicopterControl", "HelicopterControl")
	self._upButtonDown = false
	self._downButtonDown = false

	if self:IsNearGround() then
		self._linearVelocity.VectorVelocity = createVector(0, -6, 0)
	else
		self._linearVelocity.VectorVelocity = createVector(0, 0, 0)
	end

	self._alignOrientation.CFrame = self._controlledCFrame
	self._controlJanitor:Cleanup()

	if self.Instance:GetAttribute("LookAtCameraDirection") then
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end
end

function v:GetDistanceToGround()
	local characters = { self.Instance }

	for _, v2 in Players:GetPlayers() do
		if v2.Character then
			table.insert(characters, v2.Character)
		end
	end

	self._raycastParams.FilterDescendantsInstances = characters
	local raycastResult = workspace:Raycast(self._mainPart.Position, createVector(0, -100, 0), self._raycastParams)

	if not raycastResult or (raycastResult.Instance:HasTag("MilitaryVehicleCollider") or raycastResult.Instance:HasTag("AntiAircraftZone")) then
		return 1e999
	end

	return raycastResult.Distance
end

function v:IsNearGround()
	return self:GetDistanceToGround() < 20
end

function v:_GetVerticalScalar()
	if preferredInput.Current == "MouseKeyboard" then
		return ((self._keyboard:IsKeyDown(Enum.KeyCode.E) or self._upButtonDown) and 1 or 0) - ((self._keyboard:IsKeyDown(Enum.KeyCode.Q) or self._downButtonDown) and 1 or 0)
	end

	if preferredInput.Current == "Gamepad" then
		return ((self._gamepad:IsButtonDown(Enum.KeyCode.ButtonR1) or self._upButtonDown) and 1 or 0) - ((self._gamepad:IsButtonDown(Enum.KeyCode.ButtonL1) or self._downButtonDown) and 1 or 0)
	end

	if preferredInput.Current == "Touch" then
		return (self._upButtonDown and 1 or 0) - (self._downButtonDown and 1 or 0)
	end

	return 0
end

function v:UpdateAudio()
	local maxSpeed = self.Instance:GetAttribute("MaxSpeed")
	local v2 = self._mainPart.AssemblyLinearVelocity.Magnitude / maxSpeed
	self._engineLoop.PlaybackSpeed = math.map(v2, 0, 1, 0.8, 1.2)
end

function v:GetOrientationFromCamera()
	local currentCamera = workspace.CurrentCamera

	if currentCamera.CameraType == Enum.CameraType.Custom then
		currentCamera.CameraType = Enum.CameraType.Track
	end

	if currentCamera.CameraType == Enum.CameraType.Track then
		return currentCamera.CFrame
	end

	return self._controlledCFrame
end

function v:GetOrientationFromControls(p2: number)
	local moveVector = controls:GetMoveVector()
	local v2 = self._controlledCFrame * CFrame.Angles(0, -moveVector.X * p2 * 0.6981317007977318, 0)
	return (CFrame.fromMatrix(v2.Position, v2.RightVector, createVector(0, 1, 0)))
end

function v:SteppedUpdate(p: number)
	self:UpdateAudio()

	if not (self._controlling and self._helicopterControl) then
		return
	end

	local speed = self._helicopterControl.Speed
	local moveVector = controls:GetMoveVector()
	local _GetVerticalScalar = self:_GetVerticalScalar()
	local v2 = createVector(0, 0, 0)
	local orientationFromCamera

	if self._lookAtCameraDirection then
		orientationFromCamera = self:GetOrientationFromCamera()
		v2 = orientationFromCamera.RightVector * moveVector.X * speed
	else
		orientationFromCamera = self:GetOrientationFromControls(p)
	end

	local v3 = (-orientationFromCamera.LookVector * moveVector.Z * speed + createVector(0, 1, 0) * _GetVerticalScalar * 50 + v2).Unit * speed
	local v4 = v3.X ~= v3.X and createVector(0, 0, 0) or v3
	local v5 = 0.1 * (self.Instance:GetAttribute("VisualRotationMultiplier") or 1)
	local v6 = CFrame.Angles(moveVector.Z * v5, 0, 0) * CFrame.Angles(0, 0, moveVector.X * -v5)
	self._linearVelocity.VectorVelocity = self._linearVelocity.VectorVelocity:Lerp(v4, p * 2)
	self._alignOrientation.CFrame = orientationFromCamera * v6
	self._controlledCFrame = orientationFromCamera
	local forceAttached = v4.Magnitude > 0.1

	if forceAttached ~= self._forceAttached then
		self._forceAttached = forceAttached
		Remotes.fireServerComponent(self.Instance, "ForceAttached", self._forceAttached)
	end
end

function v:Stop()
	if self._controlling then
		self:ReleaseControl()
	end

	self._Janitor:Destroy()
end

return v