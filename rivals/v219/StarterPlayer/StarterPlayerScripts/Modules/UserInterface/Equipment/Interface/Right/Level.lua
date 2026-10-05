local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local LootLibrary = require(ReplicatedStorage.Modules.LootLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers.ComplianceController)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules.RewardSlot)
local Level = {}
Level.__index = Level

function Level.new(right)
	local self = setmetatable({}, Level)
	self.Right = right
	self.Frame = self.Right.Container:WaitForChild("Level")
	self.Container = self.Frame:WaitForChild("Container")
	self.BarFrame = self.Container:WaitForChild("Bar")
	self.BarFrameGoal = self.BarFrame:WaitForChild("Goal")
	self.BarFrameLevel = self.BarFrame:WaitForChild("Level")
	self.BarFrameProgress = self.BarFrame:WaitForChild("Progress")
	self.BarFrameContainer = self.BarFrame:WaitForChild("Container")
	self.BarFrameContainerBar = self.BarFrameContainer:WaitForChild("Bar")
	self.ComponentsFrame = self.Container:WaitForChild("Components")
	self.ComponentsLayout = self.ComponentsFrame:WaitForChild("Layout")
	self.NextRewardFrame = self.ComponentsFrame:WaitForChild("NextReward")
	self.NextRewardTitle = self.NextRewardFrame:WaitForChild("Title")
	self.NextRewardContainer = self.NextRewardFrame:WaitForChild("Container")
	self.LevelUpFrame = self.ComponentsFrame:WaitForChild("LevelUp")
	self.LevelUpDescription = self.LevelUpFrame:WaitForChild("Description")
	self.LevelUpButton = self.LevelUpFrame:WaitForChild("Button")
	self.LevelUpButtonPrice = self.LevelUpButton:WaitForChild("Price")
	self._cleanup = {}
	self._double_clicked = false
	self:_Init()
	return self
end

function Level:OnStateChanged()
	self:_SetDoubleClicked(false)
	self:_UpdateInformation()
end

function Level:_SetDoubleClicked(double_clicked)
	self._double_clicked = double_clicked
	self.LevelUpDescription.Text = double_clicked and "Are you sure?" or "Level up now!"
end

function Level:_GetInformation()
	if self.Right.Interface.Equipment:IsCareerPageOpen() then
		local level = PlayerDataController:Get("Level")
		return
			level,
			PlayerDataController:Get("XP"),
			LootLibrary:GetCareerLevelsRewardData(),
			math.ceil((level + 1) / LootLibrary:GetCareerLevelsRewardMilestone()) * LootLibrary:GetCareerLevelsRewardMilestone()
	end

	local weaponData = PlayerDataController:GetWeaponData((self.Right.Interface.Equipment:GetSelectedWeapon()))

	if not weaponData then
		return
	end

	local level = weaponData.Level
	local XP = weaponData.XP
	local nextWeaponLevelReward, v = LootLibrary:GetNextWeaponLevelReward(level, weaponData.Name)
	return level, XP, nextWeaponLevelReward, v
end

function Level:_UpdateInformation()
	for _, v in pairs(self._cleanup) do
		v:Destroy()
	end

	self._cleanup = {}
	local _GetInformation, v, v2, v3 = self:_GetInformation()
	local visible = _GetInformation ~= nil
	self.Frame.Visible = visible

	if not visible then
		return
	end

	local isCareerPageOpen = self.Right.Interface.Equipment:IsCareerPageOpen()
	local xPRequiredToLevelUp = LootLibrary:GetXPRequiredToLevelUp(_GetInformation)
	local v5

	if v2 then
		if v3 then
			if _GetInformation == v3 - 1 then
				v5 = CosmeticLibrary.Rewards[v2.Name]

				if v5 then
					if CosmeticLibrary.Rewards[v2.Name].Type == "Lootbox" then
						v5 = ComplianceController:ArePaidRandomItemsRestricted()
					else
						v5 = false
					end
				end
			else
				v5 = false
			end
		else
			v5 = v3
		end
	else
		v5 = v2
	end

	self.BarFrameGoal.Text = xPRequiredToLevelUp <= v and "" or Utility:PrettyNumber(xPRequiredToLevelUp)
	self.BarFrameProgress.Text = xPRequiredToLevelUp <= v and "" or Utility:PrettyNumber(v)
	self.BarFrameLevel.Text = xPRequiredToLevelUp <= v and "MAX" or Utility:PrettyNumber(_GetInformation)
	self.BarFrameContainer.Size = UDim2.new(math.clamp(v / xPRequiredToLevelUp, 0, 1), 0, 1, 0)
	local levelUpFrame = self.LevelUpFrame
	local visible2 = not isCareerPageOpen

	if visible2 then
		if v < xPRequiredToLevelUp then
			visible2 = not v5
		else
			visible2 = false
		end
	end

	levelUpFrame.Visible = visible2
	self.LevelUpButtonPrice.Text = LootLibrary:GetCostToLevelUp(_GetInformation, v)
	self.NextRewardFrame.Visible = v2 ~= nil
	self.NextRewardTitle.Text = not v3 and "" or "Reward at Level " .. Utility:PrettyNumber(v3)

	if v2 then
		local v7 = RewardSlot.new(v2)
		v7:SetParent(self.NextRewardContainer)
		table.insert(self._cleanup, v7)
	end
end

function Level:_Update()
	local v = self.ComponentsLayout.AbsoluteContentSize.Y > 0 and 1.25 or 1
	self.Frame.Size = UDim2.new(
		1,
		0,
		0,
		(self.ComponentsFrame.AbsolutePosition.Y - self.Frame.AbsolutePosition.Y) * v + self.ComponentsLayout.AbsoluteContentSize.Y
	)
end

function Level:_Init()
	self.ComponentsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_Update()
	end)
	self.LevelUpButton.MouseButton1Click:Connect(function()
		if self._double_clicked then
			self.Right.Interface.Equipment:LevelUpWeapon()
		else
			self:_SetDoubleClicked(true)
		end
	end)
	PlayerDataController:GetDataChangedSignal("WeaponInventory"):Connect(function()
		self:_UpdateInformation()
	end)
	PlayerDataController:GetDataChangedSignal("Level"):Connect(function()
		self:_UpdateInformation()
	end)
	self:_Update()
	ButtonEffect:Add(self.LevelUpButton, nil, {
		HoverRatio = UDim2.new(0, 10, 0, 10),
		ReleaseRatio = UDim2.new(0, 10, 0, 10)
	})
end

return Level