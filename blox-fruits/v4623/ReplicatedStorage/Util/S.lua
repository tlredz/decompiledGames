local createVector = vector.create
local TweenService = game:GetService("TweenService")
local random = Random.new()
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local S = {
	Random = function(p, p2)
		return random:NextInteger(p * 100, p2 * 100) / 100
	end,
	TimeScaleParticle = function(folder, p)
		for _, emitter in folder:GetDescendants() do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Drag *= p
			emitter.Speed = NumberRange.new(emitter.Speed.Min * p, emitter.Speed.Max * p)
			emitter.Lifetime = NumberRange.new(emitter.Lifetime.Min / p, emitter.Lifetime.Max / p)
			emitter.Rate *= p
			emitter.RotSpeed = NumberRange.new(emitter.RotSpeed.Min * p, emitter.RotSpeed.Max * p)
			emitter.Acceleration *= p ^ 2

			if emitter:GetAttribute("EmitDelay") then
				emitter:SetAttribute("EmitDelay", emitter:GetAttribute("EmitDelay") / p)
			end
		end
	end
}

function S.Rocks(p, p2, p3, p4, p5, p6, p7)
	local v = p7 or script.Rock

	for i = 1, p4 do
		if p6 < Random.new():NextNumber(0, 100) then
			continue
		end

		local v2 = 6.283185307179586 / p4 * i
		local v3 = p5 * math.cos(v2)
		local v4 = p5 * math.sin(v2)
		local ground = S.GetGround((p * CFrame.new(v3, p.Position.Y + 1, v4)).Position, 10)

		if not ground then
			continue
		end

		local clone = v:Clone()
		clone.Size = p2 * Vector3.new(S.Random(0.1, 2), S.Random(0.1, 2), S.Random(0.1, 2))
		clone.Position = ground.Position - Vector3.new(0, clone.Size.Y, 0)
		clone.Parent = workspace._WorldOrigin
		clone.Color = ground.Instance.Color
		clone.Material = ground.Instance.Material
		clone.CFrame = CFrame.lookAt(clone.Position, p.Position)
		TweenService:Create(
			clone,
			TweenInfo.new(S.Random(0.19, 0.28), Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
			{
				Position = ground.Position - Vector3.new(0, clone.Size.Y / 3, 0)
			}
		):Play()
		local v6 = ground
		task.delay(p3 * S.Random(0.95, 1.05), function()
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
				{
					Position = v6.Position - Vector3.new(0, clone.Size.Y * 2, 0)
				}
			)
			tween:Play()
			tween.Completed:Wait()
			clone:Destroy()
		end)
	end
end

function S.GetGround(p, value, filterDescendantsInstances)
	local v = value or 1000
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { workspace.Map }
	raycastParams.IgnoreWater = true

	if not filterDescendantsInstances then
		return (workspace:Raycast(p + createVector(0, 2, 0), createVector(0, -1, 0) * (v + 2), raycastParams))
	end

	table.insert(filterDescendantsInstances, workspace._WorldOrigin)
	table.insert(filterDescendantsInstances, workspace.Characters)
	table.insert(filterDescendantsInstances, workspace.Enemies)
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	return (workspace:Raycast(p + createVector(0, 2, 0), createVector(0, -1, 0) * (v + 2), raycastParams))
end

function S.EmitDescendants(emitter)
	coroutine.wrap(function()
		if emitter:IsA("ParticleEmitter") then
			local emitCount = emitter:GetAttribute("EmitCount") or 1
			local emitDelay = emitter:GetAttribute("EmitDelay") or nil

			if emitDelay then
				task.wait(emitDelay)
			end

			emitter:Emit(emitCount)
		else
			for _, emitter2 in pairs(emitter:GetDescendants()) do
				if not emitter2:IsA("ParticleEmitter") then
					continue
				end

				local v = emitter2
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
	end)()
end

function S.FadeOutDescendantLights(light, duration)
	if light:IsA("Light") then
		TweenService:Create(light, TweenInfo.new(duration), {
			Brightness = 0
		}):Play()
		return
	end

	for _, light2 in pairs(light:GetDescendants()) do
		if light2:IsA("Light") then
			TweenService:Create(light2, TweenInfo.new(duration), {
				Brightness = 0
			}):Play()
		end
	end
end

function S:DisableDescendantParticles()
	if self:IsA("ParticleEmitter") then
		self.Enabled = false
		return
	end

	for _, emitter2 in pairs(self:GetDescendants()) do
		if emitter2:IsA("ParticleEmitter") then
			emitter2.Enabled = false
		end
	end
end

function S:EnableDescendantParticles()
	if self:IsA("ParticleEmitter") then
		self.Enabled = true
		return
	end

	for _, effect in pairs(self:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = true
		end
	end
end

local RunService = game:GetService("RunService")
local time2 = RunService:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false and time or os.clock

function S.HeartbeatLoopFor(p: number, callback, callback2)
	local heartbeatConnection = nil
	local v = time2()
	local v2 = false
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		local v3 = time2() - v

		if v3 < p then
			callback(v3, dt, v3 / p)
		elseif v2 == true or callback2 == nil then
			if heartbeatConnection ~= nil then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end
		else
			v2 = true
			callback2()

			if heartbeatConnection ~= nil then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end
		end
	end)
	return heartbeatConnection
end

return S