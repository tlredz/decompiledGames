local CollectionService = game:GetService("CollectionService")
local plugin = script:FindFirstAncestorOfClass("Plugin")
local Options = require(script.Parent.Options)
local Defaults = {
	Font = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
	Size = 14,
	ScaleSize = nil,
	MinimumSize = nil,
	MaximumSize = nil,
	Color = Color3.fromRGB(0, 0, 0),
	Transparency = 0,
	Pixelated = false,
	Offset = Vector2.zero,
	Rotation = 0,
	StrokeSize = 5,
	StrokeColor = Color3.fromRGB(0, 0, 0),
	StrokeScaled = false,
	ShadowOffset = Vector2.new(0, 20),
	ShadowColor = Color3.fromRGB(50, 50, 50),
	LineHeight = 1,
	CharacterSpacing = 1,
	Truncate = false,
	XAlignment = "Left",
	YAlignment = "Top",
	WordSorting = false,
	LineSorting = false,
	Dynamic = false
}
local module = nil

if plugin then
	for _, descendant in plugin:GetDescendants() do
		if not descendant:HasTag("TextDefaults") then
			continue
		end

		module = require(descendant)
		break
	end
else
	module = CollectionService:GetTagged("TextDefaults")[1]

	if module then
		module = require(module)
	end
end

if module and type(module) == "table" then
	for k in module do
		if Options[k] then
			Defaults[k] = module[k]
		end
	end
end

for k, v in Defaults do
	if v == false then
		Defaults[k] = nil
	end
end

return Defaults