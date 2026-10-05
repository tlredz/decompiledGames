local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local CollectionService = game:GetService("CollectionService")
local ContentProvider = game:GetService("ContentProvider")
local Utils = require(ReplicatedStorage.Common.Utils)
return {
	Binder = function(instance)
		local maid = Utils.Maid.new()
		local getTextBoundsParams = Instance.new("GetTextBoundsParams")
		getTextBoundsParams.Archivable = false
		local clone = instance:Clone()

		for _, tag in pairs(CollectionService:GetTags(clone)) do
			clone:RemoveTag(tag)
		end

		clone.Name = "__" .. instance.Name .. "_TCR"
		clone.Archivable = false
		clone.Parent = instance.Parent
		local visible = instance.Visible
		instance.Visible = false
		maid:GiveTask(function()
			clone:Destroy()
			instance.Visible = visible
		end)

		local function updateSize()
			local contentText = instance.ContentText
			local maxVisibleGraphemes = instance.MaxVisibleGraphemes

			if maxVisibleGraphemes >= 0 then
				contentText = contentText:sub(0, maxVisibleGraphemes + 10)
			end

			getTextBoundsParams.Text = contentText
			local success, result = pcall(function()
				return TextService:GetTextBoundsAsync(getTextBoundsParams)
			end)

			if not success then
				warn("ERROR", result)
				return
			end

			clone.MaxVisibleGraphemes = maxVisibleGraphemes
			clone.Size = UDim2.new(0, math.ceil(result.X), 0, result.Y)
		end

		getTextBoundsParams.Size = instance.TextSize
		getTextBoundsParams.Width = clone.AbsoluteSize.X
		maid.MaxVisibleGraphemesChanged = instance:GetPropertyChangedSignal("MaxVisibleGraphemes"):Connect(function()
			updateSize()
		end)
		maid.TextChanged = instance:GetPropertyChangedSignal("Text"):Connect(function()
			clone.Text = instance.Text
			updateSize()
		end)
		maid.TextSizeChanged = instance:GetPropertyChangedSignal("TextSize"):Connect(function()
			local textSize = instance.TextSize
			clone.TextSize = textSize
			getTextBoundsParams.Size = textSize
			updateSize()
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateFont()
			getTextBoundsParams.Font = instance.FontFace
			ContentProvider:PreloadAsync({ instance })
			clone.FontFace = instance.FontFace
			updateSize()
		end

		updateFont() -- equivalent call inferred; original call site unknown
		maid.FontChanged = instance:GetPropertyChangedSignal("FontFace"):Connect(updateFont)
		maid.AbsoluteSizeChanged = instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			getTextBoundsParams.Width = instance.AbsoluteSize.X
			updateSize()
		end)
		maid.CopyAbsoluteSizeChanged = clone:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			getTextBoundsParams.Width = instance.AbsoluteSize.X
			updateSize()
		end)
		return maid
	end
}