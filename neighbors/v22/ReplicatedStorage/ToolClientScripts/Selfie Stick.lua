local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
game:GetService("InsertService")
local CaptureService = game:GetService("CaptureService")
require(ReplicatedStorage.Modules.Network)
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local renderSteppedConnection = nil
local connections = nil
local screenshotHud = GuiService:WaitForChild("ScreenshotHud")
screenshotHud.HideCoreGuiForCaptures = true
screenshotHud.HidePlayerGuiForCaptures = true
require(ReplicatedStorage.Modules.Tool)

-- equivalent calls inferred from this helper; original call sites unknown
local function removeExistingConnection()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	if connections then
		for _, connection in connections do
			connection:Disconnect()
		end

		connections = nil
	end
end

local function worldSpaceMovement(_, p, _)
	if p == Enum.UserInputState.Begin or p == Enum.UserInputState.Change then
		local character = localPlayer.Character

		if not (character and character:FindFirstChild("Humanoid")) then
			return
		end

		local humanoid = character.Humanoid
		local moveDirection = humanoid.MoveDirection
		local vectorToWorldSpace = workspace.CurrentCamera.CFrame:VectorToWorldSpace((Vector3.new(
			moveDirection.X,
			0,
			-moveDirection.Z
		)))
		humanoid:Move((Vector3.new(vectorToWorldSpace.X, 0, vectorToWorldSpace.Z)))
	end
end

local function onCaptureReady(p)
	CaptureService:PromptSaveCapturesToGallery({ p }, function() end)
end

local SelfieStick = {}

function SelfieStick.Activated(_)
	CaptureService:CaptureScreenshot(onCaptureReady)
end

function SelfieStick.Equipped(p)
	local character = localPlayer.Character
	local humanoid = character.Humanoid
	removeExistingConnection() -- equivalent call inferred; original call site unknown
	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.CameraSubject = p.Tool.Screen

	if connections then
		if connections then
			for k, connection in connections do
				connection:Disconnect()
				table.remove(connections, k)
			end
		end
	else
		connections = {}
	end

	table.insert(connections, UserInputService.InputBegan:Connect(function(input, _)
		if input.KeyCode ~= Enum.KeyCode.D and input.KeyCode ~= Enum.KeyCode.A then
			humanoid.AutoRotate = false
			return
		end

		humanoid.AutoRotate = not (UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.S))
	end))
	table.insert(connections, humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		if UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1 then
			if humanoid.MoveDirection.Magnitude > 0 then
				print(humanoid.MoveDirection.Magnitude)
				humanoid.AutoRotate = true
			else
				humanoid.AutoRotate = false
			end
		end
	end))
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		if not character:FindFirstChild("Head") or character.Head.LocalTransparencyModifier > 0.1 or UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
			currentCamera.FieldOfView = 70
			return
		end

		currentCamera.FieldOfView = 120
		currentCamera.CFrame = p.Tool.Screen.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
	end)
end

function SelfieStick.Unequipped(_)
	removeExistingConnection() -- equivalent call inferred; original call site unknown
	currentCamera.CameraType = Enum.CameraType.Custom
	currentCamera.CameraSubject = localPlayer.Character.Humanoid
	currentCamera.FieldOfView = 70
	localPlayer.Character.Humanoid.AutoRotate = true
end

return SelfieStick