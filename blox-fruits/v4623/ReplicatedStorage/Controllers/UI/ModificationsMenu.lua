local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local ServiceLocker = require(game.ReplicatedStorage.Packages.ServiceLocker)
local Signal = require(game.ReplicatedStorage.Packages.Signal)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local IdMap = require(game.ReplicatedStorage.IdMap)
local Global = require(game.ReplicatedStorage.Global)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local ModificationController = require(game.ReplicatedStorage.Controllers.ModificationController)
local Modification = require(game.ReplicatedStorage.Util.Modification)
local HUD = require(game.ReplicatedStorage.Controllers.UI.HUD)
local BundleMenu = require(game.ReplicatedStorage.Controllers.UI.BundleMenu)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("Modifications"):tag("UI"):tag("Controller"):traceback():display():build()
local DrawContextProvider = require(game.ReplicatedStorage.React.Components.DrawContextProvider)
local ModificationsMenu = require(game.ReplicatedStorage.React.Components.ModificationsMenu)
local useData = require(game.ReplicatedStorage.React.Hooks.Item.Modification.useData)
local useAdorneeData = require(game.ReplicatedStorage.React.Hooks.Item.Modification.useAdorneeData)
local usePurchasable = require(game.ReplicatedStorage.React.Hooks.Item.Modification.usePurchasable)
local useEquipped = require(game.ReplicatedStorage.React.Hooks.Item.Modification.useEquipped)
local previewable = { IdMap.Mutation.KITSUNEMUTKyukon, IdMap.Mutation.TIGERMUTWerewolf, IdMap.Mutation.YETIMUTFiend }
local playerGui

if RunService:IsRunning() then
	local Players = game:GetService("Players")
	playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
else
	playerGui = game:GetService("CoreGui")
end

local class = {}
class.__index = class

function class:Open(p)
	v.info(function()
		local copy = TableUtil.deepCopy(p)
		copy.AvailableModifications = copy.AvailableModifications and ItemConfig.mapDebug(copy.AvailableModifications)
		copy.SelectedModificationId = copy.SelectedModificationId and ItemConfig.match(copy.SelectedModificationId):unwrap().Index.DebugLabel
		return ":Open(", copy
	end)

	if self._IsOpen then
		v.trace("already open")
		return
	end

	task.spawn(function()
		Modification.Data.refreshAsync()
	end)
	self._IsOpen = true
	self._OnOpen:Fire(p)
end

function class:IsOpen()
	return self._IsOpen
end

function class:Close()
	v.info(":Close()")

	if not self._IsOpen then
		v.trace("already closed")
		return
	end

	self._IsOpen = false
	self._OnClose:Fire()
	self.OnClosed:Fire()
end

return ServiceLocker(function()
	v.info("init()")
	local object = setmetatable({
		IsInitialized = true,
		_Connections = {},
		_IsOpen = false,
		OnClosed = Signal.new(),
		_OnOpen = Signal.new(),
		_OnClose = Signal.new(),
		_Controllers = {}
	}, class)

	local function component(p)
		local state, setState = React.useState(object._IsOpen)
		local state2, setState2 = React.useState(false)
		local state3, setState3 = React.useState(nil)
		local state4, setState4 = React.useState(nil)
		local state5, setState5 = React.useState(nil)
		local v3 = useData()
		local v4 = useAdorneeData()
		local state6, setState6 = React.useState("FruitSkin")
		React.useEffect(function()
			v.trace(function()
				return "useAdorneeData", Modification.Data.Adornee.debug(v4)
			end)
		end, { v4 })
		React.useEffect(function()
			v.trace(function()
				return "useModificationData", Modification.Data.Modification.debug(v3)
			end)
		end, { v3 })
		React.useEffect(function()
			local connection = object._OnOpen:Connect(function(data)
				v.extend("self._OnOpen React Effect", nil).trace(function()
					local copy = TableUtil.deepCopy(data)
					copy.AvailableModifications = copy.AvailableModifications and ItemConfig.mapDebug(copy.AvailableModifications)
					copy.SelectedModificationId = copy.SelectedModificationId and ItemConfig.match(copy.SelectedModificationId):unwrap().Index.DebugLabel
					return "openInfo", copy
				end)
				setState4(data.AvailableModifications)
				setState2(data.PurchaseEnabled == true)

				if data.Type == "MovesetSkin" then
					if data.MovesetType == "Sword" then
						setState6("SwordSkin")
					elseif data.MovesetType == "Fruit" then
						setState6("FruitSkin")
					else
						error((`moveset type "{data.MovesetType}" is not currently supported`))
					end

					setState5(data.AdorneeId)
					setState3(data.SelectedModificationId)
				elseif data.Type == "AuraSkin" then
					setState6("AuraSkin")
					setState5(nil)
					setState3(data.SelectedModificationId)
				elseif data.Type == "MovesetMutation" then
					assert(data.MovesetType == "Fruit", "only fruit Moveset type is supported for mutations atm")
					setState6("FruitMutation")
					setState5(data.AdorneeId)
					setState3(data.SelectedModificationId)
				else
					error((`unknown openInfo type: "{data.Type}"`))
				end

				setState(true)
			end)
			local onClosedConnection = object.OnClosed:Connect(function()
				setState(false)
				setState5(nil)
				setState3(nil)
			end)
			return function()
				connection:Disconnect()
				onClosedConnection:Disconnect()
			end
		end, {})
		local purchasable = usePurchasable()
		local equipped = useEquipped()
		local modifications = React.useMemo(function()
			local clone

			if state4 then
				clone = table.clone(state4)
			else
				clone = Modification.getAllModifications()
			end

			local result = {}

			for _, v8 in clone do
				local ifCanUse = Modification.getIfCanUse(v8, v3, v4)
				local v9 = state2 and Modification.getIfCanPurchase(v8, v3, v4)

				if ifCanUse or v9 or table.find(previewable, v8) then
					table.insert(result, v8)
				end
			end

			return result
		end, {
			v4,
			v3,
			state4,
			state2,
			previewable
		})
		local createElement = React.createElement
		local v9 = {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Active = state,
			Visible = not p.IsPreviewOpen
		}
		local createElement2 = React.createElement
		local v12 = {
			IsOpen = state,
			InitialAdorneeId = state5,
			InitialModificationId = state3,
			Modifications = modifications,
			Equipped = equipped,
			MenuType = state6,
			Previewable = previewable,
			Purchasable = 0,
			Position = 0,
			AnchorPoint = 0,
			OnPreview = 0,
			OnPurchase = 0,
			OnEquip = 0,
			OnExit = 0
		}

		if not state2 then
			purchasable = nil
		end

		v12.Purchasable = purchasable
		v12.Position = UDim2.fromScale(0.5, 0.5)
		v12.AnchorPoint = Vector2.new(0.5, 0.5)

		function v12.OnPreview(p2: number)
			local viewportSize = workspace.CurrentCamera.ViewportSize
			local v13 = viewportSize * 0.5
			local v14 = (viewportSize - v13) * 0.5
			local v15

			if p2 == IdMap.Mutation.KITSUNEMUTKyukon then
				v15 = "FoxSpiritBundle2025"
			elseif p2 == IdMap.Mutation.TIGERMUTWerewolf then
				v15 = "HalloweenBundle2025"
			elseif p2 == IdMap.Mutation.YETIMUTFiend then
				v15 = "Valentines2026Bundle"
			else
				return
			end

			BundleMenu:Open(v13, v14, v15, p.SetIsPreviewOpen)
		end

		function v12.OnPurchase(p2: number)
			while true do
				local Global2 = require(game.ReplicatedStorage.Global)

				if Global2.hookBuy then
					break
				end

				task.wait()
			end

			local unwrapped = ItemConfig.match(p2):unwrap()
			assert(unwrapped.Index.IdType == "Redeemable", (`bad idType for "{unwrapped.Index.DebugLabel}"`))
			Global.hookBuy(unwrapped.Index.StorageKey, "Buy")
		end

		function v12.OnEquip(p2: number, flag: boolean)
			v.info((`OnEquip(itemId={p2}, value={flag})`))
			assert(ModificationController.IsInitialized, "bad ModificationController")
			ModificationController:SetEquipAsync(p2, flag)
		end

		function v12.OnExit()
			object:Close()
		end

		return createElement("Frame", v9, {
			Menu = createElement2(ModificationsMenu, v12, {})
		})
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	screenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
	screenGui.IgnoreGuiInset = true
	screenGui.Name = "ModificationsMenuRoot"
	screenGui.Parent = playerGui
	screenGui.DisplayOrder = 50
	screenGui.Enabled = true
	screenGui.ResetOnSpawn = false
	local root = ReactRoblox.createRoot(screenGui)
	task.spawn(function()
		root:render((ReactRoblox.createPortal(React.createElement(function(_)
			local state, setState = React.useState(object._IsOpen and "Default" or "Offscreen")
			local state2, setState2 = React.useState(false)
			React.useEffect(function()
				local connection = object._OnOpen:Connect(function()
					setState("Default")
				end)
				local onClosedConnection = object.OnClosed:Connect(function()
					task.wait(5)

					if not object._IsOpen then
						setState("Offscreen")
					end
				end)
				return function()
					connection:Disconnect()
					onClosedConnection:Destroy()
				end
			end, {})
			return React.createElement(DrawContextProvider, {
				Context = state2 and "Offscreen" or state
			}, {
				ModificationsMenu = React.createElement(component, {
					IsPreviewOpen = state2,
					SetIsPreviewOpen = setState2
				})
			})
		end, {}), screenGui)))
	end)
	task.spawn(function()
		while not HUD.IsInitialized do
			task.wait()
		end

		assert(HUD.IsInitialized, "bad HUD")
		HUD:RegisterPage("Modifications", function(...)
			return object:Open(...)
		end, function()
			return object:Close()
		end, function()
			return object:IsOpen()
		end)
	end)
	return object
end, function(list)
	for _, _Connection in list._Connections do
		_Connection:Disconnect()
	end

	setmetatable(list, nil)
	table.clear(list)
end)