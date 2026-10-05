local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")
game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
game:GetService("GuiService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

local TitleData = require(ReplicatedStorage.Shared.TitleData)
local CoreCall = require(ReplicatedStorage:WaitForChild("ClientGameModules"):WaitForChild("CoreCall"))
local remotes = ReplicatedStorage.Remotes

if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
	function TextChatService.OnBubbleAdded(p, p2)
		if p.TextSource then
			local playerByUserId = Players:GetPlayerByUserId(p.TextSource.UserId)

			if not playerByUserId then
				return
			end

			local chat_Tag = playerByUserId:GetAttribute("Chat_Tag")
			local v = nil

			for _, v3 in TitleData do
				if v3.Name ~= chat_Tag then
					continue
				end

				v = v3
				break
			end

			local bubbleChatMessageProperties = Instance.new("BubbleChatMessageProperties")

			if v and v.Chat then
				bubbleChatMessageProperties.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
				bubbleChatMessageProperties.TextColor3 = v.Chat.Color
			else
				bubbleChatMessageProperties.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				bubbleChatMessageProperties.TextColor3 = Color3.fromRGB(0, 0, 0)
			end

			return bubbleChatMessageProperties
		elseif p2 and p2.Parent and p2.Parent:GetAttribute("1x1x1x1") then
			return (Instance.new("BubbleChatMessageProperties"))
		end
	end

	local function updateBubbleDistance()
		if workspace:GetAttribute("CurrentlySelectedMode") == "RobloxClassic" then
			TextChatService.BubbleChatConfiguration.MaxDistance = 500
			TextChatService.BubbleChatConfiguration.MinimizeDistance = 500
		else
			TextChatService.BubbleChatConfiguration.MaxDistance = 100
			TextChatService.BubbleChatConfiguration.MinimizeDistance = 40
		end
	end

	workspace:GetAttributeChangedSignal("CurrentlySelectedMode"):Connect(updateBubbleDistance)
	task.spawn(updateBubbleDistance)

	TextChatService.OnIncomingMessage = function(data)
		local textSource = data.TextSource

		if textSource and string.find(textSource.Name, "TradeChat") == 1 then
			return
		end

		local textChatMessageProperties = Instance.new("TextChatMessageProperties")

		if data.TextSource then
			local playerByUserId = Players:GetPlayerByUserId(data.TextSource.UserId)

			if not playerByUserId then
				return
			end

			local chat_Tag = playerByUserId:GetAttribute("Chat_Tag")
			local v = nil

			for _, v3 in TitleData do
				if v3.Name ~= chat_Tag then
					continue
				end

				v = v3
				break
			end

			if v and v.Chat then
				textChatMessageProperties.Text = `<font color='#{v.Chat.Color:ToHex()}'>{data.Text}</font>`
			else
				textChatMessageProperties.Text = data.Text
			end

			if playerByUserId:GetAttribute("Chat_PSOwner") then
				textChatMessageProperties.PrefixText ..= ` <font color='#{Color3.fromRGB(97, 36, 166):ToHex()}'>[PS Owner]</font>`
			end

			if v and v.Tag then
				textChatMessageProperties.PrefixText ..= ` <font color='#{v.Tag.Color:ToHex()}'>[{v.Tag.Text}]</font>`
			end

			local chat_Top100 = playerByUserId:GetAttribute("Chat_Top100")

			if chat_Top100 then
				textChatMessageProperties.PrefixText ..= ` <font color='#FFBC00'>[#{chat_Top100}]</font>`
			end

			local clanTag = playerByUserId:GetAttribute("ShowClanTagInChat") and playerByUserId:GetAttribute("ClanTag")

			if clanTag then
				textChatMessageProperties.PrefixText ..= ` <font color='#ffffff'>[{clanTag}]</font>`
			end

			textChatMessageProperties.PrefixText = textChatMessageProperties.PrefixText:gsub("^%s+", "")

			if textChatMessageProperties.PrefixText ~= "" then
				textChatMessageProperties.PrefixText ..= " "
			end

			textChatMessageProperties.PrefixText ..= data.PrefixText
			return textChatMessageProperties
		else
			local _, result = pcall(function()
				return HttpService:JSONDecode(data.Metadata)
			end)

			if result.color then
				textChatMessageProperties.Text = `<font color='#{result.color}'>{data.Text:gsub("%s+$", "")}</font>`
			end

			if data.Text:match("^You are now on the '.*' team.$") then
				textChatMessageProperties.Text = " "
			end

			return textChatMessageProperties
		end
	end

	remotes.SystemMessage.OnClientEvent:Connect(function(p: string, p2)
		TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(p, p2)
	end)
	remotes.TextBubble.OnClientEvent:Connect(function(...)
		TextChatService:DisplayBubble(...)
	end)
	remotes.CreateHint.OnClientEvent:Connect(function(text: string, value: number?)
		local hint = workspace:FindFirstChildWhichIsA("Hint")

		if hint then
			hint:Destroy()
		end

		local hint2 = Instance.new("Hint")
		hint2.Text = text
		Debris:AddItem(hint2, value or 5)
		hint2.Parent = workspace
	end)
else
	local scroller = Players.LocalPlayer.PlayerGui:WaitForChild("Chat"):WaitForChild("Frame"):WaitForChild("ChatChannelParentFrame"):WaitForChild("Frame_MessageLogDisplay"):WaitForChild("Scroller")

	function rainbowText(parent)
		local v = parent:FindFirstChild("UIGradient")

		if not v then
			v = Instance.new("UIGradient")
			v.Parent = parent
		end

		assert(v and v:IsA("UIGradient"))

		while parent.Parent ~= nil do
			for i = 1, 255 do
				local color = Color3.fromHSV(i / 255, 1, 1)
				local color2 = Color3.fromHSV(i / 255, 1, 1)
				v.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, color),
					ColorSequenceKeypoint.new(1, color2)
				})
				task.wait()
			end
		end
	end

	local function setupRainbowMessage(label)
		if not label:IsA("TextLabel") or label:FindFirstChildWhichIsA("TextButton") then
			return
		end

		if string.find(label.Text, "gifted") ~= nil then
			task.spawn(rainbowText, label)
		end

		if label.Text:find("wheel") then
			task.spawn(rainbowText, label)
		end
	end

	remotes.SystemMessage.OnClientEvent:Connect(function(text: string, p2)
		local color

		if p2 then
			color = p2.Color
		end

		local font

		if p2 then
			font = p2.Font
		end

		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = text,
			Color = color,
			Font = font
		})
	end)

	for _, descendant in scroller:GetDescendants() do
		setupRainbowMessage(descendant)
	end

	scroller.DescendantAdded:Connect(function(descendant)
		setupRainbowMessage(descendant)
	end)
end

local success, result = pcall(function()
	return TextChatService:CanUserChatAsync(Players.LocalPlayer.UserId)
end)

if not (success and result) then
	CoreCall(Enum.CoreGuiType.Chat, false)
end