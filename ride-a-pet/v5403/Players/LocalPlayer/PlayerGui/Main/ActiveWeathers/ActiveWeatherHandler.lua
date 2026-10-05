local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Weather = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Weather"))
local Mutations = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Mutations"))
local Volcano = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Volcano"))
local serverData = ReplicatedStorage:WaitForChild("ServerData")
local localPlayer = Players.LocalPlayer
local v = {
	Type = "Scorching",
	Local = Volcano.Scorching
}
local parent = script.Parent
local weatherFrame = script:WaitForChild("WeatherFrame")
local weatherDescription = parent.Parent:WaitForChild("WeatherDescription")
local weatherName = weatherDescription:WaitForChild("WeatherName")
local description = weatherDescription:WaitForChild("Description")
local timeLeft = weatherDescription:WaitForChild("TimeLeft")
local v2 = {}
local v3 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function FormatLeft(p: number)
	local v4 = math.max(0, (math.floor(p + 0.5)))
	local v5 = math.floor(v4 / 60)

	if v5 > 0 then
		return string.format("%dm %ds", v5, v4 % 60)
	end

	return string.format("%ds", v4)
end

local function PaintFor(p: string, p2: string?)
	local v4 = v2[p]

	if v4 and v4.Local then
		return v4.Local.Gradient, nil
	end

	local v5

	if p2 == nil or type(Weather.StormRarity) ~= "table" then
		v5 = false
	else
		v5 = Weather.StormRarity[p2] ~= nil
	end

	if v5 then
		return Mutations.GradientFor(Mutations.ForWeather(p2)), nil
	end

	local gradientFor = Weather.GradientFor(p)

	if type(gradientFor) == "table" then
		return gradientFor.Color, gradientFor.Rotation
	end

	return gradientFor, nil
end

local function PaintName(p: string, variant: string?)
	local weatherPaint = weatherName:FindFirstChild("WeatherPaint")

	if weatherPaint then
		weatherPaint:Destroy()
	end

	local color, v5 = PaintFor(p, variant)

	if typeof(color) ~= "ColorSequence" then
		return
	end

	local uIGradient = Instance.new("UIGradient")
	uIGradient.Name = "WeatherPaint"
	uIGradient.Color = color

	if tonumber(v5) then
		uIGradient.Rotation = tonumber(v5)
	end

	uIGradient.Parent = weatherName
end

local function ShowPanel(name: string)
	local v4 = v2[name]

	if not v4 then
		weatherDescription.Visible = false
		return
	end

	local data = Weather.Data
	local v5 = v4.Local or data and (data[v4.Variant or name] or data[name])
	weatherName.Text = v4.Local and v4.Local.Name or v4.Variant or name
	description.Text = v5 and v5.Description or ""
	PaintName(name, v4.Variant)
	timeLeft.Visible = v4.EndsAt ~= nil

	if v4.EndsAt then
		local v6 = timeLeft
		local text = FormatLeft(v4.EndsAt - workspace:GetServerTimeNow()) -- equivalent call inferred; original call site unknown
		v6.Text = text
	end

	weatherDescription.Visible = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HidePanel(p: string?)
	if p and v3 ~= p then
		return
	end

	v3 = nil
	weatherDescription.Visible = false
end

local function RemoveTile(p: string)
	local v4 = v2[p]

	if not v4 then
		return
	end

	v2[p] = nil
	v4.Frame:Destroy()
	HidePanel(p) -- equivalent call inferred; original call site unknown
end

local function ClearAll()
	for k in v2 do
		local v4 = v2[k]

		if not v4 then
			continue
		end

		v2[k] = nil
		v4.Frame:Destroy()

		if not (not k or v3 == k) then
			continue
		end

		v3 = nil
		weatherDescription.Visible = false
	end
end

local function ShowTile(name: string, variant: string?, endsAt: number?, p)
	local v4 = v2[name]

	if not v4 then
		local clone = weatherFrame:Clone()
		clone.Name = name
		clone.Position = UDim2.fromScale(0, 0)
		clone.Visible = true
		clone.Parent = parent
		v4 = {
			Frame = clone,
			TimeLeft = clone:WaitForChild("TimeLeft")
		}
		v2[name] = v4
		clone.Active = true
		clone.MouseEnter:Connect(function()
			v3 = name
			ShowPanel(name)
		end)
		clone.MouseLeave:Connect(function()
			HidePanel(name) -- equivalent call inferred; original call site unknown
		end)
		clone.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				v3 = name
				ShowPanel(name)
			end
		end)
		clone.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				HidePanel(name) -- equivalent call inferred; original call site unknown
			end
		end)
	end

	local data = Weather.Data
	local v5 = p or data and (data[variant or name] or data[name])
	local imageLabel = v4.Frame:FindFirstChild("ImageLabel")

	if imageLabel and v5 and type(v5.Image) == "string" and v5.Image ~= "" then
		imageLabel.Image = v5.Image
	end

	v4.Frame.Name = name
	v4.EndsAt = endsAt
	v4.Variant = variant
	v4.Local = p
	v4.TimeLeft.Visible = endsAt ~= nil

	if endsAt then
		local timeLeft2 = v4.TimeLeft
		local text = FormatLeft(endsAt - workspace:GetServerTimeNow()) -- equivalent call inferred; original call site unknown
		timeLeft2.Text = text
	end

	if v3 == name then
		ShowPanel(name)
	end
end

local v4 = nil
local v5 = {}
local v6 = nil
local flag = false
local revision = -1
local now = -1e999

local function ReadSnapshot()
	local weatherSnapshotV2 = serverData:GetAttribute("WeatherSnapshotV2")
	local v7 = type(weatherSnapshotV2) == "string"

	if not v7 then
		if flag then
			return
		else
			weatherSnapshotV2 = serverData:GetAttribute("ActiveWeathers")
		end
	end

	if type(weatherSnapshotV2) ~= "string" or weatherSnapshotV2 == v6 then
		return
	end

	local success, result = pcall(HttpService.JSONDecode, HttpService, weatherSnapshotV2)

	if not success or type(result) ~= "table" then
		return
	end

	if v7 then
		if type(result.Revision) ~= "number" or result.Revision ~= result.Revision or result.Revision < revision or type(result.Weathers) ~= "table" then
			return
		end

		revision = result.Revision
		flag = true
		result = result.Weathers
	end

	local v8 = {}

	for _, v9 in pairs(result) do
		if not (type(v9) == "table" and type(v9.Type) == "string" and type(v9.EndsAt) == "number") then
			continue
		end

		v8[v9.Type] = v9
	end

	v5 = v8
	v6 = weatherSnapshotV2
end

local function Refresh()
	ReadSnapshot()
	local serverTimeNow = workspace:GetServerTimeNow()
	local v7 = {}

	for k, v8 in pairs(v5) do
		if serverTimeNow < v8.EndsAt then
			v7[k] = v8
		end
	end

	if v4 and (not v4.EndsAt or serverTimeNow < v4.EndsAt) and not v7[v4.Type] then
		v7[v4.Type] = v4
	end

	if localPlayer:GetAttribute("InVolcano") == true then
		v7[v.Type] = v
	end

	for k, v8 in pairs(v7) do
		local v9 = v2[k]

		if not v9 or v9.Variant ~= v8.Variant or v9.EndsAt ~= v8.EndsAt or v9.Local ~= v8.Local then
			ShowTile(k, v8.Variant, v8.EndsAt, v8.Local)
			v9 = v2[k]
		end

		v9.Private = v8 == v4

		if not v9.EndsAt then
			continue
		end

		local text = FormatLeft(v9.EndsAt - serverTimeNow) -- equivalent call inferred; original call site unknown

		if v9.TimeLeft.Text ~= text then
			v9.TimeLeft.Text = text
		end

		if v3 == k then
			timeLeft.Text = text
		end
	end

	for k in pairs(v2) do
		if v7[k] then
			continue
		end

		local v8 = v2[k]

		if not v8 then
			continue
		end

		v2[k] = nil
		v8.Frame:Destroy()

		if not (not k or v3 == k) then
			continue
		end

		v3 = nil
		weatherDescription.Visible = false
	end
end

local function RefreshSafely()
	local v7, v8 = xpcall(Refresh, debug.traceback)

	if not v7 and os.clock() - now >= 60 then
		now = os.clock()
		warn("[WeatherTracker] refresh failed; retrying: " .. tostring(v8))
	end
end

serverData:GetAttributeChangedSignal("WeatherSnapshotV2"):Connect(RefreshSafely)
serverData:GetAttributeChangedSignal("ActiveWeathers"):Connect(RefreshSafely)
localPlayer:GetAttributeChangedSignal("InVolcano"):Connect(RefreshSafely)
RefreshSafely()
task.spawn(function()
	ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("PrivateWeather").OnClientEvent:Connect(function(value, variant, p2)
		v4 = type(value) == "string" and {
			Type = value,
			Variant = variant,
			EndsAt = tonumber(p2)
		} or nil
		RefreshSafely()
	end)
end)
task.spawn(function()
	while true do
		task.wait(1)
		RefreshSafely()
	end
end)