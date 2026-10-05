local Codec = require(script.Parent.Codec)
local v = {
	OWNER = "QAOverlayV1"
}

local function createFrame(name: string)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Active = false
	frame.Interactable = false
	frame.Selectable = false
	return frame
end

local function createDot(frame, data)
	local name = data.name
	local frame2 = Instance.new("Frame")
	frame2.Name = name
	frame2.BackgroundTransparency = 1
	frame2.BorderSizePixel = 0
	frame2.Active = false
	frame2.Interactable = false
	frame2.Selectable = false
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.Position = UDim2.fromScale(data.position.X, data.position.Y)
	frame2.Size = UDim2.fromOffset(data.diameter, data.diameter)
	local backgroundColor

	if data.isWhite then
		backgroundColor = Color3.new(1, 1, 1)
	else
		backgroundColor = Color3.new(0, 0, 0)
	end

	frame2.BackgroundColor3 = backgroundColor
	frame2.BackgroundTransparency = 1 - data.opacity
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0.5, 0)
	uICorner.Parent = frame2
	frame2.Parent = frame
end

function v.clear(instance)
	for _, child in instance:GetChildren() do
		if child:GetAttribute("OverlayOwner") == v.OWNER then
			child:Destroy()
		end
	end
end

function v.mount(parent, data)
	assert(Codec.getIsPayload(data.payload), "Invalid overlay payload")
	local v2

	if data.viewport.X > 0 then
		v2 = data.viewport.Y > 0
	else
		v2 = false
	end

	assert(v2, "Overlay has no viewport")
	local dotOpacity = parent:GetAttribute("DotOpacity")
	local opacity = math.clamp(
		(type(dotOpacity) ~= "number" or dotOpacity ~= dotOpacity) and 0.06 or dotOpacity,
		0.01,
		0.18
	)
	local tilePixels = parent:GetAttribute("TilePixels")
	local v4 = math.min(
		math.ceil(math.max(
			math.clamp((type(tilePixels) ~= "number" or tilePixels ~= tilePixels) and 325 or tilePixels, 260, 650),
			data.viewport.X / 4,
			data.viewport.Y / 3
		) / 13) * 13,
		data.viewport.X,
		data.viewport.Y
	)
	local diameter = v4 * 4 / 325
	local encoded = Codec.encode(data.payload)
	local frame = Instance.new("Frame")
	frame.Name = "FingerprintLayer"
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Active = false
	frame.Interactable = false
	frame.Selectable = false
	frame.Size = UDim2.fromScale(1, 1)
	frame.ClipsDescendants = true
	frame:SetAttribute("OverlayOwner", v.OWNER)
	frame:SetAttribute("ProtocolVersion", Codec.VERSION)
	frame:SetAttribute("TilePixels", v4)
	frame:SetAttribute("PreviewOnly", data.isPreview)
	local frame2 = Instance.new("Frame")
	frame2.Name = "Tile_0_0"
	frame2.BackgroundTransparency = 1
	frame2.BorderSizePixel = 0
	frame2.Active = false
	frame2.Interactable = false
	frame2.Selectable = false
	frame2.Size = UDim2.fromOffset(v4, v4)

	for i = 0, 168 do
		local pair = Codec.getPair(i)
		local isWhite = encoded[i + 1] == 1
		createDot(frame2, {
			name = "A" .. i,
			position = Vector2.new(pair.ax, pair.ay),
			diameter = diameter,
			opacity = opacity,
			isWhite = isWhite
		})
		createDot(frame2, {
			name = "B" .. i,
			position = Vector2.new(pair.bx, pair.by),
			diameter = diameter,
			opacity = opacity,
			isWhite = not isWhite
		})
	end

	local v6 = math.ceil(data.viewport.X / v4)
	local v7 = math.ceil(data.viewport.Y / v4)

	for i = 0, v7 - 1 do
		for i2 = 0, v6 - 1 do
			local clone

			if i == 0 and i2 == 0 then
				clone = frame2
			else
				clone = frame2:Clone()
			end

			clone.Name = string.format("Tile_%d_%d", i2, i)
			clone.Position = UDim2.fromOffset(i2 * v4, i * v4)
			clone.Parent = frame
		end
	end

	frame:SetAttribute("TileCount", v6 * v7)
	v.clear(parent)
	frame.Parent = parent
	return frame
end

return table.freeze(v)