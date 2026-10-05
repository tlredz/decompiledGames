local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Icon = require(ReplicatedStorage:WaitForChild("TopbarPlus"):WaitForChild("Icon"))
local CameraUISystem = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("CameraUISystem"))
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local visible2 = true

local function setUIVisible(visible)
	visible2 = visible

	for _, frame in ipairs(CollectionService:GetTagged("UI")) do
		if frame:IsA("Frame") and frame:IsDescendantOf(playerGui) then
			frame.Visible = visible
		end
	end

	CameraUISystem.SetUIHidden(not visible)
end

CollectionService:GetInstanceAddedSignal("UI"):Connect(function(frame)
	if frame:IsA("Frame") and frame:IsDescendantOf(playerGui) then
		frame.Visible = visible2
	end
end)
local v2 = Icon.new():setName("UIToggle"):setImage("rbxassetid://94652404380463", "Selected"):setImage(
	"rbxassetid://106788007315711",
	"Deselected"
):setLabel("")
v2.selected:Connect(function()
	setUIVisible(false)
end)
v2.deselected:Connect(function()
	setUIVisible(true)
end)