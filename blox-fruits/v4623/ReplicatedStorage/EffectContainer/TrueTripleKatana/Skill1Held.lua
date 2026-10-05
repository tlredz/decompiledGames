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
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local skill1 = FX:WaitForChild("TrueTripleKatana").Skill1
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function cubicBezier(p, position, p2, p3, position2)
	local v = position + (p2 - position) * p
	local v2 = p2 + (p3 - p2) * p
	local v3 = p3 + (position2 - p3) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

return function(data)
	local _ = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 600 then
		return
	end

	local parent = _WorldOrigin
	local clone = skill1.Hold:Clone()
	clone.CFrame = CFrame.new(hrp.Position + Vector3.new(0, -3 + clone.Size.Y / 2, 0))
	clone.Parent = _WorldOrigin
	os.clock()
	local descendants = clone:GetDescendants()
	local children = clone.Attach_1:GetChildren()
	local v3 = Util.Sound:Play("1-DragonHurricaneCharge", hrp)
	local lastTime = os.clock()
	local v4 = time()
	local v5 = 0.001

	while true do
		clone.CFrame = CFrame.new(hrp.Position + Vector3.new(0, -3 + clone.Size.Y / 2, 0))
		local v6 = os.clock() - lastTime

		if v5 * 2 <= v6 then
			lastTime = os.clock()
			local attach_0 = clone.Attach_0
			local attach_1 = clone.Attach_1
			local v7 = math.random(0, 1)
			v5 = math.random(10, 15) / 300
			local v8 = math.random(7, 15) / 10
			local v9 = 7 * v8
			local tween = TweenService:Create(
				attach_0,
				TweenInfo.new(v5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
				{
					Position = Vector3.new(0, v7, -v9)
				}
			)
			local tween2 = TweenService:Create(
				attach_1,
				TweenInfo.new(v5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
				{
					Position = Vector3.new(0, v7, v9)
				}
			)
			tween:Play()
			tween2:Play()
			local curveSize = 9 * v8

			for _, v11 in ipairs(children) do
				if v11.Name == "Beam" or v11.Name == "Beam3" then
					TweenService:Create(
						v11,
						TweenInfo.new(v5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
						{
							CurveSize0 = -curveSize,
							CurveSize1 = curveSize,
							Width0 = 5,
							Width1 = 5
						}
					):Play()
				else
					TweenService:Create(
						v11,
						TweenInfo.new(v5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
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

		task.spawn(function()
			local position = hrp.Position
			local holdTrails = skill1.HoldTrails
			local clone2 = nil
			local v7 = math.random(1, #holdTrails:GetChildren())

			if v7 == 1 then
				clone2 = holdTrails.TrailA:Clone()
			elseif v7 == 2 then
				clone2 = holdTrails.TrailB:Clone()
			elseif v7 == 3 then
				clone2 = holdTrails.TrailC:Clone()
			elseif v7 == 4 then
				clone2 = holdTrails.TrailD:Clone()
			end

			clone2.CFrame = hrp.CFrame * CFrame.new(math.random(-25, 25), math.random(2, 10), math.random(-25, 25))
			clone2.Parent = parent
			destroyAfter(clone2, 3)
			local position2 = clone2.Position
			local magnitude = (position2 - position).Magnitude
			clone2.CFrame = CFrame.new(position2, position)
			local v8 = (position2 - position) / 2
			local position3 = CFrame.new(CFrame.new(position2) * (v8 / -1.5)).Position
			local position4 = CFrame.new(CFrame.new(position) * (v8 / 1.5)).Position
			local halfMagnitude = magnitude / 2
			local v10 = position3 + Vector3.new(
				math.random(-halfMagnitude, halfMagnitude),
				math.random(-halfMagnitude / 2, halfMagnitude),
				math.random(-halfMagnitude, halfMagnitude)
			)
			local v11 = position4 + Vector3.new(
				math.random(-halfMagnitude, halfMagnitude),
				math.random(-halfMagnitude / 2, halfMagnitude),
				math.random(-halfMagnitude, halfMagnitude)
			)
			local v12 = math.random(10, 20) / 10
			local lastTime2 = tick()
			local v13 = magnitude / v12 / 60

			while tick() - lastTime2 < v13 do
				local v14 = (tick() - lastTime2) / v13
				local v15 = cubicBezier(v14, position2, v10, v11, position)
				clone2.CFrame = clone2.CFrame:Lerp(CFrame.new(v15, position), v14)
				task.wait()
			end

			for _, emitter in ipairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			destroyAfter(clone2, 1)
		end)
		task.wait(0.1)

		if not (data.skill1Held.Value == false or not data.skill1Held:IsDescendantOf(Workspace) or time() - v4 > 600) then
			continue
		end

		for _, effect in ipairs(descendants) do
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
		Util.Sound:FadeOut(v3, 0.25)
		break
	end
end