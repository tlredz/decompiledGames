local module = require("@game/ReplicatedStorage/Omni")
local Controller = require(script.Controller)
return {
	Init = function()
		local guilds = module.Scripts.General.Guilds

		if guilds then
			guilds.Updated:Connect(Controller.OnServerSync)
		end

		for _, moduleScript in script.Frames:GetChildren() do
			if not moduleScript:IsA("ModuleScript") then
				continue
			end

			local module2 = require(moduleScript)

			if module2 and module2.Init then
				module2.Init()
			end
		end
	end
}