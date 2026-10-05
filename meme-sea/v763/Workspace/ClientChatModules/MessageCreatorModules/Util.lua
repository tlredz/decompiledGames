local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

while not localPlayer do
	Players.ChildAdded:wait()
	localPlayer = Players.LocalPlayer
end

local parent = script.Parent.Parent
local ChatSettings = require(parent:WaitForChild("ChatSettings"))
local ChatConstants = require(parent:WaitForChild("ChatConstants"))
local v = {}
local class = {}
class.__index = class

function class:GetStringTextBounds(p, p2, p3, p4)
	return TextService:GetTextSize(p, p3, p2, p4 or Vector2.new(10000, 10000))
end

function class:GetMessageHeight(data, p, p2)
	local v2 = p2 or p.AbsoluteSize.X
	return self:GetStringTextBounds(data.Text, data.Font, data.TextSize, Vector2.new(v2, 1000)).Y
end

function class:GetNumberOfSpaces(p, p2, p3)
	local stringTextBounds = self:GetStringTextBounds(p, p2, p3)
	local stringTextBounds2 = self:GetStringTextBounds(" ", p2, p3)
	return (math.ceil(stringTextBounds.X / stringTextBounds2.X))
end

function class:CreateBaseMessage(text, font, textSize, textColor)
	local fromObjectPool = self:GetFromObjectPool("Frame")
	fromObjectPool.Selectable = false
	fromObjectPool.Size = UDim2.new(1, 0, 0, 18)
	fromObjectPool.Visible = true
	fromObjectPool.BackgroundTransparency = 1
	local fromObjectPool2 = self:GetFromObjectPool("TextLabel")
	fromObjectPool2.Selectable = false
	fromObjectPool2.Size = UDim2.new(1, -14, 1, 0)
	fromObjectPool2.Position = UDim2.new(0, 8, 0, 0)
	fromObjectPool2.BackgroundTransparency = 1
	fromObjectPool2.Font = font
	fromObjectPool2.TextSize = textSize
	fromObjectPool2.TextXAlignment = Enum.TextXAlignment.Left
	fromObjectPool2.TextYAlignment = Enum.TextYAlignment.Top
	fromObjectPool2.TextTransparency = 0
	fromObjectPool2.TextStrokeTransparency = 0.75
	fromObjectPool2.TextColor3 = textColor
	fromObjectPool2.TextWrapped = true
	fromObjectPool2.Text = text
	fromObjectPool2.Visible = true
	fromObjectPool2.Parent = fromObjectPool
	return fromObjectPool, fromObjectPool2
end

function class:AddNameButtonToBaseMessage(parent2, textColor, text, p)
	local stringTextBounds = self:GetStringTextBounds(text, parent2.Font, parent2.TextSize)
	local fromObjectPool = self:GetFromObjectPool("TextButton")
	fromObjectPool.Selectable = false
	fromObjectPool.Size = UDim2.new(0, stringTextBounds.X, 0, stringTextBounds.Y)
	fromObjectPool.Position = UDim2.new(0, 0, 0, 0)
	fromObjectPool.BackgroundTransparency = 1
	fromObjectPool.Font = parent2.Font
	fromObjectPool.TextSize = parent2.TextSize
	fromObjectPool.TextXAlignment = parent2.TextXAlignment
	fromObjectPool.TextYAlignment = parent2.TextYAlignment
	fromObjectPool.TextTransparency = parent2.TextTransparency
	fromObjectPool.TextStrokeTransparency = parent2.TextStrokeTransparency
	fromObjectPool.TextColor3 = textColor
	fromObjectPool.Text = text
	fromObjectPool.Visible = true
	fromObjectPool.Parent = parent2
	local mouseButton1ClickConnection = fromObjectPool.MouseButton1Click:connect(function()
		self:NameButtonClicked(fromObjectPool, p)
	end)
	local changedConnection = nil
	changedConnection = fromObjectPool.Changed:connect(function(p2)
		if p2 == "Parent" then
			mouseButton1ClickConnection:Disconnect()
			changedConnection:Disconnect()
		end
	end)
	return fromObjectPool
end

function class:AddChannelButtonToBaseMessage(parent2, textColor, text, p)
	local stringTextBounds = self:GetStringTextBounds(text, parent2.Font, parent2.TextSize)
	local fromObjectPool = self:GetFromObjectPool("TextButton")
	fromObjectPool.Selectable = false
	fromObjectPool.Size = UDim2.new(0, stringTextBounds.X, 0, stringTextBounds.Y)
	fromObjectPool.Position = UDim2.new(0, 0, 0, 0)
	fromObjectPool.BackgroundTransparency = 1
	fromObjectPool.Font = parent2.Font
	fromObjectPool.TextSize = parent2.TextSize
	fromObjectPool.TextXAlignment = parent2.TextXAlignment
	fromObjectPool.TextYAlignment = parent2.TextYAlignment
	fromObjectPool.TextTransparency = parent2.TextTransparency
	fromObjectPool.TextStrokeTransparency = parent2.TextStrokeTransparency
	fromObjectPool.TextColor3 = textColor
	fromObjectPool.Text = text
	fromObjectPool.Visible = true
	fromObjectPool.Parent = parent2
	local mouseButton1ClickConnection = fromObjectPool.MouseButton1Click:connect(function()
		self:ChannelButtonClicked(fromObjectPool, p)
	end)
	local changedConnection = nil
	changedConnection = fromObjectPool.Changed:connect(function(p2)
		if p2 == "Parent" then
			mouseButton1ClickConnection:Disconnect()
			changedConnection:Disconnect()
		end
	end)
	return fromObjectPool
end

function GetWhisperChannelPrefix()
	if ChatConstants.WhisperChannelPrefix then
		return ChatConstants.WhisperChannelPrefix
	end

	return "To "
end

function class:NameButtonClicked(_, childName)
	if not self.ChatWindow then
		return
	end

	if ChatSettings.ClickOnPlayerNameToWhisper then
		local child = Players:FindFirstChild(childName)

		if child and child ~= localPlayer then
			local v2 = GetWhisperChannelPrefix() .. childName

			if self.ChatWindow:GetChannel(v2) then
				self.ChatBar:ResetCustomState()

				if self.ChatWindow:GetTargetMessageChannel() ~= v2 then
					self.ChatWindow:SwitchCurrentChannel(v2)
				end

				self.ChatBar:ResetText()
				self.ChatBar:CaptureFocus()
			elseif not self.ChatBar:IsInCustomState() then
				local v3 = "/w " .. childName
				self.ChatBar:CaptureFocus()
				self.ChatBar:SetText(v3)
			end
		end
	end
end

function class:ChannelButtonClicked(_, p2)
	if not self.ChatWindow then
		return
	end

	if ChatSettings.ClickOnChannelNameToSetMainChannel and self.ChatWindow:GetChannel(p2) then
		self.ChatBar:ResetCustomState()

		if self.ChatWindow:GetTargetMessageChannel() ~= p2 then
			self.ChatWindow:SwitchCurrentChannel(p2)
		end

		self.ChatBar:ResetText()
		self.ChatBar:CaptureFocus()
	end
end

function class:RegisterChatWindow(chatWindow)
	self.ChatWindow = chatWindow
	self.ChatBar = chatWindow:GetChatBar()
end

function class:GetFromObjectPool(className)
	if self.ObjectPool == nil then
		return Instance.new(className)
	end

	return self.ObjectPool:GetInstance(className)
end

function class:RegisterObjectPool(objectPool)
	self.ObjectPool = objectPool
end

function class.CreateFadeFunctions(_, items)
	local v2 = {}

	for k, item in pairs(items) do
		v2[k] = {}

		for k2, v3 in pairs(item) do
			v2[k][k2] = {
				Target = v3.FadedIn,
				Current = k[k2],
				NormalizedExptValue = 1
			}
		end
	end

	local function FadeInFunction(p, object)
		for k, v3 in pairs(v2) do
			for k2, v4 in pairs(v3) do
				v4.Target = items[k][k2].FadedIn
				v4.NormalizedExptValue = object:NormalizedDefaultExptValueInSeconds(p)
			end
		end
	end

	local function FadeOutFunction(p, object)
		for k, v3 in pairs(v2) do
			for k2, v4 in pairs(v3) do
				v4.Target = items[k][k2].FadedOut
				v4.NormalizedExptValue = object:NormalizedDefaultExptValueInSeconds(p)
			end
		end
	end

	local function AnimGuiObjects()
		for currents, v3 in pairs(v2) do
			for k, v4 in pairs(v3) do
				currents[k] = v4.Current
			end
		end
	end

	local function UpdateAnimFunction(p, object)
		for _, v3 in pairs(v2) do
			for _, v4 in pairs(v3) do
				v4.Current = object:Expt(v4.Current, v4.Target, v4.NormalizedExptValue, p)
			end
		end

		AnimGuiObjects()
	end

	return FadeInFunction, FadeOutFunction, UpdateAnimFunction
end

function class.NewBindableEvent(_, name)
	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Name = name
	return bindableEvent
end

function class.RegisterGuiRoot(_) end

function v.new()
	local self = setmetatable({}, class)
	self.ObjectPool = nil
	self.ChatWindow = nil
	self.DEFAULT_MESSAGE_CREATOR = "UnknownMessage"
	self.MESSAGE_CREATOR_MODULES_VERSION = 1
	self.KEY_MESSAGE_TYPE = "MessageType"
	self.KEY_CREATOR_FUNCTION = "MessageCreatorFunc"
	self.KEY_BASE_FRAME = "BaseFrame"
	self.KEY_BASE_MESSAGE = "BaseMessage"
	self.KEY_UPDATE_TEXT_FUNC = "UpdateTextFunction"
	self.KEY_GET_HEIGHT = "GetHeightFunction"
	self.KEY_FADE_IN = "FadeInFunction"
	self.KEY_FADE_OUT = "FadeOutFunction"
	self.KEY_UPDATE_ANIMATION = "UpdateAnimFunction"
	return self
end

return v.new()