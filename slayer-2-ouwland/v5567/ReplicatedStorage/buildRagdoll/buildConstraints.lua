local getLastWordFromPascalCase = require(script.Parent:WaitForChild("getLastWordFromPascalCase"))
local childrenByName = {}

for _, child in pairs(script:GetChildren()) do
	childrenByName[child.Name] = child
end

function getConstraintTemplate(p)
	return childrenByName[getLastWordFromPascalCase(p)] or childrenByName.Default
end

function createConstraint(data)
	local name = data.Joint.Name
	local clone = getConstraintTemplate(name):Clone()
	clone.Attachment0 = data.Attachment0
	clone.Attachment1 = data.Attachment1
	clone.Name = name .. "RagdollConstraint"
	local objectValue = Instance.new("ObjectValue", clone)
	objectValue.Name = "RigidJoint"
	objectValue.Value = data.Joint
	return clone
end

return function(items)
	local folder = Instance.new("Folder")
	folder.Name = "RagdollConstraints"
	local v = {
		Root = true,
		Neck = true
	}

	for _, item in pairs(items) do
		if v[item.Joint.Name] then
			continue
		end

		local constraint = createConstraint(item)
		constraint.Parent = folder
	end

	return folder
end