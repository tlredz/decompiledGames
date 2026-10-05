local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local Archives = require(ReplicatedStorage.CAM.Client.Modules.Archives)
local RegionPin = require(script.Parent.RegionPin)
require(script.Parent.Types)

-- equivalent calls inferred from this helper; original call sites unknown
local function centreOf(grid)
	if grid == nil or grid[1] == nil then
		return nil
	end

	local v = grid[1]

	for _, v3 in grid do
		if not v3.IsParent then
			continue
		end

		v = v3
		break
	end

	return v.Center
end

local function stackOf(list, p)
	table.sort(list, function(a, b)
		if a.Sub == b.Sub then
			return a.Name < b.Name
		end

		return not a.Sub
	end)
	local v = {}

	for k, v2 in list do
		v[k] = p.Point(v2.Position)
	end

	for k, v2 in list do
		local stack = 0

		for i = 1, k - 1 do
			if (v[k] - v[i]).Magnitude < 0.03 then
				stack = math.max(stack, list[i].Stack + 1)
			end
		end

		v2.Stack = stack
	end
end

local function regionsOf(p)
	local Regions = require(ReplicatedStorage.Regions)
	local result = {}

	for k, region in Regions.Regions do
		local area = region.Area
		local grid

		if area ~= nil then
			grid = area.Grid
		end

		local v = centreOf(grid) -- equivalent call inferred; original call site unknown

		if v == nil then
			continue
		end

		table.insert(result, {
			Name = k,
			Position = Vector3.new(v.X, 0, v.Y),
			Sub = false,
			Stack = 0
		})
		local v2 = {}

		for _, v3 in grid do
			for k2, v4 in v3.ChildAreas or {} do
				if v2[k2] then
					continue
				end

				v2[k2] = true
				local v5 = centreOf(v4.Grid) -- equivalent call inferred; original call site unknown

				if v5 ~= nil then
					table.insert(result, {
						Name = k2,
						Position = Vector3.new(v5.X, 0, v5.Y),
						Sub = true,
						Stack = 0
					})
				end
			end
		end
	end

	stackOf(result, p)
	return result
end

return function(object, p)
	local value = object:Value({})
	object:Spawn(function()
		Archives.WaitLoaded()
		value:Set((regionsOf(p)))
	end)
	return object:Create("Frame")({
		Name = "Regions",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		object:Iterate(value, function(_, p2, p3)
			return RegionPin(p3, p, p2)
		end)
	})
end