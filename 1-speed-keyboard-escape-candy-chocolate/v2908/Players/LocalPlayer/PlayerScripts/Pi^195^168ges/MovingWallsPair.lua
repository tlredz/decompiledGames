local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local v = {}
local v2 = {}

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function getWallAlpha(p: number, tweenTime: number, returnTime: number)
	if p < tweenTime then
		return p / tweenTime
	end

	if p < tweenTime + returnTime then
		return 1
	end

	if p < tweenTime * 2 + returnTime then
		return 1 - (p - tweenTime - returnTime) / tweenTime
	end

	return 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveSpeed(instance)
	local speed = instance:GetAttribute("Speed")

	if typeof(speed) == "number" and speed > 0 then
		return speed
	end

	return 1
end

local function collectWalls(instance, vector2: Vector3)
	local result = {}

	for _, childName in { "Left", "Right" } do
		local part = instance:FindFirstChild(childName)

		if part and part:IsA("BasePart") then
			table.insert(result, {
				part = part,
				originCF = part.CFrame,
				offset = part.CFrame:VectorToWorldSpace(vector2),
				timeOffset = 0
			})
		end
	end

	return result
end

local function applyModel(instance, cycleStartTime: number)
	local speed = resolveSpeed(instance) -- equivalent call inferred; original call site unknown
	local tweenTime = 0.3 / speed
	local returnTime = 1.35 / speed
	local moveDistance = instance:GetAttribute("MoveDistance") or -24
	v[instance] = {
		walls = collectWalls(instance, createVector(0, 1, 0) * moveDistance),
		startTime = cycleStartTime,
		cycleTime = tweenTime + returnTime + tweenTime + returnTime,
		tweenTime = tweenTime,
		returnTime = returnTime
	}
end

local setupModel

setupModel = function(instance)
	if v[instance] then
		return
	end

	local cycleStartTime = instance:GetAttribute("CycleStartTime")

	if cycleStartTime then
		applyModel(instance, cycleStartTime)
	elseif not v2[instance] then
		local cycleStartTimeChangedConnection = nil
		cycleStartTimeChangedConnection = instance:GetAttributeChangedSignal("CycleStartTime"):Connect(function()
			v2[instance] = nil

			if cycleStartTimeChangedConnection then
				cycleStartTimeChangedConnection:Disconnect()
			end

			setupModel(instance)
		end)
		v2[instance] = cycleStartTimeChangedConnection
	end
end

local function cleanupModel(p)
	v[p] = nil
	local connection = v2[p]

	if connection then
		connection:Disconnect()
		v2[p] = nil
	end
end

RunService.PreRender:Connect(function()
	local serverTimeNow = workspace:GetServerTimeNow()

	for _, v3 in v do
		for _, wall in v3.walls do
			if not wall.part.Parent then
				continue
			end

			local v4 = (serverTimeNow - v3.startTime - wall.timeOffset) % v3.cycleTime

			if v4 < 0 then
				v4 += v3.cycleTime
			end

			local part = wall.part
			part.CFrame = wall.originCF + wall.offset * getWallAlpha(v4, v3.tweenTime, v3.returnTime)
		end
	end
end)
CollectionService:GetInstanceAddedSignal("MovingWallPair"):Connect(setupModel)
CollectionService:GetInstanceRemovedSignal("MovingWallPair"):Connect(cleanupModel)

for _, v3 in CollectionService:GetTagged("MovingWallPair") do
	setupModel(v3)
end