local createVector = vector.create
local MoonPackHeirloomEffects = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HighlightController = require(ReplicatedStorage.SharedUtils.HighlightController)
game:GetService("CollectionService")

function MoonPackHeirloomEffects.ClientAbility(_, _)
	TweenInfo.new(0.5, Enum.EasingStyle.Linear)
	local generatorsCompleted = workspace.Info:WaitForChild("GeneratorsCompleted")
	generatorsCompleted:GetPropertyChangedSignal("Value"):Connect(function()
		if generatorsCompleted.Value <= 0 then
			return
		end

		for _, model in pairs(workspace.InGamePlayers:GetChildren()) do
			if model:IsA("Model") and model.PrimaryPart then
				HighlightController:PlayHighlight(model, "Ally", {
					FillColor = Color3.fromRGB(255, 255, 255),
					FillTransparency = 1,
					OutlineColor = Color3.fromRGB(255, 255, 255),
					OutlineTransparency = 0,
					Priority = HighlightController.Priority.TRINKET,
					Decay = 3,
					OpaqueDuration = 2.5,
					Billboard = {
						Label = "TEAMMATE",
						Size = UDim2.new(16, 0, 16, 0),
						ExtentsOffset = createVector(0, 1.5, 0)
					}
				})
			end
		end
	end)
end

return MoonPackHeirloomEffects