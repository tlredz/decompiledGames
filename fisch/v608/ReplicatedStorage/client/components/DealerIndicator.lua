local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local _ = game.Players.LocalPlayer
Color3.new(1, 1, 1)
local v = Component.new({
	Tag = "DealerIndicator"
})

function v:Construct()
	self.trove = Trove.new()
	self.gui = script.AcceptGui:Clone()
	self.gui.Enabled = false
	self.gui.Parent = self.Instance
	self.trove:Add(self.gui)
	self.gui.typeIcon.UIGradient:AddTag("AnimatedGradient")
	self.gui.typeIcon.distanceLabel.UIGradient:AddTag("AnimatedGradient")
	self.trove:Add(task.spawn(function()
		self.gui.Adornee = self.Instance:WaitForChild("HumanoidRootPart", 60)
	end))
end

function v:SetVisible(enabled: boolean)
	self.gui.Enabled = enabled
end

function v:Start()
	local dealerType = self.Instance:GetAttribute("DealerType")

	local function updateGui()
		if SettingsController:GetSettingValue("questIndicators") == "None" then
			self:SetVisible(false)
		elseif dealerType == "AdminRelic" then
			local v2 = playerDataReplicator:TryIndex({ "LastClaimedAdminRelic" })

			if not v2 then
				return
			end

			local lastAdminRelicId = self.Instance:GetAttribute("LastAdminRelicId")
			self:SetVisible(lastAdminRelicId ~= nil and (v2.Id ~= lastAdminRelicId or v2.Status == "globalgive"))
		else
			if dealerType ~= "Companions" then
				warn((`Unknown DealerType "{dealerType}"`))
				return
			end

			local currentPeriod = self.Instance:GetAttribute("CurrentPeriod")
			local wantedCompanion = self.Instance:GetAttribute("WantedCompanion")

			if not (currentPeriod and wantedCompanion) then
				self:SetVisible(false)
			elseif playerDataReplicator:TryIndex({ "ShadyBazaar", "LastShownCompanionPeriod" }) < currentPeriod then
				self:SetVisible(playerDataReplicator:TryIndex({ "Companions", "Owned", wantedCompanion }) ~= nil)
			else
				self:SetVisible(false)
			end
		end
	end

	playerDataReplicator:WaitForLoaded()

	if dealerType == "AdminRelic" then
		self.trove:Add(playerDataReplicator:Listen({ "LastClaimedAdminRelic" }, updateGui))
		self.trove:Add(self.Instance:GetAttributeChangedSignal("LastAdminRelicId"):Connect(updateGui))
	elseif dealerType == "Companions" then
		self.trove:Add(playerDataReplicator:Listen({ "ShadyBazaar", "LastShownCompanionPeriod" }, updateGui))
		self.trove:Add(playerDataReplicator:ListenKeys({ "Companions", "Owned" }, updateGui))
		self.trove:Add(self.Instance:GetAttributeChangedSignal("CurrentPeriod"):Connect(updateGui))
		self.trove:Add(self.Instance:GetAttributeChangedSignal("WantedCompanion"):Connect(updateGui))
	end

	self.trove:Add(SettingsController:GetSettingChangedSignal("questIndicators"):Connect(updateGui))
	updateGui()
end

function v.Stop(p)
	p.trove:Destroy()
end

return v