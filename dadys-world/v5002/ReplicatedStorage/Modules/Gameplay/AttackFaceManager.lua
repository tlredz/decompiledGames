local ServerStorage = game:GetService("ServerStorage")
local v = false

-- equivalent calls inferred from this helper; original call sites unknown
local function getAttackFaceTemplate(value)
	local twistedAttackFaces = ServerStorage:FindFirstChild("TwistedAttackFaces")

	if twistedAttackFaces then
		return twistedAttackFaces:FindFirstChild(value)
	end

	if not v then
		v = true
		warn("[AttackFaceManager] TwistedAttackFaces folder not found in ServerStorage (warn-once; faces disabled until the folder exists)")
	end

	return nil
end

local function applySAToPart(child, attackFaceTemplate, name)
	local child2 = child:FindFirstChild(name)

	if child2 then
		return child2
	end

	local attackFaceSA = child:FindFirstChild("AttackFaceSA")

	if attackFaceSA and name ~= "AttackFaceSA" then
		local child3 = attackFaceSA:FindFirstChild(name)

		if child3 then
			return child3
		end

		local clone = attackFaceTemplate:Clone()
		clone.Name = name

		for _, surfaceAppearance in attackFaceSA:GetChildren() do
			if surfaceAppearance:IsA("SurfaceAppearance") then
				surfaceAppearance.Parent = clone
			end
		end

		clone.Parent = attackFaceSA
		return clone
	else
		local clone = attackFaceTemplate:Clone()
		clone.Name = name

		for _, surfaceAppearance in child:GetChildren() do
			if surfaceAppearance:IsA("SurfaceAppearance") and surfaceAppearance ~= clone then
				surfaceAppearance.Parent = clone
			end
		end

		clone.Parent = child
		return clone
	end
end

local function removeSAByName(folder, p)
	for _, surfaceAppearance in folder:GetDescendants() do
		if not (surfaceAppearance:IsA("SurfaceAppearance") and surfaceAppearance.Name == p) then
			continue
		end

		local parent = surfaceAppearance.Parent

		for _, surfaceAppearance2 in surfaceAppearance:GetChildren() do
			if surfaceAppearance2:IsA("SurfaceAppearance") then
				surfaceAppearance2.Parent = parent
			end
		end

		surfaceAppearance:Destroy()
	end
end

local function applyAttackFaceToMonster(model)
	if not (model and model:IsA("Model")) then
		return
	end

	local config = model:FindFirstChild("Config")

	if not config then
		warn("[AttackFaceManager] No Config found in monster:", model.Name)
		return
	end

	local moduleName = config:FindFirstChild("ModuleName")

	if not moduleName then
		warn("[AttackFaceManager] No ModuleName found in Config for:", model.Name)
		return
	end

	local value = moduleName.Value
	local attackFaceTemplate = getAttackFaceTemplate(value) -- equivalent call inferred; original call site unknown

	if not attackFaceTemplate then
		warn("[AttackFaceManager] No attack face template found for:", value)
		return
	end

	local part = attackFaceTemplate:GetAttribute("Part")

	if not part then
		warn("[AttackFaceManager] No Part attribute on template for:", value)
	elseif value == "RazzleDazzleMonster" then
		for _, childName in ipairs({ "LeftHead", "RightHead" }) do
			local child = model:FindFirstChild(childName)

			if child then
				applySAToPart(child, attackFaceTemplate, "AttackFaceSA")
				print("[AttackFaceManager] Applied attack face to", value, childName)
			else
				warn("[AttackFaceManager] Head part not found:", childName, "in", value)
			end
		end
	else
		local child = model:FindFirstChild(part)

		if not child then
			warn("[AttackFaceManager] Part not found:", part, "in", value)
			return
		end

		applySAToPart(child, attackFaceTemplate, "AttackFaceSA")
		print("[AttackFaceManager] Applied attack face to", value)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeAttackFaceFromMonster(model)
	if model and model:IsA("Model") then
		removeSAByName(model, "AttackFaceSA")
		print("[AttackFaceManager] Removed attack face from", model.Name)
	end
end

local AttackFaceManager = {}

function AttackFaceManager.ApplyAllAttackFaces()
	local currentRoom = workspace:FindFirstChild("CurrentRoom")

	if not currentRoom then
		warn("[AttackFaceManager] No CurrentRoom found")
		return
	end

	local model = currentRoom:FindFirstChildOfClass("Model")

	if not model then
		warn("[AttackFaceManager] No map model found in CurrentRoom")
		return
	end

	local monsters = model:FindFirstChild("Monsters")

	if not monsters then
		warn("[AttackFaceManager] No Monsters folder found in map")
		return
	end

	local count = 0

	for _, model2 in monsters:GetChildren() do
		if not model2:IsA("Model") then
			continue
		end

		applyAttackFaceToMonster(model2)
		count += 1
	end

	print("[AttackFaceManager] Applied attack faces to", count, "monsters")
end

function AttackFaceManager.ApplyToMonster(model, value)
	local name = value or "AttackFaceSA"

	if not (model and model:IsA("Model")) then
		return
	end

	local config = model:FindFirstChild("Config")

	if not config then
		return
	end

	local moduleName = config:FindFirstChild("ModuleName")

	if not moduleName then
		return
	end

	local value2 = moduleName.Value
	local attackFaceTemplate = getAttackFaceTemplate(value2) -- equivalent call inferred; original call site unknown

	if not attackFaceTemplate then
		return
	end

	local part = attackFaceTemplate:GetAttribute("Part")

	if not part then
		return
	end

	if value2 == "RazzleDazzleMonster" then
		for _, childName in ipairs({ "LeftHead", "RightHead" }) do
			local child = model:FindFirstChild(childName)

			if child then
				applySAToPart(child, attackFaceTemplate, name)
			end
		end
	else
		local child = model:FindFirstChild(part)

		if not child then
			return
		end

		applySAToPart(child, attackFaceTemplate, name)
	end
end

function AttackFaceManager.RemoveFromMonster(model, value)
	local v2 = value or "AttackFaceSA"

	if model and model:IsA("Model") then
		removeSAByName(model, v2)
	end
end

function AttackFaceManager.RemoveAllAttackFaces()
	local currentRoom = workspace:FindFirstChild("CurrentRoom")

	if not currentRoom then
		return
	end

	local model = currentRoom:FindFirstChildOfClass("Model")

	if not model then
		return
	end

	local monsters = model:FindFirstChild("Monsters")

	if not monsters then
		return
	end

	local count = 0

	for _, model2 in monsters:GetChildren() do
		if not model2:IsA("Model") then
			continue
		end

		removeAttackFaceFromMonster(model2) -- equivalent call inferred; original call site unknown
		count += 1
	end

	print("[AttackFaceManager] Removed attack faces from", count, "monsters")
end

return AttackFaceManager