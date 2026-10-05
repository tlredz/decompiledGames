local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HighlightController = require(ReplicatedStorage.SharedUtils.HighlightController)
local CollectionService = game:GetService("CollectionService")
return {
	ClientAbility = function(_, instance)
		while instance and instance.Parent do
			if workspace:FindFirstChild("CurrentRoom") then
				if workspace.CurrentRoom:FindFirstChildWhichIsA("Model") and workspace.Info.FloorActive.Value then
					local tagged = CollectionService:GetTagged("Ornament")

					for _, v in ipairs(tagged) do
						if v:IsDescendantOf(workspace) and v.PrimaryPart and instance.PrimaryPart then
							HighlightController:PlayHighlight(v, "Item", {
								FillColor = Color3.fromRGB(255, 215, 0),
								FillTransparency = 1,
								OutlineColor = Color3.fromRGB(255, 215, 0),
								OutlineTransparency = 0,
								Priority = HighlightController.Priority.TRINKET,
								Decay = 3,
								Billboard = {
									Label = "ORNAMENT",
									Template = "HolidayWarningIcon",
									Size = UDim2.new(12, 0, 12, 0),
									StudsOffset = createVector(0, 5, 0),
									TextColor = Color3.fromRGB(255, 215, 0),
									IconColor = Color3.fromRGB(255, 215, 0)
								}
							})
						end
					end

					task.wait(10)
				else
					task.wait(1)
				end
			else
				task.wait(1)
			end
		end
	end
}