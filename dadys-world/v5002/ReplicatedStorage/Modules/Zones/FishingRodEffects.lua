local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HighlightController = require(ReplicatedStorage.SharedUtils.HighlightController)
local color = Color3.fromRGB(61, 151, 220)

local function highlightGenerators()
	local currentRoom = workspace:FindFirstChild("CurrentRoom")

	if not currentRoom then
		return 0
	end

	local model = currentRoom:FindFirstChildOfClass("Model")

	if not model then
		return 0
	end

	local generators = model:FindFirstChild("Generators")

	if not generators then
		return 0
	end

	local count = 0

	for _, model2 in ipairs(generators:GetChildren()) do
		if not (model2:IsA("Model") and model2.PrimaryPart) then
			continue
		end

		local stats = model2:FindFirstChild("Stats")
		local completed = stats and stats:FindFirstChild("Completed")

		if not (completed and completed.Value ~= true) then
			continue
		end

		HighlightController:PlayHighlight(model2, "Machine", {
			FillColor = color,
			FillTransparency = 1,
			OutlineColor = color,
			OutlineTransparency = 0,
			Priority = HighlightController.Priority.TRINKET,
			Decay = 5
		})
		count += 1
		task.wait()
	end

	return count
end

return {
	ClientAbility = function(_, p)
		local flag = true

		while p and p.Parent do
			local info = workspace:FindFirstChild("Info")
			local floorActive = info and info:FindFirstChild("FloorActive")

			if floorActive then
				if floorActive.Value == true then
					if flag then
						local v = 0
						local success, result = pcall(function()
							v = highlightGenerators()
						end)

						if success then
							if v > 0 then
								flag = false
							end
						else
							warn("[FishingRod] highlight error:", result)
						end
					end

					task.wait(0.5)
				else
					task.wait(0.5)
					flag = true
				end
			else
				task.wait(1)
			end
		end
	end
}