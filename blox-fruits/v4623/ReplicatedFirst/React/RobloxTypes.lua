local ReplicatedFirst = game:GetService("ReplicatedFirst")
local React = require(ReplicatedFirst:WaitForChild("Packages"):WaitForChild("React"))
local createElement = React.createElement
local RobloxTypes = {
	mergeInstance = function(instance, instance2)
		local archivable

		if instance.Archivable == nil then
			archivable = instance2.Archivable
		else
			archivable = instance.Archivable
		end

		local result = {
			Archivable = archivable,
			Name = instance.Name or instance2.Name,
			children = createElement(React.Fragment, {}, instance.children or {}, instance2.children or {}),
			ref = instance.ref or instance2.ref
		}

		for k, v2 in pairs(instance) do
			if typeof(k) ~= "string" then
				result[k] = v2
			end
		end

		for k, v2 in pairs(instance2) do
			if typeof(k) ~= "string" then
				result[k] = v2
			end
		end

		return result
	end
}
RobloxTypes.mergeGuiBase = RobloxTypes.mergeInstance

function RobloxTypes.mergeGuiObject2D(data, data2)
	local mergeGuiBase = RobloxTypes.mergeGuiBase(data, data2)
	local autoLocalize

	if data.AutoLocalize == nil then
		autoLocalize = data2.AutoLocalize
	else
		autoLocalize = data.AutoLocalize
	end

	mergeGuiBase.AutoLocalize = autoLocalize
	mergeGuiBase.RootLocalizationTable = data.RootLocalizationTable or data2.RootLocalizationTable
	mergeGuiBase.SelectionBehaviorDown = data.SelectionBehaviorDown or data2.SelectionBehaviorDown
	mergeGuiBase.SelectionBehaviorLeft = data.SelectionBehaviorLeft or data2.SelectionBehaviorLeft
	mergeGuiBase.SelectionBehaviorRight = data.SelectionBehaviorRight or data2.SelectionBehaviorRight
	mergeGuiBase.SelectionBehaviorUp = data.SelectionBehaviorUp or data2.SelectionBehaviorUp
	mergeGuiBase.SelectionGroup = data.SelectionGroup or data2.SelectionGroup
	return mergeGuiBase
end

function RobloxTypes.mergeGuiObject(data, data2)
	local mergeGuiObject2D = RobloxTypes.mergeGuiObject2D(data, data2)
	local active

	if data.Active == nil then
		active = data2.Active
	else
		active = data.Active
	end

	mergeGuiObject2D.Active = active
	mergeGuiObject2D.AnchorPoint = data.AnchorPoint or data2.AnchorPoint
	mergeGuiObject2D.AutomaticSize = data.AutomaticSize or data2.AutomaticSize
	mergeGuiObject2D.BackgroundColor3 = data.BackgroundColor3 or data2.BackgroundColor3
	mergeGuiObject2D.BackgroundTransparency = data.BackgroundTransparency or data2.BackgroundTransparency
	mergeGuiObject2D.BorderColor3 = data.BorderColor3 or data2.BorderColor3
	mergeGuiObject2D.BorderMode = data.BorderMode or data2.BorderMode
	mergeGuiObject2D.BorderSizePixel = data.BorderSizePixel or data2.BorderSizePixel
	local clipsDescendants

	if data.ClipsDescendants == nil then
		clipsDescendants = data2.ClipsDescendants
	else
		clipsDescendants = data.ClipsDescendants
	end

	mergeGuiObject2D.ClipsDescendants = clipsDescendants
	local interactable

	if data.Interactable == nil then
		interactable = data2.Interactable
	else
		interactable = data.Interactable
	end

	mergeGuiObject2D.Interactable = interactable
	mergeGuiObject2D.LayoutOrder = data.LayoutOrder or data2.LayoutOrder
	mergeGuiObject2D.NextSelectionDown = data.NextSelectionDown or data2.NextSelectionDown
	mergeGuiObject2D.NextSelectionLeft = data.NextSelectionLeft or data2.NextSelectionLeft
	mergeGuiObject2D.NextSelectionRight = data.NextSelectionRight or data2.NextSelectionRight
	mergeGuiObject2D.NextSelectionUp = data.NextSelectionUp or data2.NextSelectionUp
	mergeGuiObject2D.Position = data.Position or data2.Position
	mergeGuiObject2D.Rotation = data.Rotation or data2.Rotation
	local selectable

	if data.Selectable == nil then
		selectable = data2.Selectable
	else
		selectable = data.Selectable
	end

	mergeGuiObject2D.Selectable = selectable
	mergeGuiObject2D.SelectionImageObject = data.SelectionImageObject or data2.SelectionImageObject
	mergeGuiObject2D.SelectionOrder = data.SelectionOrder or data2.SelectionOrder
	mergeGuiObject2D.Size = data.Size or data2.Size
	mergeGuiObject2D.SizeConstraint = data.SizeConstraint or data2.SizeConstraint
	mergeGuiObject2D.Transparency = data.Transparency or data2.Transparency
	local visible

	if data.Visible == nil then
		visible = data2.Visible
	else
		visible = data.Visible
	end

	mergeGuiObject2D.Visible = visible
	mergeGuiObject2D.ZIndex = data.ZIndex or data2.ZIndex
	return mergeGuiObject2D
end

function RobloxTypes.mergeFrame(p, p2)
	local mergeGuiObject = RobloxTypes.mergeGuiObject(p, p2)
	mergeGuiObject.Style = p.Style or p2.Style
	return mergeGuiObject
end

function RobloxTypes.mergeCanvasGroup(p, p2)
	local mergeGuiObject = RobloxTypes.mergeGuiObject(p, p2)
	mergeGuiObject.GroupColor3 = p.GroupColor3 or p2.GroupColor3
	mergeGuiObject.GroupTransparency = p.GroupTransparency or p2.GroupTransparency
	return mergeGuiObject
end

function RobloxTypes.mergeImageLabel(data, data2)
	local mergeGuiObject = RobloxTypes.mergeGuiObject(data, data2)
	mergeGuiObject.Image = data.Image or data2.Image
	mergeGuiObject.ImageColor3 = data.ImageColor3 or data2.ImageColor3
	mergeGuiObject.ImageRectOffset = data.ImageRectOffset or data2.ImageRectOffset
	mergeGuiObject.ImageRectSize = data.ImageRectSize or data2.ImageRectSize
	mergeGuiObject.ImageTransparency = data.ImageTransparency or data2.ImageTransparency
	mergeGuiObject.ResampleMode = data.ResampleMode or data2.ResampleMode
	mergeGuiObject.ScaleType = data.ScaleType or data2.ScaleType
	mergeGuiObject.SliceCenter = data.SliceCenter or data2.SliceCenter
	mergeGuiObject.SliceScale = data.SliceScale or data2.SliceScale
	mergeGuiObject.TileSize = data.TileSize or data2.TileSize
	return mergeGuiObject
end

function RobloxTypes.mergeGuiButton(data, data2)
	local mergeGuiObject = RobloxTypes.mergeGuiObject(data, data2)
	local autoButtonColor

	if data.AutoButtonColor == nil then
		autoButtonColor = data2.AutoButtonColor
	else
		autoButtonColor = data.AutoButtonColor
	end

	mergeGuiObject.AutoButtonColor = autoButtonColor
	local modal

	if data.Modal == nil then
		modal = data2.Modal
	else
		modal = data.Modal
	end

	mergeGuiObject.Modal = modal
	local selected

	if data.Selected == nil then
		selected = data2.Selected
	else
		selected = data.Selected
	end

	mergeGuiObject.Selected = selected
	mergeGuiObject.Style = data.Style or data2.Style
	return mergeGuiObject
end

function RobloxTypes.mergeImageButton(data, data2)
	local mergeGuiButton = RobloxTypes.mergeGuiButton(data, data2)
	mergeGuiButton.Image = data.Image or data2.Image
	mergeGuiButton.ImageColor3 = data.ImageColor3 or data2.ImageColor3
	mergeGuiButton.ImageRectOffset = data.ImageRectOffset or data2.ImageRectOffset
	mergeGuiButton.ImageRectSize = data.ImageRectSize or data2.ImageRectSize
	mergeGuiButton.ImageTransparency = data.ImageTransparency or data2.ImageTransparency
	mergeGuiButton.ScaleType = data.ScaleType or data2.ScaleType
	mergeGuiButton.SliceCenter = data.SliceCenter or data2.SliceCenter
	mergeGuiButton.SliceScale = data.SliceScale or data2.SliceScale
	mergeGuiButton.TileSize = data.TileSize or data2.TileSize
	return mergeGuiButton
end

function RobloxTypes.mergeScrollingFrame(data, data2)
	local mergeGuiObject = RobloxTypes.mergeGuiObject(data, data2)
	mergeGuiObject.AutomaticCanvasSize = data.AutomaticCanvasSize or data2.AutomaticCanvasSize
	mergeGuiObject.BottomImage = data.BottomImage or data2.BottomImage
	mergeGuiObject.CanvasPosition = data.CanvasPosition or data2.CanvasPosition
	mergeGuiObject.CanvasSize = data.CanvasSize or data2.CanvasSize
	mergeGuiObject.ElasticBehavior = data.ElasticBehavior or data2.ElasticBehavior
	mergeGuiObject.HorizontalScrollBarInset = data.HorizontalScrollBarInset or data2.HorizontalScrollBarInset
	mergeGuiObject.MidImage = data.MidImage or data2.MidImage
	mergeGuiObject.ScrollBarImageColor3 = data.ScrollBarImageColor3 or data2.ScrollBarImageColor3
	mergeGuiObject.ScrollBarImageTransparency = data.ScrollBarImageTransparency or data2.ScrollBarImageTransparency
	mergeGuiObject.ScrollBarThickness = data.ScrollBarThickness or data2.ScrollBarThickness
	mergeGuiObject.ScrollingDirection = data.ScrollingDirection or data2.ScrollingDirection
	mergeGuiObject.ScrollingEnabled = data.ScrollingEnabled or data2.ScrollingEnabled
	mergeGuiObject.TopImage = data.TopImage or data2.TopImage
	mergeGuiObject.VerticalScrollBarInset = data.VerticalScrollBarInset or data2.VerticalScrollBarInset
	mergeGuiObject.VerticalScrollBarPosition = data.VerticalScrollBarPosition or data2.VerticalScrollBarPosition
	return mergeGuiObject
end

RobloxTypes.mergeUIBase = RobloxTypes.mergeInstance
RobloxTypes.mergeUIComponent = RobloxTypes.mergeUIBase

function RobloxTypes.mergeUIGradient(data, data2)
	local mergeUIComponent = RobloxTypes.mergeUIComponent(data, data2)
	mergeUIComponent.Color = data.Color or data2.Color
	mergeUIComponent.Rotation = data.Rotation or data2.Rotation
	mergeUIComponent.Transparency = data.Transparency or data2.Transparency
	mergeUIComponent.Offset = data.Offset or data2.Offset
	mergeUIComponent.Enabled = data.Enabled or data2.Enabled
	return mergeUIComponent
end

RobloxTypes.mergeGuiLabel = RobloxTypes.mergeGuiObject

function RobloxTypes.mergeTextLabel(data, data2)
	local mergeGuiLabel = RobloxTypes.mergeGuiLabel(data, data2)
	mergeGuiLabel.Font = data.Font or data2.Font
	mergeGuiLabel.LineHeight = data.LineHeight or data2.LineHeight
	local richText

	if data.RichText == nil then
		richText = data2.RichText
	else
		richText = data.RichText
	end

	mergeGuiLabel.RichText = richText
	mergeGuiLabel.Text = data.Text or data2.Text
	mergeGuiLabel.TextColor3 = data.TextColor3 or data2.TextColor3
	local textScaled

	if data.TextScaled == nil then
		textScaled = data2.TextScaled
	else
		textScaled = data.TextScaled
	end

	mergeGuiLabel.TextScaled = textScaled
	mergeGuiLabel.TextSize = data.TextSize or data2.TextSize
	mergeGuiLabel.TextStrokeColor3 = data.TextStrokeColor3 or data2.TextStrokeColor3
	mergeGuiLabel.TextStrokeTransparency = data.TextStrokeTransparency or data2.TextStrokeTransparency
	mergeGuiLabel.TextTransparency = data.TextTransparency or data2.TextTransparency
	local textWrapped

	if data.TextWrapped == nil then
		textWrapped = data2.TextWrapped
	else
		textWrapped = data.TextWrapped
	end

	mergeGuiLabel.TextWrapped = textWrapped
	mergeGuiLabel.TextXAlignment = data.TextXAlignment or data2.TextXAlignment
	mergeGuiLabel.TextYAlignment = data.TextYAlignment or data2.TextYAlignment
	mergeGuiLabel.FontFace = data.FontFace or data2.FontFace
	mergeGuiLabel.MaxVisibleGraphemes = data.MaxVisibleGraphemes or data2.MaxVisibleGraphemes
	mergeGuiLabel.OpenTypeFeatures = data.OpenTypeFeatures or data2.OpenTypeFeatures
	mergeGuiLabel.TextDirection = data.TextDirection or data2.TextDirection
	mergeGuiLabel.TextTruncate = data.TextTruncate or data2.TextTruncate
	return mergeGuiLabel
end

function RobloxTypes.mergeTextButton(data, data2)
	local mergeGuiButton = RobloxTypes.mergeGuiButton(data, data2)
	mergeGuiButton.Font = data.Font or data2.Font
	mergeGuiButton.LineHeight = data.LineHeight or data2.LineHeight
	local richText

	if data.RichText == nil then
		richText = data2.RichText
	else
		richText = data.RichText
	end

	mergeGuiButton.RichText = richText
	mergeGuiButton.Text = data.Text or data2.Text
	mergeGuiButton.TextColor3 = data.TextColor3 or data2.TextColor3
	local textScaled

	if data.TextScaled == nil then
		textScaled = data2.TextScaled
	else
		textScaled = data.TextScaled
	end

	mergeGuiButton.TextScaled = textScaled
	mergeGuiButton.TextSize = data.TextSize or data2.TextSize
	mergeGuiButton.TextStrokeColor3 = data.TextStrokeColor3 or data2.TextStrokeColor3
	mergeGuiButton.TextStrokeTransparency = data.TextStrokeTransparency or data2.TextStrokeTransparency
	mergeGuiButton.TextTransparency = data.TextTransparency or data2.TextTransparency
	local textWrapped

	if data.TextWrapped == nil then
		textWrapped = data2.TextWrapped
	else
		textWrapped = data.TextWrapped
	end

	mergeGuiButton.TextWrapped = textWrapped
	mergeGuiButton.TextXAlignment = data.TextXAlignment or data2.TextXAlignment
	mergeGuiButton.TextYAlignment = data.TextYAlignment or data2.TextYAlignment
	mergeGuiButton.FontFace = data.FontFace or data2.FontFace
	mergeGuiButton.MaxVisibleGraphemes = data.MaxVisibleGraphemes or data2.MaxVisibleGraphemes
	mergeGuiButton.OpenTypeFeatures = data.OpenTypeFeatures or data2.OpenTypeFeatures
	mergeGuiButton.TextDirection = data.TextDirection or data2.TextDirection
	mergeGuiButton.TextTruncate = data.TextTruncate or data2.TextTruncate
	return mergeGuiButton
end

function RobloxTypes.mergeTextBox(data, data2)
	local mergeGuiObject = RobloxTypes.mergeGuiObject(data, data2)
	local clearTextOnFocus

	if data.ClearTextOnFocus == nil then
		clearTextOnFocus = data2.ClearTextOnFocus
	else
		clearTextOnFocus = data.ClearTextOnFocus
	end

	mergeGuiObject.ClearTextOnFocus = clearTextOnFocus
	mergeGuiObject.CursorPosition = data.CursorPosition or data2.CursorPosition
	mergeGuiObject.Font = data.Font or data2.Font
	mergeGuiObject.LineHeight = data.LineHeight or data2.LineHeight
	local multiLine

	if data.MultiLine == nil then
		multiLine = data2.MultiLine
	else
		multiLine = data.MultiLine
	end

	mergeGuiObject.MultiLine = multiLine
	mergeGuiObject.PlaceholderColor3 = data.PlaceholderColor3 or data2.PlaceholderColor3
	mergeGuiObject.PlaceholderText = data.PlaceholderText or data2.PlaceholderText
	local richText

	if data.RichText == nil then
		richText = data2.RichText
	else
		richText = data.RichText
	end

	mergeGuiObject.RichText = richText
	mergeGuiObject.SelectionStart = data.SelectionStart or data2.SelectionStart
	local showNativeInput

	if data.ShowNativeInput == nil then
		showNativeInput = data2.ShowNativeInput
	else
		showNativeInput = data.ShowNativeInput
	end

	mergeGuiObject.ShowNativeInput = showNativeInput
	mergeGuiObject.Text = data.Text or data2.Text
	mergeGuiObject.TextColor3 = data.TextColor3 or data2.TextColor3
	mergeGuiObject.TextDirection = data.TextDirection or data2.TextDirection
	local textEditable

	if data.TextEditable == nil then
		textEditable = data2.TextEditable
	else
		textEditable = data.TextEditable
	end

	mergeGuiObject.TextEditable = textEditable
	local textScaled

	if data.TextScaled == nil then
		textScaled = data2.TextScaled
	else
		textScaled = data.TextScaled
	end

	mergeGuiObject.TextScaled = textScaled
	mergeGuiObject.TextSize = data.TextSize or data2.TextSize
	mergeGuiObject.TextStrokeColor3 = data.TextStrokeColor3 or data2.TextStrokeColor3
	mergeGuiObject.TextStrokeTransparency = data.TextStrokeTransparency or data2.TextStrokeTransparency
	mergeGuiObject.TextTransparency = data.TextTransparency or data2.TextTransparency
	local textWrapped

	if data.TextWrapped == nil then
		textWrapped = data2.TextWrapped
	else
		textWrapped = data.TextWrapped
	end

	mergeGuiObject.TextWrapped = textWrapped
	mergeGuiObject.TextXAlignment = data.TextXAlignment or data2.TextXAlignment
	mergeGuiObject.TextYAlignment = data.TextYAlignment or data2.TextYAlignment
	return mergeGuiObject
end

return RobloxTypes