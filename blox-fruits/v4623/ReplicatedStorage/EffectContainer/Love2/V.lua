local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = Util.RocksModule
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { workspace.Map }
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(p)
	local root = p.Root

	if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 700 then
		return
	end

	local clone = script.SummonHeart:Clone()
	clone.Size = clone.Size.Unit
	clone.Parent = workspace._WorldOrigin
	TweenService:Create(clone.Tip, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
		Position = createVector(0, 0, 4)
	}):Play()
	TweenService:Create(clone.Beam, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
		Width1 = 1.5
	}):Play()
	TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
		Size = clone.Size * 4
	}):Play()
	local flag = true
	task.spawn(function()
		while flag do
			clone.CFrame = root.CFrame * CFrame.new(1, 1, -3.5)
			local RunService = game:GetService("RunService")
			RunService.Stepped:Wait()
		end
	end)
	task.wait(0.15)

	repeat
		local loveEndPos = root:GetAttribute("LoveEndPos")
		task.wait()
	until loveEndPos or root:GetAttribute("LoveEnd")

	local loveEndPos = root:GetAttribute("LoveEndPos")
	flag = false

	if not loveEndPos then
		clone:Destroy()
		return
	end

	clone.CFrame = root:GetAttribute("LoveOrigin") * CFrame.new(0, 1, -3.5)
	local magnitude = (loveEndPos - root:GetAttribute("LoveOrigin").Position).Magnitude
	Util.Sound:Play("LoveV2ShootHeart2", clone.CFrame)
	Util.Sound:Play("LoveV2V", clone.CFrame)
	Util.Sound:Play("LoveV2CInitCharge", clone.CFrame)
	clone.Beam.Enabled = false
	clone.EmitOnPulse.ShockwaveStart:Emit(1)
	clone.EmitOnPulse.ShockwaveStart2:Emit(1)
	task.wait()
	task.wait()
	TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
		CFrame = clone.CFrame * CFrame.new(0, 0, -magnitude)
	}):Play()
	task.wait(0.04999999999999999)
	TweenService:Create(clone, TweenInfo.new(0.85, Enum.EasingStyle.Elastic), {
		Size = createVector(40, 40, 15)
	}):Play()
	clone.Attachment.Rays:Emit(6)
	clone.Attachment.Rays2:Emit(10)
	clone.Attachment.Shockwave:Emit(1)
	clone.Attachment.Shockwave2:Emit(1)
	clone.Attachment.Stars:Emit(35)
	task.wait(0.9)
	clone.Attachment.Particle.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.5, 40, 5),
		NumberSequenceKeypoint.new(1, 0)
	})
	clone.Attachment.Particle:Emit(9)
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {
		Size = createVector(0, 0, 0)
	}):Play()
	task.wait(4)
	clone:Destroy()
end