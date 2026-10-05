local TextService = game:GetService("TextService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local permanentMarker = Enum.Font.PermanentMarker
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local offset = gameSettings.KeybindTextSize.X.Offset
local vector = Vector2.new(2000, gameSettings.Width)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local v = {
	One = 1,
	Two = 2,
	Three = 3,
	Four = 4,
	Five = 5,
	Six = 6
}

local function resolve(name: string)
	local mapping = InputHandler.GetMapping(name)

	if mapping == nil then
		return name
	end

	for _, v2 in mapping do
		if typeof(v2) ~= "table" then
			return InputHandler.PrettyInput(v2.Name)
		end
	end

	return name
end

return function(parent)
	local v2 = resolve(parent.Name)
	local text = v[v2] or v2
	local textSize = TextService:GetTextSize(text, offset, permanentMarker, vector)
	local textLabel = Instance.new("TextLabel")
	textLabel.TextScaled = true
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Position = UDim2.fromScale(0.5, 0.5)
	textLabel.Size = UDim2.fromScale(textSize.X / offset * 1.325, 1.325)
	textLabel.TextXAlignment = Enum.TextXAlignment.Center
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.Parent = parent
	textLabel.TextTransparency = 0
	textLabel.Font = permanentMarker
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.Text = text
	textLabel.BackgroundTransparency = 1
	local uIStroke = Instance.new("UIStroke", textLabel)
	uIStroke.Thickness = 1
	uIStroke.Transparency = 0.15
	return textLabel
end