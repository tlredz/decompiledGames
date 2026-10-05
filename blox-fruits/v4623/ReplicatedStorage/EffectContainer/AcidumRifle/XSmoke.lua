local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local acid_X = FX:WaitForChild("AcidumRifle").Acid_X
workspace:WaitForChild("_WorldOrigin")

local function ParticleState(folder, enabled, p)
	for _, effect in pairs(folder:GetDescendants()) do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if p and effect:GetAttribute("Color") == true then
			effect.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
		end

		if enabled == nil then
			effect:Emit(effect:GetAttribute("EmitCount"))
		else
			effect.Enabled = enabled
		end
	end
end

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function ScaleTween(object, p: number, p2)
	local total = 0
	local lastTime = os.clock()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		local value = game.TweenService:GetValue(
			math.min(total / 15, 1),
			Enum.EasingStyle.Cubic,
			Enum.EasingDirection.Out
		)
		total += dt
		local scale = object:GetScale()
		object:ScaleTo(scale + (p - scale) * value)

		if object:GetScale() == p then
			heartbeatConnection:Disconnect()
		elseif p2 <= os.clock() - lastTime then
			heartbeatConnection:Disconnect()
		end
	end)
end

return function(data)
	local origin = data.origin
	local _ = data.dir

	if (currentCamera.CFrame.p - origin).Magnitude > 900 then
		return
	end

	local _ = data.projectileSpeed
	local projectileLifetime = data.projectileLifetime
	local folder = Instance.new("Folder")
	folder.Name = "AcidRifleX"
	folder.Parent = workspace._WorldOrigin
	local startCFrame = data.startCFrame
	local clone = acid_X.Acid:Clone()
	clone:PivotTo(startCFrame)
	local total = 0
	local lastTime = os.clock()
	local heartbeatConnection = nil
	local v = 1
	local v2 = 5
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		local value = game.TweenService:GetValue(
			math.min(total / 15, 1),
			Enum.EasingStyle.Cubic,
			Enum.EasingDirection.Out
		)
		total += dt
		local scale = clone:GetScale()
		clone:ScaleTo(scale + (v - scale) * value)

		if clone:GetScale() == v then
			heartbeatConnection:Disconnect()
		elseif v2 <= os.clock() - lastTime then
			heartbeatConnection:Disconnect()
		end
	end)
	local acidicSmoke = clone.AcidicSmoke
	acidicSmoke.CFrame = startCFrame
	clone.Parent = folder
	local lifetime = data.lifetime
	local _ = math.random(90, 110) / 100
	local v3 = false

	for _, effect in pairs(acidicSmoke:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = true
		end
	end

	if data.index == 1 then
		sound:Play(
			"BF_WPN_AcidiumRifle_AcidicSmokeFire_0" .. tostring(math.random(1, 2)) .. "_V2",
			acidicSmoke.Position
		)
	end

	task.delay(lifetime, function()
		if lifetime < projectileLifetime then
			local lastTime2 = os.clock()
			acidicSmoke.Position = data.hitbox.Position
			local cresents = acidicSmoke.Cresents

			for _, effect in pairs(cresents:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			acidicSmoke.Trail.Enabled = false

			if not v3 then
				v3 = sound:Play("BF_WPN_AcidiumRifle_AcidicSmokeFumes_01_V2", acidicSmoke)
			end

			for _, emitter in pairs(acidicSmoke:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Rate *= 0.6
				end
			end

			while os.clock() - lastTime2 < projectileLifetime - lifetime and data.hitbox and data.hitbox:IsDescendantOf(workspace) do
				acidicSmoke.Position = data.hitbox.Position
				task.wait()
			end
		end

		local folder2 = acidicSmoke

		for _, effect in pairs(folder2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		if v3 then
			sound:FadeOut(v3, 1)
		end
	end)
	TweenService:Create(acidicSmoke, TweenInfo.new(lifetime, Enum.EasingStyle.Linear), {
		Position = data.targetPosition
	}):Play()
	task.wait(8)
	folder:Destroy()
end