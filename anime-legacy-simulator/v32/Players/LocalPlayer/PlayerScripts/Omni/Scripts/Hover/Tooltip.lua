local module = require("@game/ReplicatedStorage/Omni")
local tooltip = module.Inset:WaitForChild("Tooltip")
local v = module.Libs.NeoHover.Create(tooltip, script.Name)
local Tooltip = {
	Open = function(self, p, p2)
		if not p2 and v.UpdateMode ~= "Mouse" and v.Element then
			return
		end

		module.Utils.String:Typewrite({
			Label = tooltip.Title,
			Text = p.Text,
			Speed = math.max(1, string.len(p.Text) / 10)
		})
		return true
	end,
	Close = function(p)
		if p and v.UpdateMode ~= "Mouse" and v.Element then
			return
		end

		v:SetUpdateMode("Mouse")
		return true
	end,
	Click = function(p, p2)
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
}
v:SetSafeBound(0.1)
v:SetRestrictedToOne(true)
v:SetOpenHandler(Tooltip.Open, {
	Text = "string"
})
v:SetCloseHandler(Tooltip.Close)
v:SetClickHandler(Tooltip.Click)
return Tooltip