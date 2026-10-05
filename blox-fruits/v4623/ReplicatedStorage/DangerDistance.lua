local createVector = vector.create
local Realm = require(game.ReplicatedStorage.Util.Realm)
local ifCurrentRealmHasTagAsync = Realm.getIfCurrentRealmHasTagAsync("IsSecondSea")

local function generateBoundaryPoints()
	local result = {}

	for _, child in ipairs(workspace._WorldOrigin.Locations:GetChildren()) do
		local midpointX = (child.Size.X + child.Mesh.Scale.X) / 2

		if not (midpointX > 400) or not (child.CFrame.Position.Y - midpointX <= 0) or child.Name:match("Trial") or not ((child.Position * createVector(
			1,
			0,
			1
		)).Magnitude < 30000) then
			continue
		end

		if child.Name == "Sea" then
			continue
		end

		local X = child.Mesh.Scale.X
		local _ = child.Name == "Graveyard Island" or child.Name == "Cursed Ship" or child.Name == "Forgotten Island"
		table.insert(result, { Vector3.new(child.Position.X, 0, child.Position.Z), X })
	end

	return result
end

function isLeft(p, p2, p3)
	return (p2.X - p.X) * (p3.Y - p.Y) - (p2.Y - p.Y) * (p3.X - p.X) > 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getOrientation(p, p2, p3)
	local v = (p2.Y - p.Y) * (p3.X - p2.X) - (p2.X - p.X) * (p3.Y - p2.Y)

	if v == 0 then
		return 0
	end

	if v > 0 then
		return 1
	end

	return 2
end

function convexHull(list)
	local count = #list

	if count < 3 then
		return
	end

	local v = 1
	local result = {}

	for i = 2, count do
		if list[i].X < list[v].X then
			v = i
		end
	end

	local v2 = v

	while true do
		table.insert(result, list[v2])
		local v3 = v2 % count + 1

		for i = 1, count do
			if getOrientation(list[v2], list[i], list[v3]) == 2 then
				v3 = i
			end
		end

		if v3 == v then
			return result
		else
			v2 = v3
		end
	end
end

function getCentroid(list)
	local v = createVector(0, 0, 0)

	for _, v2 in pairs(list) do
		v += v2[1]
	end

	return v / #list
end

function angleFromCentroid(p, p2)
	local v = math.atan2(p2.Y - p.Y, p2.X - p.X)

	if v < 0 then
		return v + 6.283185307179586
	end

	return v
end

function pointToLineDist(p, p2, p3)
	return math.abs((p3.Y - p2.Y) * p.X - (p3.X - p2.X) * p.Y + p3.X * p2.Y - p3.Y * p2.X) / math.sqrt((p3.Y - p2.Y) ^ 2 + (p3.X - p2.X) ^ 2)
end

function sortEdgesByAngle(list, p)
	local result = {}

	for i = 1, #list do
		local v = i % #list + 1
		table.insert(result, {
			angle = angleFromCentroid(p, list[i]),
			i = i,
			j = v
		})
	end

	table.sort(result, function(a, b)
		return a.angle < b.angle
	end)
	result[1].angle = 0
	return result
end

function findEdge(total, list)
	if total < 0 then
		total += 6.283185307179586
	end

	local count = #list

	for i = 1, count do
		if list[i].angle <= total and total <= list[i % count + 1].angle then
			return list[i].i, list[i].j
		end
	end

	return 1, count
end

function pointToHullDistFast(p, p2, p3, p4)
	local v = angleFromCentroid(p3, p)
	local edge, v2 = findEdge(v, p4)

	if not (edge and v2) then
		return 1e999
	end

	local v3 = pointToLineDist(p, p2[edge], p2[v2])

	if isLeft(p2[edge], p2[v2], p) then
		return -v3
	end

	return v3
end

local RunService = game:GetService("RunService")
local v, v2, v3

if RunService:IsServer() then
	v = generateBoundaryPoints()
	v2 = getCentroid(v)
	local remoteFunction = Instance.new("RemoteFunction")
	remoteFunction.Name = "DangerDistance"

	remoteFunction.OnServerInvoke = function(_)
		return v
	end

	remoteFunction.Parent = game.ReplicatedStorage.Remotes
	v3 = { 0, 0 }

	for _, v4 in pairs(v) do
		local magnitude = (v2 - v4[1]).Magnitude
		v3 = { math.max(v3[1], v4[2]), (math.max(magnitude, v3[2])) }
	end
else
	if not game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DangerDistance", 900) then
		return function(_)
			return nil
		end
	end

	v = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DangerDistance"):InvokeServer()
	v2 = getCentroid(v)
	v3 = { 0, 0 }

	for _, v4 in pairs(v) do
		local magnitude = (v2 - v4[1]).Magnitude
		v3 = { math.max(v3[1], v4[2]), (math.max(magnitude, v3[2])) }
	end
end

return function(vector2)
	if typeof(vector2) == "CFrame" then
		vector2 = Vector3.new(vector2.Position.X, 0, vector2.Position.Z)
	elseif typeof(vector2) == "Vector2" then
		vector2 = Vector3.new(vector2.X, 0, vector2.Y)
	end

	if not ifCurrentRealmHasTagAsync then
		return math.max((vector2 - v2).Magnitude - v3[1] - v3[2] / 2, 0) - 1000
	end

	local v4 = 2000

	for _, v5 in pairs(v) do
		local v6 = (vector2 - v5[1]).Magnitude - v5[2] / 2

		if v6 < v4 then
			v4 = v6
		end
	end

	if v4 > 0 then
		return v4 + 2000
	end

	return v4
end