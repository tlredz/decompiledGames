local ContentProvider = game:GetService("ContentProvider")
local GuiHost = require(script.Parent.GuiHost)
local TexturePin = {}
local screenGui = nil
local v = {}
local v2 = {}
local v3 = {}
local v4 = newproxy()

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureGui()
	if screenGui and screenGui.Parent then
		return screenGui
	end

	local container = GuiHost.resolveContainer()

	if not container then
		return nil
	end

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PartIclesTexturePin"
	screenGui.Archivable = false
	screenGui.DisplayOrder = -999
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.Parent = container
	return screenGui
end

local function _resolveAssetId(instance)
	if typeof(instance) == "string" then
		if instance == "" or not instance then
			instance = nil
		end

		return instance
	else
		if typeof(instance) ~= "Instance" then
			return nil
		end

		if instance:IsA("Decal") or instance:IsA("Texture") or instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") then
			local texture = instance.Texture

			if not texture or texture == "" or not texture then
				texture = nil
			end

			return texture
		elseif instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
			local image = instance.Image

			if not image or image == "" or not image then
				image = nil
			end

			return image
		elseif instance:IsA("SpecialMesh") then
			local textureId = instance.TextureId

			if not textureId or textureId == "" or not textureId then
				textureId = nil
			end

			return textureId
		else
			if not instance:IsA("MeshPart") then
				return
			end

			local textureID = instance.TextureID

			if not textureID or textureID == "" or not textureID then
				textureID = nil
			end

			return textureID
		end
	end
end

local function _appendAssetIds(surfaceAppearance, list)
	if surfaceAppearance:IsA("SurfaceAppearance") then
		for _, v5 in ipairs({
			"ColorMap",
			"NormalMap",
			"MetalnessMap",
			"RoughnessMap"
		}) do
			local v6 = v5
			local success, result = pcall(function()
				return surfaceAppearance[v6]
			end)

			if success and result and result ~= "" then
				table.insert(list, result)
			end
		end
	else
		local v5 = _resolveAssetId(surfaceAppearance)

		if v5 then
			table.insert(list, v5)
		end
	end
end

function TexturePin.pin(p, p2)
	if not p then
		return
	end

	local v5 = p2 or v4
	local v6 = type(p) == "table" and p or { p }
	local v7 = {}

	for _, v8 in ipairs(v6) do
		local image = _resolveAssetId(v8)

		if not image then
			continue
		end

		local v10, v11

		if v[image] then
			v10 = v2[image]

			if not v10 then
				v10 = {}
				v2[image] = v10
			end

			v10[v5] = true
			v11 = v3[v5]

			if not v11 then
				v11 = {}
				v3[v5] = v11
			end

			v11[image] = true
		else
			local gui = ensureGui() -- equivalent call inferred; original call site unknown

			if not gui then
				break
			end

			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Pin"
			imageLabel.Image = image
			imageLabel.Size = UDim2.fromOffset(1, 1)
			imageLabel.Position = UDim2.fromOffset(0, 0)
			imageLabel.BackgroundTransparency = 1
			imageLabel.ImageTransparency = 0.99
			imageLabel.BorderSizePixel = 0
			imageLabel.ZIndex = 1
			imageLabel.Parent = gui
			v[image] = imageLabel
			table.insert(v7, imageLabel)
			v10 = v2[image]

			if not v10 then
				v10 = {}
				v2[image] = v10
			end

			v10[v5] = true
			v11 = v3[v5]

			if not v11 then
				v11 = {}
				v3[v5] = v11
			end

			v11[image] = true
		end
	end

	if #v7 > 0 then
		task.spawn(function()
			pcall(ContentProvider.PreloadAsync, ContentProvider, v7)
		end)
	end
end

function TexturePin.pinSubtree(p)
	if not p then
		return
	end

	local v5 = {}
	_appendAssetIds(p, v5)
	local success, descendants = pcall(p.GetDescendants, p)

	if success then
		for _, descendant in ipairs(descendants) do
			_appendAssetIds(descendant, v5)
		end
	end

	if #v5 > 0 then
		TexturePin.pin(v5, p)
	end
end

function TexturePin.isPinned(p)
	return v[p] ~= nil
end

function TexturePin.count()
	local count = 0

	for _ in pairs(v) do
		count += 1
	end

	return count
end

function TexturePin.unpin(p, p2)
	if not p then
		return
	end

	local v5 = p2 or v4
	local v6 = type(p) == "table" and p or { p }

	for _, v7 in ipairs(v6) do
		local v8 = _resolveAssetId(v7)

		if not (v8 and v[v8]) then
			continue
		end

		local v9 = v2[v8]

		if v9 then
			v9[v5] = nil
		end

		local v10 = v3[v5]

		if v10 then
			v10[v8] = nil
		end

		local v11 = false

		if v9 then
			for _ in pairs(v9) do
				v11 = true
				break
			end
		end

		if v11 then
			continue
		end

		pcall(v[v8].Destroy, v[v8])
		v[v8] = nil
		v2[v8] = nil
	end
end

function TexturePin.releaseOwner(p)
	if not p then
		return
	end

	local v5 = v3[p]

	if not v5 then
		return
	end

	for k in pairs(v5) do
		local v6 = v2[k]

		if v6 then
			v6[p] = nil
		end

		local v7 = false

		if v6 then
			for _ in pairs(v6) do
				v7 = true
				break
			end
		end

		if v7 or not v[k] then
			continue
		end

		pcall(v[k].Destroy, v[k])
		v[k] = nil
		v2[k] = nil
	end

	v3[p] = nil
end

function TexturePin.unpinSubtree(p)
	if not p then
		return
	end

	local v5 = {}
	_appendAssetIds(p, v5)
	local success, descendants = pcall(p.GetDescendants, p)

	if success then
		for _, descendant in ipairs(descendants) do
			_appendAssetIds(descendant, v5)
		end
	end

	if #v5 > 0 then
		TexturePin.unpin(v5, p)
	end
end

function TexturePin.clear()
	v = {}
	v2 = {}
	v3 = {}

	if screenGui then
		pcall(screenGui.Destroy, screenGui)
		screenGui = nil
	end
end

return TexturePin