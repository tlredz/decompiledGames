local parent = script.Parent
local humanoid = parent:WaitForChild("Humanoid")
local humanoidRootPart = parent:WaitForChild("HumanoidRootPart")
local currentCamera = workspace.CurrentCamera
local attachment = Instance.new("Attachment", humanoidRootPart)
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local position = humanoidRootPart.Position
local alignPosition = Instance.new("AlignPosition")
alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
alignPosition.MaxForce = 10000000000
alignPosition.Position = position
alignPosition.Responsiveness = 100
alignPosition.Enabled = false
alignPosition.Parent = humanoidRootPart
alignPosition.Attachment0 = attachment
local alignOrientation = Instance.new("AlignOrientation")
alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
alignOrientation.Attachment0 = attachment
alignOrientation.Responsiveness = 100
alignOrientation.Enabled = false
alignOrientation.Parent = humanoidRootPart
alignOrientation.RigidityEnabled = true
local v = {}
local enabled = false

for _, part in pairs(parent:GetDescendants()) do
	if part:IsA("BasePart") then
		v[part] = part.CollisionGroup
	end
end

function toggleFlight(flag: boolean?)
	if flag == nil or not flag then
		flag = false
	end

	enabled = flag
	position = humanoidRootPart.Position
	alignPosition.Enabled = enabled
	alignOrientation.Enabled = enabled

	for _, v3 in pairs(Enum.HumanoidStateType:GetEnumItems()) do
		if v3 ~= Enum.HumanoidStateType.None then
			humanoid:SetStateEnabled(v3, not enabled)
		end
	end

	for _, part in pairs(parent:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = enabled and "FlightNoCollide" or "Player"
		end
	end

	if enabled then
		humanoid:ChangeState(Enum.HumanoidStateType.PlatformStanding)
	end
end

local v3 = {}
UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType ~= Enum.UserInputType.Keyboard or gameProcessed then
		return
	end

	v3[input.KeyCode] = false
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.UserInputType ~= Enum.UserInputType.Keyboard or gameProcessed then
		return
	end

	v3[input.KeyCode] = true
	local humanoid2 = Players.LocalPlayer.Character:FindFirstChild("Humanoid")

	if input.KeyCode == Enum.KeyCode.E and Players.LocalPlayer:GetAttribute("FlightEnabled") and humanoid2:GetState() ~= Enum.HumanoidStateType.Seated then
		toggleFlight(not enabled)
	end
end)
local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function(dt)
	if enabled then
		if v3[Enum.KeyCode.W] then
			position += humanoidRootPart.CFrame.LookVector * 100 * dt
		end

		if v3[Enum.KeyCode.S] then
			position -= humanoidRootPart.CFrame.LookVector * 100 * dt
		end

		if v3[Enum.KeyCode.D] then
			position += humanoidRootPart.CFrame.RightVector * 100 * dt
		end

		if v3[Enum.KeyCode.A] then
			position -= humanoidRootPart.CFrame.RightVector * 100 * dt
		end

		if v3[Enum.KeyCode.Q] or v3[Enum.KeyCode.LeftControl] then
			position -= humanoidRootPart.CFrame.UpVector * 100 * dt
		end

		if v3[Enum.KeyCode.Space] then
			position += humanoidRootPart.CFrame.UpVector * 100 * dt
		end

		alignPosition.Position = position
		alignOrientation.CFrame = currentCamera.CFrame
	end
end)
Players.LocalPlayer:GetAttributeChangedSignal("FlightEnabled"):Connect(function()
	task.wait(0.03333333333333333)
	toggleFlight(Players.LocalPlayer:GetAttribute("FlightEnabled"))
end)