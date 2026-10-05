local parent = script.Parent.Parent
local ChatSettings = require(parent:WaitForChild("ChatSettings"))
local ChatConstants = require(parent:WaitForChild("ChatConstants"))
local Util = require(script.Parent:WaitForChild("Util"))

function CreateSystemMessageLabel(data, p)
	local message = data.Message
	local extraData = data.ExtraData or {}
	local font = extraData.Font or ChatSettings.DefaultFont
	local textSize = extraData.TextSize or ChatSettings.ChatWindowTextSize
	local chatColor = extraData.ChatColor or ChatSettings.DefaultMessageColor
	local channelColor = extraData.ChannelColor or chatColor
	local baseMessage, v = Util:CreateBaseMessage(message, font, textSize, chatColor)
	local v2

	if p ~= data.OriginalChannel then
		local v3 = string.format("{%s}", data.OriginalChannel)
		v2 = Util:AddChannelButtonToBaseMessage(v, channelColor, v3, data.OriginalChannel)
		local v4 = Util:GetNumberOfSpaces(v3, font, textSize) + 1
		v.Text = string.rep(" ", v4) .. message
	end

	local function GetHeightFunction(p2)
		return Util:GetMessageHeight(v, baseMessage, p2)
	end

	local v3 = {
		[v] = {
			TextTransparency = {
				FadedIn = 0,
				FadedOut = 1
			},
			TextStrokeTransparency = {
				FadedIn = 0.75,
				FadedOut = 1
			}
		}
	}

	if v2 then
		v3[v2] = {
			TextTransparency = {
				FadedIn = 0,
				FadedOut = 1
			},
			TextStrokeTransparency = {
				FadedIn = 0.75,
				FadedOut = 1
			}
		}
	end

	local fadeFunctions, v4, v5 = Util:CreateFadeFunctions(v3)
	return {
		[Util.KEY_BASE_FRAME] = baseMessage,
		[Util.KEY_BASE_MESSAGE] = v,
		[Util.KEY_UPDATE_TEXT_FUNC] = nil,
		[Util.KEY_GET_HEIGHT] = GetHeightFunction,
		[Util.KEY_FADE_IN] = fadeFunctions,
		[Util.KEY_FADE_OUT] = v4,
		[Util.KEY_UPDATE_ANIMATION] = v5
	}
end

return {
	[Util.KEY_MESSAGE_TYPE] = ChatConstants.MessageTypeSystem,
	[Util.KEY_CREATOR_FUNCTION] = CreateSystemMessageLabel
}