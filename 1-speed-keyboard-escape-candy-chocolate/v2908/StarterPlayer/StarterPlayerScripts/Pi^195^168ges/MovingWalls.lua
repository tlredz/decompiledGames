local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local v = {
	Tag = "MovingWallModel",
	WallPrefix = "MovingWall",
	WallCount = 12,
	MoveDistance = -24,
	MoveAxis = createVector(1, 0, 0),
	DelayBetweenWalls = 0.13,
	ReturnTime = 1.35,
	TweenTime = 0.2
}
local v2 = {}
local v3 = {}

local function getWallAlpha(p: number)
	if p < 0.2 then
		return p / 0.2
	end

	if p < 1.55 then
		return 1
	end

	if p < 1.75 then
		return 1 - (p - 0.2 - 1.35) / 0.2
	end

	return 0
end

local setupModel

setupModel = function(instance)
	if v2[instance] then
		return
	end

	local cycleStartTime = instance:GetAttribute("CycleStartTime")

	if cycleStartTime then
		local moveDistance = instance:GetAttribute("MoveDistance") or -24
		local v4 = createVector(1, 0, 0) * moveDistance
		local walls = {}

		for i = 1, 12 do
			local part = instance:FindFirstChild("MovingWall" .. i)

			if not (part and part:IsA("BasePart")) then
				continue
			end

			local vectorToWorldSpace = part.CFrame:VectorToWorldSpace(v4)
			table.insert(walls, {
				part = part,
				originCF = part.CFrame,
				offset = vectorToWorldSpace,
				timeOffset = (i - 1) * 0.13
			})
		end

		v2[instance] = {
			walls = walls,
			startTime = cycleStartTime
		}
	else
		if v3[instance] then
			return
		end

		local cycleStartTimeChangedConnection = nil
		cycleStartTimeChangedConnection = instance:GetAttributeChangedSignal("CycleStartTime"):Connect(function()
			v3[instance] = nil

			if cycleStartTimeChangedConnection then
				cycleStartTimeChangedConnection:Disconnect()
			end

			setupModel(instance)
		end)
		v3[instance] = cycleStartTimeChangedConnection
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanupModel(p)
	v2[p] = nil
	local connection = v3[p]

	if connection then
		connection:Disconnect()
		v3[p] = nil
	end
end

RunService.PreRender:Connect(function()
	local serverTimeNow = workspace:GetServerTimeNow()

	for _, v4 in v2 do
		for _, wall in ipairs(v4.walls) do
			if not (wall.part and wall.part.Parent) then
				continue
			end

			local v5 = (serverTimeNow - v4.startTime - wall.timeOffset) % 3.1

			if v5 < 0 then
				v5 += 3.1
			end

			local v6

			if v5 < v.TweenTime then
				v6 = v5 / v.TweenTime
			elseif v5 < v.TweenTime + v.ReturnTime then
				v6 = 1
			elseif not (v5 < v.TweenTime * 2 + v.ReturnTime) then
				v6 = 0
			else
				v6 = 1 - (v5 - v.TweenTime - v.ReturnTime) / v.TweenTime
			end

			wall.part.CFrame = wall.originCF + wall.offset * v6
		end
	end
end)

for _, v4 in ipairs(CollectionService:GetTagged("MovingWallModel")) do
	setupModel(v4)
end

CollectionService:GetInstanceAddedSignal("MovingWallModel"):Connect(function(p)
	setupModel(p)
end)
CollectionService:GetInstanceRemovedSignal("MovingWallModel"):Connect(function(p)
	cleanupModel(p) -- equivalent call inferred; original call site unknown
end)