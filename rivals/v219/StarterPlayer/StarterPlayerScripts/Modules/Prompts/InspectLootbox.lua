local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local LootLibrary = require(ReplicatedStorage.Modules.LootLibrary)
local ShopLibrary = require(ReplicatedStorage.Modules.ShopLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("WeaponStatusHandler"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("RewardSlot"))
local Prompt = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Prompt"))
local lootboxChanceSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("LootboxChanceSlot")
local object = setmetatable({}, Prompt)
object.__index = object

function object.new(root_name, value, back_to_prompt_name, ...)
	local self = setmetatable(Prompt.new(script.Name), object)
	self.CloseButton = self.PromptFrame:WaitForChild("Close")
	self.List = self.PromptFrame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self._root_name = root_name
	self._root_weapon = value or "IsRandom"
	self._back_to_prompt_name = back_to_prompt_name
	self._back_to_prompt_args = { ... }
	self:_Init()
	return self
end

function object:CloseRequest()
	if self._back_to_prompt_name then
		self.OpenPrompt:Fire(self._back_to_prompt_name, table.unpack(self._back_to_prompt_args))
	else
		Prompt.CloseRequest(self)
	end
end

function object:_GenerateOddsData(parent, p, p2, p3)
	local rewardData = p.RewardData
	local displayType = p.DisplayType
	local text = rewardData.Name .. (not (rewardData.Quantity and rewardData.Quantity > 1) and "" or " [×" .. rewardData.Quantity .. "]" or "")
	local color = Color3.fromRGB(255, 255, 255)
	local status = nil
	local type = ""
	local color2 = Color3.fromRGB(255, 255, 255)
	local status2 = nil
	local cosmetic = CosmeticLibrary.Cosmetics[rewardData.Name]
	local reward = CosmeticLibrary.Rewards[rewardData.Name]
	local v2 = {}

	if cosmetic then
		color = CosmeticLibrary.Rarities[cosmetic.Rarity].Color
		type = cosmetic.Rarity .. " " .. cosmetic.Type

		if rewardData.Weapon == "IsUniversal" then
			type ..= " for all weapons"
		elseif rewardData.Weapon == "IsRandom" then
			type ..= " for a random weapon"
			local unlockedWeaponsForSelection = LootLibrary:GetUnlockedWeaponsForSelection(
				PlayerDataController:Get("WeaponInventory"),
				true,
				rewardData.Name,
				PlayerDataController:Get("CosmeticInventory")
			)
			local v3 = {}
			local v4 = {}

			for _, v5 in pairs(ShopLibrary:GetReleasedOwnableWeapons(
				CONSTANTS.WEAPON_EARLY_ACCESS_TIME_OFFSET,
				ShopLibrary.OwnableWeaponsAlphabetized
			)) do
				if table.find(unlockedWeaponsForSelection, v5) then
					continue
				end

				if PlayerDataController:GetWeaponData(v5) then
					table.insert(v3, v5)
				else
					table.insert(v4, v5)
				end
			end

			local function add_these(items, displayType2)
				for _, item in pairs(items) do
					local rewardData2 = {
						Name = rewardData.Name,
						Weapon = item
					}
					table.insert(v2, {
						Weight = 1,
						RewardData = rewardData2,
						DisplayType = displayType2
					})
				end
			end

			add_these(unlockedWeaponsForSelection, "Default")
			add_these(v3, "Owned")
			add_these(v4, "Locked")
		elseif rewardData.Weapon then
			type ..= " for " .. rewardData.Weapon
			status2 = ItemLibrary.Items[rewardData.Weapon].Status
		end
	elseif reward then
		if reward.Type == "Weapon" then
			local item = ItemLibrary.Items[rewardData.Name]
			type = item.Status .. " Weapon"
			status = item.Status
		else
			type = reward.Type

			if rewardData.Weapon == "IsUniversal" then
				type ..= " for all weapons"
			elseif rewardData.Weapon == "IsRandom" then
				type ..= " for a random weapon"
			elseif rewardData.Weapon then
				type ..= " for " .. rewardData.Weapon
				status2 = ItemLibrary.Items[rewardData.Weapon].Status
			end

			if reward.Type == "Lootbox" then
				local lootboxPossibilities, v3, v4 = LootLibrary:GetLootboxPossibilities(
					reward.SmartRestrictionsEnabled,
					reward.GetContents(rewardData.Weapon),
					PlayerDataController:Get("CosmeticInventory"),
					PlayerDataController:GetUnlockedWeapons(),
					rewardData.Weapon
				)

				local function add_these(items, displayType2)
					for _, item in pairs(items) do
						table.insert(v2, {
							Weight = item.Weight,
							RewardData = item.Reward,
							DisplayType = displayType2
						})
					end
				end

				add_these(lootboxPossibilities, "Default")
				add_these(v4, "Owned")
				add_these(v3, "Locked")
			end
		end
	end

	local visible

	if displayType == "Default" then
		visible = #v2 > 0
	else
		visible = false
	end

	local clone = lootboxChanceSlot:Clone()
	clone.Container.TitleContainer.Value.Text = text
	clone.Container.TitleContainer.Value.TextColor3 = color
	clone.Container.DescriptionContainer.Value.Text = type
	clone.Container.DescriptionContainer.Value.TextColor3 = color2
	clone.Container.Details.Chance.Text = string.format("%.2f%%", p2 * 100)
	clone.Container.Details.Chance.Visible = displayType == "Default"
	clone.Container.Details.Locked.Visible = displayType == "Locked"
	clone.Container.Details.Owned.Visible = displayType == "Owned"
	clone.Container.Button.Visible = visible
	clone.Container.Arrow.Visible = visible
	clone.Parent = parent
	WeaponStatusHandler:ApplyItemStatusToText(clone.Container.TitleContainer.Value, status)
	WeaponStatusHandler:ApplyItemStatusToText(clone.Container.DescriptionContainer.Value, status2)
	local v4 = RewardSlot.new(rewardData)
	v4:SetNameText("")
	v4:HideWeaponVisual()
	v4:SetParent(clone.Container.RewardContainer)
	local children = clone.Container.Children
	local layout = children.Layout

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		clone.Size = UDim2.new(1, 0, 0.075, not children.Visible and 0 or layout.AbsoluteContentSize.Y)
	end

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
	children:GetPropertyChangedSignal("Visible"):Connect(update)
	update() -- equivalent call inferred; original call site unknown
	local v5 = false
	local visible2 = false

	local function set_children_visible(p4)
		local v7 = p4 and visible

		if v7 and not v5 then
			v5 = true
			local total = 0

			for _, v8 in pairs(v2) do
				total += v8.DisplayType ~= "Default" and 0 or v8.Weight or 0
			end

			for _, v8 in pairs(v2) do
				local v9 = v8.DisplayType ~= "Default" and 0 or p2 * v8.Weight / total
				self:_GenerateOddsData(clone.Container.Children, v8, v9)
			end
		end

		visible2 = v7
		clone.Container.Children.Visible = visible2
		clone.Container.Details.Visible = not visible2
		clone.Container.Arrow.Image = visible2 and "rbxassetid://17654601337" or "rbxassetid://17654548862"
	end

	if not p3 then
		clone.Container.Button.MouseButton1Click:Connect(function()
			set_children_visible(not visible2)
		end)
		ButtonEffect:Add(clone.Container.Button)
	end

	set_children_visible(p3)
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
	end)
	task.defer(self._GenerateOddsData, self, self.Container, {
		RewardData = {
			Name = self._root_name,
			Weapon = self._root_weapon
		},
		DisplayType = "Default"
	}, 1, true)
	ButtonEffect:Add(self.CloseButton)
end

return object