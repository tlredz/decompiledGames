local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local znoTempo = FX:WaitForChild("SoundEffects").ZnoTempo
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

local rescheduleDestruction

rescheduleDestruction = function(instance, duration: number, flag: boolean?)
	if (flag == nil or flag) == true or instance:GetAttribute("PrevTimeDestructInitiated") == nil then
		instance:SetAttribute("PrevTimeDestructInitiated", time())
	end

	local destructionDepth = instance:GetAttribute("DestructionDepth") or 0
	instance:SetAttribute("DestructionDepth", destructionDepth + 1)

	if destructionDepth >= 100 then
		instance:Destroy()
		warn("rescheduleDestruction: Maximum re-entrancy depth of 100 exceeded")
	else
		task.delay(duration, function()
			local prevTimeDestructInitiated = instance:GetAttribute("PrevTimeDestructInitiated")

			if duration - (time() - prevTimeDestructInitiated) < 0.2 and instance ~= nil and instance.Parent ~= nil then
				instance:Destroy()
				return
			end

			if instance == nil or instance.Parent == nil then
				return
			end

			rescheduleDestruction(instance, duration, false)
		end)
	end
end

local function putValueAsValueObject(parent, name: string, folder, value: number)
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
		instance = Instance.new(v2[typeof(folder)])
		instance.Name = name
		instance.Parent = parent
	end

	instance.Value = folder
	rescheduleDestruction(instance, value or 60)
	return instance
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

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

return function(data)
	local _ = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local parent = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 1000 and data.skillHeld == true then
		return
	end

	local _ = data.origin
	local _ = data.fireDir
	local v = parent:FindFirstChild("ItemsTableFolder")

	if v == nil then
		v = Instance.new("Folder")
		v.Name = "ItemsTableFolder"
		v.Parent = parent
	end

	local v2 = random

	local function fn(hrp2)
		local clone = FX:WaitForChild("SoundEffects").Sound_V.Sound_V_NoTempo.Assets.Bezier:Clone()
		clone.Parent = _WorldOrigin
		destroyAfter(clone, 1)
		local position = hrp2.Position + Vector3.new(math.random(-17, 17), math.random(-17, 17), math.random(-17, 17))
		local p = (hrp2.CFrame * CFrame.new(0, 0, -3)).p
		local v4 = hrp2.Position + Vector3.new(v2:NextNumber(-12, 12), v2:NextNumber(-12, 12), v2:NextNumber(-12, 12))
		local v5 = hrp2.Position + Vector3.new(v2:NextNumber(-15, 15), v2:NextNumber(-15, 15), v2:NextNumber(-15, 15))
		clone.Position = position
		task.spawn(function()
			for i = 1, 10 do
				local v6 = i / 10
				local position2 = position
				local v8 = position2 + (v4 - position2) * v6
				local v9 = v4
				local v10 = v9 + (v5 - v9) * v6
				local v11 = v5
				local v12 = v11 + (p - v11) * v6
				local v13 = v8 + (v10 - v8) * v6
				clone.Position = v13 + (v10 + (v12 - v10) * v6 - v13) * v6
				task.wait(0.026)
			end
		end)
	end

	local _ = data.targetPos
	local cframe = CFrame.new(hrp.Position)
	local maxTempoActive = data.maxTempoActive

	if maxTempoActive == true then
		znoTempo = FX:WaitForChild("SoundEffects").Sound_V.Sound_V_MaxTempo.Assets
	elseif maxTempoActive == false then
		znoTempo = FX:WaitForChild("SoundEffects").Sound_V.Sound_V_NoTempo.Assets
	end

	if data.skillHeld == true then
		local v3

		if data.maxTempoActive == true then
			v3 = Util.Sound:Play("SoundFruitVChargeTEMPO", hrp)
		else
			v3 = Util.Sound:Play("SoundFruitVChargeNOTEMPO", hrp)
		end

		local folder = Instance.new("Folder")
		folder.Name = "MusicVChargeFolder"
		folder.Parent = _WorldOrigin
		destroyAfter(folder, 30)
		local clone = znoTempo.Charge:clone()
		clone.Parent = folder
		destroyAfter(clone, 30)
		clone.CFrame = cframe * CFrame.new(0, 0, -3)
		clone.Name = "charge"
		local lastTime = os.clock()
		local connection = nil
		connection = heartbeatLoopFor2(30, function()
			if clone == nil or folder == nil or folder.Parent == nil then
				if v3 then
					Util.Sound:FadeOut(v3, 0.1)
					v3 = nil
				end

				connection:Disconnect()
				connection = nil
			else
				if os.clock() - lastTime >= 0.1 then
					fn(hrp)
					lastTime = os.clock()
				end

				clone.CFrame = hrp.CFrame * CFrame.new(0, 0, -3)
			end
		end)
		task.delay(30, function()
			if v3 then
				Util.Sound:FadeOut(v3, 0.1)
				v3 = nil
			end
		end)
		putValueAsValueObject(v, "MusicVCharge", folder, 30)
	elseif data.skillHeld == false then
		local musicVCharge = v:FindFirstChild("MusicVCharge")

		if musicVCharge and musicVCharge.Value then
			local value = musicVCharge.Value
			local charge = value:FindFirstChild("charge")

			if charge == nil then
				return
			end

			charge.Parent = _WorldOrigin
			destroyAfter(charge, 1)

			for _, emitter in charge:GetDescendants(), nil, nil do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			destroyAfter(value, 0.1)
		end
	end
end