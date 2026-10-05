require(script.Parent.Types)
return {
	MaxOfferItems = 8,
	MinOfferItems = 0,
	MaxOutboundRequests = 3,
	RequestExpireSeconds = 30,
	TradeHistoryCap = 200,
	PlaceholderAvatarImage = "rbxassetid://696413137",
	InfoFeedback = {
		PolicyBlocked = {
			title = "Trading Unavailable",
			description = "Your account policy does not allow item trading.",
			confirmText = "Ok"
		},
		TargetCannotTrade = {
			title = "Cannot Trade",
			description = "This player cannot trade right now.",
			confirmText = "Ok"
		},
		RequestDeclined = {
			title = "Trade Declined",
			description = "Your trade request was declined.",
			confirmText = "Ok"
		},
		AlreadyTrading = {
			title = "Already Trading",
			description = "This user is trading already",
			confirmText = "Ok"
		},
		TradeBanned = {
			title = "Trading Unavailable",
			description = "Your account policy does not allow item trading.",
			confirmText = "Ok"
		},
		TargetTradeBanned = {
			title = "Cannot Trade",
			description = "This player cannot trade right now.",
			confirmText = "Ok"
		},
		TradeCancelled = {
			title = "Trade Cancelled",
			description = "The trade session has been cancelled.",
			confirmText = "Ok"
		},
		TradeSuccess = {
			title = "Trade Complete",
			description = "Your items were exchanged successfully! Check them out in your inventory.",
			confirmText = "Awesome!",
			buttonStyle = "Positive"
		},
		RequestsDisabled = {
			title = "Requests Disabled",
			description = "This player is not accepting trade requests.",
			confirmText = "Ok"
		},
		OutboundCap = {
			title = "Too Many Requests",
			description = "You already have too many pending trade requests.",
			confirmText = "Ok"
		},
		NotInServer = {
			title = "Player Not Found",
			description = "That player is not in this server.",
			confirmText = "Ok"
		}
	}
}