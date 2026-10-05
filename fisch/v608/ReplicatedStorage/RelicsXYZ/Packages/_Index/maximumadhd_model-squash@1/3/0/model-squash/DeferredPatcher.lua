local AssetService = game:GetService("AssetService")
local v = {}
local v2 = nil

local function applyPatches()
	v2 = nil

	for k, v3 in v do
		if k.Parent then
			local meshContent = v3.MeshContent or k.MeshContent
			local v5 = v3
			local v6 = k
			task.spawn(function()
				local meshPartAsync = AssetService:CreateMeshPartAsync(meshContent, {
					CollisionFidelity = v5.CollisionFidelity or v6.CollisionFidelity,
					RenderFidelity = v5.RenderFidelity or v6.RenderFidelity,
					FluidFidelity = v5.FluidFidelity or v6.FluidFidelity
				})
				meshPartAsync.TextureContent = v6.TextureContent
				v6:ApplyMesh(meshPartAsync)
			end)
		else
			v[k] = nil
		end
	end

	table.clear(v)
end

return {
	PatchMeshPart = function(p, p2, p3)
		local v3 = v[p]

		if not v3 then
			v[p] = {}
			v3 = v[p]
		end

		v3[p2] = p3
		v2 = v2 or task.defer(applyPatches)
	end
}