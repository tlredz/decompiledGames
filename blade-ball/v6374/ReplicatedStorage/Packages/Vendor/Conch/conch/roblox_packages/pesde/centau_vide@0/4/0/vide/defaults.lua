local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local enum = game and Enum or require3("../test/mock").Enum
local color3 = game and Color3 or require3("../test/mock").Color3
return {
	Part = {
		Material = enum.Material.SmoothPlastic,
		Size = vector.create(1, 1, 1),
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