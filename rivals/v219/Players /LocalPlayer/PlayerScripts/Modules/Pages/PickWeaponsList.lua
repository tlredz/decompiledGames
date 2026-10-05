local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadService = game:GetService("GamepadService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.CONSTANTS)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
require(ReplicatedStorage.Modules.ShopLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ControlsController"))
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
local FFlagController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FFlagController"))
local DuelController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("DuelController"))
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("WeaponStatusHandler"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local VoteBanFrame = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("VoteBanFrame"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local pickWeaponRandomListSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("PickWeaponRandomListSlot")
local pickWeaponListChosenSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("PickWeaponListChosenSlot")
local pickWeaponListSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("PickWeaponListSlot")
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.ChosenWeaponsFrame = self.PageFrame:WaitForChild("ChosenWeapons")
	self.HeaderFrame = self.PageFrame:WaitForChild("Header")
	self.FreeWeaponsFrame = self.HeaderFrame:WaitForChild("FreeWeapons")
	self.MapFrame = self.HeaderFrame:WaitForChild("Map")
	self.MapTitle = self.MapFrame:WaitForChild("Title")
	self.ListContainer = self.PageFrame:WaitForChild("ListContainer")
	self.List = self.ListContainer:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.LastPickedDivider = self.Container:WaitForChild("LastPickedDivider")
	self.CantBeClosedFromInputs = true
	self._current_slot = 1
	self._chosen_weapons = {}
	self._chosen_weapon_slots = {}
	self._pick_weapon_slots = {}
	self._ban_frames = {}
	self:_Init()
	return self
end

function object:SetCurrentSlot(current_slot)
	self._chosen_weapon_slots[self._current_slot].Button.Hover.Visible = false
	self._current_slot = current_slot
	self.ChosenWeaponsFrame:TweenPosition(
		UDim2.new(0.5 - 0.125 * (self._current_slot - 1), 0, 0.1, 0),
		"Out",
		"Quint",
		0.25,
		true
	)
	self._chosen_weapon_slots[self._current_slot].Button.Hover.Visible = true
	self._chosen_weapon_slots[self._current_slot].Button.Background.ImageTransparency = 0
	self._chosen_weapon_slots[self._current_slot].Button.Hover.Size = UDim2.new(1.5, 0, 1.5, 0)
	self._chosen_weapon_slots[self._current_slot].Button.Hover:TweenSize(
		UDim2.new(1, 8, 1, 8),
		"Out",
		"Back",
		0.25,
		true
	)

	for _, _pick_weapon_slot in pairs(self._pick_weapon_slots) do
		_pick_weapon_slot:Destroy()
	end

	self._pick_weapon_slots = {}
	self.LastPickedDivider.Visible = false
	local v = {}

	for _, v2 in pairs(ItemLibrary.ItemsAlphabetized) do
		local item = ItemLibrary.Items[v2]

		if not (item.Class == ItemLibrary.SlotToClass[self._current_slot].Name or FighterController.LocalFighter:Get("WeaponClassRestrictionDisabled")) then
			continue
		end

		table.insert(v, item)
	end

	table.sort(v, function(a, b)
		local item = ItemLibrary.Items[a.Name]
		local item2 = ItemLibrary.Items[b.Name]

		if item.Class ~= item2.Class then
			return ItemLibrary.Classes[item.Class].Slot < ItemLibrary.Classes[item2.Class].Slot
		end

		if item.Status == item2.Status then
			return Utility:StringLessThan(a.Name, b.Name)
		end

		return ItemLibrary.Statuses[item.Status].Value > ItemLibrary.Statuses[item2.Status].Value
	end)
	local lastPickedWeapons = FighterController.LocalFighter and FighterController.LocalFighter:Get("LastPickedWeapons")
	local count = 0
	local names = {}

	for k, v2 in pairs(v) do
		if not FighterController.LocalFighter then
			continue
		end

		local weaponPool = FighterController.LocalFighter:Get("WeaponPool")
		local index

		if FighterController.LocalFighter:Get("WeaponPoolFilterType") == "Blacklist" then
			index = table.find(weaponPool, v2.Name)
		else
			index = false
		end

		if not (FighterController.LocalFighter and (FighterController.LocalFighter:CanUseWeapon(v2.Name) or index)) then
			continue
		end

		local weaponData = PlayerDataController:GetWeaponData(v2.Name)
		local v3 = lastPickedWeapons and table.find(lastPickedWeapons, v2.Name) ~= nil
		local clone = pickWeaponListSlot:Clone()
		clone.LayoutOrder = v3 and -3 or k * 2
		clone.ZIndex = clone.LayoutOrder
		clone.Button.Icon.Picture.Image = weaponData and ItemLibrary:GetViewModelImageFromWeaponData(weaponData) or ItemLibrary:GetViewModelImage(v2.Name) or ""
		clone.Button.Title.Text = v2.Name
		clone.Parent = self.Container
		ButtonEffect:Add(clone.Button, nil, {
			HoverRatio = 1.025,
			ReleaseRatio = 1.025
		})
		table.insert(self._pick_weapon_slots, clone)
		WeaponStatusHandler:ApplyItemStatusToText(clone.Button.Title, v2.Status)

		if index then
			clone.Button.Icon.ClipsDescendants = true
			clone.Button.Title.Visible = false
			local v4 = VoteBanFrame.new(clone.Button, UDim2.new(1, 0, 0.9, 0))
			table.insert(self._ban_frames, v4)
			v4.CreateSound:Connect(function(...)
				Utility:CreateSound(...)
			end)
			task.delay(count * 0.125, v4.Play, v4, nil, true)
			count += 1
		else
			local v4 = v2
			clone.Button.MouseButton1Click:Connect(function()
				self:_InputPickWeapon(v4.Name)
			end)
			table.insert(names, v2.Name)
		end

		self.LastPickedDivider.Visible = self.LastPickedDivider.Visible or v3
	end

	if #names > 1 then
		local clone = pickWeaponRandomListSlot:Clone()
		clone.LayoutOrder = -1
		clone.Parent = self.Container
		ButtonEffect:Add(clone.Button, nil, {
			HoverRatio = 1.025,
			ReleaseRatio = 1.025
		})
		table.insert(self._pick_weapon_slots, clone)
		clone.Button.MouseButton1Click:Connect(function()
			self:_InputPickWeapon(names[math.random(#names)])
		end)
	end

	table.sort(self._pick_weapon_slots, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)

	for k, _pick_weapon_slot in pairs(self._pick_weapon_slots) do
		_pick_weapon_slot.Button.Size = UDim2.new(0.75, 0, 1, 0)
		_pick_weapon_slot.Button:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Back", 0.05 * k, true)
	end

	local list = self.List
	local canvasPosition

	if FighterController.LocalFighter:Get("WeaponClassRestrictionDisabled") then
		canvasPosition = self.List.CanvasPosition
	else
		canvasPosition = Vector2.new(0, 0)
	end

	list.CanvasPosition = canvasPosition
end

function object:PickWeapon(p2, p3)
	local weaponData = PlayerDataController:GetWeaponData(p3)
	self._chosen_weapons[p2] = p3
	self._chosen_weapon_slots[p2].Button.Picture.Image = weaponData and ItemLibrary:GetViewModelImageFromWeaponData(weaponData) or ItemLibrary:GetViewModelImage(p3) or ""
end

function object:Finish()
	local duel = DuelController:GetDuel(Players.LocalPlayer)

	if duel and duel.LocalDueler and duel.LocalDueler:GetStaggeredSpawnsTurn() then
		ReplicatedStorage.Remotes.Duels.PickWeaponsAheadOfTime:FireServer(self._chosen_weapons)
	else
		ReplicatedStorage.Remotes.Replication.Fighter.PickWeapons:FireServer(self._chosen_weapons)
	end

	self.Closed:Fire()

	if ControlsController.CurrentControls == "Gamepad" then
		GamepadService:DisableGamepadCursor()
	end
end

function object:Start()
	self:Clear()

	for i = 1, FighterController.LocalFighter:GetMaxEquippableWeapons() do
		local clone = pickWeaponListChosenSlot:Clone()
		clone.LayoutOrder = i
		clone.Parent = self.ChosenWeaponsFrame
		ButtonEffect:Add(clone.Button)
		self._chosen_weapon_slots[i] = clone
		local v = i
		clone.Button.MouseButton1Click:Connect(function()
			if v == 1 or self._chosen_weapons[v - 1] then
				self:SetCurrentSlot(v)
			end
		end)
	end

	self:SetCurrentSlot(1)

	if ControlsController.CurrentControls == "Gamepad" then
		GamepadService:EnableGamepadCursor(self.ChosenWeaponsFrame)
	end

	self:_UpdateMap()
	self:_UpdateFreeWeapons()
end

function object:Clear()
	for _, _chosen_weapon_slot in pairs(self._chosen_weapon_slots) do
		_chosen_weapon_slot:Destroy()
	end

	for _, _pick_weapon_slot in pairs(self._pick_weapon_slots) do
		_pick_weapon_slot:Destroy()
	end

	for _, _ban_frame in pairs(self._ban_frames) do
		_ban_frame:Destroy()
	end

	self._current_slot = 1
	self._chosen_weapons = {}
	self._chosen_weapon_slots = {}
	self._pick_weapon_slots = {}
	self._ban_frames = {}
end

function object:Open(...)
	Page.Open(self, ...)
	self:Start()
end

function object:_InputPickWeapon(p)
	self:PickWeapon(self._current_slot, p)

	if self._current_slot == FighterController.LocalFighter:GetMaxEquippableWeapons() then
		self:Finish()
	else
		self:SetCurrentSlot(self._current_slot + 1)
	end
end

function object:_UpdateFreeWeapons()
	self.FreeWeaponsFrame.Visible = FFlagController:IsFreeWeaponsActive()
	self.MapFrame.Size = self.FreeWeaponsFrame.Visible and UDim2.new(1, 0, 1.5, 0) or UDim2.new(1, 0, 1, 0)
	self.MapTitle.Size = self.FreeWeaponsFrame.Visible and UDim2.new(0.875, 0, 0.467, 0) or UDim2.new(0.875, 0, 0.7, 0)
	self:_UpdateMap()
end

function object:_UpdateMap()
	local duel = DuelController:GetDuel(Players.LocalPlayer)
	local name = duel and duel.Map and duel.Map.Name
	local isInShootingRange = FighterController.LocalFighter and FighterController.LocalFighter:Get("IsInShootingRange")
	local mapFrame = self.MapFrame
	local visible

	if name or isInShootingRange then
		visible = not self.FreeWeaponsFrame.Visible
	else
		visible = isInShootingRange
	end

	mapFrame.Visible = visible
	self.MapTitle.Text = name and "Map: " .. name or isInShootingRange and "Try out any weapon here for free!" or ""
end

function object:_Init()
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
	end)
	self.List:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		self.ListContainer.ClipsDescendants = self.List.CanvasPosition.Y > 5
	end)
end

return object._new()