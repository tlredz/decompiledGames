local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Shared.Globals.Constants)
return {
	Start = function()
		local CmdrClient = require(ReplicatedStorage:WaitForChild("CmdrClient"))
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		local Remotes = require(ReplicatedStorage2.Shared.Remotes)
		local TopBarPlus = require(ReplicatedStorage.Packages.TopBarPlus)
		local v = false
		local v2 = {
			[1927880506] = true,
			[2790707588] = true
		}

		local function Initialize()
			v = true
			CmdrClient:SetActivationKeys({ Enum.KeyCode.F2 })
			local v3 = TopBarPlus.new()
			v3:setName("Cmdr")
			v3:setImage(102459578526748)
			v3:setRight()
			v3.toggled:Connect(function()
				CmdrClient:Show()
			end)
		end

		Remotes.StaffConsole.StaffVerdict.OnClientEvent:Connect(function(flag: boolean)
			if v2[Players.LocalPlayer.UserId] then
				return
			end

			if flag and not v then
				Initialize()
			end
		end)
		Remotes.StaffConsole.ProbeStaffStatus:FireServer()
	end
}