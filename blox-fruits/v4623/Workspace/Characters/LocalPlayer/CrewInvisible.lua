local localPlayer = game.Players.LocalPlayer
local humanoidRootPart = localPlayer.Character:WaitForChild("HumanoidRootPart")

-- equivalent calls inferred from this helper; original call sites unknown
local function added(child)
	if child.Name == "InfoBBG" then
		child.PlayerToHideFrom = localPlayer
	end
end

humanoidRootPart.ChildAdded:Connect(added)

for _, child in pairs(humanoidRootPart:GetChildren()) do
	added(child) -- equivalent call inferred; original call site unknown
end