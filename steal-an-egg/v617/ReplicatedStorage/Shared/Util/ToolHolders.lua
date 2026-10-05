local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = require(ReplicatedStorage.Shared.Player)
local v = {
	FromTool = function(tool)
		local v2

		if typeof(tool) == "Instance" then
			v2 = tool:IsA("Tool")
		else
			v2 = false
		end

		assert(v2, "FromTool expects a Tool")
		local parent = tool.Parent

		if parent == nil then
			return nil
		end

		if parent:IsA("Player") then
			return parent
		end

		if parent:IsA("Model") then
			return (Players:GetPlayerFromCharacter(parent))
		end

		return nil
	end
}

local function survey(player, position: Vector3, value: number)
	local result = {}

	for _, player2 in Players:GetPlayers() do
		if player2 == player then
			continue
		end

		local rootPart = Player.FindRootPart(player2)

		if rootPart == nil then
			continue
		end

		local delta = rootPart.Position - position
		local magnitude = delta.Magnitude

		if magnitude <= value then
			table.insert(result, {
				player = player2,
				delta = delta,
				distance = magnitude
			})
		end
	end

	table.sort(result, function(a, b)
		return a.distance < b.distance
	end)
	return result
end

function v.NearestWithin(player, value: number, p: number?)
	local v2

	if typeof(player) == "Instance" then
		v2 = player:IsA("Player")
	else
		v2 = false
	end

	assert(v2, "NearestWithin expects a Player")
	assert(type(value) == "number", "NearestWithin expects a numeric range")
	local rootPart = Player.FindRootPart(player)

	if rootPart == nil then
		return nil, createVector(1, 0, 0)
	end

	local v3 = survey(player, rootPart.Position, value)
	local v4 = p == nil and 1 or math.max(0, (math.floor(p)))

	if v4 > 1 then
		return table.move(v3, 1, math.min(v4, #v3), 1, {})
	end

	local v5 = v3[1]

	if v5 == nil then
		return nil, createVector(1, 0, 0)
	end

	return v5.player, v5.delta
end

return table.freeze(v)