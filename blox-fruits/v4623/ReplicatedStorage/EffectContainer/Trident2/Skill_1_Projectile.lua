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
local inverse = CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
local inverse2 = CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
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

local function snapProjectileToFinalPos(folder, p)
	folder.CFrame = folder.CFrame.Rotation + p

	for _, effect in ipairs(folder:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = false
		end
	end

	folder.Transparency = 1
end

local function fireClientProjectile(fliesFor, projectileRadius, fXContainer, fn, part)
	if part == nil then
		part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Shape = Enum.PartType.Ball
		part.Size = Vector3.new(projectileRadius, projectileRadius, projectileRadius) * 2
		part.Transparency = 1
		part.Name = "Projectile"
		part.Parent = _WorldOrigin
		destroyAfter(part, fliesFor + 7)
	end

	part.CFrame = CFrame.lookAt(fn(0.001), fn(0.002)) * inverse2
	local bindableEvent = Instance.new("BindableEvent")
	destroyAfter(bindableEvent, 7)
	local v = false
	local connection = nil
	connection = heartbeatLoopFor2(fliesFor, function(_, _, p)
		if fXContainer:GetAttribute("ProjectileActive") == true then
			part.CFrame = CFrame.lookAt(fn(p), fn(p + 0.01)) * inverse2
			return
		end

		connection:Disconnect()
		connection = nil
		snapProjectileToFinalPos(part, fXContainer:GetAttribute("ImpactPos"))
		bindableEvent:Fire(fXContainer:GetAttribute("ImpactPos"), "Impact")
		v = true
	end, function()
		if v == true then
			return
		end

		snapProjectileToFinalPos(part, fn(1))
		bindableEvent:Fire(fn(1), "NonImpact")
	end)
	return bindableEvent, part, connection
end

local function AllVFX(clone, enabled2, p2)
	local function Emit(folder, enabled, duration)
		for _, effect in ipairs(folder:GetDescendants()) do
			if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
				continue
			end

			effect.Enabled = enabled
		end

		if duration then
			task.delay(duration, function()
				for _, effect in ipairs(folder:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = false
				end
			end)
		end
	end

	if typeof(clone) ~= "table" then
		Emit(clone, enabled2, p2)
		return
	end

	for _, item in clone do
		Emit(item, enabled2, p2)
	end
end

function EmitAll(items)
	local function Emit(folder)
		for _, emitter in ipairs(folder:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if emitter:GetAttribute("EmitDelay") then
				local v = emitter
				task.delay(emitter:GetAttribute("EmitDelay"), function()
					v:Emit(v:GetAttribute("EmitCount"))
				end)
			else
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end

	if typeof(items) ~= "table" then
		Emit(items)
		return
	end

	for _, item in items do
		Emit(item)
	end
end

function Weld(p, part, cFrame, name)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = p
	weldConstraint.Part1 = part
	weldConstraint.Part1.CFrame = cFrame
	weldConstraint.Parent = p
	destroyAfter(weldConstraint, 7)

	if name then
		weldConstraint.Name = name
	end
end

local function TimeScaleParticle(emitter, p)
	emitter.Speed = NumberRange.new(emitter.Speed.Min * p, emitter.Speed.Max * p)
	emitter.Rate *= p
	emitter.RotSpeed = NumberRange.new(emitter.RotSpeed.Min * p, emitter.RotSpeed.Max * p)

	if emitter:GetAttribute("EmitDelay") then
		emitter:SetAttribute("EmitDelay", emitter:GetAttribute("EmitDelay") / p)
	end
end

return function(data)
	local _ = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 900 then
		return
	end

	local origin = data.origin
	local fireDir = data.fireDir
	local targetPos = data.targetPos
	local parent2 = _WorldOrigin
	local parent = hrp.Parent
	local v2 = CFrame.lookAt(createVector(0, 0, 0), fireDir) + origin
	Util.Sound:Play("TridentThrowLaunch", hrp.CFrame)
	local clone = FX:WaitForChild("Trident").PoleThing.Pole2:Clone()
	clone.Parent = parent
	destroyAfter(clone, 7)
	local motor6D = Instance.new("Motor6D")
	motor6D.Name = "Pole2 Grip"
	motor6D.Part0 = parent.RightHand
	motor6D.Part1 = clone["Pole2 Grip"]
	motor6D.C0 = FX:WaitForChild("Trident").PoleThing.RightHand["Pole2 Grip"].C0
	motor6D.C1 = FX:WaitForChild("Trident").PoleThing.RightHand["Pole2 Grip"].C1
	motor6D.Parent = parent.RightHand
	destroyAfter(motor6D, 7)
	Util.Sound:Play("TridentThrowHitObject", clone.PrimaryPart)
	task.wait()
	local primaryPart = clone.PrimaryPart
	motor6D:Destroy()
	local flag = true
	clone.PrimaryPart.Anchored = true
	clone.Parent = parent2
	destroyAfter(clone, 7)
	hrp.CFrame = CFrame.lookAt(hrp.Position, targetPos)
	clone:PivotTo(CFrame.lookAt(hrp.Position, targetPos) * CFrame.Angles(-1.5707963267948966, 0, 0))
	local clone2 = FX:WaitForChild("Trident")["Trident Throw VFX"]:Clone()
	clone2.CFrame = primaryPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
	clone2.Parent = parent2
	destroyAfter(clone2, 7)
	local clone3 = FX:WaitForChild("Trident").Rope:Clone()
	clone3:PivotTo(primaryPart.CFrame)
	clone3.BeamEnd.CFrame = parent.RightHand.CFrame
	clone3.Parent = parent2
	destroyAfter(clone3, 7)
	local clone4 = FX:WaitForChild("Trident")["Trident Emit VFX"]:Clone()
	clone4.CFrame = primaryPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0) + (targetPos - hrp.Position).Unit * 5
	clone4.Parent = parent2
	destroyAfter(clone4, 3)
	Weld(clone2, primaryPart, primaryPart.CFrame, "PullWeld")
	Weld(clone3.PrimaryPart, primaryPart, primaryPart.CFrame)
	Weld(clone3.BeamEnd, parent.RightHand, parent.RightHand.CFrame)
	AllVFX(clone2, true)
	EmitAll(clone4)
	local v3 = fireClientProjectile(data.fliesFor, data.projectileRadius, data.FXContainer, function(p)
		return origin + (targetPos - origin) * p * 1.1
	end, primaryPart)
	local connection = heartbeatLoopFor2(data.fliesFor, function()
		local attachment = clone3.BeamEnd.Attachment
		local origin2 = origin
		local worldPosition = attachment.WorldPosition
		attachment.WorldCFrame = CFrame.lookAt(createVector(0, 0, 0), worldPosition - origin2) * inverse + worldPosition

		for _, child in ipairs(clone3.BeamStart.Attachment:GetChildren()) do
			child.CurveSize0 = 0
			child.CurveSize1 = (worldPosition - origin2).Magnitude
		end
	end)
	v3.Event:Once(function(p, p2)
		if flag then
			flag = false

			if connection then
				connection:Disconnect()
			end

			for _, child in ipairs(clone3.BeamStart.Attachment:GetChildren()) do
				local tween = TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
					CurveSize0 = 0,
					CurveSize1 = 0
				})
				tween:Play()
				tween:Destroy()
			end

			if data.victimHrpObjectValue.Value == nil then
				if p2 == "Impact" then
					AllVFX(clone2, false)
					destroyAfter(clone2, 1)
					clone2:FindFirstChild("PullWeld"):Destroy()
					clone2.Anchored = true
					clone.PrimaryPart.Anchored = true
					local clone5 = FX:WaitForChild("Trident")["Trident Hit VFX"]:Clone()
					clone5.CFrame = primaryPart.CFrame * CFrame.new(0, 5, 0) + createVector(0, 1.1, 0)
					clone5.Parent = parent2
					EmitAll(clone5)
					destroyAfter(clone5, 3)
					local clone6 = FX:WaitForChild("Trident").GrabVFX:Clone()
					clone6.CFrame = hrp.CFrame
					clone6.Anchored = true
					clone6.Parent = parent2
					AllVFX(clone6, true, 0.4)
					destroyAfter(clone6, 1.4)
					local v4 = math.clamp((p - origin).Magnitude / 300, 0, 1) * 2 + 1

					for _, emitter in ipairs(clone6:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							TimeScaleParticle(emitter, v4)
						end
					end

					local clone7 = FX:WaitForChild("Trident").Bubble:Clone()
					clone7:PivotTo(CFrame.lookAt(p, hrp.Position) * CFrame.Angles(0, 1.5707963267948966, 0))
					clone7.Parent = parent2
					destroyAfter(clone7, 7)
					Util.Sound:Play("TridentThrowHitObject", clone6)
					Util.Sound:Play("TridentThrowExplosion", p)
					local _ = CFrame.lookAt(origin, p) * CFrame.new(0, 2, -(origin - p).Magnitude + 5)
					heartbeatLoopFor2(0.4, function(_, _, _)
						local raycastResult = Workspace:Raycast(hrp.Position, createVector(-0, -10, -0), raycastParams)
						clone6.Hold1.Bluething.Enabled = raycastResult ~= nil
						clone6.Hold2.Bluething.Enabled = raycastResult ~= nil
						clone6.CFrame = CFrame.new(hrp.Position, hrp.Position + fireDir)
					end, function()
						if clone3 and clone3:FindFirstChild("BeamStart") then
							for _, child in ipairs(clone3.BeamStart.Attachment:GetChildren()) do
								local tween = TweenService:Create(child, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {
									Width0 = 0,
									Width1 = 0
								})
								tween:Play()
								tween:Destroy()
							end

							destroyAfter(clone3, 0.4)
						end

						if clone then
							destroyAfter(clone, 0.5)
						end

						local tween = TweenService:Create(
							clone7.PrimaryPart,
							TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								Size = createVector(0, 0, 0),
								Transparency = 1
							}
						)
						tween:Play()
						tween:Destroy()
						destroyAfter(clone7, 1)
					end)
					local track = clone7.AnimationController:LoadAnimation(clone7.BubbleV2)
					track:Play()
					track:AdjustSpeed(2.5)
					local tween = TweenService:Create(
						clone7.PrimaryPart,
						TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							Size = createVector(15, 15, 15),
							Transparency = 0.005
						}
					)
					tween:Play()
					tween:Destroy()
				elseif p2 == "NonImpact" then
					AllVFX(clone2, false)
					destroyAfter(clone2, 1)
					clone2:FindFirstChild("PullWeld"):Destroy()
					clone2.Anchored = true
					clone.PrimaryPart.Anchored = true

					if clone3 and clone3:FindFirstChild("BeamStart") then
						for _, child in ipairs(clone3.BeamStart.Attachment:GetChildren()) do
							local tween = TweenService:Create(child, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {
								Width0 = 0,
								Width1 = 0
							})
							tween:Play()
							tween:Destroy()
						end

						destroyAfter(clone3, 0.4)
					end

					if clone then
						destroyAfter(clone, 0.5)
					end
				end
			else
				local value = data.victimHrpObjectValue.Value
				primaryPart.Anchored = true
				AllVFX(clone2, false)
				clone2:FindFirstChild("PullWeld"):Destroy()
				destroyAfter(clone2, 1)
				destroyAfter(clone3, (v2.Position - value.Position).Magnitude / 150)
				clone2.Anchored = true
				local clone5 = FX:WaitForChild("Trident")["Trident Hit VFX"]:Clone()
				clone5.CFrame = primaryPart.CFrame * CFrame.new(0, 5, 0) + createVector(0, 1.1, 0)
				clone5.Anchored = true
				clone5.Parent = parent2
				EmitAll(clone5)
				destroyAfter(clone5, 3)
				local clone6 = FX:WaitForChild("Trident").GrabVFX:Clone()
				clone6.CFrame = value.CFrame
				clone6.Anchored = true
				clone6.Parent = parent2
				AllVFX(clone6, true, 0.4)
				destroyAfter(clone6, 1.4)
				local v4 = math.clamp((p - origin).Magnitude / 300, 0, 1) + 1

				for _, emitter in ipairs(clone6:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						TimeScaleParticle(emitter, v4)
					end
				end

				local clone7 = FX:WaitForChild("Trident").Bubble:Clone()
				clone7.PrimaryPart.Anchored = true
				clone7:PivotTo(value.CFrame * CFrame.Angles(0, 1.5707963267948966, 0))
				clone7.Parent = parent2
				destroyAfter(clone7, 7)
				local track = clone7.AnimationController:LoadAnimation(clone7.BubbleV2)
				track:Play()
				track:AdjustSpeed(2.5)
				local tween = TweenService:Create(
					clone7.PrimaryPart,
					TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						Size = createVector(25, 25, 25),
						Transparency = 0.005
					}
				)
				tween:Play()
				tween:Destroy()
				local _ = value.CFrame
				local _ = CFrame.lookAt(value.Position, origin) * CFrame.new(
					0,
					2,
					-(value.Position - origin).Magnitude + 5
				)
				clone6.Hold1.Bluething:Destroy()
				clone6.Hold2.Bluething:Destroy()
				Util.Sound:Play("TridentThrowHitObject", clone6)
				Util.Sound:Play("TridentThrowExplosion", p)
				heartbeatLoopFor2(0.38333333333333336, function(_, _, _)
					clone7:PivotTo(clone7:GetPivot().Rotation + value.Position)
					clone6.CFrame = CFrame.new(value.Position, p + (p - value.Position))
					primaryPart.CFrame = clone6.CFrame
					clone5.CFrame = primaryPart.CFrame
				end, function()
					if clone then
						destroyAfter(clone, 0.5)

						for _, part in pairs(clone:GetDescendants()) do
							if part:IsA("BasePart") then
								part.Transparency = 1
							end
						end
					end

					if clone3 and clone3:FindFirstChild("BeamStart") then
						for _, child in ipairs(clone3.BeamStart.Attachment:GetChildren()) do
							local tween2 = TweenService:Create(child, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {
								Width0 = 0,
								Width1 = 0
							})
							tween2:Play()
							tween2:Destroy()
						end

						destroyAfter(clone3, 0.4)
					end

					local tween2 = TweenService:Create(
						clone7.PrimaryPart,
						TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 0, 0),
							Transparency = 1
						}
					)
					tween2:Play()
					tween2:Destroy()
					destroyAfter(clone7, 1)
				end)
			end
		end
	end)
end