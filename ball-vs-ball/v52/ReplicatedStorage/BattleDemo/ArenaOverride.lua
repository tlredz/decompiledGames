local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {}
local ArenaOverride = {}

function ArenaOverride.buildArenaData(data)
	local boardCnId = data and data.boardCnId

	if typeof(boardCnId) ~= "string" then
		return nil
	end

	local v2 = v[data.id]

	if v2 then
		return v2
	end

	local Config = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("Config"))
	local v3 = Config.board.byCnId[boardCnId]
	assert(v3 ~= nil, string.format("[ArenaOverride] 飞书 board 表找不到: %s", boardCnId))
	local child = ReplicatedStorage:WaitForChild("美术素材"):WaitForChild("棋盘"):WaitForChild(v3.assetName)
	local part = child:FindFirstChild("绑定箱")
	assert(part and part:IsA("BasePart"), string.format("[ArenaOverride] 棋盘 '%s' 缺少绑定箱", v3.assetName))
	local spawnPositions = {}

	for _, seat in ipairs(data.seats) do
		local boardMarkerName = seat.boardMarkerName
		local part2 = boardMarkerName and child:FindFirstChild(boardMarkerName)
		assert(
			part2 and part2:IsA("BasePart"),
			string.format("[ArenaOverride] 棋盘 '%s' 缺少出生点标记 %s", v3.assetName, (tostring(boardMarkerName)))
		)
		local pointToObjectSpace = part.CFrame:PointToObjectSpace(part2.Position)
		spawnPositions[seat.team] = spawnPositions[seat.team] or {}
		spawnPositions[seat.team][seat.teamIndex] = Vector2.new(pointToObjectSpace.X, pointToObjectSpace.Y)
	end

	local v5 = {
		size = Vector2.new(v3.xSize, v3.ySize),
		boardAssetName = v3.assetName,
		spawnPositions = spawnPositions
	}
	v[data.id] = v5
	return v5
end

function ArenaOverride.resolveConfig(p, data)
	if typeof(data) ~= "table" or typeof(data.size) ~= "Vector2" or typeof(data.spawnPositions) ~= "table" then
		return p
	end

	local clone = table.clone(p.arena)
	clone.size = data.size
	clone.boardAssetName = data.boardAssetName
	local clones = {}

	for k, slot in pairs(p.slots) do
		local clone2 = table.clone(slot)
		local spawnPosition = data.spawnPositions[k]

		if typeof(spawnPosition) == "table" and typeof(spawnPosition[1]) == "Vector2" then
			clone2.spawnPosition = spawnPosition[1]
			clone2.spawnPositionCorners = spawnPosition
		end

		clones[k] = clone2
	end

	return (setmetatable({
		arena = clone,
		slots = clones
	}, {
		__index = p
	}))
end

return ArenaOverride