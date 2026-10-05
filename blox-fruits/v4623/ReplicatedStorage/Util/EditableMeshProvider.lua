local AssetService = game:GetService("AssetService")
local EditableMeshProvider = {}
local v = {}

function AddToQueue(p)
	table.insert(v, p)
end

function EditableMeshProvider.GetEditableFromMesh(p)
	local success, result = pcall(function()
		if p then
			return AssetService:CreateEditableMeshAsync(p.MeshContent, {
				FixedSize = false
			})
		end

		return AssetService:CreateEditableMesh({
			FixedSize = false
		})
	end)

	if success then
		return result
	end

	if not result:match("limit") then
		error(result)
	end

	local thread = coroutine.running()
	AddToQueue(thread)
	coroutine.yield()
	return EditableMeshProvider.GetEditableFromMesh(p)
end

function EditableMeshProvider:ConvertEditableToMeshPart(instance)
	local editableMeshAsync = AssetService:CreateEditableMeshAsync(Content.fromObject(instance), {
		FixedSize = true
	})
	instance:Destroy()
	self:PopQueue()
	return AssetService:CreateMeshPartAsync(Content.fromObject(editableMeshAsync)), editableMeshAsync
end

function EditableMeshProvider:DestroyEditableMesh(instance)
	instance:Destroy()
	self:PopQueue()
end

function EditableMeshProvider:PopQueue()
	local v2 = table.remove(v, 1)

	if v2 then
		task.spawn(v2)
	end
end

return EditableMeshProvider