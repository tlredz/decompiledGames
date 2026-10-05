local typeof2 = typeof
local AiMimic = {}

function AiMimic:Get(p, childName)
	if p and childName then
		local npcMimicFolder = self:GetFolder(p):FindFirstChild("NpcMimicFolder")
		local child = npcMimicFolder and npcMimicFolder:FindFirstChild(childName)

		if child then
			return child.Value
		end
	end
end

function AiMimic:GetFolder(parent)
	if parent == nil then
		return
	end

	if parent:FindFirstChild("AiPrerequistes") then
		return parent.AiPrerequistes
	end

	local folder = Instance.new("Folder")
	folder.Name = "AiPrerequistes"
	local intValue = Instance.new("IntValue", folder)
	intValue.Name = "PathState"
	local intValue_2 = Instance.new("IntValue", folder)
	intValue_2.Name = "StateId"
	folder.Parent = parent
	return folder
end

function AiMimic:Set(instance, items)
	if instance:FindFirstChild("NpcMimicFolder") == nil then
		local folder = self:GetFolder(instance)

		if folder:FindFirstChild("NpcMimicFolder") == nil then
			local folder2 = Instance.new("Folder")
			folder2.Name = "NpcMimicFolder"
			folder2.Parent = folder

			if items then
				for k, item in pairs(items) do
					local v = typeof2(item) == "number" and "NumberValue" or typeof2(item) == "boolean" and "BoolValue" or "StringValue"
					local instance2 = Instance.new(v)
					instance2.Name = k
					instance2.Value = item
					instance2.Parent = folder2
				end
			end
		end
	end
end

return AiMimic