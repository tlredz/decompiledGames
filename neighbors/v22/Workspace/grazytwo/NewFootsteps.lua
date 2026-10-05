local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")
local footstepSounds = ReplicatedStorage.Assets.FootstepSounds
local running = character.PrimaryPart:WaitForChild("Running")
running.Volume = 0

for _, child in footstepSounds:GetChildren() do
	child.Volume = 0
	child.Playing = true
	local clone = child:Clone()
	clone.Parent = character.PrimaryPart
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetMaterial()
	return humanoid.FloorMaterial
end

RunService.Heartbeat:Connect(function()
	local floorMaterial = GetMaterial() -- equivalent call inferred; original call site unknown
	local sound = character.PrimaryPart:FindFirstChild(floorMaterial.Name)

	for _, sound2 in character.PrimaryPart:GetChildren() do
		if sound2:IsA("Sound") and footstepSounds:FindFirstChild(sound2.Name) then
			sound2.Volume = 0
		end
	end

	if sound and sound:IsA("Sound") and humanoid:GetState() == Enum.HumanoidStateType.Running and character.PrimaryPart.AssemblyLinearVelocity.Magnitude > 2 then
		sound.PlaybackSpeed = humanoid.WalkSpeed / 12
		sound.Volume = 0.15
	end
end)