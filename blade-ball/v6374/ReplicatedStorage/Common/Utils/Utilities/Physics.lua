local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = require3("@game/ReplicatedStorage/Packages/Trove")
local v2 = require3("@game/ReplicatedStorage/Common/Utils/Utilities/Inst")
local isServer = RunService:IsServer()

local function fixJointOffset(_) end

local function fastWeld(clone, part, options)
	local v3 = options or {}
	v3.Parent = v3.Parent or clone
	local name = v3.Name

	if not name then
		if v3.Parent == clone then
			name = part.Name
		else
			name = clone.Name
		end
	end

	v3.Name = name
	v3.Part0 = clone
	v3.Part1 = part
	return (v2.new("WeldConstraint", v3))
end

local function createMotor(part, part2, options)
	local v3 = options or {}
	v3.Parent = v3.Parent or part
	local name = v3.Name

	if not name then
		if v3.Parent == part then
			name = part2.Name
		else
			name = part.Name
		end
	end

	v3.Name = name
	v3.C0 = v3.C0 or CFrame.identity
	v3.C1 = v3.C1 or CFrame.identity
	v3.Part0 = part
	v3.Part1 = part2
	return (v2.new("Motor6D", v3))
end

local function createWeld(head, handle, options)
	local v3 = options or {}
	v3.Parent = v3.Parent or head
	local name = v3.Name

	if not name then
		if v3.Parent == head then
			name = handle.Name
		else
			name = head.Name
		end
	end

	v3.Name = name
	v3.C0 = v3.C0 or CFrame.identity
	v3.C1 = v3.C1 or CFrame.identity
	v3.Part0 = head
	v3.Part1 = handle
	return (v2.new("Weld", v3))
end

local function createRigidWeld(attachment, attachment2, options)
	local v3 = options or {}
	v3.Parent = v3.Parent or attachment
	local name = v3.Name

	if not name then
		if v3.Parent == attachment then
			name = attachment2.Name
		else
			name = attachment.Name
		end
	end

	v3.Name = name
	v3.Attachment0 = attachment
	v3.Attachment1 = attachment2
	return (v2.new("RigidConstraint", v3))
end

local function resizePart(clone, scale: number)
	if typeof(clone) ~= "Instance" then
		error((`{clone} is not a Instance!`))
	end

	local parent = clone.Parent
	local model = Instance.new("Model")
	clone.Parent = model
	model:ScaleTo(scale)
	clone.Parent = parent
	model:Destroy()
	return clone
end

local function cloneAndWeld(instance, instance2, cframe: CFrame?, p, object)
	local v3 = p or instance:FindFirstChild("HumanoidRootPart")
	local clone = instance2:Clone()

	if object then
		object:Add(clone)
	end

	local v4 = cframe or CFrame.new()
	clone:PivotTo(v3:GetPivot() * v4)
	local v5 = fastWeld(clone, v3)

	if object then
		object:Add(v5)
	end

	clone.CanCollide = false
	clone.Anchored = false
	clone.Massless = true
	return clone, v5
end

local raycast

raycast = function(position: Vector3, vector: Vector3, p: number, filterDescendantsInstances, callback)
	local v3 = callback or function()
		return false
	end
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local raycastResult = workspace:Raycast(position + vector * 0.015, vector * p, raycastParams)

	if raycastResult and v3(raycastResult) and p - (raycastResult.Position - position).Magnitude > 0 then
		return raycast(raycastResult.Position, vector, p, filterDescendantsInstances, v3)
	end

	return raycastResult
end

local function addAccoutrementToChar(humanoid, accoutrement)
	local parent = humanoid.Parent
	local handle = accoutrement:FindFirstChild("Handle")

	if not (parent and humanoid and humanoid:IsA("Humanoid") and accoutrement and accoutrement:IsA("Accoutrement") and handle) then
		return
	end

	if isServer then
		humanoid:AddAccessory(accoutrement)
		return accoutrement
	end

	local attachment = handle:FindFirstChildWhichIsA("Attachment")
	local v3 = attachment and parent:QueryDescendants((`Attachment[Name="{attachment.Name}"]`))[1]
	accoutrement.Parent = parent

	if v3 then
		createRigidWeld(attachment, v3)
		return accoutrement
	end

	if attachment then
		warn(
			"Failed to weld accoutrement",
			accoutrement.Name,
			"cus of missing attachment",
			v3,
			"or missing attachment on accoutrement",
			attachment
		)
	else
		local head = parent:FindFirstChild("Head")

		if head then
			local weld = createWeld(head, handle, {
				Name = "HeadWeld"
			})
			weld.C0 = CFrame.new(0, 0.5, 0)
			weld.C1 = accoutrement.AttachmentPoint
			return accoutrement
		end
	end

	return accoutrement
end

local function attachModelToChar(callback, instance, instance2, parent, flag: boolean?)
	if parent == nil then
		error("Parent must be in DataModel", 2)
	end

	local maid = v.new()
	maid:AttachToInstance(parent)
	local clone = instance:Clone()

	if clone:IsA("Model") then
		clone:ScaleTo(instance2:GetScale())
	else
		resizePart(clone, instance2:GetScale())
	end

	for _, child in clone:GetChildren(), nil, nil do
		local name = child.Name
		local v3 = name == "Torso1" and "Torso" or name
		local child2 = instance2:FindFirstChild(v3)

		if child:IsA("BasePart") and child2 then
			child.Transparency = 1
			maid:Add(callback(child2, child))
		elseif child:IsA("Accoutrement") then
			local humanoid = instance2:FindFirstChildWhichIsA("Humanoid")

			if humanoid then
				maid:Add(addAccoutrementToChar(humanoid, child))
			end

			continue
		elseif v3 == "sord" then
			local v4 = instance2:QueryDescendants(">Model>BasePart#sord")[1]
			local motor6D

			if flag then
				motor6D = child:FindFirstChildWhichIsA("Motor6D", true)
			end

			if v4 and motor6D and (motor6D.Part0 == child or motor6D.Part1 == child) then
				if motor6D.Part0 == child then
					motor6D.Part0 = v4
				else
					motor6D.Part1 = v4
				end

				motor6D.Parent = v4
				maid:Add(motor6D)
				child:Destroy()
				continue
			elseif v4 then
				child.Transparency = 1
				maid:Add(callback(v4, child))
			end
		end

		maid:Add(child)
	end

	for _, child in clone:GetChildren(), nil, nil do
		child.Parent = parent
	end

	clone:Destroy()
	return maid
end

local function weldModelToChar(p, p2, p3)
	return (attachModelToChar(createWeld, p, p2, p3))
end

local function rigModelToChar(p, p2, parent, flag: boolean?)
	return (attachModelToChar(createMotor, p, p2, parent, flag))
end

return {
	Instance = v2.new,
	FastWeld = fastWeld,
	CreateMotor = createMotor,
	CreateWeld = createWeld,
	CreateRigidWeld = createRigidWeld,
	CloneAndWeld = cloneAndWeld,
	ResizePart = resizePart,
	AddAccoutrementToChar = addAccoutrementToChar,
	WeldModelToChar = weldModelToChar,
	RigModelToChar = rigModelToChar,
	Raycast = raycast
}