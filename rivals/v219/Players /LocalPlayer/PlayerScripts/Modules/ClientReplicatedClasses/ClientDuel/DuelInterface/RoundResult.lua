local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local uDim = UDim2.new(0.5, 0, 0.125, 30)
local uDim2 = UDim2.new(0.175, 58, 0.07, 20)
local RoundResult = {}
RoundResult.__index = RoundResult

function RoundResult.new(duelInterface)
	local self = setmetatable({}, RoundResult)
	self.DuelInterface = duelInterface
	self.Frame = self.DuelInterface.Frame:WaitForChild("Top"):WaitForChild("RoundResult")
	self.Container = self.Frame:WaitForChild("Container")
	self.OutlineFrame = self.Container:WaitForChild("Outline")
	self.OutlineUIStroke = self.OutlineFrame:WaitForChild("UIStroke")
	self.ShineFrame = self.Container:WaitForChild("Shine"):WaitForChild("Frame")
	self.Background = self.Container:WaitForChild("Background")
	self.BackgroundTitle = self.Background:WaitForChild("Title")
	self.BackgroundStatus = self.Background:WaitForChild("Status")
	self.Background2 = self.Container:WaitForChild("Background2")
	self._destroyed = false
	self._round_result_hash = 0
	self:_Init()
	return self
end

function RoundResult:Play(p)
	self._round_result_hash += 1
	local _round_result_hash = self._round_result_hash
	local v

	if p == nil then
		v = "Tie"
	elseif not self.DuelInterface.ClientDuel.LocalDueler then
		v = "Win"
	elseif self.DuelInterface.ClientDuel.LocalDueler and p == self.DuelInterface.ClientDuel.LocalDueler:Get("TeamID") then
		v = "Win"
	else
		v = "Lose"
	end

	self.Frame.Size = uDim2
	self.Frame.Position = uDim
	self.OutlineFrame.Size = UDim2.new(1, 0, 1, 0)
	self.OutlineUIStroke.Thickness = 0
	self.ShineFrame.Position = UDim2.new(-0.5, 0, 0.5, 0)
	self.BackgroundTitle.TextTransparency = 0
	self.BackgroundStatus.TextTransparency = 0
	self.BackgroundTitle.Text = (self.DuelInterface.ClientDuel.LocalDueler or not p) and "ROUND" or DuelLibrary.TeamsByID[p].TeamName
	local backgroundStatus = self.BackgroundStatus
	local text

	if self.DuelInterface.ClientDuel.LocalDueler then
		text = v == "Win" and "WON" or v == "Lose" and "LOST" or "DRAW"
	else
		text = p and "WON" or "DRAW"
	end

	backgroundStatus.Text = text
	local background2 = self.Background2
	local imageColor

	if self.DuelInterface.ClientDuel.LocalDueler then
		imageColor = v == "Win" and Color3.fromRGB(67, 214, 59) or v == "Lose" and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(
			150,
			150,
			150
		)
	else
		imageColor = DuelLibrary:GetTeamColor(p)
	end

	background2.ImageColor3 = imageColor
	self.Background2.ImageTransparency = 0
	self.Frame.Visible = true
	self.DuelInterface:CreateSound(
		v == "Win" and "rbxassetid://16810041280" or v == "Lose" and "rbxassetid://16810321565" or "rbxassetid://16810087814",
		1.5,
		1,
		script,
		true,
		5
	)

	if v == "Win" then
		self.Frame.Size = UDim2.new()
		task.spawn(Utility.RenderstepForLoop, Utility, 0, 100, 4, function(p2)
			if self._round_result_hash ~= _round_result_hash then
				return true
			end

			local v4 = 1 + 2.70158 * (p2 / 100 - 1) ^ 3 + 1.70158 * (p2 / 100 - 1) ^ 2
			self.Frame.Position = uDim + UDim2.new(0, 0, 0.15 * (1 - v4), 0)
		end)
		Utility:RenderstepForLoop(0, 100, 4, function(p2)
			if self._round_result_hash ~= _round_result_hash then
				return true
			end

			local v4 = p2 / 100
			self.Frame.Size = UDim2.new(
				uDim2.X.Scale * v4,
				uDim2.X.Offset * v4,
				uDim2.Y.Scale * v4,
				uDim2.Y.Offset * v4
			)
		end)

		if self._round_result_hash ~= _round_result_hash then
			return
		end

		Utility:RenderstepForLoop(0, 100, 5, function(p2)
			if self._round_result_hash ~= _round_result_hash then
				return true
			end

			local v4 = 1 - (1 - p2 / 100) ^ 4
			self.OutlineUIStroke.Thickness = 12 * v4
		end)

		if self._round_result_hash ~= _round_result_hash then
			return
		end

		Utility:RenderstepForLoop(0, 100, 2, function(p2)
			if self._round_result_hash ~= _round_result_hash then
				return true
			end

			local v4 = 1 - (1 - p2 / 100) ^ 4
			local v5 = 12 * (1 - v4)
			self.OutlineUIStroke.Thickness = v5 < 0.5 and 0 or v5
			self.OutlineFrame.Size = UDim2.new(1, 12 * v4 * 1.5, 1, 12 * v4 * 1.5)
		end)

		if self._round_result_hash ~= _round_result_hash then
			return
		end

		Utility:RenderstepForLoop(0, 100, 2, function(p2)
			if self._round_result_hash ~= _round_result_hash then
				return true
			end

			local v4 = 1 - (1 - p2 / 100) ^ 2
			self.ShineFrame.Position = UDim2.new(-0.5 + 2 * v4, 0, 0.5, 0)
		end)
		wait(2)

		if self._round_result_hash ~= _round_result_hash then
			return
		end

		Utility:RenderstepForLoop(0, 100, 2, function(p2)
			if self._round_result_hash ~= _round_result_hash then
				return true
			end

			local v4 = (p2 / 100) ^ 4
			self.BackgroundTitle.TextTransparency = v4
			self.BackgroundStatus.TextTransparency = v4
			self.Background2.ImageTransparency = v4
		end)

		if self._round_result_hash ~= _round_result_hash then
			return
		end

		self.Frame.Visible = false
	elseif v == "Lose" then
		Utility:RenderstepForLoop(0, 100, 2, function(p2)
			if self._round_result_hash ~= _round_result_hash then
				return true
			end

			local v4 = 1 - (1 - p2 / 100) ^ 2
			local v5 = 20 * (1 - (p2 / 100) ^ 2)
			self.Frame.Position = uDim + UDim2.new(
				0,
				v5 * math.random(),
				-0.025 * (1 - v4),
				30 + v5 * 0.25 * math.random()
			)
			self.BackgroundTitle.TextTransparency = 1 - v4
			self.BackgroundStatus.TextTransparency = 1 - v4
			self.Background2.ImageTransparency = 1 - v4
		end)
		wait(3)

		if self._round_result_hash ~= _round_result_hash then
			return
		end

		Utility:RenderstepForLoop(0, 100, 1, function(p2)
			if self._round_result_hash ~= _round_result_hash then
				return true
			end

			local v4 = (p2 / 100) ^ 4
			self.BackgroundTitle.TextTransparency = v4
			self.BackgroundStatus.TextTransparency = v4
			self.Background2.ImageTransparency = v4
		end)

		if self._round_result_hash ~= _round_result_hash then
			return
		end

		self.Frame.Visible = false
	elseif v == "Tie" then
		Utility:RenderstepForLoop(0, 100, 2, function(p2)
			if self._round_result_hash ~= _round_result_hash then
				return true
			end

			local v4 = 1 - (1 - p2 / 100) ^ 4
			self.BackgroundTitle.TextTransparency = 1 - v4
			self.BackgroundStatus.TextTransparency = 1 - v4
			self.Background2.ImageTransparency = 1 - v4
		end)
		wait(3)

		if self._round_result_hash ~= _round_result_hash then
			return
		end

		Utility:RenderstepForLoop(0, 100, 2, function(p2)
			if self._round_result_hash ~= _round_result_hash then
				return true
			end

			local v4 = (p2 / 100) ^ 4
			self.BackgroundTitle.TextTransparency = v4
			self.BackgroundStatus.TextTransparency = v4
			self.Background2.ImageTransparency = v4
		end)

		if self._round_result_hash ~= _round_result_hash then
			return
		end

		self.Frame.Visible = false
	end
end

function RoundResult:UpdateVisibility()
	self.Container.Visible = not (self.DuelInterface:IsPageOpen() or self.DuelInterface.Scoreboard:IsOpen() or self.DuelInterface.Voting:IsOpen())
end

function RoundResult:Destroy()
	self._destroyed = true
	self._round_result_hash += 1
end

function RoundResult:_Init()
	self.DuelInterface.Scoreboard.VisibilityChanged:Connect(function()
		self:UpdateVisibility()
	end)
	self.DuelInterface.Voting.VisibilityChanged:Connect(function()
		self:UpdateVisibility()
	end)
end

return RoundResult