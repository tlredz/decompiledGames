local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local TextUtil = require(game.ReplicatedStorage.Modules.Util.TextUtil)
local FreeToPlay = require(game.ReplicatedStorage.React.Components.Gacha.Windows.MagnetEvent26.FreeToPlay)
local v = {
	BoxName = "MagnetEventGacha26",
	Cost = {
		Name = "Magnet Token",
		Value = 500
	}
}
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Currency = UILabs.Number(0, 0, v.Cost.Value, (math.clamp(v.Cost.Value / 10, 1, v.Cost.Value))),
		Cost = UILabs.Choose({
			250,
			500,
			1000,
			9999
		}, 2)
	}
}, function(p)
	local cost = v.Cost
	local state, setState = React.useState({
		Value = nil,
		UID = 1
	})
	local state2, setState2 = React.useState(false)
	local v2 = React.useMemo(function()
		return {
			Name = cost.Name,
			Value = p.controls.Cost
		}
	end, { p.controls.Cost })
	local cost2 = React.useMemo(function()
		local formatted = v2.Value == 0 and "FREE" or `{TextUtil.commaValue(v2.Value)}{` {v2.Name}`}`
		return {
			Name = v2.Name,
			Value = v2.Value,
			Formatted = formatted
		}
	end, { v2 })

	-- equivalent calls inferred from this helper; original call sites unknown
	local function sendNotif(formatted: string?)
		setState({
			Value = formatted,
			UID = state.UID + 1
		})
	end

	React.useEffect(function()
		setState2(p.controls.Currency >= (not v2 and 0 or v2.Value))
	end, { v2, p.controls.Currency })

	local function tryPurchase()
		print("try purchase")
		local v4 = assert(v2).Value - p.controls.Currency
		local v5 = not v4 and "N/A" or TextUtil.commaValue(v4) or "N/A"

		if v2 then
			local v6 = v4 and v4 ~= 1 and "s" or ""
			local v7 = string.sub(v2.Name, #v2.Name) == "s" and "" or v6

			if v4 > 0 then
				sendNotif(`You need {v5} more {v2.Name}{v7} to roll!`) -- equivalent call inferred; original call site unknown
			end
		end
	end

	return createElement(FreeToPlay, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Cost = cost2,
		CanPurchase = state2,
		Notification = state,
		OnClose = function()
			print("close")
		end,
		OpenGacha = function(p2)
			print((`OpenGacha {p2}`))
		end,
		TryPurchase = tryPurchase
	})
end)