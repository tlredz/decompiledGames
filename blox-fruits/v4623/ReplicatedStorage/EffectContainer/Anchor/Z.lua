local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local masterClock = Util.MasterClock
local _ = Util.BoatTween
local _ = Util.Sound
local misc = Util.Luno.Misc
local CustomCollisions = require(game.ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local WrapHighlight = require(game.ReplicatedStorage.Util.WrapHighlight)
local TweenService = game:GetService("TweenService")
local FX = require(game.ReplicatedStorage.FX)
local Z = FX:WaitForChild("Anchor").Z

local function GetNumberDependingDistance(p, p2, p3, p4, p5)
	if p <= p4 then
		return p2
	end

	if p4 < p and p <= p5 then
		return p2 + (p3 - p2) * ((p - p4) / (p5 - p4))
	end

	return p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function AnchorRotationGroundSparks(clone, folder, p)
	task.spawn(function()
		local position = clone.Anchor.Position
		local ray, v, _ = Util.Ray(
			position + createVector(0, 2, 0),
			CFrame.new(position).UpVector * -10,
			{ workspace.Characters, workspace.Enemies },
			false
		)

		if ray then
			TweenService:Create(folder, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Position = v + createVector(0, 0, 0)
			}):Play()

			if p == false then
				p = true

				for _, effect in pairs(folder:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
						continue
					end

					if effect:GetAttribute("Color") then
						effect.Color = ColorSequence.new(ray.Color, ray.Color)
					end

					effect.Enabled = true
				end
			end
		else
			if p == true then
				for _, effect in pairs(folder:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end
			end

			p = false
		end
	end)
end

local function AnchorRotationWallSparks(p, lastTime, p2, p3, p4, _, folder)
	if lastTime == nil or p2 <= os.clock() - lastTime then
		task.spawn(function()
			lastTime = os.clock()
			local cframe = CFrame.new(p3.Position, p4.Anchor.Position)
			local v = p * 1.85
			local ray, position, _ = Util.Ray(
				cframe.Position,
				cframe.LookVector.Unit * v,
				{ workspace.Characters, workspace.Enemies },
				false
			)

			if ray then
				folder.Position = position

				for _, effect in pairs(folder:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = true
					end
				end
			else
				for _, effect in pairs(folder:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end
			end
		end)
	end
end

local function SpinSlash(cFrame, folder, spinSizeMult, spinSizeMult2, slashSpinRotateSpeed, p)
	local clone

	if spinSizeMult >= 2 then
		clone = Z.SpinSlash2:Clone()
	else
		clone = Z.SpinSlash:Clone()
	end

	Util.Debris:AddItem(clone, 5)
	clone.CFrame = cFrame * CFrame.Angles(math.rad((math.random(-0, 0))), p, (math.rad((math.random(-0, 0)))))
	clone.Parent = folder

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("Beam") then
			local v = descendant
			task.spawn(function()
				v.CurveSize0 *= spinSizeMult
				v.CurveSize1 *= spinSizeMult
				v.Width0 *= spinSizeMult / 1
				v.Width1 *= spinSizeMult / 1
				local tween = TweenService:Create(
					v,
					TweenInfo.new(slashSpinRotateSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						CurveSize0 = v.CurveSize0 * spinSizeMult2,
						CurveSize1 = v.CurveSize1 * spinSizeMult2,
						Width0 = v.Width0 * spinSizeMult2,
						Width1 = v.Width1 * spinSizeMult2
					}
				)
				tween:Play()
				tween.Completed:Wait()
				local endDelay = v:GetAttribute("EndDelay")
				local tween2 = TweenService:Create(
					v,
					TweenInfo.new(endDelay, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween2:Play()
				tween2.Completed:Wait()
				v:Destroy()
			end)
		elseif descendant:IsA("Attachment") then
			descendant.Position = Vector3.new(
				descendant.Position.X * spinSizeMult,
				descendant.Position.Y * spinSizeMult,
				descendant.Position.Z * spinSizeMult
			)
			TweenService:Create(
				descendant,
				TweenInfo.new(slashSpinRotateSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Position = Vector3.new(
						descendant.Position.X * spinSizeMult2,
						descendant.Position.Y * spinSizeMult2,
						descendant.Position.Z * spinSizeMult2
					)
				}
			):Play()
		end
	end

	task.spawn(function()
		local tween = TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = clone.CFrame * CFrame.Angles(0, 2.0943951023931953, 0)
		})
		tween:Play()
		tween.Completed:Wait()
		local tween2 = TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = clone.CFrame * CFrame.Angles(0, 2.0943951023931953, 0)
		})
		tween2:Play()
		tween2.Completed:Wait()
		TweenService:Create(clone, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = clone.CFrame * CFrame.Angles(0, 2.0943951023931953, 0)
		}):Play()
	end)
end

local function SpinSlash2(cFrame, folder, spinSizeMult, spinSizeMult2, slashSpinRotateSpeed)
	local clone = Z.SpinSlash3:Clone()
	Util.Debris:AddItem(clone, 5)
	clone.CFrame = cFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
	clone.Parent = folder

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("Beam") then
			local v = descendant
			task.spawn(function()
				v.CurveSize0 = v.CurveSize0 * spinSizeMult / 2
				v.CurveSize1 = v.CurveSize1 * spinSizeMult / 2
				v.Width0 *= spinSizeMult / 2
				v.Width1 *= spinSizeMult / 2
				local tween = TweenService:Create(
					v,
					TweenInfo.new(slashSpinRotateSpeed * 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						CurveSize0 = v.CurveSize0 * spinSizeMult2,
						CurveSize1 = v.CurveSize1 * spinSizeMult2,
						Width0 = v.Width0 * spinSizeMult2,
						Width1 = v.Width1 * spinSizeMult2
					}
				)
				tween:Play()
				tween.Completed:Wait()
				local endDelay = v:GetAttribute("EndDelay")
				local tween2 = TweenService:Create(
					v,
					TweenInfo.new(endDelay / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween2:Play()
				tween2.Completed:Wait()
				v:Destroy()
			end)
		elseif descendant:IsA("Attachment") then
			descendant.Position = Vector3.new(
				descendant.Position.X * spinSizeMult / 2,
				descendant.Position.Y * spinSizeMult / 2,
				descendant.Position.Z * spinSizeMult / 2
			)
			TweenService:Create(
				descendant,
				TweenInfo.new(slashSpinRotateSpeed * 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Position = Vector3.new(
						descendant.Position.X * spinSizeMult2,
						descendant.Position.Y * spinSizeMult2,
						descendant.Position.Z * spinSizeMult2
					)
				}
			):Play()
		end
	end

	task.spawn(function()
		local tween = TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = clone.CFrame * CFrame.new(0, 1, 0) * CFrame.Angles(0, 2.0943951023931953, 0)
		})
		tween:Play()
		tween.Completed:Wait()
		local tween2 = TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = clone.CFrame * CFrame.new(0, 1.5, 0) * CFrame.Angles(0, 2.0943951023931953, 0)
		})
		tween2:Play()
		tween2.Completed:Wait()
		local tween3 = TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = clone.CFrame * CFrame.new(0, 1, 0) * CFrame.Angles(0, 2.0943951023931953, 0)
		})
		tween3:Play()
		tween3.Completed:Wait()
		local tween4 = TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = clone.CFrame * CFrame.new(0, 1.5, 0) * CFrame.Angles(0, 2.0943951023931953, 0)
		})
		tween4:Play()
		tween4.Completed:Wait()
		TweenService:Create(clone, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = clone.CFrame * CFrame.new(0, 7, 0) * CFrame.Angles(0, 2.0943951023931953, 0)
		}):Play()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ScreenEffect(position)
	if misc.charInRange(position, 50) then
		task.spawn(function()
			local clone = Z.Bloom:Clone()
			Util.Debris:AddItem(clone, 2)
			local tween = TweenService:Create(clone, TweenInfo.new(0.03), {
				Size = clone.Size,
				Threshold = clone.Threshold,
				Intensity = clone.Intensity
			})
			clone.Size = 24
			clone.Threshold = 2
			clone.Intensity = 1
			clone.Parent = workspace.CurrentCamera
			tween:Play()
			tween.Completed:Wait()
			local tween2 = TweenService:Create(clone, TweenInfo.new(0.175), {
				Size = 24,
				Threshold = 2,
				Intensity = 1
			})
			tween2:Play()
			tween2.Completed:Wait()
			clone:Destroy()
		end)
	end
end

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function quadInLerp(p, p2, p3)
	return p + (p2 - p) * p3 * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	local v = p2 + (p3 - p2) * p
	local v2 = p3 + (p4 - p3) * p
	local v3 = p4 + (p5 - p4) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

local function Curve(clone, p)
	local position = clone.Position
	local v = math.random(20, 50)
	local v2 = p + Vector3.new(0, math.random(0, 10), 0)
	local magnitude = (position - v2).Magnitude
	clone.CFrame = CFrame.new(position, v2)
	local v3 = (position - v2) / 2
	local position2 = CFrame.new(CFrame.new(position) * (v3 / -1.5)).Position
	local position3 = CFrame.new(CFrame.new(v2) * (v3 / 1.5)).Position
	local v4 = position2 + Vector3.new(math.random(-v, v), math.random(-v, v), math.random(-v, v))
	local v5 = position3 + Vector3.new(math.random(-v, v), math.random(-v, v), math.random(-v, v))
	local lastTime = tick()
	local v6 = magnitude / 5 / 60

	while tick() - lastTime < v6 do
		local v7 = (tick() - lastTime) / v6
		local v8 = cubicBezier(v7, position, v4, v5, v2)
		clone.CFrame = clone.CFrame:Lerp(CFrame.new(v8, v2), v7)
		RunService.Heartbeat:Wait()
	end
end

local function GroundRocks(cframe, parent, _, ray)
	for _ = 1, 8 do
		task.spawn(function()
			local clone = Z.Rock:Clone()
			clone.Position = cframe.Position + Vector3.new(
				math.random(-25, 25) * 1.5,
				math.random(1, 15),
				math.random(-25, 25) * 1.5
			)
			clone.Size = Vector3.new(math.random(2, 9) * 1.5, math.random(3, 5) / 2, math.random(2, 9) * 1.5)
			clone.Material = ray.Material
			clone.Color = ray.Color
			clone.Parent = parent
			rocks:ApplyCollision(clone, nil, true)
			local bodyVelocity = Instance.new("BodyVelocity")
			Util.Debris:AddItem(bodyVelocity, 0.125)
			bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
			bodyVelocity.P = 3000
			bodyVelocity.Parent = clone
			bodyVelocity.Velocity = CFrame.new(
				clone.Position,
				(CFrame.new(clone.Position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
					0,
					0,
					-30
				)).Position + Vector3.new(math.random(-10, 10) / 5, math.random(80, 250), math.random(-10, 10) / 5)
			).LookVector * math.random(100, 130) * 1.5
			clone.Attachment0.Orientation = Vector3.new(
				math.random(-90, 90),
				math.random(-90, 90),
				math.random(-90, 90)
			)
			local v = math.random(60, 120)
			local v2 = math.random(60, 120)
			local v3 = math.random(60, 120)
			local v4 = v / 10
			local v5 = v2 / 10
			local v6 = v3 / 10

			for _ = 1, 6 do
				v = math.clamp(v - v4, 0, 120)
				v2 = math.clamp(v2 - v5, 0, 120)
				v3 = math.clamp(v3 - v6, 0, 120)
				local tween = TweenService:Create(
					clone.Attachment0,
					TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						CFrame = clone.Attachment0.CFrame * CFrame.Angles(math.rad(v), math.rad(v2), (math.rad(v3)))
					}
				)
				tween:Play()
				tween.Completed:Wait()
				tween:Destroy()
			end

			clone.AlignOrientation:Destroy()
			task.delay(2.6, function()
				local tween = TweenService:Create(
					clone,
					TweenInfo.new(1 + math.random() * 0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						Size = createVector(0, 0, 0)
					}
				)
				tween.Completed:Connect(function()
					clone:Destroy()
				end)
				tween:Play()
			end)
		end)
	end
end

local function AnchorCurve(anchor, position, p)
	local position2 = anchor.Position
	anchor.CFrame = CFrame.new(position2, position)
	local v = (position2 - position) / 2
	local _ = (position2 - position).Magnitude
	local position3 = CFrame.new(CFrame.new(position2) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position) * (v / 1.5)).Position
	local v2 = position3 + createVector(5, 20, 0)
	local v3 = position4 + Vector3.new(5, 25, math.random(15, 15))
	local lastTime = tick()

	while tick() - lastTime < p do
		local v4 = (tick() - lastTime) / p
		local v5 = cubicBezier(v4, position2, v2, v3, position)
		anchor.CFrame = anchor.CFrame:Lerp(CFrame.new(v5, position), v4)
		RunService.Heartbeat:Wait()
	end

	local cframe = CFrame.new(anchor.Position)
	local wrapHighlight = WrapHighlight(anchor.Model.AnchorModel.Highlight)
	wrapHighlight.Enabled = false
	anchor.Attachment:Destroy()
	local clone = Z.AnchorGroundImpact:Clone()
	Util.Debris:AddItem(clone, 5)
	clone.CFrame = cframe * CFrame.new(0, -5, 0) * CFrame.new(0, clone.Size.Y / 2, 0)
	clone.Parent = anchor
	coroutine.wrap(function()
		for _ = 1, 7 do
			local clone2 = Z.Rocks:Clone()
			Util.Debris:AddItem(clone2, 6)
			clone2.CFrame = cframe * CFrame.new(math.random(-2, 2) / 2, math.random(-2, 2) / 2, math.random(-3, -2))
			clone2.Parent = anchor
			clone2.Anchored = false
			clone2.CanCollide = true
			clone2:ApplyImpulse((Vector3.new(
				math.random(-10, 10) / 1000,
				math.random(15, 35) / 500,
				math.random(-10, 10) / 1000
			)))
			local v4 = math.random(1, 3)

			if v4 == 1 then
				clone2.Attachment.Particle_2:Destroy()
				clone2.Attachment.Particle_3:Destroy()
			elseif v4 == 2 then
				clone2.Attachment.Particle_1:Destroy()
				clone2.Attachment.Particle_3:Destroy()
			elseif v4 == 3 then
				clone2.Attachment.Particle_1:Destroy()
				clone2.Attachment.Particle_2:Destroy()
			end
		end
	end)()

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v4 = emitter
		coroutine.wrap(function()
			if v4:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v4:GetAttribute("EmitDelay"))
			end

			v4:Emit(v4:GetAttribute("EmitCount"))
		end)()
	end
end

local function ExplosionSlashes(cframe, parent, clonesByClone)
	task.spawn(function()
		local clone = Z.SpinSlash4:Clone()
		Util.Debris:AddItem(clone, 5)
		clone.CFrame = cframe * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
		clone.Parent = parent
		clonesByClone[clone] = clone

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("Beam") then
				local v = descendant
				task.spawn(function()
					v.CurveSize0 *= 2
					v.CurveSize1 *= 2
					v.Width0 *= 2
					v.Width1 *= 2
					local tween = TweenService:Create(
						v,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CurveSize0 = v.CurveSize0 * 2,
							CurveSize1 = v.CurveSize1 * 2,
							Width0 = v.Width0 * 2,
							Width1 = v.Width1 * 2
						}
					)
					tween:Play()
					tween.Completed:Wait()
					local tween2 = TweenService:Create(
						v,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CurveSize0 = v.CurveSize0 * 0.5,
							CurveSize1 = v.CurveSize1 * 0.5,
							Width0 = v.Width0 * 0.5,
							Width1 = v.Width1 * 0.5
						}
					)
					tween2:Play()
					tween2.Completed:Wait()
					local endDelay = v:GetAttribute("EndDelay")
					local tween3 = TweenService:Create(
						v,
						TweenInfo.new(endDelay / 10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Width0 = 0,
							Width1 = 0
						}
					)
					tween3:Play()
					tween3.Completed:Wait()
					v:Destroy()
				end)
			elseif descendant:IsA("Attachment") then
				local v = descendant
				task.spawn(function()
					v.Position = Vector3.new(v.Position.X * 2, v.Position.Y * 2, v.Position.Z * 2)
					local tween = TweenService:Create(
						v,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Position = Vector3.new(v.Position.X * 2, v.Position.Y * 2, v.Position.Z * 2)
						}
					)
					tween:Play()
					tween.Completed:Wait()
					TweenService:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = Vector3.new(v.Position.X * 0.5, v.Position.Y * 0.5, v.Position.Z * 0.5)
					}):Play()
				end)
			end
		end

		local v = math.random(70, 120)
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = clone.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(0, math.rad(v), 0)
			}
		)
		tween:Play()
		tween.Completed:Wait()
		local tween2 = TweenService:Create(
			clone,
			TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = clone.CFrame * CFrame.new(0, 12, 0) * CFrame.Angles(0, math.rad(v), 0)
			}
		)
		tween2:Play()
		tween2.Completed:Wait()
		local tween3 = TweenService:Create(
			clone,
			TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = clone.CFrame * CFrame.new(0, 13, 0) * CFrame.Angles(0, math.rad(v), 0)
			}
		)
		tween3:Play()
		tween3.Completed:Wait()
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			CFrame = clone.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(0, math.rad(v), 0)
		}):Play()
	end)
	task.spawn(function()
		local clone = Z.SpinSlash5:Clone()
		Util.Debris:AddItem(clone, 5)
		clone.CFrame = cframe * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
		clone.Parent = parent
		clonesByClone[clone] = clone

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("Beam") then
				local v = descendant
				task.spawn(function()
					v.CurveSize0 *= 1.5
					v.CurveSize1 *= 1.5
					v.Width0 *= 1.5
					v.Width1 *= 1.5
					local tween = TweenService:Create(
						v,
						TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CurveSize0 = v.CurveSize0 * 3.5,
							CurveSize1 = v.CurveSize1 * 3.5,
							Width0 = v.Width0 * 3.5,
							Width1 = v.Width1 * 3.5
						}
					)
					tween:Play()
					tween.Completed:Wait()
					local tween2 = TweenService:Create(
						v,
						TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CurveSize0 = v.CurveSize0 * 1.25,
							CurveSize1 = v.CurveSize1 * 1.25,
							Width0 = v.Width0 * 1.25,
							Width1 = v.Width1 * 1.25
						}
					)
					tween2:Play()
					tween2.Completed:Wait()
					local endDelay = v:GetAttribute("EndDelay")
					local tween3 = TweenService:Create(
						v,
						TweenInfo.new(endDelay, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Width0 = 0,
							Width1 = 0
						}
					)
					tween3:Play()
					tween3.Completed:Wait()
					v:Destroy()
				end)
			elseif descendant:IsA("Attachment") then
				local v = descendant
				task.spawn(function()
					v.Position = Vector3.new(v.Position.X * 1.5, v.Position.Y * 1.5, v.Position.Z * 1.5)
					local tween = TweenService:Create(
						v,
						TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Position = Vector3.new(v.Position.X * 3.5, v.Position.Y * 3.5, v.Position.Z * 3.5)
						}
					)
					tween:Play()
					tween.Completed:Wait()
					TweenService:Create(v, TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = Vector3.new(v.Position.X * 1.25, v.Position.Y * 1.25, v.Position.Z * 1.25)
					}):Play()
				end)
			end
		end

		local v = -math.random(70, 120)
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = clone.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(v), 0)
			}
		)
		tween:Play()
		tween.Completed:Wait()
		local tween2 = TweenService:Create(
			clone,
			TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = clone.CFrame * CFrame.new(0, math.random(0, 25), 0) * CFrame.Angles(0, math.rad(v), 0)
			}
		)
		tween2:Play()
		tween2.Completed:Wait()
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			CFrame = clone.CFrame * CFrame.new(0, math.random(5, 25) / 10, 0) * CFrame.Angles(0, math.rad(v), 0)
		}):Play()
	end)
end

local function WaterExplosion(_WorldOrigin2, clone)
	local cframe = CFrame.new(clone.PrimaryPart.Position)
	Util.Sound:Play("AnchorZBoom", cframe)
	task.spawn(function()
		for _ = 1, 20 do
			task.spawn(function()
				local clone2 = Z.Trail:Clone()
				Util.Debris:AddItem(clone2, 1)
				clone2.CFrame = cframe * CFrame.new(math.random(-100, 100), math.random(-5, 50), math.random(-100, 100))
				clone2.Parent = _WorldOrigin2

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				Curve(clone2, cframe.Position + createVector(0, 7, 0))

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
			task.wait()
		end
	end)
	local ray, v, _ = Util.Ray(
		cframe.Position + createVector(0, 1, 0),
		CFrame.new(cframe.Position).UpVector * -25,
		{ workspace.Characters, workspace.Enemies },
		false
	)
	local clone2

	if ray then
		clone2 = Z.GroundExplosionSplashStart:Clone()
		Util.Debris:AddItem(clone2, 5)
		clone2.CFrame = cframe
		clone2.Parent = _WorldOrigin2

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end
	end

	local v2 = {}

	for _ = 1, 10 do
		ExplosionSlashes(cframe, _WorldOrigin2, v2)
		task.wait(0.025)
	end

	local clone3 = Z.ExplosionStartImpact:Clone()
	Util.Debris:AddItem(clone3, 5)
	clone3.CFrame = cframe * CFrame.new(0, 10, 0)
	clone3.Parent = _WorldOrigin2

	for _, emitter in pairs(clone3:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v3 = emitter
		coroutine.wrap(function()
			if v3:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v3:GetAttribute("EmitDelay"))
			end

			v3:Emit(v3:GetAttribute("EmitCount"))
		end)()
	end

	for _, v3 in pairs(v2) do
		v3:Destroy()
	end

	if ray then
		GroundRocks(cframe, _WorldOrigin2, v, ray)
	end

	if (workspace.CurrentCamera.CFrame.p - cframe.p).Magnitude < 150 then
		Util.CameraShaker:ShakeOnce(10, 7, 0.15, 0.6)
	end

	task.wait(0.4)
	local clone4 = Z.ExplosionStartImpact2:Clone()
	Util.Debris:AddItem(clone4, 5)
	clone4.CFrame = cframe * CFrame.new(0, 10, 0)
	clone4.Parent = _WorldOrigin2

	for _, emitter in pairs(clone4:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	if (workspace.CurrentCamera.CFrame.p - cframe.p).Magnitude < 150 then
		Util.CameraShaker:ShakeOnce(20, 14, 0.15, 1.2)
	end

	task.wait(0.1)

	if clone2 ~= nil then
		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end

	local clone5 = Z.ExplosionImpact:Clone()
	Util.Debris:AddItem(clone5, 5)
	clone5.CFrame = cframe * CFrame.new(0, 10, 0)
	clone5.Parent = _WorldOrigin2

	for _, emitter in pairs(clone5:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v3 = emitter
		task.spawn(function()
			if v3:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v3:GetAttribute("EmitDelay"))
			end

			v3:Emit(v3:GetAttribute("EmitCount"))
		end)
	end

	ScreenEffect(cframe.Position) -- equivalent call inferred; original call site unknown
end

local v = {}

local function addSpinToTable(p, p2)
	table.insert(v, {
		p,
		p2,
		{}
	})
end

local function flushSpins(_)
	v = {}
end

local function removeSpinFromTable(GUID)
	for k, v2 in pairs(v) do
		if v2[1] == GUID then
			table.remove(v, k)
		end
	end
end

local function addCharacterToSpin(GUID: string, char)
	for _, v2 in pairs(v) do
		if not (v2[1] == GUID and char ~= nil) then
			continue
		end

		local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
		local humanoid = char:FindFirstChild("Humanoid")

		if humanoidRootPart and humanoidRootPart.Parent and humanoid then
			table.insert(v2[3], char)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateCharactersInSpin(_: string, anchor)
	local _, result = pcall(function()
		if #v > 0 and anchor ~= nil then
			for _, v2 in pairs(v) do
				for _, v3 in pairs(v2[3]) do
					if v3 == nil then
						continue
					end

					local humanoidRootPart = v3:FindFirstChild("HumanoidRootPart")
					local humanoid = v3:FindFirstChild("Humanoid")

					if not humanoidRootPart or not humanoid or not (humanoid.Health > 0) or humanoidRootPart.Anchored then
						continue
					end

					humanoidRootPart.CFrame = anchor.CFrame
				end
			end
		end
	end)

	if result then
		warn("[Anchor] Spin loop encountered bug when updating chars, flushing: " .. tostring(result))
		v = {}
	end
end

return function(player)
	local ID = player.ID

	if ID == 1 then
		local character = player.Character
		local minHold = player.MinHold
		local maxHold = player.MaxHold
		local holdValue = player.HoldValue
		local timestamp = player.Timestamp
		local mouseValue = player.MouseValue
		local GUID = player.GUID
		local _ = masterClock:GetTime() - timestamp

		if not (character and mouseValue) then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")

		if not (humanoidRootPart and humanoid) or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 1500 then
			return
		end

		local flag = false
		local v2 = Util.Sound:Play("AnchorZIntro", humanoidRootPart)
		task.delay(not v2.TimeLength and 0 or v2.TimeLength - 0.05 or 0, function()
			if flag then
				return
			end

			v2 = Util.Sound:Play("AnchorZLoop", humanoidRootPart)
		end)
		local folder = Instance.new("Folder")
		Util.Debris:AddItem(folder, maxHold + 1)
		folder.Name = "AnchorEffects"
		folder.Parent = _WorldOrigin
		local clone = Z.SpinStart:Clone()
		Util.Debris:AddItem(clone, 5)
		clone.CFrame = humanoidRootPart.CFrame
		clone.Parent = folder
		local clone2 = Z.SpinImpact:Clone()
		Util.Debris:AddItem(clone2, 5)
		clone2.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, 0, -1.5707963267948966)
		clone2.Parent = folder
		local clone3 = Z.SpinImpact2:Clone()
		Util.Debris:AddItem(clone3, 5)
		clone3.CFrame = humanoidRootPart.CFrame
		clone3.Parent = folder
		local clone4 = Z.SpinImpact3:Clone()
		Util.Debris:AddItem(clone4, 5)
		clone4.CFrame = humanoidRootPart.CFrame
		clone4.Parent = clone2
		local clone5 = Z.AnchorStartPoint:Clone()
		Util.Debris:AddItem(clone5, 5)
		clone5.CFrame = humanoidRootPart.CFrame
		clone5.Parent = folder
		local clone6 = Z.GroundSpark:Clone()
		Util.Debris:AddItem(clone6, 5)
		clone6.CFrame = clone5.CFrame
		clone6.Parent = folder
		local v3 = {
			SpinSizeMult = 1.25,
			SpinSizeMult2 = 1.5,
			ExtraDelay = 0,
			SlashStartTime = nil,
			SlashSpinLoopWaitTime = 0.35,
			WallSparkStartTime = nil,
			WallSparkWaitTime = 0.05,
			AnchorRotateStartTime = nil,
			MaxAnchorRotateLoopWaitTime = 0.55,
			MinAnchorRotateLoopWaitTime = 0.25,
			SlashSpinRotateSpeed = 0.2,
			AnchorDistance = 10,
			SpinStartStage = 1,
			SpinImpact2Emitting = false,
			SpinImpactSize = 5,
			SpinImpactMaxSize = 90
		}

		for _, effect in pairs(clone6:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		local clone7 = Z.WallSpark:Clone()
		Util.Debris:AddItem(clone7, 5)
		clone7.CFrame = clone5.CFrame
		clone7.Parent = folder

		for _, effect in pairs(clone7:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		local weld = clone5.Weld
		local C0 = weld.C0
		local clone8 = Z.SpinStart:Clone()
		Util.Debris:AddItem(clone8, 5)
		clone8.CFrame = humanoidRootPart.CFrame
		clone8.Parent = folder

		for _, emitter in pairs(clone8:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if emitter.Parent.Name == "Attachment" .. tostring(v3.SpinStartStage) then
				emitter.Enabled = true
			else
				emitter.Enabled = false
			end
		end

		local v4 = false
		local v5 = nil
		local diedConnection = nil

		if humanoid then
			diedConnection = humanoid.Died:Connect(function()
				diedConnection:Disconnect()
			end)
		end

		local function canRun()
			local v6

			if masterClock:GetTime() - timestamp < minHold then
				return true
			else
				v6 = diedConnection and holdValue

				if v6 then
					if holdValue.Value == true then
						return masterClock:GetTime() - timestamp < maxHold
					else
						return false
					end
				end
			end

			return v6
		end

		local v6 = {
			GUID,
			clone5.Anchor,
			{}
		}
		table.insert(v, v6)
		local position = humanoidRootPart.Position
		local steppedConnection = nil
		local lowerTorso = character:FindFirstChild("LowerTorso")

		if lowerTorso then
			local root = lowerTorso:FindFirstChild("Root")
			task.spawn(function()
				local v7 = 0
				steppedConnection = RunService.Stepped:connect(function(_, p)
					if not clone5 or clone5.Parent == nil or not (root and lowerTorso) then
						steppedConnection:Disconnect()
					end

					local cframe = CFrame.new(position, clone5.Anchor.Position)
					root.Transform = misc.cflerp(root.Transform, CFrame.new(0, -0.5, 0) * (cframe - cframe.Position), 1)
					v7 += 25 * p * 60

					if v7 >= 359 then
						v7 -= 359
					end
				end)
			end)
		end

		local value = mouseValue.Value
		local _ = masterClock:GetTime() - timestamp
		local v7 = maxHold

		while true do
			local v8

			if masterClock:GetTime() - timestamp < minHold then
				v8 = true
			else
				v8 = diedConnection

				if v8 then
					if holdValue then
						if holdValue.Value == true then
							v8 = masterClock:GetTime() - timestamp < maxHold
						else
							v8 = false
						end
					else
						v8 = holdValue
					end
				end
			end

			if v8 and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and mouseValue ~= nil and humanoidRootPart and humanoidRootPart.Parent and humanoid then
				value = mouseValue.Value
				position = humanoidRootPart.Position
				v7 = quadInLerp(v7, 0, math.min(1, (masterClock:GetTime() - timestamp) / maxHold))
				local minAnchorRotateLoopWaitTime = v3.MinAnchorRotateLoopWaitTime
				local maxAnchorRotateLoopWaitTime = v3.MaxAnchorRotateLoopWaitTime
				local v10 = v7 / maxHold
				local v11 = minAnchorRotateLoopWaitTime + (maxAnchorRotateLoopWaitTime - minAnchorRotateLoopWaitTime) * v10
				updateCharactersInSpin(nil, clone5.Anchor) -- equivalent call inferred; original call site unknown

				if v3.SlashStartTime == nil or os.clock() - v3.SlashStartTime >= v3.SlashSpinLoopWaitTime then
					v3.SlashStartTime = os.clock()
					local v12 = clone5.Orientation.Y + 50
					SpinSlash(
						humanoidRootPart.CFrame,
						folder,
						v3.SpinSizeMult,
						v3.SpinSizeMult2,
						v3.SlashSpinRotateSpeed,
						math.rad(v12)
					)
					SpinSlash2(
						humanoidRootPart.CFrame,
						folder,
						v3.SpinSizeMult,
						v3.SpinSizeMult2,
						v3.SlashSpinRotateSpeed
					)
					v3.SpinSizeMult = math.clamp(v3.SpinSizeMult + 0.5, 0, 2)
					v3.SpinSizeMult2 = math.clamp(v3.SpinSizeMult2 + 0.5, 0, 3)
					local clone9 = Z.SpinImpact:Clone()
					Util.Debris:AddItem(clone9, 3)
					clone9.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, 0, -1.5707963267948966)
					clone9.Parent = folder
					local clone10 = Z.SpinImpact2:Clone()
					Util.Debris:AddItem(clone10, 3)
					clone10.CFrame = humanoidRootPart.CFrame
					clone10.Parent = folder
					local clone11 = Z.SpinImpact3:Clone()
					Util.Debris:AddItem(clone11, 3)
					clone11.CFrame = humanoidRootPart.CFrame
					clone11.Parent = clone9
					clone9.Size = Vector3.new(0.25, v3.SpinImpactSize, v3.SpinImpactSize)
					clone11.Size = Vector3.new(v3.SpinImpactSize, 0.25, v3.SpinImpactSize)

					for _, emitter in pairs(clone9:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local emitCount = emitter:GetAttribute("EmitCount")

						if emitter:GetAttribute("BigSplash") then
							local v13 = emitCount / 4
							local spinImpactMaxSize = v3.SpinImpactMaxSize
							local spinImpactSize = v3.SpinImpactSize

							if spinImpactSize <= 5 then
								emitCount = v13
							elseif spinImpactSize > 5 and spinImpactSize <= spinImpactMaxSize then
								emitCount = v13 + (emitCount - v13) * ((spinImpactSize - 5) / (spinImpactMaxSize - 5))
							end
						end

						if emitter:GetAttribute("ParticleSize") then
							local particleSize = emitter:GetAttribute("ParticleSize")
							local v13 = particleSize * 2
							local spinImpactMaxSize = v3.SpinImpactMaxSize
							local spinImpactSize = v3.SpinImpactSize

							if spinImpactSize <= 5 then
								v13 = particleSize
							elseif spinImpactSize > 5 and spinImpactSize <= spinImpactMaxSize then
								v13 = particleSize + (v13 - particleSize) * ((spinImpactSize - 5) / (spinImpactMaxSize - 5))
							end

							emitter.Size = NumberSequence.new(v13)
						end

						emitter:Emit(emitCount)
					end

					v3.SpinImpactSize = math.clamp(v3.SpinImpactSize + 30, 5, v3.SpinImpactMaxSize)

					if v3.SpinStartStage <= 4 then
						for _, emitter in pairs(clone8:GetDescendants()) do
							if not (emitter:IsA("ParticleEmitter") and emitter.Parent.Name == "Attachment" .. tostring(v3.SpinStartStage)) then
								continue
							end

							emitter.Enabled = true
						end

						v3.SpinStartStage = math.clamp(v3.SpinStartStage + 1, 1, 5)
					end

					if v3.SpinSizeMult == 2 and v3.SpinImpact2Emitting == false then
						v3.SpinImpact2Emitting = true
						local folder2 = clone10
						task.spawn(function()
							task.wait(0.15 * v3.SpinSizeMult / 1.25)

							if v4 == false then
								for i, emitter in pairs(folder2:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										emitter:Emit(emitter:GetAttribute("EmitCount"))
									end
								end

								v3.SpinImpact2Emitting = false
							end
						end)
					end
				end

				if v3.AnchorRotateStartTime == nil or v11 <= os.clock() - v3.AnchorRotateStartTime then
					v3.AnchorRotateStartTime = os.clock()
					local v12 = v11
					task.spawn(function()
						local v13 = v12 / 3

						if v4 == true then
							return
						end

						v5 = TweenService:Create(
							clone5,
							TweenInfo.new(v13, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = clone5.CFrame * CFrame.Angles(0, 2.6179938779914944, 0)
							}
						)
						v5:Play()
						TweenService:Create(
							weld,
							TweenInfo.new(v13, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
							{
								C0 = C0 * CFrame.new(0, 0, -v3.AnchorDistance)
							}
						):Play()
						task.wait(v13)

						if v4 == true then
							return
						end

						v5 = TweenService:Create(
							clone5,
							TweenInfo.new(v13, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = clone5.CFrame * CFrame.Angles(0, 1.0471975511965976, 0)
							}
						)
						v5:Play()
						task.wait(v13)

						if v4 == true then
							return
						end

						v5 = TweenService:Create(
							clone5,
							TweenInfo.new(v13, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = clone5.CFrame * CFrame.Angles(0, 2.6179938779914944, 0)
							}
						)
						v5:Play()
						v3.AnchorDistance = math.clamp(v3.AnchorDistance * v3.SpinSizeMult, 0, 45)
					end)
				end

				AnchorRotationGroundSparks(clone5, clone6, false) -- equivalent call inferred; original call site unknown
				local anchorDistance = v3.AnchorDistance
				local wallSparkStartTime = v3.WallSparkStartTime
				local wallSparkWaitTime = v3.WallSparkWaitTime

				if wallSparkStartTime == nil or wallSparkWaitTime <= os.clock() - wallSparkStartTime then
					local anchorDistance2 = anchorDistance
					task.spawn(function()
						wallSparkStartTime = os.clock()
						local cframe = CFrame.new(humanoidRootPart.Position, clone5.Anchor.Position)
						local v13 = anchorDistance2 * 1.85
						local ray, position2, v15 = Util.Ray(
							cframe.Position,
							cframe.LookVector.Unit * v13,
							{ workspace.Characters, workspace.Enemies },
							false
						)

						if ray then
							clone7.Position = position2

							for i, effect in pairs(clone7:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = true
								end
							end
						else
							for i, effect in pairs(clone7:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = false
								end
							end
						end
					end)
				end

				RunService.Heartbeat:Wait()
			else
				if steppedConnection then
					steppedConnection:Disconnect()
				end

				if humanoidRootPart then
					humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, value)
				end

				removeSpinFromTable(GUID)
				v4 = true

				for _, emitter in pairs(clone8:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				for _, effect in pairs(clone6:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				for _, effect in pairs(clone7:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				local cframe = CFrame.new(
					humanoidRootPart.Position,
					(Vector3.new(value.X, humanoidRootPart.Position.Y, value.Z))
				)
				flag = true
				Util.Sound:FadeOut(v2, 1)
				v5:Pause()
				v5:Destroy()

				if clone5 then
					local rightVector = cframe.RightVector
					local v9 = clone5.Anchor.Position - cframe.Position
					local clone9 = Z.FinalSpinAttachment.Attachment2:Clone()
					Util.Debris:AddItem(clone9, 5)
					clone9.Parent = clone5.Anchor

					if not (rightVector:Dot(v9) > 20) then
						TweenService:Create(
							clone5,
							TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = cframe * CFrame.Angles(0, -1.5707963267948966, 0)
							}
						):Play()
						task.wait(0.05)
					end

					local tween = TweenService:Create(
						clone5,
						TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							CFrame = cframe * CFrame.Angles(0, -0.17453292519943295, 0)
						}
					)
					tween:Play()
					tween.Completed:Wait()
					clone5.Anchor.Attach_1A.Beam.Enabled = false
					clone9:Destroy()
					local clone10 = Z.StartImpact:Clone()
					Util.Debris:AddItem(clone2, 4)
					clone10.CFrame = cframe
					clone10.Parent = folder
					clone10.Position = clone5.Anchor.Position

					for _, emitter in pairs(clone10:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end

					v3.SpinSizeMult = math.clamp(2 / v7 / 1.5, 1, 2)

					if clone5 then
						clone5:Destroy()
					end
				end

				if diedConnection then
					diedConnection:Disconnect()
					diedConnection = nil
				end

				return
			end
		end
	elseif ID == 2 then
		local timestamp = player.Timestamp
		local cFrame = player.CFrame
		local projLife = player.ProjLife
		local projDist = player.ProjDist
		local time = masterClock:GetTime()
		local v2 = masterClock:GetTime() - timestamp
		local _ = projLife - v2

		if v2 < 2 then
			if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1500 then
				return
			end

			if player.Player == game.Players.LocalPlayer then
				Util.CameraShaker:ShakeOnce(10, 4, 0.15, 0.3)
			end

			local v3 = Util.Sound:Play("AnchorZFire", cFrame)
			local clone = Z.AnchorStartPoint:Clone()
			clone.Anchor.Attach_1A.Beam.Enabled = false
			clone.CFrame = cFrame
			clone.Parent = _WorldOrigin
			local _, _, _ = Util.Ray(
				cFrame.Position,
				cFrame.LookVector.Unit * projDist,
				{ workspace.Characters, workspace.Enemies },
				false
			)
			clone.Weld.Enabled = false
			clone.Anchor.Anchored = true
			clone.Anchor.Weld1.Enabled = false
			clone.Anchor.Weld2.Enabled = true
			clone.Anchor.CFrame = cFrame
			task.spawn(function()
				local v4 = cFrame * CFrame.new(0, 10, -projDist * 0.75)
				local ray, v5, _ = Util.Ray(
					v4.Position,
					CFrame.new(v4.Position, v4.Position + createVector(0, -300, 0)).LookVector * 300,
					{ workspace.Characters, workspace.Enemies },
					false
				)
				local v6 = v5 + createVector(0, 5, 0)

				if not ray then
					clone:Destroy()
					return
				end

				AnchorCurve(clone.Anchor, v6, (v6 - cFrame.Position).Magnitude / 425)
				task.delay(3, function()
					TweenService:Create(clone.Anchor, TweenInfo.new(1), {
						CFrame = clone.Anchor.CFrame - createVector(0, 9, 0)
					}):Play()
					task.wait(1)
					clone:Destroy()
				end)
			end)
			local clone2 = Z.SharkModel:Clone()
			Util.Debris:AddItem(clone2, projLife + 1)
			clone2.PrimaryPart.CFrame = cFrame
			clone2.Parent = _WorldOrigin
			local track = clone2.AnimationController:LoadAnimation(clone2:FindFirstChild("SharkSwim"))
			track:Play()
			track:AdjustSpeed(2)
			local track2 = clone2.AnimationController:LoadAnimation(clone2:FindFirstChild("SharkBite"))
			local clone3 = Z.SharkGroundWater:Clone()
			Util.Debris:AddItem(clone3, projLife + 1)
			clone3.CFrame = clone2.PrimaryPart.CFrame
			clone3.Parent = _WorldOrigin
			local v4 = cFrame
			local v5 = false

			while masterClock:GetTime() - time <= projLife do
				local v6 = math.min((masterClock:GetTime() - time) / projLife, 1)
				local lerped = cFrame:Lerp(cFrame * CFrame.new(0, 0, -projDist), v6)
				local _ = (v4.p - lerped.p).Magnitude
				clone3:PivotTo(lerped)
				clone2:PivotTo(lerped)

				if v5 == false then
					local v7 = masterClock:GetTime() - time

					if projLife - 0.125 < v7 then
						track2:Play(0.025, nil, track2.Length / 0.125)
						local clone4 = Z.Bite:Clone()
						Util.Debris:AddItem(clone4, 3)
						clone4.CFrame = cFrame * CFrame.new(0, 0, -projDist) * CFrame.new(0, 0, -20)
						clone4.Parent = workspace._WorldOrigin
						v4 = lerped
						v5 = true

						for _, emitter in pairs(clone4:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v8 = emitter
							coroutine.wrap(function()
								if v8:GetAttribute("EmitDelay") ~= 0 then
									task.wait(v8:GetAttribute("EmitDelay"))
								end

								v8:Emit(v8:GetAttribute("EmitCount"))
							end)()
						end
					else
						v4 = lerped
					end
				else
					v4 = lerped
				end

				RunService.Heartbeat:Wait()
			end

			local v6 = cFrame * CFrame.new(0, 0, -projDist)
			clone3:PivotTo(v6)
			clone2:PivotTo(v6)

			for _, effect in pairs(clone3:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			task.delay(0.05, function()
				clone2:Destroy()
			end)
			Util.Sound:FadeOut(v3, 0.5)
			WaterExplosion(_WorldOrigin, clone2)
		end
	elseif ID == 3 then
		local chars = player.Chars
		local GUID = player.GUID

		for _, char in pairs(chars) do
			addCharacterToSpin(GUID, char)
		end
	end
end