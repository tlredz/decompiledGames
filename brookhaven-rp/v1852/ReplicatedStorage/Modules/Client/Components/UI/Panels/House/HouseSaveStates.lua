local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local HousePropSavesConstants = require(ReplicatedStorage.Modules.Client.Houses.HousePropSavesConstants)
local LotController = require(ReplicatedStorage.Modules.Client.Lot.LotController)
local Component = require(ReplicatedStorage.Packages.Component)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local DevProductController = require(ReplicatedStorage.Modules.Client.Monetization.DevProductController)
local CountableDevProductController = require(ReplicatedStorage.Modules.Client.Monetization.CountableDevProductController)
local CountableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.CountableDevProducts)
local PlayerFlag = require(ReplicatedStorage.Modules.Client.PlayerFlags.PlayerFlag)
local PropsLimitClient = require(ReplicatedStorage.Modules.Client.Props.PropsLimitClient)
local PropsUtil = require(ReplicatedStorage.Modules.Shared.Housing.PropsUtil)
local PrivateServerPropLimits = require(ReplicatedStorage.Modules.Shared.PrivateServer.PrivateServerPropLimits)
local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local Houses = require(ReplicatedStorage.Modules.Client.UI.LoadableEntries.Houses)
local Mansions = require(ReplicatedStorage.Modules.Client.UI.LoadableEntries.Mansions)
local Apartments = require(ReplicatedStorage.Modules.Client.UI.LoadableEntries.Apartments)
local Motels = require(ReplicatedStorage.Modules.Client.UI.LoadableEntries.Motels)
local ConfirmationPanel = require(ReplicatedStorage.Modules.Client.UI.ConfirmationPanel)
local Landmarks = require(ReplicatedStorage.Modules.Client.UI.LoadableEntries.Landmarks)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local Semaphore = require(ReplicatedStorage.Modules.Shared.Async.Semaphore)
local PropertyUtil = require(ReplicatedStorage.Modules.Shared.Housing.PropertyUtil)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local MenuItem = require(ReplicatedStorage.Modules.Shared.Item.MenuItem)
local DevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.DevProducts)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local HouseSaveSlotsABTest = require(ReplicatedStorage.Modules.Client.Houses.ABTests.HouseSaveSlotsABTest)
local GlobalReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.GlobalReplicatedDataController)
local PlaceholderController = require(ReplicatedStorage.Modules.Client.Placeholder.PlaceholderController)

local function computeUnlockedSlots()
	local count = 0

	for _, v in DevProducts.HOUSE_SAVE_SLOTS do
		if not DevProductController.IsOwned(v) then
			break
		end

		count += 1
	end

	return count
end

local v = Component.new({
	Tag = "HouseSaveStates",
	Extensions = {
		{
			ShouldConstruct = function(_)
				return PlayerFlag.IsEnabled("save-catalog")
			end
		}
	}
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.scope = Fusion.scoped(Fusion)
	self.refreshed = self.scope:Value(false)
	self.lotType = self.scope:Value(nil)
	self._forceUpdate = self.scope:Value(0)
	self.outsidePropCount = self.scope:Value(0)
	self.slots = self.scope:Value({})
	local v2 = Semaphore.new(1)

	local function updateSlots()
		v2:acquire()
		pcall(function()
			if not Fusion.peek(self.refreshed) then
				self.slots:set({})
				return
			end

			Fusion.peek(self._forceUpdate)
			GamepassController.WaitForGamepasses()
			self.slots:set(v.getSlots((computeUnlockedSlots())))
		end)
		v2:release()
	end

	self.scope:Observer(self.refreshed):onChange(updateSlots)
	self.scope:Observer(self._forceUpdate):onChange(updateSlots)
	self.returnCallback = self.scope:Value(nil)
end

function v.getHouseIcon(p: string)
	for _, v2 in {
		Houses.Entries,
		Mansions.Entries,
		Apartments.Entries,
		Motels.Entries,
		Landmarks.Entries
	} do
		for _, v3 in v2 do
			if v3.Name ~= p then
				continue
			end

			if v3.Item == nil then
				return v3.Icon
			end

			local item = ItemRegistry.GetItem(v3.Item, MenuItem)

			if item == nil then
				return nil
			end

			return item:GetIcon()
		end
	end

	return nil
end

function v.getSlots(p)
	local v2 = Remotes.invokeServer("HS_HouseSaves")
	local v3 = p + HousePropSavesConstants.FREE_SLOTS
	local result = {}
	local v4 = false

	for i = 1, HousePropSavesConstants.FREE_SLOTS + #DevProducts.HOUSE_SAVE_SLOTS do
		if v3 < i then
			result[i] = {
				Type = "Add",
				DevProduct = DevProducts.GetName(DevProducts.HOUSE_SAVE_SLOTS[i - HousePropSavesConstants.FREE_SLOTS])
			}
			break
		end

		local v5 = v2["h" .. i]

		if v5 == nil then
			result[i] = {
				Type = "Empty",
				Slot = "h" .. i
			}
		else
			result[i] = {
				Type = "Save",
				Slot = "h" .. i,
				Name = v5.Name,
				Props = v5.PropCount,
				HouseType = v5.HouseType,
				HouseId = v5.HouseId
			}
			v4 = true
		end
	end

	if not v4 then
		result[1] = {
			Type = "Prompt",
			Slot = "h1"
		}
	end

	return result
end

function v:SetReturnCallback(callback, runSpawn)
	self.returnCallback:set(callback)
	self.runSpawn = runSpawn
end

function v:SetSource(source: string)
	self.source = source
end

function v.Refresh(data)
	local playerOwnedLotNumber = LotUtil.GetPlayerOwnedLotNumber(Players.LocalPlayer)

	if playerOwnedLotNumber ~= nil then
		data.lotType:set(LotUtil.GetLotType(playerOwnedLotNumber))
	end

	data.outsidePropCount:set(PropsUtil.CountOutsideHouseProps(Players.LocalPlayer))
	data.refreshed:set(true)
end

function v:doSave(p2: string)
	local v2, v3 = Remotes.invokeServer("HS_PropBuildSave", p2, self.source)

	if not v2 then
		NotificationController.NotifyCenter(v3 or "Unable to save house", 5)
		return
	end

	self._forceUpdate:set(Fusion.peek(self._forceUpdate) + 1)
	NotificationController.NotifyCenter("House saved!", 5)
end

function v.CanPurchaseMoreSlots()
	return DevProducts.HOUSE_SAVE_SLOTS[computeUnlockedSlots() + 1] ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setPurchaseSlotPrice(purchaseSlot, devProduct: string)
	purchaseSlot.Frame.Button.TextLabel.Text = PlaceholderController.Substitute("Add slot %devproductprice_" .. devProduct .. "%")
end

function v:updateSubtleSaleButtonVisibility()
	local subtleSaleButton = self.Instance.Parent.Parent:FindFirstChild("Header"):FindFirstChild("CategoryTabs"):FindFirstChild("SubtleSaleButton")

	if subtleSaleButton == nil then
		return
	end

	subtleSaleButton.Visible = HouseSaveSlotsABTest.IsSubtleSale() and v.CanPurchaseMoreSlots()
end

function v:updatePurchaseSlots(items)
	local instance = self.Instance
	local parent = instance.Parent

	if parent == nil then
		return
	end

	local purchaseSlot = instance:FindFirstChild("PurchaseSlot")
	local purchaseTopAnchor = parent:FindFirstChild("PurchaseTopAnchor")
	local purchaseBottomAnchor = parent:FindFirstChild("PurchaseBottomAnchor")
	local purchaseSlot2 = purchaseTopAnchor and purchaseTopAnchor:FindFirstChild("PurchaseSlot")
	local purchaseSlot3 = purchaseBottomAnchor and purchaseBottomAnchor:FindFirstChild("PurchaseSlot")

	if purchaseSlot ~= nil then
		purchaseSlot.Visible = false
	end

	if purchaseTopAnchor ~= nil then
		purchaseTopAnchor.Visible = false
	end

	if purchaseBottomAnchor ~= nil then
		purchaseBottomAnchor.Visible = false
	end

	if not v.CanPurchaseMoreSlots() then
		return
	end

	local v2 = nil
	local layoutOrder = nil

	for k, item in items do
		if item.Type ~= "Add" then
			continue
		end

		layoutOrder = k
		v2 = item
		break
	end

	if v2 == nil then
		return
	end

	if HouseSaveSlotsABTest.IsTopAnchorVariant() and purchaseTopAnchor ~= nil and purchaseSlot2 ~= nil then
		purchaseTopAnchor.Visible = true
		purchaseSlot2.Visible = true
		setPurchaseSlotPrice(purchaseSlot2, v2.DevProduct) -- equivalent call inferred; original call site unknown
	elseif HouseSaveSlotsABTest.IsBottomAnchor() and purchaseBottomAnchor ~= nil and purchaseSlot3 ~= nil then
		purchaseBottomAnchor.Visible = true
		purchaseSlot3.Visible = true
		setPurchaseSlotPrice(purchaseSlot3, v2.DevProduct) -- equivalent call inferred; original call site unknown
	elseif not HouseSaveSlotsABTest.IsPurchaseAnchored() and purchaseSlot ~= nil then
		purchaseSlot.Visible = true

		if layoutOrder ~= nil then
			purchaseSlot.LayoutOrder = layoutOrder
		end

		setPurchaseSlotPrice(purchaseSlot, v2.DevProduct) -- equivalent call inferred; original call site unknown
	end
end

function v.PromptNextSlotPurchase()
	local v2 = computeUnlockedSlots() + 1
	local v3 = DevProducts.HOUSE_SAVE_SLOTS[v2]

	if v3 == nil then
		return
	end

	DevProductController.PromptPurchaseWithId(
		DevProducts.GetId(v3),
		"AddSlot:h" .. HousePropSavesConstants.FREE_SLOTS + v2
	)
end

function v:Start()
	HouseSaveSlotsABTest.WaitForReady():await()
	self._Janitor:Add(LotController.PropertyChangedSignal:Connect(function()
		self.outsidePropCount:set(PropsUtil.CountOutsideHouseProps(Players.LocalPlayer))
		self._forceUpdate:set(Fusion.peek(self._forceUpdate) + 1)
	end))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onPropLimitChanged()
		self._forceUpdate:set(Fusion.peek(self._forceUpdate) + 1)
	end

	self._Janitor:Add(CountableDevProductController.GetCountChangedSignal(CountableDevProducts.PUBLIC_SERVER_PROP_LIMIT):Connect(onPropLimitChanged))
	self._Janitor:Add(CountableDevProductController.GetCountChangedSignal(CountableDevProducts.PRIVATE_SERVER_PROP_LIMIT):Connect(onPropLimitChanged))
	self._Janitor:Add(Workspace:GetAttributeChangedSignal(PrivateServerPropLimits.WORKSPACE_ATTR):Connect(onPropLimitChanged))
	self._Janitor:Add(Workspace:GetAttributeChangedSignal(PropsUtil.DEBUG_PROP_LIMIT_ATTR):Connect(onPropLimitChanged))
	local placementFolder = PropsUtil.GetPlacementFolder()

	if placementFolder ~= nil then
		local function fn()
			self.outsidePropCount:set(PropsUtil.CountOutsideHouseProps(Players.LocalPlayer))
		end

		self._Janitor:Add(placementFolder.ChildAdded:Connect(function()
			task.defer(fn)
		end))
		self._Janitor:Add(placementFolder.ChildRemoved:Connect(function()
			task.defer(fn)
		end))
	end

	task.spawn(function()
		local v2 = GlobalReplicatedDataController.WaitForReplica()

		if not Janitor.Is(self._Janitor) then
			return
		end

		self._Janitor:Add(v2:OnChange(function(p: string, list)
			if p ~= "SetValues" or list[1] ~= tostring(Players.LocalPlayer.UserId) or (list[2] ~= "profile" or list[3] ~= "devProducts") then
				return
			end

			onPropLimitChanged() -- equivalent call inferred; original call site unknown
		end), "Disconnect")
	end)
	local instance = self.Instance

	local function initPurchaseSlot(purchaseSlot)
		purchaseSlot.Visible = false
		local frame = purchaseSlot:FindFirstChild("Frame")
		local button = frame and frame:FindFirstChild("Button")

		if button == nil or not button:IsA("GuiButton") then
			return
		end

		self._Janitor:Add(button.Activated:Connect(function()
			v.PromptNextSlotPurchase()
		end))
	end

	local purchaseSlot = instance:FindFirstChild("PurchaseSlot")

	if purchaseSlot ~= nil then
		initPurchaseSlot(purchaseSlot)
	end

	local parent = instance.Parent

	if parent ~= nil then
		local purchaseTopAnchor = parent:FindFirstChild("PurchaseTopAnchor")

		if purchaseTopAnchor ~= nil then
			purchaseTopAnchor.Visible = false
			local purchaseSlot2 = purchaseTopAnchor:FindFirstChild("PurchaseSlot")

			if purchaseSlot2 ~= nil then
				initPurchaseSlot(purchaseSlot2)
			end
		end

		local purchaseBottomAnchor = parent:FindFirstChild("PurchaseBottomAnchor")

		if purchaseBottomAnchor ~= nil then
			purchaseBottomAnchor.Visible = false
			local purchaseSlot2 = purchaseBottomAnchor:FindFirstChild("PurchaseSlot")

			if purchaseSlot2 ~= nil then
				initPurchaseSlot(purchaseSlot2)
			end
		end
	end

	self.scope:Observer(self.slots):onBind(function()
		self:updatePurchaseSlots(Fusion.peek(self.slots))
		self:updateSubtleSaleButtonVisibility()
	end)
	self.scope:Hydrate(instance)({
		[Fusion.Children] = self.scope:ForPairs(self.slots, function(use, scope, key, value)
			local v3 = {
				Name = "h" .. key,
				Parent = instance,
				Visible = true,
				LayoutOrder = key
			}
			local visible

			if LotUtil.GetPlayerOwnedLotNumber(Players.LocalPlayer) == nil then
				visible = false
			else
				visible = LotUtil.GetPropertyRoot((LotUtil.GetPlayerOwnedLotNumber(Players.LocalPlayer))) ~= nil
			end

			if value.Type == "Prompt" and not visible then
				return scope:Hydrate(scope:Hydrate(instance.PromptTemplate:Clone())(v3).Frame.Frame.Button)({
					[Fusion.OnEvent("Activated")] = use(self.returnCallback)
				})
			else
				if value.Type == "Add" then
					return key, nil
				end

				if value.Type == "Save" then
					local v5 = scope:Hydrate(instance.SaveTemplate:Clone())(v3)
					v5.HouseImage.Value.Image = v.getHouseIcon(value.HouseId) or ""
					v5.SaveName.Value.Text = value.Name
					local propLimit = PropsLimitClient.GetPropLimit(GamepassController.IsOwned(Gamepasses.VIP))
					local v6 = propLimit < use(self.outsidePropCount) + value.Props
					local value2 = v5.PropCount.Value
					value2.Text = value.Props .. "/" .. propLimit .. " props"

					if v6 then
						value2.TextColor3 = BrickColor.Red().Color
					end

					scope:Hydrate(v5.Save.Value)({
						Visible = visible,
						[Fusion.OnEvent("Activated")] = function()
							local panel = PanelController.GetPanel("NoResetGUIHandler", "ConfirmationPanel")
							ComponentUtil.FindAndWaitForAncestorComponent(
								panel.Instance,
								"ConfirmationPanel",
								ConfirmationPanel
							):Init(
								"Overwrite the existing save with props in this house? This cannot be undone.",
								function(flag: boolean)
									if not flag then
										return
									end

									self:doSave(value.Slot)
								end
							)
						end
					})
					local value3 = Players.LocalPlayer.PlayersBag:FindFirstChild("HouseNumber").Value
					local lotType = use(self.lotType)
					local value4 = v5.Spawn.Value
					local config = PropertyUtil.GetConfig(value.HouseId)

					if lotType == value.HouseType and (not config or not config.LotIdRestrictions or table.find(
						config.LotIdRestrictions,
						value3
					)) then
						if config and config.LotIdRestrictions and not table.find(config.LotIdRestrictions, value3) then
							value4.Interactable = false
							value4.BackgroundColor3 = Color3.fromRGB(156, 167, 162)
							value4.Text = "Wrong lot"
						elseif propLimit < value.Props then
							value4.Interactable = false
							value4.BackgroundColor3 = Color3.fromRGB(156, 167, 162)
							value4.Text = "Too many props"
						elseif v6 then
							value4.Interactable = false
							value4.BackgroundColor3 = Color3.fromRGB(156, 167, 162)
							value4.Text = "Clear Outside Props"
						else
							self.scope:Hydrate(value4)({
								[Fusion.OnEvent("Activated")] = function()
									if not self.runSpawn(value.HouseId) then
										return
									end

									Remotes.invokeServer("HS_PropBuildLoad", value.Slot, self.source)
								end
							})
						end
					else
						value4.Interactable = false
						value4.BackgroundColor3 = Color3.fromRGB(156, 167, 162)
						value4.Text = value.HouseType .. " plot only"
					end

					self.scope:Hydrate(v5.Rename.Value)({
						[Fusion.OnEvent("Activated")] = function()
							local value5 = v5.SaveName.Value
							value5:ReleaseFocus(true)

							if value5:GetAttribute("Renaming") then
								return
							end

							value5.TextEditable = true
							value5.PlaceholderText = "Enter name..."
							value5.Interactable = true
							value5:CaptureFocus()
						end
					})
					self.scope:Hydrate(v5.SaveName.Value)({
						[Fusion.OnEvent("FocusLost")] = function()
							local value5 = v5.SaveName.Value
							value5.TextEditable = false
							value5.Interactable = false
							value5:SetAttribute("Renaming", true)
							value5.TextColor3 = Color3.fromRGB(127, 127, 127)
							Remotes.invokeServer("HS_PropBuildRename", value.Slot, value5.Text)
							value5:SetAttribute("Renaming", nil)
							value5.TextColor3 = Color3.fromRGB(0, 0, 0)
							onPropLimitChanged() -- equivalent call inferred; original call site unknown
						end
					})
					return value
				else
					if not visible then
						return scope:Hydrate(instance.EmptyTemplate:Clone())(v3)
					end

					local v5 = scope:Hydrate(instance.EmptySaveTemplate:Clone())(v3)
					self.scope:Hydrate(v5.Save.Value)({
						[Fusion.OnEvent("Activated")] = function()
							local value2 = Players.LocalPlayer.PlayersBag:FindFirstChild("HouseNumber").Value

							if value2 == nil then
								return
							end

							local v7 = #PropsUtil.CollectHouseProps(value2) > PropsLimitClient.GetPublicLimit(GamepassController.IsOwned(Gamepasses.VIP)) and " Warning: This save has too many props to spawn in public servers" or ""
							local panel = PanelController.GetPanel("NoResetGUIHandler", "ConfirmationPanel")
							ComponentUtil.FindAndWaitForAncestorComponent(
								panel.Instance,
								"ConfirmationPanel",
								ConfirmationPanel
							):Init(
								"Save house and props?" .. v7,
								function(flag: boolean)
									if not flag then
										return
									end

									self:doSave(value.Slot)
								end
							)
						end
					})
					return v5
				end
			end
		end)
	})
end

function v:Stop()
	self._Janitor:Destroy()
	Fusion.doCleanup(self.scope)
end

return v