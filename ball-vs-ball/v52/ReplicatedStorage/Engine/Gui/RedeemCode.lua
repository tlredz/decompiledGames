local RedeemCodeService = require(script.Parent.Parent.Service.RedeemCodeService)
local RedeemCode = {}

function RedeemCode.Init()
	RedeemCodeService.client.init()
end

function RedeemCode.GetIcon()
	return RedeemCodeService.client.getIcon()
end

function RedeemCode.SetTopbarEnabled(flag: boolean)
	RedeemCodeService.client.setTopbarEnabled(flag)
end

return RedeemCode