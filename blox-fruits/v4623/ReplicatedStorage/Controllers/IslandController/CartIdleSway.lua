local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Maid = require(game.ReplicatedStorage.Util.Maid)
local _ = {
	TAG = "IdleCart",
	WHEEL_MODEL = "CartWheel",
	AXLE_PATTERN = "Ax[le][le]",
	CULL_ENTER = 100,
	CULL_EXIT = 92,
	NEAR_DISTANCE = 55,
	NEAR_INTERVAL = 0.03333333333333333,
	FAR_INTERVAL = 0.06666666666666667,
	GROUNDED = 0.26,
	BODY_ROLL = 0.02007128639793479,
	BODY_PITCH = 0.009599310885968814,
	BODY_YAW = 0.003490658503988659,
	BODY_BOB = 0.07,
	DRIFT = 0.34,
	JOLT_PERIOD = 5.5,
	JOLT_DECAY = 1.7,
	JOLT_RING = 6.4,
	LURCH_PERIOD = 15,
	LURCH_TRAVEL = 0.75,
	LURCH_PUSH = 0.5,
	LURCH_SETTLE = 1.9,
	LURCH_PITCH = 0.015707963267948967
}
local v = {
	Rope = {
		hinge = 0.5,
		amplitude = 0.12217304763960307,
		fast = 1.24,
		slow = 0.78
	},
	Tarp = {
		hinge = -0.5,
		amplitude = 0.04537856055185257,
		fast = 0.8,
		slow = 1.5
	},
	Paper = {
		hinge = 0,
		amplitude = 0.031415926535897934,
		fast = 2.65,
		slow = 1.6
	}
}
local v2 = {}
local CartIdleSway = {
	LoadForLocations = { "Middle Town" },
	Maid = Maid.new()
}

-- equivalent calls inferred from this helper; original call sites unknown
local function hash01(p: number)
	local v3 = math.sin(p * 127.1 + 311.7) * 43758.5453
	return v3 - math.floor(v3)
end

local function buildFlex(part, p: number)
	local profile = nil

	for k, v4 in v do
		if string.find(part.Name, k) then
			profile = v4
		end
	end

	if not profile then
		return nil
	end

	local cFrame = part.CFrame
	local v4 = cFrame.Position + createVector(0, 1, 0) * (part.Size.Y * profile.hinge)
	return {
		hinge = cFrame.Rotation + v4,
		axis = part.Size.X > part.Size.Z and createVector(1, 0, 0) or createVector(0, 0, 1),
		profile = profile,
		seed = p * 0.7391
	}
end

local function resolvePivot(model, parts)
	local v3 = createVector(0, 0, 0)
	local v4 = nil
	local count = 0

	for _, item in parts do
		if not string.find(item.Name, "Ax[le][le]") then
			continue
		end

		v3 += item.Position
		v4 = v4 or item.CFrame.Rotation
		count += 1
	end

	if v4 and count > 0 then
		return v4 + v3 / count
	end

	local primaryPart = model.PrimaryPart

	if primaryPart then
		return primaryPart.CFrame.Rotation + primaryPart.Position
	end

	local boundingBox, v5 = model:GetBoundingBox()
	return boundingBox.Rotation + (boundingBox.Position - createVector(0, 1, 0) * (v5.Y * 0.5))
end

local function swayChannel(p: number, p2: number, p3: number, p4: number)
	local v3 = (math.sin(p * p2 + p4) * 0.62 + math.sin(p * p3 + p4 * 1.7) * 0.38) * 0.34
	local v4 = math.floor(p / 5.5)
	local total = 0

	for i = v4 - 1, v4 do
		local v5 = i + p4
		local v6 = p - (i + hash01(v5) * 0.7) * 5.5

		if v6 > 0 then
			total += (hash01(v5 + 41.3) < 0.5 and -1 or 1) * (hash01(v5 + 13.7) * 0.5 + 0.5) * math.exp(-1.7 * v6) * math.sin(6.4 * v6)
		end
	end

	return v3 + total
end

local function lurchProfile(lastUpdate: number)
	local v3 = math.floor(lastUpdate / 15)
	local v4 = lastUpdate - (v3 + hash01(v3 + 91.3) * 0.5) * 15

	if v4 <= 0 then
		return 0
	end

	if v4 < 0.5 then
		return 1 - (1 - v4 / 0.5) ^ 2.2
	end

	local v5 = (v4 - 0.5) / 1.9

	if v5 >= 1 then
		return 0
	end

	return math.exp(-3.2 * v5) * math.cos(v5 * 4.2) * (1 - v5)
end

local function bodyOffset(lastUpdate: number, p: number)
	local v3 = swayChannel(lastUpdate, 0.7, 0.44, 0) * 0.02007128639793479
	local v4 = swayChannel(lastUpdate, 0.54, 0.35, 3.1) * 0.009599310885968814 + p * 0.015707963267948967
	local v5 = swayChannel(lastUpdate, 0.31, 0.19, 7.7) * 0.003490658503988659
	local v6 = swayChannel(lastUpdate, 0.7, 0.47, 5.3) * 0.07
	return CFrame.new(0, v6, 0) * CFrame.Angles(v4, v5, v3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function flexAngle(flex, lastUpdate: number, p: number)
	local profile = flex.profile
	return (math.sin(lastUpdate * profile.fast + flex.seed) * 0.68 + math.sin(lastUpdate * profile.slow + flex.seed * 1.9) * 0.32) * profile.amplitude * p
end

local function restoreCart(state)
	if state.resting then
		return
	end

	state.resting = true
	local parts = {}
	local v3 = {}

	for k, part in state.parts do
		if not part:IsDescendantOf(workspace) then
			continue
		end

		local v4 = #parts + 1
		parts[v4] = part
		v3[v4] = state.restCFrames[k]
	end

	if #parts > 0 then
		workspace:BulkMoveTo(parts, v3, Enum.BulkMoveMode.FireCFrameChanged)
	end
end

local function refreshCart(state)
	restoreCart(state)
	state.dirty = false
	state.wheelRadius = 2.5
	table.clear(state.parts)
	table.clear(state.restCFrames)
	table.clear(state.cframes)
	table.clear(state.entries)
	local v3 = {}

	for _, part in state.model:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local parent = part.Parent
		local v4

		if parent == nil then
			v4 = false
		else
			v4 = parent.Name == "CartWheel"
		end

		local v5 = #state.parts + 1
		local cFrame = part.CFrame
		local v6 = {
			rest = cFrame,
			flex = buildFlex(part, v5),
			hub = nil,
			grounded = v4 or string.find(part.Name, "Ax[le][le]") ~= nil
		}
		state.parts[v5] = part
		state.restCFrames[v5] = cFrame
		state.cframes[v5] = cFrame
		state.entries[v5] = v6

		if not v4 then
			continue
		end

		table.insert(v3, v6)
		state.wheelRadius = math.max(state.wheelRadius, part.Size.Y * 0.5, part.Size.Z * 0.5)
	end

	if #state.parts == 0 then
		return
	end

	state.pivot = resolvePivot(state.model, state.parts)

	for _, v4 in v3 do
		v4.hub = state.pivot.Rotation + v4.rest.Position
	end
end

local function applyCart(state, now: number)
	state.lastUpdate = now
	state.resting = false
	local v3 = lurchProfile(now)
	local v4 = 0.75 * v3
	local pivot = state.pivot
	local v5 = bodyOffset(now, v3)
	local cframe = CFrame.new(pivot.LookVector * v4)
	local v6 = cframe * pivot * v5 * pivot:Inverse()
	local v7 = cframe * pivot * CFrame.identity:Lerp(v5, 0.26) * pivot:Inverse()
	local v8 = -v4 / state.wheelRadius
	local v9 = 0.62 + math.noise(now * 0.09, 17.3, 4.1) * 0.9

	for k, entry in state.entries do
		local v10

		if entry.grounded then
			v10 = v7
		else
			v10 = v6
		end

		local v11 = v10 * entry.rest
		local flex = entry.flex

		if flex then
			local cframe2 = v10 * flex.hinge
			v11 = cframe2 * CFrame.fromAxisAngle(flex.axis, flexAngle(flex, now, v9)) * cframe2:Inverse() * v11
		elseif entry.hub then
			local cframe2 = v10 * entry.hub
			v11 = cframe2 * CFrame.Angles(v8, 0, 0) * cframe2:Inverse() * v11
		end

		state.cframes[k] = v11
	end

	workspace:BulkMoveTo(state.parts, state.cframes, Enum.BulkMoveMode.FireCFrameChanged)
end

local function stepAll()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local position = currentCamera.CFrame.Position
	local now = os.clock()

	for _, v3 in v2 do
		if v3.dirty then
			refreshCart(v3)
		end

		if #v3.parts == 0 then
			continue
		end

		local magnitude = (position - v3.pivot.Position).Magnitude

		if (v3.resting and 92 or 100) < magnitude then
			restoreCart(v3)
		elseif (magnitude > 55 and 0.06666666666666667 or 0.03333333333333333) <= now - v3.lastUpdate then
			applyCart(v3, now)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeCart(k)
	local v3 = v2[k]

	if not v3 then
		return
	end

	v2[k] = nil
	v3.maid:DoCleaning()
	restoreCart(v3)
end

local function addCart(model)
	if v2[model] or not (model:IsA("Model") and model:IsDescendantOf(workspace)) then
		return
	end

	local v3 = {
		model = model,
		maid = Maid.new(),
		parts = {},
		restCFrames = {},
		cframes = {},
		entries = {},
		pivot = CFrame.identity,
		wheelRadius = 2.5,
		resting = true,
		dirty = false,
		lastUpdate = 0
	}
	refreshCart(v3)

	local function markDirty()
		v3.dirty = true
	end

	v3.maid:GiveTask(model.DescendantAdded:Connect(markDirty))
	v3.maid:GiveTask(model.DescendantRemoving:Connect(markDirty))
	v2[model] = v3
end

function CartIdleSway.RegionEntered(p)
	local maid = p.Maid
	maid:GiveTask(function()
		for k in v2 do
			removeCart(k) -- equivalent call inferred; original call site unknown
		end
	end)

	for _, v3 in CollectionService:GetTagged("IdleCart") do
		addCart(v3)
	end

	maid:GiveTask(CollectionService:GetInstanceAddedSignal("IdleCart"):Connect(addCart))
	maid:GiveTask(CollectionService:GetInstanceRemovedSignal("IdleCart"):Connect(removeCart))
	maid:GiveTask(RunService.PreAnimation:Connect(stepAll))
end

function CartIdleSway.RegionLeaving(_) end

return CartIdleSway