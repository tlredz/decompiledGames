local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")
game:GetService("RunService")
game:GetService("Players")
local Net = require(ReplicatedStorage.Packages.Net)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.ServerInfo)
local Utils = require(ReplicatedStorage.Common.Utils)
local FastUtils = require(ReplicatedStorage.Shared.FastUtils)
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Shared.SpeedModifiers)
Net:RemoteEvent("RequestSelfDamage")
return Observers.observeTag("Dungeons_SkullAttack", function(folder)
	local maid = Trove.new()
	local moveTo = folder:GetAttribute("MoveTo")
	local v = maid:Add(FastUtils.fastTween(
		folder.PrimaryPart,
		TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{
			CFrame = CFrame.new(moveTo)
		}
	))
	local v2 = true
	maid:Add(function()
		v2 = false
	end)
	maid:Add(v.Completed:Connect(function()
		folder.Holder.Beam:Play()

		for _, effect in folder:GetDescendants() do
			if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
				effect.Enabled = true
			end
		end

		maid:Add(Utils.Thread.LoopFor(4.25, function(p: number)
			folder.PrimaryPart:PivotTo(CFrame.new(moveTo) * CFrame.fromOrientation(0, 6.283185307179586 * p, 0))
		end)).Ended:Wait()

		if not v2 then
			return
		end

		for _, effect in folder:GetDescendants() do
			if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
				effect.Enabled = false
			end
		end

		maid:Add(FastUtils.fastTween(
			folder.Holder.Beam,
			TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
			{
				Volume = 0
			}
		))
		maid:Add(FastUtils.fastTween(
			folder.PrimaryPart,
			TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.In),
			{
				CFrame = CFrame.new(moveTo.X, folder:GetAttribute("HiddenY"), moveTo.Z)
			}
		))
	end))
	return function()
		maid:Destroy()
	end
end, { workspace })