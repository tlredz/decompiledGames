local FluteUpgradeClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
game:GetService("TweenService")

function RunUpgradeFlute(p, instance)
	instance:SetAttribute("LocalUpgrading", true)
	local proximityInteraction = instance.PrimaryPart.ProximityAttachment.ProximityInteraction
	proximityInteraction.Enabled = false
	local fluteUpgrades = instance.Parent:FindFirstChild("FluteUpgrades")
	local folder = fluteUpgrades and fluteUpgrades:FindFirstChild(p.Name)

	if folder then
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "Main" then
				part.Transparency = 0
			end
		end
	end

	p.Parent = game.ReplicatedStorage.TempStorage
	local v = Client.Events.RequestUpgradeFlute:InvokeServer(p, instance)

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

function FluteUpgradeClient.RequestUpgradeFlute(instance)
	print("req flute upg")

	if instance:GetAttribute("Upgrading") or instance:GetAttribute("LocalUpgrading") then
		return
	end

	local currentlyEquipped = Client.InventoryHandler.GetCurrentlyEquipped()

	if currentlyEquipped == nil then
		Client.PopUpUI.AddPopUp("you are not holding a taming flute", "warning")
		return
	end

	if currentlyEquipped:GetAttribute("ToolName") ~= "Taming Flute" then
		Client.PopUpUI.AddPopUp("you are not holding a taming flute", "warning")
		return
	end

	if currentlyEquipped.Name ~= "Old Taming Flute" and currentlyEquipped.Name ~= "Good Taming Flute" then
		return
	end

	if not (currentlyEquipped:GetAttribute("XP") and currentlyEquipped:GetAttribute("LevelUpXP")) then
		Client.PopUpUI.AddPopUp("need more xp", "warning")
	elseif currentlyEquipped:GetAttribute("XP") / currentlyEquipped:GetAttribute("LevelUpXP") < 1 then
		Client.PopUpUI.AddPopUp("need more xp", "warning")
	else
		RunUpgradeFlute(currentlyEquipped, instance)
	end
end

function FluteUpgradeClient.Init() end

return FluteUpgradeClient