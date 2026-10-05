local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdvertisementsController = require(ReplicatedStorage.Modules.Client.Ads.AdvertisementsController)
local Panel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local Purchasable = require(ReplicatedStorage.Modules.Shared.PlayerData.Purchasable)
local UnlockState = require(ReplicatedStorage.Modules.Shared.PlayerData.UnlockState)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
require(ReplicatedStorage.Packages.Signal)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local Component = require(ReplicatedStorage.Packages.Component)
local v = Component.new({
	Tag = "AdListProvider"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.panelJanitor = Janitor.new()
end

function v:Start()
	local panel = self:GetPanel()
	local buttonBox = self.Instance:WaitForChild("OuterBox"):WaitForChild("ButtonBox")
	panel:RegisterListener(self, Panel.Events.Opening, function()
		self.panelJanitor:Add(buttonBox:WaitForChild("Free").Activated:Connect(function()
			local selected = self.selected
			PanelController.Close("MainGUIHandler", "AdStore")
			AdvertisementsController.IsRewardedVideoAdReady():andThen(function(p)
				if p == Enum.AdAvailabilityResult.DeviceIneligible or p == Enum.AdAvailabilityResult.ExperienceIneligible or p == Enum.AdAvailabilityResult.PlayerIneligible or p == Enum.AdAvailabilityResult.PublisherIneligible then
					NotificationController.NotifyCenter("Ad not available.", 4)
					return
				end

				if p ~= Enum.AdAvailabilityResult.IsAvailable then
					NotificationController.NotifyCenter("Ad not available. Try again later.", 4)
					return
				end

				local purchasable = AdFeatures.GetPurchasable(selected)
				local telemetryIds, devProduct = Purchasable.getTelemetryIds(purchasable)
				ABTest.GetExperimentVariable("incentivized-teleports", "placement-id"):andThen(function(placementId)
					TelemetryController.SendClientInteraction("adImpression", {
						adType = "Rewarded Video",
						hasFill = true,
						source = "Discovery HUD",
						gamepass = telemetryIds,
						devProduct = devProduct,
						category = "Discovery HUD",
						itemName = selected.id,
						placementId = placementId
					})
				end)
				AdvertisementsController.RequestRewardedVideoAd(
					selected.id,
					selected.icon,
					purchasable,
					"Discovery HUD",
					"Discovery HUD",
					selected.id == AdFeatures.AIR_VEHICLES.id
				)
			end, function()
				NotificationController.NotifyCenter("Error retrieving ad. Try again later.", 4)
			end)
		end))
	end)
	panel:RegisterListener(self, Panel.Events.Closing, function()
		self.panelJanitor:Cleanup()
		local select = buttonBox:WaitForChild("Select")
		select.Visible = true
		local free = buttonBox:WaitForChild("Free")
		free.Visible = false
	end)
	task.spawn(function()
		local v2, v3 = ABTest.GetExperimentVariable("incentivized-teleports", "unlocked-duration"):timeout(10):await()

		if v2 and v3 then
			local intervalText = buttonBox:WaitForChild("Free"):WaitForChild("TextInfo"):WaitForChild("IntervalText")
			intervalText.Text = "for " .. v3 .. " minutes!"
		end
	end)
	local v2 = {}
	local thread = nil

	local function startExpiryLoop()
		while next(v2) ~= nil do
			task.wait(1)

			for k, v3 in v2 do
				if not (v3 <= workspace:GetServerTimeNow()) then
					continue
				end

				v2[k] = nil
				self.regenerateLayout = true
			end
		end

		thread = nil
	end

	self._Janitor:Add(function()
		if thread ~= nil then
			task.cancel(thread)
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function queueExpire(object2)
		if object2:HasAccess() and not object2:IsPermanent() then
			local expirationUnix = object2:GetExpirationUnix()

			if expirationUnix ~= nil then
				table.insert(v2, expirationUnix)

				if thread == nil then
					thread = task.spawn(startExpiryLoop)
				end
			end
		end
	end

	self._Janitor:Add(UnlockableController.OnItemUnlocked:Connect(function(p)
		self.regenerateLayout = true
		queueExpire(UnlockableController.GetFeatureUnlockState(p)) -- equivalent call inferred; original call site unknown
	end))
	self._Janitor:Add(GamepassController.OnGamepassUnlocked:Connect(function(_)
		self.regenerateLayout = true
	end))
	self._Janitor:Add(task.spawn(function()
		for _, v3 in UnlockableController.GetAllFeaturesUnlockedWithExpiration() do
			queueExpire(UnlockState.new(v3)) -- equivalent call inferred; original call site unknown
		end
	end))
end

function v:GetCount()
	if self.layout and not self.regenerateLayout then
		return #self.layout
	end

	self.regenerateLayout = nil
	self.layout = {}
	local category = nil
	local items = {}
	local v3 = {}

	for _, v4 in AdFeatures.All() do
		if category == nil then
			category = v4.category
		elseif category ~= v4.category or #items >= 6 then
			if #items > 0 then
				table.insert(v3, {
					type = "Row",
					items = items
				})
			end

			category = v4.category
			items = {}
		end

		if AdFeatures.IsOwned(v4) or v4.gamepass and AdvertisementsController.IsPassExcluded(v4.gamepass, nil) then
			continue
		end

		table.insert(items, v4)
	end

	if #items > 0 then
		table.insert(v3, {
			type = "Row",
			items = items
		})
	else
		table.remove(v3, #self.layout)
	end

	table.insert(v3, {
		type = "Trailer"
	})

	for k, v4 in v3 do
		if k > 1 and v4.type == "Row" then
			local v5 = v3[k - 1]

			if v5.type == "Row" and v5.items[1].category ~= v4.items[1].category then
				table.insert(self.layout, {
					type = "Divider"
				})
			end
		end

		table.insert(self.layout, v4)
	end

	local children = self.Instance:WaitForChild("OuterBox"):WaitForChild("MenuBox"):GetChildren()

	for _, guiObject in children do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local name = guiObject.Name
		local flag = false

		for _, v5 in self.layout do
			if v5.type ~= "Row" then
				continue
			end

			for _, item in v5.items do
				if item.category ~= name then
					continue
				end

				flag = true
				break
			end

			if flag then
				break
			end
		end

		guiObject.Visible = flag
	end

	return #self.layout
end

function v:GetPanel()
	return PanelController.GetAncestorPanelByInstance(self.Instance)
end

function v:Render(p: number)
	local v2 = self.layout[p]
	local templates = self.Instance:WaitForChild("Templates")
	local clone = templates:WaitForChild(v2.type):Clone()

	if v2.type ~= "Row" then
		return clone
	end

	for _, item in pairs(v2.items) do
		local clone2 = templates:WaitForChild("Item"):Clone()
		clone2.Parent = clone
		local box = clone2:WaitForChild("Box")
		local smallIcon = AdFeatures.GetPurchasable(item):GetSmallIcon()

		if smallIcon ~= nil then
			local corner = box:WaitForChild("Corner")
			corner.Image = smallIcon
		end

		local main = box:WaitForChild("Main")
		main.Image = assert(item.icon, "Feature must have a icon to be displayed")
		local selected = item
		self.panelJanitor:Add(clone2.Activated:Connect(function()
			if self.selectedInstance then
				self.selectedInstance:RemoveTag("Checked")
			end

			self.selected = selected
			self.selectedInstance = clone2
			clone2:AddTag("Checked")
			local buttonBox = self.Instance:WaitForChild("OuterBox"):WaitForChild("ButtonBox")
			local select = buttonBox:WaitForChild("Select")
			select.Visible = false
			local free = buttonBox:WaitForChild("Free")
			free.Visible = true
			self.panelJanitor:Add(function()
				self.selected = nil

				if self.selectedInstance then
					self.selectedInstance:RemoveTag("Checked")
				end

				self.selectedInstance = nil
			end, true)
		end))
	end

	return clone
end

function v.Scrolled(p, p2: number)
	while p.layout[p2].type ~= "Row" do
		p2 -= 1
	end

	local children = p.Instance:WaitForChild("OuterBox"):WaitForChild("MenuBox"):GetChildren()

	for _, guiObject in children do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		if guiObject.Name == p.layout[p2].items[1].category then
			guiObject:AddTag("Checked")
		else
			guiObject:RemoveTag("Checked")
		end
	end
end

function v:InjectScrollListener(signal)
	self.signal = signal
	local children = self.Instance:WaitForChild("OuterBox"):WaitForChild("MenuBox"):GetChildren()

	for _, guiObject in children do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local v2 = guiObject
		guiObject:WaitForChild("Button").Activated:Connect(function()
			for k, v3 in self.layout do
				if not (v3.type == "Row" and v3.items[1].category == v2.Name or v3.type == "Trailer") then
					continue
				end

				self.signal:Fire(k)
				break
			end
		end)
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v