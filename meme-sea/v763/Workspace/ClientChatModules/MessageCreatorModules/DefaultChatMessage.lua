local parent = script.Parent.Parent
local ChatSettings = require(parent:WaitForChild("ChatSettings"))
local ChatConstants = require(parent:WaitForChild("ChatConstants"))
local Util = require(script.Parent:WaitForChild("Util"))
local Chat = game:GetService("Chat")
local titleModule = require(Chat.titleModule)

function CreateMessageLabel(data, p)
	local fromSpeaker = data.FromSpeaker
	local _ = data.Message
	local extraData = data.ExtraData or {}
	local font = extraData.Font or ChatSettings.DefaultFont
	local textSize = extraData.TextSize or ChatSettings.ChatWindowTextSize
	local nameColor = extraData.NameColor or ChatSettings.DefaultNameColor
	local chatColor = extraData.ChatColor or ChatSettings.DefaultMessageColor
	local channelColor = extraData.ChannelColor or chatColor
	local Players = game:GetService("Players")
	local v2 = titleModule(Players:FindFirstChild((tostring(fromSpeaker))))
	local v3

	if v2 then
		v3 = string.format(v2.title .. " %s:", fromSpeaker)
		nameColor = v2.color
		chatColor = v2.color
	else
		v3 = string.format("%s:", fromSpeaker)
	end

	Util:GetStringTextBounds(v3, font, textSize)
	local v4 = Util:GetNumberOfSpaces(v3, font, textSize) + 1
	local baseMessage, v5 = Util:CreateBaseMessage("", font, textSize, chatColor)
	local v6 = Util:AddNameButtonToBaseMessage(v5, nameColor, v3, fromSpeaker)
	local v7

	if p ~= data.OriginalChannel then
		local v8 = string.format("{%s}", data.OriginalChannel)
		v7 = Util:AddChannelButtonToBaseMessage(v5, channelColor, v8, data.OriginalChannel)
		v6.Position = UDim2.new(0, v7.Size.X.Offset + Util:GetStringTextBounds(" ", font, textSize).X, 0, 0)
		v4 = v4 + Util:GetNumberOfSpaces(v8, font, textSize) + 1
	end

	local function UpdateTextFunction(data2)
		if data.IsFiltered then
			v5.Text = string.rep(" ", v4) .. data2.Message
		else
			v5.Text = string.rep(" ", v4) .. string.rep("_", data2.MessageLength)
		end
	end

	UpdateTextFunction(data)

	local function GetHeightFunction(p2)
		return Util:GetMessageHeight(v5, baseMessage, p2)
	end

	local v8 = {
		[v6] = {
			TextTransparency = {
				FadedIn = 0,
				FadedOut = 1
			},
			TextStrokeTransparency = {
				FadedIn = 0.75,
				FadedOut = 1
			}
		},
		[v5] = {
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

	if v7 then
		v8[v7] = {
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

	local fadeFunctions, v9, v10 = Util:CreateFadeFunctions(v8)
	return {
		[Util.KEY_BASE_FRAME] = baseMessage,
		[Util.KEY_BASE_MESSAGE] = v5,
		[Util.KEY_UPDATE_TEXT_FUNC] = UpdateTextFunction,
		[Util.KEY_GET_HEIGHT] = GetHeightFunction,
		[Util.KEY_FADE_IN] = fadeFunctions,
		[Util.KEY_FADE_OUT] = v9,
		[Util.KEY_UPDATE_ANIMATION] = v10
	}
end

return {
	[Util.KEY_MESSAGE_TYPE] = ChatConstants.MessageTypeDefault,
	[Util.KEY_CREATOR_FUNCTION] = CreateMessageLabel
}