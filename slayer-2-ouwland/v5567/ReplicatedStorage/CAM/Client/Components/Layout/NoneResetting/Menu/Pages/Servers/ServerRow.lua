local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local ServerBrowserController = require(ReplicatedStorage.CAM.Client.Controllers.ServerBrowserController)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local notification = ReplicatedStorage.Communication.CnC.Notifications.Notification
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local color = Color3.fromRGB(155, 208, 255)
local color2 = Color3.new(0.7, 0.7, 0.7)
local color3 = Color3.fromRGB(120, 220, 140)
local numberSequence = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.75) })
local info = faye.Info(0.2)
local v = {
	Name = {
		At = 0.02,
		Width = 0.28
	},
	Region = {
		At = 0.32,
		Width = 0.11
	},
	Version = {
		At = 0.45,
		Width = 0.08
	},
	Uptime = {
		At = 0.55,
		Width = 0.15,
		Height = 0.4
	},
	Count = {
		At = 0.71,
		Width = 0.08
	},
	Bar = {
		At = 0.8,
		Width = 0.04
	},
	Join = {
		At = 0.87,
		Width = 0.11
	}
}
local v2 = {
	Name = v.Name,
	Region = v.Region,
	Version = v.Version,
	Uptime = v.Uptime,
	Count = {
		At = 0.72,
		Width = 0.08
	},
	Bar = {
		At = 0.82,
		Width = 0.16
	}
}
local color4 = Color3.new(0.55, 0.55, 0.55)
local color5 = Color3.new(0.45, 0.45, 0.45)

local function cell(object, name: string, p2: string, text: string, flag: boolean?, color6: Color3?, p4)
	local v3 = (p4 or v)[p2]
	local v4 = object:Create("TextLabel")
	local v5 = {
		Name = name,
		Text = text,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(v3.At, 0.5),
		Size = UDim2.fromScale(v3.Width, v3.Height or 0.5),
		BackgroundTransparency = 1,
		TextColor3 = color6 or Color3.new(1, 1, 1),
		Font = 0,
		TextScaled = true,
		TextXAlignment = 0
	}
	local font

	if flag then
		font = Enum.Font.SourceSansBold
	else
		font = Enum.Font.SourceSans
	end

	v5.Font = font
	v5.TextXAlignment = Enum.TextXAlignment.Left
	return v4(v5)
end

return function(object, data)
	local isCurrentServer = ServerBrowserController.IsCurrentServer(data)
	local v3

	if data.MaxPlayers > 0 then
		v3 = data.Players >= data.MaxPlayers
	else
		v3 = false
	end

	local v4 = not (data.MaxPlayers > 0) and 0 or math.clamp(data.Players / data.MaxPlayers, 0, 1)
	local friends = data.Friends or {}
	local color6

	if v3 then
		color6 = Color3.new(1, 1, 1)
	elseif #friends > 0 then
		color6 = color
	else
		color6 = color3
	end

	local value = object:Value(0.6)
	local v5 = false
	local size = object:Value(UDim2.new(0, 16, 0.385, 0))
	local v6

	if isCurrentServer then
		v6 = v2
	else
		v6 = v
	end

	local color7

	if isCurrentServer then
		color7 = color4
	else
		color7 = Color3.new(1, 1, 1)
	end

	local v7

	if isCurrentServer then
		v7 = color5
	else
		v7 = color2
	end

	local function nameBox(p: number, p2: number)
		return object:Create("TextBox")({
			Name = "1Name",
			Text = data.Name,
			TextEditable = false,
			ClearTextOnFocus = false,
			Selectable = false,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(v6.Name.At, p),
			Size = UDim2.fromScale(v6.Name.Width, p2),
			BackgroundTransparency = 1,
			TextColor3 = color7,
			Font = Enum.Font.SourceSansBold,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left
		})
	end

	local v8

	if #friends == 0 then
		v8 = nameBox(0.5, 0.5)
	else
		local v9 = {}

		for i = 1, math.min(3, #friends) do
			table.insert(v9, friends[i])
		end

		local text = "Friends: " .. table.concat(v9, ", ")

		if #friends > 3 then
			text ..= ` +{#friends - 3}`
		end

		v8 = { nameBox(0.32, 0.45), object:Create("TextLabel")({
				Name = "1Friends",
				Text = text,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(v.Name.At, 0.74),
				Size = UDim2.fromScale(v.Name.Width, 0.32),
				BackgroundTransparency = 1,
				TextColor3 = color,
				Font = Enum.Font.SourceSansSemibold,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left
			}) }
	end

	local function join()
		if isCurrentServer or v5 then
			return
		end

		v5 = true

		if v3 and PopUpCreator.new({
			Type = "Question",
			Content = `{data.Name} looks full right now, but the count can lag behind. Try joining anyway?`
		}):WaitResult() ~= "Yes" then
			v5 = false
			return
		end

		local joined, text = ServerBrowserController.Join(data)
		v5 = false

		if not joined and text ~= nil then
			notification:Fire("Notify", {
				Text = text,
				Type = "Denied"
			})
		end
	end

	local v9

	if not isCurrentServer then
		v9 = object:Create("Frame")({
			Name = "7Join",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(v.Join.At, 0.5),
			Size = UDim2.fromScale(v.Join.Width, 0.6),
			BackgroundTransparency = 1,
			GradientButton(object, {
				Text = "JOIN",
				TextXAlignment = Enum.TextXAlignment.Center,
				Font = Enum.Font.SourceSansBold,
				BgColor = color6,
				ContentColor = color6,
				ContentTransparency = v3 and 0.6 or 0,
				GradientTransparency = numberSequence,
				CornerRadius = UDim.new(0.2),
				StrokeClick = true,
				Clicked = join,
				Properties = {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.fromScale(1, 0.5)
				}
			})
		})
	end

	local v10 = object:Create("Frame")
	local v11 = {
		Name = data.Name,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0.12, 0.12, 0.12),
		BackgroundTransparency = isCurrentServer and 0.6 or 0.4
	}
	local v12 = object:Create("UICorner")({
		CornerRadius = UDim.new(0.2)
	})
	local v13 = object:Create("UIStroke")
	local color8

	if isCurrentServer then
		color8 = color4
	elseif #friends > 0 then
		color8 = color
	else
		color8 = Color3.new(1, 1, 1)
	end

	v11[1], v11[2], v11[3], v11[4], v11[5], v11[6], v11[7], v11[8], v11[9], v11[10] = v12, v13({
	Color = color8,
	Thickness = 1,
	Transparency = object:Animation(value, info)
}), object:Create("TextButton")({
	Name = "Hover",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	ZIndex = 0,
	MouseEnter = function()
		if isCurrentServer then
			return
		end

		value:Set(0)
	end,
	MouseLeave = function()
		value:Reset()
	end
}), v8, object:Create("Frame")({
	Name = "2Region",
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.fromScale(v6.Region.At, 0.5),
	Size = size,
	BackgroundColor3 = Color3.new(0.25, 0.25, 0.25),
	BackgroundTransparency = 0.7,
	object:Create("UICorner")({
		CornerRadius = UDim.new(0.2)
	}),
	object:Create("TextLabel")({
		Text = data.Region,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 8, 0.5, 0),
		Size = UDim2.fromScale(100, 0.7),
		BackgroundTransparency = 1,
		TextColor3 = color7,
		Font = Enum.Font.SourceSansSemibold,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextBoundsOnChangedInit = function(_, point: Vector2)
			size:Set(UDim2.new(0, math.ceil(point.X * 1.05 + 16), 0.385, 0))
		end
	})
}), cell(object, "3Version", "Version", data.Version, false, v7, v6), cell(
	object,
	"4Uptime",
	"Uptime",
	"Up " .. Utility.formatTimeUnits(ServerBrowserController.UptimeOf(data), " ", 2),
	false,
	v7,
	v6
), cell(object, "5Count", "Count", `{data.Players} / {data.MaxPlayers}`, false, color7, v6), object:Create("Frame")({
	Name = "6Bar",
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.fromScale(v6.Bar.At, 0.5),
	Size = UDim2.fromScale(v6.Bar.Width, 0.12),
	BackgroundColor3 = Color3.new(0.25, 0.25, 0.25),
	object:Create("UICorner")({
		CornerRadius = UDim.new(1)
	}),
	object:Create("Frame")({
		Name = "Fill",
		Size = UDim2.fromScale(v4, 1),
		BackgroundColor3 = color7,
		BackgroundTransparency = 0.1,
		object:Create("UICorner")({
			CornerRadius = UDim.new(1)
		})
	})
}), v9
	return v10(v11)
end