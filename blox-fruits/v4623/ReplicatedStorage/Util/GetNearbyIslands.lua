local _ = {
	["Sea Beast"] = true
}
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local locations = workspace._WorldOrigin:WaitForChild("Locations")
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function addIsland(child)
	table.insert(v, {
		Position = child.Position,
		Size = child.Size.X * child.Mesh.Scale.X,
		Part = child,
		Name = child.Name
	})
end

local RunService = game:GetService("RunService")

if RunService:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	for _, child in pairs(locations:GetChildren()) do
		addIsland(child) -- equivalent call inferred; original call site unknown
	end

	locations.ChildAdded:Connect(function(child)
		if not child:FindFirstChild("Mesh") then
			child:WaitForChild("Mesh")
		end

		if child.Parent then
			addIsland(child) -- equivalent call inferred; original call site unknown
		end
	end)
	locations.ChildRemoved:Connect(function(child)
		for i = #v, 1, -1 do
			if v[i].Part ~= child then
				continue
			end

			table.remove(v, i)
			break
		end
	end)
end

local GetNearbyIslands = {}

function GetNearbyIslands.GetNearestIsland(vector: Vector3)
	assert(vector)
	assert(typeof(vector) == "Vector3")
	local v2 = nil

	for _, _ in pairs(v) do
		for _, v3 in pairs(v) do
			if not v2 or (v3.Position - vector).Magnitude < (v2.Position - vector).Magnitude then
				v2 = v3
			end
		end
	end

	return v2
end

function GetNearbyIslands.CheckForIslands(data)
	assert(typeof(data) == "table")
	assert(data.point)
	local magnitude2 = 1e999
	local v3 = nil
	local distance = 0

	for _, v5 in pairs(v) do
		local magnitude = (v5.Position - data.point).Magnitude
		local halfSize = v5.Size / 2

		if not (magnitude <= halfSize + (data.added or 0)) or data.exclude and data.exclude[v5.Name] or not (not data.include or data.include[v5.Name]) or not (magnitude < magnitude2) then
			continue
		end

		distance = magnitude - halfSize
		v3 = v5
		magnitude2 = magnitude
	end

	if v3 then
		return {
			Position = v3.Position,
			Size = v3.Size,
			Name = v3.Name,
			Part = v3.Part,
			Distance = distance,
			Magnitude = magnitude2
		}
	end
end

return GetNearbyIslands