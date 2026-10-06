local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local scope = fusion.scoped(fusion)
local weapons = module.Inset:WaitForChild("Weapons")
local background = weapons:WaitForChild("Background")
local main = weapons:WaitForChild("Main")
local level = main:WaitForChild("Level")
local perkTemplate = main:WaitForChild("PerkTemplate")
local breathings = weapons:WaitForChild("Breathings")
local template = breathings:WaitForChild("Template")
local v = module.Libs.NeoHover.Create(weapons, script.Name)
local value = scope:Value(UDim2.fromScale(0, 1))
local v2 = {}
local v3 = {}
local Weapons = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function SetButtonGradient(p, enabled: boolean)
	p.Main.UIGradient.Enabled = enabled
	p.Main.Title.UIGradient.Enabled = enabled
end

local function RefreshPerks(p)
	local perks = p.Perks or {}

	for k, perk in perks do
		local clone = v2[k]

		if not clone then
			clone = perkTemplate:Clone()
			clone.Name = k
			clone.Parent = main
			v2[k] = clone
		end

		clone.Value.Text = module.Utils.Multipliers.ToStringSingle({
			Name = k,
			ShowPercentage = true,
			MultiplierArray = { perk }
		})
		clone.Visible = true
	end

	for k, v4 in v2 do
		if perks[k] then
			continue
		end

		v4:Destroy()
		v2[k] = nil
	end
end

local function RefreshBreathings(data)
	local v4 = {}

	for _, v5 in module.Shared.Breathings.GetEntries(data.Breathings) do
		local v6 = module.Shared.Breathings.List[v5.Name]
		local v7 = v6 and v6.Rarities[v5.Rarity]

		if not v7 then
			continue
		end

		local clone = v3[v5.Slot]

		if not clone then
			clone = template:Clone()
			clone.Name = tostring(v5.Slot)
			clone.LayoutOrder = v5.Slot
			clone.Parent = breathings
			v3[v5.Slot] = clone
		end

		v4[v5.Slot] = true
		clone.Main.Title.Text = `{v5.Name} ({v5.Rarity})`
		clone.Main.UIGradient:SetAttribute("Rarity", v5.Rarity)
		local stringEffects = module.Utils.Multipliers.ToStringEffects({ v7 })
		clone.Main.Value.Text = (stringEffects == "" or not stringEffects) and "No effects" or stringEffects
		clone.Visible = true
	end

	for k, v5 in v3 do
		if v4[k] then
			continue
		end

		v5:Destroy()
		v3[k] = nil
	end

	breathings.Visible = next(v3) ~= nil
end

local function RefreshLevel(data)
	local maxLevel = module.Shared.Weapons.GetMaxLevel(data)
	local effectiveLevel = module.Shared.Weapons.GetEffectiveLevel(data)
	local exp = math.floor(data.Exp or 0)
	level.Level.Text = `Lvl <font color="rgb(255,198,0)">{effectiveLevel}</font>`

	if maxLevel <= effectiveLevel then
		value:set(UDim2.fromScale(1, 1))
		level.Exp.Text = "<font color=\"rgb(186,186,186)\">MAXED</font>"
	else
		local neededExpForLevel = module.Shared.Weapons.GetNeededExpForLevel(effectiveLevel + 1)
		value:set(UDim2.fromScale(math.clamp(exp / neededExpForLevel, 0, 1), 1))
		level.Exp.Text = `XP {module.Utils.Number:Format(exp)}/<font color="rgb(186,186,186)"><font size="12">{module.Utils.Number:Format(neededExpForLevel)}</font></font>`
	end
end

function Weapons.Refresh()
	local element = v.Element
	local params = v.Params

	if not (element and params) then
		return
	end

	local data = params.Data
	local playerData = params.PlayerData or module.Data
	local v4 = module.Shared.Weapons.List[data.Name]

	if not v4 then
		return
	end

	local locked = data.Locked == true
	local visible = playerData.Weapons.Equipped == data.ID
	local averageDamage = module.Shared.Weapons.GetAverageDamage(data, playerData)
	local averageSPA = module.Shared.Weapons.GetAverageSPA(data, playerData)
	main.SPA.Value.Text = `<font color="rgb(31,0,255)">SPA:</font> {module.Utils.Number:Round(averageSPA)}s`
	main.Damage.Value.Text = `<font color="rgb(255,0,31)">Damage:</font> {module.Utils.Number:Format(averageDamage)}`
	local ultimate = v4.Ultimate
	main.Ultimate.Visible = ultimate ~= nil

	if ultimate then
		main.Ultimate.Value.Text = `<font color="rgb(255,0,255)">Ultimate:</font> {module.Utils.Number:Round(ultimate.Cooldown)}s`
	else
		main.Ultimate.Value.Text = ""
	end

	RefreshBreathings(data)

	if not params.IsIndex then
		RefreshLevel(data)
	end

	if params.IsIndex then
		local canAutoManage = module.Shared.Weapons.CanAutoManage(data.Name)
		local enabled = module.Data.Weapons.AutoLock[data.Name] == true
		local enabled2 = module.Data.Weapons.AutoDelete[data.Name] == true
		main.Lock.Main.Title.Text = "Auto Lock"
		main.Delete.Main.Title.Text = "Auto Delete"
		SetButtonGradient(main.Lock, enabled) -- equivalent call inferred; original call site unknown
		SetButtonGradient(main.Delete, enabled2) -- equivalent call inferred; original call site unknown
		main.Unlock.Visible = false
		main.Lock.Visible = canAutoManage
		main.Equip.Visible = false
		main.Unequip.Visible = false
		main.Delete.Visible = canAutoManage
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
		else
			main.Unlock.Visible = locked
			main.Lock.Visible = not locked
			main.Equip.Visible = not visible
			main.Unequip.Visible = visible
			main.Delete.Visible = not locked and not visible and data.Name ~= "Melee"
		end
	end
end

function Weapons:Open(data, p)
	if not p and v.UpdateMode ~= "Mouse" and v.Element then
		return
	end

	local data2 = data.Data
	local v4 = module.Shared.Weapons.List[data2.Name]

	if not v4 then
		return
	end

	main.Header.Labels.Title.Text = data2.Name
	main.Header.Labels.Rarity.Text = v4.Rarity
	background.RarityStroke.UIGradient:SetAttribute("Rarity", v4.Rarity)
	main.Header.Labels.Rarity.UIGradient:SetAttribute("Rarity", v4.Rarity)
	main.SelectFromSelection.Visible = data.IsSelection == true
	level.Visible = data.IsIndex ~= true
	RefreshPerks(v4)
	main.Header.Visibility.Viewport.Image = v4.Icon
	Weapons.Refresh()
	return true
end

function Weapons:Close(p2)
	if self and not p2 and v.UpdateMode ~= "Mouse" and v.Element then
		return
	end

	v:SetUpdateMode("Mouse")
	return true
end

function Weapons.Click(p, p2)
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
v:SetOpenHandler(Weapons.Open, {
	IsFake = "boolean",
	Data = {
		Name = "string"
	}
})
v:SetCloseHandler(Weapons.Close)
v:SetClickHandler(Weapons.Click)
v:SetRefreshHandler(Weapons.Refresh)
scope:Hydrate(level.Bar.Slider)({
	Size = scope:Spring(value, 25, 1)
})
module.Button:Create(main.Equip.Main, "Default"):BindFunction("Click", function()
	local params = v.Params

	if not params then
		return
	end

	local data = params.Data
	module.Signal:Fire("General", "Weapons", "Equip", data.ID)
end)
module.Button:Create(main.Unequip.Main, "Default"):BindFunction("Click", function()
	local params = v.Params

	if not params then
		return
	end

	local data = params.Data
	module.Signal:Fire("General", "Weapons", "Equip", data.ID)
end)
module.Button:Create(main.Lock.Main, "Default"):BindFunction("Click", function()
	local params = v.Params

	if not params then
		return
	end

	local data = params.Data

	if params.IsIndex then
		module.Signal:Fire("General", "Weapons", "AutoLock", data.Name)
		return
	end

	module.Signal:Fire("General", "Weapons", "Lock", {
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
		module.Signal:Fire("General", "Weapons", "AutoLock", data.Name)
		return
	end

	module.Signal:Fire("General", "Weapons", "Lock", {
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
		module.Signal:Fire("General", "Weapons", "AutoDelete", data.Name)
		return
	end

	local ID = data.ID
	module.Signal:FireSelf("Interface", "Confirmation", "Start", {
		Title = "Delete",
		Description = `Permanently delete {data.Name}? This cannot be undone.`,
		ConfirmText = "Delete",
		CancelText = "Cancel",
		Callback = function(p)
			if p and module.Data.Weapons.List[ID] then
				module.Signal:Fire("General", "Weapons", "Delete", {
					[ID] = true
				})
				v:Close()
			end
		end
	})
end)
module:OnDataChanged({ "Weapons" }, Weapons.Refresh)
return Weapons