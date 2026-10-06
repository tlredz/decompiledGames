local module = require("@game/ReplicatedStorage/Omni")
local View = require(script.Parent.Parent.Interface.Shop.View)
local items = module.Inset:WaitForChild("Items")
local background = items:WaitForChild("Background")
local main = items:WaitForChild("Main")
local v = module.Libs.NeoHover.Create(items, script.Name)
local Items = {
	Refresh = function()
		local element = v.Element
		local params = v.Params

		if not (element and params) then
			return
		end

		local playerData = params.PlayerData or module.Data
		local amount

		if params.IsFake then
			amount = params.Amount or 1
		else
			amount = playerData.Items.List[params.Name] or 0
		end

		local v2 = module.Shared.Items.List[params.Name]

		if not v2 then
			return
		end

		main.Amount.Text = module.Utils.Number:Format((math.floor(amount))) .. "x"
		local v3 = module.Shared.Potions.List[params.Name]
		local isConfigured = module.Shared.Potions.IsConfigured(v3)

		if isConfigured then
			if amount >= 1 and params.IsFake ~= true and params.IsSelection ~= true then
				isConfigured = params.PlayerData == nil or params.PlayerData == module.Data
			else
				isConfigured = false
			end
		end

		main.UseOne.Visible = isConfigured
		main.UseAll.Visible = isConfigured
		main.ButtonsPadding.Visible = isConfigured or params.IsSelection == true
		main.Description.Text = v2.Description
	end
}

function Items:Open(p, p2)
	if not p2 and v.UpdateMode ~= "Mouse" and v.Element then
		return
	end

	local v2 = module.Shared.Items.List[p.Name]

	if not v2 then
		return
	end

	main.Header.Labels.Title.Text = p.Name
	main.Header.Labels.Rarity.Text = v2.Rarity
	main.Header.Visibility.Icon.Image = v2.Icon or ""
	main.Description.Text = v2.Description or "No description given."
	background.RarityStroke.UIGradient:SetAttribute("Rarity", v2.Rarity)
	main.Header.Labels.Rarity.UIGradient:SetAttribute("Rarity", v2.Rarity)
	main.ButtonsPadding.Visible = p.IsSelection == true
	main.SelectFromSelection.Visible = p.IsSelection == true
	Items.Refresh()
	return true
end

function Items.Close(p, p2)
	if p and not p2 and v.UpdateMode ~= "Mouse" and v.Element then
		return
	end

	v:SetUpdateMode("Mouse")
	return true
end

function Items.Click(p, p2)
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
v:SetOpenHandler(Items.Open, {
	Name = "string"
})
v:SetCloseHandler(Items.Close)
v:SetClickHandler(Items.Click)
v:SetRefreshHandler(Items.Refresh)
local flag = false

for k, v2 in {
	UseOne = false,
	UseAll = true
} do
	local main2 = main[k].Main
	main2.Title.Text = v2 and "Use All" or "Use 1"
	local v3 = v2
	View.Button(main2, function()
		if flag then
			return
		end

		local params = v.Params

		if not params or params.IsSelection or params.IsFake or params.PlayerData and params.PlayerData ~= module.Data then
			return
		end

		flag = true
		local success, result = pcall(function()
			return module.Signal:Invoke("General", "Marketplace", "UsePotion", params.Name, v3)
		end)
		flag = false

		if not (success and result) then
			module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
				Message = "This potion could not be used.",
				Color = Color3.new(1, 1, 0)
			})
		end

		Items.Refresh()
	end)
end

module:OnDataChanged({ "Items" }, Items.Refresh)
module:OnDataChanged({ "Commerce" }, Items.Refresh)
return Items