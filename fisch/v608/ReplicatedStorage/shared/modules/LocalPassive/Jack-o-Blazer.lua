local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Net = require(ReplicatedStorage.packages.Net)
local module = require("./PassiveHandler")
local remoteEvent = Net:RemoteEvent("ProgressModifier", -1)

-- equivalent calls inferred from this helper; original call sites unknown
local function fastTween(shine, tweenInfo, p)
	local tween = TweenService:Create(shine, tweenInfo, p)
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	tween:Play()
	return tween
end

local function showFX(instance)
	fastTween(instance.Shine, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, true), {
		ImageColor3 = Color3.fromRGB(253, 132, 18)
	}) -- equivalent call inferred; original call site unknown
end

local JackOBlazer = {
	Morph = function(p, instance, _)
		local icon = instance:WaitForChild("fish"):WaitForChild("icon")
		icon.ImageTransparency = 0
		p.reelTrove:Add(remoteEvent.OnClientEvent:Connect(function()
			showFX(instance)
		end))
	end
}
setmetatable(JackOBlazer, module)
return JackOBlazer