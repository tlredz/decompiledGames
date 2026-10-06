local module = require("@game/ReplicatedStorage/Omni")
local accessories = module.Inset:WaitForChild("Accessories")
local background = accessories:WaitForChild("Background")
local main = accessories:WaitForChild("Main")
local perkTemplate = main:WaitForChild("PerkTemplate")
local v = module.Libs.NeoHover.Create(accessories, script.Name)
local clones = {}
local Accessories = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function GetInventoryController()
	return module.Signal:InvokeSelf("Interface", "Inventory", "GetController")
end

local function CanEvolve(p)
	local inventoryController = GetInventoryController() -- equivalent call inferred; original call site unknown

	if not inventoryController or (inventoryController.Category ~= "Accessories" or inventoryController.Mode ~= "Default") then
		return false
	end

	local rarity = module.Shared.Accessories.GetRarity(p)
	return module.Shared.Accessories.GetNextRarity(rarity) ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetButtonGradient(p, enabled: boolean)
	p.Main.UIGradient.Enabled = enabled
	p.Main.Title.UIGradient.Enabled = enabled
end

local function RefreshPerks(p, rarity: string)
	for _, v2 in clones do
		v2:Destroy()
	end

	table.clear(clones)

	for k, v2 in p.Perks or {} do
		local clone = perkTemplate:Clone()
		clone.Name = k
		clone.Value.Text = module.Utils.Multipliers.ToStringSingle({
			Name = k,
			ShowPercentage = true,
			MultiplierArray = { module.Shared.Accessories.ScalePerk(v2, rarity) }
		})
		clone.Parent = main
		clone.Visible = true
		table.insert(clones, clone)
	end
end

function Accessories.Refresh()
	local element = v.Element
	local params = v.Params

	if not (element and params) then
		return
	end

	local data = params.Data
	local playerData = params.PlayerData or module.Data
	local v2 = module.Shared.Accessories.List[data.Name]

	if not v2 then
		return
	end

	local locked = data.Locked == true
	local visible = (playerData.Accessories.Equipped or {})[v2.Type] == data.ID

	if params.IsIndex then
		local canAutoManage = module.Shared.Accessories.CanAutoManage(data.Name)
		local enabled = module.Data.Accessories.AutoLock[data.Name] == true
		local enabled2 = module.Data.Accessories.AutoDelete[data.Name] == true
		main.Lock.Main.Title.Text = "Auto Lock"
		main.Delete.Main.Title.Text = "Auto Delete"
		SetButtonGradient(main.Lock, enabled) -- equivalent call inferred; original call site unknown
		SetButtonGradient(main.Delete, enabled2) -- equivalent call inferred; original call site unknown
		main.Unlock.Visible = false
		main.Lock.Visible = canAutoManage
		main.Equip.Visible = false
		main.Unequip.Visible = false
		main.Delete.Visible = canAutoManage
		main.Evolve.Visible = false
	else
		main.Lock.Main.Title.Text = "Lock"
		main.Delete.Main.Title.Text = "Delete"
		SetButtonGradient(main.Lock, true) -- equivalent call inferred; original call site unknown
		SetButtonGradient(main.Delete, true) -- equivalent call inferred; original call site unknown

		if params.IsFake then
			main.Unlock.Visible = false
			main.Lock.Visible = false
			main.Equip.Visible = false
			main.Unequip.Visible = false
			main.Delete.Visible = false
			main.Evolve.Visible = false
		else
			main.Unlock.Visible = locked
			main.Lock.Visible = not locked
			main.Equip.Visible = not visible
			main.Unequip.Visible = visible
			main.Delete.Visible = not (locked or visible)
			local evolve = main.Evolve
			local inventoryController = GetInventoryController() -- equivalent call inferred; original call site unknown
			local visible2

			if inventoryController and inventoryController.Category == "Accessories" and inventoryController.Mode == "Default" then
				local rarity = module.Shared.Accessories.GetRarity(data)
				visible2 = module.Shared.Accessories.GetNextRarity(rarity) ~= nil
			else
				visible2 = false
			end

			evolve.Visible = visible2
		end
	end
end

function Accessories:Open(p, p2)
	if not p2 and v.UpdateMode ~= "Mouse" and v.Element then
		return
	end

	local data = p.Data
	local v2 = module.Shared.Accessories.List[data.Name]

	if not v2 then
		return
	end

	local rarity = module.Shared.Accessories.GetRarity(data)
	main.Header.Labels.Title.Text = data.Name
	main.Header.Labels.Rarity.Text = rarity
	background.RarityStroke.UIGradient:SetAttribute("Rarity", rarity)
	main.Header.Labels.Rarity.UIGradient:SetAttribute("Rarity", rarity)
	main.SelectFromSelection.Visible = p.IsSelection == true
	RefreshPerks(v2, rarity)
	main.Header.Visibility.Viewport.Image = v2.Icon
	Accessories.Refresh()
	return true
end

function Accessories:Close(p2)
	if self and not p2 and v.UpdateMode ~= "Mouse" and v.Element then
		return
	end

	v:SetUpdateMode("Mouse")
	return true
end

function Accessories.Click(p, p2)
	if p == v.Element then
		if v.UpdateMode == "Mouse" then
			v:SetUpdateMode("Element")
		else
			v:SetUpdateMode("Mouse")
		end
	else
		if v.Element then
			v:Open(p, p2, true)
			return
		end

		v:SetUpdateMode("Element")
		v:Open(p, p2)
	end
end

v:SetSafeBound(0.1)
v:SetRestrictedToOne(true)
v:SetOpenHandler(Accessories.Open, {
	IsFake = "boolean",
	Data = {
		Name = "string"
	}
})
v:SetCloseHandler(Accessories.Close)
v:SetClickHandler(Accessories.Click)
v:SetRefreshHandler(Accessories.Refresh)
module.Button:Create(main.Equip.Main, "Default"):BindFunction("Click", function()
	local params = v.Params

	if not params then
		return
	end

	local data = params.Data
	module.Signal:Fire("General", "Accessories", "Equip", data.ID)
end)
module.Button:Create(main.Unequip.Main, "Default"):BindFunction("Click", function()
	local params = v.Params

	if not params then
		return
	end

	local data = params.Data
	module.Signal:Fire("General", "Accessories", "Equip", data.ID)
end)
module.Button:Create(main.Lock.Main, "Default"):BindFunction("Click", function()
	local params = v.Params

	if not params then
		return
	end

	local data = params.Data

	if params.IsIndex then
		module.Signal:Fire("General", "Accessories", "AutoLock", data.Name)
		return
	end

	module.Signal:Fire("General", "Accessories", "Lock", {
		[data.ID] = true
	})
end)
module.Button:Create(main.Unlock.Main, "Default"):BindFunction("Click", function()
	local params = v.Params

	if not params then
		return
	end

	local data = params.Data

	if params.IsIndex then
		module.Signal:Fire("General", "Accessories", "AutoLock", data.Name)
		return
	end

	module.Signal:Fire("General", "Accessories", "Lock", {
		[data.ID] = true
	})
end)
module.Button:Create(main.Delete.Main, "Default"):BindFunction("Click", function()
	local params = v.Params

	if not params then
		return
	end

	local data = params.Data

	if params.IsIndex then
		module.Signal:Fire("General", "Accessories", "AutoDelete", data.Name)
		return
	end

	local ID = data.ID
	module.Signal:FireSelf("Interface", "Confirmation", "Start", {
		Title = "Delete",
		Description = `Permanently delete {data.Name}? This cannot be undone.`,
		ConfirmText = "Delete",
		CancelText = "Cancel",
		Callback = function(p)
			if p and module.Data.Accessories.List[ID] then
				module.Signal:Fire("General", "Accessories", "Delete", {
					[ID] = true
				})
				v:Close()
			end
		end
	})
end)
module.Button:Create(main.Evolve.Main, "Default"):BindFunction("Click", function()
	local params = v.Params

	if not params then
		return
	end

	local data = params.Data

	if not params.IsFake then
		local inventoryController = GetInventoryController() -- equivalent call inferred; original call site unknown
		local v3

		if inventoryController and inventoryController.Category == "Accessories" and inventoryController.Mode == "Default" then
			local rarity = module.Shared.Accessories.GetRarity(data)
			v3 = module.Shared.Accessories.GetNextRarity(rarity) ~= nil
		else
			v3 = false
		end

		if v3 then
			v:Close()
			module.Signal:InvokeSelf("Interface", "Inventory", "GetController").SetMode("Evolve", {
				Target = data.ID
			})
		end
	end
end)
module:OnDataChanged({ "Accessories" }, Accessories.Refresh)
return Accessories