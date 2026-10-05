local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local FX = require(ReplicatedStorage:WaitForChild("FX"))

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

return function(data)
	if not data then
		return
	end

	local templeIntelFinale = Lighting:FindFirstChild("TempleIntelFinale")

	if data.Remove == true then
		if templeIntelFinale then
			templeIntelFinale:Destroy()
		end
	elseif data.PowerDown == true then
		if templeIntelFinale then
			templeIntelFinale:SetAttribute("PoweredDown", true)
		end
	else
		if templeIntelFinale then
			return
		end

		local relic = data.Relic
		local ring = data.Ring

		if typeof(relic) ~= "Instance" or not relic:IsA("BasePart") or typeof(ring) ~= "Instance" then
			return
		end

		local config = resolveConfig(data)

		if not config then
			return
		end

		local relicFinale = config.RelicFinale or {}
		local coilSpin = config.CoilSpin or {}
		local shockwave = config.Shockwave or {}
		local coilAlign = config.CoilAlign or {}

		if shockwave.Enabled then
			task.spawn(function()
				FX:Get("Lightning2")
			end)
		end

		if not (coilSpin.Enabled or shockwave.Enabled) then
			return
		end

		local startedAt

		if typeof(data.StartedAt) == "number" then
			startedAt = data.StartedAt
		else
			startedAt = os.clock()
		end

		local position = relic.Position
		local v = (relicFinale.ShakeTime or 0) + (relicFinale.RiseTime or 0)
		local v2 = v + (relicFinale.OrbitTime or 0)
		local v3 = v2 + (relicFinale.BurstTime or 0) + (relicFinale.ApproachTime or 0) + (relicFinale.HoverTime or 0)
		local v4 = v3 + (relicFinale.AlignTime or 0)
		local v5 = v2 + (relicFinale.BurstDelay or 0)
		local folder = Instance.new("Folder")
		folder.Name = "TempleIntelFinale"
		folder.Parent = Lighting
		local cFramesByPart = {}
		local v6 = {}

		for _, model in ring:GetChildren() do
			if not model:IsA("Model") then
				continue
			end

			local part = model:FindFirstChild(coilSpin.PartName or "teslaCoil")

			if part and part:IsA("BasePart") then
				cFramesByPart[part] = part.CFrame
			end

			local part2 = model:FindFirstChild(coilAlign.PartName or "relic")

			if not (part2 and part2:IsA("BasePart")) then
				continue
			end

			local cFrame = part2.CFrame
			local lookVector = cFrame.LookVector
			local v7 = position - cFrame.Position
			v6[part2] = {
				base = cFrame,
				delta = (math.atan2(v7.X, v7.Z) - math.atan2(lookVector.X, lookVector.Z) + 3.141592653589793) % 6.283185307179586 - 3.141592653589793
			}
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function fireShockwave()
			if not shockwave.Enabled then
				return
			end

			local cframe = CFrame.new(relic.Position)
			task.spawn(function()
				local lightning = FX:Get("Lightning2")
				local Z = lightning and lightning:FindFirstChild("Z")
				local assets = Z and Z:FindFirstChild("Assets")
				local phase1 = assets and assets:FindFirstChild("Phase1")
				local explosion = phase1 and phase1:FindFirstChild("Explosion")

				if not explosion then
					warn("[Temple Intel] Lightning2.Z Phase1.Explosion asset missing")
					return
				end

				local clone = explosion:Clone()
				clone.CFrame = cframe
				clone.Parent = workspace:FindFirstChild("_WorldOrigin") or workspace
				local v7 = 0

				for _, emitter in clone:GetDescendants() do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					v7 = math.max(v7, emitter.Lifetime.Max)
					local emitDelay = emitter:GetAttribute("EmitDelay") or 0
					local emitCount = emitter:GetAttribute("EmitCount") or 1
					local v9 = emitter
					task.spawn(function()
						if emitDelay > 0 then
							task.wait(emitDelay)
						end

						if v9.Parent then
							v9:Emit(emitCount)
						end
					end)
				end

				Debris:AddItem(clone, v7 + 1)
			end)
		end

		local function spinProfile(p: number)
			local idleFactor = coilSpin.IdleFactor or 0.15

			if p < v then
				return smootherstep(p / math.max(v, 0.001)) * idleFactor
			end

			if not (p < v2) then
				return 1
			end

			local v7 = (p - v) / math.max(relicFinale.OrbitTime or 0.001, 0.001)

			if v7 >= 0.5 then
				return 1
			end

			return idleFactor + (1 - idleFactor) * (30 * v7 * v7 * (1 - v7) * (1 - v7) / 1.875)
		end

		local total = 0
		local v7 = 1
		local v8 = false
		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
			if not (folder.Parent and relic.Parent) then
				renderSteppedConnection:Disconnect()
				return
			end

			local v9 = os.clock() - startedAt

			if folder:GetAttribute("PoweredDown") then
				v7 = math.max(v7 - dt / math.max(coilSpin.StopTime or 0.5, 0.01), 0)
			end

			total += dt * math.rad(coilSpin.MaxSpeed or 260) * spinProfile(v9) * v7

			for k, v10 in cFramesByPart do
				if k.Parent then
					k.CFrame = v10 * CFrame.Angles(0, total, 0)
				end
			end

			if coilAlign.Enabled and v3 <= v9 then
				local v10 = smootherstep((v9 - v3) / math.max(relicFinale.AlignTime or 0.001, 0.001)) -- equivalent call inferred; original call site unknown

				for k, v11 in v6 do
					if k.Parent then
						k.CFrame = v11.base * CFrame.Angles(0, v11.delta * v10, 0)
					end
				end
			end

			if not v8 and v5 <= v9 then
				v8 = true
				fireShockwave() -- equivalent call inferred; original call site unknown
			end

			if v7 <= 0 and v8 and v4 < v9 then
				renderSteppedConnection:Disconnect()

				if folder.Parent then
					folder:Destroy()
				end
			end
		end)
	end
end