local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Icon = require(ReplicatedStorage:WaitForChild("TopbarPlus"):WaitForChild("Icon"))
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local function getGui()
	for _, screenGui in ipairs(CollectionService:GetTagged("SocialVerifyGui")) do
		if screenGui:IsA("ScreenGui") and screenGui:IsDescendantOf(playerGui) then
			return screenGui
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setGuiEnabled(enabled)
	local gui = getGui()

	if gui then
		gui.Enabled = enabled
	end
end

local v = Icon.new():setName("SocialCodeButton"):setLabel("Social Code")
v.selected:Connect(function()
	setGuiEnabled(true) -- equivalent call inferred; original call site unknown
end)
v.deselected:Connect(function()
	setGuiEnabled(false) -- equivalent call inferred; original call site unknown
end)

local function connectCloseButton(button)
	if button:IsA("GuiButton") and button:IsDescendantOf(playerGui) then
		button.Activated:Connect(function()
			setGuiEnabled(false) -- equivalent call inferred; original call site unknown
			v:deselect()
		end)
	end
end

for _, button in ipairs(CollectionService:GetTagged("SocialVerifyButton")) do
	if button:IsA("GuiButton") and button:IsDescendantOf(playerGui) then
		button.Activated:Connect(function()
			setGuiEnabled(false) -- equivalent call inferred; original call site unknown
			v:deselect()
		end)
	end
end

CollectionService:GetInstanceAddedSignal("SocialVerifyButton"):Connect(connectCloseButton)
task.defer(function()
	setGuiEnabled(false) -- equivalent call inferred; original call site unknown
end)