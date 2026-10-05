local parent = script.Parent
local Grid = require(parent:WaitForChild("Grid"))
local v = Grid.new()
local Shared = require(parent.Shared)
local Constants = require(parent.Constants)
require(parent.MaterialLookup)
local tasklib = require(game.ReplicatedStorage.Util.tasklib)
local v2 = tasklib("MapRegion", 0.006, false)
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character
local humanoidRootPart = nil
local class = {}
local position = vector.create(0, 0, 0)
local v3 = 0
local wait = task.wait
local clock = os.clock
local now = clock()

local function onCharacterAdded(instance)
	character = instance
	task.spawn(function()
		humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
		class:Update()
		humanoidRootPart.Changed:Connect(function()
			if (position - humanoidRootPart.Position).Magnitude > 50 then
				v3 = 0
			else
				position = humanoidRootPart.Position
			end
		end)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pause()
	if clock() - now > 0.05 then
		wait()
		now = clock()
	end
end

local function compress(value, p)
	if p == "MeshId" then
		return value
	end

	local v4 = string.gsub(value, "rbxthumb://type=Asset&id=", "*")
	local v5 = string.gsub(v4, "&w=150&h=150", "+")
	return (string.gsub(v5, "rbxassetid://", "-"))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function decompress(value)
	local v4 = string.gsub(value, "*", "rbxthumb://type=Asset&id=")
	local v5 = string.gsub(v4, "+", "&w=150&h=150")
	return (string.gsub(v5, "-", "rbxassetid://"))
end

class.LoadedGrids = {}
local v4 = nil

function class:Update()
	local currentGrid = v:GetCurrentGrid(humanoidRootPart.Position)
	position = humanoidRootPart.Position

	if currentGrid ~= v4 then
		self:GridChanged(v4, currentGrid, position)
		v4 = currentGrid
	end
end

local _ = {
	__tostring = function(p)
		return p.s
	end
}

local function key(p)
	return p
end

local v5 = {
	ParticleEmitter = "Texture",
	Beam = "Texture",
	Trail = "Texture",
	Decal = "Texture",
	Texture = "Texture",
	MeshPart = "TextureID",
	SpecialMesh = "TextureId"
}
local v6 = {}

function class:ActivateObject(instance)
	if instance and typeof(instance) == "Instance" then
		for k, v7 in instance:GetAttributes() do
			local v8 = tostring(k)

			if v8 == "Enabled" then
				instance.Enabled = true
			elseif v7 ~= instance then
				if v8 == "MeshId" then
					local v10 = tostring(v7)
					v2:spawn(function()
						v2:step()
						local success, result = pcall(function()
							v2:step()

							if v6[v10] then
								return v6[v10]
							end

							if v6[v10] == false then
								repeat
									task.wait()
								until v6[v10] ~= false

								if v6[v10] then
									return v6[v10]
								end
							end

							v6[v10] = false
							local v11 = v6
							local InsertService = game:GetService("InsertService")
							v11[v10] = InsertService:CreateMeshPartAsync(
								v10,
								Enum.CollisionFidelity.Default,
								Enum.RenderFidelity.Automatic
							)
							task.delay(5, function()
								v6[v10]:Destroy()
								v6[v10] = nil
							end)
							return v6[v10]
						end)

						if not success then
							warn(result, v10)
							return
						end

						v2:step()
						instance:ApplyMesh(result)
						v2:step()
						instance.Transparency = instance:GetAttribute("__Transparency")
						instance.CanCollide = instance:GetAttribute("__CanCollide")
					end)
				elseif v5[instance.ClassName] == k then
					instance[v8] = decompress(tostring(v7))
				end
			end
		end

		pause() -- equivalent call inferred; original call site unknown
	end
end

function class:DeactivateObject(instance)
	if instance then
		for k, v7 in instance:GetAttributes() do
			local v8 = tostring(k)

			if v8 == "Enabled" then
				instance.Enabled = false
			elseif v7 ~= instance then
				if v8 == "MeshId" then
					tostring(v7)
					task.spawn(function()
						instance:ApplyMesh(script.Parent.BlankMeshPart)
						instance.Transparency = 1
						instance.CanCollide = false
						local parent2 = instance.Parent
						instance.Parent = game.ReplicatedStorage.MapStash
						instance:GetPropertyChangedSignal("Transparency"):Once(function()
							instance.Parent = parent2
						end)
					end)
				elseif v5[instance.ClassName] == k then
					instance[v8] = ""
				end
			end
		end

		pause() -- equivalent call inferred; original call site unknown
	end
end

function class:DeactivateCell(p)
	local count = 0

	for k, object in p.Objects do
		count += 1
		class:DeactivateObject(object)

		if k % 5 == 0 then
			task.wait()
		end
	end

	task.wait()
end

function class:ActivateCell(p)
	local count = 0

	for k, object in p.Objects do
		count += 1
		class:ActivateObject(object)

		if k % 5 == 0 then
			task.wait()
		end
	end

	task.wait()
end

function class:GridChanged(_, p, p2)
	local neighboringCells = v:GetNeighboringCells(p2, 1)
	table.insert(neighboringCells, p)

	for _, loadedGrid in class.LoadedGrids do
		if not table.find(neighboringCells, loadedGrid) then
			class:DeactivateCell(loadedGrid)
		end
	end

	for _, neighboringCell in neighboringCells do
		if not table.find(class.LoadedGrids, neighboringCell) then
			class:ActivateCell(neighboringCell)
		end
	end

	class.LoadedGrids = neighboringCells
end

local Graphics = require(game.ReplicatedStorage.Util.Graphics)
local _ = Graphics.SmartScale
local scaleDown = Graphics.ScaleDown

function class:AddObject(part)
	local v7 = {}

	if part:HasTag(Constants.TAG_PROPERTY) then
		local v8 = part
		local parent2 = part.Parent
		part = parent2
		task.defer(function()
			v7.__ref = parent2

			if parent2.ClassName == "ParticleEmitter" then
				if part.FlipbookLayout == Enum.ParticleFlipbookLayout.None then
					v8.Value = scaleDown(v8.Value)
				end

				if parent2.Enabled then
					v7.Enabled = parent2.Enabled
					parent2.Enabled = false
				end
			elseif v8.Name ~= "MeshId" then
				v8.Value = scaleDown(v8.Value)
			end

			local CollectionService = game:GetService("CollectionService")
			CollectionService:RemoveTag(v8, Constants.TAG_PROPERTY)
			v8:Destroy()
			v8 = nil
		end)
	end

	local position2 = nil

	if part:IsA("BasePart") then
		position2 = part.Position
	else
		local parent2 = part

		repeat
			parent2 = parent2.Parent
		until not parent2 or parent2:IsA("BasePart")

		if parent2 then
			position2 = parent2.Position
		else
			local Global = require(game.ReplicatedStorage.Global)
			Global.TestGameWarn("what", part:GetFullName())
		end
	end

	if position2 then
		v:AddObject(v7, position2)
	end
end

function class:AddObject2(instance)
	if instance:IsA("Beam") then
		local MapBeamTextures = require(game.ReplicatedStorage.Util.MapBeamTextures)
		MapBeamTextures.preload(instance)
	else
		if instance:HasTag(Constants.TAG_OPTIMIZED) then
			task.defer(function()
				for k, v7 in instance:GetAttributes() do
					if k:sub(1, 5) ~= "Proxy" then
						continue
					end

					local v8 = k:sub(6)

					if instance.ClassName == "ParticleEmitter" then
						if instance.FlipbookLayout == Enum.ParticleFlipbookLayout.None then
							v7 = scaleDown(v7)
						end

						if instance.Enabled then
							instance:SetAttribute("Enabled", instance.Enabled)
							instance.Enabled = false
						end
					elseif v8 ~= "MeshId" then
						v7 = scaleDown(v7)
					end

					local CollectionService = game:GetService("CollectionService")
					CollectionService:RemoveTag(instance, Constants.TAG_OPTIMIZED)
					instance:SetAttribute(v8, nil)

					if v8 ~= "MeshId" then
						local v10 = string.gsub(v7, "rbxthumb://type=Asset&id=", "*")
						local v11 = string.gsub(v10, "&w=150&h=150", "+")
						v7 = string.gsub(v11, "rbxassetid://", "-")
					end

					instance:SetAttribute(v8, v7)
				end
			end)
		end

		local position2

		if instance:IsA("BasePart") then
			position2 = instance.Position
		else
			local parent2 = instance

			repeat
				parent2 = parent2.Parent
			until not parent2 or parent2:IsA("BasePart")

			if parent2 then
				position2 = parent2.Position
			else
				local Global = require(game.ReplicatedStorage.Global)

				if Global.TestGameWarn then
					local Global2 = require(game.ReplicatedStorage.Global)
					Global2.TestGameWarn("what", instance:GetFullName())
				end
			end
		end

		if position2 then
			v:AddObject(instance, position2)
		end
	end
end

function class:SetupGrids()
	for _, _ in Shared.GetAllObjects() do

	end

	local CollectionService = game:GetService("CollectionService")
	CollectionService:GetInstanceAddedSignal(Constants.TAG_PROPERTY):Connect(function(_) end)
	local CollectionService2 = game:GetService("CollectionService")
	CollectionService2:GetInstanceAddedSignal(Constants.TAG_OPTIMIZED):Connect(function(p)
		class:AddObject2(p)
	end)
	local CollectionService3 = game:GetService("CollectionService")

	for _, v7 in CollectionService3:GetTagged(Constants.TAG_OPTIMIZED) do
		class:AddObject2(v7)
	end
end

class:SetupGrids()

function class:Main()
	while task.wait(0.125) do
		local _, _ = pcall(function()
			if v3 - tick() < 0 then
				self:Update()
				v3 = tick() + 5
			end
		end)
	end
end

if character then
	local v7 = character
	character = v7
	task.spawn(function()
		humanoidRootPart = v7:WaitForChild("HumanoidRootPart")
		class:Update()
		humanoidRootPart.Changed:Connect(function()
			if (position - humanoidRootPart.Position).Magnitude > 50 then
				v3 = 0
			else
				position = humanoidRootPart.Position
			end
		end)
	end)
end

localPlayer.CharacterAdded:Connect(onCharacterAdded)

repeat
	task.wait()
until humanoidRootPart

task.spawn(class.Main, class)