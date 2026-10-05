local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local _ = Util.BoatTween
local _ = Util.Sound
local _ = Util.MasterClock
local debris = Util.Debris
local scaleParticle2 = Util.ScaleParticle2

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

local function charInRange(vector2: Vector3, p: number)
	local character = game.Players.LocalPlayer.Character
	local humanoidRootPart = character ~= nil and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local magnitude = (humanoidRootPart.Position - vector2).magnitude

		if magnitude <= p then
			return magnitude
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ScreenEffect(position)
	local character = game.Players.LocalPlayer.Character
	local humanoidRootPart = character ~= nil and character:FindFirstChild("HumanoidRootPart")
	local magnitude

	if humanoidRootPart then
		magnitude = (humanoidRootPart.Position - position).magnitude

		if not (magnitude <= 50) then
			magnitude = false
		end
	else
		magnitude = false
	end

	if magnitude then
		task.spawn(function()
			local clone = script.Bloom:Clone()
			debris:AddItem(clone, 2)
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

local function ExplosionSlashes(cFrame, clonesByClone, p)
	task.spawn(function()
		local clone = script.SpinSlash4:Clone()
		debris:AddItem(clone, 7)
		clone.CFrame = cFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
		clone.Parent = _WorldOrigin
		clonesByClone[clone] = clone
		local v = 6 * p
		local v2 = 6 * p
		local v3 = 4.5 * p

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("Beam") then
				local v4 = descendant
				task.spawn(function()
					v4.CurveSize0 *= v
					v4.CurveSize1 *= v
					v4.Width0 *= v
					v4.Width1 *= v
					local tween = TweenService:Create(
						v4,
						TweenInfo.new(5.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CurveSize0 = v4.CurveSize0 * v2,
							CurveSize1 = v4.CurveSize1 * v2,
							Width0 = v4.Width0 * v2,
							Width1 = v4.Width1 * v2
						}
					)
					tween:Play()
					tween.Completed:Wait()
					local tween2 = TweenService:Create(
						v4,
						TweenInfo.new(5.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CurveSize0 = v4.CurveSize0 * v3,
							CurveSize1 = v4.CurveSize1 * v3,
							Width0 = v4.Width0 * v3,
							Width1 = v4.Width1 * v3
						}
					)
					tween2:Play()
					tween2.Completed:Wait()
					local endDelay = v4:GetAttribute("EndDelay")
					local tween3 = TweenService:Create(
						v4,
						TweenInfo.new(endDelay / 10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Width0 = 0,
							Width1 = 0
						}
					)
					tween3:Play()
					tween3.Completed:Wait()
					v4:Destroy()
				end)
			elseif descendant:IsA("Attachment") then
				local v4 = descendant
				task.spawn(function()
					v4.Position = Vector3.new(v4.Position.X * v, v4.Position.Y * v, v4.Position.Z * v)
					local tween = TweenService:Create(
						v4,
						TweenInfo.new(5.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Position = Vector3.new(v4.Position.X * v2, v4.Position.Y * v2, v4.Position.Z * v2)
						}
					)
					tween:Play()
					tween.Completed:Wait()
					TweenService:Create(v4, TweenInfo.new(5.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = Vector3.new(v4.Position.X * v3, v4.Position.Y * v3, v4.Position.Z * v3)
					}):Play()
				end)
			end
		end

		local v4 = math.random(70, 120)
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = clone.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(0, math.rad(v4), 0)
			}
		)
		tween:Play()
		tween.Completed:Wait()
		local tween2 = TweenService:Create(
			clone,
			TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = clone.CFrame * CFrame.new(0, 12, 0) * CFrame.Angles(0, math.rad(v4), 0)
			}
		)
		tween2:Play()
		tween2.Completed:Wait()
		local tween3 = TweenService:Create(
			clone,
			TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = clone.CFrame * CFrame.new(0, 13, 0) * CFrame.Angles(0, math.rad(v4), 0)
			}
		)
		tween3:Play()
		tween3.Completed:Wait()
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			CFrame = clone.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(0, math.rad(v4), 0)
		}):Play()
	end)
	task.spawn(function()
		local clone = script.SpinSlash5:Clone()
		debris:AddItem(clone, 5)
		clone.CFrame = cFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
		clone.Parent = _WorldOrigin
		clonesByClone[clone] = clone

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("Beam") then
				local v = descendant
				task.spawn(function()
					v.CurveSize0 *= 5.5
					v.CurveSize1 *= 5.5
					v.Width0 *= 5.5
					v.Width1 *= 5.5
					local tween = TweenService:Create(
						v,
						TweenInfo.new(2.525, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CurveSize0 = v.CurveSize0 * 7.5,
							CurveSize1 = v.CurveSize1 * 7.5,
							Width0 = v.Width0 * 7.5,
							Width1 = v.Width1 * 7.5
						}
					)
					tween:Play()
					tween.Completed:Wait()
					local tween2 = TweenService:Create(
						v,
						TweenInfo.new(2.525, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CurveSize0 = v.CurveSize0 * 16.25,
							CurveSize1 = v.CurveSize1 * 16.25,
							Width0 = v.Width0 * 16.25,
							Width1 = v.Width1 * 16.25
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
					v.Position = Vector3.new(v.Position.X * 5.5, v.Position.Y * 5.5, v.Position.Z * 5.5)
					local tween = TweenService:Create(
						v,
						TweenInfo.new(2.525, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Position = Vector3.new(v.Position.X * 7.5, v.Position.Y * 7.5, v.Position.Z * 7.5)
						}
					)
					tween:Play()
					tween.Completed:Wait()
					TweenService:Create(v, TweenInfo.new(2.525, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = Vector3.new(v.Position.X * 16.25, v.Position.Y * 16.25, v.Position.Z * 16.25)
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

local function WaterExplosion(cFrame, scale)
	local v = scale * 0.6
	local v2 = v < 1 and 1 or v
	task.spawn(function()
		for _ = 1, 20 do
			task.spawn(function()
				local clone = script.Trail:Clone()
				debris:AddItem(clone, 1)
				clone.CFrame = cFrame * CFrame.new(
					math.random(-100 * v2, 100 * v2),
					math.random(-5, 50 * v2),
					math.random(-100 * v2, 100 * v2)
				)
				clone.Parent = _WorldOrigin

				for _, emitter in pairs(clone:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					scaleParticle2(emitter, scale, true)
					emitter.Enabled = true
				end

				Curve(clone, cFrame.Position + Vector3.new(0, 7 * v2, 0))

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
			task.wait()
		end
	end)
	local ray, _, _ = Util.Ray(
		cFrame.Position + createVector(0, 1, 0),
		CFrame.new(cFrame.Position).UpVector * -25,
		{ workspace.Characters, workspace.Enemies },
		false
	)
	local clone

	if ray then
		clone = script.GroundExplosionSplashStart:Clone()
		debris:AddItem(clone, 5)
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			scaleParticle2(emitter, scale, true)
			emitter.Enabled = true
		end
	end

	task.wait(0.2)
	local v3 = {}

	for _ = 1, 10 do
		ExplosionSlashes(cFrame, v3, v2)
		task.wait(0.025)
	end

	local clone2 = script.ExplosionStartImpact:Clone()
	debris:AddItem(clone2, 5)
	clone2.CFrame = cFrame * CFrame.new(0, 10, 0)
	clone2.Parent = _WorldOrigin
	local descendants = clone2:GetDescendants()

	for _, emitter in pairs(descendants) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		scaleParticle2(emitter, scale, true)
		local v4 = emitter
		coroutine.wrap(function()
			if v4:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v4:GetAttribute("EmitDelay"))
			end

			v4:Emit(v4:GetAttribute("EmitCount"))
		end)()
	end

	for _, v4 in pairs(v3) do
		v4:Destroy()
	end

	task.wait(0.4)
	local clone3 = script.ExplosionStartImpact2:Clone()
	debris:AddItem(clone3, 5)
	clone3.CFrame = cFrame * CFrame.new(0, 10, 0)
	clone3.Parent = _WorldOrigin

	for _, emitter in pairs(clone3:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		scaleParticle2(emitter, scale, true)
		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end

	task.wait(0.1)

	if clone ~= nil then
		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end

	local clone4 = script.ExplosionImpact:Clone()
	debris:AddItem(clone4, 5)
	clone4.CFrame = cFrame * CFrame.new(0, 10, 0)
	clone4.Parent = _WorldOrigin
	local descendants2 = clone4:GetDescendants()

	for _, emitter in pairs(descendants2) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		scaleParticle2(emitter, scale, true)
		local v4 = emitter
		task.spawn(function()
			if v4:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v4:GetAttribute("EmitDelay"))
			end

			v4:Emit(v4:GetAttribute("EmitCount"))
		end)
	end

	ScreenEffect(cFrame.Position) -- equivalent call inferred; original call site unknown
end

return function(data)
	local ID = data.ID

	if ID == 1 then
		local scale = data.Scale or 1
		local cFrame = data.CFrame

		if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > 1000 then
			return
		end

		Util.Sound:Play("AnchorZBoom", cFrame.Position, 50 * scale)
		WaterExplosion(cFrame * CFrame.new(0, math.rad((math.random(0, 360))), 0), scale)
	elseif ID == 2 then
		local scale = data.Scale or 1
		local cFrame = data.CFrame

		if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > 1800 then
			return
		end

		Util.Sound:Play("AnchorZFire", cFrame.Position, 50 * scale)
		Util.Sound:Play("SandCWind", cFrame.Position, 50 * scale, 0.5, 2)
		local clone = script.ChargeUp:Clone()
		debris:AddItem(clone, 5)

		for _, child in pairs(clone.Attachment:GetChildren()) do
			scaleParticle2(child, scale, true)
		end

		clone.CFrame = CFrame.new(cFrame.Position)
		clone.Parent = _WorldOrigin
		local lastTime = os.clock()
		local now = os.clock() - 1

		while os.clock() - lastTime < 0.6 do
			clone.CFrame = CFrame.new(data.HRP.CFrame * createVector(0, 7, 0))

			if os.clock() - now > 0.02 then
				for _, child in pairs(clone.Attachment:GetChildren()) do
					if child.Name ~= "Roar" then
						child:Emit(child:GetAttribute("EmitCount"))
					end
				end

				now = os.clock()
			end

			RunService.Heartbeat:Wait()
		end
	end
end