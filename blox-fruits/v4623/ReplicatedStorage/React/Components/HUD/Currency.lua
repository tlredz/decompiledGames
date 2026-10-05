local React = require(game.ReplicatedStorage.Packages.React)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
local CurrencyLabel = require(script.CurrencyLabel)
local useCurrentMoney = require(game.ReplicatedStorage.React.Hooks.Player.useCurrentMoney)
local useFragments = require(game.ReplicatedStorage.React.Hooks.Player.useFragments)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local color = Color3.fromRGB(112, 255, 60)
local color2 = Color3.fromRGB(177, 121, 255)
local createElement = React.createElement
return function(p)
	local v = useCurrentMoney()
	local v2 = useFragments()
	local state, setState = React.useState(nil)
	local v3 = state == nil or state == Enum.GuiState.Idle or v2 and v2 <= 0

	if p.LockTo == "Beli" then
		v3 = true
	elseif p.LockTo == "Fragments" then
		v3 = false
	end

	local v7 = RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		[React.Change.GuiState] = function(p2)
			setState(p2.GuiState)
		end
	}, p)
	local beli

	if v3 then
		beli = createElement(CurrencyLabel, {
			Size = UDim2.fromScale(1, 1),
			Text = not v and "$ ..." or `$ {FormatUtil.commaInteger(v)}`,
			TextColor3 = color
		}) or nil
	end

	local fragments

	if not v3 then
		fragments = createElement(CurrencyLabel, {
			Size = UDim2.fromScale(1, 1),
			Text = not v2 and "" or `{FormatUtil.FRAGMENT_SYMBOL} {FormatUtil.commaInteger(v2)}`,
			RichText = true,
			TextColor3 = color2
		}) or nil
	end

	return createElement("Frame", v7, {
		Beli = beli,
		Fragments = fragments
	})
end