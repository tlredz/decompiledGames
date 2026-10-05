local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.Modules.Utility)
local MatchPoint = {}
MatchPoint.__index = MatchPoint

function MatchPoint.new(duelInterface)
	local self = setmetatable({}, MatchPoint)
	self.DuelInterface = duelInterface
	self.Frame = self.DuelInterface.Frame:WaitForChild("Top"):WaitForChild("MatchPoint")
	self.Background = self.Frame:WaitForChild("Background")
	self.Title = self.Frame:WaitForChild("Title")
	self._destroyed = false
	self._match_point_hash = 0
	self:_Init()
	return self
end

function MatchPoint:Play(p)
	self._match_point_hash += 1

	if self.DuelInterface.ClientDuel:Get("MatchPointVisualDisabled") then
		return
	end

	local _match_point_hash = self._match_point_hash
	self.DuelInterface:CreateSound(
		p and "rbxassetid://17467242617" or "rbxassetid://17026600996",
		p and 1.5 or 1,
		1,
		script,
		true,
		15
	)
	self.DuelInterface.Timer:SetVisible(false)
	self.DuelInterface.Scores:SetVisible(false)
	self.Frame.Visible = true
	self.Frame.GroupTransparency = 0
	self.Frame.Position = UDim2.new(0.5, 0, 0.02, 5)
	self.Background.Size = p and UDim2.new(0.66, 0, 0.5, 0) or UDim2.new(0.6, 0, 0.5, 0)
	self.Title.Text = p and "SUDDEN DEATH" or "MATCH POINT"
	self:_UpdateTextBounds()
	self.Frame:TweenPosition(UDim2.new(0.5, 0, 0.0425, 10), "Out", "Quint", 2, true, function()
		Utility:RenderstepForLoop(0, 100, 2, function(p2)
			if _match_point_hash ~= self._match_point_hash then
				return true
			end

			self.Frame.GroupTransparency = 1 - (1 - p2 / 100) ^ 4
		end)

		if _match_point_hash ~= self._match_point_hash then
			return
		end

		self.DuelInterface.Timer:SetVisible(true)
		self.DuelInterface.Scores:SetVisible(true)
		self.Frame.Visible = false
	end)
end

function MatchPoint:Destroy()
	self._destroyed = true
	self._match_point_hash += 1
end

function MatchPoint:_UpdateTextBounds()
	self.Background.Size = UDim2.new(0.1, self.Title.TextBounds.X, 0.5, 0)
end

function MatchPoint:_Init()
	self.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateTextBounds()
	end)
	self:_UpdateTextBounds()
end

return MatchPoint