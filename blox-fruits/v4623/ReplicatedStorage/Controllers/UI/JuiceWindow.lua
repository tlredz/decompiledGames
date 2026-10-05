local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local ServiceLocker = require(game.ReplicatedStorage.Packages.ServiceLocker)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local Signal = require(game.ReplicatedStorage.Packages.Signal)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Modification = require(game.ReplicatedStorage.Util.Modification)
local Net = require(game.ReplicatedStorage.Modules.Net)
local Skin = require(game.ReplicatedStorage.Definitions.Skin)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
local IdMap = require(game.ReplicatedStorage.IdMap)
local DrawContextProvider = require(game.ReplicatedStorage.React.Components.DrawContextProvider)
local HUD = require(game.ReplicatedStorage.Controllers.UI.HUD)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("Juice"):tag("UI"):tag("Controller"):traceback():display():build()
local DrawContextProvider2 = require(game.ReplicatedStorage.React.Components.DrawContextProvider)
local JuiceMenu = require(game.ReplicatedStorage.React.Components.JuiceMenu)
local useUnlocked = require(game.ReplicatedStorage.React.Hooks.Item.Modification.useUnlocked)
local useUsableAdornees = require(game.ReplicatedStorage.React.Hooks.Item.Modification.useUsableAdornees)
local useForSale = require(game.ReplicatedStorage.React.Hooks.Item.Modification.useForSale)
local formatted = `{FormatUtil.font("[Robux]", {
	color = Color3.fromHex("33B423")
})} purchases do not consume materials.`
local v2 = { IdMap.Skin.PORTALSKINorange, IdMap.Skin.PORTALSKINpink }
local v3 = {
	IdMap.Skin.WSTDSKINeclipse,
	IdMap.Skin.ESTDSKINeclipse,
	IdMap.Skin.WSTDSKINbloodmoon,
	IdMap.Skin.ESTDSKINbloodmoon,
	IdMap.Skin.WSTDSKINphoenixsky,
	IdMap.Skin.ESTDSKINphoenixsky,
	IdMap.Skin.ESTDSKINember,
	IdMap.Skin.WSTDSKINember
}
local playerGui

if RunService:IsRunning() then
	local Players2 = game:GetService("Players")
	playerGui = Players2.LocalPlayer:WaitForChild("PlayerGui")
else
	playerGui = game:GetService("CoreGui")
end

local createElement = React.createElement

local function fetchCraftingInventory()
	local v4 = Net:RemoteFunction("JuiceNetworkRF"):InvokeServer({
		Context = "GetRecipesAndMaterials"
	})
	local materialsByItemId = {}

	if not v4 or typeof(v4) ~= "table" or not v4.Materials then
		return materialsByItemId, {}
	end

	for k, material in v4.Materials do
		local nullable = ItemConfig.match(k, "Material"):asNullable()

		if nullable then
			materialsByItemId[nullable.Index.ItemId] = material
		end
	end

	return materialsByItemId, v4.Recipes
end

local class = {}
class.__index = class

function class:Open(p)
	v.info(function()
		return ":Open(", p
	end)

	if self._IsOpen then
		v.trace("already open")
	else
		task.spawn(function()
			Modification.Data.refreshAsync()
		end)
		self._IsOpen = true
	end

	self._OnOpen:Fire(p)
end

function class:IsOpen()
	return self._IsOpen
end

function class.GetIfCanView(_)
	if not RunService:IsRunning() then
		return false
	end

	local modification = Modification.Data.Modification.fromItemReplication(Players.LocalPlayer)
	local adornee = Modification.Data.Adornee.fromItemReplication(Players.LocalPlayer)

	for _, v4 in {
		Modification.getUnlockable(modification, adornee, nil, "Skin"),
		Modification.getUnlocked(modification, adornee, nil, "Skin")
	} do
		for _, v5 in v4 do
			local nullable = ItemConfig.match(v5):asNullable()

			if not nullable or not nullable.Skin or nullable.Skin.IsDefault then
				continue
			end

			if not (nullable.Skin.Type ~= "Fruit" and nullable.Skin.Type ~= "Sword" and nullable.Skin.Type ~= "Aura") then
				return true
			end
		end
	end

	return false
end

function class:Close()
	v.info(":Close()")

	if not self._IsOpen then
		v.trace("already closed")
		return
	end

	self._IsOpen = false
	self.OnClosed:Fire()
end

function class:WaitForClose()
	if not self._IsOpen then
		return
	end

	self.OnClosed:Wait()
end

return ServiceLocker(function()
	v.info("init()")
	local object = setmetatable({
		IsInitialized = true,
		_Connections = {},
		_IsOpen = false,
		OnClosed = Signal.new(),
		_OnOpen = Signal.new()
	}, class)

	local function requestPurchase(p: number, p2: string)
		local nullable = ItemConfig.match(p):asNullable()

		if not nullable then
			return
		end

		task.spawn(function()
			while true do
				local Global = require(game.ReplicatedStorage.Global)

				if Global.hookBuy then
					break
				end

				task.wait()
			end

			local Global = require(game.ReplicatedStorage.Global)
			Global.hookBuy(nullable.Index.StorageKey, p2)
		end)
	end

	local function handleAction(p)
		v.info(function()
			return "handleAction(", p
		end)

		if p.Type == "Back" then
			object:Close()
		elseif p.Type == "Craft" then
			local nullable = ItemConfig.match(p.ItemId):asNullable()

			if not nullable then
				return
			end

			task.spawn(function()
				if Net:RemoteFunction("JuiceNetworkRF"):InvokeServer({
					Context = "Craft",
					StorageName = nullable.Index.StorageKey
				}) then
					object:Close()
				end
			end)
		elseif p.Type == "Purchase" then
			local itemId = p.ItemId
			local nullable = ItemConfig.match(itemId):asNullable()

			if not nullable then
				return
			end

			local v4 = "Buy"
			task.spawn(function()
				while true do
					local Global = require(game.ReplicatedStorage.Global)

					if Global.hookBuy then
						break
					end

					task.wait()
				end

				local Global = require(game.ReplicatedStorage.Global)
				Global.hookBuy(nullable.Index.StorageKey, v4)
			end)
		elseif p.Type == "Gift" then
			local itemId = p.ItemId
			local nullable = ItemConfig.match(itemId):asNullable()

			if not nullable then
				return
			end

			local v4 = "Gift"
			task.spawn(function()
				while true do
					local Global = require(game.ReplicatedStorage.Global)

					if Global.hookBuy then
						break
					end

					task.wait()
				end

				local Global = require(game.ReplicatedStorage.Global)
				Global.hookBuy(nullable.Index.StorageKey, v4)
			end)
		end
	end

	local function component(_)
		local state, setState = React.useState(object._IsOpen)
		local state2, setState2 = React.useState(nil)
		local state3, setState3 = React.useState({})
		local state4, setState4 = React.useState({})
		local owned = useUnlocked()
		React.useEffect(function()
			local connection = object._OnOpen:Connect(function(p)
				setState2(p)
				setState(true)
			end)
			local onClosedConnection = object.OnClosed:Connect(function()
				setState(false)
			end)
			return function()
				connection:Disconnect()
				onClosedConnection:Disconnect()
			end
		end, {})
		React.useEffect(function()
			if not state then
				return
			end

			local v5 = false
			local thread = task.spawn(function()
				local v6, v7 = fetchCraftingInventory()

				if not v5 then
					setState3(v6)
					setState4(v7)
				end
			end)
			return function()
				v5 = true
				task.cancel(thread)
			end
		end, { state })
		local v5 = useUsableAdornees()
		local v6 = useForSale()
		local v7 = React.useMemo(function()
			local result = {}

			for _, v8 in v6 do
				local nullable = Modification.matchAdornee(v8):asNullable()

				if nullable and table.find(v5, nullable) then
					table.insert(result, nullable)
				end
			end

			TableUtil.deduplicate(result)
			return result
		end, { v6, v5 })
		local items = React.useMemo(function()
			local v9 = ItemConfig.Query.select({
				Index = {
					IdType = "Skin"
				},
				Skin = {
					IsDefault = false
				}
			})
			local itemIds = {}

			for _, v10 in v9 do
				if table.find(v3, v10.Index.ItemId) then
					continue
				end

				local unwrapped = Modification.matchAdornee(v10.Index.ItemId):unwrap()

				if not (table.find(v5, unwrapped) or table.find(v7, unwrapped)) then
					continue
				end

				table.insert(itemIds, v10.Index.ItemId)
			end

			local categories = state2 and state2.Categories

			if not categories then
				return itemIds
			end

			local v10 = {}

			for _, category in categories do
				v10[category] = true
			end

			local result = {}

			for _, v11 in itemIds do
				local nullable = ItemConfig.match(v11):asNullable()

				if nullable and nullable.Skin and v10[nullable.Skin.Type] then
					table.insert(result, v11)
				end
			end

			return result
		end, {
			state2,
			v5,
			v6,
			v7
		})
		local unlocked = React.useMemo(function()
			local result = {}

			for _, v10 in items do
				if table.find(v2, v10) then
					continue
				end

				if Skin.Definition.Recipe.match(v10):isNone() then
					table.insert(result, v10)
				elseif Skin.Definition.Quest.match(v10):isNone() then
					table.insert(result, v10)
				elseif state4[ItemConfig.match(v10):unwrap().Index.StorageKey] then
					table.insert(result, v10)
				end
			end

			return result
		end, { items, state4 })
		return createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Active = state,
			Visible = state
		}, {
			DrawContentProvider = createElement(DrawContextProvider, {
				Context = state and "Default" or "Offscreen"
			}, {
				Menu = React.createElement(JuiceMenu, {
					Items = items,
					Unlocked = unlocked,
					Owned = owned,
					HeaderText = not state2 and "Select a recipe" or state2.HeaderText or "Select a recipe",
					AdorneeHeaderText = not state2 and "Select an item" or state2.AdorneeHeaderText or "Select an item",
					FooterText = state2 and state2.FooterText or formatted,
					CraftingInventory = state3,
					OnAction = handleAction
				})
			})
		})
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	screenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
	screenGui.IgnoreGuiInset = true
	screenGui.Name = "JuiceWindowRoot"
	screenGui.Parent = playerGui
	screenGui.DisplayOrder = 7
	screenGui.Enabled = true
	screenGui.ResetOnSpawn = false
	local root = ReactRoblox.createRoot(screenGui)
	task.spawn(function()
		root:render((ReactRoblox.createPortal(React.createElement(function(_)
			local state, setState = React.useState(object._IsOpen and "Default" or "Offscreen")
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
			return React.createElement(DrawContextProvider2, {
				Context = state
			}, {
				ModificationsMenu = React.createElement(component, {})
			})
		end, {}), screenGui)))
	end)
	task.spawn(function()
		while not HUD.IsInitialized do
			task.wait()
		end

		assert(HUD.IsInitialized, "bad HUD")
		HUD:RegisterPage("Juice", function(...)
			return object:Open(...)
		end, function(...)
			return object:Close(...)
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