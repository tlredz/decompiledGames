local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)
return {
	Start = function(_)
		if not Net:Invoke("CommandsService/ViewCommands") then
			return
		end

		local Conch = require(ReplicatedStorage.Packages.Conch)
		require(ReplicatedStorage.Shared.ConchTypes)
		Conch.initiate_default_lifecycle()
		Conch.ui.bind_to(Enum.KeyCode.F2)
		Net:Connect("CommandsService/OpenCommandBar", function()
			Conch.ui.opened(true)
		end)
	end
}