local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local Object = {
	ModelToSimpleTool = function(self, model)
		if not (model and model:IsA("Model")) then
			warn("ModelToSimpleTool: expected a Model, got " .. tostring(model and model.ClassName))
			return nil
		end

		local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)

		if not primaryPart then
			warn("ModelToSimpleTool: " .. model.Name .. " has no BasePart")
			return nil
		end

		local tool = Instance.new("Tool")
		tool.Name = model.Name
		tool.RequiresHandle = true
		tool.CanBeDropped = false

		for k, v in model:GetAttributes() do
			if k:sub(1, 4) == "RBX_" then
				continue
			end

			local v2 = k
			local v3 = v
			pcall(function()
				tool:SetAttribute(v2, v3)
			end)
		end

		for _, tag in CollectionService:GetTags(model) do
			CollectionService:AddTag(tool, tag)
			CollectionService:RemoveTag(model, tag)
		end

		local part = Instance.new("Part")
		part.Name = "Handle"
		part.Size = createVector(1, 1, 1)
		part.Transparency = 1
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Massless = true
		part.CFrame = model:GetPivot()
		part.Parent = tool
		local v = {}

		for _, descendant in model:GetDescendants() do
			if descendant:IsA("JointInstance") then
				if descendant.Part0 then
					v[descendant.Part0] = true
				end

				if descendant.Part1 then
					v[descendant.Part1] = true
				end
			elseif descendant:IsA("WeldConstraint") then
				if descendant.Part0 then
					v[descendant.Part0] = true
				end

				if descendant.Part1 then
					v[descendant.Part1] = true
				end
			end
		end

		for _, part2 in model:GetDescendants() do
			if not part2:IsA("BasePart") then
				continue
			end

			part2.Anchored = false
			part2.CanCollide = false
			part2.Massless = true

			if not (part2 == primaryPart or not v[part2]) then
				continue
			end

			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = part
			weldConstraint.Part1 = part2
			weldConstraint.Parent = part
		end

		model.Parent = tool
		return tool
	end
}

function Object.AsTool(_, instance)
	if not instance then
		return nil
	end

	if instance:IsA("Tool") then
		return instance
	end

	if instance:IsA("Model") then
		return Object:ModelToSimpleTool(instance)
	end

	warn("AsTool: cannot hold a " .. instance.ClassName)
	return nil
end

function Object.PartToTerrain(_, instance)
	local v = ({
		Sand = Enum.Material.Sand,
		Dirt = Enum.Material.Ground,
		Rock = Enum.Material.Rock,
		Obsidian = Enum.Material.Basalt,
		Grass = Enum.Material.Grass,
		Water = Enum.Material.Water,
		Air = Enum.Material.Air
	})[instance.Name]

	if not v then
		warn("No terrain match found for part: " .. instance.Name)
		return
	end

	local cFrame = instance.CFrame
	local size = instance.Size
	workspace.Terrain:FillBlock(cFrame, size, v)
end

function Object.TurnModelIntoTool(_, folder)
	local scale = folder:GetScale()
	local tool = Instance.new("Tool")
	tool:ScaleTo(scale)
	tool.Name = folder.Name
	tool.RequiresHandle = true
	local primaryPart = folder.PrimaryPart

	if not primaryPart then
		warn("Model has no PrimaryPart! Cannot convert to Tool.")
		return nil
	end

	local v = nil

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.Massless = true
			descendant.Anchored = false
		elseif descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ProximityPrompt") then
			descendant:Destroy()
		elseif descendant:IsA("Animator") then
			v = descendant
		end
	end

	primaryPart.Name = "Handle"
	primaryPart.Parent = tool

	for _, child in ipairs(folder:GetChildren()) do
		child.Parent = tool
	end

	folder:Destroy()

	if v then
		local playingAnimationTracks = v:GetPlayingAnimationTracks()

		for _, playingAnimationTrack in playingAnimationTracks do
			playingAnimationTrack:Stop()
		end
	end

	tool.PrimaryPart = primaryPart
	return tool
end

function Object.TurnToolIntoModel(_, tool)
	if not (tool and tool:IsA("Tool")) then
		warn("TurnToolIntoModel: Invalid Tool provided")
		return nil
	end

	local clone = tool:Clone()
	local handle = clone:FindFirstChild("Handle")

	if not handle then
		for _, part in ipairs(clone:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			handle = part
			break
		end
	end

	if handle then
		local model = Instance.new("Model")
		model.Name = clone.Name

		for k, v in pairs(clone:GetAttributes()) do
			model:SetAttribute(k, v)
		end

		for _, child in ipairs(clone:GetChildren()) do
			if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ProximityPrompt") then
				child:Destroy()
			else
				child.Parent = model
			end
		end

		if handle and handle:IsDescendantOf(model) then
			model.PrimaryPart = handle
		end

		clone:Destroy()
		return model
	else
		warn("TurnToolIntoModel: No BasePart found to use as PrimaryPart")
		clone:Destroy()
		return nil
	end
end

function Object.PrintHierarchy(_, instance)
	if not instance then
		warn("PrintHierarchy: obj is nil")
		return
	end

	local parent = instance
	local v = {}

	while parent do
		table.insert(v, 1, parent.Name)

		if parent == game then
			break
		else
			parent = parent.Parent
		end
	end

	if parent ~= game then
		warn(instance:GetFullName() .. " is not a descendant of game")
		return
	end

	v[1] = "game"
	print(table.concat(v, " -> "))
end

function Object.GetHierarchyFrom(_, parent, p)
	if not parent then
		warn("PrintHierarchyFrom: obj is nil")
		return
	end

	local v = p or game

	if not parent:IsDescendantOf(v) then
		warn(parent:GetFullName() .. " is not a descendant of " .. v:GetFullName())
		return
	end

	local v2 = {}

	while parent and parent ~= v do
		table.insert(v2, 1, parent.Name)
		parent = parent.Parent
	end

	if v == game then
		v2[1] = "game"
	end

	return table.concat(v2, " -> ")
end

function Object.GetDistanceToAncestor(_, parent, p)
	if not (parent and p) then
		return -1
	end

	if parent == p then
		return 0
	end

	local count = 0

	while parent and parent ~= p do
		parent = parent.Parent
		count += 1
	end

	if parent == p then
		return count
	end

	return -1
end

function Object.RemoveTags(_, instance)
	for _, tag in ipairs(CollectionService:GetTags(instance)) do
		CollectionService:RemoveTag(instance, tag)
	end
end

function Object.JoinParts(_, instance, part, options)
	local C0 = (options or {}).C0
	local motor6D = Instance.new("Motor6D")
	motor6D.Part0 = instance
	motor6D.Part1 = part
	motor6D.Parent = instance
	local cFrameValue = part:FindFirstChildOfClass("CFrameValue") or instance:FindFirstChildOfClass("CFrameValue")

	if cFrameValue then
		motor6D.C0 = cFrameValue.Value
	end

	if C0 then
		motor6D.C0 = C0
	end

	motor6D.Name = "joint"
	return motor6D
end

function Object.CreateHitbox(_, model)
	if not (model and model:IsA("Model")) then
		warn("Invalid model provided for hitbox creation.")
		return
	end

	local vector2 = nil
	local vector3 = nil

	for _, part in ipairs(model:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local cFrame = part.CFrame
		local size = part.Size
		local v = {
			cFrame * Vector3.new(-size.X / 2, -size.Y / 2, -size.Z / 2),
			cFrame * Vector3.new(-size.X / 2, -size.Y / 2, size.Z / 2),
			cFrame * Vector3.new(-size.X / 2, size.Y / 2, -size.Z / 2),
			cFrame * Vector3.new(-size.X / 2, size.Y / 2, size.Z / 2),
			cFrame * Vector3.new(size.X / 2, -size.Y / 2, -size.Z / 2),
			cFrame * Vector3.new(size.X / 2, -size.Y / 2, size.Z / 2),
			cFrame * Vector3.new(size.X / 2, size.Y / 2, -size.Z / 2),
			cFrame * Vector3.new(size.X / 2, size.Y / 2, size.Z / 2)
		}

		for _, v2 in ipairs(v) do
			if vector2 then
				vector2 = Vector3.new(math.min(vector2.X, v2.X), math.min(vector2.Y, v2.Y), (math.min(vector2.Z, v2.Z)))
				vector3 = Vector3.new(math.max(vector3.X, v2.X), math.max(vector3.Y, v2.Y), (math.max(vector3.Z, v2.Z)))
			else
				vector3 = v2
				vector2 = vector3
				vector3 = vector2
			end
		end
	end

	if not (vector2 and vector3) then
		warn("Failed to calculate bounding box.")
		return
	end

	local size2 = vector3 - vector2
	local position = (vector2 + vector3) / 2
	local part = Instance.new("Part")
	part.Name = "Hitbox"
	part.Size = size2
	part.Position = position
	part.Anchored = true
	part.Transparency = 1
	part.Color = Color3.fromRGB(255, 0, 0)
	part.CanCollide = false
	part.Parent = model

	if model.PrimaryPart then
		part.CFrame = model.PrimaryPart.CFrame
	end

	return part
end

function Object.GetTopFacingSide(_, instance)
	local cFrame = instance.CFrame
	local v = -1e999
	local v2 = nil

	for k, v3 in pairs({
		Top = createVector(0, 1, 0),
		Bottom = createVector(0, -1, 0),
		Front = createVector(0, 0, -1),
		Back = createVector(0, 0, 1),
		Left = createVector(-1, 0, 0),
		Right = createVector(1, 0, 0)
	}) do
		local dot = cFrame:VectorToWorldSpace(v3):Dot(createVector(0, 1, 0))

		if not (v < dot) then
			continue
		end

		v2 = k
		v = dot
	end

	if not v2 then
		return nil, nil
	end

	local child = instance:FindFirstChild(v2)

	if child and child:FindFirstChildOfClass("Frame") then
		return v2, child:FindFirstChildOfClass("Frame").Name
	else
		print(v2)
	end

	return nil, nil
end

function Object.DeleteAllTags(_, instance)
	for _, tag in ipairs(CollectionService:GetTags(instance)) do
		CollectionService:RemoveTag(instance, tag)
	end
end

function Object.SetupInstance(_, p, name: string, parent, p2)
	p.Name = name

	if p2 then
		p.Value = p2
	end

	p.Parent = parent
	return p
end

function Object.ChangeWeldToJoint(_, instance)
	local motor6D = Instance.new("Motor6D")
	motor6D.C0 = instance.C0
	motor6D.C1 = instance.C1
	motor6D.Part0 = instance.Part0
	motor6D.Part1 = instance.Part1
	motor6D.Name = instance.Name
	motor6D.Parent = instance.Parent
	instance:Destroy()
end

function Object.CreateHolderPart(_, position, value)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanTouch = false
	part.CanCollide = false
	part.CanQuery = false
	part.Transparency = 1
	part.Position = position
	part.Size = createVector(1, 1, 1)
	part.Parent = workspace
	Debris:AddItem(part, value or 10)
	return part
end

function Object.CreateTestPart(_, position, value)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanTouch = false
	part.CanCollide = false
	part.CanQuery = false
	part.Transparency = 0.5
	part.Position = position
	part.Size = createVector(1, 1, 1)
	part.Parent = workspace
	Debris:AddItem(part, value or 10)
	return part
end

return Object