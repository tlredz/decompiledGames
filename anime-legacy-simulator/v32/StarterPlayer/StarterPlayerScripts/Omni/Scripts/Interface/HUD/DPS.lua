local module = require("@game/ReplicatedStorage/Omni")
local value = module.Interface:WaitForChild("HUD"):WaitForChild("Left"):WaitForChild("Currencies"):WaitForChild("DPS"):WaitForChild("Value")
local dPSChangedConnection = nil
local DPS = {
	Update = function()
		local DPS2 = module.Instance:GetAttribute("DPS") or 0
		value.Text = `DPS: {module.Utils.Number:Format(DPS2)}`
	end,
	Destroy = function()
		if dPSChangedConnection then
			dPSChangedConnection:Disconnect()
			dPSChangedConnection = nil
		end
	end
}

function DPS.Init()
	if dPSChangedConnection then
		return
	end

	dPSChangedConnection = module.Instance:GetAttributeChangedSignal("DPS"):Connect(DPS.Update)
	DPS.Update()
end

return DPS