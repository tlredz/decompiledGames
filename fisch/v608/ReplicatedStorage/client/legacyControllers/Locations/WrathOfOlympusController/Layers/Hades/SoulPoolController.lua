local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatusEffectsController = require(ReplicatedStorage.client.legacyControllers.StatusEffectsController)
local _ = Players.LocalPlayer
local fishing = Workspace:WaitForChild("zones"):WaitForChild("fishing", 1e999)

-- equivalent calls inferred from this helper; original call sites unknown
local function checkVision()
	return StatusEffectsController:HasStatusOfType("SoulVision")
end

local function updateVision()
	local enabled = checkVision() -- equivalent call inferred; original call site unknown

	for _, child in ipairs(fishing:GetChildren()) do
		if not (child:GetAttribute("Hidden") and child.Name == "Soul Pool") then
			continue
		end

		local radar1 = child:FindFirstChild("radar1")
		local radar2 = child:FindFirstChild("radar2")

		if radar1 then
			radar1.Enabled = enabled
		end

		if radar2 then
			radar2.Enabled = enabled
		end
	end
end

return {
	Start = function(_)
		StatusEffectsController.StatusAdded:Connect(function(p)
			if p.Id == "SoulVision" then
				updateVision()
			end
		end)
		StatusEffectsController.StatusRemoved:Connect(updateVision)
		fishing.ChildAdded:Connect(function(child)
			if not (child:GetAttribute("Hidden") and child.Name == "Soul Pool") then
				return
			end

			local enabled = checkVision() -- equivalent call inferred; original call site unknown
			local radar1 = child:WaitForChild("radar1", 5)
			local radar2 = child:WaitForChild("radar2", 5)

			if radar1 then
				radar1.Enabled = enabled
			end

			if radar2 then
				radar2.Enabled = enabled
			end
		end)
		updateVision()
	end
}