local FishingUpgradeClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
game:GetService("TweenService")

function RunUpgradeRod(p, instance)
	instance:SetAttribute("LocalUpgrading", true)
	local proximityInteraction = instance.PrimaryPart.ProximityAttachment.ProximityInteraction
	proximityInteraction.Enabled = false
	local rodUpgrades = instance.Parent:FindFirstChild("RodUpgrades")
	local folder = rodUpgrades and rodUpgrades:FindFirstChild(p.Name)

	if folder then
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "Main" then
				part.Transparency = 0
			end
		end
	end

	p.Parent = game.ReplicatedStorage.TempStorage
	local v = Client.Events.RequestUpgradeRod:InvokeServer(p, instance)

	if v and v.Success then
		task.spawn(function()
			if instance:GetAttribute("Upgrading") then
				instance:GetAttributeChangedSignal("Upgrading"):Wait()
			end

			instance:SetAttribute("LocalUpgrading", nil)
			proximityInteraction.Enabled = true
		end)
	else
		task.spawn(function()
			wait(0.5)
			p.Parent = localPlayer.Inventory
			instance:SetAttribute("LocalUpgrading", nil)

			if folder and not folder:GetAttribute("Upgrading") then
				for _, part in pairs(folder:GetDescendants()) do
					if part:IsA("BasePart") and part.Name ~= "Main" then
						part.Transparency = 1
					end
				end
			end

			if not instance:GetAttribute("Upgrading") then
				proximityInteraction.Enabled = true
			elseif instance:GetAttribute("Upgrading") then
				task.spawn(function()
					instance:GetAttributeChangedSignal("Upgrading"):Wait()
					instance:SetAttribute("LocalUpgrading", nil)
					proximityInteraction.Enabled = true
				end)
			end
		end)
	end
end

function FishingUpgradeClient.RequestUpgradeRod(instance)
	if instance:GetAttribute("Upgrading") or instance:GetAttribute("LocalUpgrading") then
		return
	end

	local currentlyEquipped = Client.InventoryHandler.GetCurrentlyEquipped()

	if currentlyEquipped == nil then
		Client.PopUpUI.AddPopUp("you are not holding a fishing rod", "warning")
		return
	end

	if currentlyEquipped:GetAttribute("ToolName") ~= "Fishing Rod" then
		Client.PopUpUI.AddPopUp("you are not holding a fishing rod", "warning")
		return
	end

	if currentlyEquipped.Name ~= "Old Rod" and currentlyEquipped.Name ~= "Good Rod" then
		return
	end

	if not (currentlyEquipped:GetAttribute("XP") and currentlyEquipped:GetAttribute("LevelUpXP")) then
		Client.PopUpUI.AddPopUp("need more xp", "warning")
	elseif currentlyEquipped:GetAttribute("XP") / currentlyEquipped:GetAttribute("LevelUpXP") < 1 then
		Client.PopUpUI.AddPopUp("need more xp", "warning")
	else
		RunUpgradeRod(currentlyEquipped, instance)
	end
end

function FishingUpgradeClient.Init() end

return FishingUpgradeClient