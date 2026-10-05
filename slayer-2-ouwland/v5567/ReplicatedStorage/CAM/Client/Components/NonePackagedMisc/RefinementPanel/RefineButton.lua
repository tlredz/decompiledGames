local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
require(ReplicatedStorage.Packages.faye)
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.75, 0.5),
	NumberSequenceKeypoint.new(1, 0.5)
})
return function(object, data)
	local rung = data.Rung
	local color, noRungLabel

	if rung == nil then
		color = Color3.new(0.35, 0.35, 0.35)
		noRungLabel = data.NoRungLabel or "Fully refined"
	elseif data.Enabled then
		local v = rung.FailBp / 10000

		if v >= 0.6 then
			color = Color3.new(1, 0.364706, 0.364706)
		elseif v >= 0.25 then
			color = Color3.new(1, 0.803922, 0.305882)
		else
			color = Color3.new(0.627451, 1, 0.466667)
		end

		noRungLabel = data.Label or "Refine"
	else
		color = Color3.new(0.35, 0.35, 0.35)
		noRungLabel = data.DisabledLabel or "Not enough materials"
	end

	return object:Create("Frame")({
		Name = "RefineButton",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		object:Create("UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.06, 0)
		}),
		object:Create("Frame")({
			Name = "ButtonHolder",
			LayoutOrder = 1,
			Size = UDim2.fromScale(0.72, 0.66),
			BackgroundTransparency = 1,
			GradientButton(object, {
				Properties = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1)
				},
				GradientTransparency = numberSequence,
				GradientRotation = -90,
				TextXAlignment = Enum.TextXAlignment.Center,
				Text = object:Do(function(callback)
					if callback(data.Busy) then
						return data.BusyLabel or "Refining..."
					end

					local v = callback(data.Reason)

					if v == "" then
						return noRungLabel
					end

					return v
				end),
				BgColor = color,
				ContentColor = Color3.new(1, 1, 1),
				Clicked = data.Clicked
			})
		}),
		object:Create("TextLabel")({
			Name = "SkipHint",
			LayoutOrder = 2,
			Size = UDim2.fromScale(1, 0.2),
			BackgroundTransparency = 1,
			Text = "click to skip",
			TextScaled = true,
			Font = Enum.Font.SourceSansSemibold,
			TextColor3 = Color3.new(1, 1, 1),
			TextTransparency = 0.5,
			Visible = data.Charging,
			object:Create("UITextSizeConstraint")({
				MaxTextSize = 14
			})
		})
	})
end