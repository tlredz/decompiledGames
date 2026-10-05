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
FX:WaitForChild("Trident")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
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

local function AllVFX(items, enabled2, p2)
	local function Emit(folder, enabled, duration)
		for _, effect in ipairs(folder:GetDescendants()) do
			if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
				continue
			end

			effect.Enabled = enabled

			if not (duration and enabled and (effect.Rate <= 2 or effect.Name == "Ripplex")) then
				continue
			end

			effect.Enabled = false
			effect:Emit(1)
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

return function(data)
	local player = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	local parent = _WorldOrigin
	local cframe = CFrame.new(hrp.Position)
	local v2 = hrp.Size.Y * 0.5 + data.hum.HipHeight
	Util.Sound:Play("SharkmanC1", hrp, 20)
	Util.Sound:Play("WaterPulseCharge", hrp)
	local clone = FX:WaitForChild("Trident").Pull:Clone()
	clone.CFrame = cframe * CFrame.new(0, -v2 + 0.5, 0)
	clone.Parent = parent
	EmitAll(clone)
	destroyAfter(clone, 1.5)

	for i = 1, 4 do
		local clone2 = FX:WaitForChild("Trident")["Pulse Trail"]:Clone()
		clone2.CFrame = cframe
		clone2.Parent = parent
		AllVFX(clone2, true)
		local v3 = 0
		local v7 = 15 - i * 2
		local v8 = i * 1.5707963267948966
		local connection = RunService.Heartbeat:Connect(function(dt)
			v3 -= dt * 20
			clone2.CFrame = cframe + Vector3.new(v7 * math.sin(v3 + v8), 3, v7 * math.cos(v3 + v8))
		end)
		local v9 = clone2
		task.delay(0.68, function()
			connection:Disconnect()
			AllVFX(v9, false)
			destroyAfter(v9, 1)
		end)
	end

	task.wait(data.delayUntilExplosion)
	Util.Sound:Play("WaterPulseAttack", hrp.Position)
	Util.Sound:Play("SharkmanX", hrp.Position)
	task.delay(0.1, function()
		local clone2 = FX:WaitForChild("Trident")["Water Pulse"]:Clone()
		clone2.CFrame = cframe * CFrame.new(0, -v2 + 0.3, 0)
		clone2.Parent = parent
		AllVFX(clone2, true, 0.5)
		destroyAfter(clone2, 2)
	end)
	local clone2 = FX:WaitForChild("Trident")["Water Pulse Emit"]:Clone()
	clone2.CFrame = cframe * CFrame.new(0, -v2 + 0.3, 0)
	clone2.Parent = parent
	EmitAll(clone2)
	destroyAfter(clone2, 3)

	for _ = 1, 8 do
		local clone3 = FX:WaitForChild("Trident").Sphere:Clone()
		clone3.CFrame = cframe * CFrame.Angles(
			math.rad((math.random(-90, 90))),
			math.rad((math.random(-90, 90))),
			(math.rad((math.random(-90, 90))))
		)
		clone3.Size = Vector3.new(4, math.random(36, 48), 4)
		clone3.Color = Color3.fromRGB(135, 175, 255)
		clone3.Parent = parent
		local tween = TweenService:Create(clone3, TweenInfo.new(0.2), {
			Size = Vector3.new(0, math.random(12, 24), 0),
			CFrame = clone3.CFrame * CFrame.new(0, math.random(50, 80), 0)
		})
		tween:Play()
		tween:Destroy()
		destroyAfter(clone3, 0.2)
	end

	local v3 = cframe * CFrame.new(0, 60, 0)
	local clone3 = FX:WaitForChild("Trident").Sphere:Clone()
	clone3.CFrame = cframe * CFrame.new(0, -hrp.Size.Y / 2, 0)
	clone3.CFrame = CFrame.new(clone3.Position, v3.Position)
	clone3.Size = createVector(10, 10, 10)
	clone3.Color = Color3.fromRGB(135, 175, 255)
	clone3.Parent = parent
	local tween = TweenService:Create(clone3, TweenInfo.new(0.2), {
		Size = Vector3.new(0, 0, (clone3.Position - v3.Position).magnitude),
		CFrame = CFrame.new(clone3.Position, v3.Position) * CFrame.new(
			0,
			0,
			(clone3.Position - v3.Position).magnitude / -2
		)
	})
	tween:Play()
	tween:Destroy()
	destroyAfter(clone3, 0.2)

	if player == game.Players.LocalPlayer then
		Util.CameraShaker:ShakeOnce(8, 13, 0.2, 0.7)
	end
end