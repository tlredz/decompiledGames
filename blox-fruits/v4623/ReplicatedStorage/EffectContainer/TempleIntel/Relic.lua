local createVector = vector.create
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local function resolveConfig(data)
	if type(data.Config) == "table" then
		return data.Config
	end

	local bonusMoments = ReplicatedStorage:FindFirstChild("BonusMoments")
	local templeIntel

	if bonusMoments then
		templeIntel = bonusMoments:FindFirstChild("Temple Intel")
	end

	local puzzleConfig

	if templeIntel then
		puzzleConfig = templeIntel:FindFirstChild("PuzzleConfig")
	end

	if not (puzzleConfig and puzzleConfig:IsA("ModuleScript")) then
		warn("[Temple Intel] PuzzleConfig not reachable from the client")
		return nil
	end

	local success, result = pcall(require, puzzleConfig)

	if success then
		return result
	end

	warn((`[Temple Intel] PuzzleConfig failed to load: {result}`))
	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function smootherstep(value: number)
	local v = math.clamp(value, 0, 1)
	return v * v * v * (v * (v * 6 - 15) + 10)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function easeOut(value: number)
	local v = math.clamp(value, 0, 1)
	return 1 - (1 - v) * (1 - v) * (1 - v)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function easeIn(value: number)
	local v = math.clamp(value, 0, 1)
	return v * v
end

local function noiseOffset(p: number, p2: number, p3: number)
	return Vector3.new(
		math.noise(p * p2, 0, 0),
		math.noise(0, p * p2 * 0.7, 12.3) * 0.6,
		math.noise(0, 0, p * p2 + 5.1)
	) * p3
end

return function(data)
	if not data then
		return
	end

	local templeIntelRelic = Lighting:FindFirstChild("TempleIntelRelic")

	if data.Remove == true then
		if templeIntelRelic then
			templeIntelRelic:Destroy()
		end
	elseif data.Finale == true then
		if templeIntelRelic then
			local v2

			if typeof(data.StartedAt) == "number" then
				v2 = data.StartedAt
			else
				v2 = os.clock()
			end

			templeIntelRelic:SetAttribute("StartedAt", v2)
		end
	else
		if templeIntelRelic then
			return
		end

		local relic = data.Relic

		if typeof(relic) ~= "Instance" or not relic:IsA("BasePart") then
			return
		end

		local config = resolveConfig(data)
		local relic2

		if config then
			relic2 = config.Relic
		else
			relic2 = nil
		end

		if not (relic2 and relic2.Enabled) then
			return
		end

		local relicFinale = config.RelicFinale or {
			Enabled = false
		}
		local localPlayer = Players.LocalPlayer
		local cFrame = relic.CFrame
		local position = cFrame.Position
		local v = cFrame - position
		local v2 = relic.Size.Y / 2
		local orbitRadius = relicFinale.OrbitRadius or 0

		if orbitRadius <= 0 then
			local ring = data.Ring
			local total = 0
			local count = 0

			if typeof(ring) == "Instance" then
				for _, child in ring:GetChildren() do
					local child2 = child:FindFirstChild(config.PointPath[1])
					local attachment = child2 and child2:FindFirstChild(config.PointPath[2])

					if not (attachment and attachment:IsA("Attachment")) then
						continue
					end

					local v3 = attachment.WorldPosition - position
					total += Vector3.new(v3.X, 0, v3.Z).Magnitude
					count += 1
				end
			end

			if count > 0 then
				orbitRadius = total / count
			else
				orbitRadius = 20
			end
		end

		local shakeTime = relicFinale.ShakeTime or 0
		local v3 = shakeTime + (relicFinale.RiseTime or 0)
		local v4 = v3 + (relicFinale.OrbitTime or 0)
		local v5 = v4 + (relicFinale.BurstTime or 0)
		local v6 = v5 + (relicFinale.ApproachTime or 0)
		local v7 = v6 + (relicFinale.HoverTime or 0)
		local v8 = v7 + (relicFinale.AlignTime or 0)
		local v9 = v8 + (relicFinale.DropTime or 0)
		local v10 = v9 + (relicFinale.BounceTime or 0)
		local v11 = position.Y + (relicFinale.RiseHeight or 0)
		local folder = Instance.new("Folder")
		folder.Name = "TempleIntelRelic"
		folder.Parent = Lighting
		local v12 = nil
		local v13 = nil
		local cFrame2 = nil
		local v15 = nil
		local flag = false
		local character = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function finaleOwnerLost()
			local v16 = character

			if not v16 or v16 ~= localPlayer.Character or not v16.Parent then
				return true
			end

			local humanoid = v16:FindFirstChildOfClass("Humanoid")
			return humanoid == nil or humanoid.Health <= 0
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function rootPosition()
			local v16 = character or localPlayer.Character
			local humanoidRootPart = v16 and v16:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
				return humanoidRootPart.Position
			end

			return nil
		end

		local function handPosition()
			local v16 = character or localPlayer.Character

			if not v16 then
				return nil
			end

			local rightHand = v16:FindFirstChild("RightHand") or v16:FindFirstChild("Right Arm")

			if rightHand and rightHand:IsA("BasePart") then
				return rightHand.Position + Vector3.new(0, relicFinale.HandOffset or 0.5, 0)
			end

			return nil
		end

		local function updateTarget(p: number)
			local v16 = rootPosition() -- equivalent call inferred; original call site unknown
			local v17 = (v16 or position) + Vector3.new(0, relicFinale.HoverHeight or 12, 0)

			if v12 then
				v12 = v12:Lerp(v17, (math.min(p * 3.5, 1)))
			else
				v12 = v17
			end

			return v12
		end

		local function groundUnder(vector2: Vector3)
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = { relic.Parent, localPlayer.Character }
			local raycastResult = workspace:Raycast(vector2, createVector(0, -500, 0), raycastParams)
			return (not raycastResult and 0 or raycastResult.Position.Y) + v2
		end

		local function catchPoint()
			local v16 = relicFinale.LandInHand and handPosition()

			if v16 then
				return v16
			end

			local v17 = v12 or position
			return (Vector3.new(v17.X, groundUnder(v17), v17.Z))
		end

		local function pose(p: number, dt: number)
			local v16 = 0
			local vector2, v17

			if p < shakeTime then
				local v18 = not (shakeTime > 0) and 1 or p / shakeTime
				local shakeFrequency = relicFinale.ShakeFrequency or 22
				local shakeAmplitude = relicFinale.ShakeAmplitude or 0.3
				vector2 = position + noiseOffset(p, shakeFrequency, shakeAmplitude * smootherstep(v18))
				v17 = smootherstep(v18) * 120
			elseif p < v3 then
				local v18 = smootherstep((p - shakeTime) / math.max(relicFinale.RiseTime or 0.001, 0.001)) -- equivalent call inferred; original call site unknown
				vector2 = position + Vector3.new(0, (v11 - position.Y) * v18, 0) + noiseOffset(
					p,
					relicFinale.ShakeFrequency or 22,
					(relicFinale.ShakeAmplitude or 0.3) * (1 - v18)
				)
				v17 = v18 * 200 + 120
			elseif p < v4 then
				local v18 = (p - v3) / math.max(relicFinale.OrbitTime or 0.001, 0.001)
				local v19 = smootherstep(v18) -- equivalent call inferred; original call site unknown
				local v20 = v19 * (relicFinale.Revolutions or 3) * 6.283185307179586
				local v21 = math.max(relicFinale.OrbitEdge or 0.25, 0.01)
				local v24 = orbitRadius * smootherstep(math.min(v18 / v21, 1)) * smootherstep(math.min(
					(1 - v18) / v21,
					1
				))
				local v25 = math.sin(v18 * (relicFinale.WaveCycles or 3) * 6.283185307179586) * (relicFinale.WaveHeight or 2.5) * math.sin(v18 * 3.141592653589793)
				vector2 = Vector3.new(position.X + math.cos(v20) * v24, v11 + v25, position.Z + math.sin(v20) * v24)
				v17 = 320 + v19 * (relicFinale.SpinDegrees or 900)
				v16 = (relicFinale.BankAngle or 25) * math.sin(v18 * 3.141592653589793)
				local v26 = rootPosition() -- equivalent call inferred; original call site unknown
				local v27 = (v26 or position) + Vector3.new(0, relicFinale.HoverHeight or 12, 0)

				if v12 then
					v12 = v12:Lerp(v27, (math.min(dt * 3.5, 1)))
				else
					v12 = v27
				end
			elseif p < v5 then
				local v18 = math.max(relicFinale.BurstTime or 0.001, 0.001)
				local v19 = (p - v4) / v18
				local v20 = math.clamp((relicFinale.BurstDelay or 0) / v18, 0, 1)
				local v21 = smootherstep(math.clamp(v19 / math.max(v20, 0.001), 0, 1)) -- equivalent call inferred; original call site unknown
				local v22 = math.clamp((v19 - v20) / math.max(1 - v20, 0.001), 0, 1)
				local v23 = v21 * -0.5 * (1 - v22)
				local v24 = math.sin(v22 * 3.141592653589793) * 1.4 * (1 - v22 * 0.4)
				vector2 = Vector3.new(position.X, v11, position.Z) + Vector3.new(0, v23 + v24, 0) + noiseOffset(
					p,
					40,
					v21 * 0.22 * (1 - v22)
				)
				v17 = 320 + (relicFinale.SpinDegrees or 900) + v19 * 200
				local v25 = rootPosition() -- equivalent call inferred; original call site unknown
				local v26 = (v25 or position) + Vector3.new(0, relicFinale.HoverHeight or 12, 0)

				if v12 then
					v12 = v12:Lerp(v26, (math.min(dt * 3.5, 1)))
				else
					v12 = v26
				end
			elseif p < v6 then
				local v18 = rootPosition() -- equivalent call inferred; original call site unknown
				local v19 = (v18 or position) + Vector3.new(0, relicFinale.HoverHeight or 12, 0)

				if v12 then
					v12 = v12:Lerp(v19, (math.min(dt * 3.5, 1)))
				else
					v12 = v19
				end

				local v20 = v12
				local v21 = smootherstep((p - v5) / math.max(relicFinale.ApproachTime or 0.001, 0.001)) -- equivalent call inferred; original call site unknown
				vector2 = Vector3.new(position.X, v11, position.Z):Lerp(v20, v21) + Vector3.new(
					0,
					(relicFinale.ApproachArc or 9) * math.sin(v21 * 3.141592653589793) ^ 2,
					0
				)
				v17 = 320 + (relicFinale.SpinDegrees or 900) + 200 + v21 * 240
			elseif p < v7 then
				local v18 = rootPosition() -- equivalent call inferred; original call site unknown
				local v19 = (v18 or position) + Vector3.new(0, relicFinale.HoverHeight or 12, 0)

				if v12 then
					v12 = v12:Lerp(v19, (math.min(dt * 3.5, 1)))
				else
					v12 = v19
				end

				local v20 = v12
				local v21 = (p - v6) / math.max(relicFinale.HoverTime or 0.001, 0.001)
				local v22 = math.sin(v21 * 6.283185307179586) * 0.35
				vector2 = v20 + Vector3.new(0, v22 * easeOut(v21), 0)
				v17 = 320 + (relicFinale.SpinDegrees or 900) + 440 + v21 * 120
			elseif p < v8 then
				local v18 = rootPosition() -- equivalent call inferred; original call site unknown
				local v19 = (v18 or position) + Vector3.new(0, relicFinale.HoverHeight or 12, 0)

				if v12 then
					v12 = v12:Lerp(v19, (math.min(dt * 3.5, 1)))
				else
					v12 = v19
				end

				local v20 = v12
				local v21 = (p - v7) / math.max(relicFinale.AlignTime or 0.001, 0.001)
				local alignRise = relicFinale.AlignRise or 7
				vector2 = v20 + Vector3.new(0, alignRise * smootherstep(v21), 0) + Vector3.new(
					0,
					math.sin(v21 * 6.283185307179586 * 2) * 0.25 * (1 - v21),
					0
				) + noiseOffset(p, 30, 0.18 * v21)
				v17 = 320 + (relicFinale.SpinDegrees or 900) + 560 + v21 * 260
			elseif p < v9 then
				if not v13 then
					v13 = v15 or v12 or position
				end

				local v18 = easeIn((p - v8) / math.max(relicFinale.DropTime or 0.001, 0.001)) -- equivalent call inferred; original call site unknown
				local v19 = v13
				local vector3 = relicFinale.LandInHand and handPosition()

				if not vector3 then
					local v20 = v12 or position
					vector3 = Vector3.new(v20.X, groundUnder(v20), v20.Z)
				end

				vector2 = v19:Lerp(vector3, v18)
				v17 = 320 + (relicFinale.SpinDegrees or 900) + 820 + v18 * 180
			else
				if not (p < v10) then
					return nil
				end

				local v18 = (p - v9) / math.max(relicFinale.BounceTime or 0.001, 0.001)
				local v19 = math.sin(v18 * 3.141592653589793) * (relicFinale.BounceHeight or 0.5) * (1 - v18)
				local vector3 = relicFinale.LandInHand and handPosition()

				if not vector3 then
					local v20 = v12 or position
					vector3 = Vector3.new(v20.X, groundUnder(v20), v20.Z)
				end

				vector2 = vector3 + Vector3.new(0, v19, 0)
				v17 = 320 + (relicFinale.SpinDegrees or 900) + 1000
			end

			v15 = vector2
			return CFrame.new(vector2) * v * CFrame.Angles(0, math.rad(v17), (math.rad(v16)))
		end

		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
			if not (folder.Parent and relic.Parent) then
				renderSteppedConnection:Disconnect()
				return
			end

			local startedAt = folder:GetAttribute("StartedAt")

			if flag then
				renderSteppedConnection:Disconnect()
			elseif typeof(startedAt) == "number" then
				if not character then
					character = localPlayer.Character
				end

				-- equivalent call inferred; original call site unknown
				if finaleOwnerLost() then
					folder:SetAttribute("StartedAt", nil)
					character = nil
					v12 = nil
					v13 = nil
					v15 = nil
					relic.CFrame = cFrame
				else
					local cFrame3 = pose(os.clock() - startedAt, dt)

					if cFrame3 then
						relic.CFrame = cFrame3
						return
					end

					local vector2 = relicFinale.LandInHand and handPosition()

					if not vector2 then
						local v17 = v12 or position
						vector2 = Vector3.new(v17.X, groundUnder(v17), v17.Z)
					end

					cFrame2 = CFrame.new(vector2) * v
					relic.CFrame = cFrame2
					flag = true
				end
			else
				character = nil
				local now = os.clock()
				local v16 = math.sin(now * 6.283185307179586 / relic2.Period) * relic2.Height
				relic.CFrame = CFrame.new(position + Vector3.new(0, v16, 0)) * v * CFrame.Angles(
					0,
					math.rad(relic2.Spin) * now,
					0
				)
			end
		end)
	end
end