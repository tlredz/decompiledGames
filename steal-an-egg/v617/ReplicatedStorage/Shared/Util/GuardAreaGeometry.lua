local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local strict = t.strict(t.Instance)
local strict2 = t.strict(t.instanceIsA("BasePart"))
local strict3 = t.strict(t.Vector3)

local function depthPast(instance, vector: Vector3)
	return instance.CFrame.LookVector:Dot(vector - instance.Position)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function checkStep(instance, vector: Vector3, vector2: Vector3)
	strict2(instance)
	strict3(vector)
	strict3(vector2)
end

local GuardAreaGeometry = {}

function GuardAreaGeometry.SignedDistanceToLine(p, vector: Vector3)
	strict2(p)
	strict3(vector)
	return depthPast(p, vector)
end

function GuardAreaGeometry.IsPastLine(instance, vector: Vector3)
	strict2(instance)
	strict3(vector)
	return instance.CFrame.LookVector:Dot(vector - instance.Position) > 0
end

function GuardAreaGeometry.CrossedLineInward(instance, vector: Vector3, vector2: Vector3)
	checkStep(instance, vector, vector2) -- equivalent call inferred; original call site unknown
	return instance.CFrame.LookVector:Dot(vector - instance.Position) <= 0 and instance.CFrame.LookVector:Dot(vector2 - instance.Position) > 0
end

function GuardAreaGeometry.CrossedLineOutward(instance, vector: Vector3, vector2: Vector3)
	checkStep(instance, vector, vector2) -- equivalent call inferred; original call site unknown
	return instance.CFrame.LookVector:Dot(vector - instance.Position) > 0 and instance.CFrame.LookVector:Dot(vector2 - instance.Position) <= 0
end

function GuardAreaGeometry.IsWithinFootprint(instance, vector: Vector3)
	strict2(instance)
	strict3(vector)
	local pointToObjectSpace = instance.CFrame:PointToObjectSpace(vector)
	local v = instance.Size * 0.5
	return math.abs(pointToObjectSpace.X) <= v.X and math.abs(pointToObjectSpace.Z) <= v.Z
end

function GuardAreaGeometry.ReadAreaBounds(folder)
	strict(folder)
	assert(folder:IsA("Folder"), "Guard areas have to be collected under a single Folder")
	local result = {}

	for _, model in ipairs(folder:GetChildren()) do
		assert(model:IsA("Model"), (`{model:GetFullName()} sits under GuardAreas but is not a Model`))
		local bounds = model.Bounds
		assert(bounds:IsA("BasePart"), (`{model:GetFullName()} has a Bounds child that is not a part`))
		table.insert(result, {
			AreaId = model.Name,
			Bounds = bounds
		})
	end

	assert(#result > 0, "GuardAreas is empty; the game needs at least one guard area")
	return result
end

return GuardAreaGeometry