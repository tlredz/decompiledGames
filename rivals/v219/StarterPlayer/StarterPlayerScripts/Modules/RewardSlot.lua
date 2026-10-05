local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local ShopLibrary = require(ReplicatedStorage.Modules.ShopLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("WeaponStatusHandler"))
local CosmeticSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("CosmeticSlot"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local rewardBubble = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("RewardBubble")
local rewardSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("RewardSlot")
local RewardSlot = {}
RewardSlot.__index = RewardSlot

function RewardSlot.new(rewardData, ignore_button_effects, is_locked)
	local self = setmetatable({}, RewardSlot)
	self.RewardData = rewardData
	self.CosmeticInfo = CosmeticLibrary.Cosmetics[self.RewardData.Name]
	self.RewardInfo = CosmeticLibrary.Rewards[self.RewardData.Name]
	self.Frame = rewardSlot:Clone()
	self.CosmeticSlot = nil
	self._ignore_button_effects = ignore_button_effects
	self._is_locked = is_locked
	self._key_slot_frame = nil
	self._bubble_hash = 0
	self._bubble_frame = nil
	self._bubble_reward_slot = nil
	self._bubble_connections = {}
	self._bubble_auto_close_delay = nil
	self._on_click_callback = nil
	self:_Init()
	return self
end

function RewardSlot:GetRewardBubbleTitle()
	local quantity = self.RewardData.Quantity or 1
	local bubbleTitle = self.RewardInfo and self.RewardInfo.BubbleTitle

	if bubbleTitle then
		return bubbleTitle
	end

	if not self.RewardInfo or self.RewardInfo.Type ~= "Weapon" then
		bubbleTitle = self.RewardInfo and self.RewardInfo.PrioritizeNameOverQuantity and quantity == 1 and self.RewardInfo.DisplayName or self.RewardInfo and "×" .. Utility:PrettyNumber(quantity) .. " " .. (quantity ~= 1 and self.RewardInfo.DisplayNamePlural or self.RewardInfo.DisplayName) or self.RewardData.Name .. " " .. CosmeticLibrary.Cosmetics[self.RewardData.Name].Type
		return bubbleTitle
	end

	if self:_IsUnreleasedWeapon() then
		return "COMING SOON"
	end

	bubbleTitle = self.RewardInfo.DisplayName

	if not bubbleTitle then
		bubbleTitle = self.RewardInfo and self.RewardInfo.PrioritizeNameOverQuantity and quantity == 1 and self.RewardInfo.DisplayName or self.RewardInfo and "×" .. Utility:PrettyNumber(quantity) .. " " .. (quantity ~= 1 and self.RewardInfo.DisplayNamePlural or self.RewardInfo.DisplayName) or self.RewardData.Name .. " " .. CosmeticLibrary.Cosmetics[self.RewardData.Name].Type
	end

	return bubbleTitle
end

function RewardSlot:GetRewardBubbleDescription()
	local bubbleDescription = self.RewardInfo and self.RewardInfo.BubbleDescription or self.RewardInfo and self.RewardInfo.Type == "Lootbox" and (self.RewardData.Weapon and self.RewardData.Weapon ~= "IsRandom" and self.RewardData.Weapon ~= "IsUniversal" and "Contains special items for " .. self.RewardData.Weapon .. "!" or self.RewardInfo.LootboxDescription) or self.RewardInfo and self.RewardInfo.Type == "Weapon" and (self:_IsUnreleasedWeapon() and "in " .. Utility:TimeFormat2(ShopLibrary:GetTimeUntilWeaponRelease(self.RewardData.Name)) .. "!" or ItemLibrary.Items[self.RewardData.Name].Status .. " Weapon")

	if bubbleDescription then
		return bubbleDescription
	end

	if self.RewardData.Weapon == "IsUniversal" then
		return "Given to all weapons forever!"
	end

	if self.RewardData.Weapon == "IsRandom" then
		return "Given to a random weapon!"
	end

	bubbleDescription = self.RewardData.Weapon and "Given to " .. self.RewardData.Weapon .. "!" or self.CosmeticInfo and self.CosmeticInfo.Description or "???"
	return bubbleDescription
end

function RewardSlot:SetParent(parent)
	self.Frame.Parent = parent
end

function RewardSlot:SetInteractable(interactable)
	self.Frame.Reward.Interactable = interactable

	if self.CosmeticSlot then
		self.CosmeticSlot:SetInteractable(interactable)
	end
end

function RewardSlot:SetWeapon(p)
	if self.CosmeticSlot then
		return self.CosmeticSlot:SetWeapon(p)
	end

	if p == "IsRandom" and self.RewardInfo and self.RewardInfo.Type == "Lootbox" then
		p = nil
	end

	if not p then
		self.Frame.Reward.Weapon.Visible = false
		return
	end

	local item = ItemLibrary.Items[p]
	local viewModel = ItemLibrary.ViewModels[p]
	local v = p == "IsUniversal" or p == "IsRandom"
	local UNIVERSAL_WEAPON_ICON

	if p == "IsUniversal" then
		UNIVERSAL_WEAPON_ICON = ItemLibrary.UNIVERSAL_WEAPON_ICON
	elseif p == "IsRandom" then
		UNIVERSAL_WEAPON_ICON = ItemLibrary.RANDOM_WEAPON_ICON
	else
		UNIVERSAL_WEAPON_ICON = not viewModel and "" or viewModel.ImageCentered or viewModel.Image
	end

	self.Frame.Reward.Weapon.Visible = true
	self.Frame.Reward.Weapon.Container.IconCanvas.Icon.Image = UNIVERSAL_WEAPON_ICON
	self.Frame.Reward.Weapon.Container.IconCanvas.Icon.ImageTransparency = v and 0.25 or 0
	self.Frame.Reward.Weapon.Container.IconCanvas.Icon.Size = v and UDim2.new(0.7, 0, 0.7, 0) or UDim2.new(4, 0, 4, 0)
	WeaponStatusHandler:ApplyItemStatusToBackground(
		self.Frame.Reward.Weapon.Container.Background,
		self.Frame.Reward.Weapon.Container.Outline.UIStroke,
		item and item.Status or "Standard"
	)
end

function RewardSlot:OnClick(on_click_callback)
	self._on_click_callback = on_click_callback
end

function RewardSlot.HideWeaponVisual(p)
	p.Frame.Reward.Weapon.Visible = false

	if p.CosmeticSlot then
		p.CosmeticSlot.Frame.Button.Weapon.Visible = false
	end
end

function RewardSlot:HideBackground()
	if self.CosmeticSlot then
		self.CosmeticSlot:HideBackground()
	end
end

function RewardSlot:ZoomOutViewportFrame()
	if self.CosmeticSlot then
		self.CosmeticSlot:ZoomOutViewportFrame()
	end
end

function RewardSlot:UseHighResolutionImage()
	if self.RewardInfo then
		self.Frame.Reward.Icon.Image = self.RewardInfo.ImageHighResolution or self.RewardInfo.Image
	end

	if self.CosmeticSlot then
		self.CosmeticSlot:UseHighResolutionImage()
	end
end

function RewardSlot.SetNameText(p, text)
	p.Frame.Reward.Title.Text = text

	if p.CosmeticSlot then
		p.CosmeticSlot.Frame.Button.Title.Text = text
	end
end

function RewardSlot:LockedImage()
	self.Frame.Reward.Icon.ImageColor3 = Color3.fromRGB(0, 0, 0)
	self.Frame.Reward.Icon.ImageTransparency = 0.5

	if self.CosmeticSlot then
		self.CosmeticSlot.Frame.Button.Icon.ImageColor3 = Color3.fromRGB(0, 0, 0)
		self.CosmeticSlot.Frame.Button.Icon.ImageTransparency = 0.5
	end
end

function RewardSlot:InvertNameText()
	if self.RewardInfo and self.RewardInfo.Type == "Weapon" then
		self.Frame.Reward.Title.Visible = false
		return
	end

	self.Frame.Reward.Title.TextColor3 = Color3.fromRGB(0, 0, 0)
	self.Frame.Reward.Title.UIStroke.Enabled = false
end

function RewardSlot:SetBubbleAutoCloseDelay(bubble_auto_close_delay)
	self._bubble_auto_close_delay = bubble_auto_close_delay
end

function RewardSlot:CloseBubble()
	self._bubble_hash += 1

	for _, _bubble_connection in pairs(self._bubble_connections) do
		_bubble_connection:Disconnect()
	end

	self._bubble_connections = {}
	self._open_bubble_upwards = nil

	if self._bubble_frame then
		self._bubble_frame:Destroy()
		self._bubble_frame = nil
	end

	if self._bubble_reward_slot then
		self._bubble_reward_slot:Destroy()
		self._bubble_reward_slot = nil
	end

	RunService:UnbindFromRenderStep("RewardSlotOpenBubble")
end

function RewardSlot:OpenBubble(open_bubble_upwards, value)
	self:CloseBubble()
	self._open_bubble_upwards = open_bubble_upwards
	self._bubble_hash += 1
	local _bubble_hash = self._bubble_hash
	local v = value or 1
	local uDim = UDim2.new(
		rewardBubble.Size.X.Scale * v,
		rewardBubble.Size.X.Offset * v,
		rewardBubble.Size.Y.Scale * v,
		rewardBubble.Size.Y.Offset * v
	)
	local uDim2 = UDim2.new(uDim.X.Scale / 2, uDim.X.Offset / 2, uDim.Y.Scale / 2, uDim.Y.Offset / 2)
	self._bubble_frame = rewardBubble:Clone()
	self._bubble_frame.Title.Text = self:GetRewardBubbleTitle()
	self._bubble_frame.Description.Text = self:GetRewardBubbleDescription()
	self._bubble_frame.Size = uDim2
	self._bubble_frame.Parent = UILibrary:GetTo("MainFrame")
	self._bubble_frame:TweenSize(uDim, "Out", "Back", 0.25, true)
	self._bubble_reward_slot = RewardSlot.new(self.RewardData, true)
	self._bubble_reward_slot:OnClick(function() end)
	self._bubble_reward_slot:InvertNameText()
	self._bubble_reward_slot:SetParent(self._bubble_frame.Reward)

	if self:_IsUnreleasedWeapon() then
		self._bubble_reward_slot:LockedImage()
	end

	if self.RewardInfo and self.RewardInfo.Type == "Weapon" then
		local status = ItemLibrary.Items[self.RewardInfo.DisplayName] and ItemLibrary.Items[self.RewardInfo.DisplayName].Status
		WeaponStatusHandler:ApplyItemStatusToText(self._bubble_frame.Title, status)
		WeaponStatusHandler:ApplyItemStatusToText(self._bubble_frame.Description, status)
	elseif self.RewardData and self.RewardData.Weapon then
		WeaponStatusHandler:ApplyItemStatusToText(
			self._bubble_frame.Description,
			ItemLibrary.Items[self.RewardData.Weapon] and ItemLibrary.Items[self.RewardData.Weapon].Status
		)
	elseif self.RewardInfo and self.RewardInfo.NameStatus then
		WeaponStatusHandler:ApplyItemStatusToText(self._bubble_frame.Title, self.RewardInfo.NameStatus)
	end

	table.insert(self._bubble_connections, GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
		if GuiService.MenuIsOpen then
			self:CloseBubble()
		end
	end))
	table.insert(self._bubble_connections, UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.Return or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonA or input.KeyCode == Enum.KeyCode.ButtonB then
			self:CloseBubble()
		end
	end))
	table.insert(self._bubble_connections, self.Frame.AncestryChanged:Connect(function()
		if not self.Frame:IsDescendantOf(workspace) and Players.LocalPlayer:FindFirstChild("PlayerGui") and not self.Frame:IsDescendantOf(Players.LocalPlayer.PlayerGui) then
			self:CloseBubble()
		end
	end))
	table.insert(self._bubble_connections, self.Frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateBubblePosition()
	end))
	table.insert(self._bubble_connections, self.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateBubblePosition()
	end))
	RunService:BindToRenderStep("RewardSlotOpenBubble", Enum.RenderPriority.Camera.Value - 1, function()
		self:_UpdateBubblePosition()
	end)
	self:_UpdateBubblePosition()

	if self._bubble_auto_close_delay then
		task.delay(self._bubble_auto_close_delay, function()
			if self._bubble_hash ~= _bubble_hash then
				return
			end

			self._bubble_frame:TweenSize(uDim2, "In", "Quint", 0.25, true)
			wait(0.25)

			if self._bubble_hash ~= _bubble_hash then
				return
			end

			self:CloseBubble()
		end)
	end
end

function RewardSlot:Destroy()
	self:CloseBubble()
	self.Frame:Destroy()

	if self.CosmeticSlot then
		self.CosmeticSlot:Destroy()
	end
end

function RewardSlot:_IsUnreleasedWeapon()
	local rewardInfo = self.RewardInfo

	if rewardInfo then
		if self.RewardInfo.Type == "Weapon" then
			rewardInfo = not table.find(ShopLibrary:GetReleasedOwnableWeapons(), self.RewardData.Name)
		else
			rewardInfo = false
		end
	end

	return rewardInfo
end

function RewardSlot:_OnClick()
	if self._on_click_callback then
		return self._on_click_callback()
	end

	self:OpenBubble()
end

function RewardSlot:_GetLayerCollector()
	local parent = self.Frame.Parent

	while parent and not parent:IsA("LayerCollector") do
		parent = parent.Parent
	end

	return parent
end

function RewardSlot:_UpdateBubblePosition()
	if not self._bubble_frame.Parent then
		return
	end

	local surfaceGui = self:_GetLayerCollector()
	local v = surfaceGui and surfaceGui:IsA("SurfaceGui")
	local vector, vector2

	if v then
		local adornee = surfaceGui.Adornee or surfaceGui.Parent

		if adornee:IsA("BasePart") then
			local worldToScreenPoint = workspace.CurrentCamera:WorldToScreenPoint(adornee.Position)

			if worldToScreenPoint.Z < 0 then
				vector = -self._bubble_frame.AbsoluteSize * 10
			else
				vector = UILibrary:ScreenPointToPosition(worldToScreenPoint)
			end
		else
			vector = Vector2.new()
		end

		vector2 = Vector2.new()
	else
		vector = self.Frame.AbsolutePosition
		vector2 = self.Frame.AbsoluteSize
	end

	local v2 = vector - self._bubble_frame.Parent.AbsolutePosition
	local v3

	if self._open_bubble_upwards == true then
		v3 = false
	else
		v3 = self._open_bubble_upwards == false or v2.Y + vector2.Y / 2 < self._bubble_frame.Parent.AbsoluteSize.Y / 2
	end

	self._bubble_frame.Position = UDim2.new(
		0,
		math.clamp(
			v2.X + vector2.X / 2,
			self._bubble_frame.AbsoluteSize.X / 2 + 10,
			self._bubble_frame.Parent.AbsoluteSize.X - self._bubble_frame.AbsoluteSize.X / 2 - 10
		),
		v and 0 or v3 and 0.02 or -0.02,
		v2.Y + (not v3 and 0 or vector2.Y)
	)
	local _bubble_frame = self._bubble_frame
	local anchorPoint

	if v3 then
		anchorPoint = Vector2.new(0.5, 0)
	else
		anchorPoint = Vector2.new(0.5, 1)
	end

	_bubble_frame.AnchorPoint = anchorPoint
	self._bubble_frame.Arrow.Position = UDim2.new(
		0,
		math.clamp(
			v2.X + vector2.X / 2 - (self._bubble_frame.AbsolutePosition.X - self._bubble_frame.Parent.AbsolutePosition.X),
			self._bubble_frame.Arrow.AbsoluteSize.X * 0.875 + 10,
			self._bubble_frame.AbsoluteSize.X - self._bubble_frame.Arrow.AbsoluteSize.X * 0.875 - 10
		),
		v3 and 0 or 1,
		v3 and 2 or -2
	)
end

function RewardSlot:_Setup()
	if self.CosmeticInfo then
		self.CosmeticSlot = CosmeticSlot.new(self.RewardData.Name, self._is_locked, self._ignore_button_effects)
		self.CosmeticSlot:SetQuantity(self.RewardData.Quantity)
		self.CosmeticSlot.Frame.Parent = self.Frame
		self.CosmeticSlot.Frame.Button.MouseButton1Click:Connect(function()
			self:_OnClick()
		end)
	elseif self.RewardInfo then
		local item = ItemLibrary.Items[self.RewardData.Name]
		local v = self.RewardInfo.Type == "Weapon" or self.RewardInfo.PrioritizeNameOverQuantity and (self.RewardData.Quantity or 1) == 1
		self.Frame.Reward.Visible = true
		self.Frame.Reward.Title.Text = v and self.RewardInfo.DisplayName or "×" .. Utility:PrettyNumber(self.RewardData.Quantity or 1)
		self.Frame.Reward.Title.Size = v and UDim2.new(0.9, 0, 0.2, 0) or UDim2.new(0.9, 0, 0.4, 0)
		self.Frame.Reward.Icon.Image = self.RewardInfo.Image
		self.Frame.Reward.Icon.Size = UDim2.new(self.RewardInfo.ImageScale, 0, self.RewardInfo.ImageScale, 0)
		WeaponStatusHandler:ApplyItemStatusToText(
			self.Frame.Reward.Title,
			self.RewardInfo.NameStatus or item and item.Status
		)
		self.Frame.Reward.MouseButton1Click:Connect(function()
			self:_OnClick()
		end)

		if not self._ignore_button_effects then
			ButtonEffect:Add(self.Frame.Reward)
		end
	else
		warn("reward_data = {")

		for k, v in pairs(self.RewardData) do
			warn("\t", k, v)
		end

		warn("}")
		assert(false, self.RewardData.Name)
	end

	self:SetWeapon(self.RewardData.Weapon)
end

function RewardSlot:_Init()
	self:_Setup()
end

return RewardSlot