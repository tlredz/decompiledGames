local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
game:GetService("Debris")
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local zipline = script:WaitForChild("Zipline")
local hook = script:WaitForChild("Hook")
local unhook = script:WaitForChild("Unhook")
local line = script:WaitForChild("Line")
local v = nil
local flag = false
local v2 = {
	[Enum.HumanoidStateType.Seated] = true,
	[Enum.HumanoidStateType.PlatformStanding] = true,
	[Enum.HumanoidStateType.Dead] = true,
	[Enum.HumanoidStateType.Physics] = true,
	[Enum.HumanoidStateType.Flying] = true
}
local track = humanoid:WaitForChild("Animator"):LoadAnimation(zipline)
track.Looped = true
track.Priority = Enum.AnimationPriority.Action4
local bezier = require(ReplicatedStorage.shared.utils.bezier)

local function travelZipline(children, value, parent)
	v = parent
	track:Play()
	track:AdjustSpeed(1.5)
	hook:Play()
	local v3 = (children[1].Position - children[#children].Position).Magnitude / value
	local positions = {}

	for i = 1, #children do
		table.insert(positions, children[i].Position)
	end

	local v4 = 1 / v3
	ReplicatedStorage.events.ridezipline:FireServer(true)
	line:Play()
	local attachment = Instance.new("Attachment")
	attachment.Name = "RootPartAlignAttachment"
	attachment.Parent = character.HumanoidRootPart
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPosition.Attachment0 = attachment
	alignPosition.MaxForce = 100000
	alignPosition.MaxVelocity = v3 * 3.5
	alignPosition.Responsiveness = 100
	alignPosition.Name = "ZiplineAlignPos"
	alignPosition.Parent = character.HumanoidRootPart
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Attachment0 = attachment
	alignOrientation.MaxTorque = 100000
	alignOrientation.MaxAngularVelocity = 1e999
	alignOrientation.Responsiveness = 100
	alignOrientation.Name = "ZiplineAlignOrient"
	alignOrientation.Parent = character.HumanoidRootPart

	for i = 0, 1 - v4, v4 do
		if not (v and alignPosition and alignOrientation) then
			break
		end

		local node = bezier.getNode(i, unpack(positions))
		local node2 = bezier.getNode(i + v4, unpack(positions))
		local magnitude = (node - node2).Magnitude
		local cFrame = CFrame.new(node, node2) * CFrame.new(0, 0, -magnitude / 2)
		alignPosition.Position = (cFrame * CFrame.new(0, -2.6, 0)).Position
		alignOrientation.CFrame = cFrame
		task.wait(0.01)
	end

	while attachment.Parent and v == parent and (attachment.WorldPosition - alignPosition.Position).Magnitude > 1 do
		RunService.Heartbeat:Wait()
	end

	alignPosition:Destroy()
	alignOrientation:Destroy()
	attachment:Destroy()

	if v == parent or not v then
		line:Stop()
		unhook:Play()
		track:Stop()
		ReplicatedStorage.events.ridezipline:FireServer(false)
		v = nil
	end
end

local function bodyPartTouched(instance)
	if instance.Name == "StartNode" and instance.Parent.Name == "zipline" and instance:IsDescendantOf(workspace.world.ziplines) and v ~= instance.Parent and not v2[humanoid:GetState()] then
		local children = {}

		for _, child in pairs(instance.Parent.Nodes:GetChildren()) do
			if string.find(child.Name, "Node", 1, true) then
				children[tonumber(string.split(child.Name, "Node")[2])] = child
			end
		end

		travelZipline(children, instance.Parent:FindFirstChild("Speed").Value, instance.Parent)
	end
end

task.delay(2.5, function()
	for _, part in pairs(character:GetChildren()) do
		if part:IsA("BasePart") then
			part.Touched:Connect(bodyPartTouched)
		end
	end
end)
UserInputService.JumpRequest:Connect(function()
	if v then
		if flag then
			return
		end

		flag = true
		v = nil
		task.delay(0.5, function()
			flag = false
		end)
	end
end)
humanoid.StateChanged:Connect(function(_, p)
	if v and v2[p] then
		v = nil
	end
end)
ReplicatedStorage:WaitForChild("events"):WaitForChild("exitzipline").Event:Connect(function()
	v = nil
end)