local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local rocksModule = Util.RocksModule
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { workspace.Map }
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(p)
	local root = p.Root

	if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 900 then
		return
	end

	local clone = script.HeartPart:Clone()
	clone.Size = clone.Size.Unit
	clone.Parent = workspace._WorldOrigin
	TweenService:Create(clone.Tip, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
		Position = createVector(0, 0, 6)
	}):Play()
	TweenService:Create(clone.Beam, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
		Width1 = 6
	}):Play()
	TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
		Size = clone.Size * 16
	}):Play()
	local flag = true
	task.spawn(function()
		while flag do
			clone.CFrame = root.CFrame * CFrame.new(1, 1, -6)
			local RunService = game:GetService("RunService")
			RunService.Stepped:Wait()
		end
	end)
	Util.Sound:Play("LoveV2ShootHeart", root.CFrame)
	task.wait(0.25)

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

	clone.CFrame = root:GetAttribute("LoveOrigin") * CFrame.new(0, 1, -6)
	local magnitude = (loveEndPos - root:GetAttribute("LoveOrigin").Position).Magnitude
	local raycastResult = workspace:Raycast(
		clone.CFrame.Position + createVector(0, 5, 0),
		Vector3.new(0, -clone.Size.Y / 2 - 10, 0),
		raycastParams
	)
	local flag2

	if raycastResult and raycastResult.Instance then
		clone.Floor.WorldPosition = raycastResult.Position + createVector(0, 1, 0)
		clone.Floor.Dust.Color = ColorSequence.new(raycastResult.Instance.Color:Lerp(Color3.new(1, 1, 1), 0.15))
		clone.Floor.Rock.Color = ColorSequence.new(raycastResult.Instance.Color)
		clone.Floor1.WorldPosition = raycastResult.Position + createVector(0, 0.5, 0)
		clone.Floor2.WorldPosition = raycastResult.Position + createVector(0, 0.5, 0)
		clone.Floor1.Position += createVector(0.6, 0, 0)
		clone.Floor2.Position -= createVector(0.6, 0, 0)
		clone.Trail.Enabled = true
		Util.Sound:Play("LoveV2Ground", clone.Position)
		flag2 = true
	else
		flag2 = false
	end

	clone.Beam.Enabled = false
	clone.EmitOnPulse.ShockwaveStart:Emit(1)
	clone.EmitOnPulse.ShockwaveStart2:Emit(1)

	if flag2 then
		clone.Floor.Dust.Enabled = true
		clone.Floor.Rock.Enabled = true
	end

	clone.Drops.Enabled = true
	Util.Sound:Play("LoveV2ZLaunch", root.CFrame)
	task.wait()
	task.wait()
	TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
		CFrame = clone.CFrame * CFrame.new(0, 0, -math.max(9, magnitude - 9))
	}):Play()
	local v = true
	task.defer(function()
		local lastTime = tick()

		while tick() - lastTime < 0.25 and v do
			local raycastResult2 = workspace:Raycast(
				clone.Position + createVector(0, 5, 0),
				Vector3.new(0, -clone.Size.Y / 2 - 10, 0),
				raycastParams
			)

			if raycastResult2 and raycastResult2.Instance then
				if not flag2 then
					flag2 = true
					clone.Floor.Dust.Color = ColorSequence.new(raycastResult2.Instance.Color:Lerp(
						Color3.new(1, 1, 1),
						0.15
					))
					clone.Floor.Rock.Color = ColorSequence.new(raycastResult2.Instance.Color)
					Util.Sound:Play("LoveV2Ground", clone.Position)
				end

				clone.Floor.WorldPosition = raycastResult2.Position + createVector(0, 1, 0)
				clone.Floor1.WorldPosition = raycastResult2.Position + createVector(0, 0.5, 0)
				clone.Floor2.WorldPosition = raycastResult2.Position + createVector(0, 0.5, 0)
				clone.Floor1.Position += createVector(0.6, 0, 0)
				clone.Floor2.Position -= createVector(0.6, 0, 0)
				clone.Floor.Dust.Enabled = true
				clone.Floor.Rock.Enabled = true
				clone.Trail.Enabled = true
			else
				clone.Floor.Dust.Enabled = false
				clone.Floor.Rock.Enabled = false
				clone.Trail.Enabled = false
			end

			task.wait()
		end
	end)
	task.wait(0.15)
	v = false
	clone.Drops.Enabled = false
	clone.Floor.Dust.Enabled = false
	clone.Floor.Rock.Enabled = false
	clone.Attachment.ToonLightningStatic.Enabled = false
	TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		Size = createVector(0, 0, 0)
	}):Play()
	Util.Sound:Play("LoveV2SingleHeartbeat2", clone.Position)
	task.wait(0.2)
	clone.Transparency = 1
	clone.End.Star:Emit(1)
	task.wait(0.25)
	Util.Sound:Play("LoveV2XRainImpact", clone.Position)
	Util.Sound:Play("LoveV2ExplosionZ", clone.Position)
	clone.EmitOnPulse.ShockwaveFast:Emit(2)
	clone.EmitOnPulse.Shockwave:Emit(3)
	clone.End.Stars:Emit(25)
	clone.Attachment.Rays:Emit(15)
	clone.End.ToonLightningStatic:Emit(9)
	local raycastResult2 = workspace:Raycast(
		clone.CFrame.Position + createVector(0, 1, 0),
		createVector(0, -30, 0),
		raycastParams
	)

	if raycastResult2 then
		local v2 = CFrame.new(raycastResult2.Position, raycastResult2.Position + raycastResult2.Normal * 10) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
		local clone2 = script.Scar:Clone()
		clone2.Size = createVector(110, 0.1, 110)
		clone2.CFrame = v2 * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
		clone2.Parent = workspace._WorldOrigin
		task.delay(1.75, function()
			for _, child in pairs(clone2:GetChildren()) do
				TweenService:Create(child, TweenInfo.new(1), {
					Transparency = 1
				}):Play()
			end

			task.delay(1, function()
				clone2:Destroy()
			end)
		end)
		clone.FloorEnd.WorldCFrame = clone2.CFrame
		clone.FloorEnd.Dust.Color = ColorSequence.new(raycastResult2.Instance.Color:Lerp(Color3.new(1, 1, 1), 0.15))
		clone.FloorEnd.Rock.Color = ColorSequence.new(raycastResult2.Instance.Color)
		clone.FloorEnd.Dust:Emit(30)
		clone.FloorEnd.Rock:Emit(30)
	end

	if (clone.Position - workspace.CurrentCamera.CFrame.p).Magnitude < 125 then
		Effect.new("ShakeCam"):replicate({
			8,
			16,
			0.2,
			2,
			createVector(0.25, 0.25, 0.25),
			createVector(4, 1, 1)
		})
	end

	local ground = rocksModule.Ground
	local v2 = clone.Position - createVector(0, 11, 0)
	local v3 = { workspace.Map }
	ground(v2, 65, createVector(6, 8, 6), v3, 12, false, 2, true)
	task.wait(4)
	clone:Destroy()
end