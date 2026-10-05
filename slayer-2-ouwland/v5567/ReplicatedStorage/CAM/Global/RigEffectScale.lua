local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = nil
local RigEffectScale = {}

local function worldHalfExtent(cframe: CFrame, vector: Vector3)
	local v2 = vector.X * 0.5
	local v3 = vector.Y * 0.5
	local v4 = vector.Z * 0.5
	local rightVector = cframe.RightVector
	local upVector = cframe.UpVector
	local lookVector = cframe.LookVector
	return (Vector3.new(
		v2 * math.abs(rightVector.X) + v3 * math.abs(upVector.X) + v4 * math.abs(lookVector.X),
		v2 * math.abs(rightVector.Y) + v3 * math.abs(upVector.Y) + v4 * math.abs(lookVector.Y),
		v2 * math.abs(rightVector.Z) + v3 * math.abs(upVector.Z) + v4 * math.abs(lookVector.Z)
	))
end

local v2 = {
	Accessories = true,
	Tool_Accessories = true,
	Weapon_Unequipped_Config = true
}

local function worn(instance)
	return v2[instance.Name] == true or (instance:IsA("Accessory") or instance:IsA("Tool"))
end

function RigEffectScale.BodyBox(instance)
	local children = { instance }
	local vector = nil
	local vector2 = nil

	while #children > 0 do
		for _, child in table.remove(children):GetChildren() do
			if v2[child.Name] == true or (child:IsA("Accessory") or child:IsA("Tool")) then
				continue
			end

			if child:IsA("BasePart") then
				local v3 = worldHalfExtent(child.CFrame, child.Size)
				local v4 = child.Position - v3
				local v5 = child.Position + v3

				if vector == nil then
					vector2 = v5
					vector = v4
				else
					vector = Vector3.new(math.min(vector.X, v4.X), math.min(vector.Y, v4.Y), (math.min(vector.Z, v4.Z)))
					vector2 = Vector3.new(
						math.max(vector2.X, v5.X),
						math.max(vector2.Y, v5.Y),
						(math.max(vector2.Z, v5.Z))
					)
				end
			end

			table.insert(children, child)
		end
	end

	if vector ~= nil then
		return vector, vector2
	end

	local boundingBox, v3 = instance:GetBoundingBox()
	local v4 = worldHalfExtent(boundingBox, v3)
	return boundingBox.Position - v4, boundingBox.Position + v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bodyExtents(p)
	local bodyBox, v3 = RigEffectScale.BodyBox(p)
	return (v3 - bodyBox).Magnitude
end

function RigEffectScale.FromRig(model)
	if model == nil or not model:IsA("Model") then
		return nil
	end

	if v == nil then
		local assets = ReplicatedStorage:FindFirstChild("Assets")
		local starterCharacterCloneable

		if assets == nil then
			starterCharacterCloneable = false
		else
			starterCharacterCloneable = assets:FindFirstChild("StarterCharacterCloneable")
		end

		if starterCharacterCloneable ~= nil and starterCharacterCloneable:IsA("Model") then
			local magnitude = bodyExtents(starterCharacterCloneable) -- equivalent call inferred; original call site unknown

			if magnitude > 0 then
				v = magnitude
			end
		end

		if v == nil then
			return nil
		end
	end

	local magnitude2 = bodyExtents(model) -- equivalent call inferred; original call site unknown

	if magnitude2 <= 0 then
		return nil
	end

	local v4 = magnitude2 / v

	if v4 >= 1.3 or v4 <= 0.7692307692307692 then
		return (math.clamp(v4, 0.25, 5))
	end

	return nil
end

function RigEffectScale.FromRoot(p)
	if p == nil then
		return nil
	end

	return RigEffectScale.FromRig(p.Parent)
end

return RigEffectScale