local CollectionService = game:GetService("CollectionService")
local v = {}

local function onInstanceAdded(instance)
	local handle = instance:WaitForChild("Handle", 5)

	if not handle then
		return
	end

	handle:WaitForChild("Mesh", 5)
	local clone = handle:Clone()

	if not script:FindFirstAncestorWhichIsA("Player") then
		local Players = game:GetService("Players")
		Players:GetPlayerFromCharacter(instance.Parent)
	end

	local rigidConstraint = Instance.new("RigidConstraint")
	rigidConstraint.Name = "VisualConstraint"
	rigidConstraint.Parent = clone
	local attachment = Instance.new("Attachment")
	attachment.Parent = handle
	local attachment2 = Instance.new("Attachment")
	attachment2.Parent = clone
	rigidConstraint.Attachment0 = attachment
	rigidConstraint.Attachment1 = attachment2
	handle.LocalTransparencyModifier = 1
	handle:GetPropertyChangedSignal("Transparency"):Connect(function()
		clone.Transparency = handle.Transparency
	end)
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone.Parent = script

	for _, emitter in handle:GetChildren() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v2 = emitter
		emitter:GetPropertyChangedSignal("Enabled"):Connect(function()
			clone[v2.Name].Enabled = v2.Enabled
		end)
	end

	for _, decal in handle:GetDescendants() do
		if decal:IsA("Decal") then
			decal.Transparency = 1
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onToolEquipped()
		if not clone.Parent then
			return
		end

		clone.Parent = workspace
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onToolUnequipped()
		if not clone.Parent then
			return
		end

		clone.Parent = script
	end

	v[instance] = clone
	local ancestryChangedConnection = nil
	ancestryChangedConnection = instance.AncestryChanged:Connect(function()
		if not instance.Parent then
			ancestryChangedConnection:Disconnect()
		elseif instance.Parent:IsA("Model") then
			onToolEquipped() -- equivalent call inferred; original call site unknown
		else
			onToolUnequipped() -- equivalent call inferred; original call site unknown
		end
	end)
end

local function onInstanceRemoved(p)
	if v[p] then
		v[p]:Destroy()
		v[p] = nil
	end
end

local function onInitialize()
	for _, v2 in CollectionService:GetTagged("GlowTool") do
		onInstanceAdded(v2)
	end

	CollectionService:GetInstanceAddedSignal("GlowTool"):Connect(onInstanceAdded)
	CollectionService:GetInstanceRemovedSignal("GlowTool"):Connect(onInstanceRemoved)
end

onInitialize()