local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
local Trove = require(ReplicatedStorage.packages.Trove)
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local fx = require(ReplicatedStorage.shared.modules.fx)
local CustomColorPicker = require(script.CustomColorPicker)
local _ = Players.LocalPlayer
local customTitle = HudController:GetSafeZone():WaitForChild("customTitle")
local textBox = customTitle:WaitForChild("Title"):WaitForChild("TextBox")
local preview = customTitle:WaitForChild("preview")
local textColor = customTitle:WaitForChild("textColor")
local strokeColor = customTitle:WaitForChild("strokeColor")
local confirm = customTitle:WaitForChild("confirm")
local warning = customTitle:WaitForChild("warning")
local close = customTitle:WaitForChild("Close")
local color = customTitle:WaitForChild("color")
local ui = ReplicatedStorage.resources.sounds.sfx.ui
local anno_localthought = ReplicatedStorage.events.anno_localthought
local remoteFunction = Net:RemoteFunction("CustomTitle/Create")
local remoteEvent = Net:RemoteEvent("TitleWriter/OpenCustom")
local color2 = Color3.fromRGB(255, 255, 255)
local color3 = Color3.fromRGB(0, 0, 0)
local color4 = Color3.fromRGB(162, 234, 166)
local color5 = Color3.fromRGB(81, 81, 81)
local color6 = Color3.fromRGB(234, 116, 118)
local v = {
	OK = "Title created!",
	TOO_LONG = "Title must be 1-10 characters.",
	BAD_CHARS = "Letters only, no spaces or symbols.",
	FILTERED = "That title isn't allowed.",
	NAME_TAKEN = "That title already exists/is blacklisted.",
	TOO_POOR = "You can't afford this.",
	BAD_INPUT = "Invalid title.",
	ERROR = "Something went wrong, try again."
}
local textColor2 = color2
local color8 = color3
local flag = false
Trove.new()
local v4 = nil
local v5 = "text"

-- equivalent calls inferred from this helper; original call sites unknown
local function updatePreview()
	local text = textBox.Text

	if text == "" then
		preview.Text = "<>"
	else
		preview.Text = `<{text}>`
	end

	preview.TextColor3 = textColor2
	preview.stroke.Color = color8
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateButtonPreviews()
	textColor.TextColor3 = textColor2
	strokeColor.stroke.Color = color8
end

local function filterInput()
	local text = textBox.Text:gsub("[^%a]", "")

	if #text > 10 then
		text = text:sub(1, 10)
	end

	if text ~= textBox.Text then
		textBox.Text = text
		return
	end

	updatePreview() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setConfirmEnabled(flag2: boolean)
	confirm.Active = flag2
	confirm.AutoButtonColor = flag2
	confirm.TextColor3 = flag2 and color4 or color5

	if confirm:FindFirstChild("border") then
		confirm.border.Color = flag2 and color4 or color5
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function flashWarning(p: string, _: Color3)
	anno_localthought:Fire(p)
end

local function submit()
	if flag then
		return
	end

	local text = textBox.Text

	if text == "" or #text > 10 or not text:match("^%a+$") then
		flashWarning("Letters only, no spaces or symbols.") -- equivalent call inferred; original call site unknown
		fx:PlaySound(ui.boowomp, confirm, false)
	else
		flag = true
		setConfirmEnabled(false) -- equivalent call inferred; original call site unknown
		confirm.Text = "[...]"
		fx:PlaySound(ui.click2, confirm, false)
		local v7 = remoteFunction:InvokeServer({
			text = text,
			textColor = {
				r = math.round(textColor2.R * 255),
				g = math.round(textColor2.G * 255),
				b = math.round(textColor2.B * 255)
			},
			strokeColor = {
				r = math.round(color8.R * 255),
				g = math.round(color8.G * 255),
				b = math.round(color8.B * 255)
			}
		})
		flag = false
		confirm.Text = "[Confirm]"
		setConfirmEnabled(true) -- equivalent call inferred; original call site unknown
		local v9 = v[typeof(v7) ~= "table" and "ERROR" or v7.code or "ERROR"] or "Something went wrong, try again."

		if typeof(v7) == "table" and v7.success then
			flashWarning(v9) -- equivalent call inferred; original call site unknown
			fx:PlaySound(ui.equip, confirm, false)
		else
			flashWarning(v9) -- equivalent call inferred; original call site unknown
			fx:PlaySound(ui.boowomp, confirm, false)
		end
	end
end

local function resetPanel()
	textBox.Text = ""
	textColor2 = color2
	color8 = color3
	v5 = "text"
	flag = false
	confirm.Text = "[Confirm]"
	setConfirmEnabled(true) -- equivalent call inferred; original call site unknown
	warning.Text = "Letters only, up to 10 characters. Changing it later costs another 50,000 S$."
	warning.TextColor3 = Color3.fromRGB(180, 180, 180)

	if color then
		color.Visible = false
	end

	updatePreview() -- equivalent call inferred; original call site unknown
	updateButtonPreviews() -- equivalent call inferred; original call site unknown
end

local function openPanel()
	resetPanel()
	customTitle.Visible = true
end

local CustomTitleController = {}

function CustomTitleController.setTextColor(color7: Color3)
	textColor2 = color7
	updatePreview() -- equivalent call inferred; original call site unknown
end

function CustomTitleController.setStrokeColor(color7: Color3)
	color8 = color7
	updatePreview() -- equivalent call inferred; original call site unknown
end

function CustomTitleController.Start(_)
	resetPanel()
	v4 = CustomColorPicker.new(color, function(color7: Color3)
		if v5 == "text" then
			textColor2 = color7
		else
			color8 = color7
		end

		updatePreview() -- equivalent call inferred; original call site unknown
		updateButtonPreviews() -- equivalent call inferred; original call site unknown
	end)
	color.Visible = false
	textBox:GetPropertyChangedSignal("Text"):Connect(filterInput)
	confirm.MouseEnter:Connect(function()
		fx:PlaySound(ui.select, confirm, false)
	end)
	confirm.Activated:Connect(submit)
	textColor.Activated:Connect(function()
		fx:PlaySound(ui.click2, textColor, false)
		v5 = "text"
		color.title.Text = "Text Color"
		color.Visible = true
		v4:LoadColor(textColor2)
	end)
	strokeColor.Activated:Connect(function()
		fx:PlaySound(ui.click2, strokeColor, false)
		v5 = "stroke"
		color.title.Text = "Stroke Color"
		color.Visible = true
		v4:LoadColor(color8)
	end)
	close.Activated:Connect(function()
		fx:PlaySound(ui.click2, close, false)
		customTitle.Visible = false
	end)
	remoteEvent.OnClientEvent:Connect(openPanel)
end

return CustomTitleController