local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Util = require(ReplicatedStorage.Util)
local VfxPool = {
	PreparedClones = require(script.Parent.PreparedVfxClones)
}
local v = {}

local function ownerKey(value)
	if typeof(value) == "Instance" then
		return value.Name
	end

	if type(value) ~= "table" then
		return "Unknown"
	end

	if type(value.Name) == "string" then
		return value.Name
	end

	if typeof(value.Character) == "Instance" then
		return value.Character.Name
	end

	return "Unknown"
end

local scheduleEviction

scheduleEviction = function(p: string)
	local v2 = v[p]

	if v2 and not v2.EvictScheduled then
		v2.EvictScheduled = true
		task.delay(12, function()
			local v3 = v[p]

			if not v3 then
				return
			end

			v3.EvictScheduled = false

			if os.clock() - v3.LastUse < 12 then
				scheduleEviction(p)
				return
			end

			v[p] = nil

			for _, ring in v3.Rings do
				for _, entry in ring.Entries do
					entry.Model:Destroy()
				end
			end
		end)
	end
end

function VfxPool.take(value, p: string, p2: number, callback)
	local name

	if typeof(value) == "Instance" then
		name = value.Name
	elseif type(value) == "table" then
		if type(value.Name) == "string" then
			name = value.Name
		else
			name = typeof(value.Character) ~= "Instance" and "Unknown" or value.Character.Name
		end
	else
		name = "Unknown"
	end

	local v2 = v[name]

	if not v2 then
		v2 = {
			Rings = {},
			LastUse = 0,
			EvictScheduled = false
		}
		v[name] = v2
	end

	v2.LastUse = os.clock()
	local v3 = v[name]

	if v3 and not v3.EvictScheduled then
		v3.EvictScheduled = true
		task.delay(12, function()
			local v4 = v[name]

			if not v4 then
				return
			end

			v4.EvictScheduled = false

			if os.clock() - v4.LastUse < 12 then
				scheduleEviction(name)
				return
			end

			v[name] = nil

			for _, ring in v4.Rings do
				for _, entry in ring.Entries do
					entry.Model:Destroy()
				end
			end
		end)
	end

	local ring = v2.Rings[p]

	if not ring then
		ring = {
			Entries = {},
			NextIndex = 1
		}
		v2.Rings[p] = ring
	end

	if #ring.Entries < p2 then
		local v4 = callback()
		table.insert(ring.Entries, v4)
		return v4
	else
		local entry = ring.Entries[ring.NextIndex]

		if not entry.Model.Parent then
			entry = callback()
			ring.Entries[ring.NextIndex] = entry
		end

		ring.NextIndex = ring.NextIndex % p2 + 1
		return entry
	end
end

function VfxPool.buildBurst(instance, p, callback, p2)
	local folder = p2 or instance:Clone()

	if callback then
		callback(folder)
	end

	local emits = {}

	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			table.insert(emits, {
				Emitter = emitter,
				Count = emitter:GetAttribute("EmitCount")
			})
		end
	end

	Util.SetParentOverrideWithColor(folder, workspace.Terrain, p, "MagnetFruitVFXColor")
	return {
		Model = folder,
		Emits = emits
	}
end

function VfxPool.takeBurst(p, p2: string, p3, value: number?, callback)
	return VfxPool.take(p, p2, value or 1, function()
		return VfxPool.buildBurst(p3, p, callback, nil)
	end)
end

function VfxPool.takePreparedBurst(p, p2: string, p3, p4, p5: string, value: number?, callback)
	return VfxPool.take(p, p2, value or 1, function()
		local v2 = VfxPool.PreparedClones.take(p4, p5, p3)
		return VfxPool.buildBurst(p3, p, callback, v2)
	end)
end

function VfxPool.emitBurst(p, p2: number?, ancestor)
	for _, emit in p.Emits do
		local emitter = emit.Emitter

		if ancestor and emitter:IsDescendantOf(ancestor) then
			continue
		end

		if p2 then
			if emit.Count then
				emitter:Emit(emit.Count * p2)
			end
		else
			emitter:Emit(emit.Count)
		end
	end
end

local function scaleEmitterOpacity(emitter, p: number)
	local v2 = emitter.LightEmission >= 0.5
	local numberSequenceKeypoints = {}

	for _, keypoint in emitter.Transparency.Keypoints do
		local v3 = 1 - keypoint.Value
		local v4

		if v2 then
			v4 = math.min(1, v3 * p)
		else
			v4 = 1 - (1 - v3) ^ p
		end

		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(keypoint.Time, 1 - v4, keypoint.Envelope))
	end

	emitter.Transparency = NumberSequence.new(numberSequenceKeypoints)
end

local function emitterStats(p)
	local v2 = 0
	local v3 = 1

	for _, keypoint in p.Size.Keypoints do
		v2 = math.max(v2, keypoint.Value)
	end

	for _, keypoint in p.Transparency.Keypoints do
		v3 = math.min(v3, keypoint.Value)
	end

	return v2, v3
end

local function isStackedHaze(p)
	local v2, v3 = emitterStats(p)
	return p.Speed.Max <= 1 and v2 >= 25 and v3 >= 0.65
end

function VfxPool.thinStreamingHaze(folder, p: number)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v2, v3 = emitterStats(emitter)
		local v4

		if emitter.Speed.Max <= 1 and v2 >= 25 then
			v4 = v3 >= 0.65
		else
			v4 = false
		end

		if not v4 then
			continue
		end

		local midpoint = (emitter.Lifetime.Min + emitter.Lifetime.Max) / 2
		local v6 = emitter.Rate * midpoint

		if midpoint <= 0 or v6 <= p then
			continue
		end

		emitter.Rate = p / midpoint
		scaleEmitterOpacity(emitter, v6 / p)
	end
end

function VfxPool.thinBurstHaze(folder)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")

		if type(emitCount) ~= "number" or emitCount < 4 then
			continue
		end

		local v2, v3 = emitterStats(emitter)
		local v4

		if emitter.Speed.Max <= 1 and v2 >= 25 then
			v4 = v3 >= 0.65
		else
			v4 = false
		end

		if not v4 then
			continue
		end

		local v5 = math.max(2, (math.floor(emitCount / 3 + 0.5)))
		emitter:SetAttribute("EmitCount", v5)
		scaleEmitterOpacity(emitter, emitCount / v5)
	end
end

function VfxPool.stripNearInvisible(folder, p: number)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local _, v2 = emitterStats(emitter)

		if p <= v2 then
			emitter:Destroy()
		end
	end
end

local v2 = {}
local heartbeatConnection = nil

local function stepAll(p: number)
	for i = #v2, 1, -1 do
		if v2[i](p) then
			table.remove(v2, i)
		end
	end

	if #v2 == 0 and heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

function VfxPool.addStep(callback)
	table.insert(v2, callback)

	if not heartbeatConnection then
		heartbeatConnection = RunService.Heartbeat:Connect(stepAll)
	end
end

local v3 = 0

function VfxPool.takeHighlight(instance, parent, p)
	if v3 >= 14 then
		return nil
	end

	v3 += 1
	local clone = instance:Clone()
	clone.Destroying:Once(function()
		v3 = math.max(0, v3 - 1)
	end)

	if p then
		Util.SetParentOverrideWithColor(clone, parent, p, "MagnetFruitVFXColor")
		return clone
	end

	clone.Parent = parent
	return clone
end

local v4 = {}

function VfxPool.getScrapChildren(instance, p: number)
	local children = v4[instance]

	if not children then
		children = {}
		v4[instance] = children
	end

	local children2 = children[p]

	if children2 then
		return children2
	end

	local clone = instance:Clone()
	clone:ScaleTo(p)
	children2 = clone:GetChildren()
	children[p] = children2
	return children2
end

function VfxPool.takeBoltAnchor(p, instance, p2: number, cFrame: CFrame, worldPosition: Vector3, p3, p4: string?)
	local model = VfxPool.take(p, "CBoltAnchor", p2, function()
		local clone

		if p4 then
			clone = VfxPool.PreparedClones.take(p3, p4, instance)
		else
			clone = instance:Clone()
		end

		clone.Parent = workspace.Terrain
		return {
			Model = clone
		}
	end).Model
	model.CFrame = cFrame
	model.Attach1.WorldPosition = worldPosition
	return model
end

function VfxPool.spherePulse(data)
	local owner = data.Owner
	local v5 = VfxPool.take(owner, data.RingKey, data.RingSize or 2, function()
		local clone

		if data.PreparedKey then
			clone = VfxPool.PreparedClones.take(data.PreparedState, data.PreparedKey, data.Template)
		else
			clone = data.Template:Clone()
		end

		if data.Prepare then
			data.Prepare(clone)
		end

		local descendants = {}
		local vectorsByDescendant = {}

		for _, descendant in clone:GetDescendants() do
			if descendant:IsA("Texture") then
				table.insert(descendants, descendant)
				vectorsByDescendant[descendant] = Vector2.new(descendant.StudsPerTileU, descendant.StudsPerTileV)
			elseif descendant:IsA("Decal") then
				table.insert(descendants, descendant)
			end
		end

		Util.SetParentOverrideWithColor(clone, workspace.Terrain, owner, "MagnetFruitVFXColor")
		return {
			Model = clone,
			Fades = descendants,
			TileBases = vectorsByDescendant,
			Tweens = {}
		}
	end)

	for _, tween in v5.Tweens do
		tween:Cancel()
	end

	table.clear(v5.Tweens)
	local model = v5.Model
	model.Size = data.StartSize
	model.CFrame = data.CFrame
	local tweens = v5.Tweens
	table.insert(
		tweens,
		TweenService:Create(
			model,
			TweenInfo.new(data.Duration or 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{
				Size = data.EndSize
			}
		)
	)
	local tweenInfo = TweenInfo.new(
		data.FadeDuration or data.Duration or 0.35,
		data.FadeStyle or Enum.EasingStyle.Quad,
		data.FadeDirection or Enum.EasingDirection.Out
	)

	for _, fade in v5.Fades do
		local tileBas = v5.TileBases[fade]

		if tileBas then
			fade.StudsPerTileU = tileBas.X
			fade.StudsPerTileV = tileBas.Y
		end

		fade.Transparency = data.Transparency
		local v6 = {
			Transparency = 1
		}

		if data.TileTween and tileBas then
			v6.StudsPerTileU = math.random(15, 20) * 2
			v6.StudsPerTileV = math.random(15, 20) * 2
		end

		table.insert(tweens, TweenService:Create(fade, tweenInfo, v6))
	end

	for _, tween in tweens do
		tween:Play()
	end
end

return VfxPool