game:GetService("MessagingService")
local import = _G.import("global")
_G.import("event")
_G.import("configuration")
_G.import("itemModules")
local Chair = {}

for k, chairId in pairs({
	p3596878456 = "AngelForce",
	p3596878463 = "Arcade"
}) do
	local v2 = chairId
	Chair[k] = {
		ChairId = chairId,
		Server = function(p, p2, p3, p4)
			local playerSave = import.get("playerSave", p)

			if playerSave:has("Inventory", "Chair", v2) then
				return true
			end

			playerSave:auto_repl(true)
			playerSave:add("Inventory", "Chair", v2)
			playerSave:clear("Equip", "Chair")
			playerSave:add("Equip", "Chair", v2)
			playerSave:auto_repl(false)
			return true
		end
	}
end

return Chair