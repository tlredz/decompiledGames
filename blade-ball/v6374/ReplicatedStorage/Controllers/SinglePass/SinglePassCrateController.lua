local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local random = Random.new()
local playerGui = Players.LocalPlayer.PlayerGui
local v = nil
local v2 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Signal)
local v3 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v4 = require3(ReplicatedStorage2.Packages.Net)
local v5 = require3(ReplicatedStorage2.Shared.CNYEvent.CNYEventCrate)
local v6 = require3(ReplicatedStorage2.Shared.WeightRandom)
require3(ReplicatedStorage2.Common.RewardInfo)
local flag = false
local v7 = {
	Green = {
		Image = "rbxassetid://18661160677",
		Hover = "rbxassetid://18661241239",
		Color = Color3.fromRGB(11, 40, 84),
		BrightColor = Color3.fromRGB(75, 213, 255)
	},
	Purple = {
		Image = "rbxassetid://18661165809",
		Hover = "rbxassetid://18661237514",
		Color = Color3.fromRGB(83, 84, 4),
		BrightColor = Color3.fromRGB(255, 234, 76)
	},
	Yellow = {
		Image = "rbxassetid://18661163512",
		Hover = "rbxassetid://18661242616",
		Color = Color3.fromRGB(84, 7, 8),
		BrightColor = Color3.fromRGB(255, 57, 60)
	}
}
local remoteEvent = v4:RemoteEvent("OpenSummerCrate")
local singlePass = playerGui:WaitForChild("SinglePass")
local unboxGui = singlePass:WaitForChild("UnboxGui")
local weaponsClipping = unboxGui:WaitForChild("WeaponsClipping")
local mover = weaponsClipping:WaitForChild("Scroller"):WaitForChild("Mover")
local unlocked = unboxGui.Unlocked
local unlockedBG = unboxGui.UnlockedBG

local function createTemplate(layoutOrder: number, data, p)
	local clone = weaponsClipping.SwordTemplate.Unique:Clone()
	local v9 = v7[p[data.Value]]
	clone.ImageLabel.Image = data.Icon or ""
	clone.NameOfWeapon.Text = data.DisplayName or ""
	clone.Image = v9.Image
	clone.HoverImage = v9.Hover
	clone.NameOfWeapon.UIStroke.Color = v9.Color
	clone.Visible = true
	clone.LayoutOrder = layoutOrder
	clone.Parent = mover
	return clone
end

local SinglePassCrateController = {}

function SinglePassCrateController:Start()
	v = v2.Client:WaitReplion("Data")
	remoteEvent.OnClientEvent:Connect(function(...)
		self:Open(...)
	end)
end

function SinglePassCrateController:Open(p)
	while flag do
		task.wait()
	end

	flag = true
	unlockedBG.Visible = false
	unlocked.Text = ""
	v3:Lock("SinglePass", true)
	singlePass.UnboxGui.Visible = true
	singlePass.MainFrame.Visible = false
	unboxGui.Position = UDim2.fromScale(0.5, 1.5)
	TweenService:Create(unboxGui, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
		Position = UDim2.fromScale(0.5, 0.5)
	}):Play()
	local probabilitiesByReward = {}
	local v8 = {}

	for _, item in v5.Items do
		probabilitiesByReward[item.Reward] = item.Probability
		v8[item.Reward.Value] = item.Probability <= 0.05 and "Purple" or item.Probability <= 1 and "Yellow" or "Green"
	end

	local picker = v6.getPicker(probabilitiesByReward)

	for i = 1, 60 do
		local v9 = i == 57
		local v10

		if v9 then
			v10 = p
		else
			v10 = picker()
		end

		createTemplate(i, v10, v8)

		if not v9 then
			continue
		end

		local v12 = v7[v8[v10.Value]]

		if not v12 then
			continue
		end

		unlockedBG.BackgroundColor3 = v12.BrightColor
		unlockedBG.Top.BackgroundColor3 = v12.BrightColor
		unlockedBG.Bottom.BackgroundColor3 = v12.BrightColor
	end

	mover.Position = UDim2.new(0, 0, 0.5, 0)
	task.wait(0.5)
	local number = random:NextNumber(-10.1, -10.29)
	local tween = TweenService:Create(mover, TweenInfo.new(6.2, Enum.EasingStyle.Sine), {
		Position = UDim2.new(number, 0, 0.5, 0)
	})
	ReplicatedStorage2.Misc.spinwheel.TimePosition = 2
	ReplicatedStorage2.Misc.spinwheel:Play()
	tween:Play()
	tween.Completed:Wait()
	tween:Destroy()
	ReplicatedStorage2.Misc.spinwheel:Stop()
	ReplicatedStorage2.Misc.reward:Play()
	unlockedBG.Visible = true
	unlocked.Text = string.format("Rolled: %s", p.DisplayName or "")
	task.wait(3)
	TweenService:Create(unboxGui, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Position = UDim2.fromScale(0.5, 1.5)
	}):Play()
	task.wait(0.65)
	flag = false
	v3:Unlock("SinglePass", true)
	singlePass.UnboxGui.Visible = false
	singlePass.MainFrame.Visible = true

	for _, guiObject in mover:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end
end

return SinglePassCrateController