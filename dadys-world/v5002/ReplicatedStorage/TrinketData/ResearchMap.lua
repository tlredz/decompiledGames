local ReplicatedStorage = game:GetService("ReplicatedStorage")
local researchMapEffects = ReplicatedStorage.Modules.Zones.ResearchMapEffects
local v = {
	Fill = Color3.fromRGB(0, 255, 0),
	Outline = Color3.fromRGB(255, 255, 0)
}
local ResearchMap = {
	Name = "Research Map",
	Icon = "rbxassetid://108132017096173",
	Rarity = "Common",
	Description = "Highlights all Research Capsules every 10 seconds during matches.",
	TrinketType = "Passive",
	Cost = 200
}
ResearchMap.Requirement1 = { "Coin", ResearchMap.Cost }
game:GetService("RunService")
local v2 = {}

local function cleanupHighlights()
	for _, v3 in pairs(v2) do
		if v3 and v3.Parent then
			v3:Destroy()
		end
	end

	v2 = {}
end

local function highlightCapsules(_)
	local success, result = pcall(function()
		local researchCapsules = workspace:FindFirstChild("ResearchCapsules")

		if not researchCapsules then
			return
		end

		for _, child in ipairs(researchCapsules:GetChildren()) do
			if v2[child] then
				continue
			end

			local highlight = Instance.new("Highlight")
			highlight.FillColor = v.Fill
			highlight.OutlineColor = v.Outline
			highlight.FillTransparency = 0.5
			highlight.Parent = child
			v2[child] = highlight
		end

		task.delay(3, cleanupHighlights)
	end)

	if not success then
		warn("Failed to highlight research capsules:", result)
	end
end

function ResearchMap.ApplyTrinket(character)
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(character)

	if not playerFromCharacter then
		return
	end

	ReplicatedStorage.Events.ClientAbilityEvent:FireClient(playerFromCharacter, researchMapEffects, character)
end

function ResearchMap.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if trinket1.Value == script.Name then
		trinket1.Value = "None"
		return "Slot1"
	end

	if trinket2.Value ~= script.Name then
		return "CantRemove"
	end

	trinket2.Value = "None"
	return "Slot2"
end

return ResearchMap