local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local events = ReplicatedStorage:WaitForChild("events")
local localPlayer = Players.LocalPlayer
events.RagdollMessage.OnClientEvent:Connect(function(platformStand)
	assert(typeof(platformStand) == "boolean", "RagdollMessage is not a boolean")
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	humanoid.PlatformStand = platformStand
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, platformStand)
end)