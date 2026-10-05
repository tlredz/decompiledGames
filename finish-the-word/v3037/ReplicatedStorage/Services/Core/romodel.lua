local cloneTable

cloneTable = function(item)
	local v = {}

	for k, item2 in pairs(item) do
		if type(item2) == "table" then
			v[k] = cloneTable(item2)
		else
			v[k] = item2
		end
	end

	return (setmetatable(v, getmetatable(item) or {}))
end

local class = {}

function class.new()
	return (setmetatable({
		PreProperties = {},
		PreChildren = {},
		Properties = {},
		Children = {}
	}, class))
end

local v = {
	PointLight = {
		Brightness = "number"
	},
	Camera = {
		CFrame = "CFrame",
		FieldOfView = "number"
	},
	UIScale = {
		Scale = "number"
	},
	UITextSizeConstraint = {
		MinTextSize = "number",
		MaxTextSize = "number"
	},
	UIGradient = {
		Color = "ColorSequence",
		Rotation = "number",
		Transparency = "NumberSequence",
		Offset = "Vector2"
	},
	UICorner = {
		Scale = "number",
		CornerRadius = "Vector2"
	},
	Attachment = {
		AncestryChanged = "RBXScriptSignal",
		GetChildren = "function",
		Name = "string"
	},
	BillboardGui = {
		Active = "boolean",
		AncestryChanged = "RBXScriptSignal",
		Size = "UDim2",
		StudsOffset = "Vector3",
		StudsOffsetWorldSpace = "Vector3",
		Enabled = "boolean",
		AlwaysOnTop = "boolean",
		Adornee = "userdata",
		MaxDistance = "number",
		Name = "string"
	},
	BodyVelocity = {
		AncestryChanged = "RBXScriptSignal",
		MaxForce = "Vector3",
		Name = "string",
		Parent = "Instance",
		Velocity = "Vector3"
	},
	Folder = {
		AncestryChanged = "RBXScriptSignal",
		IsA = "function",
		Name = "string",
		Parent = "nil"
	},
	Frame = {
		AbsolutePosition = "Vector2",
		AbsoluteSize = "Vector2",
		AutomaticSize = "EnumItem",
		AncestryChanged = "RBXScriptSignal",
		AnchorPoint = "Vector2",
		BackgroundColor3 = "Color3",
		BackgroundTransparency = "number",
		BorderSizePixel = "number",
		ChildAdded = "RBXScriptSignal",
		ChildRemoved = "RBXScriptSignal",
		ClassName = "string",
		ClipsDescendants = "bool",
		FindFirstChild = "function",
		GetChildren = "function",
		GetFullName = "function",
		GetPropertyChangedSignal = "function",
		IsA = "function",
		LayoutOrder = "number",
		Name = "string",
		Parent = "nil",
		Position = "UDim2",
		Size = "UDim2",
		SizeConstraint = "EnumItem",
		TweenPosition = "function",
		TweenSize = "function",
		Visible = "boolean",
		ZIndex = "number",
		destroy = "function",
		Rotation = "number"
	},
	CanvasGroup = {
		GroupTransparency = "number",
		AbsoluteSize = "Vector2",
		AbsolutePosition = "Vector2",
		AutomaticSize = "EnumItem",
		AncestryChanged = "RBXScriptSignal",
		AnchorPoint = "Vector2",
		BackgroundColor3 = "Color3",
		BackgroundTransparency = "number",
		BorderSizePixel = "number",
		ChildAdded = "RBXScriptSignal",
		ChildRemoved = "RBXScriptSignal",
		ClassName = "string",
		ClipsDescendants = "bool",
		FindFirstChild = "function",
		GetChildren = "function",
		GetFullName = "function",
		GetPropertyChangedSignal = "function",
		IsA = "function",
		LayoutOrder = "number",
		Name = "string",
		Parent = "nil",
		Position = "UDim2",
		Size = "UDim2",
		SizeConstraint = "EnumItem",
		TweenPosition = "function",
		TweenSize = "function",
		Visible = "boolean",
		ZIndex = "number",
		destroy = "function",
		Rotation = "number"
	},
	ViewportFrame = {
		AnchorPoint = "Vector2",
		ZIndex = "number",
		Position = "UDim2",
		Size = "UDim2",
		BackgroundTransparency = "number",
		LightColor = "Color3",
		LightDirection = "Vector3",
		Ambient = "Color3",
		CurrentCamera = "Instance"
	},
	ImageButton = {
		Active = "boolean",
		AncestryChanged = "RBXScriptSignal",
		AnchorPoint = "Vector2",
		AbsoluteSize = "Vector2",
		BackgroundColor3 = "Color3",
		AutomaticSize = "EnumItem",
		AutoButtonColor = "boolean",
		BackgroundTransparency = "number",
		BorderSizePixel = "number",
		FindFirstChild = "function",
		HoverImage = "string",
		Image = "string",
		ImageColor3 = "Color3",
		ImageTransparency = "number",
		IsA = "function",
		LayoutOrder = "number",
		MouseButton1Click = "RBXScriptSignal",
		MouseButton1Down = "RBXScriptSignal",
		MouseEnter = "RBXScriptSignal",
		MouseLeave = "RBXScriptSignal",
		Name = "string",
		Position = "UDim2",
		Size = "UDim2",
		SizeConstraint = "EnumItem",
		TweenSize = "function",
		ZIndex = "number",
		Visible = "boolean",
		destroy = "function",
		ScaleType = "Enum",
		TileSize = "UDim2",
		ImageRectSize = "Vector2",
		ImageRectOffset = "Vector2",
		ClipsDescendants = "bool"
	},
	TextButton = {
		Active = "boolean",
		AncestryChanged = "RBXScriptSignal",
		AnchorPoint = "Vector2",
		BackgroundColor3 = "Color3",
		AutomaticSize = "EnumItem",
		BackgroundTransparency = "number",
		BorderSizePixel = "number",
		Bold = "bool",
		FindFirstChild = "function",
		IsA = "function",
		LayoutOrder = "number",
		MouseButton1Click = "RBXScriptSignal",
		MouseButton1Down = "RBXScriptSignal",
		MouseEnter = "RBXScriptSignal",
		MouseLeave = "RBXScriptSignal",
		Name = "string",
		Position = "UDim2",
		Size = "UDim2",
		SizeConstraint = "EnumItem",
		TweenSize = "function",
		ZIndex = "number",
		Visible = "boolean",
		destroy = "function",
		ClipsDescendants = "bool",
		Text = "number",
		TextColor3 = "Color3",
		TextScaled = "boolean",
		TextSize = "number",
		TextStrokeColor3 = "Color3",
		TextStrokeTransparency = "number",
		TextTransparency = "number",
		TextWrapped = "boolean",
		TextXAlignment = "EnumItem",
		TextYAlignment = "EnumItem",
		FontFace = "Font",
		Font = "Enum",
		LineHeight = "number"
	},
	ImageLabel = {
		ImageContent = "Content",
		Active = "boolean",
		AbsoluteSize = "Vector2",
		AncestryChanged = "RBXScriptSignal",
		AnchorPoint = "Vector2",
		BackgroundColor3 = "Color3",
		BackgroundTransparency = "number",
		BorderSizePixel = "number",
		ClassName = "string",
		ImageRectSize = "Vector2",
		ImageRectOffset = "Vector2",
		Image = "string",
		ImageColor3 = "Color3",
		ImageTransparency = "number",
		IsA = "function",
		LayoutOrder = "number",
		MouseEnter = "RBXScriptSignal",
		MouseLeave = "RBXScriptSignal",
		Name = "string",
		Position = "UDim2",
		SliceCenter = "Rect",
		Size = "UDim2",
		SizeConstraint = "EnumItem",
		TweenSize = "function",
		Visible = "boolean",
		ZIndex = "number",
		Rotation = "number",
		destroy = "function",
		ScaleType = "Enum",
		TileSize = "UDim2",
		ClipsDescendants = "bool"
	},
	ManualWeld = {
		C0 = "CFrame",
		C1 = "CFrame",
		Name = "string",
		Part0 = "Instance",
		Part1 = "Instance",
		AncestryChanged = "RBXScriptSignal"
	},
	MeshPart = {
		AncestryChanged = "RBXScriptSignal",
		Anchored = "boolean",
		BrickColor = "BrickColor",
		CFrame = "CFrame",
		CanCollide = "boolean",
		CastShadow = "boolean",
		Color = "Color3",
		Material = "EnumItem",
		Name = "string",
		Parent = "Instance",
		Size = "Vector3",
		Touched = "RBXScriptSignal",
		Transparency = "number",
		Massless = true
	},
	Model = {
		Name = "string",
		AncestryChanged = "RBXScriptSignal",
		GetDescendants = "function",
		PrimaryPart = "Instance",
		SetPrimaryPartCFrame = "function"
	},
	WorldModel = {},
	Part = {
		AncestryChanged = "RBXScriptSignal",
		Anchored = "boolean",
		BottomSurface = "EnumItem",
		BrickColor = "BrickColor",
		CFrame = "CFrame",
		CanCollide = "boolean",
		CastShadow = "boolean",
		Color = "Color3",
		GetTouchingParts = "function",
		Massless = "boolean",
		Material = "EnumItem",
		Name = "string",
		Parent = "Instance",
		RotVelocity = "Vector3",
		Shape = "number",
		Size = "Vector3",
		TopSurface = "EnumItem",
		Touched = "RBXScriptSignal",
		Transparency = "number",
		Velocity = "Vector3"
	},
	ParticleEmitter = {
		AncestryChanged = "RBXScriptSignal",
		Color = "ColorSequence",
		EmissionDirection = "EnumItem",
		Enabled = "boolean",
		GetChildren = "function",
		Lifetime = "NumberRange",
		LightEmission = "number",
		LockedToPart = "boolean",
		Name = "string",
		Rate = "number",
		Size = "NumberSequence",
		Speed = "NumberRange",
		SpreadAngle = "Vector2",
		Texture = "string",
		Transparency = "NumberSequence",
		ZOffset = "number"
	},
	ScreenGui = {
		AbsoluteSize = "Vector2",
		AncestryChanged = "RBXScriptSignal",
		DisplayOrder = "number",
		Enabled = "boolean",
		GetPropertyChangedSignal = "function",
		IgnoreGuiInset = "boolean",
		ScreenInsets = "Enum",
		Name = "string",
		ResetOnSpawn = "boolean",
		ZIndexBehavior = "EnumItem",
		CanvasSize = "Vector2"
	},
	ScrollingFrame = {
		AbsoluteSize = "Vector2",
		AbsolutePosition = "Vector2",
		AbsoluteWindowSize = "Vector2",
		AbsoluteCanvasSize = "Vector2",
		AncestryChanged = "RBXScriptSignal",
		AnchorPoint = "Vector2",
		AutomaticCanvasSize = "Enum",
		AutomaticSize = "Enum",
		ClipsDescendants = "bool",
		BackgroundTransparency = "number",
		BackgroundColor3 = "Color3",
		CanvasPosition = "Vector2",
		CanvasSize = "UDim2",
		GetPropertyChangedSignal = "function",
		IsA = "function",
		LayoutOrder = "number",
		Name = "string",
		Position = "UDim2",
		ScrollBarImageColor3 = "Color3",
		ScrollBarImageTransparency = "number",
		ScrollBarThickness = "number",
		["VerticalScrollBarInset "] = "bool",
		["HorizontalScrollBarInset "] = "bool",
		BorderSizePixel = "number",
		Size = "UDim2",
		ZIndex = "number",
		destroy = "function",
		Visible = "bool",
		VerticalScrollBarPosition = "Enum"
	},
	Sound = {
		Name = "string",
		Play = "function",
		PlaybackSpeed = "number",
		SoundId = "string",
		TimePosition = "number",
		Volume = "number",
		AncestryChanged = "RBXScriptSignal"
	},
	SurfaceGui = {
		Name = "string",
		AncestryChanged = "RBXScriptSignal",
		Face = "Enum",
		SizingMode = "Enum",
		PixelsPerStud = "number",
		LightInfluence = "number",
		AlwaysOnTop = "bool",
		CanvasSize = "Vector2"
	},
	TextLabel = {
		AbsoluteSize = "Vector2",
		AutomaticSize = "EnumItem",
		Active = "boolean",
		AncestryChanged = "RBXScriptSignal",
		AnchorPoint = "Vector2",
		BackgroundTransparency = "number",
		BackgroundColor3 = "Color3",
		Font = "EnumItem",
		GetPropertyChangedSignal = "function",
		IsA = "function",
		LayoutOrder = "number",
		Name = "string",
		Position = "UDim2",
		RichText = "boolean",
		Size = "UDim2",
		Rotation = "number",
		Text = "number",
		TextColor3 = "Color3",
		TextScaled = "boolean",
		TextSize = "number",
		TextStrokeColor3 = "Color3",
		TextStrokeTransparency = "number",
		TextTransparency = "number",
		TextWrapped = "boolean",
		TextXAlignment = "EnumItem",
		TextYAlignment = "EnumItem",
		SizeConstraint = "EnumItem",
		Visible = "boolean",
		FontFace = "Font",
		LineHeight = "number",
		ZIndex = "number",
		ClipsDescendants = "bool",
		PlaceholderColor3 = "Color3",
		TextBounds = ""
	},
	DepthOfFieldEffect = {},
	TextBox = {
		AbsoluteSize = "Vector2",
		Active = "boolean",
		AncestryChanged = "RBXScriptSignal",
		FocusLost = "RBXScriptSignal",
		AnchorPoint = "Vector2",
		BackgroundColor3 = "Color3",
		BackgroundTransparency = "number",
		Font = "EnumItem",
		GetPropertyChangedSignal = "function",
		IsA = "function",
		LayoutOrder = "number",
		Name = "string",
		Position = "UDim2",
		RichText = "boolean",
		ClearTextOnFocus = "boolean",
		Size = "UDim2",
		Text = "number",
		PlaceholderText = "string",
		TextColor3 = "Color3",
		TextScaled = "boolean",
		TextSize = "number",
		TextStrokeColor3 = "Color3",
		TextStrokeTransparency = "number",
		TextTransparency = "number",
		TextWrapped = "boolean",
		TextXAlignment = "EnumItem",
		TextYAlignment = "EnumItem",
		FontFace = "Font",
		LineHeight = "number",
		Visible = "boolean",
		ZIndex = "number",
		ClipsDescendants = "bool",
		PlaceholderColor3 = "Color3"
	},
	UIAspectRatioConstraint = {
		AspectRatio = "number",
		IsA = "function",
		Name = "string",
		AncestryChanged = "RBXScriptSignal"
	},
	UIGridLayout = {
		CellPadding = "UDim2",
		CellSize = "UDim2",
		Name = "string",
		SortOrder = "EnumItem",
		AncestryChanged = "RBXScriptSignal",
		VerticalAlignment = "EnumItem",
		HorizontalAlignment = "EnumItem",
		FillDirectionMaxCells = "number"
	},
	UIPadding = {
		PaddingBottom = "UDim",
		PaddingLeft = "UDim",
		PaddingRight = "UDim",
		PaddingTop = "UDim"
	},
	UIListLayout = {
		FillDirection = "EnumItem",
		HorizontalAlignment = "EnumItem",
		IsA = "function",
		Name = "string",
		Padding = "UDim",
		SortOrder = "EnumItem",
		HorizontalFlex = "Enum",
		ItemLineAlignment = "Enum",
		VerticalAlignment = "EnumItem",
		VerticalFlex = "EnumItem",
		AncestryChanged = "RBXScriptSignal",
		Wraps = "boolean"
	},
	UISizeConstraint = {
		IsA = "function",
		MaxSize = "Vector2",
		MinSize = "Vector2",
		Name = "string",
		AncestryChanged = "RBXScriptSignal"
	},
	UIStroke = {
		Color = "Color3",
		Thickness = "number",
		Transparency = "number",
		LineJoinMode = "Enum",
		ApplyStrokeMode = "Enum",
		IsA = "function",
		MaxSize = "Vector2",
		MinSize = "Vector2",
		Name = "string",
		AncestryChanged = "RBXScriptSignal",
		BorderStrokePosition = "Enum",
		ZIndex = "number",
		StrokeSizingMode = "Enum"
	},
	Beam = {
		CurveSize0 = "number",
		CurveSize1 = "number",
		Transparency = "number",
		Attachment0 = "Instance",
		Attachment1 = "Instance",
		AncestryChanged = "RBXScriptSignal"
	},
	UnionOperation = {
		AncestryChanged = "RBXScriptSignal",
		Anchored = "boolean",
		BottomSurface = "EnumItem",
		BrickColor = "BrickColor",
		CFrame = "CFrame",
		CanCollide = "boolean",
		CastShadow = "boolean",
		Color = "Color3",
		GetTouchingParts = "function",
		Massless = "boolean",
		Material = "EnumItem",
		Name = "string",
		Parent = "Instance",
		RotVelocity = "Vector3",
		Shape = "number",
		Size = "Vector3",
		TopSurface = "EnumItem",
		Touched = "RBXScriptSignal",
		Transparency = "number",
		Velocity = "Vector3"
	},
	WeldConstraint = {
		AncestryChanged = "RBXScriptSignal",
		Part0 = "Instance",
		Part1 = "Instance"
	}
}
local v2 = {}

for _, v3 in pairs(v) do
	v3.GetPropertyChangedSignal = "function"
	v3.IsA = "function"
	v3.FindFirstChild = "function"
	v3.GetChildren = "function"
end

local Romodel = {}

local function newindex(data, p, items, p2)
	if p == "_Events" then
		for k, item in pairs(items) do
			if data._EventCache[item] then
				continue
			end

			data._EventCache[item] = true
			data._Callbacks[k] = data._Callbacks[k] or {}
			table.insert(data._Callbacks[k], item)
			local v3 = item
			data.Instance[k]:connect(function(...)
				v3(data, ...)
			end)
		end
	else
		local instance = data.Instance

		if not p2 then
			data._Properties[p] = items
			return
		end

		if p2 ~= "RBXScriptSignal" then
			instance[p] = items
			return
		end

		data._Callbacks[p] = data._Callbacks[p] or {}
		table.insert(data._Callbacks[p], items)
		instance[p]:connect(function(...)
			items(data, ...)
		end)
	end
end

local class2 = {}
class2 = {
	__index = function(data, p)
		local instance = data.Instance
		local v3 = v[instance.ClassName][p]

		if not v3 then
			return data._Properties[p] or data._Children[p] or rawget(data, "_Model") and data._Model[p] or class2[p]
		end

		local v4 = instance[p]

		if v3 == "function" then
			return function(_, ...)
				return v4(instance, ...)
			end
		end

		if v3 ~= "Instance" then
			return v4
		end

		local _ = data._Children[p] or v4
	end,
	__newindex = function(p, p2, p3)
		return newindex(p, p2, p3, v[p.Instance.ClassName][p2])
	end,
	isSubModel = function(p, p2)
		return p._OriginalModel == p2
	end,
	discard = function(self)
		self:destroy()
	end,
	Destroy = function(self)
		self.Instance:Destroy()
	end,
	ClearAllChildren = function(p, className)
		for _, v3 in pairs(p._Children) do
			if v3.IsA and v3:IsA(className) then
				v3:Destroy()
			end
		end
	end,
	Fire = function(p, p2, ...)
		for _, callback in pairs(p._Callbacks[p2] or {}) do
			task.spawn(callback, p, ...)
		end
	end,
	destroy = function(self)
		self.Instance:Destroy()
	end
}

function class2.new(instance, model)
	return (setmetatable({
		Instance = instance,
		_Model = model,
		_Properties = {},
		_Children = {},
		_EventCache = {},
		_Callbacks = {}
	}, class2))
end

local class3 = {}

function class3.new(...)
	return (setmetatable({
		params = { ... }
	}, class3))
end

local class4 = {}

function class4:__index(p2)
	for _, _SuperModel in pairs(self._SuperModels) do
		local v3 = _SuperModel[p2]

		if v3 then
			return v3
		end
	end

	local v3 = class4[p2]

	if v3 then
		return v3
	end
end

function class4.fragment(_) end

function class4.new(p)
	return table.clone(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isInstanceOf(p, p2)
	return type(p) == "table" and getmetatable(p) == p2
end

local function applyPropertySpecifier(p, items)
	debug.profilebegin("romodel")
	items.Instance = nil
	items.ClassName = nil
	local v3 = v[p.Instance.ClassName]

	for k, item in pairs(items) do
		newindex(p, k, item, v3[k])
	end

	debug.profileend()
end

local function applyChild(p, name, item)
	local v3 = class3
	local v4

	if type(item) == "table" then
		v4 = getmetatable(item) == v3
	else
		v4 = false
	end

	if v4 then
		local child = p.Instance:FindFirstChild(name)
		local v5, v6, v7 = unpack(item.params)

		if type(v5) == "string" then
			v5 = child
		else
			v6 = v6 or {}
			v6.Instance = child
		end

		item = Romodel.make(v5, v6, v7)
	end

	local v5 = class2
	local v6

	if type(item) == "table" then
		v6 = getmetatable(item) == v5
	else
		v6 = false
	end

	assert(v6, "Provided invalid handle " .. name .. " in child specifier")
	item.Name = name
	item.Instance.Parent = p.Instance
	rawset(item, "Parent", p)
	p._Children[tostring(name)] = item
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyChildSpecifier(p, items)
	for k, item in pairs(items) do
		applyChild(p, k, item)
	end
end

local collectSpecifiers

collectSpecifiers = function(list, p, data, p2, p3, p4, p5, ...)
	if not p2 then
		return list
	end

	data.PreProperties[p2] = p4
	data.PreChildren[p2] = p5
	local v3 = rawget(p2, p3)
	local propertySpecifier, childSpecifier

	if v3 then
		if ... then
			propertySpecifier, childSpecifier = v3(unpack({ ... }), p4, p5, p2)
		else
			propertySpecifier, childSpecifier = v3(p4, p5, mpodel)
		end

		list[#list + 1] = {
			PropertySpecifier = propertySpecifier,
			ChildSpecifier = childSpecifier
		}
		data.Properties[p2] = propertySpecifier
		data.Children[p2] = childSpecifier
	end

	for _, _SuperModel in pairs(p2._SuperModels) do
		collectSpecifiers(list, p, data, _SuperModel, p3, propertySpecifier or {}, childSpecifier or {}, ...)
	end

	return list
end

local function applySpecifiers(p, p2, p3, p4, ...)
	if rawget(p, p2) then
		return
	end

	local v3 = class.new()
	rawset(p, p2, v3)
	local v4 = collectSpecifiers({}, p, v3, rawget(p, "_Model"), p2, p3, p4, ...)
	local v5 = {}

	for i = #v4, 1, -1 do
		local v6 = v4[i]

		if v6.PropertySpecifier then
			for k, v7 in pairs(v6.PropertySpecifier) do
				v5[k] = v7
			end
		end

		if not v6.ChildSpecifier then
			continue
		end

		applyChildSpecifier(p, v6.ChildSpecifier) -- equivalent call inferred; original call site unknown
	end

	if v5.DebugPropertySpecifiers then
		print(p2, v5)
	end

	applyPropertySpecifier(p, v5)
end

local runSpecifierMethod

runSpecifierMethod = function(data, p)
	local lastTime = os.clock()
	applySpecifiers(data, p, nil, nil, data)

	for _, v3 in pairs(data._Children) do
		runSpecifierMethod(v3, p, v3)
	end

	if data.ShowSpecifierTime then
		print(data.Name, p, os.clock() - lastTime)
	end
end

function Romodel.isHandle(p)
	return isInstanceOf(p, class2)
end

function Romodel.getHandle(p)
	return v2[p]
end

function Romodel.registerHandle(instance)
	local instance2 = instance.Instance

	if not instance2.Parent then
		warn("attempted to register unparented handle")
		return
	end

	v2[instance2] = instance
	local ancestryChangedConnection = nil
	ancestryChangedConnection = instance2.AncestryChanged:Connect(function(_, _)
		if instance2:IsDescendantOf(game) then
			return
		end

		ancestryChangedConnection:Disconnect()
		local parent = instance.Parent

		if type(parent) == "table" and parent._Children[instance.Name] == instance then
			parent._Children[instance.Name] = nil
			rawset(instance, "Parent", nil)
		end

		v2[instance2] = nil
	end)
end

function Romodel.model(primarySuper, ...)
	local self = setmetatable({
		_SuperModels = {}
	}, class4)
	local v3 = 0

	if type(primarySuper) == "string" then
		self._PrimarySuper = primarySuper
	else
		local v4 = class4
		local v5

		if type(primarySuper) == "table" then
			v5 = getmetatable(primarySuper) == v4
		else
			v5 = false
		end

		if v5 then
			self._SuperModels[1] = class4.new(primarySuper)
			v3 = 1
		else
			error("Attempted to set Primary Super Model to invalid model")
		end
	end

	for k, v4 in pairs({ ... }) do
		self._SuperModels[v3 + k] = class4.new(v4)
	end

	return self
end

function Romodel.wrap(...)
	local model = Romodel.model(...)

	function model.init(p, p2)
		return p, p2
	end

	function model.prespawn(_, p, p2)
		return p, p2
	end

	function model.spawn(_, p, p2)
		return p, p2
	end

	function model.despawn(_, p, p2)
		return p, p2
	end

	return model
end

function Romodel:make(options, options2)
	local v3 = nil
	local v4 = options or {}
	local v5 = options2 or {}

	if type(self) == "string" then
		v3 = class2.new(Instance.new(self))
	elseif type(self) == "userdata" then
		v3 = class2.new(self)
	else
		local v6 = class4
		local v7

		if type(self) == "table" then
			v7 = getmetatable(self) == v6
		else
			v7 = false
		end

		if v7 then
			local instance = v4.Instance or Instance.new(v4.ClassName or self._PrimarySuper)
			v3 = class2.new(instance, class4.new(self))
			v3._OriginalModel = self
			applySpecifiers(v3, "init", v4, v5)
		else
			error("Attempted to make handle given invalid instance specifier")
		end
	end

	applyPropertySpecifier(v3, v4)
	applyChildSpecifier(v3, v5) -- equivalent call inferred; original call site unknown
	return v3
end

function Romodel.instance(...)
	return class3.new(...)
end

function Romodel.mount(instance, parent, p)
	local v3 = class2
	local v4

	if type(instance) == "table" then
		v4 = getmetatable(instance) == v3
	else
		v4 = false
	end

	if v4 then
		if typeof(parent) ~= "Instance" then
			error("Attempted to mount handle to invalid parent")
		end
	else
		error("Attempted to mount invalid handle")
	end

	runSpecifierMethod(instance, "prespawn")

	if p then
		p._Children[instance.Name] = instance
		rawset(instance, "Parent", p)
	end

	local ancestryChangedConnection = nil

	if instance.AncestryChanged then
		ancestryChangedConnection = instance.Instance.AncestryChanged:Connect(function()
			if instance.Instance:IsDescendantOf(game) then
				return
			end

			ancestryChangedConnection:disconnect()

			if p then
				if p._Children[instance.Name] == instance then
					p._Children[instance.Name] = nil
				end

				rawset(instance, "Parent", nil)
			end

			runSpecifierMethod(instance, "despawn")
		end)
	end

	instance.Instance.Parent = parent
	runSpecifierMethod(instance, "spawn")
	rawset(instance, "_Mounted", true)
	return instance
end

function Romodel.apply(p, p2, items)
	if p2 then
		applyPropertySpecifier(p, p2)
	end

	if items then
		for k, item in pairs(items) do
			applyChild(p, k, item)
			Romodel.mount(item, p.Instance, p)
		end
	end

	return p
end

function Romodel.merge(...)
	local result = {}

	for _, v3 in pairs({ ... }) do
		for k, v4 in pairs(v3) do
			result[k] = v4
		end
	end

	return result
end

return Romodel