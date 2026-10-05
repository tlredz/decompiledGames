local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local flag = false
local RagdollController = {}

function RagdollController.FrameworkStart()
	Players.LocalPlayer.CharacterAdded:Connect(function(_)
		flag = false
	end)
	RunService.Stepped:Connect(function(_)
		if not flag then
			return
		end

		local character = Players.LocalPlayer.Character

		if not character then
			return
		end

		for _, part in character:GetChildren() do
			if part:IsA("BasePart") then
				part.CanCollide = true
			end
		end
	end)
end

function RagdollController.EnableRagdoll()
	if flag then
		return
	end

	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	humanoid.PlatformStand = true
	flag = true

	for _, animationConstraint in character:GetDescendants() do
		if animationConstraint:IsA("AnimationConstraint") and animationConstraint.Name ~= "Root" then
			animationConstraint.Enabled = false
		end
	end

	humanoid.RequiresNeck = false
end

function RagdollController.DisableRagdoll()
	if not flag then
		return
	end

	flag = false
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	humanoid.PlatformStand = false

	for _, animationConstraint in character:GetDescendants() do
		if animationConstraint:IsA("AnimationConstraint") and animationConstraint.Name ~= "Root" then
			animationConstraint.Enabled = true
		end
	end

	humanoid.RequiresNeck = true
end

function RagdollController.IsRagdollEnabled()
	return flag
end

return RagdollController