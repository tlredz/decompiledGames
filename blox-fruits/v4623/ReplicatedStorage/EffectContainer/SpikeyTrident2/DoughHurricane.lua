local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local doughHurricane = FX:WaitForChild("SpikeyTrident").DoughHurricane
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
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

local function safeSetRootCFrame(instance, cFrame: CFrame, p, flag: boolean)
	local v = flag == nil or flag

	if cFrame ~= cFrame or (instance == nil or p == nil) then
		return
	end

	local bodyPosition = instance:FindFirstChildOfClass("BodyPosition")

	if bodyPosition and bodyPosition.MaxForce.Magnitude > 1000 or instance.Anchored == true then
		return
	end

	p.PlatformStand = true

	if v then
		local raycastResult = Workspace:Raycast(instance.Position, cFrame.Position - instance.Position, raycastParams)

		if raycastResult then
			instance.CFrame = instance.CFrame.Rotation + raycastResult.Position - (cFrame.Position - instance.Position).Unit * 0.2
		else
			instance.CFrame = cFrame
		end
	else
		instance.CFrame = cFrame
	end

	instance.AssemblyLinearVelocity = createVector(0, 0, 0)
	instance.AssemblyAngularVelocity = createVector(0, 0, 0)
	task.wait()
	p.PlatformStand = false
end

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

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 2500 then
		return
	end

	local _ = data.origin
	local _ = data.fireDir
	local unit = (data.TargetPos - data.StartPos).Unit
	local _ = data.hurricaneDashDuration
	local parent2 = _WorldOrigin
	local doughHurricane2 = doughHurricane

	local function DisableRush(instance, p)
		local folder = parent2:FindFirstChild(instance.Name .. p)

		if folder then
			folder.Name = "_"

			for _, emitter in folder:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.delay(2, function()
				folder:Destroy()
			end)
		end
	end

	local function EffectHandler(instance, p, ...)
		local part = hrp

		if p == "Start" then
			instance:SetAttribute("DoughHurricaneActive", 1)
			sound:Play("TridentDoughZ1", hrp)
			local clone = doughHurricane2.Root:Clone()
			clone.Name = instance.Name .. "Hurricane Root"
			clone.Massless = true
			clone.Weld.Part0 = part
			clone.Parent = parent2
			destroyAfter(clone, 7)

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			os.clock()
			local v4 = time()
			local position = createVector(0, 0, 0)

			for _ = 1, 600 do
				if (position - part.Position).Magnitude < 5 then
					continue
				end

				position = part.Position
				local raycastResult = Workspace:Raycast(part.Position, createVector(0, -10, 0), raycastParams)
				Effect.new("Dough.Misc.Drip.Generic"):replicate({
					Type = "Trajectory",
					CFrame = Util.Misc.SpreadAngleFromCFrame(hrp.CFrame, Vector2.new(180, 180)),
					Scale = random:NextNumber(1, 3),
					DropLifetime = random:NextNumber(0.5, 2),
					Velocity = (-hrp.CFrame.LookVector + createVector(0, 0.5, 0)) * random:NextNumber(5, 30),
					Gravity = Random.new():NextNumber(0.3, 1)
				})

				if raycastResult then
					local clone2

					if instance:GetAttribute("DoughHurricaneActive") == 2 then
						clone2 = doughHurricane2.Dust2:Clone()
					else
						clone2 = doughHurricane2.Dust:Clone()
					end

					local color

					if raycastResult.Instance then
						color = raycastResult.Instance.Color
					end

					clone2.CFrame = Util.Misc.AlignCFrame(
						CFrame.new(createVector(0, 0, 0), unit) + raycastResult.Position,
						raycastResult.Normal
					) + raycastResult.Normal
					clone2.Parent = _WorldOrigin

					for _, emitter in clone2:GetDescendants() do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						if color then
							string.find(string.lower(emitter.Name), "dust")
						end

						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end

					task.delay(1.7, function()
						clone2:Destroy()
					end)
				end

				task.wait(0.05)

				if not instance:GetAttribute("DoughHurricaneActive") or time() - v4 > 3 then
					break
				end
			end

			instance:SetAttribute("DoughHurricaneActive", nil)
		elseif p == "Start2" then
			local v4 = ...
			DisableRush(instance, "Hurricane Root")
			instance:SetAttribute("DoughHurricaneActive", 2)
			local clone = doughHurricane2.Root2:Clone()
			clone.Name = instance.Name .. "Hurricane Root2"
			clone.Massless = true
			clone.Weld.Part0 = part
			clone.Parent = parent2
			destroyAfter(clone, 7)

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			local lastTime = tick()

			while not (v4 < tick() - lastTime) and instance:GetAttribute("DoughHurricaneActive") do
				Effect.new("Dough.Misc.Drip.Generic"):replicate({
					Type = "Trajectory",
					CFrame = Util.Misc.SpreadAngleFromCFrame(hrp.CFrame, Vector2.new(180, 180)),
					Scale = random:NextNumber(1, 3),
					DropLifetime = random:NextNumber(0.5, 2),
					Velocity = (-hrp.CFrame.LookVector + createVector(0, 0.5, 0)) * random:NextNumber(5, 30),
					Gravity = Random.new():NextNumber(0.3, 1)
				})
				task.wait(0.016666666666666666)
			end
		elseif p == "End" then
			DisableRush(instance, "Hurricane Root")
			instance:SetAttribute("DoughHurricaneActive", nil)
		elseif p == "BurstEnd" then
			DisableRush(instance, "Hurricane Root2")
			local clone = doughHurricane2.Hit:Clone()
			clone.CFrame = part.CFrame * CFrame.new(0, 0, -5)
			clone.Parent = parent2

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			Effect.new("Dough.Explosions.DripScatter"):replicate({
				CFrame = clone.CFrame,
				Scale = 4,
				Gravity = 1,
				Distance = 35,
				Rate = 15,
				DropLifetime = 1.5,
				Influence = { 0.5, 1.5 },
				Time = random:NextNumber(0.3, 1.5),
				Force = true
			})
			task.delay(2, function()
				clone:Destroy()
			end)
			instance:SetAttribute("DoughHurricaneActive", nil)
		end
	end

	local parent = hrp.Parent

	if data.Boom == nil then
		task.spawn(EffectHandler, parent, "Start")
		local cframe = CFrame.new(data.StartPos, data.TargetPos)
		local initialDashDuration = data.initialDashDuration
		local lastTime = tick()
		local v3, v4

		if game.Players.LocalPlayer.Character == data.hrp.Parent then
			v3 = Util.BodyMover.new(parent):Create("BodyGyro", {
				CFrame = cframe - cframe.p,
				Duration = initialDashDuration
			})
			v4 = Util.BodyMover.new(parent):Create("BodyPosition", {
				Position = cframe.p,
				Duration = initialDashDuration
			})
		end

		while true do
			local v5 = math.clamp((tick() - lastTime) / initialDashDuration, 0.001, 1)

			if data.hrp.Parent:FindFirstChild("TridentGrabZ") or not data.hrp:IsDescendantOf(Workspace) then
				break
			end

			if game.Players.LocalPlayer.Character == data.hrp.Parent then
				v3:Set(cframe - cframe.p)
				v4:Set(cframe.p + (data.TargetPos - cframe.p) * v5)
			end

			if v5 == 1 then
				break
			else
				RunService.RenderStepped:Wait()
			end
		end

		if v3 and v4 then
			v3:Destroy()
			v4:Destroy()
		end
	else
		local boom = data.Boom

		if typeof(boom) == "number" then
			task.spawn(EffectHandler, parent, "Start2", boom)
		elseif boom then
			task.spawn(EffectHandler, parent, "BurstEnd")
		else
			task.spawn(EffectHandler, parent, "End")
		end
	end
end