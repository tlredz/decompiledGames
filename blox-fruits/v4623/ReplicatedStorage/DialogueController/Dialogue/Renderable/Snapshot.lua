local Snapshot = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function iconSnapshotSize(data)
	if data._optionSize then
		return data._optionSize
	end

	if data._size then
		return UDim2.fromOffset(data._size.X, data._size.Y)
	end

	return nil
end

function Snapshot.wordSnapshots(options)
	local result = {}

	for _, v in options or {} do
		table.insert(result, {
			rich = v._rawRichText,
			raw = v._rawText,
			lineBreakAfter = v._lineBreakAfter,
			animate = v._animate,
			textXAlignment = v._textXAlignment,
			textYAlignment = v._textYAlignment,
			sprite = v._sprite,
			bubble = v._bubble
		})
	end

	return result
end

function Snapshot:iconSnapshot()
	if not self then
		return nil
	end

	local v = {
		image = self._image,
		imageRectOffset = self._imageRectOffset,
		imageRectSize = self._imageRectSize,
		backgroundImage = self._backgroundImage,
		backgroundImageRectOffset = self._backgroundImageRectOffset,
		backgroundImageRectSize = self._backgroundImageRectSize,
		color = self._color,
		transparency = self._transparency,
		scaleType = self._scaleType,
		size = 0,
		effect = 0,
		bubble = 0
	}
	local size = iconSnapshotSize(self) -- equivalent call inferred; original call site unknown
	v.size = size
	v.effect = self._effect
	v.bubble = self._bubble
	return v
end

function Snapshot:renderableSnapshot()
	local children = {}

	for _, v2 in self._children or {} do
		table.insert(children, Snapshot.renderableSnapshot(v2))
	end

	local v2 = {
		kind = self._kind or "group",
		children = children,
		layout = self._layout,
		columns = self._columns,
		gap = self._gap,
		cellSize = self._cellSize,
		cellPadding = self._cellPadding,
		xAlignment = self._xAlignment,
		yAlignment = self._yAlignment,
		frameSize = self._frameSize,
		framePosition = self._framePosition,
		frameAnchorPoint = self._frameAnchorPoint,
		layoutOrder = self._layoutOrder,
		textXAlignment = self._textXAlignment,
		textYAlignment = self._textYAlignment,
		capLines = self._capLines,
		visibleGraphemes = self._visibleGraphemes,
		textColor = self._textColor,
		textTransparency = self._textTransparency,
		stroke = self._stroke,
		isolateWords = self._isolateWords
	}

	if v2.kind == "text" then
		v2.words = Snapshot.wordSnapshots(self._words)
		return v2
	end

	if v2.kind == "icon" then
		v2.icon = Snapshot.iconSnapshot(self)
		return v2
	end

	if v2.kind == "react" then
		v2.reactComponent = self._reactComponent
		v2.reactProps = self._reactProps
		v2.reactChildren = self._reactChildren
	end

	return v2
end

function Snapshot.renderableSnapshots(options)
	local result = {}

	for _, v in options or {} do
		table.insert(result, Snapshot.renderableSnapshot(v))
	end

	return result
end

return Snapshot