local UgcDynamicHeadConstants = {
	SKYE = "Skye",
	BRIAN = "Brian",
	SKYE_MESH_ID = "93785343700491",
	BRIAN_MESH_ID = "101115035255302",
	SKYE_HEAD_ASSET_ID = 134066749819030,
	BRIAN_HEAD_ASSET_ID = 105758682681174
}
local v = {
	[UgcDynamicHeadConstants.SKYE_MESH_ID] = UgcDynamicHeadConstants.SKYE,
	[UgcDynamicHeadConstants.BRIAN_MESH_ID] = UgcDynamicHeadConstants.BRIAN
}
local v2 = {
	[UgcDynamicHeadConstants.SKYE_HEAD_ASSET_ID] = UgcDynamicHeadConstants.SKYE,
	[UgcDynamicHeadConstants.BRIAN_HEAD_ASSET_ID] = UgcDynamicHeadConstants.BRIAN
}

local function extractNumericId(value: string)
	local v3 = string.match(value, "id=(%d+)")

	if v3 ~= nil then
		return v3
	end

	local v4 = string.match(value, "(%d+)$")

	if v4 == nil then
		return nil
	end

	return v4
end

function UgcDynamicHeadConstants.GetNameFromMeshId(value: string)
	local v3 = string.match(value, "id=(%d+)")

	if v3 == nil then
		v3 = string.match(value, "(%d+)$")

		if v3 == nil then
			v3 = nil
		end
	end

	if v3 == nil then
		return nil
	end

	return v[v3]
end

function UgcDynamicHeadConstants.GetNameFromHeadAssetId(p: number)
	return v2[p]
end

function UgcDynamicHeadConstants.IsUgcDynamicHeadMeshId(p: string)
	return UgcDynamicHeadConstants.GetNameFromMeshId(p) ~= nil
end

function UgcDynamicHeadConstants.GetNameFromCharacter(instance)
	local head = instance:FindFirstChild("Head")

	if head ~= nil and head:IsA("MeshPart") then
		local name = UgcDynamicHeadConstants.GetNameFromMeshId(head.MeshId)

		if name ~= nil then
			return name
		end
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if humanoid == nil then
		return nil
	end

	local head2 = tonumber(humanoid:GetAppliedDescription().Head)

	if head2 == nil or head2 == 0 then
		return nil
	end

	return UgcDynamicHeadConstants.GetNameFromHeadAssetId(head2)
end

return UgcDynamicHeadConstants