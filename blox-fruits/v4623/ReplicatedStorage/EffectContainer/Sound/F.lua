local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
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
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
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

local v = {
	"rbxassetid://15027759463",
	"rbxassetid://15027789941",
	"rbxassetid://15027825628",
	"rbxassetid://15027945079",
	"rbxassetid://15028032254"
}
return function(data)
	local _ = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local parent = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 2500 then
		return
	end

	local _ = data.origin
	local _ = data.fireDir
	local initMaxTempoActive = data.initMaxTempoActive
	local maxTempoActive = data.maxTempoActive
	local v2 = nil

	if initMaxTempoActive == false then
		Assets = FX:WaitForChild("SoundEffects").Sound_F.Sound_F_NoTempo.Assets
		v2 = Util.Sound:Play("SoundFruitFNOTEMPO", hrp)
	elseif initMaxTempoActive == true then
		Assets = FX:WaitForChild("SoundEffects").Sound_F.Sound_F_MaxTempo.Assets
		v2 = Util.Sound:Play("SoundFruitFTEMPO", hrp)
	end

	local humanoid = parent:FindFirstChildOfClass("Humanoid")
	local _ = hrp.CFrame
	local lastTime = os.clock()
	local clone = Assets.wind:Clone()
	clone.Parent = _WorldOrigin
	local clone2 = Assets.sheet:Clone()
	clone2.Parent = _WorldOrigin

	while true do
		clone2.CFrame = hrp.CFrame * CFrame.new(0, -(humanoid.HipHeight + 0.7), -8.3)
		clone.CFrame = hrp.CFrame * CFrame.new(0, 0.3, 0)

		if os.clock() - lastTime > 0.5 then
			task.spawn(function()
				local v3 = math.random(0, 360)
				local v4 = math.random(2, 7)
				local v5 = math.random(-700, 700) / 100
				local v6 = time()

				for _ = 1, 600 do
					if not (v5 > -4) or not (v5 < 4) or time() - v6 > 10 then
						break
					end

					v5 = math.random(-700, 700) / 100
				end

				local cframe = CFrame.new(math.random(-6, 6), math.random(-6, 6), math.random(-8, 8))
				local clone3 = Assets.mini:Clone()
				task.delay(2, clone3.Destroy, clone3)
				math.random(1, 2)

				if initMaxTempoActive ~= false then
				end

				local v7 = math.random(1, 5)

				for _, effect in pairs(clone3:GetDescendants()) do
					if not (effect:IsA("Trail") or effect:IsA("ParticleEmitter")) then
						continue
					end

					effect.Enabled = true

					if effect.Parent ~= clone3.Main then
						continue
					end

					effect.Texture = v[v7]
					effect:Emit(1)
				end

				clone3.Trail.Lifetime = math.random(10, 50) / 100
				clone3.CFrame = hrp.CFrame * CFrame.new(math.random(-10, 10), math.random(-10, 10), 0)
				clone3.Parent = _WorldOrigin
				local lastTime2 = os.clock()
				local v8 = time()
				local v9 = 0.016666666666666666

				for _ = 1, 600 do
					if not (os.clock() - lastTime2 <= math.random(100, 130) / 100) or time() - v8 > 10 then
						break
					end

					clone3.CFrame = hrp.CFrame * cframe * CFrame.new(
						math.sin((math.rad(v3))) * v4 * 2,
						math.cos((math.rad(v3))) * v4,
						math.sin((math.rad(v3))) * v4
					)
					v3 += v5 * v9 * 150

					if data.inputHeld == nil or data.inputHeld.Parent == nil or data.inputHeld.Value == false or maxTempoActive.Value ~= initMaxTempoActive then
						break
					else
						v9 = task.wait()
					end
				end

				for _, effect in clone3:GetDescendants(), nil, nil do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end
			end)
			lastTime = os.clock()
		end

		task.wait()

		if not (data.inputHeld == nil or data.inputHeld.Parent == nil or data.inputHeld.Value == false or maxTempoActive.Value ~= initMaxTempoActive) then
			continue
		end

		Util.Sound:FadeOut(v2, 0.5)

		for _, emitter in clone:GetDescendants(), nil, nil do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, effect in clone2:GetDescendants(), nil, nil do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		task.wait(2)
		clone:Destroy()
		clone2:Destroy()
		break
	end
end