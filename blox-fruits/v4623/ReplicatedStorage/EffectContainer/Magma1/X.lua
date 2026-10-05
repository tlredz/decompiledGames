local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local _ = Util.Sound
local masterClock = Util.MasterClock

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback()
		end
	end
end

function cubicBezier(p, p2, p3, p4, p5)
	return p2 * (1 - p) ^ 3 + p3 * 3 * p * (1 - p) ^ 2 + p4 * 3 * (1 - p) * p ^ 2 + p5 * p ^ 3
end

local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local _ = workspace.Map
local debris = Util.Debris
local MagmaPuddle = require(ReplicatedStorage.EffectContainer.Magma1.MagmaPuddle)
local v = {
	TweenInfo.new(0.2, Enum.EasingStyle.Sine),
	TweenInfo.new(1.4, Enum.EasingStyle.Linear),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true),
	TweenInfo.new(0.4, Enum.EasingStyle.Quint),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine),
	TweenInfo.new(0.35, Enum.EasingStyle.Quad),
	TweenInfo.new(0.2, Enum.EasingStyle.Sine),
	TweenInfo.new(0.26666666666666666, Enum.EasingStyle.Quart),
	TweenInfo.new(0.39999999999999997, Enum.EasingStyle.Quad),
	TweenInfo.new(0.6666666666666666, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
}

local function createEffect(cFrame, model, p, p2)
	local clone = model:Clone()
	clone.Name = p or clone.Name

	if model:IsA("Model") then
		clone:SetPrimaryPartCFrame(cFrame)
	else
		clone.CFrame = cFrame
	end

	clone.Parent = p2 or _WorldOrigin
	return clone
end

local function magmaMeteor(surfaceHit, startPos, goalPos, lifetime, timestamp, puddleSize)
	local _ = masterClock:GetTime() - timestamp
	local clone = script.Rock:Clone()
	debris:AddItem(clone, lifetime + 1)
	clone.Anchored = true
	clone.Position = startPos
	clone.Parent = _WorldOrigin
	task.spawn(function()
		local v2 = math.min((startPos - goalPos).Magnitude / 0.25, 200)
		local v3 = {
			startPos,
			startPos:Lerp(Vector3.new(goalPos.X, startPos.Y + v2, goalPos.Z), 0.25),
			startPos:Lerp(Vector3.new(goalPos.X, goalPos.Y + v2, goalPos.Z), 0.75),
			goalPos
		}
		local lastTime = tick()

		while tick() - lastTime <= lifetime do
			local v4 = tick() - lastTime
			local v5 = cubicBezier(v4 / lifetime, unpack(v3))
			clone.CFrame = CFrame.new(v5)
			RunService.RenderStepped:Wait()
		end

		task.wait()

		if surfaceHit then
			Util.Sound:Play("MagmaSmallSummon", goalPos, nil, 1.3 + math.random(-10, 10) / 100, 1)
		end

		clone.Transparency = 1

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if emitter.Parent.Name == "Explode" then
				emitter:Emit(emitter:GetAttribute("EmitCount") / 2)
			else
				emitter.Enabled = false
			end
		end

		if surfaceHit then
			MagmaPuddle(clone.Position, puddleSize, nil, 3)
		end

		if clone then
			clone:Destroy()
		end
	end)
end

return function(data)
	local subEffect = data.SubEffect

	if subEffect == 1 then
		local spawnPos = data.SpawnPos

		if (workspace.CurrentCamera.CFrame.Position - spawnPos).magnitude > 700 then
			return
		end

		local v2 = CFrame.new(spawnPos) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
		local cframe = CFrame.new(spawnPos)
		local puddle = script.puddle
		local clone = puddle:Clone()
		clone.Name = clone.Name

		if puddle:IsA("Model") then
			clone:SetPrimaryPartCFrame(cframe)
		else
			clone.CFrame = cframe
		end

		clone.Parent = _WorldOrigin
		local children = clone:GetChildren()
		debris:AddItem(clone, 2)

		for _, v3 in pairs(children) do
			if v3.Name == "red" then
				TweenService:Create(v3, v[1], {
					Size = 5 * v3.Size,
					Orientation = v3.Orientation + createVector(0, 45, 0),
					Position = v3.Position - createVector(0, 0.25, 0)
				}):Play()
			elseif v3.Name == "orange" then
				TweenService:Create(v3, v[1], {
					Size = 5 * v3.Size,
					Orientation = v3.Orientation + createVector(0, 45, 0),
					Position = v3.Position - createVector(0, 0.25, 0)
				}):Play()
			else
				TweenService:Create(v3, v[1], {
					Size = 5 * v3.Size,
					Orientation = v3.Orientation + createVector(0, 45, 0)
				}):Play()
			end
		end

		task.wait(0.15)
		Util.Sound:Play("MagmaEruption", spawnPos, nil, 1 + math.random(-10, 10) / 100, 1)
		local character = game.Players.LocalPlayer.Character

		if character ~= nil then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and (humanoidRootPart.Position - spawnPos).magnitude <= 75 then
				Util.CameraShaker:Shake(Util.CameraShaker.Presets.Explosion2)
			end
		end

		for _, v3 in pairs(children) do
			TweenService:Create(v3, v[2], {
				Size = v3.Size * 1.35
			}):Play()
		end

		if (workspace.CurrentCamera.CFrame.Position - v2.Position).magnitude < 50 then
			local clone2 = script.Blur:Clone()
			debris:AddItem(clone2, 1)
			clone2.Parent = game.Lighting
			TweenService:Create(clone2, v[3], {
				Size = 10
			}):Play()
		end

		local cFrame = v2 * CFrame.new(0, -2, 0) * CFrame.Angles(0, 0, 1.57)
		local eruption = script.Eruption
		local clone2 = eruption:Clone()
		clone2.Name = clone2.Name

		if eruption:IsA("Model") then
			clone2:SetPrimaryPartCFrame(cFrame)
		else
			clone2.CFrame = cFrame
		end

		clone2.Parent = _WorldOrigin
		debris:AddItem(clone2, 2)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local cFrame2 = v2 * CFrame.new(0, 3, 0) * CFrame.Angles(0, 0, 1.57)
		local middleShock = script.MiddleShock
		local clone3 = middleShock:Clone()
		clone3.Name = clone3.Name

		if middleShock:IsA("Model") then
			clone3:SetPrimaryPartCFrame(cFrame2)
		else
			clone3.CFrame = cFrame2
		end

		clone3.Parent = _WorldOrigin
		debris:AddItem(clone3, 1)
		TweenService:Create(clone3, v[4], {
			CFrame = clone3.CFrame * CFrame.new(15, 0, 0)
		}):Play()
		TweenService:Create(clone3.Mesh, v[5], {
			Scale = clone3.Mesh.Scale * createVector(8.1, 0, 0) * 1.5
		}):Play()
		local cFrame3 = v2 * CFrame.new(0, -1, 0) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 1.57)
		local shockwave = script.Shockwave
		local clone4 = shockwave:Clone()
		clone4.Name = clone4.Name

		if shockwave:IsA("Model") then
			clone4:SetPrimaryPartCFrame(cFrame3)
		else
			clone4.CFrame = cFrame3
		end

		clone4.Parent = _WorldOrigin
		debris:AddItem(clone4, 1)
		TweenService:Create(clone4, v[6], {
			CFrame = clone4.CFrame * CFrame.new(-2, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		}):Play()
		TweenService:Create(clone4.Mesh, v[7], {
			Scale = createVector(0.3, 1.2, 1.2)
		}):Play()
		TweenService:Create(clone4.Decal, v[7], {
			Transparency = 1
		}):Play()
		local cFrame4 = v2 * CFrame.new(0, 1.5, 0) * CFrame.Angles(
			0,
			math.rad((math.random(-180, 180))),
			1.5707963267948966
		)
		local shockwave2 = script.Shockwave2
		local clone5 = shockwave2:Clone()
		clone5.Name = clone5.Name

		if shockwave2:IsA("Model") then
			clone5:SetPrimaryPartCFrame(cFrame4)
		else
			clone5.CFrame = cFrame4
		end

		clone5.Parent = _WorldOrigin
		debris:AddItem(clone5, 1)
		TweenService:Create(clone5, v[8], {
			CFrame = clone5.CFrame * CFrame.new(-3.7, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		}):Play()
		TweenService:Create(clone5.Mesh, v[9], {
			Scale = createVector(0, 0.90000004, 0.90000004)
		}):Play()
		TweenService:Create(clone5.Decal, v[10], {
			Transparency = 1
		}):Play()
		task.wait(0.75)

		for _, v7 in pairs(children) do
			TweenService:Create(v7, v[1], {
				Size = Vector3.new()
			}):Play()
		end
	elseif subEffect == 2 then
		local startPos = data.StartPos
		local goalPos = data.GoalPos
		local lifetime = data.Lifetime
		local timestamp = data.Timestamp
		local puddleSize = data.PuddleSize
		magmaMeteor(data.SurfaceHit, startPos, goalPos, lifetime, timestamp, puddleSize)
	end
end