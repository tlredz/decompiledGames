local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local function resolveConfig(p)
	if type(p.Config) == "table" then
		return p.Config
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

return function(p)
	if not p then
		return
	end

	local Lighting = game:GetService("Lighting")
	local templeIntelBeamFlicker = Lighting:FindFirstChild("TempleIntelBeamFlicker")

	if p.Remove == true then
		if templeIntelBeamFlicker then
			templeIntelBeamFlicker:Destroy()
		end
	else
		if templeIntelBeamFlicker then
			return
		end

		local config = resolveConfig(p)
		local flicker

		if config then
			flicker = config.Flicker
		else
			flicker = nil
		end

		if not (flicker and flicker.Enabled) then
			return
		end

		local folder = Instance.new("Folder")
		folder.Name = "TempleIntelBeamFlicker"
		folder.Parent = game:GetService("Lighting")
		local v = {}
		local connection = CollectionService:GetInstanceRemovedSignal("TempleIntelBeam"):Connect(function(p2)
			v[p2] = nil
		end)
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if folder.Parent then
				local v2 = os.clock() * flicker.Speed

				for _, beam in CollectionService:GetTagged("TempleIntelBeam") do
					if not (beam:IsA("Beam") and beam.Enabled) then
						continue
					end

					local v3 = v[beam]

					if not v3 then
						v3 = math.random() * 1000
						v[beam] = v3
					end

					local baseWidth = beam:GetAttribute("BaseWidth") or config.Beam.Width
					local baseTransparency = beam:GetAttribute("BaseTransparency") or config.Beam.Transparency
					local v4 = math.noise(v2, v3, 0)
					local v5 = math.noise(v2, v3, 7.3)
					local v6 = math.noise(v2 * 0.6, v3, 19.1)
					beam.Width0 = baseWidth * (1 + v4 * flicker.WidthAmount)
					beam.Width1 = baseWidth * (1 + v5 * flicker.WidthAmount)
					beam.Transparency = NumberSequence.new((math.clamp(
						baseTransparency + v6 * flicker.AlphaAmount,
						0,
						1
					)))

					if not (flicker.CurveAmount > 0) then
						continue
					end

					beam.CurveSize0 = config.Beam.CurveSize + v5 * flicker.CurveAmount
					beam.CurveSize1 = config.Beam.CurveSize - v4 * flicker.CurveAmount
				end
			else
				heartbeatConnection:Disconnect()
				connection:Disconnect()
			end
		end)
	end
end