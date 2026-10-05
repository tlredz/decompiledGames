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
local v2 = require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(ReplicatedStorage2.Common.RewardInfo)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v4 = require3(ReplicatedStorage2.Common.GachaItemsData)
local v5 = require3(ReplicatedStorage2.Controllers.Battlepass.BattlepassViewController)
local v6 = require3(clientGameModules.GuiHandler)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local _ = localPlayer.PlayerScripts
local battlepassHelp = playerGui:WaitForChild("BattlepassHelp")
local v7 = nil
local v8 = false
local gachaNPC = nil
local main = nil
local HalloweenGachaNPCController = {
	UpdateRewards = function(self)
		local v9 = v7:Get("BattlepassGacha.SelectedAbility")
		local abilitiesReward = v4.AbilitiesRewards[v9]

		for i = 1, 3 do
			local formatted = `Item{i}`
			local child = main:WaitForChild(formatted)
			local requirement = abilitiesReward.Requirements[i]
			local icon = v2.Icons:GetIcon("DEFAULT_MISSING")
			local abilityTokenIcon, displayName

			if i == 3 then
				abilityTokenIcon = abilitiesReward.AbilityTokenIcon
				displayName = `{abilitiesReward.DisplayName} Token`
			else
				local swordReward = v3.createSwordReward(requirement)
				abilityTokenIcon = swordReward.Icon or icon
				displayName = swordReward.DisplayName or requirement
			end

			child.ImageLabel.Image = abilityTokenIcon
			child.Label.Text = displayName
		end

		v3.createAbilityReward(abilitiesReward.DisplayName)
		main.Ability.ImageLabel.Image = v2.Icons:GetAbilityIcon(abilitiesReward.DisplayName)
		main.Ability.Label.Text = abilitiesReward.DisplayName
	end,
	SetupClose = function(self)
		main:WaitForChild("Close").Activated:Connect(function()
			v6:Close("GachaNPC", true)
		end)
	end,
	OpenGacha = function(self)
		local view = v5:GetView("SpinGacha")

		if view and view._frame then
			view._frame:SetAttribute("ForceClose", true)
		end

		v5:OpenView("SpinGacha")
		v5:Open()

		if not v8 then
			v8 = true
			battlepassHelp.Enabled = true
		end
	end
}

function HalloweenGachaNPCController:SetupOpenGacha()
	main:WaitForChild("Go").Activated:Connect(function()
		HalloweenGachaNPCController:OpenGacha()
	end)
	local upgrade = main:WaitForChild("Ability"):WaitForChild("Upgrade")

	local function updateVisibility()
		local v9 = v7:Get("BattlepassGacha.SelectedAbility")
		local abilitiesReward = v4.AbilitiesRewards[v9]

		if not abilitiesReward then
			return
		end

		upgrade.Visible = v4.CheckIfPlayersOwnsBestPrizeAbility(v7) and not abilitiesReward.NoUpgrade
	end

	task.defer(updateVisibility)
	client:OnChange("Ability", updateVisibility)
	v7:OnChange("BattlepassGacha.SelectedAbility", updateVisibility)
	upgrade.Activated:Connect(function()
		local v9 = v7:Get("BattlepassGacha.SelectedAbility") or "BunnyLeap"
		v6:Open("AbilityUpgrade_" .. v4.AbilitiesRewards[v9].DisplayName)
	end)
end

function HalloweenGachaNPCController.Start(_)
	v7 = v.Client:WaitReplion("Data")
	gachaNPC = playerGui:WaitForChild("GachaNPC")
	main = gachaNPC:WaitForChild("Main")
	task.spawn(function()
		HalloweenGachaNPCController:SetupClose()
		HalloweenGachaNPCController:SetupOpenGacha()
		v7:OnChange("BattlepassGacha.SelectedAbility", function()
			HalloweenGachaNPCController:UpdateRewards()
		end)
		HalloweenGachaNPCController:UpdateRewards()
	end)
end

return HalloweenGachaNPCController