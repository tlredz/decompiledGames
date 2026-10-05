local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.ServerInfo)
require(ReplicatedStorage.Common.Utils)
local FastUtils = require(ReplicatedStorage.Shared.FastUtils)

local function lerp(p, p2, p3: number)
	return p + (p2 - p) * p3
end

return Observers.observeTag("CupidVanishingCloud", function(instance)
	local maid = Trove.new()
	local serverTimeNow = workspace:GetServerTimeNow()
	local v = serverTimeNow - (instance:GetAttribute("StartTime") or serverTimeNow)
	local duration = instance:GetAttribute("Duration") or 15
	local fadeTime = instance:GetAttribute("FadeTime") or 1
	local fadeDelay = instance:GetAttribute("FadeDelay") or 0

	if fadeDelay > 0 and v < fadeTime + fadeDelay then
		local v2 = maid:Add(Instance.new("Highlight"))
		local color = Color3.fromRGB(239, 151, 255)
		instance:SetAttribute("HighlightColor", color)
		v2.FillColor = color
		v2.OutlineColor = Color3.fromRGB(255, 255, 255)
		v2.FillTransparency = 1
		v2.OutlineTransparency = 1
		v2.Adornee = instance
		v2.Enabled = true
		v2.Parent = instance
		FastUtils.fastTween(v2, TweenInfo.new(0.25), {
			FillTransparency = 0.2,
			OutlineTransparency = 0
		}):Play()
		task.wait(0.25)
		instance:SetAttribute("EndTime", workspace:GetServerTimeNow() + fadeDelay - 0.25)
		instance:AddTag("RedHighlightFlash")
		Debris:AddItem(v2, fadeDelay - 0.25)
		task.wait(fadeDelay - 0.25)
		instance:RemoveTag("RedHighlightFlash")
	end

	if fadeTime + fadeDelay < v then
		instance.Transparency = 1
	else
		FastUtils.fastTween(instance, TweenInfo.new(fadeTime), {
			Transparency = 1
		}):Play()
	end

	maid:Add(task.delay(duration - fadeTime - v, function()
		FastUtils.fastTween(instance, TweenInfo.new(fadeTime), {
			Transparency = 0
		}):Play()
	end))
	return function()
		instance:RemoveTag("RedHighlightFlash")
		maid:Destroy()
	end
end, { workspace })