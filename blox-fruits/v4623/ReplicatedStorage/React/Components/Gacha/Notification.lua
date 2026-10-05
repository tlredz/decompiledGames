local TweenService = game:GetService("TweenService")
local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local tweenInfo = TweenInfo.new(0.1)
local tweenInfo2 = TweenInfo.new(0.25)
local color = Color3.fromRGB(255, 86, 92)
local createElement = React.createElement
return function(p)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	React.useEffect(function()
		local v = {}
		local thread = nil

		if p.Notification.Value and ref.current and ref2.current then
			for _, v2 in pairs({ ref.current, ref2.current }) do
				table.insert(v, TweenService:Create(v2, tweenInfo, {
					TextTransparency = CONSTANTS.ALPHA.OPAQUE,
					TextStrokeTransparency = CONSTANTS.ALPHA.OPAQUE
				}))
			end

			for _, v2 in pairs(v) do
				v2:Play()
			end

			thread = task.delay(4, function()
				thread = nil

				for _, v2 in pairs({ ref.current, ref2.current }) do
					table.insert(v, TweenService:Create(v2, tweenInfo2, {
						TextTransparency = CONSTANTS.ALPHA.INVISIBLE,
						TextStrokeTransparency = CONSTANTS.ALPHA.OPAQUE
					}))
				end

				for _, v2 in pairs(v) do
					v2:Play()
				end
			end)
		end

		return function()
			for _, v2 in pairs(v) do
				v2:Destroy()
			end

			if thread then
				task.cancel(thread)
				thread = nil
			end

			table.clear(v)
		end
	end, { p.Notification.UID, ref.current, ref2.current })
	return createElement("TextLabel", RobloxTypes.mergeTextLabel({
		ref = ref,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.DISPLAY,
		Text = p.Notification.Value,
		TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		TextScaled = true,
		TextTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, p), {
		RealText = createElement("TextLabel", {
			ref = ref2,
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			Position = UDim2.fromScale(0.5, 0.95),
			Size = UDim2.fromScale(1, 1),
			Text = p.Notification.Value,
			TextColor3 = color,
			TextScaled = true,
			TextTransparency = CONSTANTS.ALPHA.INVISIBLE
		})
	})
end