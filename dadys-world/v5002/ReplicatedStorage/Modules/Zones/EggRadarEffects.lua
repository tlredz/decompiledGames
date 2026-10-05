local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HighlightController = require(ReplicatedStorage.SharedUtils.HighlightController)
local CollectionService = game:GetService("CollectionService")
return {
	ClientAbility = function(p, p2)
		print("[EggRadar] ClientAbility started for", p.Name)

		while p2 and p2.Parent do
			if workspace:FindFirstChild("CurrentRoom") then
				if workspace.CurrentRoom:FindFirstChildWhichIsA("Model") and workspace.Info.FloorActive.Value then
					local success, result = pcall(function()
						local result2 = {}

						for _, v in ipairs(CollectionService:GetTagged("EasterEgg")) do
							if v:IsDescendantOf(workspace) then
								table.insert(result2, v)
							end
						end

						for _, v in ipairs(CollectionService:GetTagged("Currency")) do
							if not v:IsDescendantOf(workspace) then
								continue
							end

							if not (v:GetAttribute("CurrencyType") == "EasterEgg" or v.Name:find("Easter") or v.Name:find("Egg")) then
								continue
							end

							table.insert(result2, v)
						end

						return result2
					end)
					print("[EggRadar] Scan found", not success and 0 or #result or 0, "Easter eggs in room")

					if success and #result > 0 then
						for _, part in ipairs(result) do
							if not (part:IsDescendantOf(workspace) and (part.PrimaryPart or part:IsA("BasePart"))) then
								continue
							end

							local _ = part.PrimaryPart or part
							HighlightController:PlayHighlight(part, "Item", {
								FillColor = Color3.fromRGB(255, 192, 203),
								FillTransparency = 1,
								OutlineColor = Color3.fromRGB(255, 192, 203),
								OutlineTransparency = 0,
								Priority = HighlightController.Priority.TRINKET,
								Decay = 3,
								Billboard = {
									Label = "BASKET",
									Template = "HolidayWarningIcon",
									Size = UDim2.new(12, 0, 12, 0),
									StudsOffset = createVector(0, 5, 0)
								}
							})
						end
					end

					task.wait(15)
				else
					task.wait(1)
				end
			else
				task.wait(1)
			end
		end
	end
}