local HalloweenUtil = {}
local RunService = game:GetService("RunService")
RunService:IsServer()

function toggleLight(instance, enabled)
	if enabled then
		instance.Color = Color3.fromRGB(213, 115, 61)
		instance.PointLight.Enabled = true
	else
		instance.Color = Color3.fromRGB(24, 24, 24)
		instance.PointLight.Enabled = false
	end

	for _, child in pairs(instance:GetChildren()) do
		if child.Name == "LightParticles" then
			child.Enabled = enabled
		end
	end

	if enabled then
		instance:AddTag("FlickeringPart")
	else
		instance:RemoveTag("FlickeringPart")
	end
end

function HalloweenUtil.SetHouseActivated(instance, p)
	local lighting = instance:WaitForChild("Functional"):WaitForChild("Lighting")

	for _, child in pairs(lighting:GetChildren()) do
		if child.Name == "Window" then
			toggleLight(child, p)
		elseif child.Name == "Lantern" then
			toggleLight(child.PrimaryPart, p)
		elseif child.Name == "JackoLantern" then
			for _, part in pairs(child.Top:GetChildren()) do
				if part:IsA("BasePart") then
					part.Transparency = p and 0 or 1
				end
			end

			child.Eyes.Transparency = p and 0 or 1
			child.Inner.Color = p and Color3.fromRGB(213, 164, 109) or Color3.fromRGB(86, 59, 26)
			toggleLight(child.Eyes, p)
		end
	end
end

return HalloweenUtil