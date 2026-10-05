local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Lighting")
local packages = ReplicatedStorage.packages
local Trove = require(packages.Trove)
local modules = ReplicatedStorage.shared.modules
local library = modules.library
local totemcrafting = require(library.totemcrafting)
local items = require(library.items)
local mutations = require(modules.fishing.mutations)
local utils = ReplicatedStorage.shared.utils
local TimeUtils = require(utils.TimeUtils)
local client = ReplicatedStorage.client
local legacyControllers = client.legacyControllers
local TotemCraftingController = require(legacyControllers.Locations.Sunstone.TotemCraftingController)
local DataController = require(legacyControllers.DataController)
local legacy = client.legacy
local legacyUiLoader = require(legacy.legacyUiLoader)
local module = require("@self/SlopCodeHolder")
local uDim = UDim2.fromScale(0.5, 0.5)
local uDim2 = UDim2.fromScale(0.5, 0.38)
local playerGui = legacyUiLoader.PlayerGui
local safezone = playerGui.hud.safezone
local totemCrafting = safezone.TotemCrafting
local list = totemCrafting.List
local close = totemCrafting.Close
local craft = totemCrafting.Craft
local materials = totemCrafting.Materials
local totemInfo = totemCrafting.TotemInfo

local function getTotemInfo(p: string)
	local v = totemcrafting[p]

	if v then
		return v
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fastTween(vector, tweenInfo, p)
	local tween = TweenService:Create(vector, tweenInfo, p)
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	tween:Play()
	return tween
end

local TotemCrafting = {
	_mainTrove = Trove.new(),
	_loadedPageTrove = nil,
	_activeCraftTrove = nil,
	_rosterLoadRoutine = nil,
	_state = {
		isRosterLoaded = false
	},
	_rosterItemTemplate = totemCrafting.List.ScrollingFrame.Recipe,
	_materialTemplate = materials.List._material
}

function TotemCrafting.init()
	TotemCrafting._rosterItemTemplate.Parent = nil
	materials.List._material.Parent = nil
	TotemCrafting._rosterLoadRoutine = coroutine.create(TotemCrafting._loadRoster)
	task.defer(TotemCrafting._connectSignals)
	task.defer(TotemCrafting._bootStandardButtons)
	DataController.InventoryReplicator:Observe({ "Inventory" }, function()
		if not totemCrafting.Visible then
			return
		end

		local text = totemInfo.Info._Name.Text
		local v

		if text and totemcrafting[text] then
			v = totemcrafting[text].Recipe
		end

		TotemCrafting._populateMaterials(v)
	end)
	module(totemCrafting, fastTween, playerGui, safezone)
	totemCrafting.Position = uDim
	totemCrafting.ActiveCraftInfo:GetPropertyChangedSignal("Visible"):Connect(function()
		local v = totemCrafting
		local position

		if totemCrafting.ActiveCraftInfo.Visible then
			position = uDim2
		else
			position = uDim
		end

		v.Position = position
	end)
end

function TotemCrafting.toggle(flag: boolean)
	TotemCrafting._mainTrove:Clean()

	local function open()
		TotemCrafting._loadedPageTrove = TotemCrafting._mainTrove:Extend()
		TotemCrafting._activeCraftTrove = TotemCrafting._mainTrove:Extend()
		totemInfo.Vector.Image = "rbxassetid://-1"
		totemCrafting.Visible = true
		TotemCrafting._populateMaterials()

		if not TotemCrafting._state.isRosterLoaded then
			coroutine.resume(TotemCrafting._rosterLoadRoutine)
		end

		if TotemCraftingController.DataCache.TotemName then
			totemCrafting.ActiveCraftInfo.Visible = true
			TotemCrafting._refreshActive()
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function close2()
		totemCrafting.ActiveCraftInfo.Confirmation.Visible = false
		totemCrafting.Visible = false
		totemCrafting.ActiveCraftInfo.Visible = false
		craft.Visible = false
	end

	if flag then
		totemInfo.Info._Name.Text = ""
		open()
	else
		close2() -- equivalent call inferred; original call site unknown
	end
end

function TotemCrafting._loadRoster()
	local position = totemInfo.Vector.Position

	local function tween()
		local vector = totemInfo.Vector
		vector.Rotation = -25
		vector.Position = UDim2.fromScale(0.85, 0.6)
		fastTween(vector, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Rotation = 0,
			Position = position
		}) -- equivalent call inferred; original call site unknown
	end

	local function load(_, text: string)
		local item = items.Items[text]
		local icon = item and item.Icon
		local clone = TotemCrafting._rosterItemTemplate:Clone()
		clone._Name.Text = text
		clone.Vector.Image = icon or "rbxassetid://-1"
		clone.Parent = list.ScrollingFrame
		clone.Activated:Connect(function()
			tween()
			TotemCrafting._loadRosterPage(text)
		end)
	end

	for k, v in totemcrafting do
		load(v, k)
		task.wait()

		if not totemCrafting.Visible then
			coroutine.yield()
		end
	end

	TotemCrafting._state.isRosterLoaded = true
	TotemCrafting._rosterLoadRoutine = nil
end

function TotemCrafting._loadRosterPage(text: string)
	if not TotemCrafting._state.isRosterLoaded then
		return
	end

	if TotemCrafting._loadedPageTrove then
		TotemCrafting._loadedPageTrove:Clean()
	end

	if not TotemCrafting._loadedPageTrove then
		return
	end

	local item = items.Items[text]
	local dataCache = TotemCraftingController.DataCache

	local function load()
		if text then
			totemInfo.Info._Name.Text = text
			totemInfo.Vector.Image = item.Icon or "rbxassetid://-1"
		end

		if not text then
			text = totemInfo.Info._Name.Text
		end

		if text and totemcrafting[text] then
			TotemCrafting._populateMaterials(totemcrafting[text].Recipe)
		end

		if dataCache.TotemName then
			return
		end

		totemCrafting.Craft.Visible = true
		TotemCrafting._loadedPageTrove:Add(totemCrafting.Craft.Activated:Connect(function()
			TotemCraftingController.Signals.Outbound.Craft:Fire(text)
		end))
	end

	totemInfo.Visible = true
	materials.Visible = true
	load()
end

function TotemCrafting._connectSignals()
	TotemCraftingController.Signals.Inbound.Open:Connect(function()
		TotemCrafting.toggle(true)
	end)
	TotemCraftingController.Signals.Inbound.DataCacheUpdated:Connect(function()
		totemCrafting.ActiveCraftInfo.Visible = TotemCraftingController.DataCache.TotemName ~= nil

		if TotemCraftingController.DataCache.TotemName then
			TotemCrafting._refreshActive()
		elseif TotemCrafting._activeCraftTrove then
			TotemCrafting._activeCraftTrove:Clean()
		end
	end)
end

function TotemCrafting._bootStandardButtons()
	close.Activated:Connect(function()
		TotemCrafting.toggle(false)
	end)
	totemCrafting.ActiveCraftInfo.ClaimOrCancel.Activated:Connect(function()
		TotemCraftingController.Signals.Outbound.Claim:Fire()
	end)
	totemCrafting.ActiveCraftInfo.Cut.Activated:Connect(function()
		local v = totemcrafting[TotemCraftingController.DataCache.TotemName]

		if not v then
			return
		end

		local efficiencyPrice = v.EfficiencyPrice
		totemCrafting.ActiveCraftInfo.Confirmation.CraftInfo.Text = `Are you <b>sure</b> you want to cut the remaining time in half <b>for {efficiencyPrice} C$?</b>`
		totemCrafting.ActiveCraftInfo.Confirmation.Visible = true
	end)
	totemCrafting.ActiveCraftInfo.Confirmation.Yes.Activated:Connect(function()
		totemCrafting.ActiveCraftInfo.Confirmation.Visible = false
		TotemCraftingController.Signals.Outbound.Cut:Fire()
	end)
	totemCrafting.ActiveCraftInfo.Confirmation.No.Activated:Connect(function()
		totemCrafting.ActiveCraftInfo.Confirmation.Visible = false
	end)
end

function TotemCrafting._refreshActive()
	local _activeCraftTrove = TotemCrafting._activeCraftTrove

	if _activeCraftTrove then
		_activeCraftTrove:Clean()
		local v = totemcrafting[TotemCraftingController.DataCache.TotemName]
		totemCrafting.ActiveCraftInfo.ClaimOrCancel.Visible = false

		if v then
			totemCrafting.Craft.Visible = false
			local timeToCraft = v.TimeToCraft
			totemCrafting.ActiveCraftInfo.CraftInfo.Text = `{TotemCraftingController.DataCache.TotemName} Progress`
			_activeCraftTrove:Add(function()
				craft.Visible = true
				TotemCrafting._loadRosterPage(TotemCraftingController.DataCache.TotemName)
			end)
			_activeCraftTrove:Add(task.defer(function()
				while true do
					local visible = totemCrafting.ActiveCraftInfo.ClaimOrCancel.Visible
					local remainingTime = TotemCraftingController.GetRemainingTime()

					if remainingTime then
						local v2 = remainingTime < 0 and 0 or remainingTime
						totemCrafting.ActiveCraftInfo.TimeRemaining.Text = TimeUtils:B(v2)
						local v3 = 1 - v2 / timeToCraft
						local v4 = v3 > 1 and 1 or v3

						if v4 >= 1 then
							totemCrafting.ActiveCraftInfo.TimeRemaining.Text = "Ready!"
							totemCrafting.ActiveCraftInfo.Confirmation.Visible = false

							if not visible then
								totemCrafting.ActiveCraftInfo.ClaimOrCancel.Visible = true
							end
						end

						totemCrafting.ActiveCraftInfo.Progress.InsideProgress.Size = UDim2.fromScale(v4, 1)
						task.wait(1)
					else
						task.wait(1)
					end
				end
			end))
		end
	end
end

function TotemCrafting._populateMaterials(items2)
	if not totemCrafting.Visible then
		return
	end

	for _, frame in materials.List:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	if not items2 then
		return
	end

	DataController.InventoryReplicator:WaitForLoaded()
	local v = {}

	for _, item in items2 do
		for _, v2 in DataController.InventoryReplicator:Index({ "Inventory" }) do
			if item.Component ~= v2.name then
				continue
			end

			local flag = true

			for k, requiredSubvalue in item.RequiredSubvalues do
				if requiredSubvalue == v2.sub[k] then
					continue
				end

				flag = false
				break
			end

			if not flag then
				continue
			end

			if v[item.Component] == nil then
				v[item.Component] = 0
			end

			local component = item.Component
			v[component] += v2.sub.Stack or 1
		end
	end

	for k, item in items2 do
		local _ = item.Component
		local v2 = v[item.Component] or 0
		local clone = TotemCrafting._materialTemplate:Clone()
		clone.Icon.Image = item.Icon or "rbxassetid://-1"
		clone.Amount.Text = `{v2}/{item.Amount}`
		clone.LayoutOrder = k
		local v3 = item
		local mutation = item.RequiredSubvalues.Mutation
		clone.MouseEnter:Connect(function()
			local component = v3.Component

			if mutation and mutations.Mutations[mutation] then
				local mutation2 = mutations.Mutations[mutation]
				component = `{component} (<font color="#{mutation2.Color:ToHex()}">{mutation2.Display}</font>)`
			end

			if v3.RequiredSubvalues.Shiny then
				component = "Shiny " .. component
			end

			if v3.RequiredSubvalues.Sparkling then
				component = "Sparkling " .. component
			end

			local clone2 = script.HoverInfo:Clone()
			local label = clone2.Label
			label.Text = component
			clone2.Parent = clone
			label.Position = UDim2.fromScale(0.5, -0.25)

			if label.Parent then
				local tween = TweenService:Create(
					label,
					TweenInfo.new(0.25, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
					{
						Position = UDim2.fromScale(0.5, -0.5)
					}
				)
				tween.Completed:Once(function()
					tween:Destroy()
				end)
				tween:Play()
			end
		end)
		local parent = clone
		clone.MouseLeave:Connect(function()
			for i, child in parent:GetChildren() do
				if child.Name == "HoverInfo" then
					child:Destroy()
				end
			end
		end)
		clone.Parent = materials.List
	end
end

return TotemCrafting