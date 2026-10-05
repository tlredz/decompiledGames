local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LoginRewardLibrary = require(ReplicatedStorage.Modules.LoginRewardLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules.RewardSlot)
local loginRewardSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("LoginRewardSlot")
local LoginRewards = {}
LoginRewards.__index = LoginRewards

function LoginRewards.new(daily)
	local self = setmetatable({}, LoginRewards)
	self.Daily = daily
	self.Frame = self.Daily.Container:WaitForChild("LoginRewards")
	self.Container = self.Frame:WaitForChild("Container")
	self.SlotsFrame = self.Container:WaitForChild("Slots")
	self._cleanup = {}
	self:_Init()
	return self
end

function LoginRewards:Generate()
	for _, v in pairs(self._cleanup) do
		v:Destroy()
	end

	self._cleanup = {}
	local claimedLoginRewardToday = PlayerDataController:Get("ClaimedLoginRewardToday")
	local loginRewardsClaimed = PlayerDataController:Get("LoginRewardsClaimed")
	local v = math.max(0, (math.ceil((loginRewardsClaimed + (claimedLoginRewardToday and 0 or 1)) / 7 - 1))) * 7 + 1

	for i = v, v + 7 - 1 do
		local loginRewardInfoFromDay = LoginRewardLibrary:GetLoginRewardInfoFromDay(i)
		local visible = i <= loginRewardsClaimed
		local v3 = i == loginRewardsClaimed + 1
		local color

		if v3 and not claimedLoginRewardToday then
			color = Color3.fromRGB(255, 255, 255)
		else
			color = Color3.fromRGB(0, 0, 0)
		end

		local clone = loginRewardSlot:Clone()
		clone.Button.Title.Text = loginRewardInfoFromDay.Title
		clone.Button.Description.Text = visible and "" or loginRewardInfoFromDay.Description ~= "" and loginRewardInfoFromDay.Description or v3 and not claimedLoginRewardToday and "Claim now!" or ""
		clone.Button.Background.BackgroundColor3 = color
		clone.Button.Background.UIStroke.Color = color
		clone.Button.Claimed.Visible = visible
		clone.Parent = self.SlotsFrame:WaitForChild(i - v + 1)
		table.insert(self._cleanup, clone)

		for _, reward in pairs(loginRewardInfoFromDay.Rewards) do
			local v4 = RewardSlot.new(reward)
			v4:SetInteractable(false)
			v4:SetParent(clone.Button.Reward)
			table.insert(self._cleanup, v4)
		end

		if not v3 or claimedLoginRewardToday then
			continue
		end

		clone.Button.MouseButton1Click:Connect(function()
			ReplicatedStorage.Remotes.Data.ClaimLoginReward:FireServer()
		end)
		ButtonEffect:Add(clone.Button, nil, {
			HoverRatio = 1.05,
			ReleaseRatio = 1.05
		})
	end
end

function LoginRewards:Open()
	self:Generate()
end

function LoginRewards:Close()
	self:Generate()
end

function LoginRewards:Setup()
	self:Generate()
end

function LoginRewards:_Init()
	PlayerDataController:GetDataChangedSignal("ClaimedLoginRewardToday"):Connect(function()
		self:Generate()
	end)
	PlayerDataController:GetDataChangedSignal("LoginRewardsClaimed"):Connect(function()
		self:Generate()
	end)
end

return LoginRewards