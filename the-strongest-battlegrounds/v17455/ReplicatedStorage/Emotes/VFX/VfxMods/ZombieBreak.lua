local createVector = vector.create
local ZombieBreak = {}
local library = require(game.ReplicatedStorage.library)
local maid = library.Maid
local EFP = library.EFP
local class = {}
class.__index = class
local random = Random.new()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local AssetService = game:GetService("AssetService")
local ContentProvider = game:GetService("ContentProvider")

local function zblog(_) end

local v = { "bounce", "arc" }
local v2 = { "rbxassetid://82367180774446", "rbxassetid://138283977997248" }
local v3 = {
	arc = {
		min = 0.72,
		max = 1.5,
		perStud = 0.04
	},
	orbit = {
		min = 0.9,
		max = 2.3,
		perStud = 0.05
	},
	snap = {
		min = 0.78,
		max = 1.3,
		perStud = 0.035
	},
	bounce = {
		min = 1.1,
		max = 1.4,
		perStud = 0.05
	}
}
local trail = script:FindFirstChild("Trail")
local v4 = {
	["Left Leg"] = {
		start = 1,
		duration = 74
	},
	["Right Leg"] = {
		start = 30,
		duration = 83
	},
	Torso = {
		start = 49,
		duration = 80
	},
	["Right Arm"] = {
		start = 82,
		duration = 64
	},
	["Left Arm"] = {
		start = 128,
		duration = 74
	},
	Head = {
		start = 168,
		duration = 83
	}
}
local part = Instance.new("Part")
part.Parent = workspace.Thrown
part.Name = "__ConnectFX"
part.Anchored = true
part.CanCollide = false
part.Transparency = 1
part.Size = createVector(0.2, 0.2, 0.2)
local v5 = 2

if EFP then
	for _, emitter in ipairs(EFP:GetChildren()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local clone = emitter:Clone()
		warn(clone)
		clone.Enabled = false
		clone.Parent = part
		v5 = math.max(v5, clone.Lifetime.Max)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rankForBodyPart(p)
	if p == "Left Leg" or p == "Right Leg" then
		return 0
	end

	if p == "Torso" then
		return 1
	end

	if p == "Left Arm" or p == "Right Arm" then
		return 2
	end

	if p == "Head" then
		return 3
	end

	return 1
end

local function gatherAccessories(char)
	local accessories = {}

	local function collect(instance)
		for _, accessory in ipairs(instance:GetChildren()) do
			if accessory:IsA("Accessory") then
				table.insert(accessories, accessory)
			end
		end
	end

	collect(char)
	local fakeHead = char:FindFirstChild("FakeHead")

	if fakeHead then
		collect(fakeHead)
	end

	return accessories
end

local function findAccessoryAnchor(handle, instance)
	local attachment = handle:FindFirstChildWhichIsA("Attachment")

	if not attachment then
		return instance:FindFirstChild("Torso") or instance.PrimaryPart
	end

	for _, part2 in ipairs(instance:GetChildren()) do
		if not part2:IsA("BasePart") then
			continue
		end

		local attachment2 = part2:FindFirstChild(attachment.Name)

		if attachment2 and attachment2:IsA("Attachment") then
			return part2
		end
	end

	return instance:FindFirstChild("Torso") or instance.PrimaryPart
end

local function buildAccessoryModel(instance, char, parent)
	local handle = instance:FindFirstChild("Handle")

	if not (handle and handle:IsA("BasePart")) then
		return
	end

	local accessoryAnchor = findAccessoryAnchor(handle, char)

	if not accessoryAnchor then
		return
	end

	local clone = handle:Clone()
	task.delay(13, function()
		if clone and clone.Parent then
			clone:Destroy()
		end
	end)

	for _, child in ipairs(clone:GetChildren()) do
		if not (child:IsA("Attachment") or child:IsA("JointInstance") or child:IsA("BodyMover") or child:IsA("Constraint")) then
			continue
		end

		child:Destroy()
	end

	clone.Name = "AccPiece"
	clone.CFrame = handle.CFrame
	clone.Anchored = false
	clone.CanCollide = false
	clone.Massless = false
	local model = Instance.new("Model")
	model.Name = "Acc_" .. instance.Name
	local part2 = Instance.new("Part")
	part2.Name = "root"
	part2.Size = createVector(0.2, 0.2, 0.2)
	part2.Transparency = 1
	part2.CanCollide = false
	part2.Massless = true
	part2.CFrame = handle.CFrame
	part2.Parent = model
	model.PrimaryPart = part2
	clone.Parent = model
	local weld = Instance.new("Weld")
	weld.Name = clone.Name
	weld.Part0 = part2
	weld.Part1 = clone
	weld.C0 = part2.CFrame:ToObjectSpace(clone.CFrame)
	weld.Parent = part2
	local weld2 = Instance.new("Weld")
	weld2.Name = "RootWeld"
	weld2.Part0 = accessoryAnchor
	weld2.Part1 = part2
	weld2.C0 = accessoryAnchor.CFrame:ToObjectSpace(part2.CFrame)
	weld2.Parent = model
	model:SetAttribute("Accessory", true)
	model:SetAttribute("AnchorRank", rankForBodyPart(accessoryAnchor.Name))
	model:SetAttribute("AnchorName", accessoryAnchor.Name)
	local objectValue = Instance.new("ObjectValue")
	objectValue.Name = "SourceHandle"
	objectValue.Value = handle
	objectValue.Parent = model
	model.Parent = parent

	if handle:GetAttribute("OrigTransparency") == nil then
		handle:SetAttribute("OrigTransparency", handle.Transparency)
	end

	handle.Transparency = 1
end

local function buildWholePieceModel(part2, _, parent)
	if not (part2 and part2:IsA("BasePart")) then
		return
	end

	local clone = part2:Clone()
	task.delay(13, function()
		if clone and clone.Parent then
			clone:Destroy()
		end
	end)

	for _, child in ipairs(clone:GetChildren()) do
		if not (child:IsA("Attachment") or child:IsA("JointInstance") or child:IsA("BodyMover") or child:IsA("Constraint")) then
			continue
		end

		child:Destroy()
	end

	clone.Name = "WholePiece"
	clone.CFrame = part2.CFrame
	clone.Anchored = false
	clone.CanCollide = false
	clone.Massless = false
	local model = Instance.new("Model")
	model.Name = part2.Name
	local part3 = Instance.new("Part")
	part3.Name = "root"
	part3.Size = createVector(0.2, 0.2, 0.2)
	part3.Transparency = 1
	part3.CanCollide = false
	part3.Massless = true
	part3.CFrame = part2.CFrame
	part3.Parent = model
	model.PrimaryPart = part3
	clone.Parent = model
	local weld = Instance.new("Weld")
	weld.Name = clone.Name
	weld.Part0 = part3
	weld.Part1 = clone
	weld.C0 = part3.CFrame:ToObjectSpace(clone.CFrame)
	weld.Parent = part3
	local weld2 = Instance.new("Weld")
	weld2.Name = "RootWeld"
	weld2.Part0 = part2
	weld2.Part1 = part3
	weld2.C0 = part2.CFrame:ToObjectSpace(part3.CFrame)
	weld2.Parent = model
	model:SetAttribute("WholePiece", true)
	model.Parent = parent
	part2.Transparency = 1
end

local function attachTrail(part2)
	if not trail then
		return nil
	end

	local att0 = trail:FindFirstChild("Att0")
	local att1 = trail:FindFirstChild("Att1")
	local trail2 = trail:FindFirstChild("Trail")

	if not (att0 and att1 and trail2) then
		return nil
	end

	task.delay(13, function()
		if part2 and part2.Parent then
			part2:Destroy()
		end
	end)
	local clone = att0:Clone()
	local clone2 = att1:Clone()
	local clone3 = trail2:Clone()
	clone.Parent = part2
	clone2.Parent = part2
	clone3.Attachment0 = clone
	clone3.Attachment1 = clone2
	clone3.Enabled = false
	clone3.Parent = part2
	return clone3, clone, clone2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseTrail(state, instance)
	local trail2 = state.trail
	local trailA0 = state.trailA0
	local trailA1 = state.trailA1

	if not trail2 then
		return
	end

	state.trail = nil
	trail2.Enabled = false
	local primaryPart = instance.PrimaryPart

	if primaryPart then
		trailA0.Parent = primaryPart
		trailA1.Parent = primaryPart
		trail2.Parent = primaryPart
	end

	task.spawn(function()
		local lastTime = tick()

		while trail2.Parent do
			local v6 = (tick() - lastTime) / 0.45

			if v6 >= 1 then
				break
			end

			trail2.Transparency = NumberSequence.new(v6)
			task.wait()
		end

		trail2:Destroy()
		trailA0:Destroy()
		trailA1:Destroy()
	end)
end

local function playConnectEffect(_) end

local v6 = {
	["Right Leg"] = "Pants",
	["Left Leg"] = "Pants",
	Torso = "Shirt",
	["Right Arm"] = "Shirt",
	["Left Arm"] = "Shirt",
	Head = ""
}

local function RemoveSpaces(value)
	return (value:gsub("%s+", ""))
end

local v7 = {}

local function fingerprintAny(meshId)
	if not meshId or meshId == 0 or meshId == "" then
		return nil
	end

	local v8 = tostring(meshId)
	local v9 = v7[v8]

	if v9 ~= nil then
		return v9 or nil
	end

	local content

	if type(meshId) == "number" then
		content = Content.fromAssetId(meshId)
	else
		content = Content.fromUri(meshId)
	end

	local success, result = pcall(function()
		return AssetService:CreateEditableMeshAsync(content)
	end)

	if not (success and result) then
		v7[v8] = false
		return nil
	end

	local vertices = result:GetVertices()
	local vector2 = nil
	local vector3 = nil

	for _, v10 in ipairs(vertices) do
		local position = result:GetPosition(v10)

		if vector2 then
			vector2 = Vector3.new(
				math.min(vector2.X, position.X),
				math.min(vector2.Y, position.Y),
				(math.min(vector2.Z, position.Z))
			)
			vector3 = Vector3.new(
				math.max(vector3.X, position.X),
				math.max(vector3.Y, position.Y),
				(math.max(vector3.Z, position.Z))
			)
		else
			vector3 = position
			vector2 = vector3
			vector3 = vector2
		end
	end

	result:Destroy()
	local v10 = {
		vCount = #vertices,
		size = vector2 and vector3 - vector2 or createVector(0, 0, 0)
	}
	v7[v8] = v10
	return v10
end

local function fingerprintsMatch(p, p2)
	if not (p and p2 and p.vCount == p2.vCount) then
		return false
	end

	local v8 = p.size - p2.size
	return math.abs(v8.X) < 0.001 and math.abs(v8.Y) < 0.001 and math.abs(v8.Z) < 0.001
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCharMeshUri(part2)
	if not part2 then
		return nil
	end

	if part2:IsA("MeshPart") and part2.MeshId ~= "" then
		return part2.MeshId
	end

	local specialMesh = part2:FindFirstChildOfClass("SpecialMesh")

	if specialMesh and specialMesh.MeshId and specialMesh.MeshId ~= "" then
		return specialMesh.MeshId
	end

	return nil
end

local v8 = {}

local function findTemplate(instance, childName)
	local humanoid = instance:FindFirstChild("Humanoid")

	if not (humanoid and v6[childName]) then
		return nil
	end

	local humanoidDescription = humanoid:FindFirstChildOfClass("HumanoidDescription")

	if not humanoidDescription then
		return nil
	end

	local v9 = humanoidDescription[childName:gsub("%s+", "")]
	local v10

	if v9 == 0 then
		v10 = "R6:" .. childName
	elseif v9 then
		v10 = tostring(v9)
	else
		return nil
	end

	local v11 = v8[v10]

	if v11 ~= nil then
		return v11 or nil
	end

	if v9 == 0 then
		local R6 = script.Templates:FindFirstChild("R6")
		local child = R6 and R6:FindFirstChild(childName)

		if child then
			v8[v10] = child
			return child
		end

		v8[v10] = false
		return nil
	else
		for _, child in pairs(script.Templates:GetChildren()) do
			for _, child2 in pairs(child:GetChildren()) do
				if child2:GetAttribute("Match") ~= v9 then
					continue
				end

				v8[v10] = child2
				return child2
			end
		end

		local charMeshUri = getCharMeshUri(instance:FindFirstChild(childName)) -- equivalent call inferred; original call site unknown
		local v13 = fingerprintAny(charMeshUri)

		if v13 then
			for _, child2 in pairs(script.Templates:GetChildren()) do
				for _, child3 in pairs(child2:GetChildren()) do
					local meshId = child3:GetAttribute("MeshId") or child3:GetAttribute("Match")

					if not (meshId and meshId ~= v9) then
						continue
					end

					local v14 = fingerprintAny(meshId)
					local v15

					if v13 and v14 and v13.vCount == v14.vCount then
						local v16 = v13.size - v14.size

						if math.abs(v16.X) < 0.001 and math.abs(v16.Y) < 0.001 then
							v15 = math.abs(v16.Z) < 0.001
						else
							v15 = false
						end
					else
						v15 = false
					end

					if not v15 then
						continue
					end

					v8[v10] = child3
					return child3
				end
			end
		end

		v8[v10] = false
		return nil
	end
end

local v9 = { "Torso" }
local v10 = {
	Head = 0,
	["Left Arm"] = -90,
	["Left Leg"] = -90,
	["Right Arm"] = 0,
	["Right Leg"] = 0,
	Torso = 0
}
local v11 = {
	Head = 0,
	["Left Arm"] = 180,
	["Left Leg"] = 180,
	["Right Arm"] = 180,
	["Right Leg"] = 180,
	Torso = 180
}
local object = setmetatable({}, {
	__mode = "k"
})

local function clusterLimb(clone, max)
	local primaryPart = clone.PrimaryPart

	if not primaryPart then
		return
	end

	local parts = {}

	for _, part2 in ipairs(clone:GetChildren()) do
		if part2:IsA("BasePart") and part2 ~= primaryPart then
			parts[#parts + 1] = part2
		end
	end

	if #parts <= max then
		return
	end

	local positions = {}
	local vector2 = nil
	local vector3 = nil

	for _, v12 in ipairs(parts) do
		local position = primaryPart.CFrame:ToObjectSpace(v12.CFrame).Position
		positions[v12] = position

		if vector2 then
			vector2 = Vector3.new(
				math.min(vector2.X, position.X),
				math.min(vector2.Y, position.Y),
				(math.min(vector2.Z, position.Z))
			)
			vector3 = Vector3.new(
				math.max(vector3.X, position.X),
				math.max(vector3.Y, position.Y),
				(math.max(vector3.Z, position.Z))
			)
		else
			vector3 = position
			vector2 = vector3
			vector3 = vector2
		end
	end

	local v12 = vector3 - vector2
	local fn, v13

	if v12.X >= v12.Y and v12.X >= v12.Z then
		fn = function(p)
			return p.X
		end

		v13 = 1
	elseif v12.Z >= v12.X and v12.Z >= v12.Y then
		fn = function(p)
			return p.Z
		end

		v13 = 3
	else
		fn = function(p)
			return p.Y
		end

		v13 = 2
	end

	local v14 = fn(vector2)
	local v15 = math.max(fn(vector3) - v14, 0.001)
	local v16 = {}

	for _, v17 in ipairs(parts) do
		local v18 = math.clamp(math.floor((fn(positions[v17]) - v14) / v15 * max) + 1, 1, max)
		v16[v18] = v16[v18] or {}
		table.insert(v16[v18], v17)
	end

	for k, list in pairs(v16) do
		local vector4 = nil
		local vector5 = nil

		for _, v17 in ipairs(list) do
			local v18 = positions[v17]

			if vector4 then
				vector4 = Vector3.new(
					math.min(vector4.X, v18.X),
					math.min(vector4.Y, v18.Y),
					(math.min(vector4.Z, v18.Z))
				)
				vector5 = Vector3.new(
					math.max(vector5.X, v18.X),
					math.max(vector5.Y, v18.Y),
					(math.max(vector5.Z, v18.Z))
				)
			else
				vector5 = v18
				vector4 = vector5
				vector5 = vector4
			end
		end

		local v17 = vector5 - vector4
		local vector6 = Vector3.new(math.max(v17.X, 0.4), math.max(v17.Y, 0.4), (math.max(v17.Z, 0.4)))
		local part2 = Instance.new("Part")
		part2.Name = "Chunk" .. k
		part2.Size = vector6
		part2.Color = Color3.fromRGB(math.random(108, 138), math.random(20, 34), math.random(20, 34))
		part2.Material = list[1].Material
		part2.CFrame = primaryPart.CFrame * CFrame.new((vector4 + vector5) / 2)
		local weld = Instance.new("Weld")
		weld.Name = part2.Name
		weld.Part0 = primaryPart
		weld.Part1 = part2
		weld.C0 = primaryPart.CFrame:ToObjectSpace(part2.CFrame)
		weld.Parent = primaryPart

		for _, part4 in ipairs(list) do
			for _, weld2 in ipairs(primaryPart:GetChildren()) do
				if not (weld2:IsA("Weld") and (weld2.Part1 == part4 or weld2.Part0 == part4)) then
					continue
				end

				weld2:Destroy()
				break
			end

			part4.Massless = true
			local weld2 = Instance.new("Weld")
			weld2.Part0 = part2
			weld2.Part1 = part4
			weld2.C0 = part2.CFrame:ToObjectSpace(part4.CFrame)
			weld2.Parent = part2
			part4.Parent = part2
		end

		local part3 = Instance.new("Part")
		part3.Name = "Bone"
		part3.Material = Enum.Material.SmoothPlastic
		part3.Color = Color3.fromRGB(232, 226, 208)
		part3.CanCollide = false
		part3.Massless = true
		task.delay(13, function()
			if part3 and part3.Parent then
				part3:Destroy()
			end
		end)

		if v13 == 1 then
			part3.Size = Vector3.new(math.max(vector6.X * 1.5, 0.8), 0.22, 0.22)
		elseif v13 == 3 then
			part3.Size = Vector3.new(0.22, 0.22, (math.max(vector6.Z * 1.5, 0.8)))
		else
			part3.Size = Vector3.new(0.22, math.max(vector6.Y * 1.5, 0.8), 0.22)
		end

		part3.CFrame = part2.CFrame
		local weld2 = Instance.new("Weld")
		weld2.Part0 = part2
		weld2.Part1 = part3
		weld2.C0 = part2.CFrame:ToObjectSpace(part3.CFrame)
		weld2.Parent = part3
		part3.Parent = part2
		task.delay(13, function()
			if part2 and part2.Parent then
				part2:Destroy()
			end
		end)
		part2.Parent = clone
	end
end

local function buildHeadPiece(part2, _, parent)
	if not (part2 and part2:IsA("BasePart")) then
		return
	end

	local clone = part2:Clone()
	task.delay(13, function()
		if clone and clone.Parent then
			clone:Destroy()
		end
	end)

	for _, child in ipairs(clone:GetChildren()) do
		if not (child:IsA("Attachment") or child:IsA("JointInstance") or child:IsA("Decal") or child:IsA("BodyMover") or child:IsA("Constraint")) then
			continue
		end

		child:Destroy()
	end

	clone.Name = "Head"
	clone.CFrame = part2.CFrame
	clone.Anchored = false
	clone.CanCollide = false
	clone.Massless = false
	local model = Instance.new("Model")
	model.Name = part2.Name
	local humanoid = Instance.new("Humanoid")
	humanoid.DisplayName = ""
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.NameDisplayDistance = 0
	humanoid.HealthDisplayDistance = 0
	humanoid.Parent = model
	local part3 = Instance.new("Part")
	part3.Name = "root"
	part3.Size = createVector(0.2, 0.2, 0.2)
	part3.Transparency = 1
	part3.CanCollide = false
	part3.Massless = true
	part3.CFrame = part2.CFrame
	part3.Parent = model
	model.PrimaryPart = part3
	clone.Parent = model
	local weld = Instance.new("Weld")
	weld.Name = clone.Name
	weld.Part0 = part3
	weld.Part1 = clone
	weld.C0 = part3.CFrame:ToObjectSpace(clone.CFrame)
	weld.Parent = part3
	local weld2 = Instance.new("Weld")
	weld2.Name = "RootWeld"
	weld2.Part0 = part2
	weld2.Part1 = part3
	weld2.C0 = part2.CFrame:ToObjectSpace(part3.CFrame)
	weld2.Parent = model
	model:SetAttribute("WholePiece", true)
	model.Parent = parent
	part2.Transparency = 1
end

local color = Color3.fromRGB(10, 9, 8)

-- equivalent calls inferred from this helper; original call sites unknown
local function getBurnSmoke()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local emotes = ReplicatedStorage:FindFirstChild("Emotes")
	return emotes and emotes:FindFirstChild("BurnSmoke2")
end

local function applyBurnToTemp(char)
	local temp = char:FindFirstChild("Temp")

	if not temp or temp:GetAttribute("Burned") then
		return
	end

	temp:SetAttribute("Burned", true)
	local descendants = {}

	for _, descendant in ipairs(temp:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Color = color

			if descendant.Transparency < 1 then
				descendants[#descendants + 1] = descendant
			end
		elseif descendant:IsA("SpecialMesh") then
			descendant.TextureId = ""
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			descendant.Color3 = color
		end
	end

	local burnSmoke = getBurnSmoke() -- equivalent call inferred; original call site unknown

	if burnSmoke then
		local v12 = {}

		for _, folder in ipairs(temp:GetChildren()) do
			local parts = {}

			for _, part2 in ipairs(folder:GetDescendants()) do
				if part2:IsA("BasePart") and part2.Transparency < 1 then
					parts[#parts + 1] = part2
				end
			end

			if #parts > 0 then
				v12[#v12 + 1] = parts
			end
		end

		for i = #v12, 2, -1 do
			local integer = random:NextInteger(1, i)
			local v13 = v12[integer]
			local v14 = v12[i]
			v12[i] = v13
			v12[integer] = v14
		end

		for i = 1, math.min(6, #v12) do
			local v13 = v12[i]
			local clone = burnSmoke:Clone()
			clone.Rate = random:NextInteger(15, 35)
			local number = random:NextNumber(0.65, 2.5)
			local number2 = random:NextNumber(0.65, 2.5)
			clone.Lifetime = NumberRange.new(math.min(number, number2), (math.max(number, number2)))

			if random:NextInteger(1, 2) == 2 then
				local integer = random:NextInteger(3, 20)
				clone.SpreadAngle = Vector2.new(-integer, integer)
			end

			clone.Parent = v13[random:NextInteger(1, #v13)]
		end
	end
end

local function buildOneLimbVoxels(char, part2, parent, clones)
	if part2:GetAttribute("ZBOrigGroup") == nil then
		part2:SetAttribute("ZBOrigGroup", part2.CollisionGroup)
		part2:SetAttribute("ZBOrigCollide", part2.CanCollide)
	end

	part2.CanCollide = true
	part2.CollisionGroup = "untouchable"
	local v12

	if part2.Name == "Head" then
		v12 = false
	else
		v12 = findTemplate(char, part2.Name)
	end

	if v12 then
		local clone = v12:Clone()
		task.delay(13, function()
			if clone and clone.Parent then
				clone:Destroy()
			end
		end)
		local shirt = v6[part2.Name] and char:FindFirstChild(v6[part2.Name])
		clone.PrimaryPart.Transparency = 1

		for _, child in pairs(clone:GetChildren()) do
			if child == clone.PrimaryPart then
				continue
			end

			if v12.Name == "Head" then
				child.Material = Enum.Material.SmoothPlastic
			else
				child.Material = Enum.Material.RoofShingles
			end

			local decal = child:FindFirstChildOfClass("Decal")
			local pants = table.find(v9, part2.Name) and decal and char:FindFirstChildOfClass("Pants")

			if pants then
				local decal2 = Instance.new("Decal")
				decal2.Texture = pants.PantsTemplate
				decal2.ZIndex = 1
				decal2.Parent = child
			end

			if decal and shirt then
				decal.Texture = shirt:IsA("Shirt") and shirt.ShirtTemplate or shirt.PantsTemplate
			elseif decal then
				decal.Texture = ""
			end

			if decal then
				decal.ZIndex = 2
			end

			child.Color = part2.Color
		end

		clusterLimb(clone, 3)
		local weld = Instance.new("Weld")
		weld.Part0 = clone.PrimaryPart
		weld.Part1 = part2
		local v13 = (not v12.Parent or v12.Parent.Name ~= "R6") and 0 or v10[clone.Name] or 0

		if v12.Parent and v12.Parent.Name == "Robloxian" then
			v13 = v11[clone.Name] or 0
		end

		weld.C0 = CFrame.Angles(0, math.rad(v13), 0)
		weld.Parent = clone
		clone.Parent = parent

		if clones then
			table.insert(clones, clone)
		end

		part2.Transparency = 1
	elseif part2.Name == "Head" then
		buildHeadPiece(part2, char, parent)
	else
		buildWholePieceModel(part2, char, parent)
	end
end

local function burstOneLimb(instance, velocity, p, _)
	local primaryPart = instance.PrimaryPart

	if not primaryPart then
		return
	end

	for _, weld in pairs(primaryPart:GetChildren()) do
		if weld:IsA("Weld") then
			weld.Enabled = false
		end
	end

	for _, part2 in pairs(instance:GetChildren()) do
		if not (part2:IsA("BasePart") and part2 ~= instance.PrimaryPart) then
			continue
		end

		part2.CanCollide = true
		part2.CollisionGroup = "untouchable"
		part2:SetAttribute("Offset", part2.CFrame:ToObjectSpace(primaryPart.CFrame))
		local v12 = part2.Position - p
		local vector2 = Vector3.new(v12.X, 0, v12.Z)

		if vector2.Magnitude < 0.1 then
			vector2 = Vector3.new(random:NextNumber(-1, 1), 0, random:NextNumber(-1, 1))
		end

		local v13 = vector2.Unit * random:NextNumber(15, 25) + Vector3.new(0, random:NextNumber(35, 55), 0)
		part2.AssemblyLinearVelocity += velocity + v13
	end
end

local function Transform(p)
	local char = p.Char

	if object[char] or not p.Break then
		if not p.Break then
			local temp = char:FindFirstChild("Temp")

			if temp then
				temp:Destroy()
			end

			for _, part2 in pairs(char:GetChildren()) do
				if part2:IsA("BasePart") and part2 ~= char.PrimaryPart and part2.Transparency ~= 1 then
					part2.Transparency = 0
				end

				if not (part2:IsA("BasePart") and part2:GetAttribute("ZBOrigGroup") ~= nil) then
					continue
				end

				part2.CollisionGroup = part2:GetAttribute("ZBOrigGroup")
				part2.CanCollide = part2:GetAttribute("ZBOrigCollide")
				part2:SetAttribute("ZBOrigGroup", nil)
				part2:SetAttribute("ZBOrigCollide", nil)
			end

			for _, v12 in ipairs((gatherAccessories(char))) do
				local handle = v12:FindFirstChild("Handle")

				if not (handle and handle:GetAttribute("OrigTransparency") ~= nil) then
					continue
				end

				handle.Transparency = handle:GetAttribute("OrigTransparency")
				handle:SetAttribute("OrigTransparency", nil)
			end

			object[char] = nil
		end
	else
		object[char] = true
		local folder = Instance.new("Folder")
		folder.Name = "Temp"
		folder.Parent = char
		local v12 = {}

		for _, part2 in pairs(char:GetChildren()) do
			if not (part2:IsA("BasePart") and part2 ~= char.PrimaryPart and (v4[part2.Name] or part2.Transparency < 1)) then
				continue
			end

			if part2:GetAttribute("ZBOrigGroup") == nil then
				part2:SetAttribute("ZBOrigGroup", part2.CollisionGroup)
				part2:SetAttribute("ZBOrigCollide", part2.CanCollide)
			end

			part2.CanCollide = true
			part2.CollisionGroup = "untouchable"
			local v13

			if part2.Name == "Head" then
				v13 = false
			else
				v13 = findTemplate(char, part2.Name)
			end

			if v13 then
				local clone = v13:Clone()
				task.delay(13, function()
					if clone and clone.Parent then
						clone:Destroy()
					end
				end)
				local shirt = v6[part2.Name] and char:FindFirstChild(v6[part2.Name])
				clone.PrimaryPart.Transparency = 1

				for _, child in pairs(clone:GetChildren()) do
					if child == clone.PrimaryPart then
						continue
					end

					if v13.Name == "Head" then
						child.Material = Enum.Material.SmoothPlastic
					else
						child.Material = Enum.Material.RoofShingles
					end

					local decal = child:FindFirstChildOfClass("Decal")
					local pants = table.find(v9, part2.Name) and decal and char:FindFirstChildOfClass("Pants")

					if pants then
						local decal2 = Instance.new("Decal")
						decal2.Texture = pants.PantsTemplate
						decal2.ZIndex = 1
						decal2.Parent = child
					end

					if decal and shirt then
						decal.Texture = shirt:IsA("Shirt") and shirt.ShirtTemplate or shirt.PantsTemplate
					elseif decal then
						decal.Texture = ""
					end

					if decal then
						decal.ZIndex = 2
					end

					child.Color = part2.Color
				end

				clusterLimb(clone, 3)
				local weld = Instance.new("Weld")
				weld.Part0 = clone.PrimaryPart
				weld.Part1 = part2
				local v15 = (not v13.Parent or v13.Parent.Name ~= "R6") and 0 or v10[clone.Name] or 0

				if v13.Parent and v13.Parent.Name == "Robloxian" then
					v15 = v11[clone.Name] or 0
				end

				weld.C0 = CFrame.Angles(0, math.rad(v15), 0)
				weld.Parent = clone
				clone.Parent = folder
				table.insert(v12, clone)
				part2.Transparency = 1
			elseif part2.Name == "Head" then
				buildHeadPiece(part2, char, folder)
			else
				buildWholePieceModel(part2, char, folder)
			end
		end

		for _, v13 in ipairs((gatherAccessories(char))) do
			buildAccessoryModel(v13, char, folder)
		end

		if char:GetAttribute("Burnt") then
			applyBurnToTemp(char)
		end
	end
end

local function Materialize(data)
	local char = data.Char
	local temp = char:FindFirstChild("Temp")

	if not temp then
		return
	end

	if data.Bool then
		math.random(5, 8)
		local _ = data.Velocity or createVector(0, 0, 0)
		local v12 = not char.PrimaryPart and createVector(0, 0, 0) or char.PrimaryPart.Position or createVector(0, 0, 0)
		local impacts = workspace:FindFirstChild("impacts")
		local impacts2 = impacts and impacts:FindFirstChild("impacts")
		local _3 = impacts2 and impacts2:FindFirstChild("3")
		local filterDescendantsInstances = {}
		local map = workspace:FindFirstChild("Map")

		if map then
			filterDescendantsInstances[#filterDescendantsInstances + 1] = map
		end

		local built = workspace:FindFirstChild("Built")

		if built then
			filterDescendantsInstances[#filterDescendantsInstances + 1] = built
		end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		raycastParams.IgnoreWater = true
		local primaryPart = char.PrimaryPart
		local hitCharge = script:FindFirstChild("HitCharge")

		if primaryPart and hitCharge then
			local clone = hitCharge:Clone()
			local v14 = primaryPart.CFrame * CFrame.new(0, -1, 0)

			if clone:IsA("Model") then
				if clone.PrimaryPart then
					clone:PivotTo(v14)
				end

				clone.Parent = workspace.Thrown
			end

			local max = 2

			for _, emitter in ipairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount") or 40)

				if max < emitter.Lifetime.Max then
					max = emitter.Lifetime.Max
				end
			end

			Debris:AddItem(clone, max + 0.5)
		end

		for _, child in pairs(temp:GetChildren()) do
			local primaryPart2 = child.PrimaryPart

			for _, weld in pairs(primaryPart2:GetChildren()) do
				if weld:IsA("Weld") then
					weld.Enabled = false
				end
			end

			if char == game.Players.LocalPlayer.Character then
				shared.repfire({
					Effect = "Camshake",
					Intensity = 5.5
				})
			end

			for _, part2 in pairs(child:GetChildren()) do
				if not (part2:IsA("BasePart") and part2 ~= child.PrimaryPart) then
					continue
				end

				part2.CanCollide = true
				part2.CollisionGroup = "untouchable"
				part2:SetAttribute("Offset", part2.CFrame:ToObjectSpace(primaryPart2.CFrame))
				local v14 = part2.Position - v12
				local vector2 = Vector3.new(v14.X, 0, v14.Z)

				if vector2.Magnitude < 0.1 then
					vector2 = Vector3.new(random:NextNumber(-1, 1), 0, random:NextNumber(-1, 1))
				end

				local v15 = vector2.Unit * random:NextNumber(15, 25) + Vector3.new(0, random:NextNumber(35, 55), 0)
				part2.AssemblyLinearVelocity += v15
				part2.AssemblyAngularVelocity += Vector3.new(
					random:NextNumber(-1, 1),
					random:NextNumber(-1, 1),
					random:NextNumber(-1, 1)
				) * random:NextNumber(10, 25)
				local parent = part2
				task.delay(0.05, function()
					if not parent.Parent then
						return
					end

					local lastTime = tick()

					repeat
						task.wait()
					until tick() - lastTime > 5 or not parent.Parent or workspace:Raycast(
						parent.Position,
						createVector(0, -2, 0),
						raycastParams
					) ~= nil

					if tick() - lastTime > 5 or not parent.Parent then
						return
					end

					parent.AssemblyLinearVelocity = Vector3.new()
					parent.AssemblyAngularVelocity = Vector3.new()

					if shared.sfx then
						local v17 = {
							"rbxassetid://11714811219",
							"rbxassetid://11714811286",
							"rbxassetid://11714811320"
						}
						local v18 = { "rbxassetid://133407465637225", "rbxassetid://117409168259538" }

						for k, v19 in pairs(v17) do
							if math.random(1, 2) == 2 then
								table.insert(v18, v19)
							end
						end

						shared.sfx({
							SoundId = v17[math.random(1, #v18)],
							Volume = 0.2,
							Parent = parent
						}):Play()
					end
				end)

				if not _3 then
					continue
				end

				local clone = _3:Clone()
				Debris:AddItem(clone, 2)
				clone.Position = createVector(0, 0, 0)
				clone.Parent = part2
				warn(clone)

				for _, emitter in ipairs(clone:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter.Enabled = false
					local v17 = math.floor(3 * random:NextNumber(0, 1.6))

					if v17 > 0 then
						emitter:Emit(v17)
					end
				end
			end
		end

		if char.PrimaryPart then
			local primaryPart2 = char.PrimaryPart
			task.spawn(function()
				local raycastParams2 = RaycastParams.new()
				raycastParams2.FilterType = Enum.RaycastFilterType.Include
				raycastParams2.FilterDescendantsInstances = { workspace.Map, workspace.Built }
				raycastParams2.IgnoreWater = true
				local v14 = {}

				for _, child in pairs(temp:GetChildren()) do
					for _, part2 in pairs(child:GetChildren()) do
						if part2:IsA("BasePart") and part2 ~= child.PrimaryPart then
							v14[part2] = {
								gain = 0.75 + math.random() * 0.35,
								drift = Vector3.new(
									math.random() * 2 - 1,
									(math.random() * 2 - 1) * 0.3,
									math.random() * 2 - 1
								),
								wobble = math.random() * 3.141592653589793 * 2,
								radius = part2.Size.Magnitude * 0.5
							}
						end
					end
				end

				local v15 = 0.06 * (char:FindFirstChild("extrazombievelocity") ~= nil and 1.5 or 1)
				local lastTime = tick()
				local position = primaryPart2.Position
				local now = tick()
				local random2 = Random.new()
				local v16 = char:FindFirstChild("extrazombievelocity") and Random.new():NextNumber(3.5, 5) or 1
				local v17 = char:FindFirstChild("extrazombievelocityup") and 1.35 or 1
				local v18 = v16 * 1.15
				local flag = false
				local total = 0

				for k, _ in pairs(v14) do
					if not k.Parent or k.Anchored then
						continue
					end

					local v19

					if v18 == 1 then
						v19 = random2:NextNumber(1.1, 1.6)
					else
						v19 = random2:NextNumber(1.865, 2.5)
					end

					local v20 = Vector3.new(
						random2:NextNumber(-1, 1),
						random2:NextNumber(0, 0.6) * v19 * v17,
						random2:NextNumber(-1, 1)
					) * (8 + random2:NextNumber(0, 10)) * v18
					k.AssemblyLinearVelocity += v20
				end

				local extrazombievelocity = char:FindFirstChild("extrazombievelocity")

				if extrazombievelocity and extrazombievelocity:GetAttribute("cantrack") then
					extrazombievelocity:Destroy()
				end

				while tick() - lastTime < 3 and temp.Parent and char.Parent and primaryPart2.Parent do
					RunService.Heartbeat:Wait()

					if char:FindFirstChild("zombiebypass") then
						break
					end

					local position2 = primaryPart2.Position
					local now2 = tick()
					local v19 = math.max(now2 - now, 0.004166666666666667)
					local v20 = position2 - position
					local v21 = v20.Magnitude / v19

					if not flag then
						if v21 >= 80 and v20.Magnitude < 50 then
							total += v19

							if v15 <= total then
								flag = true
							end
						else
							total = 0
						end

						if not flag and tick() - lastTime > 0.5 then
							break
						end
					end

					if flag then
						local magnitude = v20.Magnitude

						if magnitude > 0.0001 and magnitude < 50 then
							local v22 = tick() - lastTime
							position = position2
							now = now2

							for _, child in pairs(temp:GetChildren()) do
								local primaryPart3 = child.PrimaryPart

								for _, part2 in pairs(child:GetChildren()) do
									if not part2:IsA("BasePart") or part2 == primaryPart3 or part2.Anchored then
										continue
									end

									local v23 = v14[part2]
									local v24

									if v23 then
										local v25 = v23.drift * math.sin(v22 * 6 + v23.wobble) * magnitude * 0.15
										v24 = part2.Position + v20 * v23.gain + v25
									else
										v24 = part2.Position + v20
									end

									local v25 = v24 - part2.Position
									local magnitude2 = v25.Magnitude
									local radius = v23 and v23.radius or part2.Size.Magnitude * 0.5

									if magnitude2 > 0.0001 then
										local v26 = v25 / magnitude2
										local raycastResult = workspace:Raycast(
											part2.Position,
											v26 * (magnitude2 + radius),
											raycastParams2
										)

										if raycastResult then
											v24 = raycastResult.Position + raycastResult.Normal * radius
										end
									end

									part2.CFrame = CFrame.new(v24) * part2.CFrame.Rotation
								end
							end

							continue
						end
					end

					position = position2
					now = now2
				end
			end)
		end
	else
		local v12 = v[math.random(#v)]
		local v13 = v3[v12] or v3.arc
		local v14 = {}
		local v15 = {}

		for _, child in pairs(temp:GetChildren()) do
			local primaryPart = child.PrimaryPart
			local accessory = child:GetAttribute("Accessory") == true
			local wholePiece = child:GetAttribute("WholePiece") == true
			local anchorRank = child:GetAttribute("AnchorRank") or 1
			local rank

			if accessory then
				rank = -1
			elseif child.Name == "Left Leg" or child.Name == "Right Leg" then
				rank = 0
			elseif child.Name == "Torso" then
				rank = 1
			elseif child.Name == "Head" then
				rank = 3
			else
				rank = 2
			end

			local count = 0

			for _, part2 in pairs(child:GetChildren()) do
				if not (part2:IsA("BasePart") and part2 ~= child.PrimaryPart) then
					continue
				end

				local child2 = primaryPart:FindFirstChild(part2.Name)

				if not child2 then
					continue
				end

				local cFrame = part2.CFrame
				local v17 = (primaryPart.CFrame * part2:GetAttribute("Offset"):Inverse()).Position - cFrame.Position
				local magnitude = v17.Magnitude
				local unit = magnitude > 0.001 and v17.Unit or createVector(0, 1, 0)
				local unit2 = unit:Cross(math.abs(unit.Y) < 0.95 and createVector(0, 1, 0) or createVector(1, 0, 0)).Unit
				local unit3 = unit2:Cross(unit).Unit
				v14[part2] = {
					Weld = child2,
					rank = rank,
					isAcc = accessory,
					accRank = anchorRank,
					sortY = part2.Position.Y,
					Root = primaryPart,
					Limb = child,
					style = (accessory or wholePiece) and "arc" or v[math.random(#v)],
					duration = math.clamp(magnitude * v13.perStud, v13.min, v13.max) * (0.85 + math.random() * 0.15),
					side = unit2,
					up = unit3,
					arcHeight = (0.45 + math.random()) * math.max(magnitude * 0.35, 2.5),
					arcSideAmt = (math.random() * 2 - 1) * math.max(magnitude * 0.3, 2),
					orbitRadius = 5 + math.random() * 4,
					orbitRevs = 1 + math.random(),
					orbitPhase = math.random() * 3.141592653589793 * 2,
					orbitDir = math.random() < 0.5 and 1 or -1,
					spinAxis = Vector3.new(math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1).Unit,
					spinAmt = (math.random() * 2 - 1) * 3.141592653589793 * (v12 == "bounce" and 7 or v12 == "orbit" and 0 or 3),
					bounceCount = math.random(3, 5),
					bounceHeight = 2 + math.random() * 3
				}
				local trail2, trailA, trailA2 = attachTrail(part2)
				v14[part2].trail = trail2
				v14[part2].trailA0 = trailA
				v14[part2].trailA1 = trailA2
				count += 1
			end

			v15[child] = count
		end

		local total = 0
		local count = 0

		for _, v16 in pairs(v14) do
			total += v16.duration
			count += 1
		end

		if not (count > 0 and total / count) then
			local _ = v13.max
		end

		local v16 = {}

		for _, v17 in pairs(v14) do
			if v17.isAcc then
				continue
			end

			local name = v17.Limb.Name
			local v18 = v16[name]

			if not v18 then
				v18 = {
					minY = v17.sortY,
					maxY = v17.sortY,
					parts = {}
				}
				v16[name] = v18
			end

			if v17.sortY < v18.minY then
				v18.minY = v17.sortY
			end

			if v17.sortY > v18.maxY then
				v18.maxY = v17.sortY
			end

			table.insert(v18.parts, v17)
		end

		for k, v17 in pairs(v16) do
			local v18 = v4[k]

			if v18 then
				local v19 = v18.start / 60
				local v20 = v18.duration / 60
				local v21 = v20 * 0.4
				local v22 = v17.maxY - v17.minY

				for _, part2 in ipairs(v17.parts) do
					local v23 = not (v22 > 0.001) and 0 or (part2.sortY - v17.minY) / v22 or 0
					part2.Time = v19 + v23 * v21
					part2.duration = math.max(v20 - v23 * v21, 0.05)
				end
			else
				for _, part2 in ipairs(v17.parts) do
					part2.Time = 0
				end
			end
		end

		for _, v17 in pairs(v14) do
			if not v17.isAcc then
				continue
			end

			local anchorName = v17.Limb:GetAttribute("AnchorName")
			local v18 = anchorName and v4[anchorName]

			if v18 then
				v17.Time = v18.start / 60
				v17.duration = math.max(v18.duration / 60, 0.05)
			else
				v17.Time = 0
			end
		end

		local now = tick()
		local renderSteppedConnection = nil
		local ancestryChangedConnection = nil
		ancestryChangedConnection = char.AncestryChanged:Connect(function()
			if not char:IsDescendantOf(game) then
				if renderSteppedConnection then
					renderSteppedConnection:Disconnect()
				end

				if ancestryChangedConnection then
					ancestryChangedConnection:Disconnect()
				end

				object[char] = nil
			end
		end)
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			if char.Parent then
				local now2 = tick()
				local folders = {}
				local count2 = 0

				for folder, v17 in pairs(v14) do
					if now2 - now > v17.Time then
						if not v17.moveStart then
							v17.moveStart = now2
							v17.startPos = folder.Position
							v17.startRot = folder.CFrame.Rotation
							folder.Anchored = true
							folder.CanCollide = false
							folder.CollisionGroup = "nocol"

							for _, part2 in ipairs(folder:GetDescendants()) do
								if not part2:IsA("BasePart") then
									continue
								end

								part2.CanCollide = false
								part2.CollisionGroup = "nocol"
							end

							if v17.trail then
								v17.trail.Enabled = true
							end
						end

						local v18 = math.min((now2 - v17.moveStart) / v17.duration, 1)
						local v19 = v18 * v18 * (3 - v18 * 2)
						local cFrame = v17.Root.CFrame * folder:GetAttribute("Offset"):Inverse()

						if v18 >= 1 then
							folder.CFrame = cFrame
							folder.Anchored = false
							v17.Weld.Enabled = true
							releaseTrail(v17, char) -- equivalent call inferred; original call site unknown

							if #v2 > 0 and shared.sfx then
								shared.sfx({
									SoundId = v2[math.random(1, #v2)],
									CFrame = cFrame,
									Volume = 0.25
								}):Play()
							end

							folders[#folders + 1] = folder

							if v15[v17.Limb] then
								local v21 = v15
								local limb = v17.Limb
								v21[limb] -= 1

								if v15[v17.Limb] == 0 then
									local adornee

									if v17.Limb:GetAttribute("Accessory") then
										local sourceHandle = v17.Limb:FindFirstChild("SourceHandle")
										adornee = sourceHandle and sourceHandle.Value

										if adornee then
											adornee.Transparency = adornee:GetAttribute("OrigTransparency") or 0
											adornee:SetAttribute("OrigTransparency", nil)
										end
									else
										adornee = char:FindFirstChild(v17.Limb.Name)

										if adornee then
											adornee.Transparency = 0
										end
									end

									local highlight = Instance.new("Highlight")
									highlight.DepthMode = Enum.HighlightDepthMode.Occluded
									highlight.FillTransparency = 0
									highlight.OutlineTransparency = 1
									highlight.FillColor = Color3.new(0, 0, 0)
									highlight.Adornee = adornee
									highlight.Parent = char
									TweenService:Create(highlight, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
										FillTransparency = 1
									}):Play()
									TweenService:Create(highlight, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
										OutlineTransparency = 1
									}):Play()
									Debris:AddItem(highlight, 1)

									if #v2 > 0 and shared.sfx then
										local sfx = shared.sfx
										local v22 = {
											SoundId = v2[math.random(1, #v2)],
											CFrame = 0,
											Volume = 0.25
										}

										if adornee then
											cFrame = adornee.CFrame or cFrame
										end

										v22.CFrame = cFrame
										sfx(v22):Play()
									end

									v17.Limb:Destroy()
								end
							end
						else
							local startPos = v17.startPos
							local position = cFrame.Position
							local vector2

							if v17.style == "orbit" then
								local v20 = startPos - position
								local magnitude = Vector3.new(v20.X, 0, v20.Z).Magnitude
								local v21 = math.atan2(v20.Z, v20.X)
								local v22 = (1 - v18) ^ 3
								local v23 = magnitude * v22
								local v24 = math.clamp(1 - v23 / v17.orbitRadius, 0, 1)
								local v25 = v24 * v24 * (3 - v24 * 2)
								local v26 = v21 + v17.orbitDir * v17.orbitRevs * 3.141592653589793 * 2 * v25
								vector2 = Vector3.new(
									position.X + math.cos(v26) * v23,
									startPos.Y + (position.Y - startPos.Y) * (1 - v22),
									position.Z + math.sin(v26) * v23
								)
							elseif v17.style == "snap" then
								if v18 < 0.78 then
									v19 = (1 - (1 - v18 / 0.78) ^ 4) * 0.9
								else
									local v20 = (v18 - 0.78) / 0.22
									v19 = v20 * 0.1 * v20 * v20 + 0.9
								end

								vector2 = startPos:Lerp(position, v19)
							elseif v17.style == "bounce" then
								local Y = startPos.Y

								if v18 < 0.8 then
									local v20 = v18 / 0.8
									local lerped = startPos:Lerp(
										Vector3.new(position.X, Y, position.Z),
										1 - (1 - v20) * (1 - v20)
									)
									local v21 = v20 * v17.bounceCount
									local v22 = math.floor(v21)
									local v23 = v21 - v22
									local v24 = v17.bounceHeight * 0.55 ^ v22
									vector2 = Vector3.new(lerped.X, Y + 4 * v23 * (1 - v23) * v24, lerped.Z)
								else
									local v20 = (v18 - 0.8) / 0.19999999999999996
									vector2 = Vector3.new(position.X, Y, position.Z):Lerp(
										position,
										v20 * v20 * (3 - v20 * 2)
									) + Vector3.new(0, math.sin(v20 * 3.141592653589793) * v17.bounceHeight * 0.4, 0)
								end
							else
								local v20 = math.sin(v18 * 3.141592653589793)
								vector2 = startPos:Lerp(position, v19) + v17.up * (v17.arcHeight * v20) + v17.side * (v17.arcSideAmt * v20)
							end

							folder.CFrame = CFrame.new(vector2) * v17.startRot:Lerp(cFrame.Rotation, v19) * CFrame.fromAxisAngle(
								v17.spinAxis,
								v17.spinAmt * (1 - v19)
							)
							count2 += 1
						end
					else
						count2 += 1
					end
				end

				for _, v17 in ipairs(folders) do
					v14[v17] = nil
				end

				if count2 <= 0 then
					renderSteppedConnection:Disconnect()

					if ancestryChangedConnection then
						ancestryChangedConnection:Disconnect()
					end

					Transform({
						Char = char
					})
				end
			else
				renderSteppedConnection:Disconnect()

				if ancestryChangedConnection then
					ancestryChangedConnection:Disconnect()
				end

				object[char] = nil
			end
		end)
	end
end

function ZombieBreak.Materialize(p)
	local data = p.Data
	local char = data.Char
	local _ = char.HumanoidRootPart
	local _ = char.Humanoid
	local object2 = setmetatable({}, class)
	object2._maid = maid.new()
	local v12 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v12 then
			v12 = true
			object2._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	object2._maid:giveTask(char:GetAttributeChangedSignal("Burnt"):Connect(function()
		if char:GetAttribute("Burnt") then
			applyBurnToTemp(char)
		end
	end))

	local function FirstEvent()
		if data.Break then
			local primaryPart = char.PrimaryPart
			local position = primaryPart and primaryPart.Position
			local lastTime = tick()
			task.wait()
			Transform({
				Char = char,
				Break = true
			})
			task.wait()
			local velocity

			if primaryPart and primaryPart.Parent and position then
				local v14 = math.max(tick() - lastTime, 0.004166666666666667)
				velocity = (primaryPart.Position - position) / v14

				if velocity.Magnitude > 900 then
					velocity = createVector(0, 0, 0)
				elseif velocity.Magnitude > 500 then
					velocity = velocity.Unit * 500
				end
			else
				velocity = createVector(0, 0, 0)
			end

			Materialize({
				Char = char,
				Bool = true,
				Velocity = velocity
			})
		end

		if data.Regen then
			Materialize({
				Char = char
			})
		end
	end

	task.spawn(FirstEvent)
	task.wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

local v12 = {}

local function gatherTemplateMeshes(folder, descendants)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if not (descendant:IsA("SpecialMesh") or descendant:IsA("MeshPart")) then
			continue
		end

		local meshId = descendant.MeshId

		if not meshId or meshId == "" or v12[meshId] then
			continue
		end

		v12[meshId] = true
		descendants[#descendants + 1] = descendant
	end
end

function ZombieBreak.Warm(instance)
	if not instance then
		return
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	task.spawn(function()
		if not humanoid:FindFirstChildOfClass("HumanoidDescription") then
			local lastTime = tick()

			repeat
				task.wait(0.2)
			until humanoid:FindFirstChildOfClass("HumanoidDescription") or tick() - lastTime > 8 or not instance.Parent
		end

		if not instance.Parent then
			return
		end

		local v13 = {}

		for k in pairs(v6) do
			local template = findTemplate(instance, k)

			if template then
				gatherTemplateMeshes(template, v13)
			end
		end

		for i = 1, #v13, 12 do
			local v14 = {}

			for i2 = i, math.min(i + 11, #v13) do
				v14[#v14 + 1] = v13[i2]
			end

			pcall(function()
				ContentProvider:PreloadAsync(v14)
			end)
			task.wait()
		end
	end)
end

function ZombieBreak.BreakLimb(p)
	local data = p.Data
	local char = data.Char

	if not (char and char.Parent) then
		return
	end

	local limb = data.Limb

	if not limb then
		return
	end

	local v13 = char:FindFirstChild("Temp")

	if not v13 then
		v13 = Instance.new("Folder")
		v13.Name = "Temp"
		v13.Parent = char
		object[char] = true
	end

	local v14 = not char.PrimaryPart and createVector(0, 0, 0) or char.PrimaryPart.Position or createVector(0, 0, 0)
	local velocity = data.Velocity or createVector(0, 0, 0)
	local impacts = workspace:FindFirstChild("impacts")
	local impacts2 = impacts and impacts:FindFirstChild("impacts")
	local _3 = impacts2 and impacts2:FindFirstChild("3")
	local children = {}

	local function breakPart(part2)
		if not part2 or not part2:IsA("BasePart") or part2 == char.PrimaryPart or v13:FindFirstChild(part2.Name) then
			return
		end

		if not (v4[part2.Name] or part2.Transparency < 1) then
			return
		end

		buildOneLimbVoxels(char, part2, v13)
		local child = v13:FindFirstChild(part2.Name)

		if child then
			children[#children + 1] = child
		end

		for _, v15 in ipairs((gatherAccessories(char))) do
			local handle = v15:FindFirstChild("Handle")

			if not (handle and handle:GetAttribute("OrigTransparency") == nil and findAccessoryAnchor(handle, char) == part2) then
				continue
			end

			buildAccessoryModel(v15, char, v13)
			local child2 = v13:FindFirstChild("Acc_" .. v15.Name)

			if child2 then
				children[#children + 1] = child2
			end
		end
	end

	breakPart(char:FindFirstChild(limb))

	if data.Finish then
		for _, part2 in ipairs(char:GetChildren()) do
			if not (part2:IsA("BasePart") and part2 ~= char.PrimaryPart and (v4[part2.Name] or part2.Transparency < 1)) then
				continue
			end

			breakPart(part2)
		end

		for _, v15 in ipairs((gatherAccessories(char))) do
			local handle = v15:FindFirstChild("Handle")

			if not (handle and handle:GetAttribute("OrigTransparency") == nil) then
				continue
			end

			buildAccessoryModel(v15, char, v13)
			local child = v13:FindFirstChild("Acc_" .. v15.Name)

			if child then
				children[#children + 1] = child
			end
		end
	end

	if char:GetAttribute("Burnt") and applyBurnToTemp then
		applyBurnToTemp(char)
	end

	for _, v15 in ipairs(children) do
		burstOneLimb(v15, velocity, v14, _3)
	end
end

return ZombieBreak