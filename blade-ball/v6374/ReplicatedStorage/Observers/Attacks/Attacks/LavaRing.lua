local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
game:GetService("RunService")
game:GetService("Players")
local Net = require(ReplicatedStorage.Packages.Net)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.ServerInfo)
local FastUtils = require(ReplicatedStorage.Shared.FastUtils)
Net:RemoteEvent("RequestSelfDamage")
return Observers.observeTag("Dungeons_LavaRingAttack", function(instance)
	local duration = instance:GetAttribute("Duration") or 10
	local maxSize = instance:GetAttribute("MaxSize") or 1000
	local maid = Trove.new()
	local v = {}
	local v2 = instance

	if instance:IsA("Model") then
		v2 = maid:Add(Instance.new("NumberValue"))
		maid:Add(v2:GetPropertyChangedSignal("Value"):Connect(function()
			instance:ScaleTo(v2.Value)
		end))
		v.Value = instance:GetAttribute("MaxScale") or 100
	else
		v.Size = Vector3.new(maxSize, instance.Size.Y, maxSize)
	end

	maid:Add(FastUtils.fastTween(v2, TweenInfo.new(duration, Enum.EasingStyle.Sine), v))
	local v3 = {}

	for _, part in instance:GetDescendants() do
		if part:IsA("BasePart") then
			table.insert(v3, part)
		end
	end

	if instance:IsA("BasePart") then
		table.insert(v3, instance)
	end

	local v4 = math.max(0.15, duration / 10)
	local fadeDelay = instance:GetAttribute("FadeDelay") or duration

	for _, v5 in v3 do
		maid:Add(FastUtils.fastTween(
			v5,
			TweenInfo.new(v4, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, fadeDelay - v4),
			{
				Transparency = 1
			}
		))
	end

	task.delay(duration - v4, function()
		instance:RemoveTag("Dungeons_HitboxDamage")
	end)

	if not instance:GetAttribute("NoSound") then
		local clone = maid:Clone(ReplicatedStorage.Misc.LavaBrickSFX)
		clone.Parent = SoundService
		maid:Add(clone.Ended:Once(function()
			clone:Destroy()
		end))
		clone:Play()
	end

	return function()
		maid:Destroy()
	end
end, { workspace })