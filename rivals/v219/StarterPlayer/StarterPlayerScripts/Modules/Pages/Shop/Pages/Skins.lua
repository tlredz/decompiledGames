local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MonetizationLibrary = require(ReplicatedStorage.Modules.MonetizationLibrary)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
require(ReplicatedStorage.Modules.Utility)
local MonetizationController = require(Players.LocalPlayer.PlayerScripts.Controllers.MonetizationController)
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers.ComplianceController)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local Spotlight = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Spotlight)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules.RewardSlot)
local Skins = {}
Skins.__index = Skins

function Skins.new(pages)
	local self = setmetatable({}, Skins)
	self.Pages = pages
	self.Frame = self.Pages.Frame:WaitForChild("Skins")
	self.Container = self.Frame:WaitForChild("Container")
	self.SlotsFrame = self.Container:WaitForChild("Slots")
	self.InspectFrame = self.Container:WaitForChild("Inspect")
	self.InspectRewardsFrame = self.InspectFrame:WaitForChild("Rewards")
	self.InspectNameDisplayFrame = self.InspectFrame:WaitForChild("NameDisplay")
	self.InspectNameDisplayBackground = self.InspectNameDisplayFrame:WaitForChild("Background")
	self.InspectNameDisplayElementsFrame = self.InspectNameDisplayFrame:WaitForChild("Elements")
	self.InspectNameDisplayLayout = self.InspectNameDisplayElementsFrame:WaitForChild("Layout")
	self.InspectNameDisplayTitleContainerFrame = self.InspectNameDisplayElementsFrame:WaitForChild("TitleContainer")
	self.InspectNameDisplayTitle = self.InspectNameDisplayTitleContainerFrame:WaitForChild("Title")
	self.InspectNameDisplaySlotFrameContainer = self.InspectNameDisplayElementsFrame:WaitForChild("Slot"):WaitForChild("Container")
	self.InspectDescriptionFrame = self.InspectNameDisplaySlotFrameContainer:WaitForChild("Description")
	self.InspectDescriptionArrow = self.InspectDescriptionFrame:WaitForChild("Arrow")
	self.InspectDescriptionBackground = self.InspectDescriptionFrame:WaitForChild("Background")
	self.InspectDescriptionTitle = self.InspectDescriptionFrame:WaitForChild("Title")
	self.InspectButtonsFrame = self.InspectFrame:WaitForChild("Buttons")
	self.InspectBackButton = self.InspectButtonsFrame:WaitForChild("Back")
	self.InspectBuyItemButton = self.InspectButtonsFrame:WaitForChild("BuyItem")
	self.InspectBuyItemText = self.InspectBuyItemButton:WaitForChild("Value")
	self.InspectBuyBundleButton = self.InspectButtonsFrame:WaitForChild("BuyBundle")
	self.InspectBuyBundleText = self.InspectBuyBundleButton:WaitForChild("Value")
	self.InspectDiscountTitle = self.InspectButtonsFrame:WaitForChild("Discount"):WaitForChild("Bubble"):WaitForChild("Title")
	self.InspectPreviewFrame = self.InspectFrame:WaitForChild("Preview")
	self.InspectPreviewContainer = self.InspectPreviewFrame:WaitForChild("Container")
	self._inspected_bundle_name = false
	self._inspected_bundle_info = nil
	self._selected_product_and_reward = nil
	self._inspected_reward_slots = {}
	self._selected_reward_slot = nil
	self._preview_reward_slot = nil
	self:_Init()
	return self
end

function Skins:SelectProductAndReward(selected_product_and_reward)
	if self._selected_reward_slot then
		self._selected_reward_slot:Destroy()
		self._selected_reward_slot = nil
	end

	if self._preview_reward_slot then
		self._preview_reward_slot:Destroy()
		self._preview_reward_slot = nil
	end

	self._selected_product_and_reward = selected_product_and_reward
	self.InspectNameDisplayFrame.Visible = self._selected_product_and_reward ~= nil
	self.InspectBuyItemButton.Visible = self._selected_product_and_reward and self._selected_product_and_reward[1] ~= nil

	if not self._selected_product_and_reward then
		return
	end

	if self.InspectBuyItemButton.Visible then
		MonetizationController:SetRobuxText(
			self.InspectBuyItemText,
			self._selected_product_and_reward and self._selected_product_and_reward[1]
		)
	end

	local v = self._selected_product_and_reward[3]
	local cosmetic = CosmeticLibrary.Cosmetics[v.Name]
	self.InspectNameDisplayTitle.Text = v.Name .. (not cosmetic and "" or "  •  " .. cosmetic.Type .. " ")
	self.InspectDescriptionTitle.Text = (not (cosmetic and cosmetic.ItemName) and "" or v.Weapon or "") .. " not included"
	self.InspectDescriptionFrame.Visible = cosmetic and cosmetic.ItemName and v.Weapon and not PlayerDataController:GetWeaponData(v.Weapon)
	self._selected_reward_slot = RewardSlot.new(v)
	self._selected_reward_slot:HideWeaponVisual()
	self._selected_reward_slot:SetNameText("")
	self._selected_reward_slot:SetInteractable(false)
	self._selected_reward_slot.Frame.Parent = self.InspectNameDisplaySlotFrameContainer
	self._preview_reward_slot = RewardSlot.new(v)
	self._preview_reward_slot:ZoomOutViewportFrame()
	self._preview_reward_slot:UseHighResolutionImage()
	self._preview_reward_slot:HideBackground()
	self._preview_reward_slot:HideWeaponVisual()
	self._preview_reward_slot:SetNameText("")
	self._preview_reward_slot:SetInteractable(false)
	self._preview_reward_slot.Frame.Parent = self.InspectPreviewContainer
	self.InspectPreviewContainer.Position = UDim2.new(0.5, 0, 0.6, 0)
	self.InspectPreviewContainer:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quint", 0.25, true)
end

function Skins:Inspect(inspected_bundle_name)
	if inspected_bundle_name == self._inspected_bundle_name then
		return
	end

	for _, _inspected_reward_slot in pairs(self._inspected_reward_slots) do
		_inspected_reward_slot:Destroy()
	end

	self._inspected_reward_slots = {}
	self._inspected_bundle_name = inspected_bundle_name
	self._inspected_bundle_info = self._inspected_bundle_name and MonetizationLibrary.Bundles[self._inspected_bundle_name]
	self:SelectProductAndReward(nil)
	self.SlotsFrame.Visible = not self._inspected_bundle_name
	local slotsFrame = self.SlotsFrame
	local position

	if self.SlotsFrame.Visible then
		position = UDim2.new(0.375, 0, 0, 0)
	else
		position = UDim2.new(0.5, 0, 0, 0)
	end

	slotsFrame.Position = position
	self.SlotsFrame:TweenPosition(UDim2.new(0.5, 0, 0, 0), "Out", "Quint", 0.25, true)
	self.InspectFrame.Visible = not self.SlotsFrame.Visible
	local inspectFrame = self.InspectFrame
	local position2

	if self.InspectFrame.Visible then
		position2 = UDim2.new(0.625, 0, 0, 0)
	else
		position2 = UDim2.new(0.5, 0, 0, 0)
	end

	inspectFrame.Position = position2
	self.InspectFrame:TweenPosition(UDim2.new(0.5, 0, 0, 0), "Out", "Quint", 0.25, true)

	if not self._inspected_bundle_name then
		return
	end

	MonetizationController:SetRobuxText(self.InspectBuyBundleText, self._inspected_bundle_info.ProductID)
	MonetizationController:SetRobuxTextWithFormat(
		"<s>%s</s>",
		self.InspectDiscountTitle,
		table.unpack(self._inspected_bundle_info.SetRobuxTextArgs)
	)

	for k, rewardsWithIndividualProductID in pairs(self._inspected_bundle_info.RewardsWithIndividualProductIDs) do
		local v3 = rewardsWithIndividualProductID[3]
		local reward = CosmeticLibrary.Rewards[v3.Name]

		if not (not reward or reward.Type ~= "Lootbox" or not ComplianceController:ArePaidRandomItemsRestricted()) then
			continue
		end

		local v4 = RewardSlot.new(v3)
		v4.Frame.LayoutOrder = k
		v4:SetParent(self.InspectRewardsFrame)
		table.insert(self._inspected_reward_slots, v4)
		local v5 = rewardsWithIndividualProductID
		v4:OnClick(function()
			self:SelectProductAndReward(v5)
		end)

		if self._selected_product_and_reward or not rewardsWithIndividualProductID[1] then
			continue
		end

		self:SelectProductAndReward(rewardsWithIndividualProductID)
	end

	if not self._selected_product_and_reward then
		self:SelectProductAndReward(self._inspected_bundle_info.RewardsWithIndividualProductIDs[1])
	end
end

function Skins:Open()
	self:Inspect(nil)
end

function Skins:Close()
	self:Inspect(nil)
end

function Skins:Setup()
	for childName, bundle in pairs(MonetizationLibrary.Bundles) do
		if not bundle.IsCosmeticBundle then
			continue
		end

		local container = self.SlotsFrame:WaitForChild(childName):WaitForChild("Container")
		local rewards = container:WaitForChild("Rewards")
		local title = container:WaitForChild("Title")
		title.Text = bundle.DisplayName
		local v = childName
		container.MouseButton1Click:Connect(function()
			self:Inspect(v)
		end)
		container.MouseEnter:Connect(function()
			Spotlight:ChangeSubject(container)
		end)
		local v3 = container
		container.MouseLeave:Connect(function()
			Spotlight:ChangeSubject(nil, v3)
		end)
		ButtonEffect:Add(container, nil, {
			HoverRatio = 1.025,
			ReleaseRatio = 1.025
		})

		for k, rewardsWithIndividualProductID in pairs(bundle.RewardsWithIndividualProductIDs) do
			if not rewardsWithIndividualProductID[1] then
				continue
			end

			local v4 = rewardsWithIndividualProductID[3]
			local reward = CosmeticLibrary.Rewards[v4.Name]

			if not (not reward or reward.Type ~= "Lootbox" or not ComplianceController:ArePaidRandomItemsRestricted()) then
				continue
			end

			local v5 = RewardSlot.new(v4)
			v5.Frame.LayoutOrder = k
			v5:SetInteractable(false)
			v5:SetNameText("")
			v5:HideWeaponVisual()
			v5:SetParent(rewards)
		end
	end

	self:Inspect(nil)
end

function Skins:_UpdateLayout()
	self.InspectNameDisplayTitleContainerFrame.Size = UDim2.new(0, self.InspectNameDisplayTitle.TextBounds.X, 0.75, 0)
	self.InspectNameDisplayBackground.Size = UDim2.new(
		0,
		self.InspectNameDisplayLayout.AbsoluteContentSize.X + self.InspectNameDisplayTitleContainerFrame.AbsoluteSize.Y * 0.5,
		1,
		0
	)
	self.InspectDescriptionBackground.Size = UDim2.new(
		0,
		self.InspectDescriptionTitle.TextBounds.X + self.InspectDescriptionFrame.AbsoluteSize.Y,
		1,
		0
	)
end

function Skins:_Init()
	self.InspectBuyBundleButton.MouseButton1Click:Connect(function()
		MonetizationController:PromptProductPurchase(self._inspected_bundle_info.ProductID)
	end)
	self.InspectBuyItemButton.MouseButton1Click:Connect(function()
		MonetizationController:PromptProductPurchase(self._selected_product_and_reward[1])
	end)
	self.InspectBackButton.MouseButton1Click:Connect(function()
		self:Inspect(nil)
	end)
	self.InspectNameDisplayTitle:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateLayout()
	end)
	self.InspectNameDisplayTitleContainerFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateLayout()
	end)
	self.InspectNameDisplayLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateLayout()
	end)
	self.InspectDescriptionTitle:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateLayout()
	end)
	self.Pages.Shop.CurrentPageChanged:Connect(function()
		self:Inspect(nil)
	end)
	self:_UpdateLayout()
	ButtonEffect:Add(self.InspectBackButton)
	ButtonEffect:Add(self.InspectBuyItemButton)
	ButtonEffect:Add(self.InspectBuyBundleButton)
end

return Skins