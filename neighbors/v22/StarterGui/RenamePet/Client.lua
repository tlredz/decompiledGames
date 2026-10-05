local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ColorPicker = require(ReplicatedStorage.Modules.ColorPicker)
local UI = require(ReplicatedStorage.Modules.UI)
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local renamePet = parent.RenamePet
local contentContainer = renamePet.ContentContainer
local v = nil
local fontTemplate = contentContainer.FontTemplate
local dropdown = fontTemplate.Dropdown
local fonts = dropdown.Fonts
local information = fontTemplate.Information
local edit = information.Edit
local icon = edit.Icon
local buttons = contentContainer.Buttons
local confirm = buttons.Confirm
local cancel = buttons.Cancel
local edit2 = contentContainer.ColourTemplate.Edit
local textBox = contentContainer.TextboxTemplate.TextBox
local v2 = nil
local fontFace = nil
local color = Color3.fromRGB(255, 255, 255)

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateFontInformation(name)
	information.FontName.Text = `Name: <b>{name}</b>`
end

local function ToggleDropdown()
	dropdown.Visible = not dropdown.Visible
	TweenService:Create(icon, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Rotation = dropdown.Visible and 180 or 0
	}):Play()
end

local function CloseDropdown()
	if dropdown.Visible then
		dropdown.Visible = false
		TweenService:Create(icon, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Rotation = 0
		}):Play()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SelectFont(state)
	if v2 then
		v2.Visible = true
	end

	state.Visible = false
	v2 = state
	fontFace = state.Title.FontFace
	UpdateFontInformation(state.Name) -- equivalent call inferred; original call site unknown
	CloseDropdown()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SelectColor(color2: Color3)
	contentContainer.ColourTemplate.Edit.BackgroundColor3 = color2
	contentContainer.ColourTemplate.HexCode.Text = `Hex Code: <b>#{color2:ToHex():lower()}</b>`
	color = color2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function BindUIButton(p)
	UI:Bind(p)
	UI:BindHover(p)
end

edit.Activated:Connect(function()
	ToggleDropdown()
end)

for _, button in fonts:GetChildren() do
	if not button:IsA("ImageButton") then
		continue
	end

	BindUIButton(button) -- equivalent call inferred; original call site unknown
	local v3 = button
	button.Activated:Connect(function()
		SelectFont(v3) -- equivalent call inferred; original call site unknown
	end)
end

contentContainer.ColourTemplate.Edit.Activated:Connect(function()
	if v then
		v:Destroy()
		v = nil
	else
		v = ColorPicker.new(parent.Frame.Position, parent.Frame.AnchorPoint)
		v:Build()
		v.ColorUpdated:Connect(SelectColor)
	end
end)
confirm.Activated:Connect(function()
	local text = textBox.Text
	local tool = localPlayer.Character:FindFirstChildOfClass("Tool")

	if tool then
		tool.Rename:FireServer(text, fontFace.Family, color)
	end

	renamePet.Visible = false

	if v then
		v:Destroy()
		v = nil
	end
end)
cancel.Activated:Connect(function()
	renamePet.Visible = false

	if v then
		v:Destroy()
		v = nil
	end
end)
BindUIButton(edit2) -- equivalent call inferred; original call site unknown
BindUIButton(confirm) -- equivalent call inferred; original call site unknown
BindUIButton(cancel) -- equivalent call inferred; original call site unknown
SelectFont(fonts.Montserrat) -- equivalent call inferred; original call site unknown
BindUIButton(parent.Rename.Button) -- equivalent call inferred; original call site unknown
SelectColor(Color3.fromRGB(255, 255, 255)) -- equivalent call inferred; original call site unknown
parent.Rename.Button.Activated:Connect(function()
	renamePet.Visible = true
	parent.Rename.Visible = false
end)
renamePet:GetPropertyChangedSignal("Visible"):Connect(function()
	parent.Rename.Visible = not renamePet.Visible
end)
parent:GetPropertyChangedSignal("Enabled"):Connect(function()
	if v then
		v:Destroy()
		v = nil
	end

	if parent.Enabled then
		parent.Rename.Visible = true
	end

	parent.RenamePet.Visible = false
end)
UI:RegisterUIScale(parent.Rename.UIScale, {
	Mobile = 0.9,
	Tablet = 1,
	PC = 1
})
UI:RegisterUIScale(renamePet.UIScale, {
	Mobile = 1.6,
	Tablet = 1.5,
	PC = 1.5
})