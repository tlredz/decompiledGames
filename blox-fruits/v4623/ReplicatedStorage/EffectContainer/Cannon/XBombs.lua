local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local cannon_X = FX:WaitForChild("Cannon").Cannon_X
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

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
return function(data)
	local origin = data.origin

	if (currentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	if data.stage == 1 then
		local stateProxy = data.stateProxy

		if not stateProxy then
			return
		end

		local _ = data.maxRange
		local projectileSpeed = data.projectileSpeed
		local folder = Instance.new("Folder")
		folder.Name = "CannonBombEffect"
		folder.Parent = _WorldOrigin
		local startCFrame = data.startCFrame

		if data.i == 1 and data.player == game.Players.LocalPlayer then
			task.spawn(function()
				for _ = 1, 3 do
					Util.CameraShaker:ShakeOnce(8, 12, 0.1, 0.25)
					task.wait(0.05)
				end
			end)
		end

		local clone = cannon_X.Start:Clone()
		clone.CFrame = startCFrame
		clone.Parent = folder

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		if data.i == 1 then
			sound:Play("BF_WPN_Cannon_IncendiaryAmmoFire_01_V2", startCFrame.Position)
		end

		TweenService:Create(clone.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Range = 0,
			Brightness = 0
		}):Play()
		local targetPosition = data.targetPosition
		local clone2 = cannon_X.Ball:Clone()
		clone2.CFrame = startCFrame
		clone2.Parent = folder
		local position = clone2.Position
		local position2 = nil
		local vector2 = Vector3.new(0, -workspace.Gravity, 0)
		local position3 = startCFrame.Position
		local v = (targetPosition - position3 - vector2 * 0.5) * projectileSpeed
		local v2 = nil
		local lastTime = os.clock()
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(_)
			if os.clock() - lastTime >= data.maxDuration or stateProxy:GetAttribute("Destroyed") then
				heartbeatConnection:Disconnect()

				if stateProxy:GetAttribute("Destroyed") then
					clone2.CFrame = CFrame.new(stateProxy:GetAttribute("Destroyed"))
				end

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
				clone2.Transparency = 1
			else
				v2 = os.clock() - lastTime
				position2 = CFrame.new(vector2 * 0.5 * projectileSpeed ^ 2 * v2 ^ 2 + v * v2 + position3).Position
				clone2.CFrame = CFrame.lookAt(position2, position) * CFrame.Angles(0, 3.141592653589793, 0)
				position = position2
			end
		end)
		task.wait(data.maxDuration + 3)

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
		end

		folder:Destroy()
	elseif data.stage == 2 then
		local folder = Instance.new("Folder")
		folder.Name = "CannonExplosionEffect"
		folder.Parent = _WorldOrigin
		local clone = cannon_X.Explode:Clone()
		clone.CFrame = data.hitCFrame
		clone.Parent = folder

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		if data.i == 1 then
			sound:Play("BF_WPN_Cannon_IncendiaryAmmoExplosion_01_V2", clone.Position)
		end

		task.spawn(function()
			local v = math.random(5, 8)
			local v2 = data.origin + createVector(0, 1, 0)

			for i = 1, v do
				local v3 = 360 / v * i
				local v4 = CFrame.new(v2, v2 + data.nor * 2) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
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
		TweenService:Create(clone.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Range = 0,
			Brightness = 0
		}):Play()

		if (workspace.CurrentCamera.CFrame.p - clone.CFrame.Position).Magnitude < 100 then
			Util.CameraShaker:ShakeOnce(8, 6, 0.1, 0.5)
		end

		if data.floorfire then
			local clone2 = cannon_X.FloorFire:Clone()
			clone2.CFrame = clone.CFrame
			clone2.Parent = folder
			task.delay(data.floorTime, function()
				TweenService:Create(clone2.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
					Range = 0,
					Brightness = 0
				}):Play()
				local folder2 = clone2

				for _, emitter in pairs(folder2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
		end

		task.wait(5)
		folder:Destroy()
	end
end