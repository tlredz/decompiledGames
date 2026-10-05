local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local tushitaSkill2 = FX:WaitForChild("Tushita").TushitaSkill2
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

local function fireClientProjectile(p, p2, instance, callback, part)
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

	part.CFrame = CFrame.lookAt(callback(0.001), callback(0.002))
	local bindableEvent = Instance.new("BindableEvent")
	destroyAfter(bindableEvent, 7)
	local v = false
	local connection = nil
	connection = heartbeatLoopFor2(p, function(_, _, p3)
		if instance:GetAttribute("ProjectileActive") == true then
			part.CFrame = CFrame.lookAt(callback(p3), callback(p3 + 0.01))
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

return function(data)
	local player = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 1200 then
		return
	end

	local origin = data.origin
	local parent = _WorldOrigin

	if data.mode then
		local mode = data.mode
		local finalCFrame = data.finalCFrame
		local startCFrame = data.startCFrame
		TweenService:Create(hrp, TweenInfo.new(0.075), {
			CFrame = finalCFrame
		}):Play()
		local v2 = startCFrame * CFrame.new(0, 0, 0) * CFrame.Angles(
			0,
			mode == 6 and 0.07 or mode % 2 == 0 and 0.14 or -0.14,
			0
		)
		local v3 = mode == 6 and 3 or mode % 2 == 0 and 1 or 2
		local v4 = 10 + (v2.p - finalCFrame.p).Magnitude
		local v5 = 5 + (v3 == 3 and 60 or 30)
		local clone = tushitaSkill2.RedSpike:Clone()
		clone:SetPrimaryPartCFrame(v2 * CFrame.new(0, 0, v4 * 0.5) * CFrame.Angles(0, 3.141592653589793, 0))

		for _, child in ipairs(clone:GetChildren()) do
			child.Size *= 2.5 * v5 * 0.04
			local tween = TweenService:Create(child, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
				Size = createVector(0.05, 0.05, 0.05),
				CFrame = child.CFrame * CFrame.new(0, 0, v4 * 1.5)
			})

			if child == clone.PrimaryPart then
				tween.Completed:Once(function()
					clone:Destroy()
				end)
			end

			tween:Play()
		end

		clone.Parent = parent
		destroyAfter(clone, 7)
		local v6 = v3 or 1

		for i = 1, v6 == 3 and 2 or 1 do
			local v7 = i ~= 1 and 0 or v6 == 2 and 0 or 3.141592653589793
			local v8 = true
			local clone2 = tushitaSkill2.RedSlash:Clone()
			clone2.Red.Electric.Enabled = false
			clone2:SetPrimaryPartCFrame(finalCFrame * CFrame.new(0, 0, -12) * CFrame.Angles(
				v7,
				v7,
				v7 + (v7 > 0 and 2.2 or -2.2)
			))

			for _, child in ipairs(clone2:GetChildren()) do
				child.Size *= 1 + v5 * 0.05
				local tween = TweenService:Create(child, TweenInfo.new(0.15 + (v3 == 3 and 0.06 or 0)), {
					Size = child.Size * 2
				})

				if child == clone2.PrimaryPart then
					local v9 = clone2
					tween.Completed:Once(function()
						v8 = false
						v9:Destroy()
					end)
				end

				tween:Play()
			end

			clone2.Parent = parent
			destroyAfter(clone2, 7)
			coroutine.resume(coroutine.create(function()
				time()

				for i2 = 1, 600 do
					local v10 = RunService.Heartbeat:Wait()

					if v8 and clone2.PrimaryPart then
						clone2:SetPrimaryPartCFrame(clone2.PrimaryPart.CFrame * CFrame.Angles(
							-v10 * 3.141592653589793 * 5,
							0,
							0
						))
					else
						break
					end
				end
			end))
		end

		if mode == 6 then
			local clone2 = tushitaSkill2.CrossSlash:Clone()
			clone2.CFrame = finalCFrame * CFrame.new(0, 0, -50)
			clone2.Parent = parent
			destroyAfter(clone2, 3)

			if player == game.Players.LocalPlayer then
				Util.CameraShaker:ShakeOnce(8, 14, 0.2, 0.7)
			end

			for _, emitter in ipairs(clone2:GetDescendants()) do
				if not (emitter:IsA("ParticleEmitter") and emitter.Parent.Name == "Slash3") then
					continue
				end

				for _ = 1, 30 do
					local clone3 = emitter:Clone()
					clone3.Parent = emitter.Parent
					clone3.Drag = emitter.Drag + math.random(-7, -3)
					clone3:SetAttribute("EmitDelay", math.random(10, 100) / 1000)
					coroutine.wrap(function()
						task.wait(math.random(10, 40) / 700)
						clone3.Acceleration = Vector3.new(
							math.random(-40, 40) * math.random(9, 12),
							math.random(-40, 40) * math.random(9, 12),
							math.random(-40, 40) * math.random(9, 12)
						)
						task.wait(math.random(10, 40) / 200)
						clone3.Acceleration = Vector3.new(
							math.random(-20, 20) * math.random(3, 7) * 2,
							math.random(-20, 20) * math.random(3, 7),
							math.random(-20, 20) * math.random(3, 7) * 2
						)
						task.wait(math.random(10, 30) / 100)
						clone3.Acceleration = Vector3.new(
							math.random(-20, 20),
							math.random(-10, 10),
							math.random(-20, 20)
						)
					end)()
				end
			end

			for _, emitter in ipairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v7 = emitter
				coroutine.wrap(function()
					if v7:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v7:GetAttribute("EmitDelay"))
					end

					v7:Emit(v7:GetAttribute("EmitCount"))
				end)()
			end

			task.wait(0.05)
			local v7 = finalCFrame * CFrame.new(0, 3, -50).Position
			local ray = Ray.new(
				v7 + createVector(0, 2, 0),
				CFrame.new(v7 + createVector(0, 2, 0), v7 + createVector(0, -20, 0)).LookVector * 20
			)
			local raycastResult = Workspace:Raycast(ray.Origin, ray.Direction, raycastParams)

			if raycastResult then
				local _ = raycastResult.Instance
				local position = raycastResult.Position
				local normal = raycastResult.Normal
				local clone3 = tushitaSkill2.GroundCut:Clone()
				clone3.CFrame = Util.Misc.AlignCFrame(CFrame.new(position, position + finalCFrame.LookVector), normal)
				clone3.Parent = parent
				destroyAfter(clone3, 3)

				for _, effect in ipairs(clone3:GetDescendants()) do
					if effect:IsA("Beam") then
						local tween = TweenService:Create(
							effect,
							TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Width0 = effect.Width0,
								Width1 = effect.Width1
							}
						)
						effect.Width0 = 0
						effect.Width1 = 0
						local tween2 = TweenService:Create(
							effect,
							TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Brightness = effect.Brightness,
								LightEmission = effect.LightEmission
							}
						)
						effect.Brightness = 10
						effect.LightEmission = 1
						tween:Play()
						coroutine.wrap(function()
							tween.Completed:Wait()
							task.wait(0.025)
							tween2:Play()
						end)()
					elseif effect:IsA("ParticleEmitter") then
						effect.Enabled = true
					end
				end

				task.wait(0.25)

				for _, emitter in ipairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.wait(0.5)

				for _, beam in ipairs(clone3:GetDescendants()) do
					if beam:IsA("Beam") then
						TweenService:Create(
							beam,
							TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Width0 = 0,
								Width1 = 0
							}
						):Play()
					end
				end
			end
		end
	elseif data.holdEffect then
		if player == game.Players.LocalPlayer then
			Util.CameraShaker:ShakeOnce(8, 14, 0.2, 0.7)
		end

		local clone = tushitaSkill2.HoldStart:Clone()
		clone.CFrame = hrp.CFrame
		clone.Parent = parent
		destroyAfter(clone, 3)

		for _, emitter in ipairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	elseif data.fireEffect then
		local cFrame = hrp.CFrame.Rotation + origin
		local clone = tushitaSkill2.DashStart:Clone()
		clone.CFrame = cFrame
		clone.Parent = parent
		destroyAfter(clone, 3)

		for _, emitter in ipairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local clone2 = tushitaSkill2.Start:Clone()
		clone2.CFrame = cFrame
		clone2.Parent = parent
		destroyAfter(clone2, 7)
		clone2.Weld.Part0 = hrp

		for _, emitter in ipairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		coroutine.wrap(function()
			task.wait(0.2)
			clone2.Weld:Destroy()
			clone2.Anchored = true

			for _, emitter in ipairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)()
	end
end