local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local v = {
	Tag = "World4Stage6MovingWallModel",
	WallPrefix = "MovingWall",
	WallCount = 6,
	MoveDistance = 50,
	MoveAxis = createVector(0, 1, 0),
	DelayBetweenWalls = 0.13,
	TweenTime = 0.2,
	ClosedTime = 1.35,
	OpenTime = 6.45
}
local v2 = {}
local v3 = {}

local function countMatchingWalls(folder)
	local count = 0

	for _, part in ipairs(folder:GetDescendants()) do
		local v4 = string.match(part.Name, "^MovingWall(%d+)$")
		local v5 = v4 and tonumber(v4)

		if v5 and v5 >= 1 and v5 <= 6 and part:IsA("BasePart") then
			count += 1
		end
	end

	return count
end

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

local function setupModel(folder)
	if v2[folder] or v3[folder] then
		return
	end

	v3[folder] = true
	local serverTimeNow = workspace:GetServerTimeNow()
	local moveDistance = folder:GetAttribute("MoveDistance") or 50
	local v4 = createVector(0, 1, 0) * moveDistance
	local walls = {}
	local connections = {}

	while folder.Parent and countMatchingWalls(folder) < 12 do
		task.wait(0.1)
	end

	for _, part in ipairs(folder:GetDescendants()) do
		local v6 = string.match(part.Name, "^MovingWall(%d+)$")
		local v7 = v6 and tonumber(v6)

		if not (v7 and v7 >= 1 and v7 <= 6 and part:IsA("BasePart")) then
			continue
		end

		part.Anchored = true
		local vectorToWorldSpace = part.CFrame:VectorToWorldSpace(v4)
		table.insert(walls, {
			part = part,
			originCF = part.CFrame,
			offset = vectorToWorldSpace,
			timeOffset = (v7 - 1) * 0.13
		})
		table.insert(connections, part.Touched:Connect(function(otherPart)
			local character = localPlayer.Character

			if not (character and otherPart:IsDescendantOf(character)) then
				return
			end

			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.Health > 0 then
				humanoid.Health = 0
			end
		end))
	end

	if #walls ~= 12 then
		warn(string.format(
			"[Stage6MovingWalls][Client] %d/12 murs trouvés dans %s (attendu : deux MovingWall1..6)",
			#walls,
			folder:GetFullName()
		))
	end

	v2[folder] = {
		walls = walls,
		startTime = serverTimeNow,
		touchConnections = connections
	}
	v3[folder] = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanupModel(p)
	local v4 = v2[p]

	if v4 then
		for _, touchConnection in v4.touchConnections do
			touchConnection:Disconnect()
		end
	end

	v2[p] = nil
	v3[p] = nil
end

RunService.PreRender:Connect(function()
	local serverTimeNow = workspace:GetServerTimeNow()

	for _, v4 in v2 do
		for _, wall in ipairs(v4.walls) do
			if not (wall.part and wall.part.Parent) then
				continue
			end

			local v5 = (serverTimeNow - v4.startTime - wall.timeOffset) % 8.2

			if v5 < 0 then
				v5 += 8.2
			end

			local v6

			if v5 < v.TweenTime then
				v6 = v5 / v.TweenTime
			elseif v5 < v.TweenTime + v.ClosedTime then
				v6 = 1
			elseif not (v5 < v.TweenTime * 2 + v.ClosedTime) then
				v6 = 0
			else
				v6 = 1 - (v5 - v.TweenTime - v.ClosedTime) / v.TweenTime
			end

			wall.part.CFrame = wall.originCF + wall.offset * v6
		end
	end
end)

for _, v4 in ipairs(CollectionService:GetTagged("World4Stage6MovingWallModel")) do
	task.spawn(setupModel, v4)
end

CollectionService:GetInstanceAddedSignal("World4Stage6MovingWallModel"):Connect(function(p)
	task.spawn(setupModel, p)
end)
CollectionService:GetInstanceRemovedSignal("World4Stage6MovingWallModel"):Connect(function(p)
	cleanupModel(p) -- equivalent call inferred; original call site unknown
end)