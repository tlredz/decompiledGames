local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
return {
	GetCombatCooldown = function()
		local v = os.clock() - Combat_presets.Last_Punched
		local default = Combat_presets.Presets.Normal.default

		if (Combat_presets.Last_Combo == 5 or Combat_presets.Last_Combo == 7) and (Combat_presets.Last_Combo ~= 5 or Combat_presets.Is_Air_Combo ~= true) then
			default = Combat_presets.Presets.Normal.final
		end

		return v, default
	end
}