local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TopbarPlusReference = {}

function TopbarPlusReference.addToReplicatedStorage()
	if ReplicatedStorage:FindFirstChild(script.Name) then
		return false
	end

	local objectValue = Instance.new("ObjectValue")
	objectValue.Name = script.Name
	objectValue.Value = script.Parent
	objectValue.Parent = ReplicatedStorage
	return objectValue
end

function TopbarPlusReference.getObject()
	local child = ReplicatedStorage:FindFirstChild(script.Name)
	return child or false
end

return TopbarPlusReference