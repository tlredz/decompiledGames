local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local PartyController = require(Players.LocalPlayer.PlayerScripts.Controllers.PartyController)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local v = {
	HoverRatio = UDim2.new(0, 10, 0, 10),
	ReleaseRatio = UDim2.new(0, 10, 0, 10)
}
local Buttons = {}
Buttons.__index = Buttons

function Buttons.new(finalResults)
	local self = setmetatable({}, Buttons)
	self.FinalResults = finalResults
	self.Frame = self.FinalResults.Frame:WaitForChild("Buttons")
	self.BottomRightFrame = self.Frame:WaitForChild("BottomRight")
	self.BottomRightContainer = self.BottomRightFrame:WaitForChild("Container")
	self.ContinueFrame = self.BottomRightContainer:WaitForChild("Continue")
	self.ContinueButton = self.ContinueFrame:WaitForChild("Button")
	self.PlayAgainFrame = self.BottomRightContainer:WaitForChild("PlayAgain")
	self.PlayAgainButton = self.PlayAgainFrame:WaitForChild("Button")
	self.LeaveFrame = self.BottomRightContainer:WaitForChild("Leave")
	self.LeaveButton = self.LeaveFrame:WaitForChild("Button")
	self.LeaveButtonTitle = self.LeaveButton:WaitForChild("Title")
	self.LeaveButtonTitleStroke = self.LeaveButtonTitle:WaitForChild("UIStroke")
	self.LeaveButtonShine = self.LeaveButton:WaitForChild("Shine")
	self.LeaveButtonOutlineUIStroke = self.LeaveButton:WaitForChild("Outline"):WaitForChild("UIStroke")
	self.RematchFrame = self.BottomRightContainer:WaitForChild("Rematch")
	self.RematchButton = self.RematchFrame:WaitForChild("Button")
	self.RematchButtonTitle = self.RematchButton:WaitForChild("Title")
	self.RematchButtonTitleStroke = self.RematchButtonTitle:WaitForChild("UIStroke")
	self.RematchButtonCount = self.RematchButton:WaitForChild("Count")
	self.RematchButtonCountStroke = self.RematchButtonCount:WaitForChild("UIStroke")
	self.RematchButtonShine = self.RematchButton:WaitForChild("Shine")
	self.RematchButtonOutlineUIStroke = self.RematchButton:WaitForChild("Outline"):WaitForChild("UIStroke")
	self.BottomLeftFrame = self.Frame:WaitForChild("BottomLeft")
	self.BottomLeftContainer = self.BottomLeftFrame:WaitForChild("Container")
	self.BackFrame = self.BottomLeftContainer:WaitForChild("Back")
	self.BackButton = self.BackFrame:WaitForChild("Button")
	self._destroyed = false
	self:_Init()
	return self
end

function Buttons:LeaveRequest()
	if not self.FinalResults.Winners:IsFinished() then
		self.FinalResults.Winners:Skip()
	elseif self.FinalResults.DuelInterface.ClientDuel.LocalDueler then
		ReplicatedStorage.Remotes.Duels.LeaveDuel:FireServer()
	else
		SpectateController:Exit()
	end
end

function Buttons:Rematch()
	ReplicatedStorage.Remotes.Duels.Rematch:FireServer()
end

function Buttons:PlayAgain()
	ReplicatedStorage.Remotes.Matchmaking.PlayAgain:FireServer()
end

function Buttons:Continue()
	self.FinalResults:SetPage("Summary")
end

function Buttons:Update()
	self:_UpdateRematchButton()
end

function Buttons:Destroy()
	self._destroyed = true
end

function Buttons:_UpdateRematchButton()
	local rematchCount = self.FinalResults.DuelInterface.ClientDuel:Get("RematchCount")
	local rematchGoal = self.FinalResults.DuelInterface.ClientDuel:Get("RematchGoal")
	local rematchSuccess = self.FinalResults.DuelInterface.ClientDuel:Get("RematchSuccess")
	local enabled = rematchSuccess or rematchCount and rematchGoal and self.FinalResults.DuelInterface.ClientDuel:Get("RematchAvailable")
	local color = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
	local v3 = enabled and 0 or 0.75
	self.RematchButtonOutlineUIStroke.Color = color
	self.RematchButtonShine.ImageColor3 = color
	self.RematchButtonTitle.TextColor3 = color
	self.RematchButtonCount.TextColor3 = color
	self.RematchButtonOutlineUIStroke.Transparency = v3
	self.RematchButtonShine.ImageTransparency = v3
	self.RematchButtonTitle.TextTransparency = v3
	self.RematchButtonCount.TextTransparency = v3
	self.RematchButtonCount.Text = rematchSuccess and "• • •" or enabled and rematchCount .. " / " .. rematchGoal or "Unavailable"
	self.RematchButtonCount.FontFace = enabled and Font.fromId(12187365977, Enum.FontWeight.Heavy) or Font.fromId(
		12187365977,
		Enum.FontWeight.Medium
	)
	self.RematchButtonTitleStroke.Enabled = enabled
	self.RematchButtonCountStroke.Enabled = enabled
end

function Buttons:_UpdateButtonStates()
	local isActive = self.FinalResults:IsActive()
	local isFinished = self.FinalResults.Winners:IsFinished()
	local currentPage = self.FinalResults.CurrentPage
	local v2 = self.FinalResults.DuelInterface.ClientDuel.LocalDueler ~= nil
	local continueFrame = self.ContinueFrame
	local visible

	if isActive then
		if isFinished then
			if currentPage == "Winners" then
				visible = self.FinalResults.Summary:HasDetailsReady()
			else
				visible = false
			end
		else
			visible = isFinished
		end
	else
		visible = isActive
	end

	continueFrame.Visible = visible
	self.RematchFrame.Visible = v2 and not self.ContinueFrame.Visible and isActive and isFinished
	self.PlayAgainFrame.Visible = v2 and not self.ContinueFrame.Visible and isActive and isFinished and CONSTANTS.IS_MATCHMAKING_SERVER and PartyController:IsPartyLeader()
	self.LeaveFrame.Visible = not self.ContinueFrame.Visible and isActive
	self.BackButton.Visible = isActive and isFinished and currentPage == "Summary"
	local color = isFinished and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
	local v4 = isFinished and 0 or 0.75
	self.LeaveButtonTitle.Text = isFinished and "Leave" or "Skip"
	self.LeaveButtonTitle.TextColor3 = color
	self.LeaveButtonShine.ImageColor3 = color
	self.LeaveButtonOutlineUIStroke.Color = color
	self.LeaveButtonTitle.TextTransparency = v4
	self.LeaveButtonShine.ImageTransparency = v4
	self.LeaveButtonOutlineUIStroke.Transparency = v4
	self.LeaveButtonTitleStroke.Enabled = isFinished
end

function Buttons:_Init()
	self.LeaveButton.MouseButton1Click:Connect(function()
		self:LeaveRequest()
	end)
	self.PlayAgainButton.MouseButton1Click:Connect(function()
		self:PlayAgain()
	end)
	self.RematchButton.MouseButton1Click:Connect(function()
		self:Rematch()
	end)
	self.ContinueButton.MouseButton1Click:Connect(function()
		self:Continue()
	end)
	self.BackButton.MouseButton1Click:Connect(function()
		self.FinalResults:SetPage("Winners")
	end)
	self.FinalResults.Activated:Connect(function()
		self:_UpdateButtonStates()
	end)
	self.FinalResults.Winners.Finished:Connect(function()
		if PlayerDataController:GetSetting("Hide HUD") then
			self:LeaveRequest()
		end

		self:_UpdateButtonStates()
	end)
	self.FinalResults.PageChanged:Connect(function()
		self:_UpdateButtonStates()
	end)
	task.defer(self._UpdateButtonStates, self)
	task.defer(self._UpdateRematchButton, self)
	ButtonEffect:Add(self.ContinueButton, nil, v)
	ButtonEffect:Add(self.LeaveButton, nil, v)
	ButtonEffect:Add(self.PlayAgainButton, nil, v)
	ButtonEffect:Add(self.RematchButton, nil, v)
	ButtonEffect:Add(self.BackButton, nil, v)
end

return Buttons