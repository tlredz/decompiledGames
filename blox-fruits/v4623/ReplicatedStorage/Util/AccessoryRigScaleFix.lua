local createVector = vector.create
local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return function(parent, instance)
		assert(instance, "AccessoryRigScaleFix requires an accessory weld on the server")
		instance:SetAttribute("real", instance.C0)
		local clone = script.ScaleFix:Clone()
		clone.Parent = parent
		clone.Enabled = true
	end
end

local v = os.clock() + 10

local function getDependency(childName: string)
	local moduleScript = script.Parent:WaitForChild(childName, (math.max(0, v - os.clock())))
	assert(
		moduleScript and moduleScript:IsA("ModuleScript"),
		(`AccessoryRigScaleFix dependency timed out: {childName}`)
	)
	return moduleScript
end

local maid = script.Parent:WaitForChild("Maid", (math.max(0, v - os.clock())))
assert(maid and maid:IsA("ModuleScript"), "AccessoryRigScaleFix dependency timed out: Maid")
local attributeCounter = script.Parent:WaitForChild("AttributeCounter", (math.max(0, v - os.clock())))
assert(
	attributeCounter and attributeCounter:IsA("ModuleScript"),
	"AccessoryRigScaleFix dependency timed out: AttributeCounter"
)
local Maid = require(script.Parent.Maid)
local AttributeCounter = require(script.Parent.AttributeCounter)
local v2 = {}
return function(instance)
	local parent = instance.Parent
	local parent2 = parent and parent.Parent

	if not (parent and parent:IsA("Accessory") and parent2 and parent2:IsA("Model")) then
		return
	end

	if not instance:IsDescendantOf(workspace) then
		return
	end

	local v3 = v2[parent2]

	if v3 then
		if v3.rig == instance then
			return
		else
			v3.cleanup()
		end
	end

	local maid2 = Maid.new()
	local flag = false
	local v4 = false
	local v5 = os.clock() + 10

	local function isActive()
		local v6 = not flag

		if v6 then
			if instance.Parent == parent and parent.Parent == parent2 then
				return (parent2:IsDescendantOf(workspace))
			else
				return false
			end
		end

		return v6
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cleanup()
		if flag then
			return
		end

		flag = true
		v2[parent2] = nil
		maid2:DoCleaning()
	end

	v2[parent2] = {
		rig = instance,
		cleanup = cleanup
	}
	maid2:GiveTask(instance.Destroying:Connect(cleanup))
	maid2:GiveTask(parent.Destroying:Connect(cleanup))
	maid2:GiveTask(instance.AncestryChanged:Connect(function()
		local v6 = not flag

		if v6 then
			if instance.Parent == parent and parent.Parent == parent2 then
				v6 = parent2:IsDescendantOf(workspace)
			else
				v6 = false
			end
		end

		if not v6 then
			cleanup() -- equivalent call inferred; original call site unknown
		end
	end))

	local function initialize()
		local handle = parent:FindFirstChild("Handle")
		local humanoidRootPart = parent2:FindFirstChild("HumanoidRootPart")
		local humanoid = parent2:FindFirstChild("Humanoid")
		local accessoryWeld = handle and handle:FindFirstChild("AccessoryWeld")

		if not (handle and handle:IsA("BasePart") and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			return false
		end

		if not (humanoid and humanoid:IsA("Humanoid") and accessoryWeld and accessoryWeld:IsA("Weld")) then
			return false
		end

		if typeof(accessoryWeld:GetAttribute("real")) ~= "CFrame" then
			return false
		end

		v4 = true
		maid2.setupConnection = nil
		parent2:SetAttribute("Current_Transformation", parent.Name)
		maid2:GiveTask(function()
			parent2:SetAttribute("Current_Transformation", nil)
		end)
		AttributeCounter.add(humanoid, "BlockSit")
		maid2:GiveTask(function()
			AttributeCounter.remove(humanoid, "BlockSit")
		end)
		humanoid.Sit = false
		maid2:GiveTask(humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
			local v6 = not flag

			if v6 then
				if instance.Parent == parent and parent.Parent == parent2 then
					v6 = parent2:IsDescendantOf(workspace)
				else
					v6 = false
				end
			end

			if v6 and humanoid.SeatPart then
				humanoid.Sit = false
				task.defer(function()
					local v7 = not flag

					if v7 then
						if instance.Parent == parent and parent.Parent == parent2 then
							v7 = parent2:IsDescendantOf(workspace)
						else
							v7 = false
						end
					end

					if v7 then
						humanoid.Sit = false
					end
				end)
			end
		end))

		local function fixWeld()
			local real = accessoryWeld:GetAttribute("real")
			local v6 = not flag

			if v6 then
				if instance.Parent == parent and parent.Parent == parent2 then
					v6 = parent2:IsDescendantOf(workspace)
				else
					v6 = false
				end
			end

			if not v6 or accessoryWeld.Parent ~= handle or typeof(real) ~= "CFrame" then
				return
			end

			if accessoryWeld.C0 ~= real then
				accessoryWeld.C0 = real
			end

			if accessoryWeld.C1.Position ~= createVector(0, 0, 0) then
				accessoryWeld.C1 -= accessoryWeld.C1.Position
			end
		end

		local v6 = false

		local function queueFix()
			if not v6 then
				local v7 = not flag

				if v7 then
					if instance.Parent == parent and parent.Parent == parent2 then
						v7 = parent2:IsDescendantOf(workspace)
					else
						v7 = false
					end
				end

				if v7 then
					v6 = true
					task.defer(function()
						fixWeld()
						v6 = false
					end)
				end
			end
		end

		maid2:GiveTask(accessoryWeld:GetAttributeChangedSignal("real"):Connect(queueFix))
		maid2:GiveTask(accessoryWeld:GetPropertyChangedSignal("C0"):Connect(queueFix))
		maid2:GiveTask(accessoryWeld:GetPropertyChangedSignal("C1"):Connect(queueFix))
		fixWeld()

		local function removeExtraRoot(attachment)
			local parent3 = attachment.Parent
			local v7 = not flag

			if v7 then
				if instance.Parent == parent and parent.Parent == parent2 then
					v7 = parent2:IsDescendantOf(workspace)
				else
					v7 = false
				end
			end

			if not (v7 and parent3) then
				return
			end

			local root = nil

			if attachment:IsA("Attachment") and attachment.Name == "RootRigAttachment" then
				root = parent3:FindFirstChild("Root")
			elseif attachment.Name == "Root" and parent3:FindFirstChild("RootRigAttachment") then
				root = attachment
			end

			if root and (root:IsA("Motor6D") or root:IsA("Weld")) then
				task.defer(function()
					local v8 = not flag

					if v8 then
						if instance.Parent == parent and parent.Parent == parent2 then
							v8 = parent2:IsDescendantOf(workspace)
						else
							v8 = false
						end
					end

					if v8 and root:IsDescendantOf(parent) then
						root:Destroy()
					end
				end)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function fixPriority(part)
			local v7 = not flag

			if v7 then
				if instance.Parent == parent and parent.Parent == parent2 then
					v7 = parent2:IsDescendantOf(workspace)
				else
					v7 = false
				end
			end

			if v7 and part ~= humanoidRootPart and part:IsA("BasePart") and part.RootPriority > humanoidRootPart.RootPriority then
				part.RootPriority = -99
			end
		end

		maid2:GiveTask(parent2.DescendantAdded:Connect(fixPriority))
		maid2:GiveTask(parent.DescendantAdded:Connect(removeExtraRoot))

		for _, descendant in parent2:GetDescendants() do
			fixPriority(descendant) -- equivalent call inferred; original call site unknown
		end

		for _, descendant in parent:GetDescendants() do
			removeExtraRoot(descendant)
		end

		return true
	end

	if initialize() then
		return
	end

	maid2.setupConnection = RunService.Heartbeat:Connect(function()
		local v6 = not flag

		if v6 then
			if instance.Parent == parent and parent.Parent == parent2 then
				v6 = parent2:IsDescendantOf(workspace)
			else
				v6 = false
			end
		end

		if v6 then
			if v5 <= os.clock() then
				warn((`AccessoryRigScaleFix timed out after {10}s: {instance:GetFullName()}`))
				cleanup() -- equivalent call inferred; original call site unknown
			elseif not v4 then
				initialize()
			end
		else
			cleanup() -- equivalent call inferred; original call site unknown
		end
	end)
end