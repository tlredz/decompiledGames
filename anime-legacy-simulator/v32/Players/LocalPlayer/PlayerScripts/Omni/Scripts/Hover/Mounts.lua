local module = require("@game/ReplicatedStorage/Omni")
local mounts = module.Inset:WaitForChild("Mounts")
local background = mounts:WaitForChild("Background")
local main = mounts:WaitForChild("Main")
local v = module.Libs.NeoHover.Create(mounts, script.Name)
local Mounts = {
	Refresh = function()
		local element = v.Element
		local params = v.Params

		if not (element and params) then
			return
		end

		local data = params.Data
		local playerData = params.PlayerData or module.Data
		local v2 = module.Shared.Mounts.List[data.Name]

		if not v2 then
			return
		end

		local visible = playerData.Mounts.Equipped[v2.Type] == data.Name
		main.Type.Value.Text = `<font color="rgb(255,0,31)">Type:</font> {v2.Type}`
		main.Speed.Value.Text = `<font color="rgb(31,0,255)">Speed:</font> {module.Utils.Number:Format(v2.MaxSpeed or 0)}`

		if params.IsFake then
			main.Equip.Visible = false
			main.Unequip.Visible = false
		else
			main.Equip.Visible = not visible
			main.Unequip.Visible = visible
		end
	end
}

function Mounts:Open(p, p2)
	if not p2 and v.UpdateMode ~= "Mouse" and v.Element then
		return
	end

	local data = p.Data
	local v2 = module.Shared.Mounts.List[data.Name]

	if not v2 then
		return
	end

	main.Header.Labels.Title.Text = data.Name
	main.Header.Labels.Rarity.Text = v2.Rarity
	background.RarityStroke.UIGradient:SetAttribute("Rarity", v2.Rarity)
	main.Header.Labels.Rarity.UIGradient:SetAttribute("Rarity", v2.Rarity)
	main.SelectFromSelection.Visible = p.IsSelection == true
	main.Header.Visibility.Icon.Image = v2.Icon
	Mounts.Refresh()
	return true
end

function Mounts.Close(p, p2)
	if p and not p2 and v.UpdateMode ~= "Mouse" and v.Element then
		return
	end

	v:SetUpdateMode("Mouse")
	return true
end

function Mounts.Click(p, p2)
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
v:SetOpenHandler(Mounts.Open, {
	IsFake = "boolean",
	Data = {
		Name = "string"
	}
})
v:SetCloseHandler(Mounts.Close)
v:SetClickHandler(Mounts.Click)
v:SetRefreshHandler(Mounts.Refresh)
module.Button:Create(main.Equip.Main, "Default"):BindFunction("Click", function()
	local params = v.Params

	if not params then
		return
	end

	module.Signal:Fire("General", "Mounts", "Equip", params.Data.Name)
end)
module.Button:Create(main.Unequip.Main, "Default"):BindFunction("Click", function()
	local params = v.Params

	if not params then
		return
	end

	module.Signal:Fire("General", "Mounts", "Equip", params.Data.Name)
end)
module:OnDataChanged({ "Mounts" }, Mounts.Refresh)
return Mounts