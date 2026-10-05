local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIController = require(ReplicatedStorage:WaitForChild("UIController"))
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local click = SoundService:WaitForChild("SFX"):WaitForChild("Click")
local settings = playerGui:WaitForChild("Main"):WaitForChild("Settings")
local satchel = script.Parent.Parent:WaitForChild("Satchel"):WaitForChild("Satchel")
local topbarplus = require(satchel:WaitForChild("Packages"):WaitForChild("topbarplus"))
local v = topbarplus.new():setName("Settings"):setImage("rbxassetid://82576192977925"):setImageScale(0.62):setCaption("Settings"):autoDeselect(false):setOrder(0)
local flag = false
v.toggled:Connect(function()
	if flag then
		return
	end

	click:Play()

	if v.isSelected then
		UIController.open(settings)
	else
		UIController.close(settings)
	end
end)
settings:GetPropertyChangedSignal("Visible"):Connect(function()
	if settings.Visible == v.isSelected then
		return
	end

	flag = true

	if settings.Visible then
		v:select()
	else
		v:deselect()
	end

	flag = false
end)
local close = settings:FindFirstChild("Close")

if close and close:IsA("GuiButton") then
	close.Activated:Connect(function()
		click:Play()
		UIController.close(settings)
	end)
end