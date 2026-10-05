local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local bazooka_X = FX:WaitForChild("Bazooka").Bazooka_X
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local rock2 = Util.Rock2

local function ParticleState(folder, enabled, p)
	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if p and emitter:GetAttribute("Color") == true then
			emitter.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
		end

		if enabled == nil then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		else
			emitter.Enabled = enabled
		end
	end
end

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

return function(data)
	local origin = data.origin
	local dir = data.dir

	if (currentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	if data.stage == 1 then
		local projectileSpeed = data.projectileSpeed
		local _ = data.maxRange
		local targetPos = data.targetPos
		local targetHrp = data.targetHrp
		local projectileCount = data.projectileCount
		local random = Random.new(data.randomSeed)
		local hrp = data.hrp
		local folder = Instance.new("Folder")
		folder.Name = "BazookaEffects"
		folder.Parent = _WorldOrigin
		local _ = CFrame.new(origin, origin + dir) * CFrame.new(0, 0, -5)
		local clone = bazooka_X.Start:Clone()
		clone.CFrame = hrp.CFrame * CFrame.new(0, 0, -4)
		clone.Parent = folder

		if data.player == game.Players.LocalPlayer then
			Util.CameraShaker:ShakeOnce(10, 15, 0.1, 0.3)
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		for i = 1, projectileCount do
			local v = i
			task.spawn(function()
				local vector2 = Vector3.new(targetPos[v][1], targetPos[v][2], targetPos[v][3])
				local position = hrp.Position
				local v2

				if targetHrp then
					v2 = targetHrp.Position or vector2
				else
					v2 = vector2
				end

				local cFrame = CFrame.lookAt(position, v2) * CFrame.new(0, 0, -4)
				TweenService:Create(clone.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
					Range = 0,
					Brightness = 0
				}):Play()
				local clone2 = bazooka_X.Missile:Clone()
				clone2.CFrame = cFrame
				clone2.Parent = folder

				if v == 1 then
					sound:Play("BF_WPN_Bazooka_Flaring_Missiles_Fire_01_V2", clone2.Position)
				end

				local v4

				if targetHrp and targetHrp[1] then
					if targetHrp[v] then
						vector2 = targetHrp[v].Position
						v4 = targetHrp[v]
					else
						vector2 = targetHrp[1].Position
						v4 = targetHrp[1]
					end
				end

				local magnitude = (vector2 - clone2.Position).Magnitude
				local v5 = math.clamp(magnitude / 350, 0.3333333333333333, 1)
				local cframe = CFrame.lookAt(cFrame.p, vector2)
				local position2 = clone2.Position
				local position3 = clone2.Position
				local v6 = position3 + (vector2 - position3) * 0.25 + cframe.UpVector * random:NextNumber(0, 90) * v5 + cframe.RightVector * random:NextNumber(
					-120,
					120
				) * v5
				local position4 = clone2.Position
				local v7 = position4 + (vector2 - position4) * 0.5 + cframe.UpVector * random:NextNumber(0, 30) * 1 + cframe.RightVector * random:NextNumber(
					-30,
					30
				) * 1
				local position5 = clone2.Position
				local v8 = position5 + (vector2 - position5) * 0.75 + cframe.UpVector * random:NextNumber(0, 30) + cframe.RightVector * random:NextNumber(
					-30,
					30
				)
				local position6 = clone2.Position
				local v9 = magnitude / projectileSpeed

				if data.duration and data.duration[1] then
					v9 = data.duration[v] and data.duration[v] or data.duration[1]
				end

				local lastTime = tick()

				while tick() - lastTime < v9 do
					local v10 = (tick() - lastTime) / v9

					if v4 then
						vector2 = v4.Position
					end

					local v11 = position2 + (v6 - position2) * v10
					local v12 = v6 + (v7 - v6) * v10
					local v13 = v7 + (v8 - v7) * v10
					local v14 = v8 + (vector2 - v8) * v10
					local v15 = v11 + (v12 - v11) * v10
					local v16 = v12 + (v13 - v12) * v10
					local v17 = v13 + (v14 - v13) * v10
					local v18 = v15 + (v16 - v15) * v10
					local v19 = v18 + (v16 + (v17 - v16) * v10 - v18) * v10

					if v10 ~= 0 then
						clone2.CFrame = CFrame.lookAt(v19, position6) * CFrame.Angles(0, 3.141592653589793, 0)
					end

					task.wait()
					position6 = v19
				end

				for i2, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				TweenService:Create(clone2.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
					Range = 0,
					Brightness = 0
				}):Play()
			end)
		end

		task.wait(5)
		folder:Destroy()
	else
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { workspace.Map }
		local folder = Instance.new("Folder")
		folder.Name = "BazookaEffects"
		folder.Parent = _WorldOrigin
		local clone = bazooka_X.Explode:Clone()
		clone.Position = origin
		clone.Parent = folder
		sound:Play("BF_WPN_Bazooka_Explosion_01", origin, nil, math.random(10, 12) / 10)

		if (workspace.CurrentCamera.CFrame.p - clone.CFrame.Position).Magnitude < 100 then
			if data.first then
				local clone2 = FX:WaitForChild("Musket").Musket_Z.ColorCorrection:Clone()
				clone2.Parent = game:GetService("Lighting")
				TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
					TintColor = Color3.new(1, 1, 1),
					Brightness = 0
				}):Play()
				task.delay(0.3, clone2.Destroy, clone2)
			end

			Util.CameraShaker:ShakeOnce(6, 4, 0.1, 0.6)
		end

		if data.floor then
			task.spawn(function()
				local v = math.random(3, 4)
				local v2 = data.floor.pos + createVector(0, 1, 0)

				for i = 1, v do
					local v3 = 360 / v * i
					local v4 = CFrame.new(v2, v2 + data.floor.nor * 2) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
						0,
						math.rad(v3),
						0
					) * CFrame.new(0, 0, -15)
					local ray, v5, v6 = Util.Ray(
						v4.Position,
						v4.upVector.Unit * -30,
						{ workspace.Characters, workspace.Enemies },
						false
					)

					if not ray then
						continue
					end

					local v7 = rock2.new({
						FadeIn = { 0.3, 0.6 },
						Lifetime = math.random(10, 20) / 10,
						FadeOut = { 0.4, 0.5 },
						Type = "Flying",
						Size = Vector3.new(math.random(2, 3), 2, math.random(2, 3)),
						Scale = { 1, 2 }
					})
					v7:Spawn(CFrame.new(v5, v5 + v6) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(0, 0, 0))
					v7:Eject({
						Velocity = v4.UpVector * (workspace.Gravity / 2 + math.random(-10, 20)) + v7.Part.CFrame.lookVector * math.random(
							10,
							20
						),
						RotVelocity = createVector(3.1415927, 3.1415927, 3.1415927)
					})
				end
			end)
			local clone2 = bazooka_X.FloorFire:Clone()
			clone2.CFrame = data.floor.CFrame
			clone2.Parent = folder
			task.delay(data.floor.Duration, function()
				local folder2 = clone2

				for _, emitter in pairs(folder2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				TweenService:Create(clone2.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
					Range = 0,
					Brightness = 0
				}):Play()
			end)
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		TweenService:Create(clone.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Range = 0,
			Brightness = 0
		}):Play()
		task.wait(5)
		folder:Destroy()
	end
end