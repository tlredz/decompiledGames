local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function trackEmitter(p, emitter)
	if p.emitters[emitter] then
		return
	end

	p.emitters[emitter] = {
		cadence = 0,
		acc = math.random()
	}
end

local function adopt(folder)
	if v[folder] then
		return
	end

	local v2 = {
		emitters = {}
	}
	v[folder] = v2

	for _, emitter in ipairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		trackEmitter(v2, emitter) -- equivalent call inferred; original call site unknown
	end

	v2.conn = folder.DescendantAdded:Connect(function(emitter)
		if emitter:IsA("ParticleEmitter") then
			local v3 = v2

			if v3.emitters[emitter] then
				return
			else
				v3.emitters[emitter] = {
					cadence = 0,
					acc = math.random()
				}
			end
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function release(k)
	local v2 = v[k]

	if not v2 then
		return
	end

	v[k] = nil

	if v2.conn then
		v2.conn:Disconnect()
	end
end

for _, v2 in ipairs(CollectionService:GetTagged("FlameTrailQualityProof")) do
	adopt(v2)
end

CollectionService:GetInstanceAddedSignal("FlameTrailQualityProof"):Connect(adopt)
CollectionService:GetInstanceRemovedSignal("FlameTrailQualityProof"):Connect(release)
local total = 0
RunService.Heartbeat:Connect(function(dt)
	total += math.min(dt, 0.1)

	if total < 0.03333333333333333 then
		return
	end

	local v2 = total
	total = 0

	for k, v3 in pairs(v) do
		if k.Parent then
			for k2, emitter in pairs(v3.emitters) do
				if k2.Parent then
					local rate = k2.Rate

					if rate > 0 then
						emitter.cadence = rate * k2.TimeScale
						k2.Rate = 0
					end

					if emitter.cadence > 0 and k2.Enabled then
						emitter.acc += emitter.cadence * 1 * v2

						if emitter.acc >= 1 then
							local acc = math.floor(emitter.acc)
							emitter.acc -= acc
							k2:Emit(acc)
						end
					end
				else
					v3.emitters[k2] = nil
				end
			end
		else
			release(k) -- equivalent call inferred; original call site unknown
		end
	end
end)