local parent = script.Parent.Parent
local ChatSettings = require(parent:WaitForChild("ChatSettings"))
local Util = require(script.Parent:WaitForChild("Util"))

function CreateMeCommandChannelEchoMessageLabel(data)
	local message = data.Message
	local originalChannel = data.OriginalChannel
	local extraData = data.ExtraData or {}
	local font = extraData.Font or Enum.Font.SourceSansBold
	local fontSize = extraData.FontSize or ChatSettings.ChatWindowTextSize
	local color = Color3.new(1, 1, 1)
	local v = data.FromSpeaker .. " " .. string.sub(message, 5)

	if not data.IsFiltered then
		local numberOfUnderscores = Util:GetNumberOfUnderscores(v, font, fontSize)
		string.rep("_", numberOfUnderscores)
	end

	local v2 = string.format("{%s}", originalChannel)
	local v3 = Util:GetNumberOfSpaces(v2, font, fontSize) + 1
	local baseMessage, v5 = Util:CreateBaseMessage(string.rep(" ", v3) .. message, font, fontSize, color)
	Util:AddChannelButtonToBaseMessage(v5, v2, v5.TextColor3)

	local function UpdateTextFunction(p)
		v5.Text = string.rep(" ", v3) .. p.FromSpeaker .. " " .. string.sub(p.Message, 5)
	end

	local function GetHeightFunction()
		return Util:GetMessageHeight(v5, baseMessage)
	end

	local v6 = {
		Text_TargetTransparency = 0,
		Text_CurrentTransparency = 0,
		Text_NormalizedExptValue = 0,
		TextStroke_TargetTransparency = 0.75,
		TextStroke_CurrentTransparency = 0.75,
		TextStroke_NormalizedExptValue = 1
	}

	local function FadeInFunction(p, object)
		v6.Text_TargetTransparency = 0
		v6.TextStroke_TargetTransparency = 0.75
		v6.Text_NormalizedExptValue = object:NormalizedDefaultExptValueInSeconds(p)
		v6.TextStroke_NormalizedExptValue = object:NormalizedDefaultExptValueInSeconds(p)
	end

	local function FadeOutFunction(p, object)
		v6.Text_TargetTransparency = 1
		v6.TextStroke_TargetTransparency = 1
		v6.Text_NormalizedExptValue = object:NormalizedDefaultExptValueInSeconds(p)
		v6.TextStroke_NormalizedExptValue = object:NormalizedDefaultExptValueInSeconds(p)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function AnimGuiObjects()
		v5.TextTransparency = v6.Text_CurrentTransparency
		v5.TextStrokeTransparency = v6.TextStroke_CurrentTransparency
	end

	local function UpdateAnimFunction(p, object)
		v6.Text_CurrentTransparency = object:Expt(
			v6.Text_CurrentTransparency,
			v6.Text_TargetTransparency,
			v6.Text_NormalizedExptValue,
			p
		)
		v6.TextStroke_CurrentTransparency = object:Expt(
			v6.TextStroke_CurrentTransparency,
			v6.TextStroke_TargetTransparency,
			v6.TextStroke_NormalizedExptValue,
			p
		)
		AnimGuiObjects() -- equivalent call inferred; original call site unknown
	end

	return {
		[Util.KEY_BASE_FRAME] = baseMessage,
		[Util.KEY_UPDATE_TEXT_FUNC] = UpdateTextFunction,
		[Util.KEY_GET_HEIGHT] = GetHeightFunction,
		[Util.KEY_FADE_IN] = FadeInFunction,
		[Util.KEY_FADE_OUT] = FadeOutFunction,
		[Util.KEY_UPDATE_ANIMATION] = UpdateAnimFunction
	}
end

return {
	[Util.KEY_MESSAGE_TYPE] = "MeCommandChannelEchoMessage",
	[Util.KEY_CREATOR_FUNCTION] = CreateMeCommandChannelEchoMessageLabel
}