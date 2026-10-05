local AssetService = game:GetService("AssetService")

function loadMesh(instance, point: Vector2)
	local v = nil
	local v2 = pcall(function()
		local editableMeshAsync = AssetService:CreateEditableMeshAsync(instance.MeshContent)
		local meshPartAsync = AssetService:CreateMeshPartAsync(Content.fromObject(editableMeshAsync))
		instance:ApplyMesh(meshPartAsync)
		v = {
			EditableMesh = editableMeshAsync,
			ReferenceMesh = meshPartAsync,
			ScrollUVDirection = point,
			ScrollUVSpeed = instance:GetAttribute("ScrollUVSpeed") or 1,
			Velocity = point
		}
	end)
	instance:SetAttribute("Transparency", instance.Transparency)

	if v2 then
		return v
	end

	warn((`{instance.Name} failed to load!`))
	return nil
end

local class = {}
class.__index = class

function class:Step(p: number)
	self._FrequencyTime += p

	if self._FrequencyTime < self._Frequency then
		return
	end

	self._FrequencyTime = 0
	local cFrame = self._Camera.CFrame
	local lookVector = cFrame.LookVector

	for k, v in self._MeshData do
		if lookVector:Dot((k.Position - cFrame.Position).Unit) < -0.2 then
			continue
		end

		local v2 = v.Velocity * p * v.ScrollUVSpeed

		for _, v3 in v.EditableMesh:GetUVs() do
			local UV = v.EditableMesh:GetUV(v3)
			assert(UV, "bad uv")
			v.EditableMesh:SetUV(v3, UV + v2)
		end
	end
end

function class:SetModifier(p2, p3: number, p4: number)
	local v = self._MeshData[p2]

	if not v then
		return
	end

	local v2 = math.rad(p4)
	local v3 = math.cos(v2)
	local v4 = math.sin(v2)
	local scrollUVDirection = v.ScrollUVDirection
	v.Velocity = Vector2.new(
		v3 * scrollUVDirection.X - v4 * scrollUVDirection.Y,
		v4 * scrollUVDirection.X + v3 * scrollUVDirection.Y
	) * p3
end

function class:GetMeshes()
	local result = {}

	for k in self._MeshData do
		table.insert(result, k)
	end

	return result
end

function class:Destroy()
	table.clear(self._MeshData)
	setmetatable(self, nil)
end

return {
	new = function(instance)
		local meshs = instance:FindFirstChild("Meshs")
		assert(meshs, "bad meshs folder")
		local meshData = {}

		for _, part in meshs:GetChildren() do
			if not part:IsA("MeshPart") then
				continue
			end

			local scrollUVDirection = part:GetAttribute("ScrollUVDirection")

			if not scrollUVDirection then
				continue
			end

			local v2 = loadMesh(part, scrollUVDirection)

			if v2 then
				meshData[part] = v2
			end
		end

		return (setmetatable({
			_MeshData = meshData,
			_Camera = workspace.CurrentCamera,
			_Frequency = 0.016666666666666666,
			_FrequencyTime = 0
		}, class))
	end
}