local RunService = game:GetService("RunService")
local module = require("../modules/SaneDebris")
local RayVisual = {}
local v = {}

local function makeBillboard(text: string, backgroundColor: Color3, scale: number)
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.AlwaysOnTop = true
	billboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	billboardGui.AutoLocalize = false
	billboardGui.Size = UDim2.fromScale(scale * 0.25, scale * 0.25)
	billboardGui.ResetOnSpawn = false
	local textLabel = Instance.new("TextLabel")
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Position = UDim2.fromScale(0.5, 0.5)
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundColor3 = backgroundColor
	textLabel.Interactable = false
	textLabel.TextScaled = true
	textLabel.AutoLocalize = false
	textLabel.FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold)
	textLabel.Text = text
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(1, 0)
	uICorner.Parent = textLabel
	local uISizeConstraint = Instance.new("UISizeConstraint")
	uISizeConstraint.MaxSize = Vector2.new(24, 24)
	uISizeConstraint.Parent = textLabel
	textLabel.Parent = billboardGui
	return billboardGui
end

local function makeVisual(data)
	local scale = data.config.Scale or 1
	local attachment = Instance.new("Attachment")
	attachment.WorldPosition = data.start
	local attachment2 = Instance.new("Attachment")
	attachment2.Parent = attachment
	attachment2.Position = data.dir
	local beam = Instance.new("Beam")
	beam.Transparency = NumberSequence.new(0)
	beam.Segments = 1
	beam.Attachment0 = attachment
	beam.Width0 = 0.05 * scale
	beam.Width1 = 0.05 * scale
	beam.FaceCamera = true
	beam.Parent = attachment
	local billboard = makeBillboard("S", Color3.fromRGB(89, 217, 75), scale)
	billboard.Parent = attachment
	local billboard_2 = makeBillboard("E", Color3.fromRGB(255, 213, 88), scale)
	billboard_2.Parent = attachment2

	if data.result then
		local attachment3 = Instance.new("Attachment")
		attachment3.Parent = attachment
		attachment3.WorldPosition = data.result.Position
		local billboard_3 = makeBillboard("H", Color3.fromRGB(255, 83, 83), scale)
		billboard_3.Parent = attachment3
		local beam2 = Instance.new("Beam")
		beam2.Transparency = NumberSequence.new(0.75)
		beam2.Segments = 1
		beam2.Attachment0 = attachment3
		beam2.Attachment1 = attachment2
		beam2.Width0 = 0.05 * scale
		beam2.Width1 = 0.05 * scale
		beam2.FaceCamera = true
		beam2.Parent = attachment
		beam.Attachment1 = attachment3
	else
		beam.Attachment1 = attachment2
	end

	attachment.Parent = workspace.Terrain

	if data.config.Lifetime then
		module:AddItem(attachment, data.config.Lifetime)
	end
end

function RayVisual.visualize(vector: Vector3, vector2: Vector3, p, config)
	if not config then
		return
	end

	table.insert(v, {
		start = vector,
		dir = vector2,
		result = p,
		config = config
	})
end

function RayVisual.raycast(vector: Vector3, vector2: Vector3, p, p2)
	local raycastResult = workspace:Raycast(vector, vector2, p)

	if p2 then
		RayVisual.visualize(vector, vector2, raycastResult, p2)
	end

	return raycastResult
end

function RayVisual.blockcast(cframe: CFrame, vector: Vector3, vector2: Vector3, p, p2)
	local blockcast = workspace:Blockcast(cframe, vector, vector2, p)

	if p2 then
		RayVisual.visualize(cframe.Position, vector2, blockcast, p2)
	end

	return blockcast
end

function RayVisual.spherecast(vector: Vector3, p: number, vector2: Vector3, p2, p3)
	local spherecast = workspace:Spherecast(vector, p, vector2, p2)

	if p3 then
		RayVisual.visualize(vector, vector2, spherecast, p3)
	end

	return spherecast
end

function RayVisual.shapecast(p, vector: Vector3, p2, p3)
	local shapecast = workspace:Shapecast(p, vector, p2)

	if p3 then
		RayVisual.visualize(p.Position, vector, shapecast, p3)
	end

	return shapecast
end

RunService.Heartbeat:Connect(function()
	for _, v2 in ipairs(v) do
		makeVisual(v2)
	end

	table.clear(v)
end)
return RayVisual