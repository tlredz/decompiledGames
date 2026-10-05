workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(game.ReplicatedStorage.FX)
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _WorldOrigin = workspace._WorldOrigin
local _ = workspace.Map
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(instance)
	local cFrame = instance.Part.CFrame
	local direction = instance.Direction
	local caster = instance.Caster
	local humanoid = instance.Humanoid
	local holding = instance.Holding

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 400 then
		return
	end

	local humanoidRootPart = caster.HumanoidRootPart
	Util.Sound:Play("Charge Init 3", cFrame)
	local v = Util.Sound:Play("DarkStatic", cFrame)
	local clone = FX:WaitForChild("Attachments").DarkGrab:Clone()
	clone.ParticleEmitter.Size = NumberSequence.new(15, 0)
	clone.Parent = instance.Part
	local lastTime = tick()
	local lastTime2 = tick()
	local lastTime3 = tick()

	while tick() - lastTime3 < 3 and not (humanoid.Health <= 0) and caster.Parent and (not (tick() - lastTime3 > 0.3) or holding and holding.Value) do
		if tick() - lastTime > 0.12 then
			clone.ParticleEmitter:Emit(1)
			lastTime = tick()
		end

		if tick() - lastTime2 > 0.06 then
			clone.Hole:Emit(1)
			lastTime2 = tick()
		end

		clone.CFrame *= CFrame.Angles(
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2
		)

		for _ = 1, math.random(2, 3) do
			local cframe = CFrame.new(
				math.random(-25, 25) * 2,
				math.random(-25, 25) * 2,
				-104 - math.random() * 130 * 0.4
			)
			local cframe2 = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + direction.LookVector)
			local attachment = Instance.new("Attachment")
			attachment.CFrame = cframe2 * cframe * CFrame.Angles(
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2
			)
			attachment.Parent = workspace.Terrain
			local clone2 = clone.Beam:Clone()
			clone2.Segments = 80
			clone2.CurveSize0 = math.random(-25, 25) * 2
			clone2.CurveSize1 = math.random(-25, 25) * 2
			clone2.Width0 = 3.125
			clone2.Attachment0 = clone
			clone2.Attachment1 = attachment
			clone2.Parent = _WorldOrigin
			local tweenInfo = TweenInfo.new(0.25)
			TweenService:Create(attachment, tweenInfo, {
				CFrame = cframe2 * CFrame.Angles(
					math.random() * 3.141592653589793 * 2,
					math.random() * 3.141592653589793 * 2,
					math.random() * 3.141592653589793 * 2
				)
			}):Play()
			local tween = TweenService:Create(clone2, tweenInfo, {
				Width0 = 0
			})
			tween.Completed:Connect(function()
				attachment:Destroy()
				clone2:Destroy()
			end)
			tween:Play()
		end

		wait()
	end

	Util.Sound:FadeOut(v, 0.4)
	Util.Sound:Play("DarkPortalClose", cFrame)
	clone.Hole.Enabled = false
	clone.ParticleEmitter.Enabled = false
	wait(1)
	clone:Destroy()
end