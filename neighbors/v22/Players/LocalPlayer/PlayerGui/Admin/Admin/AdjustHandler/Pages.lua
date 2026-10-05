local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Modules.Network)
local parent = script.Parent
local pages = parent.Pages
local tabList = parent.Tabs.TabList
local textBox = parent.Hotbar.SearchBar.Search.TextBox
local v = {
	Items = pages.ItemsList,
	Skins = pages.SkinsList,
	Titles = pages.TitlesList,
	Values = pages.ValuesList,
	Profile = pages.ProfileList,
	Passes = pages.PassesList,
	Warnings = pages.WarningsList
}
local v2 = nil

local function invertColor(value: Color3)
	return Color3.new(1 - value.R, 1 - value.G, 1 - value.B)
end

local function invertColorSequence(color)
	local colorSequenceKeypoints = {}

	for _, keypoint in color.Keypoints do
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(keypoint.Time, invertColor(keypoint.Value)))
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

local function invertTab(folder)
	local descendants = { folder }

	for _, descendant in folder:GetDescendants() do
		table.insert(descendants, descendant)
	end

	for _, instance in descendants do
		if instance:IsA("GuiObject") then
			local backgroundColor3 = instance.BackgroundColor3
			instance.BackgroundColor3 = Color3.new(
				1 - backgroundColor3.R,
				1 - backgroundColor3.G,
				1 - backgroundColor3.B
			)
		end

		if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
			local textColor3 = instance.TextColor3
			instance.TextColor3 = Color3.new(1 - textColor3.R, 1 - textColor3.G, 1 - textColor3.B)
		end

		if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
			local imageColor3 = instance.ImageColor3
			instance.ImageColor3 = Color3.new(1 - imageColor3.R, 1 - imageColor3.G, 1 - imageColor3.B)
		end

		if instance:IsA("UIStroke") then
			local color = instance.Color
			instance.Color = Color3.new(1 - color.R, 1 - color.G, 1 - color.B)
		elseif instance:IsA("UIGradient") then
			instance.Color = invertColorSequence(instance.Color)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setActiveTab(guiObject)
	if v2 == guiObject then
		return
	end

	if v2 then
		invertTab(v2)
	end

	invertTab(guiObject)
	v2 = guiObject
end

local function setActivePage(childName: string)
	local v3 = v[childName]
	local guiObject = tabList:FindFirstChild(childName)

	if not (v3 and (guiObject and guiObject:IsA("GuiObject"))) then
		return
	end

	for _, scrollingFrame in pages:GetChildren() do
		if scrollingFrame:IsA("ScrollingFrame") then
			scrollingFrame.Visible = scrollingFrame == v3
		end
	end

	setActiveTab(guiObject) -- equivalent call inferred; original call site unknown
	textBox.Text = ""
end

local function wireTab(childName: string)
	local guiObject = tabList:FindFirstChild(childName)

	if not (guiObject and guiObject:IsA("GuiObject")) then
		return
	end

	local button = guiObject:FindFirstChild("Button")

	if button and button:IsA("GuiButton") then
		button.MouseButton1Click:Connect(function()
			setActivePage(childName)
		end)
	end
end

local function hideUnsupportedTabs()
	for _, guiObject in tabList:GetChildren() do
		if not guiObject:IsA("GuiObject") or v[guiObject.Name] then
			continue
		end

		guiObject.Visible = false
	end
end

hideUnsupportedTabs()

for k in v do
	wireTab(k)
end

setActivePage("Profile")
Network:listen("AdjustAccount", function()
	setActivePage("Profile")
end)