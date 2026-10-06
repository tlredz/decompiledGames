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
local color = Color3.fromRGB(255, 255, 127)
local Controller = require(script.Parent.Parent.Controller)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Presentation = require(ReplicatedStorage.Omni.Shared.Mutations.Presentation)
local fighters = module.Interface:WaitForChild("Frames"):WaitForChild("Fighters")
local main = fighters:WaitForChild("Main")
local scroll = main:WaitForChild("List"):WaitForChild("Scroll")
local utils = main:WaitForChild("Utils")
local buttons = fighters:WaitForChild("Buttons")
local main2 = module.Inset:WaitForChild("Fighters"):WaitForChild("Main")
local fighter = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Inventory"):WaitForChild("Fighter")
local flag = false
local v2 = {}
local flag2 = false
local v3 = {}
local flag3 = false
local current = nil
local Fighters = {
	Interface = fighters
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

local function GetSellSummary(items)
	local v5 = {}
	local count = 0
	local names = {}

	for k in items do
		local v6 = module.Data.Fighters.List[k]

		if not v6 then
			continue
		end

		local v7 = module.Shared.Fighters.List[v6.Name]

		if not (v7 and v7.Price and v7.Sellable ~= false and v6.Locked ~= true) then
			continue
		end

		if module.Data.Fighters.Equipped[k] == true then
			continue
		end

		local name = v7.Price.Name

		if not v5[name] then
			table.insert(names, name)
		end

		v5[name] = (v5[name] or 0) + v7.Price.Amount
		count += 1
	end

	table.sort(names)
	local result = {}

	for _, v6 in names do
		table.insert(result, (`{module.Utils.Number:Format(v5[v6])} {v6}`))
	end

	return count, result
end

local function FilterDataChange(p, p2, list)
	if module:IsExpChange(list, p, p2) then
		return false
	end

	local v5 = list[2]

	if v5 then
		v3[v5] = true
	elseif list[1] == "Equipped" then
		flag3 = true
	end

	return true
end

function Fighters.ListRender(currentID: string, instance)
	local mutationIcon = instance.Main.MiscList.MutationIcon
	mutationIcon.LayoutOrder = 2
	mutationIcon.Visible = false
	mutationIcon.Image = ""
	local v5 = module.Data.Fighters.List[currentID]

	if not v5 then
		return
	end

	local v6 = module.Shared.Fighters.List[v5.Name]

	if not v6 then
		return
	end

	if not instance:GetAttribute("Loaded") then
		instance:SetAttribute("Loaded", true)
		local v7 = module.Button:Create(instance.Main, "Default")
		v7:BindFunction("Click", function()
			if Controller.ModeLocked and Controller.Mode ~= "Selection" then
				return
			end

			local currentID2 = instance:GetAttribute("CurrentID")

			if not currentID2 then
				return
			end

			local v8 = module.Data.Fighters.List[currentID2]

			if not v8 then
				return
			end

			local v9 = module.Data.Fighters.Equipped[currentID2] == true

			if Controller.Mode == "Default" or Controller.Mode == "Selection" then
				local v10 = Controller.Mode == "Selection"
				local v11 = module.Libs.NeoHover.GetByIdentifier("Fighters")

				if v11 then
					v11:Click(instance, {
						IsFake = v10,
						IsSelection = v10,
						Data = v8
					})
				end
			elseif Controller.Mode == "Sell" or Controller.Mode == "Deconstruct" then
				if v9 or v8.Locked == true then
					return
				end

				local v10 = module.Shared.Fighters.List[v8.Name]

				if not v10 or Controller.Mode == "Sell" and v10.Sellable == false or Controller.Mode == "Deconstruct" and not module.Shared.FighterFeed.GetDeconstructReward(v8) then
					return
				end

				Controller.SelectItem(currentID2)
			else
				Controller.SelectItem(currentID2)
			end
		end)
		v7:BindOnEnter("Hover", function()
			if Controller.ModeLocked and Controller.Mode ~= "Selection" then
				return
			end

			local currentID2 = instance:GetAttribute("CurrentID")

			if not currentID2 then
				return
			end

			local v8 = module.Data.Fighters.List[currentID2]

			if not v8 then
				return
			end

			local v9 = module.Libs.NeoHover.GetByIdentifier("Fighters")

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
			local v8 = module.Libs.NeoHover.GetByIdentifier("Fighters")

			if v8 then
				v8:Close(instance)
			end
		end)
	end

	if instance:GetAttribute("CurrentID") ~= currentID then
		instance:SetAttribute("CurrentID", currentID)
		local v7 = module.Utils.Info:Get(v6.Price.Type, v6.Price.Name) or {}
		instance.Main.SellSelection.Icon.Image = v7.Icon or ""
		instance.Main.SellSelection.Title.Text = "+" .. module.Utils.Number:Format(v6.Price.Amount)
		module.Utils.Camera.ViewportCharacter({
			Viewport = instance.Main.Viewport,
			Animation = module.Utils.Characters.GetCharacterAnimation(v5.Name, "Idle"),
			Character = module.Utils.Characters.Get({
				Name = v5.Name,
				Shiny = v5.Shiny,
				RemoveHumanoidStates = true
			})
		})
	end

	local v7 = module.Shared.Traits.Get(v5)
	local image = not v7 and "" or v7.Icon or ""
	local v9 = Presentation.Get(v5.Mutations)
	local icon = v9 and v9.Icon or ""
	local locked = v5.Locked == true
	local visible = module.Data.Fighters.Equipped[currentID] == true
	local v11 = Controller.SelectedItens[currentID] == true
	instance.Main.DeconstructSelection.Visible = v11 and Controller.Mode == "Deconstruct"
	local sellSelection = instance.Main.SellSelection
	sellSelection.Visible = v11 == true and Controller.Mode == "Sell"
	local unlockSelection = instance.Main.UnlockSelection
	local visible2

	if v11 == true then
		if Controller.Mode == "Lock" then
			visible2 = locked
		else
			visible2 = false
		end
	else
		visible2 = false
	end

	unlockSelection.Visible = visible2
	local lockSelection = instance.Main.LockSelection
	lockSelection.Visible = v11 == true and Controller.Mode == "Lock" and not locked
	instance.Main.InfoList.LockedIcon.Visible = locked
	instance.Main.InfoList.EquippedIcon.Visible = visible
	instance.Main.ShinyIndicator.Visible = v5.Shiny == true
	instance.Main.MiscList.TraitIcon.Image = image
	instance.Main.MiscList.TraitIcon.Visible = image ~= ""
	instance.Main.MiscList.TraitIcon.UIGradient:SetAttribute("Rarity", v7 and v7.Rarity or nil)
	mutationIcon.Image = icon
	mutationIcon.Visible = icon ~= ""
	local shiny = v5.Shiny == true
	local displayName = module.Shared.Fighters.GetDisplayName(v5.Name)
	local title = instance.Main.Title

	if shiny then
		displayName = `{displayName} ⭐` or displayName
	end

	title.Text = displayName
	instance.Main.Title.TextColor3 = shiny and color or fighter.Main.Title.TextColor3
	instance.Main.UIGradient:SetAttribute("Rarity", v6.Rarity)
	instance.Visible = true
end

function Fighters.ListRelease(instance)
	instance:SetAttribute("CurrentID", nil)
	module.Utils.Camera.ClearViewport(instance.Main.Viewport)
end

local v5 = module.Utils.VirtualList.New({
	List = scroll,
	Template = fighter,
	Render = Fighters.ListRender,
	Release = Fighters.ListRelease,
	BufferRows = 1
})

function Fighters.RefreshInventory()
	local text = string.lower(utils.Search.Text)
	local solvedFilters = GetSolvedFilters()
	local v7 = solvedFilters.Sorting ~= "Rarity"
	local v8 = {}
	local items = {}
	local v10 = {}

	for k, v11 in module.Data.Fighters.List do
		local v12 = module.Shared.Fighters.List[v11.Name]

		if not v12 then
			continue
		end

		local displayName = module.Shared.Fighters.GetDisplayName(v11.Name)
		local v13 = string.find(string.lower(v11.Name), text, 1, true) ~= nil or string.find(
			string.lower(displayName),
			text,
			1,
			true
		) ~= nil

		if not v13 then
			continue
		end

		if typeof(Controller.ModeParams.NeededProperties) == "table" then
			local v14 = true

			for k2, neededProperty in Controller.ModeParams.NeededProperties do
				if v12[k2] == neededProperty then
					continue
				end

				v14 = false
				break
			end

			if not v14 then
				continue
			end
		end

		if not (not solvedFilters.Rarities or solvedFilters.Rarities[v12.Rarity]) then
			continue
		end

		table.insert(v8, {
			ID = k,
			IsLocked = v11.Locked == true,
			IsEquipped = module.Data.Fighters.Equipped[k] == true,
			RarityOrder = module.Utils.Order:Rarity(v12.Rarity),
			DPS = v7 and module.Shared.Fighters.GetFighterDPS(v11, module.Data) or 0
		})

		if v13 then
			table.insert(items, k)
		end
	end

	table.sort(v8, function(a, b)
		if solvedFilters.Sorting == "Rarity" then
			local v11 = a.RarityOrder * 10
			local v12 = b.RarityOrder * 10

			if solvedFilters.Order == "Ascending" then
				v11 *= -1
				v12 *= -1
			end

			if a.IsLocked then
				v11 += 1
			end

			if a.IsEquipped then
				v11 += 999
			end

			if b.IsLocked then
				v12 += 1
			end

			if b.IsEquipped then
				v12 += 999
			end

			return v12 < v11
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

	for k, v11 in v8 do
		v10[v11.ID] = k
	end

	table.sort(items, function(a, b)
		return (v10[a] or 0) < (v10[b] or 0)
	end)
	v5.Items = items
	v5:Update()
	local fightersInventory, v11 = module.Utils.PlayerStats.FightersInventory(module.Data, module.Instance)
	local fightersEquipped, v12 = module.Utils.PlayerStats.FightersEquipped(module.Data, module.Instance)
	utils.Slots.Value.Text = module.Utils.Number:Format(v11) .. "/" .. module.Utils.Number:Format(fightersInventory)
	utils.Equipped.Value.Text = module.Utils.Number:Format(v12) .. "/" .. module.Utils.Number:Format(fightersEquipped)
end

function Fighters.RefreshFromData()
	Fighters.RefreshInventory()

	for k in v3 do
		v5:RenderID(k)
	end

	if flag3 then
		for k in module.Data.Fighters.Equipped do
			v5:RenderID(k)
		end
	end

	table.clear(v3)
	flag3 = false
end

function Fighters.RefreshButtons()
	if Controller.Mode ~= "Selection" then
		buttons.Selection.Text = "Select the fighter!"
	end

	buttons.Default.Visible = Controller.Mode == "Default"
	buttons.Selection.Visible = Controller.Mode == "Selection"
	local mode = buttons.Mode
	mode.Visible = Controller.Mode ~= "Default" and Controller.Mode ~= "Selection"
end

function Fighters.Start()
	if flag then
		return
	end

	flag = true
	v2.DataChanged = module:OnDataChangedDeferred({ "Fighters" }, Fighters.RefreshFromData, FilterDataChange)
	v2.TextBoxChanged = utils.Search:GetPropertyChangedSignal("Text"):Connect(Fighters.RefreshInventory)
	v2.Loop = module.Utils.Loop:Connect({
		Time = 1,
		Callback = function()
			v5:Update()
		end
	})
	v5:Resume()
	Fighters.RefreshButtons()
	Fighters.RefreshInventory()
end

function Fighters.Stop()
	flag = false

	for _, connection in v2 do
		connection:Disconnect()
	end

	local v6 = module.Libs.NeoHover.GetByIdentifier("Fighters")

	if v6 then
		v6:Close()
	end

	v5:Suspend()
	table.clear(v2)
	table.clear(v3)
	flag3 = false
end

function Fighters.Init()
	Controller.CategoryChanged:Connect(function(p: string)
		if p == script.Name then
			Fighters.Start()
		else
			Fighters.Stop()
		end
	end)
	Controller.ModeChanged:Connect(function()
		local v6 = Controller.Mode ~= "Default" and module.Libs.NeoHover.GetByIdentifier("Fighters")

		if v6 then
			v6:Close()
		end

		if not flag then
			Fighters.RefreshButtons()
			return
		end

		Fighters.RefreshButtons()
		Fighters.RefreshInventory()
		v5:RenderAll()
	end)
	Controller.SelectedItensChanged:Connect(function()
		v5:RenderAll()
	end)
	module.Frame:OnFrameOpened(fighters, function()
		if Controller.Category == script.Name then
			Fighters.Start()
		else
			Controller.SetCategory(script.Name)
		end
	end)
	module.Frame:OnFrameClosed(fighters, function()
		Fighters.Stop()
	end)
end

module.Button:Create(main2.SelectFromSelection.Main, "Default"):BindFunction("Click", function()
	if Controller.Mode ~= "Selection" then
		return
	end

	local v6 = module.Libs.NeoHover.GetByIdentifier("Fighters")
	local data = v6 and v6.Params and v6.Params.Data

	if data then
		Controller.ModeParams.Callback(data.ID)
	end
end)
module.Button:Create(buttons.Default.EquipBest.Main, "Default"):BindFunction("Click", function()
	module.Signal:Fire("General", "Fighters", "EquipBest")
end)
module.Button:Create(buttons.Default.UnequipAll.Main, "Default"):BindFunction("Click", function()
	module.Signal:Fire("General", "Fighters", "UnequipAll")
end)
module.Button:Create(buttons.Default.Sell.Main, "Default"):BindFunction("Click", function()
	Controller.SetMode("Sell")
end)
module.Button:Create(buttons.Default.Lock.Main, "Default"):BindFunction("Click", function()
	Controller.SetMode("Lock")
end)
module.Button:Create(buttons.Default.Teams.Main, "Default"):BindFunction("Click", function()
	module.Signal:FireSelf("Interface", "FighterTeams", "Open", fighters)
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

		for _, v7 in module.Data.Fighters.List do
			local v8 = module.Shared.Fighters.List[v7.Name]

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
		PastUI = fighters,
		Current = current,
		List = list,
		Default = default,
		Callback = function(p)
			current = p
			Fighters.RefreshInventory()
		end
	})
end)
module.Button:Create(buttons.Mode.Cancel.Main, "Default"):BindFunction("Click", function()
	if flag2 then
		return
	end

	Controller.SetMode("Default")
end)
module.Button:Create(buttons.Mode.Confirm.Main, "Default"):BindFunction("Click", function()
	if flag2 then
		return
	end

	local copy = module.Utils.Table:DeepCopy(Controller.SelectedItens)

	if Controller.Mode == "Sell" then
		local v6, v7 = GetSellSummary(copy)

		if v6 == 0 then
			return
		end

		module.Signal:FireSelf("Interface", "Confirmation", "Start", {
			Title = "Sell",
			Description = `Sell {v6} {v6 == 1 and "fighter" or "fighters"} for {table.concat(v7, ", ")}?`,
			ConfirmText = "Sell",
			CancelText = "Cancel",
			Callback = function(p)
				if not p or Controller.Mode ~= "Sell" then
					return
				end

				module.Signal:Fire("General", "Fighters", "Sell", copy)
				Controller.SetMode("Default")
			end
		})
	else
		if Controller.Mode == "Lock" then
			module.Signal:Fire("General", "Fighters", "Lock", copy)
		elseif Controller.Mode == "Deconstruct" then
			local v6 = {}
			local count = 0

			for k in copy do
				local v7 = module.Data.Fighters.List[k]

				if not v7 or v7.Locked or module.Data.Fighters.Equipped[k] then
					return
				end

				local deconstructReward = module.Shared.FighterFeed.GetDeconstructReward(v7)

				if not deconstructReward then
					return
				end

				v6[deconstructReward.Name] = (v6[deconstructReward.Name] or 0) + deconstructReward.Amount
				count += 1
			end

			if count == 0 then
				return
			end

			local v7 = {}

			for _, v8 in module.Shared.FighterFeed.GetFoods() do
				if v6[v8] then
					table.insert(v7, (`{module.Utils.Number:Format(v6[v8])}x {v8}`))
				end
			end

			module.Signal:FireSelf("Interface", "Confirmation", "Start", {
				Title = "Deconstruct",
				Description = `Convert {count} fighters into {table.concat(v7, ", ")} (Food)?`,
				ConfirmText = "Deconstruct",
				CancelText = "Cancel",
				Callback = function(p)
					if not p or flag2 then
						return
					end

					flag2 = true
					local success, result = pcall(function()
						return module.Signal:Invoke("General", "Fighters", "Deconstruct", copy)
					end)
					flag2 = false

					if success and result then
						Controller.SetMode("Default")
					else
						module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
							Message = "Unable to deconstruct this selection. Check locked or equipped fighters.",
							Color = Color3.new(1, 1, 0)
						})
					end
				end
			})
			return
		end

		Controller.SetMode("Default")
	end
end)
module.Button:Create(buttons.Mode.SelectAll.Main, "Default"):BindFunction("Click", function()
	local v6 = {}

	for k, v7 in module.Data.Fighters.List do
		local v8 = module.Shared.Fighters.List[v7.Name]

		if not (v8 and (Controller.Mode ~= "Sell" or v8.Sellable ~= false)) then
			continue
		end

		if not (Controller.Mode ~= "Deconstruct" or table.find(v5.Items, k) and module.Shared.FighterFeed.GetDeconstructReward(v7)) or Controller.SelectedItens[k] then
			continue
		end

		local v9 = module.Data.Fighters.Equipped[k] == true

		if not (Controller.Mode == "Lock" and v7.Locked ~= true or (Controller.Mode == "Sell" or Controller.Mode == "Deconstruct") and v7.Locked ~= true and not v9) then
			continue
		end

		v6[k] = true
	end

	Controller.BulkSelectItems(v6)
end)
module.Button:Create(buttons.Mode.DeselectAll.Main, "Default"):BindFunction("Click", function()
	Controller.DeselectAllItems()
end)
return Fighters