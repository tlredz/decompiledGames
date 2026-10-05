local React = require(game.ReplicatedStorage.Packages.React)
local BuildInfo = require(game.ReplicatedStorage.BuildInfo)
local useCurrentSea = require(game.ReplicatedStorage.React.Hooks.useCurrentSea)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	local v = useCurrentSea() or "other"
	local v2

	if BuildInfo.VERSION == "v0.0.0" and BuildInfo.CORE_BRANCH ~= "live" then
		v2 = BuildInfo.COMMIT_SHA:lower()
	else
		v2 = BuildInfo.VERSION:lower()
	end

	return createElement("TextLabel", RobloxTypes.mergeTextLabel({
		AutoLocalize = false,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
		TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		TextStrokeTransparency = CONSTANTS.ALPHA.HALF,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = `{v2}{BuildInfo.CORE_BRANCH == "live" and "" or `-{BuildInfo.CORE_BRANCH:lower()}`}-{v} : {game.JobId:sub(1, 8)}`
	}, p))
end