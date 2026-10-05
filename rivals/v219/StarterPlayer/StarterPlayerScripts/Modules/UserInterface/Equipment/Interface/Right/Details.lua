local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local StatisticsLibrary = require(ReplicatedStorage.Modules.StatisticsLibrary)
local ShopLibrary = require(ReplicatedStorage.Modules.ShopLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers.ComplianceController)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules.WeaponStatusHandler)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local equipmentDetailsDescription = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("EquipmentDetailsDescription")
local v = { "Lookin' good!" }
local Details = {}
Details.__index = Details

function Details.new(right)
	local self = setmetatable({}, Details)
	self.Right = right
	self.Frame = self.Right.Container:WaitForChild("Details")
	self.Container = self.Frame:WaitForChild("Container")
	self.Title = self.Container:WaitForChild("Title")
	self.Icon = self.Container:WaitForChild("Icon")
	self.Headshot = self.Container:WaitForChild("Headshot")
	self.DescriptionsFrame = self.Container:WaitForChild("Descriptions")
	self.DescriptionsLayout = self.DescriptionsFrame:WaitForChild("Layout")
	self.FavoritedFrame = self.Container:WaitForChild("Favorited")
	self.FavoritedButton = self.FavoritedFrame:WaitForChild("Button")
	self.FavoritedFilled = self.FavoritedButton:WaitForChild("Filled")
	self.FavoritedEmpty = self.FavoritedButton:WaitForChild("Empty")
	self._cleanup = {}
	self:_Init()
	return self
end

function Details:OnStateChanged()
	self:_Generate()
end

function Details:_Generate()
	for _, v2 in pairs(self._cleanup) do
		WeaponStatusHandler:ClearStatusElements(v2)
		v2:Destroy()
	end

	self._cleanup = {}
	WeaponStatusHandler:ClearStatusElements(self.Title)
	local isCareerPageOpen = self.Right.Interface.Equipment:IsCareerPageOpen()
	local selectedWeapon = self.Right.Interface.Equipment:GetSelectedWeapon()
	local _, _, v2, _ = ShopLibrary:GetWeaponKeyPriceInfo(
		selectedWeapon,
		PlayerDataController:Get("UnlockTokens"),
		PlayerDataController:Get("FreeWeaponUnlockCheck")
	)
	local timeUntilWeaponRelease = ShopLibrary:GetTimeUntilWeaponRelease(selectedWeapon)
	local v3 = not v2 and timeUntilWeaponRelease > 0
	local visible = isCareerPageOpen or selectedWeapon and not v3
	self.Frame.Visible = visible

	if not visible then
		return
	end

	local visible2 = selectedWeapon and PlayerDataController:GetWeaponData(selectedWeapon) ~= nil
	local visible3 = selectedWeapon and PlayerDataController:GetFavoritedWeapons()[selectedWeapon]
	self.FavoritedFrame.Visible = visible2
	self.FavoritedFilled.Visible = visible3
	self.FavoritedEmpty.Visible = not visible3

	if isCareerPageOpen then
		self.Headshot.Image = string.format(CONSTANTS.HEADSHOT_IMAGE, Players.LocalPlayer.UserId)
		self.Icon.Image = ""
		self.Title.AutoLocalize = false
		self.Title.Text = ComplianceController:GetName(Players.LocalPlayer)

		if Players.LocalPlayer.Name ~= Players.LocalPlayer.DisplayName then
			local v7 = "• Also known as @" .. Players.LocalPlayer.Name
			self:_CreateDescription(v7, #v7 > 34 and 2 or 1)
		end

		self:_CreateDescription("• " .. v[math.random(#v)], 1)
	elseif selectedWeapon then
		local item = ItemLibrary.Items[selectedWeapon]
		local item2 = StatisticsLibrary.Items[selectedWeapon]
		local weaponData = PlayerDataController:GetWeaponData(selectedWeapon)
		self.Headshot.Image = ""
		self.Icon.Image = weaponData and ItemLibrary:GetViewModelImageFromWeaponData(weaponData) or ""
		self.Title.Text = selectedWeapon
		self.Title.AutoLocalize = true
		WeaponStatusHandler:ApplyItemStatusToText(self.Title, item.Status)
		WeaponStatusHandler:ApplyItemStatusToText(
			self:_CreateDescription("• " .. item.Status .. " " .. item.Class, 1),
			item.Status
		)

		for _, list in pairs(item2 and item2.Descriptions or {}) do
			local v7, v8 = table.unpack(list)
			self:_CreateDescription("• " .. v8, v7)
		end
	end
end

function Details:_CreateDescription(text, p2)
	local clone = equipmentDetailsDescription:Clone()
	clone.Text = text
	clone.Size = UDim2.new(0.75, 0, 0.05 * p2, 0)
	clone.LayoutOrder = #self._cleanup
	clone.Parent = self.DescriptionsFrame
	table.insert(self._cleanup, clone)
	return clone
end

function Details:_Update()
	self.Frame.Size = UDim2.new(
		1,
		0,
		0,
		(self.DescriptionsFrame.AbsolutePosition.Y - self.Frame.AbsolutePosition.Y) * 1.25 + self.DescriptionsLayout.AbsoluteContentSize.Y
	)
end

function Details:_Init()
	self.DescriptionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_Update()
	end)
	self.FavoritedButton.MouseButton1Click:Connect(function()
		self.Right.Interface.Equipment:FavoriteWeapon()
	end)
	PlayerDataController:GetDataChangedSignal("WeaponInventory"):Connect(function()
		self:_Generate()
	end)
	self:_Update()
	ButtonEffect:Add(self.FavoritedButton)
end

return Details