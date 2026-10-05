game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BaseInteractable = require(script.Parent.BaseInteractable)
local _ = Players.LocalPlayer
local v = false

local function ToggleModelVisibility(instance, p)
	for _, part in instance:GetChildren() do
		if part:IsA("BasePart") then
			part.Transparency = p and 0.75 or 0
		end
	end

	instance.PrimaryPart.ProximityPrompt.ActionText = p and "Return sponge" or "Get sponge"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ToggleTool(p)
	v = not v
	ToggleModelVisibility(p, v)
	script.GetTool:FireServer()
end

return function(instance)
	local v2 = BaseInteractable.new()
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.Parent = instance.PrimaryPart
	proximityPrompt.MaxActivationDistance = 20
	proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	proximityPrompt.ActionText = "Get sponge"
	proximityPrompt.Triggered:Connect(function(_)
		v2.State = true
		ToggleTool(instance) -- equivalent call inferred; original call site unknown
	end)

	function v2.Reset(_)
		ToggleModelVisibility(instance, false)
		v = false
	end

	return v2
end