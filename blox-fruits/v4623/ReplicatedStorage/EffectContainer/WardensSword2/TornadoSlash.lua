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
local tornadoSlash = FX:WaitForChild("WardensSword").TornadoSlash
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

local function fn(position, value, clone)
	local raycastParams2 = RaycastParams.new()
	raycastParams2.IgnoreWater = true

	if clone then
		raycastParams2.FilterType = Enum.RaycastFilterType.Blacklist
		raycastParams2.FilterDescendantsInstances = raycastParams.FilterDescendantsInstances
	end

	local raycastResult = Workspace:Raycast(
		position + createVector(0, 2, 0),
		createVector(0, -1, 0) * ((value or 1000) + 2),
		raycastParams2
	)

	if raycastResult then
		return {
			Position = raycastResult.Position,
			Object = raycastResult.Instance
		}
	end

	return nil
end

local function fn2(emitter)
	if emitter:IsA("ParticleEmitter") then
		emitter.Enabled = false
		return
	end

	for _, emitter2 in ipairs(emitter:GetDescendants()) do
		if emitter2:IsA("ParticleEmitter") then
			emitter2.Enabled = false
		end
	end
end

local function fn3(emitter)
	if emitter:IsA("ParticleEmitter") then
		emitter.Enabled = true
		return
	end

	for _, effect in ipairs(emitter:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = true
		end
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

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 1100 then
		return
	end

	local origin = data.origin
	local _ = data.fireDir
	Util.Sound:Play("KiBlastFireShort", hrp.Position)
	local targetPos = data.targetPos
	local cframe = CFrame.lookAt(origin, targetPos)
	local clone = tornadoSlash.TornadoSlash:Clone()
	clone.Parent = _WorldOrigin
	clone.CFrame = cframe
	task.spawn(function()
		if clone:IsA("ParticleEmitter") then
			local emitCount = clone:GetAttribute("EmitCount") or 1
			local emitDelay = clone:GetAttribute("EmitDelay") or nil

			if emitDelay then
				task.wait(emitDelay)
			end

			clone:Emit(emitCount)
		else
			for _, emitter in ipairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v = emitter
				task.spawn(function()
					local emitCount = v:GetAttribute("EmitCount") or 1
					local emitDelay = v:GetAttribute("EmitDelay") or nil

					if emitDelay then
						task.wait(emitDelay)
					end

					v:Emit(emitCount)
				end)
			end
		end
	end)
	destroyAfter(clone, 2)
	local clone2 = tornadoSlash.TornadoWind:Clone()
	clone2.Parent = _WorldOrigin
	clone2.CFrame = cframe * CFrame.new(0, 0, -5)
	task.spawn(function()
		if clone2:IsA("ParticleEmitter") then
			local emitCount = clone2:GetAttribute("EmitCount") or 1
			local emitDelay = clone2:GetAttribute("EmitDelay") or nil

			if emitDelay then
				task.wait(emitDelay)
			end

			clone2:Emit(emitCount)
		else
			for _, emitter in ipairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v = emitter
				task.spawn(function()
					local emitCount = v:GetAttribute("EmitCount") or 1
					local emitDelay = v:GetAttribute("EmitDelay") or nil

					if emitDelay then
						task.wait(emitDelay)
					end

					v:Emit(emitCount)
				end)
			end
		end
	end)
	destroyAfter(clone2, 2)
	local clone3 = tornadoSlash.Tornado:Clone()
	Util.Sound:Play("RagingWindProjectile", clone3)
	clone3.Parent = _WorldOrigin
	clone3.CFrame = cframe
	local descendants = clone3.Attachment:GetDescendants()
	local attachment = clone3.Attachment
	task.spawn(function()
		if attachment:IsA("ParticleEmitter") then
			local emitCount = attachment:GetAttribute("EmitCount") or 1
			local emitDelay = attachment:GetAttribute("EmitDelay") or nil

			if emitDelay then
				task.wait(emitDelay)
			end

			attachment:Emit(emitCount)
		else
			for _, emitter in ipairs(attachment:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v = emitter
				task.spawn(function()
					local emitCount = v:GetAttribute("EmitCount") or 1
					local emitDelay = v:GetAttribute("EmitDelay") or nil

					if emitDelay then
						task.wait(emitDelay)
					end

					v:Emit(emitCount)
				end)
			end
		end
	end)
	fn3(clone3.Attachment)
	local v = true
	TweenService:Create(clone3, TweenInfo.new(data.fliesFor, Enum.EasingStyle.Linear), {
		Position = targetPos
	}):Play()
	local flag = false
	task.spawn(function()
		local WAIT_INTERVAL = 0.1
		local v2 = time()

		for _ = 1, 600 do
			if not v or time() - v2 > 10 then
				break
			end

			for _, emitter in pairs(descendants) do
				if emitter:IsA("ParticleEmitter") and emitter.Enabled then
					emitter:Emit(emitter.Rate * 0.05)
				end
			end

			if fn(clone3.Position, 5, clone3) then
				if flag then
					task.wait(WAIT_INTERVAL)
					continue
				else
					flag = true
					fn3(clone3.Ground)
				end
			elseif flag == false then
				task.wait(WAIT_INTERVAL)
				continue
			else
				flag = false
				fn2(clone3.Ground)
			end

			task.wait(WAIT_INTERVAL)
		end
	end)
	task.wait(data.fliesFor)
	v = false
	fn2(clone3)
	destroyAfter(clone3, 3)
end