local module = require("@game/ReplicatedStorage/Omni")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local weather = module.Shared.Weather
local WeatherColors = require(ReplicatedStorage.Omni.Shared.WeatherColors)
local weather2 = module.Interface:WaitForChild("HUD"):WaitForChild("Weather")
local button = weather2:WaitForChild("Button")
local label = button:WaitForChild("Label")
local value = weather2:WaitForChild("Time"):WaitForChild("Value")
local v = {
	button:WaitForChild("BG"):WaitForChild("UIGradient"),
	button:WaitForChild("Icon"):WaitForChild("UIGradient"),
	label:WaitForChild("UIGradient"),
	button:WaitForChild("Glow"):WaitForChild("UIGradient")
}
local v2 = {}
local loopConnection = nil
local name = nil
local flag = false
local Weather = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function FormatTime(p: number)
	local v3 = math.floor(p / 3600)
	local v4 = math.floor(p % 3600 / 60)
	local v5 = p % 60

	if v3 > 0 then
		return string.format("%02d:%02d:%02d", v3, v4, v5)
	end

	return string.format("%02d:%02d", v4, v5)
end

local function UpdateTime()
	local state = weather.GetState()

	if not state then
		return
	end

	local formatTime = FormatTime(math.max(0, (math.ceil(state.EndsAt - workspace:GetServerTimeNow())))) -- equivalent call inferred; original call site unknown
	local formatted = `Weather ({formatTime})`

	if value.Text == formatted then
		return
	end

	value.Text = formatted
end

local function Refresh()
	local state = weather.GetState()

	if not state then
		weather2.Visible = false
		return
	end

	weather2.Visible = true
	UpdateTime()

	if name == state.Name then
		return
	end

	name = state.Name
	local colorSequence = ColorSequence.new(WeatherColors.GetTextColor(state.Name), WeatherColors.GetAccent(state.Name))
	label.Text = state.Name

	for _, v3 in v do
		v3.Color = colorSequence
	end
end

function Weather.Destroy()
	flag = false

	if loopConnection then
		loopConnection:Disconnect()
		loopConnection = nil
	end

	for _, connection in v2 do
		connection:Disconnect()
	end

	table.clear(v2)
	name = nil
end

function Weather.Init()
	if flag then
		return
	end

	flag = true
	module.Button:Create(button, "Small"):BindFunction("Click", function()
		module.Frame:Open("Weather")
	end)
	v2.Weather = ReplicatedStorage:GetAttributeChangedSignal(weather.AttributeName):Connect(Refresh)
	v2.Destroying = module.Interface.Destroying:Connect(Weather.Destroy)
	loopConnection = module.Utils.Loop:Connect({
		Time = 1,
		Callback = UpdateTime
	})
	Refresh()
end

return Weather