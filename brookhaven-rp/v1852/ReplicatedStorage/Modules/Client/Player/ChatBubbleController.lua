local ChatBubbleController = {}
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local TextService = game:GetService("TextService")
require(ReplicatedStorage.Packages.Remotes)
require(ReplicatedStorage.Packages.Signal)
require(ReplicatedStorage.Packages.Janitor)
local v = {}
local bubbleChat = nil
local template = nil
local clonesByPlayer = {}
local v2 = {}
setmetatable(v2, {
	__mode = "k"
})
local v3 = {}
setmetatable(v3, {
	__mode = "k"
})
local v4 = {}
setmetatable(v4, {
	__mode = "k"
})
local getTextBoundsParams = Instance.new("GetTextBoundsParams")
local font = Font.fromName("Montserrat")
font.Weight = Enum.FontWeight.Medium
getTextBoundsParams.Text = "HelloWorld"
getTextBoundsParams.Font = font
getTextBoundsParams.Size = 16
getTextBoundsParams.Width = 327
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local function onBubbleAddedDispatch(...)
	for _, v5 in v do
		local v6 = v5(...)

		if v6 then
			return v6
		end
	end
end

function ChatBubbleController.ConnectChatBubbleListener(callback)
	v[callback] = callback
	return {
		Disconnect = function()
			v[callback] = nil
		end
	}
end

function ChatBubbleController.Show(player, p, duration: number?)
	if bubbleChat == nil then
		return
	end

	if not clonesByPlayer[player] then
		local clone = template:Clone()
		clone.Parent = bubbleChat
		clonesByPlayer[player] = clone
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local v5 = clonesByPlayer[player]
	v5.Adornee = humanoidRootPart
	v5.Enabled = true
	local bubbleChatList = v5.BubbleChatList
	local bubbleTemplate = bubbleChatList.BubbleTemplate

	if not v2[player] then
		v2[player] = {}
	end

	local v6 = v2[player][p.Text]
	local v7 = v3[player] ~= p.Text and v2[player][v3[player]]

	if v7 then
		v7:Destroy()
		v2[player][v3[player]] = nil
	end

	local v8 = v6 or bubbleTemplate:Clone()

	if not v6 then
		v2[player][p.Text] = v8
	end

	v3[player] = p.Text
	v8.Name = tostring(player.UserId) .. HttpService:GenerateGUID(true)
	v8.Visible = true
	local chatBubbleFrame = v8.ChatBubbleFrame
	local text = chatBubbleFrame:FindFirstChild("Text")
	text.Text = p.Text
	getTextBoundsParams.Text = p.Text
	getTextBoundsParams.Font = text.FontFace
	getTextBoundsParams.Size = text.TextSize
	getTextBoundsParams.RichText = text.RichText
	local maxWidth = chatBubbleFrame:GetAttribute("MaxWidth") or 220
	local minWidth = chatBubbleFrame:GetAttribute("MinWidth") or 28
	getTextBoundsParams.Width = 0
	local v9 = math.clamp(TextService:GetTextBoundsAsync(getTextBoundsParams).X, minWidth, maxWidth)
	getTextBoundsParams.Width = v9 + 1
	local textBoundsAsync = TextService:GetTextBoundsAsync(getTextBoundsParams)
	local uIPadding = chatBubbleFrame:FindFirstChildWhichIsA("UIPadding")
	local v10 = not uIPadding and 0 or uIPadding.PaddingLeft.Offset + uIPadding.PaddingRight.Offset or 0
	local v11 = uIPadding and uIPadding.PaddingTop.Offset + uIPadding.PaddingBottom.Offset or 0
	v8.ChatBubbleFrame.ImageTransparency = 1
	v8.Caret.ImageTransparency = 1
	text.TextTransparency = 1
	text.TextColor3 = p.Color
	v8.Size = UDim2.fromOffset(v9 + v10, 0)

	if v6 then
		v8.Size = UDim2.fromOffset(v9 + 1 + v10, textBoundsAsync.Y + v11)
		v8.ChatBubbleFrame.ImageTransparency = 0
		v8.Caret.ImageTransparency = 0
		text.TextTransparency = 0
	else
		TweenService:Create(v8, tweenInfo, {
			Size = UDim2.fromOffset(v9 + 1 + v10, textBoundsAsync.Y + v11)
		}):Play()
		TweenService:Create(v8.Caret, tweenInfo, {
			ImageTransparency = 0
		}):Play()
		TweenService:Create(v8.ChatBubbleFrame, tweenInfo, {
			ImageTransparency = 0
		}):Play()
		TweenService:Create(text, tweenInfo, {
			TextTransparency = 0
		}):Play()
	end

	v8.Parent = bubbleChatList
	local v12 = v4[player]

	if v12 ~= nil then
		task.cancel(v12)
		v4[player] = nil
	end

	if duration ~= nil and duration > 0 then
		v4[player] = task.delay(duration, function()
			ChatBubbleController.Clear(player)
			v4[player] = nil
		end)
	end
end

function ChatBubbleController.Clear(p)
	if not v2[p] then
		return
	end

	for _, v5 in v2[p] do
		v5:Destroy()
	end

	v2[p] = {}
	v3[p] = nil
end

function ChatBubbleController.FrameworkStart()
	bubbleChat = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("BubbleChat")
	template = bubbleChat:WaitForChild("Template")
	TextChatService.OnBubbleAdded = onBubbleAddedDispatch
end

return ChatBubbleController