local createVector = vector.create
local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local FX = require(game.ReplicatedStorage.FX)
local ghoulClawProjectile = FX:WaitForChild("Ghoul").Projectile.GhoulClawProjectile
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
local magnitude = 120

local function GetNumberDependingDistance(p, p2, p3, p4, p5)
	if p <= p4 then
		return p2
	end

	if p4 < p and p <= p5 then
		return p2 + (p3 - p2) * ((p - p4) / (p5 - p4))
	end

	return p3
end

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	local v = p2 + (p3 - p2) * p
	local v2 = p3 + (p4 - p3) * p
	local v3 = p4 + (p5 - p4) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

local function StartClawSlash(folder, folder2, _)
	coroutine.wrap(function()
		task.wait(0.125)
		folder2.CFrame = folder.CFrame * CFrame.new(0, -5, -11)

		for _, emitter in pairs(folder2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end)()
	coroutine.wrap(function()
		for _, beam in pairs(folder:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			local startDelay = beam:GetAttribute("StartDelay")
			local v = beam
			local v2 = beam:GetAttribute("EndDelay")
			coroutine.wrap(function()
				local tween = TweenService:Create(
					v,
					TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						Width0 = v.Width0,
						Width1 = v.Width1
					}
				)
				v.Width0 = 0
				v.Width1 = 0
				task.wait(startDelay)
				tween:Play()
				task.wait(v2)

				if v:IsDescendantOf(folder.Slash2) then
					task.wait(0.05)
				elseif v:IsDescendantOf(folder.Slash3) then
					task.wait(0.06)
				elseif v:IsDescendantOf(folder) and not (v:IsDescendantOf(folder.Slash3) or v:IsDescendantOf(folder.Slash2)) then
					task.wait(0.07)
				end

				local tween2 = TweenService:Create(
					v,
					TweenInfo.new(v2 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween2:Play()
				tween2.Completed:Wait()
				v:Destroy()
			end)()
		end
	end)()
	local tween = TweenService:Create(
		folder.Weld,
		TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			C0 = folder.Weld.Part0.CFrame:ToObjectSpace(folder.Weld.Part1.CFrame) * CFrame.Angles(
				-2.6179938779914944,
				0,
				0
			)
		}
	)
	tween.Completed:Connect(function()
		if folder:FindFirstChild("Weld") then
			folder.Weld.Enabled = false
			folder.Anchored = true
			tween = TweenService:Create(folder, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				CFrame = folder.CFrame * CFrame.Angles(-1.3089969389957472, 0, 0)
			})
			tween:Play()
		end
	end)
	tween:Play()
end

local function StartProjectileSlash(folder, duration, magnitude2)
	coroutine.wrap(function()
		for _, beam in pairs(folder:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			local startDelay = beam:GetAttribute("StartDelay")
			local v = beam
			local v2 = beam:GetAttribute("EndDelay")
			coroutine.wrap(function()
				local tween = TweenService:Create(
					v,
					TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						Width0 = v.Width0,
						Width1 = v.Width1
					}
				)
				v.Width0 = 0
				v.Width1 = 0
				task.wait(startDelay / 2)
				tween:Play()
			end)()
		end
	end)()
	local tween = TweenService:Create(
		folder,
		TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{
			CFrame = folder.CFrame * CFrame.new(0, 0, -magnitude2) * CFrame.Angles(0, 0, 0)
		}
	)
	tween:Play()
	tween.Completed:Wait()

	for _, effect in pairs(folder:GetDescendants()) do
		if effect:IsA("Beam") then
			local v = effect
			coroutine.wrap(function()
				local endDelay = v:GetAttribute("EndDelay")
				local tween2 = TweenService:Create(
					v,
					TweenInfo.new(endDelay / 3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween2:Play()
				tween2.Completed:Wait()
				v:Destroy()
			end)()
		elseif effect:IsA("ParticleEmitter") then
			effect.Enabled = false
		end
	end
end

return function(data)
	local root = data.Root

	if not root then
		return
	end

	if data.Holding then
		if (workspace.CurrentCamera.CFrame.Position - root.Position).Magnitude > 1250 then
			return
		end

		local v = Util.Sound:Play("GenericDarkSkillCharge", root)
		local clone = ghoulClawProjectile.HoldHand:Clone()
		clone.CFrame = root.Parent.RightHand.CFrame
		clone.Parent = root.Parent
		clone.Weld.Part0 = root.Parent.RightHand
		local clone2 = ghoulClawProjectile.HoldHand:Clone()
		clone2.CFrame = root.Parent.LeftHand.CFrame
		clone2.Parent = root.Parent
		clone2.Weld.Part0 = root.Parent.LeftHand

		repeat
			wait()
		until data.Holding.Value == false or not data.Holding:IsDescendantOf(workspace)

		Util.Sound:FadeOut(v, 0.25)
		task.wait(0.1)

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = false
			elseif effect:IsA("Beam") then
				Util.BoatTween:Create(effect, {
					Time = 0.4,
					EasingStyle = "Sine",
					EasingDirection = "In",
					StepType = "Heartbeat",
					Goal = {
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(1, 1)
						})
					}
				}):Play()
			end
		end

		for _, effect in pairs(clone2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = false
			elseif effect:IsA("Beam") then
				Util.BoatTween:Create(effect, {
					Time = 0.4,
					EasingStyle = "Sine",
					EasingDirection = "In",
					StepType = "Heartbeat",
					Goal = {
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(1, 1)
						})
					}
				}):Play()
			end
		end

		task.wait(0.8)
		clone:Destroy()
		clone2:Destroy()
	else
		local endPosition = data.EndPosition

		if (workspace.CurrentCamera.CFrame.Position - endPosition).Magnitude > 1250 then
			return
		end

		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 4)
		local cframe = CFrame.new(root.CFrame.Position, endPosition)
		Util.Sound:Play("ScarletTearProjectile", cframe)
		local raycastParams = RaycastParams.new()
		raycastParams.IgnoreWater = false
		raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
		magnitude = (cframe.Position - endPosition).Magnitude
		local v = magnitude
		local v2 = v <= 5 and 0.05 or not (v > 5 and v <= 200) and 0.15 or 0.05 + 0.09999999999999999 * ((v - 5) / 195)

		for i = 1, 2 do
			local v3 = i
			coroutine.wrap(function()
				local v4 = nil
				local v5 = nil

				if v3 == 1 then
					v5 = 3
					v4 = -35
				elseif v3 == 2 then
					v5 = -3
					v4 = 35
				end

				local clone = ghoulClawProjectile.ClawSlash:Clone()
				local clone2 = ghoulClawProjectile.SlashHit:Clone()
				clone.CFrame = cframe * CFrame.new(v5, 0, 0)
				clone.Weld.Part0 = root
				clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.Angles(
					0,
					0,
					(math.rad(v4))
				) * CFrame.Angles(2.9670597283903604, 0, 0)
				clone.Parent = folder
				clone2.Parent = folder
				StartClawSlash(clone, clone2, cframe)
			end)()
		end

		local v3 = cframe * CFrame.new(0, 0, -5).Position
		local raycastResult = workspace:Raycast(
			v3 + createVector(0, 1, 0),
			CFrame.new(v3).UpVector * -11,
			raycastParams
		)

		if raycastResult then
			local clone = ghoulClawProjectile.GroundSlash:Clone()
			clone.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + cframe.LookVector)
			clone.Orientation = Vector3.new(0, clone.Orientation.Y, clone.Orientation.Z)
			clone.CFrame *= CFrame.new(0, 0.4, 0)
			clone.Parent = folder
			local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					local v4 = descendant
					coroutine.wrap(function()
						v4.Enabled = true
						task.wait(0.5)
						v4.Enabled = false
					end)()
				elseif descendant:IsA("Attachment") then
					local tween = TweenService:Create(descendant, tweenInfo, {
						Position = createVector(0, 0, -12.5)
					})
					tween:Play()
					local v5 = descendant
					coroutine.wrap(function()
						tween.Completed:Wait()
						v5.Particle_1.Enabled = false
					end)()
				elseif descendant:IsA("BasePart") then
					local v4 = descendant
					coroutine.wrap(function()
						task.wait(0.1)
						v4.Anchored = true
						TweenService:Create(v4, tweenInfo, {
							Size = Vector3.new(v4.Size.X, v4.Size.Y, 25),
							CFrame = v4.CFrame * CFrame.new(0, 0, -12.5)
						}):Play()
					end)()
				elseif descendant:IsA("Weld") then
					local v4 = descendant
					task.delay(0.1, function()
						v4:Destroy()
					end)
				end
			end
		end

		task.wait(0.05)
		coroutine.wrap(function()
			task.wait(0.05)

			for _ = 1, 10 do
				coroutine.wrap(function()
					task.wait(0.005)
					local clone = ghoulClawProjectile.Trail:Clone()
					clone.CFrame = cframe * CFrame.new(
						math.random(-20, 20) / 1,
						math.random(-15, 15) * 1.5,
						math.random(-1, 1)
					)
					clone.Parent = folder

					for _, emitter in pairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end

					local position = clone.Position
					local v4 = cframe * CFrame.new(math.random(-15, 15), math.random(-15, 15) * 1.5, -magnitude).Position
					local magnitude2 = (position - v4).Magnitude
					clone.CFrame = CFrame.new(position, v4)
					local v5 = (position - v4) / 2
					local position2 = CFrame.new(CFrame.new(position) * (v5 / -1.5)).Position
					local position3 = CFrame.new(CFrame.new(v4) * (v5 / 1.5)).Position
					local v6 = magnitude2 / 12
					local v7 = position2 + Vector3.new(
						math.random(-v6, v6),
						math.random(-3, 8) * 3,
						math.random(-v6, v6)
					)
					local v8 = position3 + Vector3.new(
						math.random(-v6, v6),
						math.random(-3, 8) * 3,
						math.random(-v6, v6)
					)
					local v9 = math.random(12, 20) / 1.15
					local lastTime = tick()
					local v10 = magnitude2 / v9 / 60

					while tick() - lastTime < v10 do
						local v11 = (tick() - lastTime) / v10
						local v12 = cubicBezier(v11, position, v7, v8, v4)
						clone.CFrame = clone.CFrame:Lerp(CFrame.new(v12, v4), v11)
						RunService.Heartbeat:Wait()
					end

					for _, emitter in pairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					Util.Debris:AddItem(clone, 1)
				end)()
			end
		end)()
		local clone = ghoulClawProjectile.StartImpact:Clone()
		clone.CFrame = cframe * CFrame.new(0, 0, -5)
		clone.Parent = folder
		Util.Debris:AddItem(clone, 1)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		task.wait(0.07)
		local clone2 = ghoulClawProjectile.ProjectileSlash:Clone()

		for _, descendant in pairs(clone2:GetDescendants()) do
			if descendant:IsA("Beam") then
				descendant.CurveSize0 *= 2.5
				descendant.CurveSize1 *= 2.5
				descendant.Width0 *= 3.75
				descendant.Width1 *= 3.75
			elseif descendant:IsA("Attachment") then
				descendant.Position = Vector3.new(
					descendant.Position.X * 2.5,
					descendant.Position.Y * 2.5,
					descendant.Position.Z * 2.5
				)
			elseif descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
			end
		end

		clone2.CFrame = cframe * CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)
		clone2.Parent = folder
		StartProjectileSlash(clone2, v2, magnitude)
		local v4 = Util.Sound:Play("ScarletTearExplosion", clone2.CFrame)
		local play = Util.Sound:Play("SanguineArtXExplosion", clone2.CFrame)
		play.TimePosition = 0.075
		local clone3 = ghoulClawProjectile.Explosion:Clone()
		clone3.CFrame = clone2.CFrame
		clone3.Parent = folder

		for _, emitter in pairs(clone3:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v5 = emitter
			coroutine.wrap(function()
				if v5:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v5:GetAttribute("EmitDelay"))
				end

				v5:Emit(v5:GetAttribute("EmitCount"))
			end)()
		end

		local clone4 = ghoulClawProjectile.Explosion2:Clone()
		clone4.CFrame = clone3.CFrame
		clone4.Parent = folder

		for _, emitter in pairs(clone4:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v5 = emitter
			coroutine.wrap(function()
				v5.Enabled = true
				task.wait(0.25)
				v5.Enabled = false
			end)()
		end

		task.wait(1)
		Util.Sound:FadeOut(v4, 0.5)
	end
end