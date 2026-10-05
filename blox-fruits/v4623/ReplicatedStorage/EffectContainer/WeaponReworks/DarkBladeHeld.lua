local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
require(ReplicatedStorage:WaitForChild("FX"))
local script2 = script
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local scaleParticle = Util.ScaleParticle

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function cubicBezier(p, p2, p3, p4, p5)
	local v = p2 + (p3 - p2) * p
	local v2 = p3 + (p4 - p3) * p
	local v3 = p4 + (p5 - p4) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

return function(data)
	local _ = data.player
	local hrp = data.hrp
	local chargeTime = data.chargeTime
	local special = data.special

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 600 then
		return
	end

	local parent = _WorldOrigin
	local clone = script2.Hold:Clone()
	clone.CFrame = CFrame.new(hrp.Position + Vector3.new(0, -3 + clone.Size.Y / 2, 0))
	clone.Parent = _WorldOrigin
	os.clock()
	local descendants = clone:GetDescendants()

	if special then
		for _, effect in pairs(descendants) do
			if not ((effect:IsA("ParticleEmitter") or effect:IsA("Beam")) and effect.Color.Keypoints[1].Value ~= Color3.new()) then
				continue
			end

			effect.Color = ColorSequence.new(Color3.new(1, 1, 1))
		end
	end

	local children = clone.Attach_1:GetChildren()
	local v3 = Util.Sound:Play("RengokuChargeWindup", hrp, 9, 1.175)
	local v4 = Util.Sound:Play("Burn1", hrp, 9)
	local lastTime = os.clock()
	local v5 = time()
	local v6 = false
	local v7 = false
	local v8 = 0.1

	while true do
		clone.CFrame = CFrame.new(hrp.Position + Vector3.new(0, -3 + clone.Size.Y / 2, 0))

		if chargeTime < time() - v5 and not v6 then
			v6 = true

			for _, emitter in pairs(clone:GetChildren()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local clone2 = emitter:Clone()
				scaleParticle({
					Emitter = clone2,
					Scale = 2,
					Time = 0
				})
				clone2.SpreadAngle = Vector2.new(60, 60)
				clone2.Parent = emitter.Parent
				clone2:Emit(clone2:GetAttribute("EmitCount"))
				local v9 = emitter
				task.delay(0.1, function()
					v9.Enabled = true
				end)
			end
		end

		local v9 = time() - v5

		if chargeTime * 0.5 < v9 and not v7 then
			v7 = true

			for i = 1, 4 do
				local v10 = i
				task.spawn(function()
					local position = hrp.Position
					local holdTrails = script2.HoldTrails
					local clone2 = nil
					local v11 = v10

					if v11 == 1 then
						clone2 = holdTrails.TrailA:Clone()
					elseif v11 == 2 then
						clone2 = holdTrails.TrailB:Clone()
					elseif v11 == 3 then
						clone2 = holdTrails.TrailC:Clone()
					elseif v11 == 4 then
						clone2 = holdTrails.TrailD:Clone()
					end

					if special then
						for i2, trail in pairs(clone2:GetDescendants()) do
							if not (trail:IsA("Trail") and trail.Color.Keypoints[1].Value ~= Color3.new()) then
								continue
							end

							trail.Color = ColorSequence.new(Color3.new(1, 1, 1))
						end
					end

					clone2.CFrame = hrp.CFrame * CFrame.new(0, 20, 0)
					clone2.Parent = parent
					destroyAfter(clone2, 3)
					local position2 = clone2.Position
					local lastTime2 = tick()
					local v12 = chargeTime * 0.5 * 0.95 * (v10 / 4 * 0.25 + 0.75)

					while tick() - lastTime2 < v12 do
						local v13 = (tick() - lastTime2) / v12
						clone2.CFrame = CFrame.new(position2:Lerp(position, v13)) * CFrame.Angles(
							0,
							v13 * 3.141592653589793 * 2 + v10 * 3.141592653589793 / 2,
							0
						) * CFrame.new(0, 0, -14 + v13 * 13)
						task.wait()
					end

					clone2.CFrame = CFrame.new(position)

					for i2, emitter in ipairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					destroyAfter(clone2, 1)
				end)
			end

			local attach_0 = clone.Attach_0
			local attach_1 = clone.Attach_1
			local v10 = chargeTime * 0.5
			local v11 = 1 * 1.5
			local tween = TweenService:Create(
				attach_0,
				TweenInfo.new(v10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Position = Vector3.new(0, 0, -v11)
				}
			)
			local tween2 = TweenService:Create(
				attach_1,
				TweenInfo.new(v10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Position = Vector3.new(0, 0, v11)
				}
			)
			tween:Play()
			tween2:Play()
			local curveSize = 1 * 1.5

			for _, v13 in ipairs(children) do
				if v13.Name == "Beam" or v13.Name == "Beam3" then
					TweenService:Create(v13, TweenInfo.new(v10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						CurveSize0 = -curveSize,
						CurveSize1 = curveSize,
						Width0 = 0,
						Width1 = 0
					}):Play()
				else
					TweenService:Create(v13, TweenInfo.new(v10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						CurveSize0 = curveSize,
						CurveSize1 = -curveSize,
						Width0 = 0,
						Width1 = 0
					}):Play()
				end
			end
		end

		if v8 <= os.clock() - lastTime and not v7 then
			lastTime = os.clock()
			local attach_0 = clone.Attach_0
			local attach_1 = clone.Attach_1
			local v10 = math.random(0, 1)
			v8 = math.random(10, 15) / 300
			local v11 = math.random(7, 15) / 10
			local v12 = 7 * v11
			local tween = TweenService:Create(
				attach_0,
				TweenInfo.new(v8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
				{
					Position = Vector3.new(0, v10, -v12)
				}
			)
			local tween2 = TweenService:Create(
				attach_1,
				TweenInfo.new(v8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
				{
					Position = Vector3.new(0, v10, v12)
				}
			)
			tween:Play()
			tween2:Play()
			local curveSize = 9 * v11

			for _, v14 in ipairs(children) do
				if v14.Name == "Beam" or v14.Name == "Beam3" then
					TweenService:Create(
						v14,
						TweenInfo.new(v8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
						{
							CurveSize0 = -curveSize,
							CurveSize1 = curveSize,
							Width0 = 5,
							Width1 = 5
						}
					):Play()
				else
					TweenService:Create(
						v14,
						TweenInfo.new(v8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
						{
							CurveSize0 = curveSize,
							CurveSize1 = -curveSize,
							Width0 = 5,
							Width1 = 5
						}
					):Play()
				end
			end
		end

		task.wait()

		if not (data.skill1Held.Value == false or not data.skill1Held:IsDescendantOf(Workspace) or time() - v5 > 600) then
			continue
		end

		local descendants2 = clone:GetDescendants()

		for _, effect in ipairs(descendants2) do
			if effect:IsA("Beam") then
				TweenService:Create(effect, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			elseif effect:IsA("ParticleEmitter") then
				effect.Enabled = false
			end
		end

		destroyAfter(clone, 2)
		Util.Sound:FadeOut(v4, 0.25)
		Util.Sound:FadeOut(v3, 0.25)
		break
	end
end