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
local v5 = require3(ReplicatedStorage2.Shared.SinglePass.SinglePassCrate)
local v6 = require3(ReplicatedStorage2.Shared.WeightRandom)
require3(ReplicatedStorage2.Common.RewardInfo)
local flag = false
local v7 = {
	Green = {
		Image = "rbxassetid://93776847894210",
		Hover = "rbxassetid://78049756345053"
	},
	Purple = {
		Image = "rbxassetid://76646398204401",
		Hover = "rbxassetid://109871120647836"
	},
	Yellow = {
		Image = "rbxassetid://85495068885632",
		Hover = "rbxassetid://129630194296730"
	}
}
local remoteEvent = v4:RemoteEvent("OpenSinglePassCrate")
local singlePass = playerGui:WaitForChild("SinglePass")
local unboxGui = singlePass:WaitForChild("UnboxGui")
local weaponsClipping = unboxGui:WaitForChild("WeaponsClipping")
local scroller = weaponsClipping:WaitForChild("Scroller")
local mover = scroller:WaitForChild("Mover")
local unlocked = unboxGui.Unlocked
local fade = unboxGui.Fade

local function createTemplate(layoutOrder: number, data, p)
	local clone = weaponsClipping.SwordTemplate.Unique:Clone()
	local v8 = p[data.Value]
	clone.LayoutOrder = layoutOrder
	clone.ImageLabel.Image = data.Icon or ""
	clone.NameOfWeapon.Text = data.DisplayName or ""
	clone.Visible = true
	clone.Image = v7[v8].Image
	clone.HoverImage = v7[v8].Hover
	clone.Parent = mover
	return clone
end

local SinglePassAnimationController = {}

function SinglePassAnimationController:Start()
	v = v2.Client:WaitReplion("Data")
	remoteEvent.OnClientEvent:Connect(function(...)
		self:Open(...)
	end)
end

function SinglePassAnimationController:Open(p)
	while flag do
		task.wait()
	end

	flag = true
	fade.Visible = false
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
	local v9 = nil

	for i = 1, 60 do
		local v10 = i == 57
		local v11

		if v10 then
			v11 = p
		else
			v11 = picker()
		end

		local clone = weaponsClipping.SwordTemplate.Unique:Clone()
		local v12 = v8[v11.Value]
		clone.LayoutOrder = i
		clone.ImageLabel.Image = v11.Icon or ""
		clone.NameOfWeapon.Text = v11.DisplayName or ""
		clone.Visible = true
		clone.Image = v7[v12].Image
		clone.HoverImage = v7[v12].Hover
		clone.Parent = mover

		if v10 then
			v9 = clone
		end
	end

	mover.Position = UDim2.new(0, 0, 0.484, 0)
	task.wait(0.5)
	local v10 = mover.AbsoluteSize.X / 2 - (v9.AbsolutePosition.X + v9.AbsoluteSize.X / 2 - scroller.AbsolutePosition.X)
	local tween = TweenService:Create(mover, TweenInfo.new(6.2, Enum.EasingStyle.Sine), {
		Position = UDim2.fromOffset(v10, 0) + UDim2.fromScale(0, 0.484)
	})
	ReplicatedStorage2.Misc.spinwheel.TimePosition = 2
	ReplicatedStorage2.Misc.spinwheel:Play()
	tween:Play()
	tween.Completed:Wait()
	tween:Destroy()
	ReplicatedStorage2.Misc.spinwheel:Stop()
	ReplicatedStorage2.Misc.reward:Play()
	fade.Visible = true
	unlocked.Text = string.format("Rolled: %s", p.DisplayName)
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

return SinglePassAnimationController