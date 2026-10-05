local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
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

local function safeSetRootCFrame(instance, cFrame: CFrame, flag: boolean)
	local v = flag == nil or flag

	if instance == nil then
		return
	end

	local bodyPosition = instance:FindFirstChildOfClass("BodyPosition")

	if bodyPosition and bodyPosition.MaxForce.Magnitude > 1000 or instance.Anchored == true then
		return
	end

	if not v then
		instance.CFrame = cFrame
		return
	end

	local raycastResult = Workspace:Raycast(instance.Position, cFrame.Position - instance.Position, raycastParams)

	if raycastResult then
		instance.CFrame = instance.CFrame.Rotation + raycastResult.Position - (cFrame.Position - instance.Position).Unit * 0.2
	else
		instance.CFrame = cFrame
	end
end

local function snapProjectileToFinalPos(folder, p)
	folder.CFrame = folder.CFrame.Rotation + p

	for _, effect in ipairs(folder:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = false
		end
	end

	folder.Transparency = 1
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
		if instance:GetAttribute("ProjectileActive") == true then
			part.CFrame = CFrame.lookAt(callback(p4), callback(p4 + 0.01)) * fn(p4)
			return
		end

		connection:Disconnect()
		connection = nil
		snapProjectileToFinalPos(part, instance:GetAttribute("ImpactPos"))
		bindableEvent:Fire(instance:GetAttribute("ImpactPos"), "Impact")
		v = true
	end, function()
		if v == true then
			return
		end

		snapProjectileToFinalPos(part, callback(1))
		bindableEvent:Fire(callback(1), "NonImpact")
	end)
	return bindableEvent, part, connection
end

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local function createEffect(cFrame, model, p, p2)
	local clone = model:Clone()
	clone.Name = p or clone.Name

	if model:IsA("Model") then
		clone.PrimaryPart.CFrame = cFrame
	else
		clone.CFrame = cFrame
	end

	clone.Parent = p2 or _WorldOrigin
	destroyAfter(clone, 7)
	return clone
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

local function adjustDuration(p, p2)
	local v = math.max(0.01, p - p2)
	return v, p2 - (p - v)
end

return function(data)
	local player = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local parent = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	local _ = data.origin
	local fireDir = data.fireDir
	local v = TweenService
	local crescentDash = FX:WaitForChild("MidnightBlade").CrescentDash
	local v2 = CFrame.lookAt(createVector(0, 0, 0), fireDir) + data.dragStartPoint
	local _ = hrp.Position
	local _ = v2.Position
	local scaleParticle = Util.ScaleParticle
	local parent2 = _WorldOrigin
	local v4 = math.max(0, Util.MasterClock:GetTime() - data.ClockTime)
	local fadeIn = data.fadeIn or 0.2
	local dashTime = data.dashTime or 0.35
	local v5 = math.max(0.01, fadeIn - v4)
	local _ = v4 - (fadeIn - v5)
	local v7 = math.max(0.01, dashTime - v4)
	local _ = v4 - (dashTime - v7)
	local magnitude = (data.dragEndPoint - data.dragStartPoint).Magnitude
	local v9 = {
		TweenInfo.new(data.victimRoot and 0.7 or 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true),
		TweenInfo.new(0.533333333, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
	}

	local function createEffect2(cFrame, model, p, p2)
		local clone = model:Clone()
		clone.Name = p or clone.Name

		if model:IsA("Model") then
			clone.Parent = p2 or parent2
			destroyAfter(clone, 7)
			clone.PrimaryPart.CFrame = cFrame
		else
			clone.CFrame = cFrame
			clone.Parent = p2 or parent2
			destroyAfter(clone, 7)
		end

		return clone
	end

	local effect = createEffect2(v2 * CFrame.new(0, -3.2, 0), crescentDash.Teleport)
	destroyAfter(effect, 1.5)

	for _, emitter in ipairs(effect:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if emitter:GetAttribute("EmitDelay") then
			local v10 = emitter
			task.delay(emitter:GetAttribute("EmitDelay"), function()
				v10:Emit(v10:GetAttribute("EmitCount"))
			end)
		else
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	Effect.new("Portal.CreatePortal"):replicate({
		origin = data.origin,
		lookDir = v2.LookVector,
		lastsFor = 0.75,
		chargeParticlesEnabled = true
	})
	local rengokuZ

	if player == game.Players.LocalPlayer then
		rengokuZ = Util.Anims:Get(parent, "RengokuZ")
		rengokuZ:Play(nil, nil, 1)
	end

	task.wait(v5)
	local effect2 = createEffect2(v2, crescentDash.Forward)
	destroyAfter(effect2, 1)
	effect2.Weld.Part0 = hrp
	local trail1 = effect2.Trail1
	local trail2 = effect2.Trail2
	trail1.Burn.Enabled = false
	trail1.Parent = Workspace.Terrain
	trail2.Parent = Workspace.Terrain
	local v10 = trail1.Position - trail2.Position
	local flag = true
	task.spawn(function()
		local lastTime = tick()

		while flag do
			local v11 = tick() - lastTime
			local part, v12, v13 = Workspace:FindPartOnRayWithIgnoreList(
				Ray.new(hrp.Position, createVector(0, -10, 0)),
				raycastParams.FilterDescendantsInstances
			)

			if part then
				local v14 = Util.Misc.AlignCFrame(CFrame.new(createVector(0, 0, 0), fireDir) + v12, v13) + v13 * 0.05
				trail1.WorldCFrame = v14 * CFrame.new(-v10)
				trail2.WorldCFrame = v14 * CFrame.new(v10)
			end

			trail1.Burn.Enabled = part and true or false

			if v11 > 2 then
				break
			else
				task.wait(0.016666666666666666)
			end
		end

		destroyAfter(trail1, trail1.Burn.Lifetime)
		destroyAfter(trail2, trail1.Burn.Lifetime)
	end)

	for _, emitter in ipairs(effect2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Rate *= 5
		end
	end

	Effect.new("Portal.CreatePortal"):replicate({
		origin = v2.p,
		lookDir = v2.LookVector,
		lastsFor = 0.75,
		chargeParticlesEnabled = false
	})
	local v11 = {
		"rbxassetid://12558376366",
		"rbxassetid://12558376101",
		"rbxassetid://12558375916",
		"rbxassetid://12558375736",
		"rbxassetid://12558375599",
		"rbxassetid://12558375321",
		"rbxassetid://12558375128",
		"rbxassetid://12558374890",
		"rbxassetid://12558374679"
	}
	task.spawn(function()
		for _ = 1, 6 do
			local effect3 = createEffect2(
				hrp.CFrame * CFrame.Angles(0, 0, (math.rad((math.random(-360, 360))))),
				crescentDash.spiral
			)
			v:Create(effect3.Mesh, TweenInfo.new(0.25 * v5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = createVector(0.09, 0.09, 0.011)
			}):Play()
			v:Create(effect3.Decal, TweenInfo.new(0.25 * v5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 0.1
			}):Play()
			task.spawn(function()
				for i = 1, #v11 do
					local decal = effect3:FindFirstChild("Decal")
					decal.Texture = v11[i]
					task.wait(0.016666666666666666)
				end

				effect3:Destroy()
			end)
			task.wait(0.1 * v7)
		end
	end)
	task.wait(0.2 * v7)
	effect2.SpotLight.Enabled = true
	local effect3 = createEffect2(v2 * CFrame.new(0, 0, 8) * CFrame.Angles(0, 4.71, 0), crescentDash.TexturedShockwave1)
	v:Create(effect3, TweenInfo.new(0.45 * v7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = effect3.CFrame * CFrame.new(-magnitude, 0, 0) * CFrame.Angles(-3.141592653589793, 0, 0)
	}):Play()
	v:Create(effect3.Mesh, TweenInfo.new(0.45 * v7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0), {
		Scale = createVector(1, 0.3, 0.3)
	}):Play()
	v:Create(effect3.Texture, TweenInfo.new(0.75 * v7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	destroyAfter(effect3, 0.2)
	local effect4 = createEffect2(v2 * CFrame.new(0, 0, 8) * CFrame.Angles(0, 4.71, 0), crescentDash.TexturedShockwave2)
	v:Create(effect4, TweenInfo.new(0.45 * v7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = effect4.CFrame * CFrame.new(-magnitude, 0, 0)
	}):Play()
	v:Create(effect4.Mesh, TweenInfo.new(0.3 * v7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Scale = createVector(1, 0.25, 0.25)
	}):Play()
	v:Create(effect4.Texture, TweenInfo.new(0.75 * v7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	destroyAfter(effect4, 0.2)
	task.wait(0.5 * v7)

	for _, descendant in ipairs(effect2:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant.Enabled = false
		elseif descendant:IsA("SpotLight") then
			v:Create(descendant, TweenInfo.new(v7 * 0.75, Enum.EasingStyle.Sine), {
				Brightness = 0,
				Range = 0
			}):Play()
		end
	end

	task.wait(0.3 * v7)
	flag = false
	local part, v12, v13 = Workspace:FindPartOnRayWithIgnoreList(
		Ray.new(hrp.Position, createVector(0, -5, 0)),
		raycastParams.FilterDescendantsInstances
	)
	local v14 = CFrame.new(createVector(0, 0, 0), fireDir) + data.dragEndPoint
	local effect5 = createEffect2(v14 * CFrame.Angles(0, 1.57, 0), crescentDash.Slash)
	destroyAfter(effect5, 2)
	local position = v14.Position
	local v15 = 8
	local v16 = 14
	local v17 = 0.2
	local v18 = 0.7

	if (70 or 300) > (Workspace.CurrentCamera.CFrame.Position - position).Magnitude then
		Util.CameraShaker:ShakeOnce(v15, v16, v17, v18)
	end

	for _, emitter in ipairs(effect5:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local lifetime = emitter.Lifetime
		emitter.Lifetime = NumberRange.new(lifetime.Min * 1.25, lifetime.Max * 1.25)
		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end

	if part then
		local effect6 = createEffect2(
			Util.Misc.AlignCFrame(CFrame.new(createVector(0, 0, 0), fireDir) + v12, v13) + v13 * 0.05,
			crescentDash.Dust
		)
		destroyAfter(effect6, 1.5)

		for _, emitter in ipairs(effect6:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local lifetime = emitter.Lifetime
			emitter.Lifetime = NumberRange.new(lifetime.Min * 2, lifetime.Max * 2)
			scaleParticle({
				Emitter = emitter,
				Scale = 1,
				Time = 0.05,
				EasingStyle = Enum.EasingStyle.Linear,
				EasingDirection = Enum.EasingDirection.Out
			})
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	local v19 = v14 * CFrame.new(0, 0, -10)
	local part2, v20, _ = Workspace:FindPartOnRayWithIgnoreList(
		Ray.new(v14.p, (v19.p - v14.p) * 1.01),
		raycastParams.FilterDescendantsInstances
	)

	if part2 then
		v19 = CFrame.new(createVector(0, 0, 0), v19.LookVector) + v20 - v19.LookVector * 2
	end

	local effect6 = createEffect2(
		v19 * CFrame.new(-5, -3, 0) * CFrame.new(0, 5, 0) * CFrame.Angles(0, 0, 0.17453292519943295),
		crescentDash.Start
	)
	destroyAfter(effect6, 4)

	for _, emitter in ipairs(effect6:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	task.wait(0.1)

	if (Workspace.CurrentCamera.CFrame.Position - v19.p).Magnitude < 70 then
		local clone = crescentDash.Blur:Clone()
		clone.Parent = Lighting
		destroyAfter(clone, 7)
		v:Create(clone, v9[1], {
			Size = 13
		}):Play()
		destroyAfter(clone, 1)
	end

	local effect7 = createEffect2(
		v19 * CFrame.new(0, -3, 0) * CFrame.new(0, 5, 0) * CFrame.Angles(0, 0, 0.17453292519943295),
		crescentDash.Start2
	)
	destroyAfter(effect7, 4)

	for _, emitter in ipairs(effect7:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	local effect8 = createEffect2(v19 * CFrame.new(0, -3, 0) * CFrame.new(0, 5, 0), crescentDash.Impact)
	destroyAfter(effect8, 4)

	for _, emitter in ipairs(effect8:GetDescendants()) do
		if not (emitter:IsA("ParticleEmitter") and emitter.Parent ~= effect8.Attachment4) then
			continue
		end

		if emitter:GetAttribute("EmitDelay") == 0 then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		else
			local v21 = emitter
			task.delay(emitter:GetAttribute("EmitDelay"), function()
				v21:Emit(v21:GetAttribute("EmitCount"))
			end)
		end
	end

	local clone

	if (Workspace.CurrentCamera.CFrame.Position - v19.p).Magnitude < 70 then
		clone = crescentDash["Black&White"]:Clone()
		clone.Parent = Lighting
		destroyAfter(clone, 7)
	end

	local v21 = v19 * CFrame.new(0, -3, 0) * CFrame.new(0, 5, 0)
	local part3, v22, v23 = Workspace:FindPartOnRayWithIgnoreList(
		Ray.new(v19.p, (v21 * createVector(0, 0, -5) - v19.p) * 1.01),
		raycastParams.FilterDescendantsInstances
	)

	if part3 then
		v21 = Util.Misc.AlignCFrame(CFrame.new(createVector(0, 0, 0), v21.LookVector) + v22, v23) * CFrame.Angles(
			1.5707963267948966,
			0,
			0
		) + v23
	end

	local effect9 = createEffect2(v21, crescentDash.Main)
	destroyAfter(effect9, 4)
	local effect10 = createEffect2(effect8.CFrame, crescentDash.Explosion)
	destroyAfter(effect10, 4)

	if clone then
		clone:Destroy()
	end

	local foundVictim = data.victimDetectedBool:GetAttribute("FoundVictim")

	if rengokuZ then
		rengokuZ:Stop()
	end

	if player == game.Players.LocalPlayer then
		if foundVictim then
			Util.Anims:Get(parent, "MidnightBladeXAttack"):Play(nil, nil, 1.65 / ((data.attackHoldTime or 1) + 0.25))
		else
			Util.Anims:Get(parent, "MidnightBladeXMiss"):Play(nil, nil, 8)
		end
	end

	if foundVictim then
		local attackHoldTime = data.attackHoldTime or 0
		local v24 = math.max(0.01, attackHoldTime - v4)
		local _ = v4 - (attackHoldTime - v24)
		task.wait(v24)
	end

	for _, emitter in ipairs(effect9:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	if not foundVictim then
		return
	end

	for _, emitter in ipairs(effect8:GetDescendants()) do
		if not (emitter:IsA("ParticleEmitter") and emitter.Parent ~= effect8.Attachment3) then
			continue
		end

		if emitter:GetAttribute("EmitDelay") == 0 then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		else
			local v24 = emitter
			task.delay(emitter:GetAttribute("EmitDelay"), function()
				v24:Emit(v24:GetAttribute("EmitCount"))
			end)
		end
	end

	for _, emitter in ipairs(effect10:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.ZOffset /= 4
		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end

	local position2 = v14.Position
	local v24 = 8
	local v25 = 14
	local v26 = 0.2
	local v27 = 0.7

	if (100 or 300) > (Workspace.CurrentCamera.CFrame.Position - position2).Magnitude then
		Util.CameraShaker:ShakeOnce(v24, v25, v26, v27)
	end

	local effect11 = createEffect2(v14 * CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0), crescentDash.SlashBig)
	effect11.Attachment.Orientation = createVector(0, -180, -15)
	effect11.Wind.Orientation = createVector(0, -180, -15)

	for _, emitter in ipairs(effect11:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local lifetime = emitter.Lifetime
		emitter.Lifetime = NumberRange.new(lifetime.Min * 1.25, lifetime.Max * 1.25)

		if emitter.Parent.Name == "Slash" then
			continue
		end

		if emitter.Parent.Name == "Wind" then
			local lifetime2 = emitter.Lifetime
			emitter.Lifetime = NumberRange.new(lifetime2.Min * 1.25, lifetime2.Max * 1.25)
		end

		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end

	if part then
		local effect12 = createEffect2(
			Util.Misc.AlignCFrame(CFrame.new(createVector(0, 0, 0), fireDir) + v12, v13) + v13 * 0.05,
			crescentDash.Dust
		)
		destroyAfter(effect12, 1.5)

		for _, emitter in ipairs(effect12:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local lifetime = emitter.Lifetime
			emitter.Lifetime = NumberRange.new(lifetime.Min * 2.25, lifetime.Max * 2.25)
			scaleParticle({
				Emitter = emitter,
				Scale = 1.6,
				Time = 0.05,
				EasingStyle = Enum.EasingStyle.Linear,
				EasingDirection = Enum.EasingDirection.Out
			})
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	task.wait(0.05)

	if effect11 then
		for _, child in ipairs(effect11.Slash:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end
	end

	if part then
		local v28 = Util.Misc.AlignCFrame(CFrame.new(createVector(0, 0, 0), fireDir) + v12, v13) + v13 * 0.05

		for i = 1, 2 do
			local effect12 = createEffect2(
				v28 * CFrame.new(-15, i == 1 and 0 or -0.025, -2) * CFrame.Angles(0, -0.17453292519943295, 0),
				i == 1 and crescentDash.GroundSlash or crescentDash.Burn
			)
			destroyAfter(effect12, 2)

			if i == 1 then
				v:Create(effect12.tex, TweenInfo.new(2.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Color3 = Color3.new(0, 0, 0)
				}):Play()
				v:Create(effect12.tex, v9[3], {
					Transparency = 1
				}):Play()
			else
				local v29 = effect12
				task.delay(0.1, function()
					v:Create(v29.tex, v9[3], {
						Transparency = 1
					}):Play()
				end)
			end
		end

		for i = 1, 2 do
			local effect12 = createEffect2(
				v28 * CFrame.new(-15, 0, -2) * CFrame.Angles(-0.3490658503988659, -0.17453292519943295, -1.57),
				i == 1 and crescentDash.ColorSlice or crescentDash.BlackSlice
			)
			destroyAfter(effect12, 2)
			v:Create(effect12, v9[5], {
				Size = effect12.Size * 1.3,
				CFrame = effect12.CFrame * CFrame.new(0.5, 0, 0.5)
			}):Play()

			if i == 1 then
				v:Create(effect12.Top, v9[4], {
					Transparency = 1
				}):Play()
				v:Create(effect12.Bottom, v9[4], {
					Transparency = 1
				}):Play()
			else
				local v29 = effect12
				task.delay(0.1, function()
					v:Create(v29.Top, v9[5], {
						Transparency = 1
					}):Play()
					v:Create(v29.Bottom, v9[5], {
						Transparency = 1
					}):Play()
				end)
			end
		end
	end
end