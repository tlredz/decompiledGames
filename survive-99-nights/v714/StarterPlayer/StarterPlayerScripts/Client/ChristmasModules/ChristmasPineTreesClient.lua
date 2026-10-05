local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ChristmasPineTreesClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local christmasTrees = Client.Interface.ChristmasTrees
local christmasTreeCount = 0
local christmasTreeGoal = 15
local v = false
local flag = false

function ShowGui()
	if v or flag then
		return
	end

	v = true
	christmasTrees.Visible = true
	TweenService:Create(christmasTrees.TreeIcon, TweenInfo.new(2, Enum.EasingStyle.Linear), {
		ImageTransparency = 0
	}):Play()
	TweenService:Create(christmasTrees.TextLabel, TweenInfo.new(2, Enum.EasingStyle.Linear), {
		TextTransparency = 0
	}):Play()
	TweenService:Create(christmasTrees.TextLabel.UIStroke, TweenInfo.new(2, Enum.EasingStyle.Linear), {
		Transparency = 0
	}):Play()
end

function HideGui()
	if not v then
		return
	end

	v = false
	TweenService:Create(christmasTrees.TreeIcon, TweenInfo.new(2, Enum.EasingStyle.Linear), {
		ImageTransparency = 1
	}):Play()
	TweenService:Create(christmasTrees.TextLabel, TweenInfo.new(2, Enum.EasingStyle.Linear), {
		TextTransparency = 1
	}):Play()
	TweenService:Create(christmasTrees.TextLabel.UIStroke, TweenInfo.new(2, Enum.EasingStyle.Linear), {
		Transparency = 1
	}):Play()
end

local tweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local treeIcon = christmasTrees.TreeIcon

function Wiggle()
	local v2 = math.random() > 0.5 and 1 or -1
	local tween = TweenService:Create(treeIcon, tweenInfo, {
		Rotation = 8 * v2
	})
	local tween2 = TweenService:Create(treeIcon, tweenInfo, {
		Rotation = -8 * v2 * 0.6
	})
	local tween3 = TweenService:Create(treeIcon, tweenInfo, {
		Rotation = 8 * v2 * 0.3
	})
	local tween4 = TweenService:Create(treeIcon, tweenInfo, {
		Rotation = 0
	})
	tween:Play()
	tween.Completed:Wait()
	tween2:Play()
	tween2.Completed:Wait()
	tween3:Play()
	tween3.Completed:Wait()
	tween4:Play()
end

function ChristmasPineTreesClient.Init()
	task.spawn(function()
		local christmasTrees2 = ReplicatedStorage:WaitForChild("Shops"):WaitForChild("ChristmasTrees")
		christmasTreeGoal = christmasTrees2:GetAttribute("ChristmasTreeGoal") or 15
		christmasTreeCount = christmasTrees2:GetAttribute("ChristmasTreeCount") or 0
		christmasTrees.TextLabel.Text = christmasTreeCount .. " / " .. christmasTreeGoal
		Client.Events.BiomeEntered:Connect(function(p)
			print(p)

			if p == "Christmas" then
				ShowGui()
			else
				HideGui()
			end
		end)
		christmasTrees2:GetAttributeChangedSignal("ChristmasTreeCount"):Connect(function()
			christmasTreeCount = christmasTrees2:GetAttribute("ChristmasTreeCount") or christmasTreeGoal
			christmasTrees.TextLabel.Text = christmasTreeCount .. " / " .. christmasTreeGoal

			if christmasTreeGoal <= christmasTreeCount then
				flag = true
				christmasTrees.TextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
			end
		end)
		task.spawn(function()
			while true do
				task.wait(math.random(30, 50) / 10)

				if flag then
					break
				end

				Wiggle()
			end
		end)
	end)
end

return ChristmasPineTreesClient