local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BoatPresentation = require(script.Parent.Parent.BoatPresentation)
local Marines = require(script.Parent.Marines)
require(script.Parent.Types)
local frozen = table.freeze({
	RowCapacity = 4,
	HullGap = 22,
	RowGap = 38,
	DeckHeightFraction = 0.35,
	DecorativeBrigadeBehindGap = 45,
	DecorativeBrigadeLateralGap = 42,
	DecorativeBrigadeDepthStagger = 14,
	DecorativeBrigadeYaw = 0.4188790204786391,
	WaterPlaneSize = 50000,
	WaterEffectTag = "WaterEffect"
})
local v = {}
local v2 = {}

function v.createWater(parent, vector2: Vector3)
	local assets = ReplicatedStorage:FindFirstChild("Assets") or ReplicatedStorage:WaitForChild("Assets", 5)
	local water = assets and assets:FindFirstChild("Water;")

	if not (water and water:IsA("BasePart")) then
		return nil, "ReplicatedStorage.Assets[Water;] is unavailable"
	end

	local clone = water:Clone()
	clone.Name = "LocalWater;"
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false
	clone.CastShadow = false
	clone.CFrame = CFrame.new(vector2 - createVector(0, 0.35, 0))
	local texture = clone:FindFirstChild("Texture")
	texture.Texture = "rbxassetid://9667785886"
	texture.Face = Enum.NormalId.Top
	texture.Transparency = 0.5
	texture.Color3 = Color3.fromRGB(255, 255, 255)
	texture.StudsPerTileU = 300
	texture.StudsPerTileV = 300
	local specialMesh = clone:FindFirstChildWhichIsA("SpecialMesh")

	if specialMesh then
		specialMesh.Scale = Vector3.new(frozen.WaterPlaneSize, 1, frozen.WaterPlaneSize)
	else
		local specialMesh2 = Instance.new("SpecialMesh")
		specialMesh2.MeshType = Enum.MeshType.Brick
		specialMesh2.Scale = Vector3.new(frozen.WaterPlaneSize, 1, frozen.WaterPlaneSize)
		specialMesh2.Parent = clone
	end

	clone.Parent = parent
	CollectionService:AddTag(clone, frozen.WaterEffectTag)
	return clone, nil
end

function v2.createWater(p, vector2: Vector3)
	return v.createWater(p, vector2)
end

function v.destroyShips(items)
	for _, item in items do
		item.Boat:Destroy()
	end
end

function v.createDecorativeBrigades(parent, p, p2, vector2: Vector3, vector3: Vector3, vector4: Vector3)
	local folder = Instance.new("Folder")
	folder.Name = "DecorativeBrigades"
	local v3 = math.max(p2.Size.X, p2.Size.Z)

	for i = 1, 2 do
		local namedFromCache, v4 = BoatPresentation.cloneNamedFromCache(
			p,
			"PirateBrigade",
			p2.Entry.SailColor,
			"Finale"
		)

		if not namedFromCache then
			folder:Destroy()
			return v4 or "a decorative finale Brigade failed to initialize"
		end

		namedFromCache.Name = `DecorativeBrigade{i}`

		for _, part in namedFromCache:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
		end

		local v5 = math.max(namedFromCache:GetExtentsSize().X, namedFromCache:GetExtentsSize().Z)
		local v6 = i == 1 and -1 or 1
		local v7 = v3 * 0.5 + v5 * 0.5 + frozen.DecorativeBrigadeBehindGap + (i - 1) * frozen.DecorativeBrigadeDepthStagger
		local v8 = v3 * 0.5 + frozen.DecorativeBrigadeLateralGap
		local v9 = vector2 - vector3 * v7 + vector4 * v8 * v6 + createVector(0, 1, 0) * BoatPresentation.getVerticalOffset("Brigade")
		local v10 = frozen.DecorativeBrigadeYaw * v6
		namedFromCache:PivotTo(CFrame.lookAt(v9, v9 + vector3) * CFrame.Angles(0, v10, 0))
		namedFromCache.Parent = folder
	end

	folder.Parent = parent
	return nil
end

function v.createBoats(parent, p, data, vector2: Vector3, vector3: Vector3, vector4: Vector3)
	local result = {}

	for _, ship in data.Ships do
		local cloneFromCache, v3 = BoatPresentation.cloneFromCache(p, ship, "Finale")

		if cloneFromCache then
			table.insert(result, {
				Boat = cloneFromCache,
				Entry = ship,
				Size = cloneFromCache:GetExtentsSize(),
				DeckY = vector2.Y
			})
		else
			v.destroyShips(result)
			return nil, v3
		end
	end

	local v3 = result[data.MainShipIndex]
	local v4 = math.max(v3.Size.X, v3.Size.Z)
	local v5 = {}

	for k, v6 in result do
		if k ~= data.MainShipIndex then
			table.insert(v5, v6)
		end
	end

	table.sort(v5, function(a, b)
		return math.max(a.Size.X, a.Size.Z) > math.max(b.Size.X, b.Size.Z)
	end)
	local v6 = {}

	for k, v7 in v5 do
		local v8 = math.floor((k - 1) / frozen.RowCapacity) + 1
		v6[v8] = math.max(v6[v8] or 0, (math.max(v7.Size.X, v7.Size.Z)))
	end

	local v7 = v4 * 0.5 + frozen.RowGap
	local v8 = {}

	for i = 1, #v6 do
		local v9 = v6[i]
		v8[i] = v7 + v9 * 0.5
		v7 += v9 + frozen.RowGap
	end

	local v9 = {
		[v3] = vector2
	}
	local v10 = {}
	local v11 = {}

	for k, v12 in v5 do
		local v13 = math.floor((k - 1) / frozen.RowCapacity) + 1
		local v14 = math.max(v12.Size.X, v12.Size.Z)
		local v15

		if (k - 1) % frozen.RowCapacity % 2 == 0 then
			local v16 = v11[v13] or frozen.HullGap * 0.5
			v15 = -(v16 + v14 * 0.5)
			v11[v13] = v16 + v14 + frozen.HullGap
		else
			local v16 = v10[v13] or frozen.HullGap * 0.5
			v15 = v16 + v14 * 0.5
			v10[v13] = v16 + v14 + frozen.HullGap
		end

		v9[v12] = vector2 + vector3 * v8[v13] + vector4 * v15
	end

	for _, v12 in result do
		local v13 = v9[v12] + createVector(0, 1, 0) * BoatPresentation.getVerticalOffset(v12.Entry.Boat)
		local cframe = CFrame.lookAt(v13, v13 + vector3)
		v12.Boat:PivotTo(cframe)
		v12.Boat.Parent = parent
		v12.DeckY = v13.Y + math.clamp(v12.Size.Y * frozen.DeckHeightFraction, 4, 18)
	end

	local v12 = data.Variant == "Success" and v.createDecorativeBrigades(parent, p, v3, vector2, vector3, vector4)

	if not v12 then
		return result, nil
	end

	v.destroyShips(result)
	return nil, v12
end

function v2.build(p, p2, data, vector2: Vector3, vector3: Vector3, vector4: Vector3, p3, p4)
	local _, v3 = v.createWater(p, vector2)

	if v3 then
		return nil, v3
	end

	local boats, v4 = v.createBoats(p, p2, data, vector2, vector3, vector4)

	if not boats then
		return nil, v4 or "the finale ships failed to initialize"
	end

	local cameraTarget, marineEntrances, fruitJumps, fruitCrate, mainActor = Marines.create(
		p,
		p3,
		boats,
		data.MainShipIndex,
		p4,
		data.Variant,
		data.FailureTemplate
	)
	return {
		Ships = boats,
		CameraTarget = cameraTarget,
		MarineEntrances = marineEntrances,
		FruitJumps = fruitJumps,
		FruitCrate = fruitCrate,
		MainActor = mainActor
	}, nil
end

return table.freeze(v2)