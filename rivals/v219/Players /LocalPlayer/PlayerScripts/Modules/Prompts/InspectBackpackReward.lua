local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local ServerOsTime = require(ReplicatedStorage.Modules.ServerOsTime)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("RewardSlot"))
local Prompt = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Prompt"))
local object = setmetatable({}, Prompt)
object.__index = object

function object.new(p)
	local self = setmetatable(Prompt.new(script.Name), object)
	self.ClosePage = Signal.new()
	self.Title = self.PromptFrame:WaitForChild("Title")
	self.ExpireText = self.PromptFrame:WaitForChild("Expire")
	self.ExpireLeftIcon = self.ExpireText:WaitForChild("LeftIcon")
	self.ExpireRightIcon = self.ExpireText:WaitForChild("RightIcon")
	self.Container = self.PromptFrame:WaitForChild("Container")
	self.CloseButton = self.PromptFrame:WaitForChild("Close")
	self.ButtonsFrame = self.PromptFrame:WaitForChild("Buttons")
	self.ViewContentsButton = self.ButtonsFrame:WaitForChild("ViewContents")
	self.UseButton = self.ButtonsFrame:WaitForChild("Use")
	self.Use3Button = self.ButtonsFrame:WaitForChild("Use3")
	self.UseMaxButton = self.ButtonsFrame:WaitForChild("UseMax")
	self.UseMaxButtonText = self.UseMaxButton:WaitForChild("Price")
	self._index = p
	self._reward_data = nil
	self._cosmetic_info = nil
	self._reward_info = nil
	self._reward_slot = nil
	self._expire_hash = 0
	self._is_using = false
	self:_Init()
	return self
end

function object:Use(p)
	if self._is_using or not FighterController.LocalFighter or FighterController.LocalFighter:Get("IsInDuel") or FighterController.LocalFighter:Get("IsInShootingRange") then
		return
	end

	self._is_using = true
	local v = self._reward_info and self._reward_info.Type == "Lootbox"

	if ReplicatedStorage.Remotes.Data.UseUnclaimedReward:InvokeServer(self._index, p) == "Success" then
		if v then
			if self._reward_info and self._reward_info.SoundProfile then
				self.ClosePage:Fire()
			else
				self:CloseRequest()
			end
		end
	elseif v then
		self.OpenPrompt:Fire("ErrorMessage", "Whoops!", "Failed to open, you probably already have everything!")
	elseif self._cosmetic_info and CosmeticLibrary.Types[self._cosmetic_info.Type].IsWeaponCosmetic then
		self.OpenPrompt:Fire(
			"ErrorMessage",
			"Whoops!",
			"Failed to use, this item is probably already unlocked for all possible weapons!"
		)
	else
		self.OpenPrompt:Fire("ErrorMessage", "Whoops!", "Failed to use, this item is probably already unlocked!")
	end

	self._is_using = false
end

function object:Destroy()
	self:_Clear()
	Prompt.Destroy(self)
end

function object:_UpdateTextBounds()
	self.ExpireLeftIcon.Position = UDim2.new(0.5, -self.ExpireText.TextBounds.X / 2, 0.5, 0)
	self.ExpireRightIcon.Position = UDim2.new(0.5, self.ExpireText.TextBounds.X / 2, 0.5, 0)
end

function object:_UpdateExpireText()
	self.ExpireText.Text = not self._reward_data and "" or not self._reward_data.ExpireTime and "" or ServerOsTime:Get() >= self._reward_data.ExpireTime and "This item has expired" or "Expires in " .. Utility:TimeFormat2(self._reward_data.ExpireTime - ServerOsTime:GetRounded())
end

function object:_Clear()
	if self._reward_slot then
		self._reward_slot:Destroy()
		self._reward_slot = nil
	end

	self._expire_hash += 1
end

function object:_Update()
	self:_Clear()
	self._reward_data = PlayerDataController:Get("UnclaimedRewards")[self._index]
	self._cosmetic_info = self._reward_data and CosmeticLibrary.Cosmetics[self._reward_data.Name]
	self._reward_info = self._reward_data and CosmeticLibrary.Rewards[self._reward_data.Name]

	if not self._reward_data then
		task.defer(self.CloseRequest, self)
		return
	end

	local v = self._reward_data.Weapon == "IsRandom" and "Random" or self._reward_data.Weapon == "IsUniversal" and "Universal" or self._reward_data.Weapon
	local quantity = self._reward_data.Quantity or 1
	local title = self.Title
	local type

	if self._cosmetic_info and v then
		type = v .. " " .. self._cosmetic_info.Type
	elseif self._cosmetic_info then
		type = self._cosmetic_info.Type
	else
		type = self._reward_data.Name
	end

	title.Text = type
	self.ExpireText.Visible = self._reward_data.ExpireTime ~= nil
	self.ViewContentsButton.Visible = self._reward_info and self._reward_info.Type == "Lootbox" and true or self._cosmetic_info and CosmeticLibrary.Types[self._cosmetic_info.Type].IsWeaponCosmetic and self._reward_data.Weapon == "IsRandom"
	self.Use3Button.Visible = self.ViewContentsButton.Visible and quantity >= 3
	self.UseMaxButton.Visible = self.ViewContentsButton.Visible and quantity > 3
	self.UseMaxButtonText.Text = "×" .. math.min(CONSTANTS.MAX_BACKPACK_USE_QUANTITY, quantity)
	self._reward_slot = RewardSlot.new(self._reward_data)
	self._reward_slot:SetParent(self.Container)

	if self.ExpireText.Visible then
		task.spawn(function()
			self._expire_hash += 1
			local _expire_hash = self._expire_hash

			while not self._destroyed or _expire_hash ~= self._expire_hash do
				self:_UpdateExpireText()
				wait(1)
			end
		end)
	end
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.UseButton.MouseButton1Click:Connect(function()
		self:Use(1)
	end)
	self.Use3Button.MouseButton1Click:Connect(function()
		self:Use(3)
	end)
	self.UseMaxButton.MouseButton1Click:Connect(function()
		self:Use(CONSTANTS.MAX_BACKPACK_USE_QUANTITY)
	end)
	self.ViewContentsButton.MouseButton1Click:Connect(function()
		if self._reward_data then
			self.OpenPrompt:Fire(
				"InspectLootbox",
				self._reward_data.Name,
				self._reward_data.Weapon,
				"InspectBackpackReward",
				self._index
			)
		end
	end)
	self.ExpireText:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateTextBounds()
	end)
	table.insert(self._connections, PlayerDataController:GetDataChangedSignal("UnclaimedRewards"):Connect(function()
		self:_Update()
	end))
	self:_Update()
	self:_UpdateTextBounds()
	ButtonEffect:Add(self.UseButton)
	ButtonEffect:Add(self.Use3Button)
	ButtonEffect:Add(self.UseMaxButton)
	ButtonEffect:Add(self.CloseButton)
	ButtonEffect:Add(self.ViewContentsButton)
end

return object