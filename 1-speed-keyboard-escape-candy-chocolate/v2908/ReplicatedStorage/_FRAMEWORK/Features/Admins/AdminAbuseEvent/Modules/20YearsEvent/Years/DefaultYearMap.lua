require(script.Parent.Parent.Types)

local function checkYearMapReady(p, p2: number)
	local model = p.yearMaps:FindFirstChild((tostring(p2)))

	if not (model and model:IsA("Model")) then
		return false, nil, nil, string.format("20th Anniversary map template for year %d is missing", p2)
	end

	local part = model:FindFirstChild(p.spawnPartName, true)

	if part and part:IsA("BasePart") then
		return true, model, part, nil
	end

	return false, nil, nil, string.format("20th Anniversary map for year %d requires a BasePart named Spawn", p2)
end

local DefaultYearMap = {
	getMapName = function(p: number)
		return (`20Anniversary_{p}`)
	end
}

function DefaultYearMap.watchMap(p, p2: number, callback)
	local mapName = DefaultYearMap.getMapName(p2)
	local mapParent = p.mapParent
	local v = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onMapAdded(model)
		if model.Name == mapName and model:IsA("Model") and not v then
			v = callback(model)
		end
	end

	local function detachMap()
		if v then
			v()
			v = nil
		end
	end

	local childAddedConnection = mapParent.ChildAdded:Connect(onMapAdded)
	local childRemovedConnection = mapParent.ChildRemoved:Connect(function(child)
		if child.Name == mapName and v then
			v()
			v = nil
		end
	end)

	for _, child in mapParent:GetChildren() do
		onMapAdded(child) -- equivalent call inferred; original call site unknown
	end

	return function()
		childAddedConnection:Disconnect()
		childRemovedConnection:Disconnect()

		if v then
			v()
			v = nil
		end
	end
end

function DefaultYearMap.load(p, p2: number)
	if p.preloadedMap then
		return p.preloadedMap, nil
	end

	local v, v2, v3, v4 = checkYearMapReady(p, p2)

	if not v then
		return nil, v4
	end

	local clone = v2:Clone()
	clone.Name = DefaultYearMap.getMapName(p2)
	clone.Parent = p.mapParent
	return {
		map = clone,
		spawn = clone:FindFirstChild(v3.Name, true),
		cleanup = function()
			clone:Destroy()
		end
	}, nil
end

return DefaultYearMap