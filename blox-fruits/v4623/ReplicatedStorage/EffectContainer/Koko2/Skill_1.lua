local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
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

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }
return function(data)
	local _ = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	local effectId = data.EffectId or data.EffectID

	if effectId then
		if data.skillHeld then
			if Workspace:Raycast(hrp.Position, createVector(-0, -7.5, -0), raycastParams) then
				local name = "Koko1" .. effectId
				local clone = FX:WaitForChild("Koko")["Electric Stab"]:Clone()
				clone.Name = name
				clone:PivotTo(hrp.CFrame)
				local weldConstraint = Instance.new("WeldConstraint")
				weldConstraint.Name = "WeldConstraint"
				local primaryPart = clone.PrimaryPart
				weldConstraint.Part0 = hrp
				weldConstraint.Part1 = primaryPart
				weldConstraint.Parent = clone.PrimaryPart
				clone.Parent = _WorldOrigin
				task.spawn(function()
					local v2 = {}

					for i = 1, 2 do
						local v3 = clone.PrimaryPart["Hold" .. i]

						for _, child in pairs(v3:GetChildren()) do
							v2[child] = child.Name == "RealisticSmoke" and 1 or math.floor(child.Rate * 0.2)
						end
					end

					local v3 = Util.Sound:Play("ElectricLoopable", hrp, 10)

					while clone and clone:IsDescendantOf(Workspace) and clone.Name == name do
						for k, v4 in pairs(v2) do
							k:Emit(v4)
						end

						task.wait(0.1)
					end

					Util.Sound:FadeOut(v3, 0.25)
				end)
			end
		else
			local folder = _WorldOrigin:FindFirstChild("Koko1" .. effectId)

			if folder then
				folder.Name = "DESTROYING"
				local v = 0

				for _, emitter in pairs(folder:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					v = math.max(v, emitter.Lifetime.Max)
					emitter.Enabled = false
				end

				folder.PrimaryPart.WeldConstraint:Destroy()
				folder.PrimaryPart.Anchored = true
				task.wait(v)
				folder:Destroy()
			end
		end
	end
end