local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local flyingTridentPull = FX:WaitForChild("SpikeyTrident").FlyingTridentPull
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt

local function putFolder(parent, name: string)
	local v = parent:FindFirstChild(name)

	if v == nil then
		v = Instance.new("Folder")
		v.Name = name
		v.Parent = parent
	end

	return v
end

local function putValueAsValueObject(parent, name: string, p, value: number)
	local v2 = {
		boolean = "BoolValue",
		CFrame = "CFrameValue",
		Color3 = "Color3Value",
		number = "NumberValue",
		Instance = "ObjectValue",
		Ray = "RayValue",
		string = "StringValue",
		Vector3 = "Vector3Value"
	}
	local instance = parent:FindFirstChild(name)

	if instance == nil then
		instance = Instance.new(v2[typeof(p)])
		instance.Name = name
		instance.Parent = parent
	end

	instance.Value = p
	destroyAfter(instance, value or 60)
end

local function getValueObject(instance, childName)
	return instance:FindFirstChild(childName)
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

-- equivalent calls inferred from this helper; original call sites unknown
local function snapProjectileToFinalPos(p, p2)
	p.CFrame = p.CFrame.Rotation + p2
end

local function fireClientProjectile(p, p2, instance, callback, part, p3)
	local fn = p3 == nil and function(_)
		return CFrame.new()
	end or p3

	if part == nil then
		part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Shape = Enum.PartType.Ball
		part.Size = Vector3.new(p2, p2, p2) * 2
		part.Transparency = 1
		part.Name = "Projectile"
		part.Parent = _WorldOrigin
		destroyAfter(part, p + 7)
	end

	part.CFrame = CFrame.lookAt(callback(0.001), callback(0.002)) * fn(0.001)
	local bindableEvent = Instance.new("BindableEvent")
	destroyAfter(bindableEvent, 7)
	local v = false
	local connection = nil
	connection = heartbeatLoopFor2(p, function(_, _, p4)
		if instance:GetAttribute("ProjectileActive") == true or instance:GetAttribute("ImpactPos") == nil or not (instance:GetAttribute("DisabledInterp") < 0.9999) then
			part.CFrame = CFrame.lookAt(callback(p4), callback(p4 + 0.01)) * fn(p4)
			return
		end

		connection:Disconnect()
		connection = nil
		snapProjectileToFinalPos(part, instance:GetAttribute("ImpactPos")) -- equivalent call inferred; original call site unknown
		bindableEvent:Fire(instance:GetAttribute("ImpactPos"), "Impact")
		v = true
	end, function()
		if v == true then
			return
		end

		snapProjectileToFinalPos(part, callback(1)) -- equivalent call inferred; original call site unknown
		bindableEvent:Fire(callback(1), "NonImpact")
	end)
	return bindableEvent, part, connection
end

local function cameraShakeAt(vector2: Vector3, value: number, value2: number, value3: number, value4: number, value5: number)
	local v = value2 or 8
	local v2 = value3 or 14
	local v3 = value4 or 0.2
	local v4 = value5 or 0.7

	if (value or 300) > (Workspace.CurrentCamera.CFrame.Position - vector2).Magnitude then
		Util.CameraShaker:ShakeOnce(v, v2, v3, v4)
	end
end

return function(data)
	local _ = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local parent = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 1400 then
		return
	end

	local _ = data.origin
	local _ = data.fireDir
	local v = flyingTridentPull
	local parent3 = _WorldOrigin
	local projectileSpeed = data.projectileSpeed
	local projectileDuration = data.projectileDuration

	local function easeOutSine(p: number)
		return 1 - math.pow(1 - p, 3)
	end

	local function DestroyProjectile(folder, p)
		if folder == nil or folder.Parent == nil then
			return
		end

		folder:SetAttribute("Active", true)

		if p then
			folder.WorldPivot = folder:GetPivot().Rotation + folder.Handle.Position
			folder:PivotTo(folder:GetPivot().Rotation + p)
		end

		for _, part in folder:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.Anchored = true
			part.Transparency = 1
		end

		local doughRope = folder:FindFirstChild("DoughRope")

		if doughRope then
			TweenService:Create(doughRope, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end

		destroyAfter(doughRope, 0.4)

		for _, emitter in folder:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("Beam") then
				TweenService:Create(descendant, TweenInfo.new(0.3), {
					Width0 = 0,
					CurveSize0 = 0
				}):Play()
			elseif descendant:IsA("BasePart") then
				TweenService:Create(descendant, TweenInfo.new(0.4), {
					Transparency = 1
				}):Play()
			end
		end

		destroyAfter(folder, 2)
	end

	local function Projectile(parent2, folder)
		local clone = v.DoughRope:Clone()
		clone.Attachment1 = parent2.RightHand.RightGripAttachment
		clone.Attachment0 = folder.Handle.DoughAttachment
		clone.Parent = folder
		destroyAfter(clone, 7)
		local width0 = folder.VFXHandle.Beam.Width0
		local curveSize0 = folder.VFXHandle.Beam.CurveSize0

		for _, effect in folder:GetDescendants() do
			if effect:IsA("Beam") then
				effect.Width0 = 0
				effect.CurveSize0 = 0
				TweenService:Create(effect, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Width0 = width0,
					CurveSize0 = curveSize0
				}):Play()
			elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = true
			end
		end

		coroutine.wrap(function()
			local v3 = time()

			for _ = 1, 600 do
				if folder.Handle.Transparency ~= 0 or time() - v3 > 10 then
					break
				end

				task.wait(0.15)
				local clone2 = v.ProjectileRing:Clone()
				clone2.CFrame = folder.Handle.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 6.283185307179586, 0)
				clone2.Parent = parent3
				TweenService:Create(clone2, TweenInfo.new(0.34, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Size = createVector(22, 0, 22)
				}):Play()
				TweenService:Create(clone2, TweenInfo.new(0.34), {
					Transparency = 1
				}):Play()
				task.delay(0.34, function()
					clone2:Destroy()
				end)
			end
		end)
	end

	local EffectHandler

	EffectHandler = function(list)
		if list[2] == "Windup" then
			return
		end

		if list[2] == "Shoot" then
			local dir = data.dir
			Util.Sound:Play("DoughPunch3", hrp, 10, 1.3)
			Util.Sound:Play("DoughSmallWhoosh", hrp, 10)
			local raycastResult = Workspace:Raycast(dir.p, createVector(-0, -10, -0), raycastParams)
			local clone = v.Throw:Clone()
			local swirl = clone.Swirl
			local swirl2 = clone.Swirl2
			local ring1Fat = clone.Ring1Fat
			local ring2Fat = clone.Ring2Fat
			local ring1 = clone.Ring1
			local tornado = clone.Tornado
			local waveLeft = clone.WaveLeft
			local waveRight = clone.WaveRight
			local wind = clone.Wind
			local stab = clone.Stab
			clone.Parent = parent3
			local clone2 = v.Burst:Clone()
			clone2.CFrame = dir * CFrame.new(0, 0, -5)
			clone2.Parent = parent3

			for _, emitter in clone2:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			task.delay(2, function()
				clone2:Destroy()
			end)
			tornado.CFrame = dir * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.new(0, 5, 0)
			TweenService:Create(tornado, TweenInfo.new(0.2), {
				Transparency = 1,
				CFrame = tornado.CFrame * CFrame.new(0, -9, 0) * CFrame.Angles(0, 2.9670597283903604, 0),
				Size = createVector(9, 7, 9)
			}):Play()
			swirl.CFrame = dir * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.new(0, 5, 0)
			TweenService:Create(swirl, TweenInfo.new(0.31, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Transparency = 1,
				CFrame = swirl.CFrame * CFrame.new(0, -6, 0) * CFrame.Angles(0, 2.9670597283903604, 0),
				Size = createVector(6, 9, 6)
			}):Play()
			ring1Fat.CFrame = dir * CFrame.new(0, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
			TweenService:Create(ring1Fat, TweenInfo.new(0.32, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				CFrame = ring1Fat.CFrame * CFrame.new(0, -7, 0),
				Size = createVector(12, 0, 12)
			}):Play()
			TweenService:Create(ring1Fat, TweenInfo.new(0.34), {
				Transparency = 1
			}):Play()
			swirl2.CFrame = dir * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.new(0, 5, 0)
			TweenService:Create(swirl2, TweenInfo.new(0.38, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Transparency = 1,
				CFrame = swirl.CFrame * CFrame.new(0, -4, 0) * CFrame.Angles(0, -1.4835298641951802, 0),
				Size = createVector(10, 5, 10)
			}):Play()
			ring1.CFrame = dir * CFrame.new(0, 0, -10) * CFrame.Angles(1.5707963267948966, 0, 0)
			TweenService:Create(ring1, TweenInfo.new(0.33, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				CFrame = ring1.CFrame * CFrame.new(0, 13, 0),
				Size = createVector(17, 0, 17)
			}):Play()
			TweenService:Create(ring1, TweenInfo.new(0.33), {
				Transparency = 1
			}):Play()
			ring2Fat.CFrame = dir * CFrame.new(0, 0, -6) * CFrame.Angles(1.5707963267948966, 0, 0)
			TweenService:Create(ring2Fat, TweenInfo.new(0.37, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				CFrame = ring2Fat.CFrame * CFrame.new(0, 19, 0),
				Size = createVector(20, 0, 20)
			}):Play()
			TweenService:Create(ring2Fat, TweenInfo.new(0.38), {
				Transparency = 1
			}):Play()
			wind.CFrame = dir * CFrame.new(0, 0, -4) * CFrame.Angles(1.5707963267948966, 0, 0)
			TweenService:Create(wind, TweenInfo.new(0.24, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				CFrame = wind.CFrame * CFrame.new(0, -10, 0) * CFrame.Angles(0, -1.4835298641951802, 0),
				Size = createVector(0, 7, 0)
			}):Play()
			TweenService:Create(wind, TweenInfo.new(0.24), {
				Transparency = 1
			}):Play()
			stab.CFrame = dir * CFrame.new(0, 0, 12) * CFrame.Angles(0, -1.5707963267948966, 0)
			TweenService:Create(stab, TweenInfo.new(0.29, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				CFrame = stab.CFrame * CFrame.new(-26, 0, 0)
			}):Play()
			TweenService:Create(stab.Mesh, TweenInfo.new(0.29, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Scale = createVector(0.5, 0, 0)
			}):Play()
			TweenService:Create(stab.Decal, TweenInfo.new(0.29, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()

			if raycastResult then
				local cFrame = Util.Misc.AlignCFrame(
					CFrame.new(createVector(0, 0, 0), dir.LookVector) + raycastResult.Position,
					raycastResult.Normal
				) + raycastResult.Normal * 0.5
				local clone3 = v.Burst2:Clone()
				clone3.CFrame = cFrame
				clone3.Parent = parent3

				for _, emitter in clone3:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				task.delay(2, function()
					clone3:Destroy()
				end)
				waveLeft.CFrame = cFrame * CFrame.new(-2, 3, -15) * CFrame.Angles(0, 1.3788101090755203, 0)
				waveRight.CFrame = cFrame * CFrame.new(2, 3, -15) * CFrame.Angles(0, 1.7627825445142729, 0)
				waveLeft.Orientation *= createVector(0, 1, 0)
				waveRight.Orientation *= createVector(0, 1, 0)
				TweenService:Create(waveLeft, TweenInfo.new(0.27, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Transparency = 1,
					CFrame = waveLeft.CFrame * CFrame.new(-24, -3, 0),
					Size = createVector(35, 6, 0.1)
				}):Play()
				TweenService:Create(waveRight, TweenInfo.new(0.27, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Transparency = 1,
					CFrame = waveRight.CFrame * CFrame.new(-24, -3, 0),
					Size = createVector(35, 6, 0.1)
				}):Play()
			else
				waveLeft:Destroy()
				waveRight:Destroy()
			end

			task.delay(0.5, function()
				clone:Destroy()
			end)
			coroutine.wrap(function()
				local clone3 = v.DashMesh1:Clone()
				local clone4 = v.DashMesh2:Clone()
				local scale = clone3.Mesh.Scale
				local scale2 = clone4.Mesh.Scale
				clone3.Mesh.Scale = createVector(0, 0, 0)
				clone4.Mesh.Scale = createVector(2, 0, 0)
				clone3.CFrame = dir * CFrame.Angles(1.5707963267948966, 0, 1.5707963267948966) * CFrame.new(-7, 0, 0)
				clone4.CFrame = dir * CFrame.Angles(1.5707963267948966, 0, 1.5707963267948966) * CFrame.new(-7, 0, 0)
				clone3.Parent = parent3
				clone4.Parent = parent3
				task.wait(0.03)
				TweenService:Create(
					clone3.Mesh,
					TweenInfo.new(0.34, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						Scale = scale
					}
				):Play()
				TweenService:Create(
					clone4.Mesh,
					TweenInfo.new(0.23, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						Scale = scale2
					}
				):Play()
				TweenService:Create(clone3, TweenInfo.new(0.34, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					CFrame = clone3.CFrame * CFrame.new(20, 0, 0)
				}):Play()
				TweenService:Create(clone4, TweenInfo.new(0.23, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					CFrame = clone4.CFrame * CFrame.new(14, 0, 0)
				}):Play()
				TweenService:Create(
					clone3.Decal,
					TweenInfo.new(0.34, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
				TweenService:Create(
					clone4.Decal,
					TweenInfo.new(0.23, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
				task.wait(0.4)
				clone3:Destroy()
				clone4:Destroy()
			end)()
			Projectile(hrp.Parent, list[3])
		elseif list[2] == "DestroyProjectile" then
			DestroyProjectile(list[3], list[4])
		elseif list[1] == "Hit" then
			local clone = v.HitFX:Clone()
			clone.CFrame = CFrame.new(list[2])
			clone.Parent = parent3

			for _, emitter in clone:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local ScaleParticle = require(game.ReplicatedStorage.Util.ScaleParticle)
				ScaleParticle({
					Emitter = emitter,
					Scale = 2.5,
					Time = 0
				})
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end

			TweenService:Create(
				clone.Attachment.PointLight,
				TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Brightness = 6
				}
			):Play()
			task.spawn(EffectHandler, {
				parent,
				"DestroyProjectile",
				list[3],
				clone.CFrame.Position
			})
			task.wait(0.2)
			TweenService:Create(clone.Attachment.PointLight, TweenInfo.new(0.19), {
				Brightness = 0
			}):Play()
			task.wait(3)
			clone:Destroy()
		end
	end

	os.clock()
	local parent2 = hrp.Parent
	task.spawn(EffectHandler, { parent2, "Windup" })
	local clone = v.Projectile:Clone()
	local dir = data.dir
	clone.Handle:PivotTo(dir * CFrame.Angles(-1.5707963267948966, 0, 0))
	clone.Parent = _WorldOrigin
	destroyAfter(clone, 7)
	local lookVector = dir.LookVector
	local now = os.clock()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if clone and clone:GetAttribute("Active") == nil then
			clone:PivotTo(clone:GetPivot() + lookVector * dt * projectileSpeed)
			Effect.new("Dough.Misc.Drip.Generic"):replicate({
				Type = "Trajectory",
				CFrame = Util.Misc.SpreadAngleFromCFrame(clone.Handle.CFrame, Vector2.new(180, 180)),
				Scale = random:NextNumber(1.5, 3.5),
				DropLifetime = random:NextNumber(0.5, 2),
				Velocity = (-hrp.CFrame.LookVector + createVector(0, 0.5, 0)) * random:NextNumber(7.5, 35),
				Gravity = Random.new():NextNumber(0.3, 1)
			})
		end

		local now2 = os.clock()

		if not (now + projectileDuration <= now2) then
			return
		end

		heartbeatConnection:Disconnect()
		task.spawn(EffectHandler, { parent2, "DestroyProjectile", clone })
		task.wait(1.5)

		if clone then
			clone:Destroy()
		end
	end)
	task.spawn(EffectHandler, { parent2, "Shoot", clone })
	local serverProjectile = data.serverProjectile
	local v3 = time()

	for _ = 1, 600 do
		task.wait()

		if serverProjectile == nil or serverProjectile.Anchored == true or serverProjectile:FindFirstChildOfClass("Weld") or projectileDuration < time() - v3 then
			break
		end
	end

	if serverProjectile then
		if serverProjectile.Anchored == false then
			local weld = serverProjectile:FindFirstChildOfClass("Weld")

			if weld and weld.Part1 ~= nil and weld.Part1.Parent ~= nil then
				local _ = weld.Part1.Parent
				task.spawn(EffectHandler, { "Hit", data.impactPos.Value, clone })
			end
		else
			local value = data.impactPos.Value
			local unit = (value - hrp.Position).Unit
			local raycastResult = Workspace:Raycast(value - unit * 10, unit * 10, raycastParams)

			if raycastResult then
				value = raycastResult.Position
			end

			task.spawn(EffectHandler, { "Hit", value, clone })
		end
	end
end