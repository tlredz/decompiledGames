local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local info2 = faye.Info(0.2)
local color = Color3.new(1, 1, 1)

-- equivalent calls inferred from this helper; original call sites unknown
local function display(p: number)
	return string.gsub(Utility.formatTime(p), "s", "")
end

return function(animator, callback, p: number?)
	local v = p or callback()
	local v2 = {}
	local count = 0

	for k, v3 in string.split(string.gsub(Utility.formatTime(v), "s", ""), ":") do
		if k > 1 then
			table.insert(v2, {
				Type = "Separator"
			})
		end

		for _ = 1, #v3 do
			count += 1
			table.insert(v2, {
				Type = "Digit",
				Digit = count
			})
		end
	end

	local v4 = display(callback()) -- equivalent call inferred; original call site unknown
	local v5 = #v2 - #v4
	local textColor = color
	local v7 = {}
	local v8 = {}
	local v9 = {}
	local v10 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function rawOf(instance)
		if instance == nil then
			return nil
		end

		return typeof(instance) == "Instance" and instance or instance.Instance
	end

	local function makeDigitLabel(parent, text: string)
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Value"
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.Position = UDim2.fromScale(0, -1)
		textLabel.BackgroundTransparency = 1
		textLabel.TextScaled = true
		textLabel.FontFace = gameSettings.preferedFont
		textLabel.TextColor3 = textColor
		textLabel.Text = text
		textLabel.Parent = parent
		return textLabel
	end

	local function setDigit(digit: number, text: string)
		local parent = rawOf(v7[digit]) -- equivalent call inferred; original call site unknown

		if not (parent ~= nil and v9[digit] ~= text) then
			return
		end

		v9[digit] = text
		local v14 = rawOf(v10[digit]) -- equivalent call inferred; original call site unknown
		local digitLabel = makeDigitLabel(parent, text)
		v10[digit] = digitLabel

		if v14 == nil then
			digitLabel.Position = UDim2.fromScale(0, 0)
			return
		end

		animator:LoadAnimation(v14, {
			Position = UDim2.fromScale(0, 1)
		}, info):Play()
		task.delay(info.Time + 0.05, v14.Destroy, v14)
		animator:LoadAnimation(digitLabel, {
			Position = UDim2.fromScale(0, 0)
		}, info):Play()
	end

	local function render()
		local v12 = display(callback()) -- equivalent call inferred; original call site unknown
		local v13 = #v2 - #v12

		for k, v14 in v2 do
			local v16 = rawOf(v8[k]) -- equivalent call inferred; original call site unknown

			if v16 == nil then
				continue
			end

			local v17 = k - v13

			if v17 < 1 then
				v16.Visible = false

				if v14.Type == "Digit" then
					v9[v14.Digit] = nil
				end
			else
				v16.Visible = true

				if v14.Type == "Digit" then
					setDigit(v14.Digit, string.sub(v12, v17, v17))
				end
			end
		end
	end

	local v11 = animator:Create("Frame")({
		Name = "Timer",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		animator:Create("UIListLayout")({
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 1)
		}),
		animator:Iterate(v2, function(layoutOrder, p3, object)
			if p3.Type == "Separator" then
				local v12 = object:Create("Frame")({
					Name = `Separator{layoutOrder}`,
					LayoutOrder = layoutOrder,
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Visible = layoutOrder - v5 >= 1,
					object:Create("UIAspectRatioConstraint")({
						AspectRatio = 0.15
					}),
					object:Create("TextLabel")({
						Name = "Colon",
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						Text = ":",
						TextTransparency = object:Animation(0, info2, {
							From = 1
						}),
						TextScaled = true,
						FontFace = gameSettings.preferedFont,
						TextColor3 = color
					})
				})
				v8[layoutOrder] = v12
				return v12
			else
				local v12 = layoutOrder - v5
				local text

				if v12 >= 1 then
					text = string.sub(v4, v12, v12)
				end

				local v14

				if not (text == nil or text == "") then
					v14 = object:Create("TextLabel")({
						Name = "Value",
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						TextScaled = true,
						TextTransparency = object:Animation(0, info2, {
							From = 1
						}),
						FontFace = gameSettings.preferedFont,
						TextColor3 = color,
						Text = text
					})
				end

				if v14 ~= nil then
					v9[p3.Digit] = text
					v10[p3.Digit] = v14
				end

				local v15 = object:Create("Frame")({
					Name = `Digit{p3.Digit}`,
					LayoutOrder = layoutOrder,
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Visible = v12 >= 1,
					ClipsDescendants = true,
					object:Create("UIAspectRatioConstraint")({
						AspectRatio = 0.55
					}),
					v14
				})
				v7[p3.Digit] = v15
				v8[layoutOrder] = v15
				return v15
			end
		end)
	})
	render()
	animator:Spawn(function()
		while true do
			task.wait(0.5)
			render()
		end
	end)
	return v11
end