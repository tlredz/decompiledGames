local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CountableDevProductController = require(ReplicatedStorage.Modules.Client.Monetization.CountableDevProductController)
local PlayerFlag = require(ReplicatedStorage.Modules.Client.PlayerFlags.PlayerFlag)
local PlaceholderController = require(ReplicatedStorage.Modules.Client.Placeholder.PlaceholderController)
local PropsLimitClient = require(ReplicatedStorage.Modules.Client.Props.PropsLimitClient)
local VehiclePropSavesConstants = require(ReplicatedStorage.Modules.Client.Vehicles.VehiclePropSavesConstants)
local ConfirmationPanel = require(ReplicatedStorage.Modules.Client.UI.ConfirmationPanel)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local VehicleSavePicker = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Vehicle.VehicleSavePicker)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local VehicleMiddleware = require(ReplicatedStorage.Modules.Shared.Item.Middleware.VehicleMiddleware)
local CountableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.CountableDevProducts)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local PrivateServerPropLimits = require(ReplicatedStorage.Modules.Shared.PrivateServer.PrivateServerPropLimits)
local PropsUtil = require(ReplicatedStorage.Modules.Shared.Housing.PropsUtil)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local Semaphore = require(ReplicatedStorage.Modules.Shared.Async.Semaphore)
local Component = require(ReplicatedStorage.Packages.Component)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local t = require(ReplicatedStorage.Packages.t)
local VEHICLE_SAVE_SLOT = CountableDevProducts.VEHICLE_SAVE_SLOT

local function computeUnlockedSlots()
	return VehiclePropSavesConstants.GetUnlockedSlotCount(CountableDevProductController.GetCount(VEHICLE_SAVE_SLOT))
end

local function isSaveableMotorCar(p: string)
	local item = ItemRegistry.GetItem(p, VehicleMiddleware.VehicleItem)

	if item == nil or item.VehicleImpl.NoMotor then
		return false
	end

	local type = item.VehicleImpl.Type
	return type ~= "boat" and type ~= "air"
end

local function getSaveableSpawnedCars()
	local result = {}
	local vehicles = Workspace:FindFirstChild("Vehicles")

	if vehicles == nil then
		return result
	end

	local name = Players.LocalPlayer.Name

	for _, model in vehicles:GetChildren() do
		if not model:IsA("Model") then
			continue
		end

		local owner = model:FindFirstChild("Owner")

		if not (owner ~= nil and owner:IsA("StringValue") and owner.Value == name) then
			continue
		end

		local vehicleUuid = model:GetAttribute("VehicleUuid")

		if not t.string(vehicleUuid) then
			continue
		end

		local vehicleName = model:GetAttribute("vehicleName")

		if not t.string(vehicleName) then
			continue
		end

		local item = ItemRegistry.GetItem(vehicleName, VehicleMiddleware.VehicleItem)
		local v

		if item == nil or item.VehicleImpl.NoMotor then
			v = false
		else
			local type = item.VehicleImpl.Type
			v = type ~= "boat" and type ~= "air"
		end

		if not v then
			continue
		end

		local item2 = ItemRegistry.GetItem(vehicleName, VehicleMiddleware.VehicleItem)
		table.insert(result, {
			uuid = vehicleUuid,
			icon = item2 == nil and "" or item2:GetIcon() or ""
		})
	end

	return result
end

local v = Component.new({
	Tag = "VehicleSaveStates",
	Extensions = {
		{
			ShouldConstruct = function(_)
				return PlayerFlag.IsEnabled("vehicle-save-catalog")
			end
		}
	}
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.scope = Fusion.scoped(Fusion)
	self.refreshed = self.scope:Value(false)
	self._forceUpdate = self.scope:Value(0)
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
			self.slots:set(v.getSlots(computeUnlockedSlots()))
		end)
		v2:release()
	end

	self.scope:Observer(self.refreshed):onChange(updateSlots)
	self.scope:Observer(self._forceUpdate):onChange(updateSlots)
	self.returnCallback = self.scope:Value(nil)
end

function v.getVehicleIcon(p: string)
	local item = ItemRegistry.GetItem(p, VehicleMiddleware.VehicleItem)

	if item == nil then
		return nil
	end

	return item:GetIcon()
end

function v.getSlots(p: number)
	local v2 = Remotes.invokeServer("VS_VehicleSaves")
	local result = {}

	for i = 1, VehiclePropSavesConstants.MAX_SLOTS do
		if p < i then
			result[i] = {
				Type = "Add",
				DevProduct = CountableDevProducts.GetName(VEHICLE_SAVE_SLOT)
			}
			return result
		end

		local slotName = VehiclePropSavesConstants.GetSlotName(i)
		local v3 = v2[slotName]

		if v3 == nil then
			result[i] = {
				Type = "Empty",
				Slot = slotName
			}
		else
			result[i] = {
				Type = "Save",
				Slot = slotName,
				Name = v3.Name,
				Props = v3.PropCount or 0,
				VehicleName = v3.VehicleName,
				SavedAt = v3.SavedAt
			}
		end
	end

	return result
end

function v.SetReturnCallback(p, callback)
	p.returnCallback:set(callback)
end

function v:SetSource(source: string)
	self.source = source
end

function v:Refresh()
	self.refreshed:set(true)
	self._forceUpdate:set(Fusion.peek(self._forceUpdate) + 1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showConfirmation(p: string, fn)
	local panel = PanelController.GetPanel("NoResetGUIHandler", "ConfirmationPanel")
	ComponentUtil.FindAndWaitForAncestorComponent(panel.Instance, "ConfirmationPanel", ConfirmationPanel):Init(p, fn)
end

function v:doLoad(p: string, flag: boolean?, flag2: boolean?)
	local v2, v3 = Remotes.invokeServer("VS_VehicleBuildLoad", p, self.source, flag, flag2)

	if v2 then
		return
	end

	if v3 == VehiclePropSavesConstants.TOO_MANY_PROPS then
		local function fn(flag3: boolean)
			if flag3 then
				self:doLoad(p, true, flag2)
			else
				NotificationController.NotifyCenter("Too many props", 5)
			end
		end

		showConfirmation("Too many props. Delete oldest props?", fn) -- equivalent call inferred; original call site unknown
	elseif v3 == VehiclePropSavesConstants.EXCEEDS_SERVER_LIMIT then
		local panel = PanelController.GetPanel("NoResetGUIHandler", "ConfirmationPanel")
		ComponentUtil.FindAndWaitForAncestorComponent(panel.Instance, "ConfirmationPanel", ConfirmationPanel):Init(
			"This vehicle has more props than allowed, will not load completely.",
			function(flag3: boolean)
				if flag3 then
					self:doLoad(p, true, true)
				end
			end
		)
	elseif v3 ~= nil then
		NotificationController.NotifyCenter(v3, 5)
	end
end

function v:doSave(p: string, p2: string, flag: boolean?)
	local v2, v3 = Remotes.invokeServer("VS_VehicleBuildSave", p, p2, self.source, flag)

	if v2 then
		self._forceUpdate:set(Fusion.peek(self._forceUpdate) + 1)
		NotificationController.NotifyCenter("Car saved!", 5)
	else
		if v3 ~= VehiclePropSavesConstants.TOO_MANY_PROPS then
			NotificationController.NotifyCenter(v3 or "Unable to save car", 5)
			return
		end

		local function fn(flag2: boolean)
			if flag2 then
				self:doSave(p, p2, true)
			else
				NotificationController.NotifyCenter("Too many props", 5)
			end
		end

		showConfirmation("Too many props. Delete oldest props?", fn) -- equivalent call inferred; original call site unknown
	end
end

function v:beginSave(p: string, flag: boolean)
	local saveableSpawnedCars = getSaveableSpawnedCars()

	if #saveableSpawnedCars == 0 then
		NotificationController.Notify("No spawned vehicle to save")
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function confirmAndSave(p2: string)
		local function fn(flag2: boolean)
			if not flag2 then
				return
			end

			self:doSave(p, p2)
		end

		showConfirmation(
			flag and "Overwrite the existing save with this car and props? This cannot be undone." or "Save car with props?",
			fn
		) -- equivalent call inferred; original call site unknown
	end

	if #saveableSpawnedCars == 1 then
		local uuid = saveableSpawnedCars[1].uuid
		local panel = PanelController.GetPanel("NoResetGUIHandler", "ConfirmationPanel")
		ComponentUtil.FindAndWaitForAncestorComponent(panel.Instance, "ConfirmationPanel", ConfirmationPanel):Init(
			flag and "Overwrite the existing save with this car and props? This cannot be undone." or "Save car with props?",
			function(flag2: boolean)
				if not flag2 then
					return
				end

				self:doSave(p, uuid)
			end
		)
	else
		local mainVehicleMenu = self.Instance:FindFirstAncestor("MainVehicleMenu")
		local vehicleSavePicker

		if mainVehicleMenu ~= nil then
			vehicleSavePicker = mainVehicleMenu:FindFirstChild("VehicleSavePicker")
		end

		if vehicleSavePicker == nil then
			NotificationController.Notify("Unable to pick a vehicle")
		else
			VehicleSavePicker:WaitForInstance(vehicleSavePicker):andThen(function(object2)
				object2:Show(saveableSpawnedCars, function(p2: string?)
					if p2 == nil then
						return
					end

					confirmAndSave(p2) -- equivalent call inferred; original call site unknown
				end)
			end)
		end
	end
end

function v.CanPurchaseMoreSlots()
	local max = CountableDevProducts.GetMax(VEHICLE_SAVE_SLOT)
	return max == nil or CountableDevProductController.GetCount(VEHICLE_SAVE_SLOT) < max
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setPurchaseSlotPrice(purchaseSlot, _: string)
	purchaseSlot.Frame.Button.TextLabel.Text = PlaceholderController.Substitute("Add slot %countabledevproductprice_VEHICLE_SAVE_SLOT%")
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

	for _, item in items do
		if item.Type ~= "Add" then
			continue
		end

		v2 = item
		break
	end

	if v2 == nil then
		return
	end

	if purchaseTopAnchor ~= nil and purchaseSlot2 ~= nil then
		purchaseTopAnchor.Visible = true
		purchaseSlot2.Visible = true
		local _ = v2.DevProduct
		setPurchaseSlotPrice(purchaseSlot2) -- equivalent call inferred; original call site unknown
	end
end

function v.PromptNextSlotPurchase()
	if not v.CanPurchaseMoreSlots() then
		return
	end

	local v2 = VehiclePropSavesConstants.GetUnlockedSlotCount(CountableDevProductController.GetCount(VEHICLE_SAVE_SLOT)) + 1
	CountableDevProductController.PromptPurchase(VEHICLE_SAVE_SLOT, "AddSlot:v" .. tostring(v2))
end

function v:Start()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function onForceUpdate()
		self._forceUpdate:set(Fusion.peek(self._forceUpdate) + 1)
	end

	self._Janitor:Add(CountableDevProductController.GetCountChangedSignal(VEHICLE_SAVE_SLOT):Connect(onForceUpdate))
	self._Janitor:Add(CountableDevProductController.GetCountChangedSignal(CountableDevProducts.PUBLIC_SERVER_PROP_LIMIT):Connect(onForceUpdate))
	self._Janitor:Add(CountableDevProductController.GetCountChangedSignal(CountableDevProducts.PRIVATE_SERVER_PROP_LIMIT):Connect(onForceUpdate))
	self._Janitor:Add(Workspace:GetAttributeChangedSignal(PrivateServerPropLimits.WORKSPACE_ATTR):Connect(onForceUpdate))
	self._Janitor:Add(Workspace:GetAttributeChangedSignal(PropsUtil.DEBUG_PROP_LIMIT_ATTR):Connect(onForceUpdate))
	self._Janitor:Add(GamepassController.OnGamepassUnlocked:Connect(onForceUpdate))
	local instance = self.Instance
	self.saveTemplate = instance.SaveTemplate:Clone()
	self.emptySaveTemplate = instance.EmptySaveTemplate:Clone()
	self.saveTemplate.Visible = false
	self.emptySaveTemplate.Visible = false

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
		end
	end

	self.scope:Observer(self.slots):onBind(function()
		self:updatePurchaseSlots(Fusion.peek(self.slots))
	end)
	self.scope:Hydrate(instance)({
		[Fusion.Children] = self.scope:ForPairs(self.slots, function(_, scope, key, value)
			local v3 = {
				Name = VehiclePropSavesConstants.GetSlotName(key),
				Parent = instance,
				Visible = true,
				LayoutOrder = key
			}

			if value.Type == "Add" then
				return key, nil
			end

			if value.Type == "Save" then
				local v4 = scope:Hydrate(self.saveTemplate:Clone())(v3)
				v4.HouseImage.Value.Image = v.getVehicleIcon(value.VehicleName) or ""
				v4.SaveName.Value.Text = value.Name
				local propLimit = PropsLimitClient.GetPropLimit(GamepassController.IsOwned(Gamepasses.VIP))
				local value2 = v4.PropCount.Value
				value2.Text = tostring(value.Props) .. "/" .. tostring(propLimit) .. " props"

				if propLimit < value.Props then
					value2.TextColor3 = BrickColor.Red().Color
				end

				scope:Hydrate(v4.Save.Value)({
					[Fusion.OnEvent("Activated")] = function()
						self:beginSave(value.Slot, true)
					end
				})
				local value3 = v4.Spawn.Value
				self.scope:Hydrate(value3)({
					[Fusion.OnEvent("Activated")] = function()
						self:doLoad(value.Slot)
					end
				})
				self.scope:Hydrate(v4.Rename.Value)({
					[Fusion.OnEvent("Activated")] = function()
						local value4 = v4.SaveName.Value
						value4:ReleaseFocus(true)

						if value4:GetAttribute("Renaming") then
							return
						end

						value4.TextEditable = true
						value4.PlaceholderText = "Enter name..."
						value4.Interactable = true
						value4:CaptureFocus()
					end
				})
				self.scope:Hydrate(v4.SaveName.Value)({
					[Fusion.OnEvent("FocusLost")] = function()
						local value4 = v4.SaveName.Value
						value4.TextEditable = false
						value4.Interactable = false
						value4:SetAttribute("Renaming", true)
						value4.TextColor3 = Color3.fromRGB(127, 127, 127)
						Remotes.invokeServer("VS_VehicleBuildRename", value.Slot, value4.Text)
						value4:SetAttribute("Renaming", nil)
						value4.TextColor3 = Color3.fromRGB(0, 0, 0)
						onForceUpdate() -- equivalent call inferred; original call site unknown
					end
				})
				return key, v4
			else
				local v4 = scope:Hydrate(self.emptySaveTemplate:Clone())(v3)
				self.scope:Hydrate(v4.Save.Value)({
					[Fusion.OnEvent("Activated")] = function()
						self:beginSave(value.Slot, false)
					end
				})
				return key, v4
			end
		end)
	})
end

function v:Stop()
	self._Janitor:Destroy()
	Fusion.doCleanup(self.scope)
end

return v