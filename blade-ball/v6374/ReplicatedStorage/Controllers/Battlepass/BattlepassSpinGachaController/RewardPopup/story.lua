local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Trove)
local v2 = require3(ReplicatedStorage2.Shared.BattlepassUIType)
local playerGui = Players.LocalPlayer.PlayerGui
local battlepass = playerGui:WaitForChild("Battlepass")
local main

if v2 == "Window" then
	main = playerGui:WaitForChild("BattlepassSpinGacha").Main
else
	main = battlepass.Main.Background.Views.SpinGacha
end

local rewardPopup = main.RewardPopup
rewardPopup.Visible = false
rewardPopup.Parent = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function FastTween(p, tweenInfo, p2)
	local tween = TweenService:Create(p, tweenInfo, p2)
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	tween:Play()
	return tween
end

local function Animate(text: string, image: string)
	local quart = Enum.EasingStyle.Quart
	local v3 = v.new()
	local clone = rewardPopup:Clone()
	clone.BG.BackgroundTransparency = 1
	clone.BG.Visible = true
	clone.Frame.Visible = false
	clone.Frame.Circle.ImageTransparency += 1
	clone.Frame.Vector.ImageTransparency += 1
	clone.Frame.Header.Position -= UDim2.fromScale(0, 1)
	clone.Frame.SuperRewardBG.Position += UDim2.fromScale(0, 1)
	clone.Frame.Back.Position += UDim2.fromScale(0, 1)
	clone.Frame.SuperRewardBG.Label.Text = text
	clone.Frame.Vector.Image = image
	clone.Visible = true
	clone.Parent = main
	;(FastTween(clone.BG, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
		BackgroundTransparency = 0.2
	})).Completed:Wait()
	clone.Frame.Visible = true
	;(FastTween(clone.Frame.Back, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {
		Position = clone.Frame.Back.Position - UDim2.fromScale(0, 1)
	})).Completed:Wait()
	task.wait(0.1)
	FastTween(clone.Frame.Header, TweenInfo.new(0.22, quart), {
		Position = clone.Frame.Header.Position + UDim2.fromScale(0, 1)
	}) -- equivalent call inferred; original call site unknown
	FastTween(clone.Frame.SuperRewardBG, TweenInfo.new(0.22, quart), {
		Position = clone.Frame.SuperRewardBG.Position - UDim2.fromScale(0, 1)
	}) -- equivalent call inferred; original call site unknown
	;(FastTween(clone.Frame.Vector, TweenInfo.new(0.22, quart), {
		ImageTransparency = 0
	})).Completed:Wait()
	clone.Frame.Circle.ImageTransparency -= 1
	local fastTween = FastTween(
		clone.Frame.Circle,
		TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1),
		{
			Rotation = 359.9
		}
	) -- equivalent call inferred; original call site unknown
	local fastTween2 = FastTween(
		clone.Frame.Circle,
		TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, true),
		{
			ImageTransparency = 0.5
		}
	) -- equivalent call inferred; original call site unknown
	task.wait(1.5)
	fastTween:Destroy()
	fastTween2:Destroy()
	;(FastTween(clone.Frame.Circle, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
		ImageTransparency = 1
	})).Completed:Wait()
	FastTween(clone.BG, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {
		BackgroundTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	FastTween(clone.Frame.Back, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {
		Position = clone.Frame.Back.Position + UDim2.fromScale(0, 1)
	}) -- equivalent call inferred; original call site unknown
	FastTween(clone.Frame.Header, TweenInfo.new(0.22, quart), {
		Position = clone.Frame.Header.Position - UDim2.fromScale(0, 1)
	}) -- equivalent call inferred; original call site unknown
	FastTween(clone.Frame.SuperRewardBG, TweenInfo.new(0.22, quart), {
		Position = clone.Frame.SuperRewardBG.Position + UDim2.fromScale(0, 1)
	}) -- equivalent call inferred; original call site unknown
	;(FastTween(clone.Frame.Vector, TweenInfo.new(0.22, quart), {
		ImageTransparency = 1
	})).Completed:Wait()
	v3:Clean()
	v3:Destroy()
	clone:Destroy()
end

return Animate