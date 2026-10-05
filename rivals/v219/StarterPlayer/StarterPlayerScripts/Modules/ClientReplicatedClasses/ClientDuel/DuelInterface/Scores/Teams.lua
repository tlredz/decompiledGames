local ScoreNeeded = require(script:WaitForChild("ScoreNeeded"))
local Classic = require(script:WaitForChild("Classic"))
local Teams = {}
Teams.__index = Teams

function Teams.new(scores)
	local self = setmetatable({}, Teams)
	self.Scores = scores
	self.Frame = self.Scores.Frame:WaitForChild("Teams")
	self.LeftFrame = self.Frame:WaitForChild("Left")
	self.RightFrame = self.Frame:WaitForChild("Right")
	self.ScoreNeeded = ScoreNeeded.new(self)
	self.Classic = Classic.new(self)
	self:_Init()
	return self
end

function Teams:GetChatBubbleContainer(p2)
	return self.ScoreNeeded:GetChatBubbleContainer(p2) or self.Classic:GetChatBubbleContainer(p2)
end

function Teams:Generate()
	self.ScoreNeeded:Generate()
	self.Classic:Generate()
end

function Teams:Destroy()
	self.ScoreNeeded:Destroy()
	self.Classic:Destroy()
end

function Teams:_Init() end

return Teams