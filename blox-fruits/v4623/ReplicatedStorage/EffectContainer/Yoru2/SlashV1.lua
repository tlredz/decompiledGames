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
local yoruSkill1 = FX:WaitForChild("Yoru").YoruSkill1
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

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function cubicBezier(linear, position, p, p2, p3)
	local v = position + (p - position) * linear
	local v2 = p + (p2 - p) * linear
	local v3 = p2 + (p3 - p2) * linear
	local v4 = v + (v2 - v) * linear
	return v4 + (v2 + (v3 - v2) * linear - v4) * linear
end

local function adjustDuration(p, p2)
	local v = math.max(0.01, p - p2)
	return v, p2 - (p - v)
end

return function(data)
	local _ = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera
	local cFrame = hrp.CFrame

	if (cFrame.Position - currentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	local origin = data.origin
	local fireDir = data.fireDir
	local targetPos = data.targetPos
	local v = math.max(0, Util.MasterClock:GetTime() - data.ClockTime - 0.05)
	local fliesFor = data.fliesFor
	local v2 = math.max(0.01, fliesFor - v)
	local _ = v - (fliesFor - v2)
	local _ = (Workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude < 150
	local parent = _WorldOrigin
	local v5 = CFrame.lookAt(createVector(0, 0, 0), fireDir) * CFrame.new(0, 0, -10) + origin
	local magnitude = (targetPos - v5.Position).Magnitude
	Util.Sound:Play("KiBlastFireShort", v5, 25)
	task.wait(adjustDuration(0.04, v))
	local clone = yoruSkill1.Slash:Clone()
	clone.Size *= 1.75

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Size *= 1.75
		elseif descendant:IsA("Attachment") then
			descendant.Position *= 1.75
		elseif descendant:IsA("Weld") then
			descendant.C0 = CFrame.new(descendant.C0.p * 1.75) * (descendant.C0 - descendant.C0.p)
		elseif descendant:IsA("Beam") then
			descendant.Width0 *= 1.75
			descendant.Width1 *= 1.75
		else
			descendant:IsA("ParticleEmitter")
		end
	end

	clone.CFrame = v5 * CFrame.new(0, 0, 0) * CFrame.new(0, clone.Size.Y / 2.5, 0)
	clone.Parent = parent
	destroyAfter(clone, v2 + 5)

	for _, effect in ipairs(clone:GetDescendants()) do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
			continue
		end

		if effect:IsA("ParticleEmitter") then
			effect.Lifetime = NumberRange.new(effect.Lifetime.Min * v2, effect.Lifetime.Max * v2)
		end

		effect.Enabled = true
	end

	local cFrame2 = clone.CFrame
	local tween = TweenService:Create(clone, TweenInfo.new(v2, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
		CFrame = clone.CFrame * CFrame.new(0, 0, -magnitude)
	})
	tween:Play()

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("MeshPart") then
			local tween2 = TweenService:Create(descendant, TweenInfo.new(0.1), {
				Size = Vector3.new(descendant.Size.X, descendant.Size.Y, descendant.Size.Z)
			})
			descendant.Size = Vector3.new(descendant.Size.X, 0, descendant.Size.Z)
			tween2:Play()
		elseif descendant:IsA("Attachment") then
			if descendant:FindFirstChildOfClass("Beam") then
				TweenService:Create(descendant, TweenInfo.new(v2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = Vector3.new(descendant.Position.X, descendant.Position.Y, descendant.Position.Z * 1.5)
				}):Play()
			end
		elseif descendant:IsA("Beam") then
			local tween2 = TweenService:Create(descendant, TweenInfo.new(0.25), {
				Width0 = descendant.Width0,
				Width1 = descendant.Width1
			})
			descendant.Width0 = 0
			descendant.Width1 = 0
			tween2:Play()
		end
	end

	for i = 1, 4 do
		local v6 = i
		coroutine.wrap(function()
			task.wait(0.025)
			local clone2 = yoruSkill1.Trail:Clone()
			clone2.CFrame = cFrame2 * CFrame.new(math.random(-20, 20) / 3, math.random(-15, 15), math.random(-1, 1))
			clone2.Parent = parent
			local position = clone2.Position
			local v7 = cFrame2 * CFrame.new(math.random(-5, 5), math.random(-15, 15), -magnitude).Position
			local magnitude2 = (position - v7).Magnitude
			local cframe = CFrame.new(position, v7)
			clone2.CFrame = cframe
			local v8 = (position - v7) / 2
			local position2 = CFrame.new(CFrame.new(position) * (v8 / -1.5)).Position
			local position3 = CFrame.new(CFrame.new(v7) * (v8 / 1.5)).Position
			local v9 = magnitude2 / 12
			local v10 = position2 + Vector3.new(math.random(-v9, v9), math.random(-3, 8) * 4, math.random(-v9, v9))
			local v11 = position3 + Vector3.new(math.random(-v9, v9), math.random(-3, 8) * 4, math.random(-v9, v9))

			for i2, effect in pairs(clone2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") then
					effect.Lifetime = NumberRange.new(effect.Lifetime.Min * v2 * 0.8, effect.Lifetime.Max * v2 * 0.8)
					effect.Enabled = true
				end

				if effect:IsA("Trail") then
					effect.Lifetime *= v2 * 0.8
				end
			end

			local lastTime = tick()
			local v12 = 0
			local v13 = 0.016666666666666666

			while true do
				local v14 = math.min(1, (tick() - lastTime) / v2)
				v12 = v12 % 6.283185307179586 + 7.0685834705770345 * v13
				local linear = Util.Tween.ease["in"].linear(v14, 0, 1, 1)
				local v15 = cubicBezier(linear, position, v10, v11, v7) + cframe.UpVector * (v6 % 2 == 0 and 1 or -1) * math.sin(v12) * v9 * (1.01 - linear)
				clone2.CFrame = clone2.CFrame:Lerp(CFrame.new(v15, v7), linear)

				if v14 == 1 then
					break
				end

				v13 = task.wait()
			end

			local v14 = 0

			for i2, emitter in ipairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				v14 = math.max(v14, emitter.Lifetime.Max)
				emitter.Enabled = false
			end

			destroyAfter(clone2, v14 + 1)
		end)()
	end

	coroutine.wrap(function()
		task.wait(0.025)
		local position = cFrame2.Position
		local v6 = 30
		local part, v7, v8 = Workspace:FindPartOnRayWithIgnoreList(
			Ray.new(
				position + Vector3.new(0, v6 / 10, 0),
				CFrame.new(position + Vector3.new(0, v6 / 10, 0), position + Vector3.new(0, -v6, 0)).LookVector * v6
			),
			raycastParams.FilterDescendantsInstances
		)

		if part then
			coroutine.wrap(function()
				local clone2 = yoruSkill1.GroundTrail:Clone()
				clone2.CFrame = Util.Misc.AlignCFrame(cFrame2 - cFrame2.p + v7, v8)
				clone2.Position = v7 + createVector(0, 0.001, 0)
				clone2.Parent = parent

				for _, effect in pairs(clone2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") then
						effect.Lifetime = NumberRange.new(effect.Lifetime.Min * v2 / 2, effect.Lifetime.Max * v2 / 2)
						effect.Enabled = true
					end

					if effect:IsA("Trail") then
						effect.Lifetime *= v2 / 2
					end
				end

				local tween2 = TweenService:Create(
					clone2,
					TweenInfo.new(v2, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
					{
						CFrame = clone2.CFrame * CFrame.new(0, 0, -magnitude)
					}
				)
				tween2:Play()
				v6 = 10
				local lastTime = os.clock()
				local v9 = v8

				while true do
					task.wait(0.01)
					local position2 = clone.Position
					local part2, _, v10 = Workspace:FindPartOnRayWithIgnoreList(
						Ray.new(
							position2 + Vector3.new(0, v6 / 2, 0),
							CFrame.new(position2 + Vector3.new(0, v6 / 10, 0), position2 + Vector3.new(0, -v6, 0)).LookVector * v6 * 2
						),
						raycastParams.FilterDescendantsInstances
					)

					if not part2 then
						tween2:Pause()
						break
					end

					if v9 ~= nil and v9 ~= v10 then
						tween2:Pause()
						break
					end

					local v11 = os.clock() - lastTime

					if v2 * 0.8 <= v11 or os.clock() - lastTime > 10 then
						break
					else
						v9 = v10
					end
				end

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				destroyAfter(clone2, 3)
			end)()
		end

		coroutine.wrap(function()
			task.wait(0.1)
			local clone2 = yoruSkill1.Smoke:Clone()
			clone2.CFrame = cFrame2
			clone2.Parent = parent
			local lastTime = os.clock()
			local v9 = false

			while true do
				task.wait(0.01)
				local v10 = clone.CFrame * CFrame.new(0, 0, -10).Position
				local part2, v11 = Workspace:FindPartOnRayWithIgnoreList(
					Ray.new(
						v10 + createVector(0, 15, 0),
						CFrame.new(v10 + createVector(0, 3, 0), v10 + createVector(0, -30, 0)).LookVector * 30
					),
					raycastParams.FilterDescendantsInstances
				)

				if part2 then
					if v9 == false then
						v9 = true

						for _, effect in ipairs(clone2:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
								effect.Enabled = true
							end
						end
					end

					clone2.Position = v11 + createVector(0, 2, 0)
				elseif v9 == true then
					for _, effect in ipairs(clone2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							effect.Enabled = false
						end
					end

					v9 = false
				end

				local v12 = os.clock() - lastTime

				if not (v2 * 0.65 <= v12 or os.clock() - lastTime > 10) then
					continue
				end

				for _, effect in ipairs(clone2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						effect.Enabled = false
					end
				end

				destroyAfter(clone2, 4)
				break
			end
		end)()
	end)()
	coroutine.wrap(function()
		tween.Completed:Wait()

		for _, descendant in ipairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = false
			elseif descendant:IsA("Beam") then
				TweenService:Create(descendant, TweenInfo.new(0.15), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			elseif descendant:IsA("MeshPart") then
				TweenService:Create(descendant, TweenInfo.new(0.1), {
					Transparency = 1,
					Size = Vector3.new(descendant.Size.X, 0, descendant.Size.Z)
				}):Play()
			end
		end

		local clone2 = yoruSkill1.End:Clone()
		clone2.CFrame = clone.CFrame
		clone2.Parent = parent
		destroyAfter(clone2, 3)

		for _, emitter in ipairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end)()
end