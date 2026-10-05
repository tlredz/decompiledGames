local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HighlightTargets = require(ReplicatedStorage.GameServices:WaitForChild("HighlightTargets"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local GameSettings = require(ReplicatedStorage2:WaitForChild("GameSettings"))
local Mutations = require(ReplicatedStorage2:WaitForChild("GameData"):WaitForChild("Mutations"))
local Eggs = require(ReplicatedStorage2:WaitForChild("GameData"):WaitForChild("Eggs"))
local PetRigService = require(ReplicatedStorage2:WaitForChild("GameServices"):WaitForChild("PetRigService"))
local gameObjects = workspace:WaitForChild("GameObjects")
local v = {}
local v2 = {}

local function RestoreSolid(p)
	if not (p and p.Solid) then
		return
	end

	local solid = p.Solid
	p.Solid = nil

	for k, original in solid.Originals do
		local v3 = original
		local v4 = k
		pcall(function()
			for k2, v5 in v3 do
				v4[k2] = v5
			end
		end)
	end

	solid.Stash:Destroy()
end

local function ApplySolid(folder, state)
	if not state then
		return
	end

	if not state.Solid then
		PetRigService.ApplyMutationSkin(folder, nil)
		local folder2 = Instance.new("Folder")
		folder2.Name = "RainbowOriginalSurfaces"
		folder2.Parent = folder
		state.Solid = {
			Originals = {},
			Parts = {},
			Stash = folder2
		}
	end

	local solid = state.Solid
	local color = Color3.fromHSV(os.clock() / 4 % 1, 0.85, 1)

	for _, descendant in folder:GetDescendants() do
		local parent = descendant
		local v3 = false

		while parent and parent ~= folder do
			if parent == solid.Stash or parent.Name == "SpawnMutationHitbox" or parent.Name == "MutationHitbox" then
				v3 = true
				break
			else
				parent = parent.Parent
			end
		end

		if v3 then
			continue
		end

		if descendant:IsA("BasePart") then
			if not solid.Originals[descendant] then
				solid.Originals[descendant] = {
					Color = descendant.Color
				}

				if descendant:IsA("MeshPart") then
					solid.Originals[descendant].TextureID = descendant.TextureID
				end
			end

			solid.Parts[descendant] = true

			if descendant:IsA("MeshPart") then
				descendant.TextureID = ""
			end

			descendant.Color = color
		elseif descendant:IsA("SpecialMesh") then
			if not solid.Originals[descendant] then
				solid.Originals[descendant] = {
					TextureId = descendant.TextureId,
					VertexColor = descendant.VertexColor
				}
			end

			descendant.TextureId = ""
			descendant.VertexColor = createVector(1, 1, 1)
		elseif descendant:IsA("SurfaceAppearance") and descendant.Parent:IsA("MeshPart") then
			solid.Originals[descendant] = {
				Parent = descendant.Parent
			}
			descendant.Parent = solid.Stash
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			if not solid.Originals[descendant] then
				solid.Originals[descendant] = {
					Transparency = descendant.Transparency
				}
			end

			descendant.Transparency = 1
		end
	end

	local highlight = state.Highlight

	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "SpawnMutationHighlight"
		highlight.Parent = folder
		state.Highlight = highlight
	end

	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 0.5
	highlight.OutlineColor = Color3.new(0, 0, 0)
	HighlightTargets.SetAdornee(highlight, folder)

	if folder:IsA("Tool") then
		local v4 = nil
		local v5 = nil

		for k in solid.Parts do
			if not (k:IsDescendantOf(folder) and k.Transparency < 1) then
				continue
			end

			local v6 = k.Size.X * k.Size.Y * k.Size.Z

			if not (not v4 or v5 < v6) then
				continue
			end

			v5 = v6
			v4 = k
		end

		if v4 then
			HighlightTargets.SetAdornee(highlight, v4)
		end
	end

	v2[folder] = true
end

local function Clear(instance)
	local v3 = v[instance]

	if not v3 then
		return
	end

	RestoreSolid(v3)
	v[instance] = nil
	v2[instance] = nil

	for _, connection in v3.Connections do
		connection:Disconnect()
	end

	if v3.Highlight then
		v3.Highlight:Destroy()
	end

	local spawnMutationHitbox = instance:FindFirstChild("SpawnMutationHitbox")

	if spawnMutationHitbox then
		spawnMutationHitbox:Destroy()
	end
end

local function Apply(tool)
	local spawnMutation = tool:GetAttribute("SpawnMutation")
	local v3 = v[tool]
	local v4

	if spawnMutation == "Rainbow" then
		v4 = GameSettings.RAINBOWMUTATIONUSESOLIDCOLORS == true
	else
		v4 = false
	end

	if not v4 then
		RestoreSolid(v3)
	end

	if spawnMutation and Mutations.IsSpawned(spawnMutation) then
		PetRigService.ApplyMutationAura(tool, spawnMutation, nil, "SpawnMutationHitbox")

		if v4 then
			ApplySolid(tool, v3)
			return
		end

		local v5 = PetRigService.ApplyMutationSkin(tool, spawnMutation)
		local highlight = v3 and v3.Highlight

		if v5 then
			if highlight then
				highlight:Destroy()

				if v3 then
					v3.Highlight = nil
				end
			end

			v2[tool] = nil
		else
			if not highlight then
				highlight = Instance.new("Highlight")
				highlight.Name = "SpawnMutationHighlight"
				highlight.FillTransparency = 0.65
				highlight.OutlineTransparency = 1
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				HighlightTargets.SetAdornee(highlight, tool)
				highlight.Parent = tool

				if v3 then
					v3.Highlight = highlight
				end
			end

			local mutation = Mutations[spawnMutation]
			local highlightFillColor = type(mutation) == "table" and mutation.HighlightFillColor or Mutations.ColorFor(spawnMutation) or Color3.new(
				1,
				1,
				1
			)
			highlight.FillColor = highlightFillColor
			highlight.OutlineColor = highlightFillColor
			highlight.FillTransparency = type(mutation) ~= "table" and 0.65 or tonumber(mutation.HighlightFillTransparency) or 0.65

			if spawnMutation == "Rainbow" then
				highlight.FillTransparency = math.max(highlight.FillTransparency - 0.1, 0)
			end

			highlight.OutlineTransparency = 1

			if tool:IsA("Tool") then
				local v7 = nil
				local v8 = nil

				for _, part in tool:GetDescendants() do
					if not (part:IsA("BasePart") and part.Transparency < 1) then
						continue
					end

					local v9 = part.Size.X * part.Size.Y * part.Size.Z

					if not (not v7 or v8 < v9) then
						continue
					end

					v8 = v9
					v7 = part
				end

				if v7 then
					HighlightTargets.SetAdornee(highlight, v7)
				end
			end

			v2[tool] = spawnMutation == "Rainbow" or nil
		end
	else
		PetRigService.ApplyMutationSkin(tool, nil)

		if v3 and v3.Highlight then
			v3.Highlight:Destroy()
			v3.Highlight = nil
		end

		local spawnMutationHitbox = tool:FindFirstChild("SpawnMutationHitbox")

		if spawnMutationHitbox then
			spawnMutationHitbox:Destroy()
		end

		v2[tool] = nil
	end
end

local function Watch(instance)
	if v[instance] then
		return
	end

	local v3 = {
		Connections = {}
	}
	v[instance] = v3
	Apply(instance)
	table.insert(v3.Connections, instance.DescendantRemoving:Connect(function(descendant)
		if v3.Solid then
			v3.Solid.Parts[descendant] = nil
		end

		if v3.RigPart == descendant then
			v3.RigPart = nil
		end
	end))
	table.insert(v3.Connections, instance.DescendantAdded:Connect(function(instance2)
		if v3.Solid and (instance2:IsA("BasePart") or instance2:IsA("SpecialMesh") or instance2:IsA("SurfaceAppearance") or instance2:IsA("Decal")) then
			if v3.SolidRefreshPending then
				return
			end

			v3.SolidRefreshPending = true
			task.defer(function()
				v3.SolidRefreshPending = nil

				if v[instance] == v3 and v3.Solid then
					ApplySolid(instance, v3)
				end
			end)
		end
	end))
	table.insert(v3.Connections, instance:GetAttributeChangedSignal("SpawnMutation"):Connect(function()
		Apply(instance)
	end))
	table.insert(v3.Connections, instance.Destroying:Connect(function()
		Clear(instance)
	end))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HasAura(instance, childName)
	local child = instance:FindFirstChild(childName)

	if child then
		return child:FindFirstChildWhichIsA("ParticleEmitter", true) ~= nil
	end

	return false
end

local function Ensure(instance)
	local spawnMutation = instance:GetAttribute("SpawnMutation")

	if spawnMutation and Mutations.IsSpawned(spawnMutation) then
		-- equivalent call inferred; original call site unknown
		if not HasAura(instance, "SpawnMutationHitbox") then
			Apply(instance)
		end
	end

	local mutation = instance:GetAttribute("Mutation")

	if mutation and not instance:IsDescendantOf(gameObjects) then
		-- equivalent call inferred; original call site unknown
		if not HasAura(instance, "MutationHitbox") then
			PetRigService.ApplyMutationAura(instance, mutation)
		end
	end
end

local function IsRig(folder)
	local hasTag = folder:HasTag("SpawnMutationCarrier")

	if not folder:IsA("Model") or folder:IsA("Tool") and not hasTag or not folder:IsDescendantOf(workspace) then
		return false
	end

	local v3 = v[folder]
	local rigPart = v3 and v3.RigPart

	if rigPart and rigPart:IsDescendantOf(folder) and (rigPart.Name ~= "Handle" or hasTag) then
		return true
	end

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and (part.Name ~= "Handle" or hasTag)) then
			continue
		end

		if v3 then
			v3.RigPart = part
		end

		return true
	end

	return false
end

local function StripStray(tool)
	if not tool:IsA("Tool") or tool:HasTag("SpawnMutationCarrier") then
		return
	end

	for _, childName in { "SpawnMutationHitbox", "SpawnMutationHighlight" } do
		local child = tool:FindFirstChild(childName)

		if child then
			child:Destroy()
		end
	end
end

local v3 = { "Pet", "PetReveal", "SpawnMutationCarrier" }

for _, tag in v3 do
	for _, v4 in CollectionService:GetTagged(tag) do
		if IsRig(v4) then
			task.defer(Watch, v4)
		end
	end

	CollectionService:GetInstanceAddedSignal(tag):Connect(function(p)
		if IsRig(p) then
			task.defer(Watch, p)
		end
	end)
	CollectionService:GetInstanceRemovedSignal(tag):Connect(Clear)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsPetRig(instance)
	return IsRig(instance) and instance:GetAttribute("PetName") ~= nil
end

for _, child in gameObjects:GetChildren() do
	if IsPetRig(child) then
		task.defer(Watch, child)
	end
end

gameObjects.ChildAdded:Connect(function(child)
	task.defer(function()
		if child.Parent and IsPetRig(child) then
			Watch(child)
		end
	end)
end)
gameObjects.ChildRemoved:Connect(Clear)
local Players = game:GetService("Players")

-- equivalent calls inferred from this helper; original call sites unknown
local function WatchHeldTool(tool)
	if tool:IsA("Tool") and Eggs[tool.Name] and tool:GetAttribute("SpawnMutation") then
		task.defer(Watch, tool)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HookCharacter(character)
	for _, child in character:GetChildren() do
		WatchHeldTool(child) -- equivalent call inferred; original call site unknown
	end

	character.ChildAdded:Connect(WatchHeldTool)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HookPlayer(player)
	if player.Character then
		HookCharacter(player.Character) -- equivalent call inferred; original call site unknown
	end

	player.CharacterAdded:Connect(HookCharacter)
end

for _, v4 in Players:GetPlayers() do
	HookPlayer(v4) -- equivalent call inferred; original call site unknown
end

Players.PlayerAdded:Connect(HookPlayer)
task.spawn(function()
	while true do
		task.wait(1)
		local v4 = {}

		for _, tag in v3 do
			for _, v5 in CollectionService:GetTagged(tag) do
				if v4[v5] then
					continue
				end

				v4[v5] = true

				if IsRig(v5) then
					Watch(v5)
					Ensure(v5)
				else
					StripStray(v5)
				end
			end
		end

		for _, child in gameObjects:GetChildren() do
			if v4[child] or not IsPetRig(child) then
				continue
			end

			Watch(child)
			Ensure(child)
		end
	end
end)
RunService.Heartbeat:Connect(function()
	if next(v2) == nil then
		return
	end

	local v4 = os.clock() / 4 % 1
	local color = Color3.fromHSV(v4, 0.85, 1)

	for k in v2 do
		if not k:IsDescendantOf(workspace) then
			continue
		end

		local v5 = v[k]
		local highlight = v5 and v5.Highlight

		if v5 and v5.Solid then
			for k2 in v5.Solid.Parts do
				if k2.Parent then
					k2.Color = color
				else
					v5.Solid.Parts[k2] = nil
				end
			end
		elseif highlight then
			if not HighlightTargets.IsMuted(highlight) then
				highlight.FillColor = color
				highlight.OutlineColor = color
			end
		else
			v2[k] = nil
		end
	end
end)