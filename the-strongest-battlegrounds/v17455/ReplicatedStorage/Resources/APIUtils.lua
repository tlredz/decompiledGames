local AssetService = game:GetService("AssetService")
local v = {
	{
		x1 = 0.39487179487179486,
		y1 = 0.13237924865831843,
		x2 = 0.611965811965812,
		y2 = 0.3595706618962433
	},
	{
		x1 = 0.03076923076923077,
		y1 = 0.6350626118067979,
		x2 = 0.24786324786324787,
		y2 = 0.8622540250447227
	},
	{
		x1 = 0.582905982905983,
		y1 = 0.6350626118067979,
		x2 = 0.8,
		y2 = 0.8622540250447227
	}
}
local v2 = {
	{
		x1 = 0.03076923076923077,
		y1 = 0.6350626118067979,
		x2 = 0.24786324786324787,
		y2 = 0.8622540250447227
	},
	{
		x1 = 0.582905982905983,
		y1 = 0.6350626118067979,
		x2 = 0.8,
		y2 = 0.8622540250447227
	}
}

local function isInArea(i, i2, X, Y, list)
	for _, v3 in ipairs(list) do
		local v4 = v3.x1 * X
		local v5 = v3.x2 * X
		local v6 = v3.y1 * Y
		local v7 = v3.y2 * Y

		if v4 <= i and i <= v5 and v6 <= i2 and i2 <= v7 then
			return true
		end
	end

	return false
end

return {
	getClothingColor = function(instance)
		if not instance then
			return nil
		end

		local shirtTemplate = nil
		local v3 = nil
		local flag = false

		if instance:IsA("Shirt") then
			shirtTemplate = instance.ShirtTemplate
			v3 = v
		elseif instance:IsA("Pants") then
			shirtTemplate = instance.PantsTemplate
			v3 = v2
		else
			if not instance:IsA("Accessory") or instance.AccessoryType ~= Enum.AccessoryType.Hat and instance.AccessoryType ~= Enum.AccessoryType.Hair then
				return nil
			end

			flag = true
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function extractAssetId(value: string?)
			if value and value ~= "" then
				return (string.match(value, "%d+"))
			end

			return nil
		end

		local function getAccessoryTextureId(instance2)
			local handle = instance2:FindFirstChild("Handle")

			if not handle then
				return nil
			end

			if handle:IsA("MeshPart") then
				local assetId = extractAssetId(handle.TextureID) -- equivalent call inferred; original call site unknown

				if assetId then
					return assetId
				end
			end

			local specialMesh = handle:FindFirstChildOfClass("SpecialMesh")

			if specialMesh then
				local assetId = extractAssetId(specialMesh.TextureId) -- equivalent call inferred; original call site unknown

				if assetId then
					return assetId
				end
			end

			local decal = handle:FindFirstChildOfClass("Decal")

			if not decal then
				return nil
			end

			local assetId2 = extractAssetId(decal.Texture) -- equivalent call inferred; original call site unknown
			return assetId2 or nil
		end

		local v4

		if flag then
			v4 = getAccessoryTextureId(instance)

			if not v4 then
				local handle = instance:FindFirstChild("Handle")

				if handle and handle:IsA("BasePart") then
					return handle.Color
				end

				return nil
			end
		else
			if shirtTemplate and shirtTemplate ~= "" then
				v4 = string.match(shirtTemplate, "%d+")
			end

			if not v4 then
				return nil
			end
		end

		local v5 = "rbxthumb://type=Asset&id=" .. v4 .. "&w=420&h=420"
		local success, result = pcall(function()
			return AssetService:CreateEditableImageAsync(Content.fromUri(v5))
		end)

		if not (success and result) then
			return nil
		end

		local X = result.Size.X
		local Y = result.Size.Y
		local pixelsBuffer = result:ReadPixelsBuffer(Vector2.zero, result.Size)
		result:Destroy()
		local v6 = {}
		local count = 0

		for i = 0, Y - 1, 3 do
			for i2 = 0, X - 1, 3 do
				if not (flag or isInArea(i2, i, X, Y, v3)) then
					continue
				end

				local v7 = (i * X + i2) * 4

				if not (buffer.readu8(pixelsBuffer, v7 + 3) > 200) then
					continue
				end

				local v8 = buffer.readu8(pixelsBuffer, v7)
				local v9 = buffer.readu8(pixelsBuffer, v7 + 1)
				local v10 = buffer.readu8(pixelsBuffer, v7 + 2)

				if v8 < 30 and v9 < 30 and v10 < 30 then
					continue
				end

				local v11 = math.floor(v8 / 25) * 25
				local v12 = math.floor(v9 / 25) * 25
				local v13 = math.floor(v10 / 25) * 25
				local v14 = v11 .. "_" .. v12 .. "_" .. v13

				if not v6[v14] then
					v6[v14] = {
						Count = 0,
						Color = Color3.fromRGB(v11, v12, v13)
					}
				end

				v6[v14].Count += 1
				count += 1
			end
		end

		if count == 0 then
			if flag then
				local handle = instance:FindFirstChild("Handle")

				if handle and handle:IsA("BasePart") then
					return handle.Color
				end
			end

			return nil
		else
			local v7 = {}

			for _, v8 in pairs(v6) do
				table.insert(v7, v8)
			end

			table.sort(v7, function(a, b)
				return a.Count > b.Count
			end)

			if #v7 > 0 then
				return v7[1].Color
			end

			return nil
		end
	end
}