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
Random.new()
local playerGui = Players.LocalPlayer.PlayerGui
local v = nil
local v2 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Signal)
local v3 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v4 = require3(ReplicatedStorage2.Packages.Net)
local v5 = require3(ReplicatedStorage2.Shared.Merchant.MerchantCrate)
local v6 = require3(ReplicatedStorage2.Shared.WeightRandom)
require3(ReplicatedStorage2.Common.RewardInfo)
local flag = false
local remoteEvent = v4:RemoteEvent("OpenMerchantCrate")
local unboxGui = playerGui:WaitForChild("MerchantCrate"):WaitForChild("UnboxGui")
local weaponsClipping = unboxGui:WaitForChild("WeaponsClipping")
local scroller = weaponsClipping:WaitForChild("Scroller")
local mover = scroller:WaitForChild("Mover")
local unlocked = unboxGui.Unlocked
local fade = unboxGui.Fade
local X = unboxGui.X

local function createTemplate(layoutOrder: number, p)
	local clone = weaponsClipping.SwordTemplate.Unique:Clone()
	clone.LayoutOrder = layoutOrder
	clone.ImageLabel.Image = p.Icon or ""
	clone.NameOfWeapon.Text = p.DisplayName or ""
	clone.Parent = mover
	return clone
end

local MerchantCrateAnimationController = {}

function MerchantCrateAnimationController:Start()
	v = v2.Client:WaitReplion("Data")
	remoteEvent.OnClientEvent:Connect(function(...)
		self:Open(...)
	end)
end

function MerchantCrateAnimationController:Open(p: string, p2, _: boolean?)
	while flag do
		task.wait()
	end

	flag = true
	fade.Visible = false
	unlocked.Text = ""
	X.Visible = false
	v3:Lock("MerchantCrate", true)
	v3:Open("MerchantCrate", true)
	unboxGui.Position = UDim2.fromScale(0.5, 1.5)
	TweenService:Create(unboxGui, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
		Position = UDim2.fromScale(0.5, 0.5)
	}):Play()
	local chancesByReward = {}

	for _, v7 in v5[p] do
		chancesByReward[v7.Reward] = v7.Chance
	end

	local picker = v6.getPicker(chancesByReward)
	local v7 = nil

	for i = 1, 60 do
		local v8 = i == 57
		local v9

		if v8 then
			v9 = p2
		else
			v9 = picker()
		end

		local clone = weaponsClipping.SwordTemplate.Unique:Clone()
		clone.LayoutOrder = i
		clone.ImageLabel.Image = v9.Icon or ""
		clone.NameOfWeapon.Text = v9.DisplayName or ""
		clone.Parent = mover

		if v8 then
			v7 = clone
		end
	end

	mover.Position = UDim2.new()
	task.wait(0.5)
	local v8 = mover.AbsoluteSize.X / 2 - (v7.AbsolutePosition.X + v7.AbsoluteSize.X / 2 - scroller.AbsolutePosition.X)
	local tween = TweenService:Create(mover, TweenInfo.new(6.2, Enum.EasingStyle.Sine), {
		Position = UDim2.fromOffset(v8, 0)
	})
	ReplicatedStorage2.Misc.spinwheel.TimePosition = 2
	ReplicatedStorage2.Misc.spinwheel:Play()
	tween:Play()
	tween.Completed:Wait()
	tween:Destroy()
	ReplicatedStorage2.Misc.spinwheel:Stop()
	ReplicatedStorage2.Misc.reward:Play()
	fade.Visible = true
	unlocked.Text = string.format("Rolled: %s", p2.DisplayName)
	task.wait(3)
	TweenService:Create(unboxGui, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Position = UDim2.fromScale(0.5, 1.5)
	}):Play()
	task.wait(0.65)
	flag = false
	v3:Unlock("MerchantCrate", true)
	v3:Close("MerchantCrate", true)

	for _, guiObject in mover:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	local v9 = v2.Client:WaitReplion("MerchantShop")

	if v9 and v9:Get("Active") then
		v3:Open("Merchant")
	end
end

return MerchantCrateAnimationController