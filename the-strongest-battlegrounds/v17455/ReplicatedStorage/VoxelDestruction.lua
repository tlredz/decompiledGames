local createVector = vector.create
local VoxelDestruction = {
	VoxelSize = 2,
	CleanupTime = 30,
	VoxelScalar = createVector(0.9, 0.95, 0.9),
	MaxPartsPerVoxelization = 50,
	caches = {},
	overlapParams = nil,
	originalPartInfo = {},
	splitPartsToSourcePart = {},
	sourcePartToSplits = {}
}
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

if not RunService:IsServer() then
	local _ = Players.LocalPlayer
end

local RegionModule = require(script.RegionModule)
local PartCache = require(script.PartCache)
local cframe = CFrame.new(0, 10000, 0)

-- equivalent calls inferred from this helper; original call sites unknown
local function cacheKeyForPart(data)
	return data.Material.Name .. tostring(data.Color) .. data.Transparency
end

local function splitPart(instance, p, p2)
	local size = instance.Size
	local vector2, vector3

	if p == "X" then
		vector2 = Vector3.new(size.X / 2, size.Y, size.Z)
		vector3 = Vector3.new(p2 / 4, 0, 0)
	elseif p == "Y" then
		vector2 = Vector3.new(size.X, size.Y / 2, size.Z)
		vector3 = Vector3.new(0, p2 / 4, 0)
	else
		vector2 = Vector3.new(size.X, size.Y, size.Z / 2)
		vector3 = Vector3.new(0, 0, p2 / 4)
	end

	local v = {
		Size = vector2,
		Part = instance.Part
	}
	local v2 = {
		Size = vector2,
		Part = instance.Part
	}
	v.CFrame = instance.CFrame * CFrame.new(-vector3)
	v2.CFrame = instance.CFrame * CFrame.new(vector3)
	return v, v2
end

local function allCornersInsideTestBox(instance, instance2)
	local size = instance2.Size
	local cFrame = instance2.CFrame
	local halfSize = instance.Size / 2
	local halfSize2 = size / 2
	local v3 = instance.CFrame:Inverse() * cFrame

	local function isPointInsideBox(data, data2)
		return math.abs(data.X) <= data2.X and math.abs(data.Y) <= data2.Y and math.abs(data.Z) <= data2.Z
	end

	for i = -1, 1, 2 do
		for i2 = -1, 1, 2 do
			for i3 = -1, 1, 2 do
				local v4 = v3 * Vector3.new(i * halfSize2.X, i2 * halfSize2.Y, i3 * halfSize2.Z)
				local v5

				if math.abs(v4.X) <= halfSize.X and math.abs(v4.Y) <= halfSize.Y then
					v5 = math.abs(v4.Z) <= halfSize.Z
				else
					v5 = false
				end

				if not v5 then
					return false
				end
			end
		end
	end

	return true
end

local function allCornersInsideTestSphere(data, p, instance)
	local size = instance.Size
	local cFrame = instance.CFrame
	local halfSize = size / 2

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isPointInsideSphere(data2)
		local v2 = data2.X - data.X
		local v3 = data2.Y - data.Y
		local v4 = data2.Z - data.Z
		return v2 * v2 + v3 * v3 + v4 * v4 <= p * p
	end

	for i = -1, 1, 2 do
		for i2 = -1, 1, 2 do
			for i3 = -1, 1, 2 do
				if not isPointInsideSphere(cFrame * Vector3.new(i * halfSize.X, i2 * halfSize.Y, i3 * halfSize.Z)) then
					return false
				end
			end
		end
	end

	return true
end

local function dividePart(p, p2)
	local size = p.Size
	local v = math.max(size.X, size.Y, size.Z)
	local v2 = v == size.X and "X" or v == size.Y and "Y" or "Z"
	local v3 = p2 or VoxelDestruction.VoxelSize

	if v3 < v and v3 < v / 2 then
		local v4, v5 = splitPart(p, v2, v)
		return v4, v5, math.max(v4.Size.X, v4.Size.Y, v4.Size.Z) <= v3
	else
		return p, nil, true
	end
end

local function areAnyPlayersInBox(size, cFrame)
	local v = RegionModule.new(cFrame, size)

	for _, v2 in Players:GetPlayers() do
		local character = v2.Character

		if not (character and character:FindFirstChild("HumanoidRootPart")) then
			continue
		end

		local humanoidRootPart = character.HumanoidRootPart
		local v3 = humanoidRootPart.Size + createVector(0, 3, 0)

		if v:CastBox(humanoidRootPart.CFrame, v3) then
			return true
		end
	end
end

local function restorePart(instance)
	local originalPartInfo = VoxelDestruction.originalPartInfo
	local sourcePartToSplits = VoxelDestruction.sourcePartToSplits
	local splitPartsToSourcePart = VoxelDestruction.splitPartsToSourcePart
	local v = originalPartInfo[instance]

	if not v then
		return
	end

	originalPartInfo[instance] = nil
	local sourcePartToSplit = sourcePartToSplits[instance]
	sourcePartToSplits[instance] = nil
	local v2 = cacheKeyForPart(instance) -- equivalent call inferred; original call site unknown
	local cach = VoxelDestruction.caches[v2]

	if sourcePartToSplit then
		for k, v3 in sourcePartToSplit do
			if k == "LastCut" then
				continue
			end

			for _, v4 in v3 do
				if not (v4.OwnedPart and v4.OwnedPart ~= v4.Part) then
					continue
				end

				splitPartsToSourcePart[v4.OwnedPart] = nil
				sourcePartToSplits[v4.OwnedPart] = nil
				v4.OwnedPart.Anchored = true
				v4.OwnedPart.AssemblyLinearVelocity = createVector(0, 0, 0)
				v4.OwnedPart.AssemblyAngularVelocity = createVector(0, 0, 0)
				CollectionService:RemoveTag(v4.OwnedPart, "VoxelDebris")

				if v4.OwnedPart.Parent then
					v4.OwnedPart.Parent = workspace.Built
				end

				if CollectionService:HasTag(v4.OwnedPart, "PSBuilt") then
					CollectionService:RemoveTag(v4.OwnedPart, "PSBuilt")
					CollectionService:AddTag(v4.OwnedPart, "PSBuilt")
				end

				cach:Return(v4.OwnedPart)
				v4.OwnedPart = nil
			end
		end
	end

	instance.AssemblyLinearVelocity = createVector(0, 0, 0)
	instance.AssemblyAngularVelocity = createVector(0, 0, 0)

	if instance.Parent then
		instance.Parent = workspace.Built
	end

	instance.Anchored = true

	if CollectionService:HasTag(instance, "PSBuilt") then
		CollectionService:RemoveTag(instance, "PSBuilt")
		CollectionService:AddTag(instance, "PSBuilt")
	end

	return v.CFrame
end

local function render(items, p, list, list2, p2)
	local originalPartInfo = VoxelDestruction.originalPartInfo
	local splitPartsToSourcePart = VoxelDestruction.splitPartsToSourcePart
	local sourcePartToSplits = VoxelDestruction.sourcePartToSplits
	local v = table.create(256)
	local v2 = table.create(256)
	local count = 0

	for k, item in items do
		if p then
			local v3 = originalPartInfo[k]

			if v3 and v3.Final then
				count += 1
				table.insert(list2, v3)
				table.insert(list, v3.OwnedPart)
				sourcePartToSplits[k] = {
					LastCut = os.clock()
				}
				continue
			else
				k.Anchored = true
				table.insert(v, k)
				table.insert(v2, cframe)
			end
		end

		if #item == 0 and not p then
			table.insert(list, k)
			table.insert(list2, originalPartInfo[k])
			sourcePartToSplits[k] = {
				LastCut = os.clock()
			}
		else
			if not p then
				k.Anchored = true
				table.insert(v, k)
				table.insert(v2, cframe)
			end

			local v3 = splitPartsToSourcePart[k]
			local v4 = {
				LastCut = os.clock()
			}

			if v3 then
				v4 = sourcePartToSplits[v3]

				if v4 then
					v4.LastCut = os.clock()
				end
			end

			local v5 = cacheKeyForPart(k) -- equivalent call inferred; original call site unknown
			local cach = VoxelDestruction.caches[v5]

			if not cach then
				local clone = k:Clone()
				clone:ClearAllChildren()
				cach = PartCache.new(clone, VoxelDestruction.currentMap, 25)
				VoxelDestruction.caches[v5] = cach
			end

			for _, v6 in item do
				if v6.OwnedPart then
					continue
				end

				local ownedPart = cach:Get()
				table.insert(v, ownedPart)
				table.insert(v2, v6.CFrame)
				v6.OwnedPart = ownedPart
				splitPartsToSourcePart[ownedPart] = v3 or k

				if v6.Final then
					ownedPart.Size = v6.Size * VoxelDestruction.VoxelScalar
					table.insert(list, ownedPart)
					table.insert(list2, v6)
				else
					ownedPart.Size = v6.Size
				end
			end

			table.insert(v4, item)
			sourcePartToSplits[v3 or k] = v4
		end
	end

	if p2 then
		local _ = p2.DeleteClose
	end

	if #list2 > VoxelDestruction.MaxPartsPerVoxelization then
		local clone = table.clone(list2)
		table.clear(list)
		table.clear(list2)

		for k, v3 in clone do
			if k <= VoxelDestruction.MaxPartsPerVoxelization then
				table.insert(list2, v3)
				table.insert(list, v3.OwnedPart)
			else
				local index = table.find(v, v3.OwnedPart)

				if index then
					table.remove(v, index)
					table.remove(v2, index)
				end

				VoxelDestruction.HideVoxel(v3.OwnedPart, v3)
			end
		end
	end

	workspace:BulkMoveTo(v, v2, Enum.BulkMoveMode.FireCFrameChanged)
end

function VoxelDestruction:SetMap()
	if typeof(self) == "table" then
		error("expected '.' to call SetMap (used ':')")
	end

	self.Parent = workspace
	local caches = VoxelDestruction.caches
	VoxelDestruction.currentMap = self
	local overlapParams = OverlapParams.new()
	overlapParams.FilterDescendantsInstances = { self }
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	VoxelDestruction.overlapParams = overlapParams
	local v = {}
	task.delay(1, function()
		for _, part in self:GetDescendants() do
			if not (part:IsA("Part") and part.Shape == Enum.PartType.Block) then
				continue
			end

			local v2 = cacheKeyForPart(part) -- equivalent call inferred; original call site unknown
			local v3 = v[v2]

			if v3 then
				v3.count += 1
			else
				v[v2] = {
					count = 1,
					object = part
				}
			end
		end

		for k, v2 in v do
			local v3 = math.min(250, v2.count)
			local cach = caches[k]

			if cach and cach.amount < v3 then
				cach:ExpandCache(v3 - cach.amount)
			else
				local clone = v2.object:Clone()
				clone:ClearAllChildren()
				caches[k] = PartCache.new(clone, VoxelDestruction.currentMap, v3)
			end
		end
	end)
end

function VoxelDestruction.GetMap()
	return VoxelDestruction.currentMap
end

function VoxelDestruction.SetVoxelSize(voxelSize)
	if typeof(voxelSize) == "table" then
		error("expected '.' to call SetVoxelSize (used ':')")
	end

	VoxelDestruction.VoxelSize = voxelSize
end

function VoxelDestruction.SetCleanupTime(cleanupTime)
	if typeof(cleanupTime) == "table" then
		error("expected '.' to call SetCleanupTime (used ':')")
	end

	VoxelDestruction.CleanupTime = cleanupTime
end

function VoxelDestruction.VoxelizeArea(p, p2, p3)
	if typeof(p) == "table" then
		error("expected '.' to call VoxelizeArea (used ':')")
	end

	local partBoundsInBox = workspace:GetPartBoundsInBox(p, p2, p3.psbuilt or VoxelDestruction.overlapParams)
	local v = RegionModule.new(p, p2)
	local originalPartInfo = VoxelDestruction.originalPartInfo
	local splitPartsToSourcePart = VoxelDestruction.splitPartsToSourcePart
	local sourcePartToSplits = VoxelDestruction.sourcePartToSplits
	local v2 = {}
	local v3 = {}
	local v4 = {}
	local v5 = {}

	for _, v6 in partBoundsInBox do
		if not v6:IsDescendantOf(VoxelDestruction.currentMap) or not v6:GetAttribute("Destructible") or table.find(
			p3.Blacklist or {},
			v6
		) then
			continue
		end

		if not (v6.Anchored and v6.Shape == Enum.PartType.Block) then
			continue
		end

		local v7 = {
			OwnedPart = v6,
			Part = v6,
			CFrame = v6.CFrame,
			Size = v6.Size
		}
		table.insert(v2, v7)
		v3[v6] = {}

		if not (splitPartsToSourcePart[v6] or sourcePartToSplits[v6]) then
			originalPartInfo[v6] = v7
		end
	end

	while #v2 > 0 do
		local v6 = {}

		for _, v7 in v2 do
			local v8 = v3[v7.Part]
			local v9, v10, v11 = dividePart(v7)

			if v10 then
				if v11 then
					v9.Final = true
					v10.Final = true
					table.insert(v8, v9)
					table.insert(v8, v10)
				else
					local v12 = v:CastBox(v9.CFrame, v9.Size)
					local v13 = v:CastBox(v10.CFrame, v10.Size)

					if v12 then
						table.insert(v6, v9)
					else
						table.insert(v8, v9)
					end

					if v13 then
						table.insert(v6, v10)
					else
						table.insert(v8, v10)
					end
				end
			else
				if v11 then
					v7.Final = true
				end

				if not v7.OwnedPart then
					table.insert(v8, v7)
				end
			end
		end

		v2 = v6
	end

	render(v3, false, v4, v5, p3)
	return v4, v5
end

function VoxelDestruction.VoxelizeRadius(p, p2, data)
	if typeof(p) == "table" then
		error("expected '.' to call VoxelizeRadius (used ':')")
	end

	local partBoundsInRadius = workspace:GetPartBoundsInRadius(p, p2, data.psbuilt or VoxelDestruction.overlapParams)

	for k, v in pairs(partBoundsInRadius) do
		if not v:IsDescendantOf(workspace.Built) then
			partBoundsInRadius[k] = nil
		end
	end

	local originalPartInfo = VoxelDestruction.originalPartInfo
	local splitPartsToSourcePart = VoxelDestruction.splitPartsToSourcePart
	local sourcePartToSplits = VoxelDestruction.sourcePartToSplits
	local v = {}
	local v2 = {}
	local v3 = {}
	local v4 = {}

	for _, v5 in partBoundsInRadius do
		if not v5:IsDescendantOf(VoxelDestruction.currentMap) or not v5:GetAttribute("Destructible") or table.find(
			data.Blacklist or {},
			v5
		) then
			continue
		end

		if not (v5.Shape == Enum.PartType.Block and v5.Anchored) then
			continue
		end

		local v6 = {
			OwnedPart = v5,
			Part = v5,
			CFrame = v5.CFrame,
			Size = v5.Size
		}
		table.insert(v, v6)
		v2[v5] = {}

		if not (splitPartsToSourcePart[v5] or sourcePartToSplits[v5]) then
			originalPartInfo[v5] = v6
		end
	end

	while #v > 0 do
		local v5 = {}

		for _, v6 in v do
			local v7 = v2[v6.Part]
			local v8, v9, v10 = dividePart(v6, data.VoxelSize)

			if v9 then
				if v10 then
					v8.Final = true
					v9.Final = true
					table.insert(v7, v8)
					table.insert(v7, v9)
				else
					local boxSphereCollision = RegionModule.BoxSphereCollision(v8.CFrame, v8.Size, p, p2)
					local boxSphereCollision2 = RegionModule.BoxSphereCollision(v9.CFrame, v9.Size, p, p2)

					if boxSphereCollision then
						table.insert(v5, v8)
					else
						table.insert(v7, v8)
					end

					if boxSphereCollision2 then
						table.insert(v5, v9)
					else
						table.insert(v7, v9)
					end
				end
			else
				v6.Final = true

				if not v6.OwnedPart then
					table.insert(v7, v6)
				end
			end
		end

		v = v5
	end

	render(v2, false, v3, v4, data)
	return v3, v4
end

function VoxelDestruction.DeleteArea(p, p2, data)
	if typeof(p) == "table" then
		error("expected '.' to call DeleteArea (used ':')")
	end

	local partBoundsInBox = workspace:GetPartBoundsInBox(p, p2, data.psbuilt or VoxelDestruction.overlapParams)
	local v = RegionModule.new(p, p2)
	local originalPartInfo = VoxelDestruction.originalPartInfo
	local splitPartsToSourcePart = VoxelDestruction.splitPartsToSourcePart
	local sourcePartToSplits = VoxelDestruction.sourcePartToSplits
	local flag = not data.DontSimulate
	local v2 = {}
	local v3 = {}
	local v4 = {}
	local v5 = {}

	for _, v6 in partBoundsInBox do
		if not v6:IsDescendantOf(VoxelDestruction.currentMap) or not v6:GetAttribute("Destructible") or table.find(
			data.Blacklist or {},
			v6
		) then
			continue
		end

		if v6.Shape ~= Enum.PartType.Block then
			continue
		end

		local v7 = {
			OwnedPart = v6,
			Part = v6,
			CFrame = v6.CFrame,
			Size = v6.Size
		}

		if not (splitPartsToSourcePart[v6] or sourcePartToSplits[v6]) then
			originalPartInfo[v6] = v7
		end

		if v6.Anchored then
			v2[v6] = {}
			table.insert(v3, v7)
		elseif allCornersInsideTestBox(v, v7) then
			VoxelDestruction.HideVoxel(v6)
		end
	end

	while #v3 > 0 do
		local v6 = {}

		for _, v7 in v3 do
			local v8 = v2[v7.Part]
			local v9, v10, _ = dividePart(v7, data.VoxelSize)

			if v10 then
				local v11 = v:CastBox(v9.CFrame, v9.Size)
				local v12 = v:CastBox(v10.CFrame, v10.Size)

				if v11 then
					if not allCornersInsideTestBox(v, v9) then
						table.insert(v6, v9)
					end
				else
					table.insert(v8, v9)
				end

				if v12 then
					if not allCornersInsideTestBox(v, v10) then
						table.insert(v6, v10)
					end
				else
					table.insert(v8, v10)
				end
			elseif not allCornersInsideTestBox(v, v7) and v:CastBox(v7.CFrame, v7.Size) and flag then
				v7.Final = true
				table.insert(v8, v7)
			end
		end

		v3 = v6
	end

	render(v2, true, v4, v5, data)
	return v4, v5
end

function VoxelDestruction.DeleteRadius(p, p2, data)
	if typeof(p) == "table" then
		error("expected '.' to call DeleteRadius (used ':')")
	end

	local partBoundsInRadius = workspace:GetPartBoundsInRadius(p, p2, data.psbuilt or VoxelDestruction.overlapParams)
	local originalPartInfo = VoxelDestruction.originalPartInfo
	local splitPartsToSourcePart = VoxelDestruction.splitPartsToSourcePart
	local sourcePartToSplits = VoxelDestruction.sourcePartToSplits
	local flag = not data.DontSimulate
	local v = {}
	local v2 = {}
	local v3 = {}
	local v4 = {}

	for _, v5 in partBoundsInRadius do
		if not v5:IsDescendantOf(VoxelDestruction.currentMap) or not v5:GetAttribute("Destructible") or table.find(
			data.Blacklist or {},
			v5
		) then
			continue
		end

		if v5.Shape ~= Enum.PartType.Block then
			continue
		end

		local v6 = {
			OwnedPart = v5,
			Part = v5,
			CFrame = v5.CFrame,
			Size = v5.Size
		}

		if not (splitPartsToSourcePart[v5] or sourcePartToSplits[v5]) then
			originalPartInfo[v5] = v6
		end

		if v5.Anchored then
			v[v5] = {}
			table.insert(v2, v6)
		elseif allCornersInsideTestSphere(p, p2, v6) then
			VoxelDestruction.HideVoxel(v5)
		end
	end

	while #v2 > 0 do
		local v5 = {}

		for _, v6 in v2 do
			local v7 = v[v6.Part]
			local v8, v9, _ = dividePart(v6, data.VoxelSize)

			if v9 then
				local boxSphereCollision = RegionModule.BoxSphereCollision(v8.CFrame, v8.Size, p, p2)
				local boxSphereCollision2 = RegionModule.BoxSphereCollision(v9.CFrame, v9.Size, p, p2)

				if boxSphereCollision then
					if not allCornersInsideTestSphere(p, p2, v8) then
						table.insert(v5, v8)
					end
				else
					table.insert(v7, v8)
				end

				if boxSphereCollision2 then
					if not allCornersInsideTestSphere(p, p2, v9) then
						table.insert(v5, v9)
					end
				else
					table.insert(v7, v9)
				end
			elseif not allCornersInsideTestSphere(p, p2, v6) and RegionModule.BoxSphereCollision(
				v6.CFrame,
				v6.Size,
				p,
				p2
			) and flag then
				v6.Final = true
				table.insert(v7, v6)
			end
		end

		v2 = v5
	end

	render(v, true, v3, v4, data)
	return v3, v4
end

function VoxelDestruction:HideVoxel(p2)
	local sourcePartToSplits = VoxelDestruction.sourcePartToSplits
	local splitPartsToSourcePart = VoxelDestruction.splitPartsToSourcePart

	if sourcePartToSplits[self] then
		self.Anchored = true
		self.CFrame = cframe
	else
		local v = splitPartsToSourcePart[self]

		if not v then
			return
		end

		local sourcePartToSplit = sourcePartToSplits[v]
		local v2 = cacheKeyForPart(v) -- equivalent call inferred; original call site unknown
		local cach = VoxelDestruction.caches[v2]

		if p2 then
			local ownedPart = p2.OwnedPart
			ownedPart.Anchored = true
			ownedPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			ownedPart.AssemblyAngularVelocity = createVector(0, 0, 0)
			cach:Return(self)
			p2.OwnedPart = nil
		else
			for k, v3 in sourcePartToSplit do
				if k == "LastCut" then
					continue
				end

				for _, v5 in v3 do
					local ownedPart = v5.OwnedPart

					if ownedPart ~= self then
						continue
					end

					splitPartsToSourcePart[ownedPart] = nil
					ownedPart.Anchored = true
					ownedPart.AssemblyLinearVelocity = createVector(0, 0, 0)
					ownedPart.AssemblyAngularVelocity = createVector(0, 0, 0)
					cach:Return(ownedPart)
					v5.OwnedPart = nil
					break
				end
			end
		end
	end
end

task.spawn(function()
	local sourcePartToSplits = VoxelDestruction.sourcePartToSplits
	local originalPartInfo = VoxelDestruction.originalPartInfo
	warn("lol")

	while true do
		task.wait(1)
		local v = {}
		local v2 = {}

		for k, sourcePartToSplit in sourcePartToSplits do
			warn("d")

			if not (os.clock() - sourcePartToSplit.LastCut >= VoxelDestruction.CleanupTime) then
				continue
			end

			print("nb")
			local v3 = originalPartInfo[k]

			if not v3 or areAnyPlayersInBox(k.Size, v3.CFrame) then
				continue
			end

			local v4 = restorePart(k)

			if not v4 then
				continue
			end

			table.insert(v, k)
			table.insert(v2, v4)
		end

		if #v > 0 then
			workspace:BulkMoveTo(v, v2, Enum.BulkMoveMode.FireCFrameChanged)
		end
	end
end)
return VoxelDestruction