local ChatBubbles = require(script:WaitForChild("ChatBubbles"))
local Duelers = require(script:WaitForChild("Duelers"))
local Teams = require(script:WaitForChild("Teams"))
local Scores = {}
Scores.__index = Scores

function Scores.new(duelInterface)
	local self = setmetatable({}, Scores)
	self.DuelInterface = duelInterface
	self.Frame = self.DuelInterface.Frame:WaitForChild("Top"):WaitForChild("Scores")
	self.ChatBubbles = ChatBubbles.new(self)
	self.Duelers = Duelers.new(self)
	self.Teams = Teams.new(self)
	self._is_visible = true
	self:_Init()
	return self
end

function Scores:GetChatBubbleContainer(p2)
	return self.Duelers:GetChatBubbleContainer(p2) or self.Teams:GetChatBubbleContainer(p2)
end

function Scores:SetVisible(is_visible)
	self._is_visible = is_visible
	self:UpdateVisibility()
end

function Scores:UpdateVisibility()
	self.Frame.Visible = self._is_visible and not (self.DuelInterface:IsPageOpen() or self.DuelInterface.ClientDuel:Get("HideMostDuelInterfaceElements"))
end

function Scores:NewChatMessage(...)
	self.ChatBubbles:NewChatMessage(...)
end

function Scores:Generate()
	self.ChatBubbles:Hide()
	self.Duelers:Generate()
	self.Teams:Generate()
	self.ChatBubbles:Show()
end

function Scores:Destroy()
	self.ChatBubbles:Destroy()
	self.Duelers:Destroy()
	self.Teams:Destroy()
end

function Scores:_Init() end

return Scores