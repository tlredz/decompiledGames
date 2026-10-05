local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local SkillHitCache = {}
SkillHitCache.__index = SkillHitCache

function SkillHitCache.new(root)
	return (setmetatable({
		_root = root
	}, SkillHitCache))
end

function SkillHitCache:HasHit(childName: string, p2)
	local child = self._root:FindFirstChild(childName)

	if child == nil then
		return false
	end

	for _, objectValue in child:GetChildren() do
		if objectValue:IsA("ObjectValue") and objectValue.Value == p2 then
			return true
		end
	end

	return false
end

function SkillHitCache:MarkHit(name: string, p, p2: number?)
	if self:HasHit(name, p) then
		return
	end

	local parent = self._root:FindFirstChild(name)

	if parent == nil then
		parent = Instance.new("Folder")
		parent.Name = name
		parent.Parent = self._root
	end

	local objectValue = Instance.new("ObjectValue")
	objectValue.Name = p.Name
	objectValue.Value = p
	objectValue.Parent = parent

	if p2 ~= nil then
		DebrisModule:AddItem(objectValue, p2)
	end
end

return SkillHitCache