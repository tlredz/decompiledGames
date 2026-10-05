local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local BountyLibrary = require(ReplicatedStorage.Modules.BountyLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules.RewardSlot)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local notificationSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("NotificationSlot")
local NotificationSlot = {}
NotificationSlot.__index = NotificationSlot

function NotificationSlot.new(value, value2, first_icon, second_icon, p)
	local self = setmetatable({}, NotificationSlot)
	self.Frame = notificationSlot:Clone()
	self._creation_time = p or tick()
	self._title = value or ""
	self._description = value2 or ""
	self._first_icon = first_icon
	self._second_icon = second_icon
	self._first_reward_info = typeof(self._first_icon) == "table" and self._first_icon
	self._second_reward_info = typeof(self._second_icon) == "table" and self._second_icon
	self._cleanup = {}
	self:_Init()
	return self
end

function NotificationSlot:SetParent(parent)
	self.Frame.Parent = parent
end

function NotificationSlot:PlaySound(p2)
	if p2 then
		Utility:CreateSound(p2, 1.5, 1, script, true, 5)
	elseif self._second_reward_info and BountyLibrary.Rewards[self._second_reward_info.Name] then
		Utility:CreateSound("rbxassetid://17770244373", 1.5, 1, script, true, 5)
	elseif self._second_reward_info and CosmeticLibrary.Rewards[self._second_reward_info.Name] and CosmeticLibrary.Rewards[self._second_reward_info.Name].Type == "Weapon" then
		Utility:CreateSound("rbxassetid://17769583566", 1.5, 1, script, true, 5)
	elseif self._second_reward_info and CosmeticLibrary.Rewards[self._second_reward_info.Name] then
		Utility:CreateSound("rbxassetid://17769583339", 1.5, 1, script, true, 5)
	elseif self._second_reward_info and self._second_reward_info.Weapon == "IsUniversal" then
		Utility:CreateSound("rbxassetid://17769583566", 1.5, 1, script, true, 5)
	elseif self._second_reward_info then
		Utility:CreateSound("rbxassetid://17769583804", 1.5, 1, script, true, 5)
	else
		Utility:CreateSound("rbxassetid://17769893181", 1.5, 1, script, true, 5)
	end
end

function NotificationSlot.PlayGlow(p)
	task.spawn(Utility.RenderstepForLoop, Utility, 0, 100, 1, function(p2)
		local imageTransparency = p2 / 100
		p.Frame.Visuals.Glow.ImageTransparency = imageTransparency
	end)
end

function NotificationSlot:PlaySize(value, duration)
	local v = value or 1
	self.Frame.Size = UDim2.new(1.1 * v, 0, 1.1 * v, 0)
	self.Frame:TweenSize(UDim2.new(1 * v, 0, 1 * v, 0), "Out", "Back", 0.25, true)

	if duration then
		task.delay(duration, function()
			local Inset = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Inset)
			self.Frame.Visuals.ClipsDescendants = true
			self.Frame:TweenSize(UDim2.new(0.13333333333333333 * v, 0, 1 * v, 0), "In", "Quint", 0.5, true, function()
				local notificationGoal = Inset.MainBar:GetNotificationGoal()
				Utility:RenderstepForLoop(0, 100, 7.5, function(p)
					local v2 = p / 100
					local v3 = notificationGoal.Frame.AbsolutePosition + notificationGoal.Frame.AbsoluteSize / 2 - (self.Frame.AbsolutePosition + self.Frame.AbsoluteSize / 2)
					self.Frame.Size = UDim2.new(0.13333333333333333 * (1 - v2) * v, 0, 1 * (1 - v2) * v, 0)
					self.Frame.Visuals.Position = UDim2.new(0.5, v3.X * v2, 0.5, v3.Y * v2)
				end)
				notificationGoal:PlayJiggleEffect()
				self:Destroy()
			end)
		end)
	end
end

function NotificationSlot:UpdateAge()
	local v = math.floor(tick() - self._creation_time)
	self.Frame.Visuals.Container.Age.Visible = true
	self.Frame.Visuals.Container.Age.Title.Text = v < 1 and "just now" or Utility:TimeFormat2(v, true) .. " ago"
end

function NotificationSlot:Destroy()
	for _, v in pairs(self._cleanup) do
		v:Destroy()
	end

	self._cleanup = {}
	self.Frame:Destroy()
end

function NotificationSlot:_Setup()
	self.Frame.Visuals.Container.Title.Text = self._title or ""
	self.Frame.Visuals.Container.Description.Text = self._description or ""
	self.Frame.Visuals.Container.FirstIcon.Image = typeof(self._first_icon) ~= "string" and "" or self._first_icon or ""
	self.Frame.Visuals.Container.SecondIcon.Image = typeof(self._second_icon) ~= "string" and "" or self._second_icon or ""
	self.Frame.Visuals.Background.BackgroundColor3 = UILibrary.BUTTON_BACKGROUND_COLOR
	self.Frame.Visuals.Background.BackgroundTransparency = UILibrary.BUTTON_BACKGROUND_TRANSPARENCY

	if self._first_reward_info then
		if CosmeticLibrary.Cosmetics[self._first_reward_info.Name] then
			self._first_reward_info.Quantity = nil
		end

		local v = RewardSlot.new(self._first_reward_info)
		v:SetParent(self.Frame.Visuals.Container.FirstReward)
		table.insert(self._cleanup, v)
	end

	if self._second_reward_info then
		if CosmeticLibrary.Cosmetics[self._second_reward_info.Name] then
			self._second_reward_info.Quantity = nil
		end

		local v = RewardSlot.new(self._second_reward_info)
		v:SetParent(self.Frame.Visuals.Container.SecondReward)
		table.insert(self._cleanup, v)
	end
end

function NotificationSlot:_Init()
	self:_Setup()
end

return NotificationSlot