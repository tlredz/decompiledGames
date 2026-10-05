local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Particles = {
	enable = function(effect, _: number)
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam") then
			effect.Enabled = true
		end

		for _, effect2 in effect:GetDescendants() do
			if not (effect2:IsA("ParticleEmitter") or effect2:IsA("Trail") or effect2:IsA("Beam")) then
				continue
			end

			effect2.Enabled = true
		end
	end,
	disable = function(effect)
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam") then
			effect.Enabled = false
		end

		for _, effect2 in effect:GetDescendants() do
			if not (effect2:IsA("ParticleEmitter") or effect2:IsA("Trail") or effect2:IsA("Beam")) then
				continue
			end

			effect2.Enabled = false
		end
	end,
	emit = function(folder)
		for _, emitter in folder:GetDescendants() do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local emitDelay = emitter:GetAttribute("EmitDelay")
			-- equivalent calls inferred from this helper; original call sites unknown
			local v = emitter

			local function doEmit()
				local emitCount = v:GetAttribute("EmitCount")

				if typeof(emitCount) == "number" then
					v:Emit(emitCount)
				end
			end

			if typeof(emitDelay) == "number" and emitDelay > 0 then
				task.delay(emitDelay, doEmit)
			else
				doEmit() -- equivalent call inferred; original call site unknown
			end
		end
	end,
	slowmo = function(folder, p, timeScale: number)
		for _, emitter in folder:GetDescendants() do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter:SetAttribute("TimeScale", emitter.TimeScale)
			TweenService:Create(emitter, p, {
				TimeScale = timeScale
			}):Play()
		end
	end,
	resetTimeScale = function(folder)
		for _, emitter in folder:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.TimeScale = emitter:GetAttribute("TimeScale") or 1
			end
		end
	end,
	bezierCharge = {}
}

local function getBezierCFrame(value: number, cframe: CFrame, cframe2: CFrame, cframe3: CFrame, cframe4: CFrame)
	local v = 1 - value
	local v2 = v * v
	local v3 = v2 * v
	local v4 = value * value
	local v5 = v4 * value
	local v6 = cframe.Position * v3 + cframe2.Position * (v2 * 3 * value) + cframe3.Position * (v * 3 * v4) + cframe4.Position * v5
	local v7 = (cframe2.Position - cframe.Position) * (v2 * 3) + (cframe3.Position - cframe2.Position) * (v * 6 * value) + (cframe4.Position - cframe3.Position) * (v4 * 3)

	if v7.Magnitude < 0.001 then
		local v8 = cframe4.Position - cframe.Position
		v7 = v8.Magnitude < 0.001 and createVector(0, 0, -1) or v8
	end

	return CFrame.lookAt(v6, v6 + v7)
end

function Particles.bezierCharge.emit(cframe: CFrame, options)
	local v = options or {}

	if typeof(cframe) ~= "CFrame" then
		warn("bezierCharge.emit: targetCFrame must be a CFrame")
		return
	end

	local particleTemplate = v.ParticleTemplate

	if not (particleTemplate and particleTemplate:IsA("BasePart")) then
		warn("bezierCharge.emit: ParticleTemplate BasePart is required")
		return
	end

	local count = v.Count or 30
	local parent = v.Parent or workspace:FindFirstChild("Thrown") or workspace
	local spawnRadius = v.SpawnRadius or 20
	local minDuration = v.MinDuration or 0.8
	local maxDuration = v.MaxDuration or 1.5
	local lifetime = v.Lifetime or 2
	local controlPointHeight = v.ControlPointHeight or 15
	local randomControlOffset = math.abs(v.RandomControlOffset or 8)
	local easingStyle = v.EasingStyle or Enum.EasingStyle.Quart
	local easingDirection = v.EasingDirection or Enum.EasingDirection.Out
	local spawnDelay = v.SpawnDelay or 0.05
	local colorSequence = v.ColorSequence
	local transparencySequence = v.TransparencySequence
	local swirlStrength = v.SwirlStrength or 0

	for i = 1, count do
		local v2 = i
		task.spawn(function()
			if spawnDelay > 0 then
				task.wait(v2 * spawnDelay)
			end

			local clone = particleTemplate:Clone()
			clone.Anchored = false
			clone.CanCollide = false
			clone.CanTouch = false
			clone.Massless = true
			clone.Parent = parent
			local v3 = Vector3.new(math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1).Unit * math.random(
				0,
				spawnRadius
			)
			local cframe2 = CFrame.new(cframe.Position + v3)
			clone.CFrame = cframe2
			local v4 = cframe
			local lerped = cframe2:Lerp(v4, 0.5)
			local v5 = Vector3.new(math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1).Unit * (math.random() * randomControlOffset)
			local v6 = Vector3.new(math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1).Unit * (math.random() * randomControlOffset)
			local unit = (v4.Position - cframe2.Position).Unit
			local cross = unit:Cross(createVector(0, 1, 0))

			if cross.Magnitude < 0.001 then
				cross = unit:Cross(createVector(0, 0, -1))
			end

			local unit2 = cross.Unit
			local cframe3 = CFrame.new(cframe2.Position:Lerp(lerped.Position, 0.3) + Vector3.new(
				0,
				controlPointHeight,
				0
			) + v5 + unit2 * ((math.random() * 2 - 1) * swirlStrength))
			local cframe4 = CFrame.new(lerped.Position:Lerp(v4.Position, 0.7) + Vector3.new(0, controlPointHeight, 0) + v6 + unit2 * ((math.random() * 2 - 1) * swirlStrength))
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = 0
			local tween = TweenService:Create(
				numberValue,
				TweenInfo.new(math.random(minDuration * 100, maxDuration * 100) / 100, easingStyle, easingDirection),
				{
					Value = 1
				}
			)
			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				if clone.Parent and tween.PlaybackState == Enum.PlaybackState.Playing then
					clone.CFrame = getBezierCFrame(numberValue.Value, cframe2, cframe3, cframe4, v4)
				elseif heartbeatConnection then
					heartbeatConnection:Disconnect()
					heartbeatConnection = nil
				end
			end)
			local trail = colorSequence and clone:FindFirstChildOfClass("Trail")

			if trail then
				trail.Color = colorSequence
			end

			local trail2 = transparencySequence and clone:FindFirstChildOfClass("Trail")

			if trail2 then
				trail2.Transparency = transparencySequence
			end

			tween:Play()
			tween.Completed:Connect(function()
				if heartbeatConnection then
					heartbeatConnection:Disconnect()
				end

				numberValue:Destroy()
			end)
			Debris:AddItem(clone, lifetime)
		end)
	end
end

return Particles