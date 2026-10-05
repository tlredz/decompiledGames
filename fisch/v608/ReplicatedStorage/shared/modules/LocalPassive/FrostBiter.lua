local FrostBiter = {}
game:GetService("ContentProvider")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContextActionService")
game:GetService("UserInputService")
game:GetService("SoundService")
game:GetService("GuiService")
local Players = game:GetService("Players")
Players = Players.LocalPlayer
require(ReplicatedStorage.packages.Trove)
require(ReplicatedStorage.packages.Net)
require(ReplicatedStorage.shared.modules.fx)
local module = require("./PassiveHandler")
Random.new()

function FrostBiter.MorphHarpoon(p, _, object)
	object:GetRandom(12 + p.config.FreezeTimeFactor)
	p.reelTrove:Add(object.core.pullButtons.OnButtonAdd:Connect(function(p2)
		p2.paused = true
		local clone = script.frozenOverlay:Clone()
		local clone2 = script.frozenGlow:Clone()
		clone.Parent = p2.buttonObject
		clone2.Parent = p2.buttonObject
		local v = math.max(p.config.FreezeTimeFactor * object.resilience, p.config.MinFreezeTime)
		local tweenInfo = TweenInfo.new(v, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
		object.logicTweens:CreateAndPlay(clone, tweenInfo, {
			BackgroundTransparency = 1
		})
		object.logicTweens:CreateAndPlay(clone.bevel, tweenInfo, {
			ImageTransparency = 1
		})
		object.logicTweens:CreateAndPlay(clone2, tweenInfo, {
			BlurRadius = UDim.new(),
			Transparency = 1
		})
		object:WaitLogic(v)
		p2.paused = false
		clone:Destroy()
		clone2:Destroy()
	end))
end

setmetatable(FrostBiter, module)
return FrostBiter