local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local clientGameModules = ReplicatedStorage2.ClientGameModules
local _ = ReplicatedStorage2.Common
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Common.Utils)
local v4 = require3(clientGameModules.GuiHandler)
local v5 = require3(ReplicatedStorage2.Shared.SecretAwakenData)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local localPlayer = Players.LocalPlayer
local v6 = nil
local v7 = nil
local playerGui = nil
local secretUpgrade = nil
local alive = nil
local Main = {
	Hook = function(self, p)
		alive = workspace:WaitForChild("Alive")
		v7 = v.Client:WaitReplion("Data")
		playerGui = localPlayer:WaitForChild("PlayerGui")
		secretUpgrade = playerGui:WaitForChild("SecretUpgrade")
		v6 = require3(ReplicatedStorage2.Controllers.UI.SpectateController)
		local remoteEvent = v2:RemoteEvent("SecretAwaken")
		local remoteEvent2 = v2:RemoteEvent("SecretClaimed")
		local close = p.Container:WaitForChild("Close")
		local vector = p.Container:WaitForChild("template1"):WaitForChild("vector")
		local template2 = p.Container:WaitForChild("template2")
		local vector2 = template2:WaitForChild("vector")
		local progress = p.Container:WaitForChild("Progress")
		local fill = progress:WaitForChild("Fill")
		local progress2 = progress:WaitForChild("Progress")
		local c3 = template2:WaitForChild("customs"):WaitForChild("c3")
		local upgrade = p.Container:WaitForChild("Upgrade")

		local function UpdateRewards()
			local toAwaken = secretUpgrade:GetAttribute("ToAwaken")

			if not toAwaken then
				return
			end

			local v8

			if client:GetInventoryVersion() == "Old" then
				v8 = v7:Get({ "SecretAwakenKills", toAwaken }) or 0
			else
				local item = client:GetItem("Sword", toAwaken)
				v8 = not item and 0 or item.Kills or 0
				toAwaken = item and item.Name
			end

			if not (toAwaken and v5[toAwaken]) then
				return
			end

			local swordIcon = v3.Icons:GetSwordIcon(toAwaken)
			local swordIcon2 = v3.Icons:GetSwordIcon((`Awakened {toAwaken}`))
			local requirement = v5.Requirement
			fill.Size = UDim2.fromScale(math.min(v8 / requirement, 1), 1)
			progress2.Text = `{math.min(v8, requirement)}/{requirement}`
			vector.Image = swordIcon or ""
			vector2.Image = swordIcon2 or ""
			c3.Visible = v5[toAwaken].CustomSlash
		end

		close.Activated:Connect(function()
			if localPlayer.Character and not localPlayer.Character:IsDescendantOf(alive) then
				v4:Open("Shop")
			else
				v4:Close(secretUpgrade.Name)
			end
		end)
		workspace.Alive.ChildAdded:Connect(function(child)
			if child == localPlayer.Character then
				v4:Close(secretUpgrade.Name)
			end
		end)
		upgrade.Activated:Connect(function()
			local toAwaken = secretUpgrade:GetAttribute("ToAwaken")

			if not toAwaken then
				return
			end

			remoteEvent:FireServer(toAwaken)
		end)
		v4:OnOpen(function(p2)
			if p2 == secretUpgrade then
				v6:SetVisibility(not secretUpgrade.Enabled)
			end
		end)
		v4:OnClose(function(p2)
			if p2 == secretUpgrade then
				v6:SetVisibility(not secretUpgrade.Enabled)
			end
		end)
		remoteEvent2.OnClientEvent:Connect(function()
			v4:Open("Shop")
		end)
		UpdateRewards()
		v7:OnChange("SecretAwakenKills", UpdateRewards)
		client:OnInventoryChange("Sword", UpdateRewards)
		secretUpgrade:GetAttributeChangedSignal("ToAwaken"):Connect(UpdateRewards)
	end
}

function Main.Init(_, container)
	local v8 = {
		Container = container
	}
	Main:Hook(v8)
	return v8
end

return Main