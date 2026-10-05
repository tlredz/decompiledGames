local parent = script.Parent

if not parent:IsA("Tool") then
	return
end

local parent2 = nil
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fx = require(ReplicatedStorage.shared.modules:WaitForChild("fx"))

local function VisibleModels(enabled)
	local parachute = parent:FindFirstChild("Details") and parent.Details:FindFirstChild("parachute")

	if parachute then
		local trailL = parachute:FindFirstChild("trailL")
		local trailR = parachute:FindFirstChild("trailR")

		if trailL then
			trailL.Enabled = enabled
		end

		if trailR then
			trailR.Enabled = enabled
		end
	end

	local gliderActiveSound = parent:FindFirstChild("handle") and parent.handle:FindFirstChild("gliderActiveSound")

	if gliderActiveSound then
		if enabled then
			gliderActiveSound:Play()
		else
			gliderActiveSound:Stop()
		end
	end
end

parent.Equipped:Connect(function()
	parent2 = parent.Parent
	local humanoidRootPart = parent.Parent:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		VisibleModels(true)
		fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.item.gliderDeploy, humanoidRootPart, true)
	end
end)
parent.Unequipped:Connect(function()
	VisibleModels(false)
end)
VisibleModels(false)