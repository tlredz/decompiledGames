local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)

-- equivalent calls inferred from this helper; original call sites unknown
local function boxScale()
	if Platform_Handler.Platform.Value == "Mobile" then
		return 1.35
	end

	return 1.2000000000000002
end

local friendsHandler = require(ReplicatedStorage.CAM.Global.friendsHandler)
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local color = Color3.fromRGB(155, 208, 255)
local color2 = Color3.fromRGB(130, 255, 160)
local info = faye.Info(0.15)
local result = {}
local v = {}
local now = 0
local flag = false

local function rebuild()
	table.clear(result)
	local v2 = {
		[Players.LocalPlayer.Name] = true
	}

	for _, v3 in Players:GetPlayers() do
		if v2[v3.Name] then
			continue
		end

		v2[v3.Name] = true
		table.insert(result, v3.Name)
	end

	for _, v3 in v do
		if v2[v3] then
			continue
		end

		v2[v3] = true
		table.insert(result, v3)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshFriends()
	if flag then
		return
	end

	flag = true
	task.spawn(function()
		local names = {}

		for _, v2 in friendsHandler.getAllOnlineFriends() do
			if v2.IsInGame then
				table.insert(names, v2.name)
			end
		end

		v = names
		flag = false
		rebuild()
	end)
end

local function getItems()
	if os.clock() - now > 25 then
		now = os.clock()
		rebuild()
		refreshFriends() -- equivalent call inferred; original call site unknown
	end

	return result
end

local function completionFor(text: string)
	if text == "" then
		return nil
	end

	local v2 = string.lower(text)
	local v3 = nil
	local v4 = 1e999

	if os.clock() - now > 25 then
		now = os.clock()
		rebuild()
		refreshFriends() -- equivalent call inferred; original call site unknown
	end

	for _, v5 in result do
		if not (v2 == string.sub(string.lower(v5), 1, #text) and #v5 < v4) then
			continue
		end

		v4 = #v5
		v3 = v5
	end

	return v3
end

local function findItem(text: string)
	if text == "" then
		return nil
	end

	if os.clock() - now > 25 then
		now = os.clock()
		rebuild()
		refreshFriends() -- equivalent call inferred; original call site unknown
	end

	for _, v2 in result do
		if string.lower(v2) == string.lower(text) then
			return v2
		end
	end

	return nil
end

return function(object, _: string, p: number, data)
	local v2 = (data == nil or data.Signal == nil) and "Invite To Party" or data.Signal
	local text2 = object:Value("")
	local one

	if data == nil or data.SizeScale == nil then
		one = Vector2.one
	else
		one = data.SizeScale
	end

	local placeholderText = (data == nil or data.Placeholder == nil) and "Write Player name here to invite!" or data.Placeholder
	local v4

	if data == nil then
		v4 = false
	else
		v4 = data.Disabled == true
	end

	local v5 = nil
	local v6 = p * 0.75 * boxScale() * one.Y * 0.28 / 2
	local value2 = object:Value(color)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function markTyped(value3: string)
		local v8

		if value3 == "" then
			v8 = color
		else
			v8 = color2
		end

		value2:Set(v8)
	end

	local function send()
		if v4 or v5 == nil then
			return
		end

		local text = v5.Text
		local v7

		if text2.Value == "" then
			v7 = completionFor(text)
		else
			v7 = text2.Value
		end

		local v8 = v7 or findItem(text) or text
		v5.Text = ""
		text2:Set("")
		value2:Set(color)

		if v8 ~= "" then
			SignalEvent.ToServer(v2, v8)
		end
	end

	local v7 = object:Create("Frame")
	local v8 = {
		Size = UDim2.new(boxScale() * 0.5 * one.X, 0, 0, p * 0.75 * boxScale() * one.Y),
		BackgroundTransparency = 0.35
	}
	local backgroundColor

	if data == nil or data.BgColor == nil then
		backgroundColor = Color3.new()
	else
		backgroundColor = data.BgColor
	end

	v8.BackgroundColor3 = backgroundColor
	local v10

	if not (data == nil or not data.Shadow) then
		v10 = object:Create("UIShadow")({
			Color = Color3.new(0.7, 0.7, 0.75),
			BlurRadius = UDim.new(1, 0),
			Transparency = 0.85
		})
	end

	v8[1] = v10
	v8.Name = (data == nil or data.Name == nil) and "zzzzzzzzzz9zInviteBox" or data.Name
	local v11 = object:Create("UIGradient")({
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.75) }),
		Rotation = 5
	})
	local v12

	if data == nil or not data.NoStroke then
		v12 = object:Create("UIStroke")({
			BorderOffset = UDim.new(0, -2),
			Transparency = 0.5,
			Color = Color3.new(1, 1, 1)
		})
	end

	local v13 = object:Create("UICorner")({
		CornerRadius = UDim.new(1)
	})
	local v14

	if not v4 then
		v14 = object:Create("Frame")({
			Name = "ZSend",
			Size = UDim2.new(0.2, -v6, 0.72, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0.8, 0, 0.5, 0),
			BackgroundTransparency = 1,
			GradientButton(object, {
				Image = BunchaIcons.Checkmark2,
				BgColor = object:Animation(value2, info),
				CornerRadius = UDim.new(1, 0),
				StrokeClick = true,
				GradientTransparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.4),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Properties = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5)
				},
				Clicked = send
			})
		})
	end

	do local _values = table.pack(v11, v12, v13, v14, object:Create("Frame")({
	Name = "Textboxholder",
	Size = UDim2.new(v4 and 1 or 0.8, -math.min(10, p * 0.4), 0.85, 0),
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, math.min(10, p * 0.4) / 2, 0.5, 0),
	BackgroundTransparency = 1,
	AbsoluteSizeOnChangedInit = function(instance)
		local textSize = math.max(math.floor(instance.AbsoluteSize.Y * 0.8), 1)

		for _, child in instance:GetChildren() do
			if child:IsA("TextBox") or child:IsA("TextLabel") then
				child.TextSize = textSize
			end
		end
	end,
	object:Create("TextBox")({
		Name = "Textbox",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		TextScaled = false,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Font = Enum.Font.SourceSansSemibold,
		PlaceholderColor3 = Color3.new(0.75, 0.75, 0.75),
		PlaceholderText = placeholderText,
		ClearTextOnFocus = false,
		TextEditable = not v4,
		function(p2)
			v5 = p2
			return {
				FocusLost = function(p3, p4)
					if v4 then
						p3.Text = ""
					elseif p4 then
						send()
					end

					text2:Set("")
				end
			}
		end,
		TextOnChanged = function(object2, value3: string)
			markTyped(value3) -- equivalent call inferred; original call site unknown

			if not object2:IsFocused() then
				text2:Set("")
				return
			end

			if os.clock() - now > 25 then
				now = os.clock()
				rebuild()
				refreshFriends() -- equivalent call inferred; original call site unknown
			end

			local v15 = result
			local v16 = 9999
			local v17 = nil

			for i = 1, #v15 do
				local v18 = v15[i]

				if not (value3 ~= "" and string.lower(value3) == string.sub(string.lower(v18), 0, #value3)) then
					continue
				end

				if not (#v18 < v16) then
					continue
				end

				v16 = #v18
				v17 = v18
			end

			if v17 == nil then
				text2:Set("")
			else
				text2:Set(value3 .. string.sub(v17, #value3 + 1, #v17))
			end
		end
	}),
	object:Create("TextLabel")({
		Name = "AutoComplete",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		TextColor3 = Color3.new(1, 1, 1),
		ZIndex = -1,
		Text = text2,
		TextTransparency = 0.5,
		Font = Enum.Font.SourceSansSemibold,
		TextScaled = false,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextXAlignment = Enum.TextXAlignment.Left
	})
})); for _k = 1, _values.n do v8[1 + _k] = _values[_k] end end
	return v7(v8)
end