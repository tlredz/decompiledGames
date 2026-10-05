local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
game:GetService("Workspace")
local open_treasure = ReplicatedStorage:WaitForChild("events"):WaitForChild("open_treasure")

-- equivalent calls inferred from this helper; original call sites unknown
local function onProximityPromptTriggered(_, parent)
	if parent:GetAttribute("id") then
		open_treasure:FireServer(parent:GetAttribute("id"))
	else
		warn("WHATS MY ID!!!")
	end
end

script.Parent:WaitForChild("ProximityPrompt").Triggered:Connect(function(_)
	onProximityPromptTriggered(nil, script.Parent) -- equivalent call inferred; original call site unknown
end)