local createVector = vector.create
local Workspace = game:GetService("Workspace")
local Config = require(script.Config)

local function collectParts(folder)
	local parts = {}

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			table.insert(parts, part)
		end
	end

	return parts
end

local function addWeld(p, filterDescendantsInstance, part)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = filterDescendantsInstance
	weldConstraint.Part1 = part
	weldConstraint.Parent = filterDescendantsInstance

	for _, v in { filterDescendantsInstance, part } do
		local v2 = p[v]

		if v2 then
			table.insert(v2, weldConstraint)
		else
			p[v] = { weldConstraint }
		end
	end
end

local function weldTouchingParts(filterDescendantsInstances)
	local v = {}
	local v2 = {}

	for k, filterDescendantsInstance in filterDescendantsInstances do
		v[filterDescendantsInstance] = k
	end

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = filterDescendantsInstances
	local v3 = createVector(1, 1, 1) * Config.weldMarginStuds * 2

	for k, filterDescendantsInstance in filterDescendantsInstances do
		for _, v4 in Workspace:GetPartBoundsInBox(
			filterDescendantsInstance.CFrame,
			filterDescendantsInstance.Size + v3,
			overlapParams
		) do
			if k < v[v4] then
				addWeld(v2, filterDescendantsInstance, v4)
			end
		end
	end

	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function breakWelds(p, p2)
	local weld = p.welds[p2]

	if weld then
		for _, v in weld do
			v:Destroy()
		end

		p.welds[p2] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function blastPart(object, position: Vector3)
	local v = object.Position - position
	object:ApplyImpulse(((not (v.Magnitude > 0.001) and createVector(0, 1, 0) or v.Unit) + createVector(0, 1, 0) * Config.blastUpwardBias).Unit * Config.blastSpeed * object.AssemblyMass)
end

local DestructibleBuilds = {}

function DestructibleBuilds.prepareServer(instance)
	for _, model in instance:GetChildren() do
		if model:IsA("Model") then
			model.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
		end
	end
end

function DestructibleBuilds.startClient(parent)
	local v = {}
	local v2 = {}
	local v3 = {}
	local v4 = false

	local function spawnLive(state)
		local clone = state.pristine:Clone()
		v3[clone] = true
		clone.Parent = parent
		local parts = collectParts(clone)
		state.live = clone
		state.parts = parts
		state.welds = weldTouchingParts(parts)
		table.clear(state.hit)
		state.hitCount = 0
		state.collapsed = false

		for _, v6 in parts do
			v6.Anchored = false
			v2[v6] = state
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function despawnLive(p)
		for _, part in p.parts do
			v2[part] = nil
		end

		v3[p.live] = nil
		p.live:Destroy()
	end

	local function respawn(p)
		p.respawnThread = nil
		despawnLive(p) -- equivalent call inferred; original call site unknown
		spawnLive(p)
	end

	local function collapse(p)
		p.collapsed = true

		for _, part in p.parts do
			breakWelds(p, part) -- equivalent call inferred; original call site unknown
		end

		p.respawnThread = task.delay(Config.respawnSeconds, respawn, p)
	end

	local function adopt(model)
		local v5 = {
			original = model,
			pristine = model:Clone(),
			hit = {},
			hitCount = 0,
			collapsed = false
		}
		model.Parent = nil
		spawnLive(v5)
		table.insert(v, v5)
	end

	local function onExplosion(explosion)
		local lives = {}

		for _, v5 in v do
			table.insert(lives, v5.live)
		end

		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Include
		overlapParams.FilterDescendantsInstances = lives
		local position = explosion.Position
		local partBoundsInRadius = Workspace:GetPartBoundsInRadius(position, explosion.BlastRadius, overlapParams)

		for _, v5 in partBoundsInRadius do
			local v6 = v2[v5]
			breakWelds(v6, v5) -- equivalent call inferred; original call site unknown

			if v6.hit[v5] then
				continue
			end

			v6.hit[v5] = true
			v6.hitCount += 1
		end

		for _, v5 in partBoundsInRadius do
			blastPart(v5, position) -- equivalent call inferred; original call site unknown
		end

		for _, v5 in v do
			if v5.collapsed or not (v5.hitCount > #v5.parts * Config.collapseHitFraction) then
				continue
			end

			collapse(v5)
		end
	end

	local childAddedConnection = parent.ChildAdded:Connect(function(model)
		if model:IsA("Model") and not v3[model] then
			task.defer(function()
				if not v4 and model.Parent == parent then
					adopt(model)
				end
			end)
		end
	end)
	local descendantAddedConnection = Workspace.DescendantAdded:Connect(function(explosion)
		if explosion:IsA("Explosion") then
			onExplosion(explosion)
		end
	end)

	for _, model in parent:GetChildren() do
		if model:IsA("Model") then
			adopt(model)
		end
	end

	return function()
		v4 = true
		childAddedConnection:Disconnect()
		descendantAddedConnection:Disconnect()
		local isDescendant = parent:IsDescendantOf(game)

		for _, v5 in v do
			if v5.respawnThread then
				task.cancel(v5.respawnThread)
			end

			despawnLive(v5) -- equivalent call inferred; original call site unknown

			if isDescendant then
				v5.original.Parent = parent
			else
				v5.original:Destroy()
			end
		end

		table.clear(v)
	end
end

return DestructibleBuilds