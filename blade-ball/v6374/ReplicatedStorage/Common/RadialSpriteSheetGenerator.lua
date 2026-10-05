local HttpService = game:GetService("HttpService")
local ContentProvider = game:GetService("ContentProvider")
local RadialSpriteSheetGenerator = {
	_version = 1
}
RadialSpriteSheetGenerator.__index = RadialSpriteSheetGenerator
local v = {
	version = "number",
	size = "number",
	count = "number",
	columns = "number",
	rows = "number",
	images = "table"
}

function RadialSpriteSheetGenerator.new(config, label)
	if type(config) == "string" then
		config = HttpService:JSONDecode(config)
	elseif type(config) ~= "table" then
		error("Argument #1 (configuration) must be a JSON string or table.", 2)
	end

	for k, item in pairs(config) do
		if v[k] == nil then
			error(("Invalid property name in Radial Image configuration: %s"):format(k), 2)
		end

		if type(item) ~= v[k] then
			error(("Invalid property type %q in Radial Image configuration: must be a %s."):format(k, v[k]), 2)
		end
	end

	if config.version ~= RadialSpriteSheetGenerator._version then
		error(
			("Passed configuration version does not match this module's version (which is %d)"):format(RadialSpriteSheetGenerator._version),
			2
		)
	end

	local v2 = {
		config = config,
		label = label
	}
	setmetatable(v2, RadialSpriteSheetGenerator)
	return v2
end

function RadialSpriteSheetGenerator:Preload()
	if self.label == nil then
		error("You must provide a label to RadialImage.new to use Preload", 2)
	end

	self.labels = {}

	for _, image in ipairs(self.config.images) do
		local clone = self.label:Clone()
		clone.Image = image
		clone.Visible = true
		clone.Size = UDim2.new(0, 0, 0, 0)
		clone.Parent = self.label.Parent
		table.insert(self.labels, clone)
	end

	ContentProvider:PreloadAsync(self.labels)

	for _, label in ipairs(self.labels) do
		label.Visible = false
	end
end

function RadialSpriteSheetGenerator:Destroy()
	for _, label in ipairs(self.labels) do
		label:Destroy()
	end

	self.labels = nil
end

function RadialSpriteSheetGenerator:GetFromAlpha(value)
	if type(value) ~= "number" then
		error("Argument #1 (alpha) to GetFromAlpha must be a number.", 2)
	end

	local count = self.config.count
	local size = self.config.size
	local columns = self.config.columns
	local rows = self.config.rows
	local v2 = value >= 1 and count - 1 or math.floor(value * count)
	local v3 = math.floor(v2 / (columns * rows)) + 1
	local v4 = v2 - columns * rows * (v3 - 1)
	return v4 % columns * size, math.floor(v4 / columns) * size, v3
end

function RadialSpriteSheetGenerator:UpdateLabel(value, p)
	local guiObject = p or self.label

	if type(value) ~= "number" then
		error("Argument #1 (alpha) to UpdateLabel must be a number.", 2)
	end

	if typeof(guiObject) ~= "Instance" or not (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) then
		error(
			"Attempt to update label but no label has been given. Either pass the label as argument #2 to \"new\", or as argument #2 to \"UpdateLabel\".",
			2
		)
	end

	local fromAlpha, v2, v3 = self:GetFromAlpha(value)
	guiObject.ImageRectSize = Vector2.new(self.config.size, self.config.size)
	guiObject.ImageRectOffset = Vector2.new(fromAlpha, v2)
	guiObject.Image = value <= 0 and "" or self.config.images[v3]
end

return RadialSpriteSheetGenerator