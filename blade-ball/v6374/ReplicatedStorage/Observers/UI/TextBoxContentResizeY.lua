local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local TextService = game:GetService("TextService")
local Trove = require(ReplicatedStorage.Packages.Trove)
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Common.Utils)
return Observers.observeTagNoAncestry("UI_TextBoxContentResizeY", function(instance)
	local maid = Trove.new()
	local getTextBoundsParams = Instance.new("GetTextBoundsParams")
	getTextBoundsParams.Archivable = false
	getTextBoundsParams.Size = instance.TextSize
	getTextBoundsParams.Font = instance.FontFace
	getTextBoundsParams.Width = instance.AbsoluteSize.X
	local scrollingFrame = instance:FindFirstAncestorWhichIsA("ScrollingFrame")

	local function updateSize()
		local contentText = instance.ContentText

		if contentText == "" then
			contentText = instance.PlaceholderText
		end

		getTextBoundsParams.Text = contentText
		local X = instance.AbsoluteSize.X

		if scrollingFrame and scrollingFrame.AbsoluteCanvasSize.Y > scrollingFrame.AbsoluteSize.Y then
			X -= scrollingFrame.ScrollBarThickness
		end

		getTextBoundsParams.Width = X
		local success, result = pcall(function()
			return TextService:GetTextBoundsAsync(getTextBoundsParams)
		end)

		if success then
			local Y = result.Y

			if instance:GetAttribute("MaxSize") and scrollingFrame then
				Y = math.max(Y, scrollingFrame.AbsoluteSize.Y)
			end

			instance.Size = UDim2.new(1, 0, 0, Y)
		end

		if scrollingFrame and instance.CursorPosition > 0 then
			scrollingFrame.CanvasPosition = Vector2.new(0, scrollingFrame.AbsoluteCanvasSize.Y)
		end
	end

	maid:Add(instance:GetPropertyChangedSignal("Text"):Connect(updateSize))
	maid:Add(instance:GetPropertyChangedSignal("PlaceholderText"):Connect(updateSize))
	maid:Add(instance.AncestryChanged:Connect(function()
		scrollingFrame = instance:FindFirstAncestorWhichIsA("ScrollingFrame")
		updateSize()
	end))
	maid:Add(instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		updateSize()
	end))
	maid:Add(instance:GetPropertyChangedSignal("TextSize"):Connect(function()
		getTextBoundsParams.Size = instance.TextSize
		updateSize()
	end))

	local function updateFont()
		getTextBoundsParams.Font = instance.FontFace
		ContentProvider:PreloadAsync({ instance })
		updateSize()
	end

	maid:Add(instance:GetPropertyChangedSignal("FontFace"):Connect(updateFont))
	maid:Add(task.defer(updateSize))
	return function()
		maid:Destroy()
	end
end)