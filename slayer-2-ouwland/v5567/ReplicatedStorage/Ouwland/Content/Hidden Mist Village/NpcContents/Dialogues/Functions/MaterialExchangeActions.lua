local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PopUpCreator

if RunService:IsClient() then
	PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
else
	PopUpCreator = nil
end

local vfxUtility

if RunService:IsClient() then
	vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
else
	vfxUtility = nil
end

local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local flag = false

local function picked(p)
	local exchange = p.Exchange
	return typeof(exchange) == "table" and exchange.Give ~= nil and exchange.Take ~= nil and exchange.Amount ~= nil
end

local MaterialExchangeActions = {}

function MaterialExchangeActions.ToganeExchangeReview(_, p)
	local exchange = p.Exchange
	local v

	if typeof(exchange) == "table" and exchange.Give ~= nil and exchange.Take ~= nil then
		v = exchange.Amount ~= nil
	else
		v = false
	end

	if v then
		return "Togane_ExchangeConfirm"
	end

	return "Togane_ExchangeNothing"
end

function MaterialExchangeActions.ToganeExchange(_, p)
	if flag then
		return "Togane_ExchangeConfirm"
	end

	local exchange = p.Exchange
	local v

	if typeof(exchange) == "table" and exchange.Give ~= nil and exchange.Take ~= nil then
		v = exchange.Amount ~= nil
	else
		v = false
	end

	if not v then
		return "Togane_ExchangeNothing"
	end

	flag = true
	local v2

	if PopUpCreator ~= nil then
		v2 = PopUpCreator.new({
			Type = "LoadingFull"
		}) or nil
	end

	local server = SignalFunction.ToServer("MaterialExchange", p.Exchange)

	if v2 ~= nil then
		v2:Destroy()
	end

	flag = false
	p.Exchange = nil

	if vfxUtility ~= nil then
		vfxUtility.PlaySound(
			ReplicatedStorage.Assets.Sounds.Misc,
			server == true and "Money_Kaching" or "denied_old",
			script,
			true
		)
	end

	if server == true then
		return "Togane_ExchangeDone"
	end

	return "Togane_ExchangeFail"
end

return MaterialExchangeActions