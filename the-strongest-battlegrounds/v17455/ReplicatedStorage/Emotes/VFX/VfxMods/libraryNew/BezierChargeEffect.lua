local createVector = vector.create
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("Debris")
local RunService = game:GetService("RunService")

local function getBezierCFrame(value: number, cframe: CFrame, cframe2: CFrame, cframe3: CFrame, cframe4: CFrame)
	local DISTANCE_EPSILON = 0.001
	local v = 1 - value
	local v2 = v * v
	local v3 = v2 * v
	local v4 = value * value
	local v5 = v4 * value
	local v6 = cframe.Position * v3 + cframe2.Position * (v2 * 3 * value) + cframe3.Position * (v * 3 * v4) + cframe4.Position * v5
	local unit = (cframe2.Position - cframe.Position) * (v2 * 3) + (cframe3.Position - cframe2.Position) * (v * 6 * value) + (cframe4.Position - cframe3.Position) * (v4 * 3)

	if unit.Magnitude < DISTANCE_EPSILON then
		if value < 0.5 then
			unit = (cframe2.Position - cframe.Position).Unit
		else
			unit = (cframe4.Position - cframe3.Position).Unit
		end

		if unit.Magnitude < DISTANCE_EPSILON then
			local v7 = cframe4.Position - cframe.Position
			unit = v7.Magnitude < DISTANCE_EPSILON and createVector(0, 0, -1) or v7
		end
	end

	return CFrame.lookAt(v6, v6 + unit)
end

return {
	Create = function(self: CFrame, options)
		local v = options or {}

		if typeof(self) ~= "CFrame" then
			warn("BezierChargeEffect.Create: 'targetCFrame' must be a CFrame value, but received an " .. typeof(self) .. ". Did you pass a Part/Instance instead of Part.CFrame?")
			return
		end

		local count = v.Count or 30
		local spawnRadius = v.SpawnRadius or 20
		local minDuration = v.MinDuration or 0.8
		local maxDuration = v.MaxDuration or 1.5
		local lifetime = v.Lifetime or 2
		local particleTemplate = v.ParticleTemplate
		local controlPointHeight = v.ControlPointHeight or 15
		local randomControlOffset = v.RandomControlOffset or 8
		local parent = v.Parent or workspace.Thrown
		local easingStyle = v.EasingStyle or Enum.EasingStyle.Quart
		local easingDirection = v.EasingDirection or Enum.EasingDirection.Out
		local spawnDelay = v.SpawnDelay or 0.05
		local colorSequence = v.ColorSequence
		local transparencySequence = v.TransparencySequence
		local swirlStrength = v.SwirlStrength or 0

		if particleTemplate and particleTemplate:IsA("BasePart") then
			for i = 1, count do
				local v2 = i
				task.spawn(function()
					if spawnDelay > 0 then
						task.wait(v2 * spawnDelay)
					end

					local clone = particleTemplate:Clone()
					game.Debris:AddItem(clone, lifetime)
					clone.Anchored = false
					clone.CanCollide = false
					clone.CanTouch = false
					clone.Massless = true
					clone.Parent = parent
					local v3 = Vector3.new(math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1).Unit * math.random(
						0,
						spawnRadius
					)
					local cframe2 = CFrame.new(self.Position + v3)
					clone.CFrame = cframe2
					local v4 = math.random(minDuration * 100, maxDuration * 100) / 100
					local v5 = self
					local lerped = cframe2:Lerp(v5, 0.5)
					local v6 = math.abs(randomControlOffset)
					local v7 = Vector3.new(math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1).Unit * (math.random() * v6)
					local v8 = Vector3.new(math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1).Unit * (math.random() * v6)
					local unit = (v5.Position - cframe2.Position).Unit
					local cross = unit:Cross(createVector(0, 1, 0))

					if cross.Magnitude < 0.001 then
						cross = unit:Cross(createVector(0, 0, -1))
					end

					local unit2 = cross.Unit
					local v9 = unit2 * (math.random() * 2 - 1) * swirlStrength
					local v10 = unit2 * (math.random() * 2 - 1) * swirlStrength
					local v11 = cframe2.Position:Lerp(lerped.Position, 0.3) + Vector3.new(0, controlPointHeight, 0) + v7 + v9
					local v12 = lerped.Position:Lerp(v5.Position, 0.7) + Vector3.new(0, controlPointHeight, 0) + v8 + v10
					local cframe3 = CFrame.new(v11)
					local cframe4 = CFrame.new(v12)
					local numberValue = Instance.new("NumberValue")
					numberValue.Value = 0
					numberValue.Parent = nil
					local tween = TweenService:Create(
						numberValue,
						TweenInfo.new(v4, easingStyle, easingDirection, 0, false, 0),
						{
							Value = 1
						}
					)
					local heartbeatConnection = nil
					heartbeatConnection = RunService.Heartbeat:Connect(function()
						if clone and clone.Parent and tween.PlaybackState == Enum.PlaybackState.Playing then
							clone.CFrame = getBezierCFrame(numberValue.Value, cframe2, cframe3, cframe4, v5)
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
							heartbeatConnection = nil
						end

						numberValue:Destroy()
					end)
				end)
			end
		else
			warn("BezierChargeEffect.Create: ParticleTemplate is required and must be a BasePart.")
		end
	end
}