local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local debris = Util.Debris
TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo2 = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo3 = TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local resume = coroutine.resume
local create = coroutine.create

local function rocks(data)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = data.ignore

	for i = 1, data.amount do
		local clone = script.RockMesh:Clone()
		clone.CastShadow = false
		clone.Size = createVector(0.5, 0.5, 0.5)
		clone.CanCollide = false
		clone.Anchored = true
		clone.CFrame = data.origin * CFrame.fromOrientation(0, math.rad(360 / data.amount * i), 0) * CFrame.new(
			0,
			0,
			data.offset - data.offset / 2
		)
		clone.Parent = _WorldOrigin
		local raycastResult = workspace:Raycast(
			data.origin * CFrame.Angles(0, math.rad(360 / data.amount * i), 0) * CFrame.new(0, 0, data.offset).Position + createVector(
				0,
				10,
				0
			),
			createVector(0, -20, 0),
			raycastParams
		)

		if raycastResult then
			clone.Color = raycastResult.Instance.Color
			clone.Material = raycastResult.Material
			clone.Rocks.Color = ColorSequence.new(raycastResult.Instance.Color)
			clone.sm2.Color = ColorSequence.new(raycastResult.Instance.Color)
			local v = clone
			task.delay(0.3, function()
				v.Rocks:Emit(17)
				v.sm2:Emit(9)
			end)
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(data.tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Size = Vector3.new(
						math.random(data.size[1] - data.size[1] / 3.5, data.size[1]),
						math.random(data.size[2] - data.size[2] / 3.5, data.size[2]),
						math.random(data.size[3] - data.size[3] / 3.5, data.size[3])
					),
					CFrame = CFrame.new(raycastResult.Position) * CFrame.fromOrientation(
						0,
						math.rad(360 / data.amount * i),
						0
					) * CFrame.Angles(math.rad((math.random(-65, -45))), 0, 0)
				}
			)
			tween:Play()
			local v3 = clone
			coroutine.wrap(function()
				tween.Completed:Wait()
				task.wait(data.waitTime)
				local tween2 = TweenService:Create(
					v3,
					TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Position = v3.Position - Vector3.new(0, data.size[2] / 2, 0),
						Transparency = 1,
						Size = Vector3.new()
					}
				)
				tween2:Play()
				tween2.Completed:Wait()
				v3:Destroy()
			end)()
		else
			clone:Destroy()
		end
	end
end

for _, emitter in pairs(script.sandexplosion:GetDescendants()) do
	if emitter:IsA("ParticleEmitter") then
		Util.ScaleParticle({
			Emitter = emitter,
			Scale = 1.75,
			Time = 0
		})
	end
end

local function projectileExplosion(lastCF, _, norm)
	local cFrame = CFrame.new(lastCF.Position, lastCF.Position + norm) * CFrame.Angles(-1.5707963267948966, 0, 0)
	local clone = script.sandexplosion:Clone()
	clone.CFrame = cFrame * CFrame.new(0, 1, 0)
	clone.Parent = _WorldOrigin
	debris:AddItem(clone, 3)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	Util.Sound:Play("SandVExplosion", clone.Position)
	coroutine.wrap(function()
		rocks({
			origin = clone.CFrame * CFrame.new(0, 1, 0),
			amount = 7,
			size = { 7, 7, 8.5 },
			offset = 33.25,
			ignore = {
				_WorldOrigin,
				workspace.CurrentCamera,
				workspace.Characters,
				workspace.Enemies
			},
			tweenTime = 0.5,
			waitTime = 1
		})
	end)()

	if (workspace.CurrentCamera.CFrame.Position - lastCF.Position).Magnitude < 150 then
		Util.CameraShaker:Shake(Util.CameraShaker.Presets.Explosion)
	end

	resume(create(function()
		for _ = 1, 1 do
			local clone2 = script.Ring:Clone()
			clone2.Position = lastCF.Position
			clone2.Parent = _WorldOrigin
			TweenService:Create(clone2, tweenInfo3, {
				Size = createVector(78.75, 1.01325, 78.75),
				Transparency = 1
			}):Play()
			task.wait(0.1)
		end
	end))
	local clone2 = script["8smash"]:Clone()
	debris:AddItem(clone2, 0.9)
	clone2.CFrame = cFrame
	clone2.Parent = _WorldOrigin
	TweenService:Create(clone2, tweenInfo, {
		Transparency = 1,
		CFrame = clone2.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
	}):Play()
	local clone3 = script.BlackPart:Clone()
	debris:AddItem(clone3, 1)
	clone3.Parent = _WorldOrigin
	clone3.Position = lastCF.Position
	TweenService:Create(clone3, tweenInfo2, {
		Size = createVector(106.70275, 106.70275, 106.70275),
		Transparency = 1
	}):Play()
	local clone4 = script.OrangePart:Clone()
	debris:AddItem(clone4, 1)
	clone4.Parent = _WorldOrigin
	clone4.Position = lastCF.Position
	TweenService:Create(clone4, tweenInfo2, {
		Size = createVector(91.64225, 91.64225, 91.64225),
		Transparency = 1
	}):Play()
	task.delay(0.7, function()
		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
end

local function projectile(cFrame, positionObject, timestamp, lifetime, distance)
	local clone = script.Sandrelease:Clone()
	Util.Debris:AddItem(clone, lifetime + 5)
	clone.Anchored = true
	clone.Parent = _WorldOrigin
	Util.Sound:Play("SandCast2", clone)
	local v = masterClock:GetTime() - timestamp
	local _ = cFrame.lookVector
	local value = false
	positionObject.Changed:Connect(function()
		value = positionObject.Value or nil
	end)
	local v2 = {
		t = tick(),
		life = lifetime,
		currentCFrame = cFrame,
		lastCF = cFrame,
		lastDist = 1,
		dt = 0.016666666666666666,
		hit = nil,
		pos = nil,
		norm = createVector(0, 1, 0)
	}

	while tick() - v2.t + v < v2.life do
		local _ = (tick() - v2.t + v) / v2.life
		local v3 = (tick() - v2.t + v) / 100 / (v2.life / 100)
		v2.lastCF = v2.currentCFrame
		v2.currentCFrame = cFrame:Lerp(cFrame * CFrame.new(0, 0, -distance), v3)
		clone.CFrame = v2.currentCFrame * CFrame.Angles(0, 0, 1.5707963267948966)
		v2.lastDist = (v2.lastCF.p - v2.currentCFrame.p).Magnitude
		local ray, pos, norm = Util.Ray(
			v2.lastCF.p,
			v2.lastCF.lookVector.Unit * v2.lastDist,
			{ workspace.Characters, workspace.Enemies },
			false
		)
		v2.hit = ray
		v2.pos = pos
		v2.norm = norm

		if value then
			clone.Position = positionObject.Value
			break
		end

		if v2.hit then
			break
		else
			v2.dt = RunService.RenderStepped:Wait()
		end
	end

	if clone then
		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.delay(1, function()
			clone:Destroy()
		end)
	end

	if not v2.norm or v2.norm == createVector(0, 0, 0) then
		v2.norm = createVector(0, 1, 0)
	end

	projectileExplosion(v2.lastCF, v2.hit, v2.norm)
end

return function(data)
	local subID = data.SubID or 1

	if subID ~= 1 then
		return
	end

	local cFrame = data.CFrame
	local positionObject = data.PositionObject
	local timestamp = data.Timestamp
	local distance = data.Distance
	local lifetime = data.Lifetime

	if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > 600 then
		return
	end

	projectile(cFrame, positionObject, timestamp, lifetime, distance)
end