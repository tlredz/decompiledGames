local module = require("@game/ReplicatedStorage/Omni")
local gacha = module.Inset:WaitForChild("Gacha")
local background = gacha:WaitForChild("Background")
local main = gacha:WaitForChild("Main")
local v = module.Libs.NeoHover.Create(gacha, script.Name)
local clone = main.PerkTemplate:Clone()
main.PerkTemplate:Destroy()
local clones = {}
local Gacha = {
	Refresh = function()
		local params = v.Params

		if not params then
			return
		end

		local v2 = module.Data.Gacha[params.GachaName]
		local v3 = not v2 and {} or v2.Vault or {}
		local current = v2 and v2.Current
		local v4 = v3[params.ResultName] == true
		local v5 = current == params.ResultName
		main.Equip.Visible = v4 and not v5
		main.Unequip.Visible = v4 and v5
	end
}

function Gacha:Open(p, p2)
	if not p2 and v.UpdateMode ~= "Mouse" and v.Element then
		return
	end

	local v2 = module.Shared.Gacha.List[p.GachaName]

	if not v2 then
		return
	end

	local v3 = v2.Source.Normal[p.ResultName]

	if not v3 then
		return
	end

	main.Header.Labels.Title.Text = p.ResultName
	main.Header.Labels.Rarity.Text = v3.Rarity
	main.Header.Visibility.Viewport.Image = v3.Icon
	main.Header.Visibility.Viewport.UIGradient:SetAttribute("Rarity", v3.Rarity)
	background.RarityStroke.UIGradient:SetAttribute("Rarity", v3.Rarity)
	main.Header.Labels.Rarity.UIGradient:SetAttribute("Rarity", v3.Rarity)

	for _, v4 in clones do
		v4:Destroy()
	end

	table.clear(clones)
	local count = 0

	for k, perk in v3.Perks do
		local clone2 = clone:Clone()
		clone2.Name = k
		clone2.LayoutOrder = count + 20
		clone2.Value.Text = module.Utils.Multipliers.ToStringSingle({
			Name = k,
			MultiplierArray = { perk },
			IsRich = true,
			ShowPercentage = true
		})
		clone2.Parent = main
		clone2.Visible = true
		table.insert(clones, clone2)
		count += 1
	end

	Gacha.Refresh()
	return true
end

function Gacha.Close(p, p2)
	if p and not p2 and v.UpdateMode ~= "Mouse" and v.Element then
		return
	end

	v:SetUpdateMode("Mouse")
	return true
end

function Gacha.Click(p, p2)
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
v:SetOpenHandler(Gacha.Open, {
	GachaName = "string",
	ResultName = "string"
})
v:SetCloseHandler(Gacha.Close)
v:SetClickHandler(Gacha.Click)
v:SetRefreshHandler(Gacha.Refresh)
module.Button:Create(main.Equip.Main, "Default"):BindFunction("Click", function()
	local params = v.Params

	if not params then
		return
	end

	module.Signal:Fire("General", "Gacha", "Equip", params.GachaName, params.ResultName)
end)
module.Button:Create(main.Unequip.Main, "Default"):BindFunction("Click", function()
	local params = v.Params

	if not params then
		return
	end

	module.Signal:Fire("General", "Gacha", "Equip", params.GachaName, params.ResultName)
end)
module:OnDataChanged({ "Gacha" }, Gacha.Refresh)
return Gacha