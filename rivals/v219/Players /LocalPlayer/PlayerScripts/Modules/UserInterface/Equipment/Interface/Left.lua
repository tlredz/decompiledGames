local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local ShopLibrary = require(ReplicatedStorage.Modules.ShopLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local EquipmentButtonSlot = require(Players.LocalPlayer.PlayerScripts.Modules.EquipmentButtonSlot)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local equipmentQuickActionButton = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("EquipmentQuickActionButton")
local equipmentUnlockMeBubble = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("EquipmentUnlockMeBubble")
local equipmentClassSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("EquipmentClassSlot")
local Left = {}
Left.__index = Left

function Left.new(interface)
	local self = setmetatable({}, Left)
	self.Interface = interface
	self.Frame = self.Interface.Frame:WaitForChild("Left")
	self.Background = self.Frame:WaitForChild("Background")
	self.List = self.Frame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.TopBufferFrame = self.Container:WaitForChild("TopBuffer")
	self._generate_deferred = false
	self._cleanup = {}
	self._weapon_slots = {}
	self._career_slot = nil
	self._unlock_me_bubbles = {}
	self._previous_canvas_position = nil
	self:_Init()
	return self
end

function Left.SetVisible(p, p2)
	p.Frame:TweenPosition(p2 and UDim2.new(0, 0, 0.5, 0) or UDim2.new(-0.375, 0, 0.5, 0), "Out", "Quint", 0.25, true)
end

function Left:ScrollTo(p2, value)
	task.delay(value or 0, function()
		local v = math.min(
			self.List.AbsoluteCanvasSize.Y,
			p2.AbsolutePosition.Y + UILibrary.MainGui.AbsolutePosition.Y * 2 - self.Container.AbsolutePosition.Y
		)
		TweenService:Create(self.List, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CanvasPosition = Vector2.new(0, v)
		}):Play()
	end)
end

function Left:OnStateChanged()
	self:_UpdateActive()
	self:_UpdateUnlockMeBubbles()
end

function Left:OnOpen()
	self:_GenerateDeferred()
end

function Left:Update(_)
	for _, _unlock_me_bubble in pairs(self._unlock_me_bubbles) do
		local v = _unlock_me_bubble.WeaponSlot.Frame.AbsolutePosition.Y + _unlock_me_bubble.WeaponSlot.Frame.AbsoluteSize.Y / 2 - _unlock_me_bubble.Bubble.Parent.AbsolutePosition.Y
		local Y = _unlock_me_bubble.Bubble.AbsoluteSize.Y
		local v2 = _unlock_me_bubble.Bubble.Parent.AbsoluteSize.Y - _unlock_me_bubble.Bubble.AbsoluteSize.Y
		local v3 = math.clamp(v, Y, v2)
		_unlock_me_bubble.Bubble.Position = UDim2.new(0.7, 0, 0, v3)
		local arrow = _unlock_me_bubble.Bubble.Button.Arrow
		local uDim

		if v2 <= v3 then
			uDim = UDim2.new(0.5, 0, 1, -2)
		elseif v3 <= Y then
			uDim = UDim2.new(0.5, 0, 0, 2)
		else
			uDim = UDim2.new(0, 2, 0.5, 0)
		end

		arrow.Position = uDim
	end
end

function Left:_Update()
	if self.Interface.Equipment:IsCustomizing() then
		return
	end

	task.defer(function()
		self.TopBufferFrame.Size = UDim2.new(
			1,
			0,
			0,
			(math.max(
				self.List.AbsoluteSize.Y * 0.375,
				self.List.AbsoluteSize.Y - (self.Layout.AbsoluteContentSize.Y - self.TopBufferFrame.AbsoluteSize.Y)
			))
		)
		self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
		self.Background.Size = UDim2.new(
			0.7,
			0,
			0,
			self.Background.AbsolutePosition.Y + self.Background.AbsoluteSize.Y - (self.TopBufferFrame.AbsolutePosition.Y + self.TopBufferFrame.AbsoluteSize.Y)
		)
	end)
end

function Left:_UpdateUnlockMeBubbles()
	for _, _unlock_me_bubble in pairs(self._unlock_me_bubbles) do
		_unlock_me_bubble.Bubble:Destroy()
	end

	self._unlock_me_bubbles = {}

	if not self.Interface.Equipment.IsOpen or self.Interface.Equipment:IsUnlocking() then
		return
	end

	local selectedWeapon = self.Interface.Equipment:GetSelectedWeapon()

	for k in pairs(PlayerDataController:Get("FreeWeaponUnlockCheck")) do
		if k == selectedWeapon or PlayerDataController:GetWeaponData(k) then
			continue
		end

		local _weapon_slot = self._weapon_slots[k]

		if not _weapon_slot then
			continue
		end

		local clone = equipmentUnlockMeBubble:Clone()
		clone.Parent = self.Frame
		table.insert(self._unlock_me_bubbles, {
			Bubble = clone,
			WeaponSlot = _weapon_slot
		})
		ButtonEffect:Add(clone.Button)
		local weaponSlot = _weapon_slot
		local v2 = k
		clone.Button.MouseButton1Click:Connect(function()
			self:ScrollTo(weaponSlot.Frame)
			self.Interface.Equipment:SelectWeapon(v2)
		end)
	end
end

function Left:_UpdateActive()
	local isCareerPageOpen = self.Interface.Equipment:IsCareerPageOpen()
	local selectedWeapon = self.Interface.Equipment:GetSelectedWeapon()

	if self._career_slot then
		self._career_slot:SetActive(isCareerPageOpen)
	end

	for k, _weapon_slot in pairs(self._weapon_slots) do
		_weapon_slot:SetActive(k == selectedWeapon)
	end
end

function Left:_GetOrder()
	local unlockedWeapons = PlayerDataController:GetUnlockedWeapons(true)
	local favoritedWeapons = PlayerDataController:GetFavoritedWeapons()
	local result = {}
	local result2 = {}

	for _, v in pairs(ShopLibrary:GetReleasedOwnableWeapons(
		CONSTANTS.WEAPON_REVEAL_TIME_OFFSET,
		ShopLibrary.OwnableWeaponsAlphabetized
	)) do
		table.insert(result, v)

		if ShopLibrary:GetTimeUntilWeaponRelease(v) > 0 then
			result2[v] = true
		end
	end

	table.sort(result, function(a, b)
		local favoritedWeapon = favoritedWeapons[a]

		if favoritedWeapon ~= favoritedWeapons[b] then
			return favoritedWeapon
		end

		local unlockedWeapon = unlockedWeapons[a]

		if unlockedWeapon ~= unlockedWeapons[b] then
			return unlockedWeapon
		end

		local slot = ItemLibrary.Classes[ItemLibrary.Items[a].Class].Slot
		local slot2 = ItemLibrary.Classes[ItemLibrary.Items[b].Class].Slot

		if slot ~= slot2 then
			return slot < slot2
		end

		local value = ItemLibrary.Statuses[ItemLibrary.Items[a].Status].Value
		local value2 = ItemLibrary.Statuses[ItemLibrary.Items[b].Status].Value

		if value == value2 then
			return Utility:StringLessThan(a, b)
		end

		return value < value2
	end)
	return result, unlockedWeapons, favoritedWeapons, result2
end

function Left:_Generate()
	for _, _weapon_slot in pairs(self._weapon_slots) do
		_weapon_slot:Destroy()
	end

	for _, v in pairs(self._cleanup) do
		v:Destroy()
	end

	self._weapon_slots = {}
	self._cleanup = {}

	if self._career_slot then
		self._career_slot:Destroy()
		self._career_slot = nil
	end

	self._previous_canvas_position = self._previous_canvas_position or self.List.CanvasPosition

	if not self.Interface.Equipment.IsOpen or self.Interface.Equipment:IsCustomizing() then
		return
	end

	local cosmeticNotifications = PlayerDataController:Get("CosmeticNotifications")
	local countNotifications = CosmeticLibrary:CountNotifications(cosmeticNotifications)
	local countNotificationsByCosmeticType = CosmeticLibrary:CountNotificationsByCosmeticType(
		cosmeticNotifications,
		"Emote"
	)
	local _GetOrder, v, v2, v3 = self:_GetOrder()
	local clones = {}
	local clones2 = {}

	local function create_quick_action_button_slot(p, layoutOrder, image, onMouseButton1Click)
		local ___career = clones.___career

		if not ___career or clones2[p] then
			return
		end

		local clone = equipmentQuickActionButton:Clone()
		clone.LayoutOrder = layoutOrder
		clone.Icon.Image = image
		clone.Parent = ___career.Container.QuickActions.Container
		ButtonEffect:Add(clone)
		clone.MouseButton1Click:Connect(onMouseButton1Click)
		clones2[p] = clone
	end

	local function get_class_slot(p, p2, p3, p4, p5)
		if clones[p] then
			return clones[p].Container
		end

		local class = ItemLibrary.Classes[p]
		local layoutOrder = p2 or not class and -999999 or class.Slot or -999999
		local text = p3 or not class and "" or class.Name or ""
		local image = p4 or not class and "" or class.ImageDiagonalLeft or ""
		local image2 = p5 or class and class.ImageDiagonalRight or ""
		local clone = equipmentClassSlot:Clone()
		clone.Container.Footer.Visible = false
		clone.Container.QuickActions.Visible = false
		clone.Container.DismissNotifications.Visible = false
		clone.Container.Header.Visible = text and text ~= ""
		clone.Container.Header.Title.Left.Image = image
		clone.Container.Header.Title.Right.Image = image2
		clone.Container.Header.Title.Text = text
		clone.LayoutOrder = layoutOrder
		clone.ZIndex = clone.LayoutOrder
		clone.Parent = self.Container
		table.insert(self._cleanup, clone)
		clones[p] = clone
		local header = clone.Container.Header
		local layout = clone.Container.Layout
		local title = clone.Container.Header.Title
		local left = clone.Container.Header.Title.Left
		local right = clone.Container.Header.Title.Right

		local function update()
			clone.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
			left.Position = UDim2.new(0.5, -title.TextBounds.X / 2, 0.5, 0)
			right.Position = UDim2.new(0.5, title.TextBounds.X / 2, 0.5, 0)
		end

		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
		header:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
		title:GetPropertyChangedSignal("TextBounds"):Connect(update)
		update()

		if p ~= "___career" then
			return clones[p].Container
		end

		clone.Container.QuickActions.Visible = true
		clone.Container.DismissNotifications.Visible = countNotifications > 0
		clone.Container.DismissNotifications.Button.Title.Text = string.format(
			"Dismiss <font weight=\"800\">%s</font> Notification%s",
			Utility:PrettyNumber(countNotifications),
			countNotifications == 1 and "" or "s"
		)
		ButtonEffect:Add(clone.Container.DismissNotifications.Button, nil, {
			HoverRatio = UDim2.new(0, 10, 0, 10),
			ReleaseRatio = UDim2.new(0, 10, 0, 10)
		})
		clone.Container.DismissNotifications.Button.MouseButton1Click:Connect(function()
			PlayerDataController:SilenceCosmeticNotification(nil, nil)
		end)
		create_quick_action_button_slot("___career", -1, CosmeticLibrary.Types.Emote.Image, function()
			self.Interface.Equipment:StartCustomizing("Emote")
		end)
		return clones[p].Container
	end

	local v4 = string.format(CONSTANTS.HEADSHOT_IMAGE, Players.LocalPlayer.UserId)
	local v5 = get_class_slot("___career", -3)
	self._career_slot = EquipmentButtonSlot.new(
		"___career",
		-999998,
		true,
		"Career",
		v4,
		nil,
		countNotificationsByCosmeticType
	)
	self._career_slot:SetCareerIcon()
	self._career_slot:SetParent(v5)
	self._career_slot.Button.MouseButton1Click:Connect(function()
		self.Interface.Equipment:OpenCareerPage(true)
	end)
	local v6 = {}
	local v7 = false

	for k, v8 in pairs(_GetOrder) do
		local item = ItemLibrary.Items[v8]
		local class = ItemLibrary.Classes[item.Class]
		local weaponData = PlayerDataController:GetWeaponData(v8)
		local v9 = v[v8]
		local v10 = not v9 and v3[v8]
		local v11 = v2[v8]
		local v12 = v10 and "___comingsoon" or v11 and "___favorited" or item.Class
		local v13

		if v10 then
			v13 = get_class_slot(v12, -2, "Coming Soon", "rbxassetid://18195730712", "rbxassetid://18195730712")
		elseif v11 then
			v13 = get_class_slot(v12, -1)
		else
			v13 = get_class_slot(v12)
		end

		local viewModelImageFromWeaponData = weaponData and ItemLibrary:GetViewModelImageFromWeaponData(weaponData) or ItemLibrary:GetViewModelImage(v8) or ""
		local v14 = v9 and CosmeticLibrary:CountNotificationsByWeapon(cosmeticNotifications, v8)
		local v15 = EquipmentButtonSlot.new(
			v8,
			k,
			v9,
			v10 and "???" or v8,
			viewModelImageFromWeaponData,
			item.Status,
			v14
		)
		v15:SetParent(v13)
		self._weapon_slots[v8] = v15
		v6[v12] = v6[v12] or {}
		table.insert(v6[v12], v15)
		local v16 = v8
		v15.Button.MouseButton1Click:Connect(function()
			self.Interface.Equipment:SelectWeapon(v16)
		end)
		create_quick_action_button_slot(item.Class, class.Slot, class.ImageDiagonalRight, function()
			local name

			if v6[item.Class] then
				name = v6[item.Class][1].Name
			else
				name = CONSTANTS.DEFAULT_WEAPONS[class.Slot]
			end

			self.Interface.Equipment:SelectWeapon(name)
			self:ScrollTo(self._weapon_slots[name].Frame)
		end)
		v7 = v7 or v10
	end

	local v8 = #ShopLibrary.OwnableWeapons - #_GetOrder
	local ___comingsoon = clones.___comingsoon

	if ___comingsoon then
		___comingsoon.Container.Footer.Visible = v7 and v8 > 0
		___comingsoon.Container.Footer.Title.Text = "+" .. v8 .. " more weapon" .. (v8 == 1 and "" or "s") .. "!"
	end

	self.List.CanvasPosition = self._previous_canvas_position or self.List.CanvasPosition
	self._previous_canvas_position = nil
	self:_UpdateActive()
	self:_UpdateUnlockMeBubbles()
end

function Left:_GenerateDeferred()
	if self._generate_deferred then
		return
	end

	self._generate_deferred = true
	task.defer(function()
		self._generate_deferred = false
		self:_Generate()
	end)
end

function Left:_Setup()
	self.Frame.Visible = true
end

function Left:_Init()
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_Update()
	end)
	self.Background:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_Update()
	end)
	self.Background:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_Update()
	end)
	self.TopBufferFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_Update()
	end)
	self.TopBufferFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_Update()
	end)
	self.Interface.Equipment.UnlockingChanged:Connect(function()
		self:_UpdateUnlockMeBubbles()
	end)
	self.Interface.Equipment.CustomizingChanged:Connect(function()
		self:_GenerateDeferred()
	end)
	PlayerDataController:GetDataChangedSignal("FreeWeaponUnlockCheck"):Connect(function()
		self:_UpdateUnlockMeBubbles()
	end)
	PlayerDataController:GetDataChangedSignal("WeaponInventory"):Connect(function()
		self:_GenerateDeferred()
	end)
	PlayerDataController:GetDataChangedSignal("CosmeticNotifications"):Connect(function()
		self:_GenerateDeferred()
	end)
	PlayerDataController.StatisticsUpdated:Connect(function()
		self:_GenerateDeferred()
	end)
	self:_Setup()
	self:_Update()
	self:_GenerateDeferred()
end

return Left