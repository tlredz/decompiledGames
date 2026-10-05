local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local ProximityPromptChooser = require(game.ReplicatedStorage.CAM.Client.Components.ProximityPrompt.ProximityPromptChooser)
local ProximityPromptService = game:GetService("ProximityPromptService")
local v = {
	Prompts = {
		Available = {},
		States = {}
	},
	Indicators = {
		Available = {},
		States = {}
	}
}
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.ResetOnSpawn = false
screenGui.Name = "PromptsHolder"
local prompts = game.ReplicatedStorage.CAM.Client.Components.Layout.Visibility.Prompts

function updateIndividualPrompt(p, flag: boolean, p2)
	if v.Prompts.States[p] then
		task.spawn(v.Prompts.States[p])
		v.Prompts.States[p] = nil
	end

	if flag then
		v.Prompts.States[p] = ProximityPromptChooser(screenGui, p, 1, p2)
	end
end

function updateIndividualIndicator(p, flag: boolean, p2)
	if v.Indicators.States[p] then
		task.spawn(v.Indicators.States[p])
		v.Indicators.States[p] = nil
	end

	if flag then
		v.Indicators.States[p] = ProximityPromptChooser(screenGui, p, 2, p2)
	end
end

local value = nil

local function updateVisibility()
	value = prompts.Value

	for k, v2 in v.Prompts.Available do
		updateIndividualPrompt(k, value, v2)
	end

	for k in v.Indicators.Available do
		updateIndividualIndicator(k, value, nil)
	end
end

prompts.Changed:Connect(updateVisibility)
updateVisibility()
ProximityPromptService.PromptShown:Connect(function(p, p2)
	if p.Style ~= Enum.ProximityPromptStyle.Custom then
		return
	end

	v.Prompts.Available[p] = p2
	updateIndividualPrompt(p, value, p2)
end)
ProximityPromptService.PromptHidden:Connect(function(p)
	if p.Style ~= Enum.ProximityPromptStyle.Custom then
		return
	end

	v.Prompts.Available[p] = nil
	updateIndividualPrompt(p, false)
end)
ProximityPromptService.IndicatorShown:Connect(function(p, p2)
	if p.Style == Enum.ProximityPromptStyle.Custom then
		v.Indicators.Available[p] = true
		updateIndividualIndicator(p, value, p2)
	end
end)
ProximityPromptService.IndicatorHidden:Connect(function(p)
	if v.Indicators.Available[p] ~= nil then
		v.Indicators.Available[p] = nil
	end

	updateIndividualIndicator(p, nil)
end)