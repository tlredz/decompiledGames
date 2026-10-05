local localPlayer = game.Players.LocalPlayer
local replicatedFirst = game.ReplicatedFirst
local starterGui = game.StarterGui
replicatedFirst:RemoveDefaultLoadingScreen()
starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
local parent = script.Parent
local main = parent:WaitForChild("Main")
local container = parent:WaitForChild("Main"):WaitForChild("Container")
local color = container:WaitForChild("Color")
local grey = container:WaitForChild("Grey")
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
local tween = TweenService:Create(main, tweenInfo, {
	BackgroundTransparency = 1
})
local tween2 = TweenService:Create(color, tweenInfo, {
	ImageTransparency = 1
})
local v = false

local function fadeOutOfLoading()
	tween2:Play()
	tween:Play()
	task.wait(0.5)
	parent.Enabled = false
	starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
	starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
	starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Captures, true)
	starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.SelfView, true)
end

local function initialize()
	task.spawn(function()
		while task.wait() and not v do
			starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		end
	end)

	repeat
		task.wait()
	until localPlayer.Character ~= nil

	grey.Visible = false
	task.wait(1)
	fadeOutOfLoading()
	v = true
	local newUI2025 = game.StarterGui:WaitForChild("NewUI2025")
	newUI2025.Enabled = true
	local newUI2025_2 = game.Players.LocalPlayer.PlayerGui:WaitForChild("NewUI2025")
	newUI2025_2.Enabled = true
end

initialize()