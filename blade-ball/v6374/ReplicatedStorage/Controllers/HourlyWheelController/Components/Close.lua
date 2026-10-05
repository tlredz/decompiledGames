local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local localPlayer = Players.LocalPlayer
local v2 = nil
local playerGui = nil
local hourlyWheel = nil
local Close = {
	Hook = function(self, p)
		playerGui = localPlayer:WaitForChild("PlayerGui")
		hourlyWheel = playerGui:WaitForChild("HourlyWheel")
		v2 = require3(ReplicatedStorage2.Controllers.UI.SpectateController)
		p.Container.Activated:Connect(function()
			v:Close("HourlyWheel")
		end)
		v:OnOpen(function(p2)
			if p2 == hourlyWheel then
				v2:SetVisibility(not hourlyWheel.Enabled)
			end
		end)
		v:OnClose(function(p2)
			if p2 == hourlyWheel then
				v2:SetVisibility(not hourlyWheel.Enabled)
			end
		end)
	end
}

function Close.Init(_, container)
	local v3 = {
		Container = container
	}
	Close:Hook(v3)
	return v3
end

return Close