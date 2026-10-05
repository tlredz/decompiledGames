local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local HeadHoncho = {}
HeadHoncho.__index = HeadHoncho

function HeadHoncho.new(duelInterface)
	local self = setmetatable({}, HeadHoncho)
	self.DuelInterface = duelInterface
	self.Frame = self.DuelInterface.Frame:WaitForChild("HeadHoncho")
	self.Container = self.Frame:WaitForChild("Container")
	self.HeadHonchoFrame = self.Container:WaitForChild("HeadHoncho")
	self.HeadHonchoBackground = self.HeadHonchoFrame:WaitForChild("Background")
	self.BodyguardFrame = self.Container:WaitForChild("Bodyguard")
	self.BodyguardBackground = self.BodyguardFrame:WaitForChild("Background")
	self:_Init()
	return self
end

function HeadHoncho:Update()
	local v = not (self.DuelInterface.Scoreboard:IsOpen() or self.DuelInterface.Voting:IsOpen() or self.DuelInterface:IsPageOpen() or self.DuelInterface.RoundResult.Frame.Visible)
	local isHeadHoncho

	if self.DuelInterface.ClientDuel.LocalDueler then
		isHeadHoncho = self.DuelInterface.ClientDuel.LocalDueler:Get("IsHeadHoncho")
	end

	local teamColor = DuelLibrary:GetTeamColor(self.DuelInterface.ClientDuel.LocalDueler and self.DuelInterface.ClientDuel.LocalDueler:Get("TeamID"))
	self.Frame.Visible = v and self.DuelInterface.ClientDuel:Get("Status") ~= "GameOver"
	self.HeadHonchoFrame.Visible = isHeadHoncho == true
	self.BodyguardFrame.Visible = isHeadHoncho == false
	self.HeadHonchoBackground.ImageColor3 = teamColor
	self.BodyguardBackground.ImageColor3 = teamColor
end

function HeadHoncho.Destroy(_) end

function HeadHoncho:_Init()
	self.DuelInterface.RoundResult.Frame:GetPropertyChangedSignal("Visible"):Connect(function()
		self:Update()
	end)
	self.DuelInterface.Scoreboard.VisibilityChanged:Connect(function()
		self:Update()
	end)
	self.DuelInterface.Voting.VisibilityChanged:Connect(function()
		self:Update()
	end)
end

return HeadHoncho