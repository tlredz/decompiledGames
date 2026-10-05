local enum = game and Enum

if not enum then
	local module = require("test/mock")
	enum = module.Enum
end

local color3 = game and Color3

if not color3 then
	local module = require("test/mock")
	color3 = module.Color3
end

local vector3 = game and Vector3

if not vector3 then
	local module = require("test/mock")
	vector3 = module.Vector3
end

return {
	Part = {
		Material = enum.Material.SmoothPlastic,
		Size = vector3.new(1, 1, 1),
		Anchored = true
	},
	BillboardGui = {
		ResetOnSpawn = false,
		ZIndexBehavior = enum.ZIndexBehavior.Sibling
	},
	CanvasGroup = nil,
	Frame = {
		BackgroundColor3 = color3.new(1, 1, 1),
		BorderColor3 = color3.new(0, 0, 0),
		BorderSizePixel = 0
	},
	ImageButton = {
		BackgroundColor3 = color3.new(1, 1, 1),
		BorderColor3 = color3.new(0, 0, 0),
		BorderSizePixel = 0,
		AutoButtonColor = false
	},
	ImageLabel = {
		BackgroundColor3 = color3.new(1, 1, 1),
		BorderColor3 = color3.new(0, 0, 0),
		BorderSizePixel = 0
	},
	ScreenGui = {
		ResetOnSpawn = false,
		ZIndexBehavior = enum.ZIndexBehavior.Sibling
	},
	ScrollingFrame = {
		BackgroundColor3 = color3.new(1, 1, 1),
		BorderColor3 = color3.new(0, 0, 0),
		BorderSizePixel = 0,
		ScrollBarImageColor3 = color3.new(0, 0, 0)
	},
	SurfaceGui = {
		ResetOnSpawn = false,
		ZIndexBehavior = enum.ZIndexBehavior.Sibling,
		PixelsPerStud = 50,
		SizingMode = enum.SurfaceGuiSizingMode.PixelsPerStud
	},
	TextBox = {
		BackgroundColor3 = color3.new(1, 1, 1),
		BorderColor3 = color3.new(0, 0, 0),
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = enum.Font.SourceSans,
		Text = "",
		TextColor3 = color3.new(0, 0, 0)
	},
	TextButton = {
		BackgroundColor3 = color3.new(1, 1, 1),
		BorderColor3 = color3.new(0, 0, 0),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = enum.Font.SourceSans,
		Text = "",
		TextColor3 = color3.new(0, 0, 0)
	},
	TextLabel = {
		BackgroundColor3 = color3.new(1, 1, 1),
		BorderColor3 = color3.new(0, 0, 0),
		BorderSizePixel = 0,
		Font = enum.Font.SourceSans,
		Text = "",
		TextColor3 = color3.new(0, 0, 0)
	},
	UIListLayout = {
		SortOrder = enum.SortOrder.LayoutOrder
	},
	UIGridLayout = {
		SortOrder = enum.SortOrder.LayoutOrder
	},
	UITableLayout = {
		SortOrder = enum.SortOrder.LayoutOrder
	},
	UIPageLayout = {
		SortOrder = enum.SortOrder.LayoutOrder
	},
	VideoFrame = {
		BackgroundColor3 = color3.new(1, 1, 1),
		BorderColor3 = color3.new(0, 0, 0),
		BorderSizePixel = 0
	},
	ViewportFrame = {
		BackgroundColor3 = color3.new(1, 1, 1),
		BorderColor3 = color3.new(0, 0, 0),
		BorderSizePixel = 0
	}
}