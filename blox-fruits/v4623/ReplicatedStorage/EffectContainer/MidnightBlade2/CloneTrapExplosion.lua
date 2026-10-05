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

-- equivalent calls inferred from this helper; original call sites unknown
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
	local _ = hrp.CFrame
	local fireDir = data.fireDir
	local v = TweenService
	local cloneTrap = FX:WaitForChild("MidnightBlade").CloneTrap
	local victimDetected = data.victimDetected
	local duration = data.duration

	if (data.endPoint - currentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	local v2 = {
		TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true),
		TweenInfo.new(0.533333333, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		TweenInfo.new(0.325, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true),
		TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
	}
	local folder = _WorldOrigin:FindFirstChild("MIDNIGHTBLADE/CLONE_" .. data.EffectId)

	if not folder then
		return
	end

	local v3 = Util.MasterClock:GetTime() - data.ClockTime
	local v4 = math.max(0.01, duration - v3)
	local _ = v3 - (duration - v4)
	local part, v5, v6 = Workspace:FindPartOnRayWithIgnoreList(
		Ray.new(data.spherePosition, createVector(0, -10, 0)),
		raycastParams.FilterDescendantsInstances
	)
	local alignCFrame = Util.Misc.AlignCFrame(CFrame.new(createVector(0, 0, 0), fireDir) + data.spherePosition)

	if part then
		alignCFrame = Util.Misc.AlignCFrame(alignCFrame - alignCFrame.p + v5, v6) + v6 * 5
	end

	local effect = createEffect(alignCFrame, cloneTrap.Trap)
	effect.Name = "MIDNIGHTBLADE/PORTAL_" .. data.EffectId
	destroyAfter(effect, 7)
	local clone = cloneTrap.CC1:Clone()
	destroyAfter(clone, 0.2)

	if (Workspace.CurrentCamera.CFrame.Position - hrp.Position).Magnitude < 70 then
		clone.Parent = Lighting
	end

	destroyAfter(clone, 7)
	v:Create(clone, v2[4], {
		Saturation = 0,
		Brightness = 0,
		Contrast = 0
	}):Play()

	if part then
		local v7 = Util.Misc.AlignCFrame(CFrame.new(createVector(0, 0, 0), fireDir) + v5, v6) + v6 * 0.05

		for i = 1, 2 do
			local effect2 = createEffect(
				v7 * CFrame.new(17, i == 1 and 0 or 0.05, -3) * CFrame.Angles(0, 0.3490658503988659, 0),
				i == 1 and cloneTrap.GroundSlash or cloneTrap.Burn
			)
			destroyAfter(effect2, 2)

			if i == 1 then
				v:Create(effect2.tex, TweenInfo.new(2.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Color3 = Color3.new(0, 0, 0)
				}):Play()
				v:Create(effect2.tex, v2[5], {
					Transparency = 1
				}):Play()
			else
				local v8 = effect2
				task.delay(0.1, function()
					v:Create(v8.tex, v2[5], {
						Transparency = 1
					}):Play()
				end)
			end
		end

		for i = 1, 2 do
			local effect2 = createEffect(
				v7 * CFrame.new(17, 0, -3) * CFrame.Angles(-0.3490658503988659, 0.3490658503988659, -1.57),
				i == 1 and cloneTrap.ColorSlice or cloneTrap.BlackSlice
			)
			destroyAfter(effect2, 2)
			v:Create(effect2, v2[7], {
				Size = effect2.Size * 1.3,
				CFrame = effect2.CFrame * CFrame.new(0.5, 0, 0.5)
			}):Play()

			if i == 1 then
				v:Create(effect2.Top, v2[6], {
					Transparency = 1
				}):Play()
				v:Create(effect2.Bottom, v2[6], {
					Transparency = 1
				}):Play()
			else
				local v8 = effect2
				task.delay(0.1, function()
					v:Create(v8.Top, v2[7], {
						Transparency = 1
					}):Play()
					v:Create(v8.Bottom, v2[7], {
						Transparency = 1
					}):Play()
				end)
			end
		end

		folder.Handle.Aura1.Enabled = false
	else
		folder.Handle.Aura1.Enabled = false
	end

	folder.Handle.Body.Enabled = false
	folder.Handle.Tip.Enabled = false
	cameraShakeAt(data.endPoint, 70, 7, 7, 0.3, 0.4) -- equivalent call inferred; original call site unknown
	local midnightBladeZAttack = nil

	if victimDetected then
		if player == game.Players.LocalPlayer then
			midnightBladeZAttack = Util.Anims:Get(parent, "MidnightBladeZAttack")
			midnightBladeZAttack:Play(nil, nil, 1.5 / v4)
		end

		local ray2 = Util.Ray
		local endPoint2 = data.endPoint
		local v7 = { hrp.Parent }
		local v8, v9, lookDir = ray2(endPoint2, createVector(-0, -10, -0), v7)

		if v8 then
			Effect.new("Portal.CreatePortal"):replicate({
				origin = v9 + lookDir * 0.1,
				lookDir = lookDir,
				lastsFor = v4 / 2 + 0.3,
				chargeParticlesEnabled = true
			})
		end

		local v11 = CFrame.new(createVector(0, 0, 0), fireDir) + data.endPoint
		local effect2 = createEffect(v11 * CFrame.new(0, -3.2, 0), cloneTrap.Teleport)
		destroyAfter(effect2, 1.5)

		for _, emitter in ipairs(effect2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if emitter:GetAttribute("EmitDelay") then
				local v12 = emitter
				task.delay(emitter:GetAttribute("EmitDelay"), function()
					v12:Emit(v12:GetAttribute("EmitCount"))
				end)
			else
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		folder:Destroy()
		local cFrame = nil
		task.spawn(function()
			for _ = 1, 25 do
				local v12 = v11 * CFrame.new(math.random(-40, 40), math.random(0, 30), math.random(-80, -5))
				local effect3 = createEffect(v12, cloneTrap.CutStart)
				destroyAfter(effect3, 2)

				for _, child in ipairs(effect3.Attachment:GetChildren()) do
					if child:GetAttribute("EmitDelay") then
						local v13 = child
						task.delay(child:GetAttribute("EmitDelay"), function()
							v13:Emit(v13:GetAttribute("EmitCount"))
						end)
					else
						child:Emit(child:GetAttribute("EmitCount"))
					end
				end

				if cFrame then
					local effect4 = createEffect(cFrame, cloneTrap.TrailTeleport)
					destroyAfter(effect4, 1)
					v:Create(effect4, v2[9], {
						Position = effect3.Position
					}):Play()
				end

				if cFrame then
					local effect4 = createEffect(
						CFrame.new(cFrame.Position, v12.Position) * CFrame.new(
							0,
							0,
							-((v12.Position - cFrame.Position).Magnitude / 2)
						) * CFrame.Angles(
							math.rad((math.random(-180, 180))),
							math.rad((math.random(-180, 180))),
							(math.rad((math.random(-180, 180))))
						),
						cloneTrap.TrapSlash
					)
					destroyAfter(effect4, 1)

					for _, child in ipairs(effect4.Attachment:GetChildren()) do
						child:Emit(child:GetAttribute("EmitCount"))
					end

					cameraShakeAt(cFrame.Position, 70, 4, 7, 0.1, 0.3) -- equivalent call inferred; original call site unknown
				end

				cFrame = effect3.CFrame
				task.wait(0.05)
			end
		end)
		task.wait(v4)
	else
		destroyAfter(folder, 0.5)

		for _, descendant in ipairs(folder:GetDescendants()) do
			if descendant:IsA("Part") or descendant:IsA("Mesh") or descendant:IsA("MeshPart") or descendant:IsA("Decal") then
				v:Create(descendant, v2[10], {
					Transparency = 1
				}):Play()
			elseif descendant:IsA("Highlight") then
				v:Create(descendant, v2[10], {
					OutlineTransparency = 1
				}):Play()
			elseif descendant:IsA("ParticleEmitter") then
				descendant.Enabled = false
			end
		end
	end

	destroyAfter(effect, 2)

	for _, descendant in ipairs(effect:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant.Enabled = false
		elseif descendant:IsA("Beam") then
			Util.BoatTween:Create(descendant, {
				Time = 0.35,
				EasingStyle = "Sine",
				EasingDirection = "Out",
				StepType = "Heartbeat",
				Goal = {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(1, 1)
					})
				}
			}):Play()
		elseif descendant:IsA("PointLight") then
			v:Create(descendant, v2[8], {
				Brightness = 0
			}):Play()
		end
	end

	if victimDetected then
		task.wait(0.25)
	end

	if midnightBladeZAttack then
		midnightBladeZAttack:Stop()
	end

	local effect2 = createEffect(effect.CFrame, cloneTrap.Implode)
	destroyAfter(effect2, 1)

	for _, emitter in ipairs(effect2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.ZOffset += 5
		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end

	cameraShakeAt(data.endPoint, 100, 5, 7, 0.3, 0.3) -- equivalent call inferred; original call site unknown
end