local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SequenceUtils = require(script.Parent.SequenceUtils)
local InstanceUtils = {}

local function getDefaultSoundsParent()
	local _FRAMEWORK = ReplicatedStorage:FindFirstChild("_FRAMEWORK")
	local assets

	if _FRAMEWORK ~= nil then
		assets = _FRAMEWORK:FindFirstChild("Assets")
	end

	if assets == nil then
		assets = ReplicatedStorage:FindFirstChild("Assets")
	end

	if assets == nil then
		return nil
	end

	return (assets:FindFirstChild("Sounds"))
end

function InstanceUtils.reconcileInstances(parent, instance)
	assert(parent.ClassName == instance.ClassName, "target and template must have the same class")

	for _, child in instance:GetChildren() do
		local child2 = parent:FindFirstChild(child.Name)

		if child2 == nil or child2.ClassName ~= child.ClassName then
			if child2 ~= nil then
				child2:Destroy()
			end

			local clone = child:Clone()
			clone.Parent = parent
		else
			InstanceUtils.reconcileInstances(child2, child)
		end
	end

	return parent
end

function InstanceUtils.weld(p, part)
	local weld = Instance.new("Weld")
	weld.Part0 = p
	weld.Part1 = part
	weld.C1 = part.CFrame:ToObjectSpace(p.CFrame)
	weld.Name = `{p.Name} -> {part.Name}`
	weld.Parent = p
	return weld
end

function InstanceUtils.weldModel(folder, p)
	local v = p or folder.PrimaryPart or folder:FindFirstChildWhichIsA("BasePart")
	assert(v ~= nil, "model has no PrimaryPart or BasePart")

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") and part ~= v then
			InstanceUtils.weld(v, part)
		end
	end
end

function InstanceUtils.getInstanceFromPath(value: string, p, flag: boolean?)
	local v = p or getDefaultSoundsParent()

	if v == nil then
		return nil
	end

	for _, childName in string.split(value, "/") do
		if childName == "" then
			continue
		end

		local child = v:FindFirstChild(childName)

		if not child and flag then
			child = v:WaitForChild(childName)
		end

		if child == nil then
			return nil
		else
			v = child
		end
	end

	return v
end

function InstanceUtils.getPathFromInstance(instance, p)
	local v = p or getDefaultSoundsParent()

	if v == nil or not instance:IsDescendantOf(v) then
		return nil
	end

	local v2 = { instance.Name }
	local parent = instance.Parent

	while parent ~= nil and parent ~= v do
		table.insert(v2, 1, parent.Name)
		parent = parent.Parent
	end

	if parent == v then
		return (table.concat(v2, "/"))
	end

	return nil
end

function InstanceUtils.getC0ForWorldCFrame(p, cframe: CFrame)
	local part0 = p.Part0

	if part0 == nil then
		return CFrame.identity
	end

	return part0.CFrame:ToObjectSpace(cframe) * p.C1
end

function InstanceUtils.getWorldCFrameFromC0(data, cframe: CFrame?)
	local part0 = data.Part0

	if part0 == nil then
		return CFrame.identity
	end

	return part0.CFrame * (cframe or data.C0) * data.C1:Inverse()
end

function InstanceUtils.getPotentialInstance(p, p2: string)
	return (InstanceUtils.getInstanceFromPath(p2, p))
end

function InstanceUtils.waitForPotentialInstance(p, p2: string)
	return (InstanceUtils.getInstanceFromPath(p2, p, true))
end

function InstanceUtils.getNumberSequenceValueAtTime(p, p2: number)
	return SequenceUtils.getSequenceValueAtTime(p, p2)
end

function InstanceUtils.getColorSequenceValueAtTime(p, p2: number)
	return SequenceUtils.getSequenceValueAtTime(p, p2)
end

return InstanceUtils