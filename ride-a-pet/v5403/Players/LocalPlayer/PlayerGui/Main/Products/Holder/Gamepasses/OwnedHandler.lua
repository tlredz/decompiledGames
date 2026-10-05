local parent = script.Parent
local ownedPasses = game.Players.LocalPlayer:WaitForChild("SavedData"):WaitForChild("OwnedPasses")
local giftingMode = parent.Parent.Parent:WaitForChild("GiftingMode")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AutoCollect = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("AutoCollect"))

local function ApplyAutoCollectCard()
	local enabled = AutoCollect.Enabled()

	for _, guiObject in parent:GetDescendants() do
		if guiObject.Name == "AutoCollect" and guiObject:IsA("GuiObject") then
			guiObject.Visible = not enabled
		end
	end
end

ApplyAutoCollectCard()
AutoCollect.Changed():Connect(ApplyAutoCollectCard)

-- equivalent calls inferred from this helper; original call sites unknown
local function HasPass(name: string)
	return string.find(ownedPasses.Value, name .. ",", 1, true) ~= nil
end

local function Refresh()
	for _, guiObject in parent:GetDescendants() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local owned = guiObject:FindFirstChild("Owned")
		local button = guiObject:FindFirstChild(guiObject.Name)

		if not (owned and button and button:IsA("GuiButton")) then
			continue
		end

		local pass = HasPass(guiObject.Name) -- equivalent call inferred; original call site unknown
		owned:SetAttribute("OwnedByPlayer", pass)
		local visible = giftingMode.Visible
		owned.Visible = pass and not visible
		button.Visible = not pass or visible
	end
end

Refresh()
ownedPasses.Changed:Connect(Refresh)
giftingMode:GetPropertyChangedSignal("Visible"):Connect(Refresh)