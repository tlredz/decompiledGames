local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

while not localPlayer do
	Players.ChildAdded:wait()
	localPlayer = Players.LocalPlayer
end

local parent = script.Parent.Parent
local ChatSettings = require(parent:WaitForChild("ChatSettings"))
local ChatConstants = require(parent:WaitForChild("ChatConstants"))
local Util = require(script.Parent:WaitForChild("Util"))

function CreateMessageLabel(data, p)
	local fromSpeaker = data.FromSpeaker
	local _ = data.Message
	local extraData = data.ExtraData or {}
	local font = extraData.Font or ChatSettings.DefaultFont
	local textSize = extraData.TextSize or ChatSettings.ChatWindowTextSize
	local nameColor = extraData.NameColor or ChatSettings.DefaultNameColor
	local chatColor = extraData.ChatColor or ChatSettings.DefaultMessageColor
	local channelColor = extraData.ChannelColor or chatColor
	local v = string.format("[%s]:", fromSpeaker)
	Util:GetStringTextBounds(v, font, textSize)
	local v2 = Util:GetNumberOfSpaces(v, font, textSize) + 1
	local baseMessage, v3 = Util:CreateBaseMessage("", font, textSize, chatColor)
	local v4 = Util:AddNameButtonToBaseMessage(v3, nameColor, v, fromSpeaker)
	local v5

	if p ~= data.OriginalChannel then
		local originalChannel = data.OriginalChannel

		if data.FromSpeaker ~= localPlayer.Name then
			originalChannel = string.format("From %s", data.FromSpeaker)
		end

		local v6 = string.format("{%s}", originalChannel)
		v5 = Util:AddChannelButtonToBaseMessage(v3, channelColor, v6, data.OriginalChannel)
		v4.Position = UDim2.new(0, v5.Size.X.Offset + Util:GetStringTextBounds(" ", font, textSize).X, 0, 0)
		v2 = v2 + Util:GetNumberOfSpaces(v6, font, textSize) + 1
	end

	local function UpdateTextFunction(data2)
		if data.IsFiltered then
			v3.Text = string.rep(" ", v2) .. data2.Message
		else
			v3.Text = string.rep(" ", v2) .. string.rep("_", data2.MessageLength)
		end
	end

	UpdateTextFunction(data)

	local function GetHeightFunction(p2)
		return Util:GetMessageHeight(v3, baseMessage, p2)
	end

	local v6 = {
		[v4] = {
			TextTransparency = {
				FadedIn = 0,
				FadedOut = 1
			},
			TextStrokeTransparency = {
				FadedIn = 0.75,
				FadedOut = 1
			}
		},
		[v3] = {
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

	if v5 then
		v6[v5] = {
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

	local fadeFunctions, v7, v8 = Util:CreateFadeFunctions(v6)
	return {
		[Util.KEY_BASE_FRAME] = baseMessage,
		[Util.KEY_BASE_MESSAGE] = v3,
		[Util.KEY_UPDATE_TEXT_FUNC] = UpdateTextFunction,
		[Util.KEY_GET_HEIGHT] = GetHeightFunction,
		[Util.KEY_FADE_IN] = fadeFunctions,
		[Util.KEY_FADE_OUT] = v7,
		[Util.KEY_UPDATE_ANIMATION] = v8
	}
end

return {
	[Util.KEY_MESSAGE_TYPE] = ChatConstants.MessageTypeWhisper,
	[Util.KEY_CREATOR_FUNCTION] = CreateMessageLabel
}