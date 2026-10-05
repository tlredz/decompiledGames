local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local yamaSkill1 = FX:WaitForChild("Yama").YamaSkill1
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

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local origin = data.origin
	local _ = data.fireDir

	if player == localPlayer then
		Util.CameraShaker:ShakeOnce(8, 14, 0.2, 0.7)
	end

	local parent = _WorldOrigin
	local cframe = CFrame.lookAt(origin, data.dashTargetPos)
	local magnitude = (data.dashTargetPos - origin).Magnitude
	local clone = yamaSkill1.Slash:Clone()
	clone.CFrame = cframe * CFrame.new(0, 0, -magnitude)
	clone.Massless = true
	clone.Parent = parent
	clone.Weld.Part0 = hrp
	clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.Angles(
		0,
		0,
		0.17453292519943295
	)

	for _, effect in ipairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = true
		elseif effect:IsA("Beam") then
			local tween = TweenService:Create(
				effect,
				TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					Width0 = effect.Width0,
					Width1 = effect.Width1
				}
			)
			effect.Width0 = 0
			effect.Width1 = 0
			tween:Play()
		end
	end

	task.wait()
	coroutine.wrap(function()
		local v2 = true
		coroutine.wrap(function()
			local clone2 = yamaSkill1.GroundSparks:Clone()
			clone2.CFrame = cframe
			clone2.Massless = true
			clone2.Parent = parent
			clone2.Weld.Part0 = hrp
			clone2.Weld.Enabled = true
			local v3 = time()

			for _ = 1, 600 do
				clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.Angles(
					0,
					-0.4363323129985824,
					0
				)
				local position = clone2.Position
				local part, _ = Workspace:FindPartOnRayWithIgnoreList(
					Ray.new(
						position + createVector(0, 1, 0),
						CFrame.new(position + createVector(0, 1, 0), position + createVector(0, -10, 0)).LookVector * 10
					),
					raycastParams.FilterDescendantsInstances
				)

				if part then
					for _, emitter in ipairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end
				else
					for _, emitter in ipairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end

				task.wait()

				if v2 == false or time() - v3 > 10 then
					break
				end
			end

			for _, emitter in ipairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			destroyAfter(clone2, 2)
			destroyAfter(clone, 2)
		end)()
		task.wait(data.dashFor)

		for _, effect in ipairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = false
			elseif effect:IsA("Beam") then
				TweenService:Create(effect, TweenInfo.new(0.15), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end
		end

		v2 = false
	end)()
	task.wait(0.2 + data.dashFor)
end