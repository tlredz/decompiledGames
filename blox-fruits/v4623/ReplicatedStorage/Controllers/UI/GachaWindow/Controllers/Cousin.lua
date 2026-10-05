local React = require(game.ReplicatedStorage.Packages.React)
local Cousin = require(game.ReplicatedStorage.React.Components.Gacha.Windows.Cousin)
local GachaClient = require(game.ReplicatedStorage.Controllers.GachaClient)
require(game.ReplicatedStorage.Controllers.BannerClient)
require(game.ReplicatedStorage.Modules.Gacha.SharedGachaTypes)
local TextUtil = require(game.ReplicatedStorage.Modules.Util.TextUtil)
require(game.ReplicatedStorage.React.Components.Gacha.Notification)
local useCurrentMoney = require(game.ReplicatedStorage.React.Hooks.Player.useCurrentMoney)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
return function(props)
	local cost = props.Cost
	local v = useCurrentMoney()
	local state, setState = React.useState(nil)
	local state2, setState2 = React.useState(false)
	React.useEffect(function()
		local v2 = false

		if state then
			local v3 = state.Cooldown.RequirementMet and state.Price.RequirementMet and true or false
			v2 = state.Keys.Silver.RequirementMet and true or v3

			if state.PaidRandomItemsRestricted.Value then
				v2 = false
			end
		end

		setState2(v2 == true)
	end, { state })
	React.useEffect(function()
		setState(GachaClient.CheckGachaAsync(props.BoxName))
	end, {
		v,
		props.BoxName,
		props.Keys.Silver,
		props.BannerItem
	})
	return React.createElement(Cousin, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.7, 0.7),
		ZIndex = CONSTANTS.LAYER.RAISED,
		Cost = React.useMemo(function()
			if cost.Value == 0 then
				return {
					Formatted = "FREE",
					Name = cost.Name,
					Value = cost.Value
				}
			end

			if state and state.Keys.Silver.RequirementMet then
				return {
					Formatted = `Keys x{TextUtil.commaValue(state.Keys.Silver.Value)}`,
					Name = "Silver Key",
					Value = state.Keys.Silver.Value
				}
			end

			return {
				Formatted = `${TextUtil.commaValue(cost.Value)}`,
				Value = cost.Value,
				Name = cost.Name
			}
		end, { state }),
		CanPurchase = state2,
		Notification = props.Notification,
		TryPurchase = props.TryPurchase,
		OnClose = props.SetClosed,
		OnCloseFinished = props.Close,
		IsOpen = props.IsOpen,
		BannerItem = props.BannerItem,
		CommonsCrossedOut = props.BannerItem ~= nil,
		CooldownTimeEnds = React.useMemo(function()
			if state and state.Cooldown.RequirementMet == false then
				return state.Cooldown.TimeEnds
			end

			return 0
		end, { state })
	})
end