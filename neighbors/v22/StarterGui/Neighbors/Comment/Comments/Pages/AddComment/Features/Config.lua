local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.UI)
local Color = require(ReplicatedStorage.Modules.Color)
local Comment = require(ReplicatedStorage.Assets.Data.Comment)
local Styles = require(ReplicatedStorage.Assets.Data.Comment.Styles)
local module = require("@self/Dropdown")
local addComment = script:FindFirstAncestorOfClass("Frame").AddComment
local input = addComment.Input
local config = addComment.Bottom.Config
local commentStyleHint = addComment.Top.CommentStyleHint
local slot = config.Type.Slot
slot.Parent = nil

for k, style in next, Styles, nil do
	local clone = slot:Clone()
	clone.Name = style.Name
	clone.Text = style.Name
	clone.BackgroundColor3 = style.Color
	clone.TextColor3 = Color:GetShadedColor(style.Color, 0.5)
	clone.LayoutOrder = -k
	clone.Parent = config.Type
end

local negative = module.new(config.Negative)
local style2 = module.new(config.Type)

local function updateStyleConfig()
	local v3 = negative.Value == "Negative"
	local commentStyle = Comment:GetCommentStyle(style2.Value)

	for _, button in next, style2.Buttons, nil do
		button.Text = `{button.Name} ({Comment:GetCommentValueString(button.Name, v3)})`
	end

	if commentStyle and commentStyle.Hint then
		local hint = commentStyle.Hint
		task.spawn(function()
			if typeof(hint) == "function" then
				hint = hint()
			end

			if style2.Value ~= commentStyle.Name then
				return
			end

			commentStyleHint.BackgroundColor3 = commentStyle.Color
			commentStyleHint.UIStroke.Color = Color:GetShadedColor(commentStyle.Color, 0.5)
			commentStyleHint.Label.TextColor3 = Color:GetShadedColor(commentStyle.Color, 0.5)
			commentStyleHint.Label.Text = hint
			commentStyleHint.Visible = true
		end)
	else
		commentStyleHint.Visible = false
	end
end

updateStyleConfig()
style2.ValueChanged:Connect(updateStyleConfig)
negative.ValueChanged:Connect(updateStyleConfig)

-- equivalent calls inferred from this helper; original call sites unknown
local function isAnyDropdownVisible()
	for _, activeDropdown in next, module.ActiveDropdowns, nil do
		if activeDropdown.IsOpen then
			return true
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateInputBox()
	local anyDropdownVisible = isAnyDropdownVisible() -- equivalent call inferred; original call site unknown

	if not anyDropdownVisible then
		input:ReleaseFocus()
	end

	input.Interactable = not anyDropdownVisible
end

for _, activeDropdown in next, module.ActiveDropdowns, nil do
	activeDropdown.OpenChanged:Connect(updateInputBox)
end

updateInputBox() -- equivalent call inferred; original call site unknown
task.spawn(function()
	while task.wait(2) do
		if not (addComment.Visible and addComment.Parent.Visible) then
			continue
		end

		local commentStyle = Comment:GetCommentStyle(style2.Value)

		if not (commentStyle and commentStyle.Hint and typeof(commentStyle.Hint) == "function") then
			continue
		end

		local v3 = commentStyle
		task.spawn(function()
			commentStyleHint.Label.Text = v3.Hint()
		end)
	end
end)
return {
	Style = style2,
	Negative = negative
}