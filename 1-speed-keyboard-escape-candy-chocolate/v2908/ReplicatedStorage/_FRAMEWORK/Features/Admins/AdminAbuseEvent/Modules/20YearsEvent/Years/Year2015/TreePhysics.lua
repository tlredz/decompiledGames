local createVector = vector.create
local Debris = game:GetService("Debris")
local Config = require(script.Parent.Config)
local DefaultYearMap = require(script.Parent.Parent.DefaultYearMap)
require(script.Parent.Parent.Parent.Types)

-- equivalent calls inferred from this helper; original call sites unknown
local function prepareDebris(p)
	p.Anchored = false
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
end

local function throwShedPart(part, position: Vector3, random, parent)
	local clone = part:Clone()

	for _, weldConstraint in clone:GetChildren() do
		if weldConstraint:IsA("WeldConstraint") then
			weldConstraint:Destroy()
		end
	end

	prepareDebris(clone) -- equivalent call inferred; original call site unknown
	clone.Parent = parent
	part:Destroy()
	local v = clone.Position - position
	local vector2 = Vector3.new(v.X, 0, v.Z)
	clone.AssemblyLinearVelocity = (not (vector2.Magnitude > 0) and createVector(1, 0, 0) or vector2.Unit) * Config.shedImpulseStuds + Vector3.new(
		0,
		Config.shedUpwardStuds,
		0
	)
	clone.AssemblyAngularVelocity = Vector3.new(
		random:NextNumber(-1, 1),
		random:NextNumber(-1, 1),
		random:NextNumber(-1, 1)
	) * Config.shedSpinRadians
	Debris:AddItem(clone, Config.shedLifetimeSeconds)
end

local function toppleTree(model, attribute: number, parent)
	local clone = model:Clone()
	local primaryPart = clone.PrimaryPart
	local highlight = clone:FindFirstChildOfClass("Highlight")

	if highlight then
		highlight:Destroy()
	end

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		prepareDebris(part) -- equivalent call inferred; original call site unknown
	end

	clone.Parent = parent
	model:Destroy()
	local boundingBox, v = clone:GetBoundingBox()
	local v2 = boundingBox.Position + Vector3.new(0, v.Y * 0.5, 0)
	primaryPart:ApplyImpulseAtPosition(
		Vector3.new(math.cos(attribute), 0, (math.sin(attribute))) * Config.fallPushStuds * primaryPart.AssemblyMass,
		v2
	)
	local sound = clone:FindFirstChild(Config.fallSoundName)

	if sound and sound:IsA("Sound") then
		sound:Play()
	end

	Debris:AddItem(clone, Config.fallDespawnDelaySeconds)
end

local function attachToMap(instance)
	local connections = {}
	local random = Random.new()

	local function watchTree(model)
		local child = model:FindFirstChild(Config.shedFolderName)

		if model:IsA("Model") and model.PrimaryPart and child then
			child:ClearAllChildren()

			if model:GetAttribute(Config.fallYawAttributeName) == nil then
				table.insert(connections, child.ChildAdded:Connect(function(part)
					local primaryPart = model.PrimaryPart

					if part:IsA("BasePart") and primaryPart then
						throwShedPart(part, primaryPart.Position, random, instance)
					end
				end))
				table.insert(
					connections,
					model:GetAttributeChangedSignal(Config.fallYawAttributeName):Connect(function()
						toppleTree(model, model:GetAttribute(Config.fallYawAttributeName), instance)
					end)
				)
			else
				model:Destroy()
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function watchTreesFolder(child)
		for _, child2 in child:GetChildren() do
			watchTree(child2)
		end

		table.insert(connections, child.ChildAdded:Connect(watchTree))
	end

	local child = instance:FindFirstChild(Config.treesFolderName)

	if child then
		watchTreesFolder(child) -- equivalent call inferred; original call site unknown
	end

	table.insert(connections, instance.ChildAdded:Connect(function(child2)
		if child2.Name == Config.treesFolderName then
			watchTreesFolder(child2) -- equivalent call inferred; original call site unknown
		end
	end))
	return function()
		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)
	end
end

return {
	start = function(p, p2: number)
		return DefaultYearMap.watchMap(p, p2, attachToMap)
	end
}