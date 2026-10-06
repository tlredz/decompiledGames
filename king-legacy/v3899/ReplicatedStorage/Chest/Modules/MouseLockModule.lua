local createVector = vector.create
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local MouseLockModule = {}
MouseLockModule.__index = MouseLockModule
local vector3Value = Instance.new("Vector3Value")
vector3Value.Value = Vector3.new()
local Config = require(script.Config)
local MobileUI = require(script.MobileUI)
local mobileUI = MobileUI()
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local mouse = localPlayer:GetMouse()
local touchEnabled = UserInputService.TouchEnabled

if touchEnabled then
	mobileUI.Parent = localPlayer.PlayerGui
end

function MouseLockModule.Init()
	local object = setmetatable({}, MouseLockModule)
	object:AddCharacter(localPlayer.Character)
	localPlayer.CharacterAdded:Connect(function(character)
		object:AddCharacter(character)
	end)
	localPlayer.CharacterRemoving:Connect(function(character)
		if character == object.Character then
			object:RemoveCharacter()
		end
	end)
	return object
end

function MouseLockModule:UpdateMobileImageButton()
	mobileUI.BottomLeftControl.MouseLockLabel.Image = self.Enabled and Config.MobileLockOnImage or Config.MobileLockOffImage
	mobileUI.MiddleIcon.MouseLockLabel.Visible = self.Enabled
end

function MouseLockModule:ToggleShiftLock(enabled)
	self.Enabled = enabled

	if self.Enabled then
		RunService:UnbindFromRenderStep("CameraRender")

		if touchEnabled then
			if touchEnabled and not _G.ShiftLockMobile then
				_G.ShiftLockMobile = true
			end
		else
			mouse.Icon = Config.MouseLockIconPC
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		end

		TweenService:Create(vector3Value, Config.TweenIn, {
			Value = self.CameraOffset
		}):Play()
		self.Character:SetAttribute("MouseLockOn", true)
		RunService:BindToRenderStep("CameraRender", Enum.RenderPriority.Camera.Value, function()
			if currentCamera.CameraType == Enum.CameraType.Scriptable then
				return
			end

			if not touchEnabled and UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			end

			currentCamera.CFrame *= CFrame.new(vector3Value.Value)
			currentCamera.Focus *= CFrame.new(vector3Value.Value)

			if self.Humanoid.Sit or self.Humanoid.PlatformStand or not self.Humanoid:GetAttribute("CustomRotate") or self.RootPart:FindFirstChild("FlyingGyro") then
				return
			end

			if self.MovementRelative == Enum.RotationType.CameraRelative then
				local _, v2, _ = currentCamera.CFrame:ToOrientation()
				self.RootPart.CFrame = CFrame.new(self.RootPart.Position) * CFrame.fromOrientation(0, v2, 0)
			end
		end)
	else
		if touchEnabled and _G.ShiftLockMobile then
			_G.ShiftLockMobile = false
		end

		self.Character:SetAttribute("MouseLockOn", nil)
		RunService:UnbindFromRenderStep("CameraRender")
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		mouse.Icon = Config.MouseIcon
		local tween = TweenService:Create(vector3Value, Config.TweenOut, {
			Value = createVector(0, 0, 0)
		})
		tween:Play()
		local lastTime, renderSteppedConnection = os.clock()
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			if renderSteppedConnection and renderSteppedConnection.Connected and os.clock() - lastTime > tween.TweenInfo.Time then
				renderSteppedConnection:Disconnect()
			end

			if currentCamera.CameraType == Enum.CameraType.Scriptable then
				return
			end

			currentCamera.CFrame *= CFrame.new(vector3Value.Value)
		end)
		task.spawn(function()
			tween.Completed:Wait()
			vector3Value.Value = createVector(0, 0, 0)
			renderSteppedConnection:Disconnect()
			currentCamera.CFrame = currentCamera.CFrame
		end)
	end

	if touchEnabled then
		self:UpdateMobileImageButton()
	end
end

function MouseLockModule:AddCharacter(model)
	if not (model and model:IsA("Model")) then
		return
	end

	local humanoid = model:WaitForChild("Humanoid")
	local humanoidRootPart = model:WaitForChild("HumanoidRootPart")
	local head = model:WaitForChild("Head")
	self.Character = model
	self.Humanoid = humanoid
	self.RootPart = humanoidRootPart
	self.Head = head
	self.MovementRelative = Config.RotationType
	self.CameraOffset = Config.CameraOffset
	self:RemoveCharacter()
	self.Connects = {}
	table.insert(self.Connects, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		for _, toggleShiftLockKeybind in pairs(Config.ToggleShiftLockKeybinds) do
			if toggleShiftLockKeybind ~= input.KeyCode then
				continue
			end

			self:ToggleShiftLock(not self.Enabled)
			break
		end
	end))
	table.insert(self.Connects, self.Humanoid.Died:Connect(function()
		self:RemoveCharacter()
	end))
end

function MouseLockModule:ClearConnects()
	if self.Connects then
		for _, connect in pairs(self.Connects) do
			if connect.Connected then
				connect:Disconnect()
			end
		end
	end

	RunService:UnbindFromRenderStep("CameraRender")
end

function MouseLockModule:RemoveCharacter()
	self:ToggleShiftLock(false)
	self:ClearConnects()
	self:UpdateMobileImageButton()
end

function MouseLockModule:UpdateMovementRelative(movementRelative)
	self.MovementRelative = movementRelative
end

function MouseLockModule.IsEnabled(p)
	return p.Enabled
end

return MouseLockModule