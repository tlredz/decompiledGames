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
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor

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

local function AllVFX(items, enabled2, p2)
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

	if typeof(items) ~= "table" then
		Emit(items, enabled2, p2)
		return
	end

	for _, item in items do
		Emit(item, enabled2, p2)
	end
end

return function(data)
	local _ = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local parent = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	local effectId = data.EffectId or data.EffectID

	if effectId then
		if data.skillHeld then
			local clone = FX:WaitForChild("Koko")["Injection Shot"].Aim:Clone()
			clone.Name = "Koko2" .. effectId
			clone.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = clone
			weldConstraint.Part1 = hrp
			weldConstraint.Parent = clone
			clone.Parent = _WorldOrigin
			AllVFX(clone, true)

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(1)
				end
			end

			local tween = TweenService:Create(clone.Attachment.PointLight, TweenInfo.new(0.4), {
				Brightness = 3,
				Range = 10
			})
			tween:Play()
			tween:Destroy()
			clone.Attachment["1"].Enabled = false
			local v = Util.Sound:Play("ElectricLoopable", hrp, 10)
			local now = 0

			while clone and clone.Parent and clone:IsDescendantOf(Workspace) and parent:IsDescendantOf(Workspace) do
				if tick() - now > 0.5 then
					now = tick()
					clone.Attachment["1"]:Emit(1)
				end

				task.wait(0.1)
			end

			Util.Sound:FadeOut(v, 0.25)
		else
			local child = _WorldOrigin:FindFirstChild("Koko2" .. effectId)

			if child then
				child.WeldConstraint:Destroy()
				child.Anchored = true
				AllVFX(child, false)
				destroyAfter(child, 2)
				local tween = TweenService:Create(child.Attachment.PointLight, TweenInfo.new(0.2), {
					Brightness = 0,
					Range = 0
				})
				tween:Play()
				tween:Destroy()
				task.wait(0.2)
				child:Destroy()
			end
		end
	end
end