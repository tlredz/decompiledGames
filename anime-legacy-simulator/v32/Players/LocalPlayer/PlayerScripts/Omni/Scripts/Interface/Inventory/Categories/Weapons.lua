local module = require("@game/ReplicatedStorage/Omni")
local default = {
	Sorting = {
		Rarity = true
	},
	Order = {
		Descending = true
	},
	Rarities = {}
}
local Controller = require(script.Parent.Parent.Controller)
local backpack = module.Interface:WaitForChild("Frames"):WaitForChild("Backpack")
local weapons = backpack:WaitForChild("CategoryFrames"):WaitForChild("Weapons")
local scroll = weapons:WaitForChild("List"):WaitForChild("Scroll")
local utils = weapons:WaitForChild("Utils")
local buttons = weapons:WaitForChild("Buttons")
local main = module.Inset:WaitForChild("Weapons"):WaitForChild("Main")
local weapon = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Inventory"):WaitForChild("Weapon")
local flag = false
local v2 = {}
local v3 = {}
local flag2 = false
local current = nil
local Weapons = {
	Interface = backpack
}

local function GetSolvedFilters()
	local v5 = {}

	if current then
		local rarities = {}

		for k in current.Rarities do
			rarities[k] = true
		end

		v5.Sorting = next(current.Sorting) or next(default.Sorting)
		v5.Order = next(current.Order) or next(default.Order)

		if next(rarities) then
			v5.Rarities = rarities
			return v5
		end
	else
		v5.Sorting = next(default.Sorting)
		v5.Order = next(default.Order)
	end

	return v5
end

local function GetDeletableAmount(items)
	local count = 0

	for k in items do
		local v5 = module.Data.Weapons.List[k]

		if not (v5 and v5.Name ~= "Melee" and module.Shared.Weapons.List[v5.Name] and v5.Locked ~= true) then
			continue
		end

		if module.Data.Weapons.Equipped == k then
			continue
		end

		count += 1
	end

	return count
end

local function RefreshBreathingIcons(instance, p)
	local breathings = instance.Main.Breathings
	local breathingIconTemplate = breathings.BreathingIconTemplate
	breathingIconTemplate.Visible = false
	local v5 = {}

	for _, v6 in module.Shared.Breathings.GetEntries(p.Breathings) do
		local v7 = module.Shared.Breathings.List[v6.Name]

		if not (v7 and v7.Rarities[v6.Rarity]) then
			continue
		end

		local formatted = `Slot{v6.Slot}`
		local clone = breathings:FindFirstChild(formatted)

		if not clone then
			clone = breathingIconTemplate:Clone()
			clone.Name = formatted
			clone.Parent = breathings
		end

		v5[formatted] = true
		clone.Image = v7.Icon or ""
		clone.LayoutOrder = -module.Utils.Order:Rarity(v6.Rarity)
		clone.Visible = true
	end

	for _, image in breathings:GetChildren() do
		if image == breathingIconTemplate or not image:IsA("ImageLabel") or v5[image.Name] then
			continue
		end

		image:Destroy()
	end
end

local function FilterDataChange(p, p2, list)
	if module:IsExpChange(list, p, p2) then
		return false
	end

	local v5 = list[2]

	if v5 then
		v3[v5] = true
	elseif list[1] == "Equipped" then
		flag2 = true
	end

	return true
end

function Weapons.ListRender(currentID: string, instance)
	local v5 = module.Data.Weapons.List[currentID]

	if not v5 then
		return
	end

	local v6 = module.Shared.Weapons.List[v5.Name]

	if not v6 then
		return
	end

	if not instance:GetAttribute("Loaded") then
		instance:SetAttribute("Loaded", true)
		local v7 = module.Button:Create(instance.Main, "Default")
		v7:BindFunction("Click", function()
			local currentID2 = instance:GetAttribute("CurrentID")

			if not currentID2 then
				return
			end

			local v8 = module.Data.Weapons.List[currentID2]

			if not v8 then
				return
			end

			if Controller.Mode == "Default" or Controller.Mode == "Selection" then
				local v9 = Controller.Mode == "Selection"
				local v10 = module.Libs.NeoHover.GetByIdentifier("Weapons")

				if v10 then
					v10:Click(instance, {
						IsFake = v9,
						IsSelection = v9,
						Data = v8
					})
				end
			elseif Controller.Mode == "Delete" or Controller.Mode == "Lock" then
				local v9 = module.Data.Weapons.Equipped == currentID2

				if v8.Name == "Melee" or Controller.Mode == "Delete" and (v9 or v8.Locked == true) then
					return
				else
					Controller.SelectItem(currentID2)
				end
			end
		end)
		v7:BindOnEnter("Hover", function()
			local currentID2 = instance:GetAttribute("CurrentID")

			if not currentID2 then
				return
			end

			local v8 = module.Data.Weapons.List[currentID2]

			if not v8 then
				return
			end

			local v9 = module.Libs.NeoHover.GetByIdentifier("Weapons")

			if v9 then
				local v10 = Controller.Mode == "Selection"
				v9:Open(instance, {
					IsFake = v10,
					IsSelection = v10,
					Data = v8
				})
			end
		end)
		v7:BindOnLeave("Hover", function()
			local v8 = module.Libs.NeoHover.GetByIdentifier("Weapons")

			if v8 then
				v8:Close(instance)
			end
		end)
	end

	if instance:GetAttribute("CurrentID") ~= currentID then
		instance:SetAttribute("CurrentID", currentID)
	end

	local locked = v5.Locked == true
	local visible = module.Data.Weapons.Equipped == currentID
	local visible2 = Controller.SelectedItens[currentID] == true
	instance.Main.DeleteSelection.Visible = visible2 and Controller.Mode == "Delete"
	local unlockSelection = instance.Main.UnlockSelection
	local visible3

	if visible2 then
		if Controller.Mode == "Lock" then
			visible3 = locked
		else
			visible3 = false
		end
	else
		visible3 = visible2
	end

	unlockSelection.Visible = visible3
	local lockSelection = instance.Main.LockSelection

	if visible2 then
		if Controller.Mode == "Lock" then
			visible2 = not locked
		else
			visible2 = false
		end
	end

	lockSelection.Visible = visible2
	instance.Main.InfoList.LockedIcon.Visible = locked
	instance.Main.InfoList.EquippedIcon.Visible = visible
	RefreshBreathingIcons(instance, v5)
	instance.Main.Title.Text = v5.Name
	instance.Main.Icon.Image = v6.Icon
	instance.Main.UIGradient:SetAttribute("Rarity", v6.Rarity)
	instance.Visible = true
end

local v5 = module.Utils.VirtualList.New({
	List = scroll,
	Template = weapon,
	Render = Weapons.ListRender
})

function Weapons.RefreshInventory()
	local text = string.lower(utils.Search.Text)
	local solvedFilters = GetSolvedFilters()
	local v7 = solvedFilters.Sorting ~= "Rarity"
	local v8 = v7 and module.Utils.PlayerStats.PlayerDamage(module.Data) or nil
	local v9 = {}
	local items = {}
	local v11 = {}

	for k, v12 in module.Data.Weapons.List do
		local v13 = module.Shared.Weapons.List[v12.Name]

		if not (v13 and string.find(string.lower(v12.Name), text, 1, true) ~= nil and (not solvedFilters.Rarities or solvedFilters.Rarities[v13.Rarity])) then
			continue
		end

		if Controller.Mode == "Selection" and typeof(Controller.ModeParams.NeededProperties) == "table" then
			local v14 = true

			for k2, neededProperty in Controller.ModeParams.NeededProperties do
				if v13[k2] == neededProperty then
					continue
				end

				v14 = false
				break
			end

			if not v14 or Controller.ModeParams.NeededProperties.Tradeable and not module.Shared.Trade.CanOfferWeapon({
				Type = "Weapons",
				ID = k
			}, module.Data) then
				continue
			end
		end

		table.insert(v9, {
			ID = k,
			IsLocked = v12.Locked == true,
			IsEquipped = module.Data.Weapons.Equipped == k,
			RarityOrder = module.Utils.Order:Rarity(v13.Rarity),
			DPS = not v7 and 0 or module.Shared.Weapons.GetDPS(v12, module.Data, v8) or 0
		})
		table.insert(items, k)
	end

	table.sort(v9, function(a, b)
		if solvedFilters.Sorting == "Rarity" then
			local v12 = a.RarityOrder * 10
			local v13 = b.RarityOrder * 10

			if solvedFilters.Order == "Ascending" then
				v12 *= -1
				v13 *= -1
			end

			if a.IsLocked then
				v12 += 1
			end

			if a.IsEquipped then
				v12 += 999
			end

			if b.IsLocked then
				v13 += 1
			end

			if b.IsEquipped then
				v13 += 999
			end

			return v13 < v12
		else
			if a.IsEquipped and not b.IsEquipped then
				return true
			end

			if a.IsEquipped or not b.IsEquipped then
				if solvedFilters.Order == "Descending" then
					return a.DPS > b.DPS
				end

				return a.DPS < b.DPS
			else
				return false
			end
		end
	end)

	for k, v12 in v9 do
		v11[v12.ID] = k
	end

	table.sort(items, function(a, b)
		return (v11[a] or 0) < (v11[b] or 0)
	end)
	v5.Items = items
	v5:Update()
	local weaponsInventory, v12 = module.Utils.PlayerStats.WeaponsInventory(module.Data, module.Instance)
	utils.Slots.Value.Text = module.Utils.Number:Format(v12) .. "/" .. module.Utils.Number:Format(weaponsInventory)
end

function Weapons.RefreshFromData()
	Weapons.RefreshInventory()

	for k in v3 do
		v5:RenderID(k)
	end

	if flag2 then
		v5:RenderAll()
	end

	table.clear(v3)
	flag2 = false
end

function Weapons.RefreshButtons()
	buttons.Default.Visible = Controller.Mode == "Default"
	buttons.Selection.Visible = Controller.Mode == "Selection"
	local mode = buttons.Mode
	mode.Visible = Controller.Mode ~= "Default" and Controller.Mode ~= "Selection"
end

function Weapons.Start()
	if flag then
		return
	end

	flag = true
	v2.DataChanged = module:OnDataChangedDeferred({ "Weapons" }, Weapons.RefreshFromData, FilterDataChange)
	v2.TextBoxChanged = utils.Search:GetPropertyChangedSignal("Text"):Connect(Weapons.RefreshInventory)
	v2.Loop = module.Utils.Loop:Connect({
		Time = 1,
		Callback = function()
			v5:Update()
		end
	})
	Weapons.RefreshButtons()
	Weapons.RefreshInventory()
end

function Weapons.Stop()
	flag = false

	for _, connection in v2 do
		connection:Disconnect()
	end

	local v6 = module.Libs.NeoHover.GetByIdentifier("Weapons")

	if v6 then
		v6:Close()
	end

	table.clear(v2)
	table.clear(v3)
	flag2 = false
end

function Weapons.Init()
	Controller.CategoryChanged:Connect(function(p: string)
		if p == script.Name then
			Weapons.Start()
		else
			Weapons.Stop()
		end
	end)
	Controller.ModeChanged:Connect(function()
		Weapons.RefreshButtons()
		v5:RenderAll()
	end)
	Controller.SelectedItensChanged:Connect(function()
		v5:RenderAll()
	end)
	module.Frame:OnFrameOpened(backpack, function()
		if Controller.Category == script.Name then
			Weapons.Start()
		end
	end)
	module.Frame:OnFrameClosed(backpack, function()
		Weapons.Stop()
	end)
end

module.Button:Create(main.SelectFromSelection.Main, "Default"):BindFunction("Click", function()
	if Controller.Mode ~= "Selection" then
		return
	end

	local v6 = module.Libs.NeoHover.GetByIdentifier("Weapons")
	local data = v6 and v6.Params and v6.Params.Data

	if data then
		Controller.ModeParams.Callback(data.ID)
	end
end)
module.Button:Create(buttons.Default.EquipBest.Main, "Default"):BindFunction("Click", function()
	module.Signal:Fire("General", "Weapons", "EquipBest")
end)
module.Button:Create(buttons.Default.UnequipAll.Main, "Default"):BindFunction("Click", function()
	local equipped = module.Data.Weapons.Equipped

	if not equipped then
		return
	end

	module.Signal:Fire("General", "Weapons", "Equip", equipped)
end)
module.Button:Create(buttons.Default.Delete.Main, "Default"):BindFunction("Click", function()
	Controller.SetMode("Delete")
end)
module.Button:Create(buttons.Default.Lock.Main, "Default"):BindFunction("Click", function()
	Controller.SetMode("Lock")
end)
module.Button:Create(buttons.Default.Filters.Main, "Default"):BindFunction("Click", function()
	local list = {
		Sorting = {
			Index = 1,
			Multi = false,
			List = {
				{
					Name = "Rarity",
					Text = "Rarity"
				},
				{
					Name = "DPS",
					Text = "DPS"
				}
			}
		},
		Order = {
			Index = 2,
			Multi = false,
			List = {
				{
					Name = "Descending",
					Text = "Descending"
				},
				{
					Name = "Ascending",
					Text = "Ascending"
				}
			}
		},
		Rarities = {
			Index = 3,
			Multi = true,
			List = {}
		}
	}

	for k, rarity in module.Utils.Order.Rarities do
		local count = 0

		for _, v7 in module.Data.Weapons.List do
			local v8 = module.Shared.Weapons.List[v7.Name]

			if v8 and v8.Rarity == rarity then
				count += 1
			end
		end

		list.Rarities.List[k] = {
			Name = rarity,
			Rarity = rarity,
			Text = `{rarity} ({count > 0 and `<font color="rgb(50,255,50)">{count}</font>` or "<font color=\"rgb(255,50,50)\">0</font>"})`
		}
	end

	module.Signal:FireSelf("Interface", "Filters", "Start", {
		PastUI = backpack,
		Current = current,
		List = list,
		Default = default,
		Callback = function(p)
			current = p
			Weapons.RefreshInventory()
		end
	})
end)
module.Button:Create(buttons.Mode.Cancel.Main, "Default"):BindFunction("Click", function()
	Controller.SetMode("Default")
end)
module.Button:Create(buttons.Mode.Confirm.Main, "Default"):BindFunction("Click", function()
	local copy = module.Utils.Table:DeepCopy(Controller.SelectedItens)

	if Controller.Mode == "Delete" then
		local deletableAmount = GetDeletableAmount(copy)

		if deletableAmount == 0 then
			return
		end

		module.Signal:FireSelf("Interface", "Confirmation", "Start", {
			Title = "Delete",
			Description = `Permanently delete {deletableAmount} {deletableAmount == 1 and "weapon" or "weapons"}? This cannot be undone.`,
			ConfirmText = "Delete",
			CancelText = "Cancel",
			Callback = function(p)
				if not p or Controller.Mode ~= "Delete" then
					return
				end

				module.Signal:Fire("General", "Weapons", "Delete", copy)
				Controller.SetMode("Default")
			end
		})
	else
		if Controller.Mode == "Lock" then
			module.Signal:Fire("General", "Weapons", "Lock", copy)
		end

		Controller.SetMode("Default")
	end
end)
module.Button:Create(buttons.Mode.SelectAll.Main, "Default"):BindFunction("Click", function()
	local v6 = {}

	for k, v7 in module.Data.Weapons.List do
		if Controller.SelectedItens[k] then
			continue
		end

		local v8 = module.Data.Weapons.Equipped == k

		if v7.Name ~= "Melee" and (Controller.Mode ~= "Delete" or v7.Locked ~= true and not v8) then
			v6[k] = true
		end
	end

	Controller.BulkSelectItems(v6)
end)
module.Button:Create(buttons.Mode.DeselectAll.Main, "Default"):BindFunction("Click", function()
	Controller.DeselectAllItems()
end)
return Weapons