local shared = script.Parent.Parent.Parent.Shared
local React = require(shared.React)
local parent = script.Parent
local Button = require(parent.Button)

local function DisabledOverlay(props)
	if not props.Visible then
		return nil
	end

	local createElement = React.createElement
	local v2 = {
		[React.Tag] = "DisabledOverlay",
		Active = false
	}
	local v3 = {
		LockIcon = React.createElement("ImageLabel", {
			[React.Tag] = props.Freemium and "FreemiumLockIcon" or "LockIcon"
		}),
		BuyButton = 0
	}
	local onPurchase = not props.Freemium and props.OnPurchase

	if onPurchase then
		onPurchase = React.createElement(Button, {
			[React.Tag] = "BuyButton",
			OnActivated = props.OnPurchase
		}, {
			Text = React.createElement("TextLabel", {
				[React.Tag] = "BuyButtonLabel",
				Text = "BUY",
				BackgroundTransparency = 1
			})
		})
	end

	v3.BuyButton = onPurchase
	return createElement("Frame", v2, v3)
end

return DisabledOverlay