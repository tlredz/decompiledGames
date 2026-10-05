local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local types = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Tools"):WaitForChild("Jetpack"):WaitForChild("Types")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")
local Workspace = game:GetService("Workspace")
local currentCamera = Workspace.CurrentCamera
local v = nil
local v2 = 0
script:WaitForChild("Object")
local character = localPlayer.Character
local humanoid = character:FindFirstChildOfClass("Humanoid")
local animator = humanoid:FindFirstChild("Animator")
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
local attachment = Instance.new("Attachment")
attachment.Name = "JetpackAttachment"
attachment.Parent = humanoidRootPart
local alignOrientation = Instance.new("AlignOrientation")
alignOrientation.Name = "FlyOrientation"
alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
alignOrientation.Attachment0 = attachment
alignOrientation.Responsiveness = 100
alignOrientation.Enabled = true
alignOrientation.RigidityEnabled = true
alignOrientation.CFrame = humanoidRootPart.CFrame

if VRService.VREnabled then
	alignOrientation.Enabled = false
	alignOrientation.Parent = script
else
	alignOrientation.Parent = humanoidRootPart
end

local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
	if input.KeyCode ~= Enum.KeyCode.Thumbstick1 then
		return
	end

	local magnitude = input.Position.Magnitude

	if magnitude <= 0.22 then
		v2 = 0
	else
		v2 = math.clamp((magnitude - 0.22) / 0.78, 0, 1)
	end
end)
local linearVelocity = Instance.new("LinearVelocity")
linearVelocity.Name = "FlyVelocity"
linearVelocity.MaxForce = 10000000000000
linearVelocity.Attachment0 = attachment
linearVelocity.Parent = humanoidRootPart
local v3 = "FlyHover"
local v4 = {
	"Flying",
	"FlyLeft",
	"FlyBack",
	"FlyHover",
	"FlyRight"
}
humanoid.AutoRotate = false

-- equivalent calls inferred from this helper; original call sites unknown
local function Unsit()
	if humanoid.Sit then
		humanoid.Sit = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetPlayerMoveDirection()
	return currentCamera:GetRenderCFrame():VectorToObjectSpace(localPlayer.Character.Humanoid.MoveDirection)
end

local function PlayAnimation(p)
	if not localPlayer.Character or not localPlayer.Character:FindFirstChild("Humanoid") or not localPlayer.Character.Humanoid:FindFirstChild("Animator") or localPlayer:GetAttribute("VR") then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function PlayTrack(animation)
		local track = localPlayer.Character.Humanoid.Animator:LoadAnimation(animation)
		track.Priority = Enum.AnimationPriority.Movement
		track:Play(0.3)
		v = track
	end

	local animations = types[script:GetAttribute("Type")].Animations

	if v then
		if animations[v.Name].AnimationId == animations[p].AnimationId then
			return
		else
			v:Stop(0.3)
		end
	end

	PlayTrack(animations[p]) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetDirectionVector()
	local playerMoveDirection = GetPlayerMoveDirection() -- equivalent call inferred; original call site unknown

	if playerMoveDirection.magnitude < 0.1 then
		return createVector(0, 0, 0)
	end

	local lookVector = currentCamera:GetRenderCFrame().LookVector
	local rightVector = currentCamera:GetRenderCFrame().RightVector
	return (-playerMoveDirection.Z * lookVector + playerMoveDirection.X * rightVector).unit
end

local function GetFlightSpeed()
	local v5 = v3 == "Flying" and 50 or v3 == "FlyBack" and 37.5 or 40

	if v2 > 0 then
		return v5 * v2
	end

	return v5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetFlyState()
	local playerMoveDirection = GetPlayerMoveDirection() -- equivalent call inferred; original call site unknown

	if playerMoveDirection.Z < -0.1 then
		return "Flying"
	end

	if playerMoveDirection.Z > 0.1 then
		return "FlyBack"
	end

	if playerMoveDirection.X > 0.1 then
		return "FlyRight"
	end

	if playerMoveDirection.X < -0.1 then
		return "FlyLeft"
	end

	return "FlyHover"
end

local function JetUpdate(p)
	v3 = GetFlyState()
	local playerMoveDirection = GetPlayerMoveDirection() -- equivalent call inferred; original call site unknown
	local v6 = v3 == "Flying" and 50 or v3 == "FlyBack" and 37.5 or 40

	if v2 > 0 then
		v6 *= v2
	end

	local directionVector = GetDirectionVector() -- equivalent call inferred; original call site unknown
	local vectorVelocity = directionVector * v6
	v3 = GetFlyState()
	linearVelocity.VectorVelocity = vectorVelocity
	PlayAnimation(v3)
	local cFrame

	if vectorVelocity.magnitude > 1 then
		if v3 == "Flying" or v3 == "FlyBack" then
			local v9 = math.atan2(playerMoveDirection.X, (math.abs(playerMoveDirection.Z))) * math.sign(playerMoveDirection.Z)
			cFrame = currentCamera.CFrame * CFrame.Angles(0, v9, 0)
		else
			cFrame = currentCamera.CFrame
		end
	else
		local _, v9, _ = alignOrientation.CFrame:ToEulerAnglesYXZ()
		cFrame = CFrame.Angles(0, v9, 0)
	end

	alignOrientation.CFrame = alignOrientation.CFrame:lerp(cFrame, p * 10)
end

local function Unequip()
	local humanoid2 = localPlayer.Character:FindFirstChild("Humanoid")
	v3 = nil
	RunService:UnbindFromRenderStep("FlyBinding")

	if inputChangedConnection then
		inputChangedConnection:Disconnect()
		inputChangedConnection = nil
	end

	if v then
		if v.Name ~= v3 then
			v:Stop()
		end

		v:Stop()
		v = nil
	end

	if alignOrientation then
		alignOrientation:Destroy()
	end

	if linearVelocity then
		linearVelocity:Destroy()
	end

	humanoid2.AutoRotate = true
	humanoid2:SetStateEnabled(Enum.HumanoidStateType.Seated, true)

	for _, descendant in localPlayer.Character:GetDescendants() do
		if descendant.Name == "FlyVelocity" or descendant.Name == "FlyOrientation" or descendant.Name == "JetpackAttachment" then
			descendant:Destroy()
		end
	end
end

RunService:BindToRenderStep("FlyBinding", Enum.RenderPriority.Camera.Value - 1, JetUpdate)
PlayAnimation(v3)
Unsit() -- equivalent call inferred; original call site unknown
humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
localPlayer.Character:GetAttributeChangedSignal("UsingJetpack"):Once(function()
	RunService:UnbindFromRenderStep("FlyBinding")
	Unequip()
	script:Destroy()
	local playingAnimationTracks = animator:GetPlayingAnimationTracks()

	for _, v5 in pairs(v4) do
		for _, playingAnimationTrack in pairs(playingAnimationTracks) do
			if v5 ~= playingAnimationTrack.Name then
				continue
			end

			playingAnimationTrack:Stop()
			playingAnimationTrack:Destroy()
		end
	end
end)
local object = script:WaitForChild("Object")

if not object.Value then
	object:GetPropertyChangedSignal("Value"):Wait()
end

if object.Value then
	object.Value.Destroying:Connect(Unequip)
end