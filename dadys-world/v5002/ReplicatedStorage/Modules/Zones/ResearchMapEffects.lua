local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HighlightController = require(ReplicatedStorage.SharedUtils.HighlightController)
local CollectionService = game:GetService("CollectionService")
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(255, 255, 255)
return {
	ClientAbility = function(_, instance)
		while instance and instance.Parent do
			if workspace:FindFirstChild("CurrentRoom") then
				if workspace.CurrentRoom:FindFirstChildWhichIsA("Model") and workspace.Info.FloorActive.Value then
					local tagged = CollectionService:GetTagged("ResearchCapsule")

					for _, v in ipairs(tagged) do
						if v:IsDescendantOf(workspace) and v.PrimaryPart and instance.PrimaryPart then
							HighlightController:PlayHighlight(v, "Research", {
								FillColor = color2,
								FillTransparency = 0.3,
								OutlineColor = color,
								OutlineTransparency = 0,
								Priority = HighlightController.Priority.TRINKET,
								Decay = 3,
								Billboard = {
									Label = "RESEARCH",
									Template = "HolidayWarningIcon",
									Size = UDim2.new(12, 0, 12, 0),
									StudsOffset = createVector(0, 5, 0)
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