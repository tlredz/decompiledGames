local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent
local world = ReplicatedStorage:WaitForChild("world")
local weathers = require(ReplicatedStorage.shared.modules.library.weathers)
local SharedWeather = require(ReplicatedStorage.shared.modules.SharedWeather)
local frame = Instance.new("Frame")
frame.Name = "modifiers"
frame.AnchorPoint = Vector2.new(0.5, 1)
frame.Position = UDim2.fromScale(0.5, -0.2)
frame.Size = UDim2.fromScale(2, 0.8)
frame.BackgroundTransparency = 1
frame.Parent = parent
local uIListLayout = Instance.new("UIListLayout")
uIListLayout.FillDirection = Enum.FillDirection.Vertical
uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout.Padding = UDim.new(0, 2)
uIListLayout.Parent = frame
local joined = ""

local function mouseEnter()
	local label = script.Parent:WaitForChild("label")
	local value = world:WaitForChild("weather").Value
	label.Text = `{(weathers[value] or {}).DisplayName or value}{joined}`
	label.Visible = true
end

local function mouseLeave()
	local label = script.Parent:WaitForChild("label")
	label.Visible = false
end

local function clearBadges()
	for _, image in frame:GetChildren() do
		if image:IsA("ImageLabel") then
			image:Destroy()
		end
	end
end

local function makeBadge(data)
	local UI = data.UI or {}

	if not (UI.Color or data.AmbientColor) then
		Color3.fromRGB(255, 220, 140)
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = data.Name
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.BackgroundTransparency = 1
	imageLabel.ZIndex = 100
	imageLabel.Image = UI.Icon or "rbxassetid://18987581016"
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.LayoutOrder = data.Severity or 0
	local uIScale = Instance.new("UIScale")
	uIScale.Scale = 2
	uIScale.Parent = imageLabel
	imageLabel.MouseEnter:Connect(mouseEnter)
	imageLabel.MouseLeave:Connect(mouseLeave)
	imageLabel.Parent = frame
	return imageLabel
end

local function updateModifierBadges()
	local allActive = SharedWeather.GetAllActive()
	clearBadges()

	if #allActive == 0 then
		joined = ""
		return
	end

	local v = {}

	for _, v2 in allActive do
		local v3 = weatherModifiers.Get(v2)

		if not v3 then
			continue
		end

		makeBadge(v3)
		local color = v3.UI and v3.UI.Color or v3.AmbientColor or Color3.fromRGB(255, 220, 140)
		local displayName = v3.DisplayName or v3.Name
		table.insert(v, (` + <b><font color="#{color:ToHex()}">{displayName}</font></b>`))
	end

	joined = table.concat(v)
end

function Check()
	local value = world:WaitForChild("weather").Value
	local v = weathers[value] or {}
	script.Parent.label.Text = v.DisplayName or value
	parent.Image = v.Icon or "rbxassetid://113973039010423"
	parent.ImageColor3 = v.IconColor or Color3.fromRGB(255, 255, 255)
end

SharedWeather.WeatherChanged:Connect(Check)
task.wait()
Check()
updateModifierBadges()
script.Parent.MouseEnter:Connect(mouseEnter)
script.Parent.MouseLeave:Connect(mouseLeave)