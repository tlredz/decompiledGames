local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local StateUtil = require(game.ReplicatedStorage.Controllers.UI.FruitShop.StateUtil)
local Signal = require(game.ReplicatedStorage.Packages.Signal)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
local DragonSelectionMenu = require(game.ReplicatedStorage.React.Components.DragonSelectionMenu)
local ConfirmationDialog = require(game.ReplicatedStorage.React.Components.ConfirmationDialog)
local useHasTag = require(game.ReplicatedStorage.React.Hooks.Instance.useHasTag)
local commRemoteFunc = StateUtil.CommRemoteFunc
local createElement = React.createElement

function newDebounce(p: number)
	local v = 0
	return function()
		local now = tick()

		if p < now - v then
			v = now
			return true
		else
			return false
		end
	end
end

function respondAsync(flag: boolean, p)
	commRemoteFunc:InvokeServer("ClassicDragonGui1", p, flag)
end

local class = {}
class.__index = class

function class:Open()
	if self.IsOpen then
		return
	end

	self.IsOpen = true
	self._OnOpen:Fire()
	local GUID = HttpService:GenerateGUID(false)
	self._UID = GUID
	local root = ReactRoblox.createRoot(self._Root)
	local flag = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cleanUp()
		if not flag then
			return
		end

		flag = false
		self.OnClose:Fire()

		if GUID == self._UID then
			self.IsOpen = false
			self._UID = nil
			self._CleanUp = nil
		end

		root:unmount()
	end

	local v = newDebounce(1)

	local function component(_)
		local state2, setState = React.useState(nil)
		local state3, setState2 = React.useState(state2 ~= nil)
		React.useEffect(function()
			local flag2 = false
			task.defer(function()
				if flag2 then
					return
				end

				if not state3 and state2 then
					setState2(state2 ~= nil)
				end
			end)
			return function()
				flag2 = true
			end
		end, { state3, state2 })
		local flag2 = useHasTag("IsPermChoiceOpen", Players.LocalPlayer)
		local flag3 = useHasTag("IsClassicChoiceOpen", Players.LocalPlayer)
		local flag4 = useHasTag("ForceDragonChoiceEast", Players.LocalPlayer)
		local flag5 = useHasTag("ForceDragonChoiceWest", Players.LocalPlayer)
		local v2 = React.useMemo(function()
			if flag4 then
				return "ForceEast"
			end

			if flag5 then
				return "ForceWest"
			end

			if flag3 or flag2 then
				return "Selection"
			end

			return nil
		end, { flag3 or flag2, flag4, flag5 })
		local v3 = React.useMemo(function()
			if v2 == "ForceEast" then
				return "East"
			elseif v2 == "ForceWest" then
				return "West"
			end

			return nil
		end, { v2 })
		local v4 = React.useMemo(function()
			return v2 == "ForceEast" or v2 == "ForceWest"
		end, { v2 })
		React.useEffect(function()
			local flag6 = false
			task.defer(function()
				if flag6 then
					return
				end

				if v2 == nil then
					cleanUp() -- equivalent call inferred; original call site unknown
				end
			end)
			return function()
				flag6 = true
			end
		end, { v2 == nil })
		local fragment = React.Fragment
		local warningDialog

		if state3 then
			warningDialog = createElement(ConfirmationDialog, {
				Title = "WARNING",
				Body = `You have selected {FormatUtil.arrowBracket(`{v4 and "" or "Permanent "}Dragon ({state2})`, "Red")} Fruit.\nWould you like to proceed?`,
				ConfirmText = "Continue",
				CancelText = "Cancel",
				OnCloseComplete = function()
					setState2(false)
					print("complete dialog close")
				end,
				OnResponse = function(flag6: boolean)
					print("response", flag6)

					if not v() then
						return
					end

					if state2 then
						setState(nil)
					end

					print("responding", flag6)

					if flag6 then
						respondAsync(v4, state2)
					end
				end
			})
		end

		return createElement(fragment, {}, {
			WarningDialog = warningDialog,
			DragonSelectionMenu = createElement(DragonSelectionMenu, {
				IsOpen = true,
				IsQuick = false,
				EquipButtonText = "Claim",
				IsEastEnabled = not flag5,
				IsWestEnabled = not flag4,
				HeaderOverride = "Claim your Dragon",
				BodyText = v4 and flag2 and "Convert." or flag2 and "You can select from one of the following eastern/western versions." or not v4 and "You can convert your Permanent Dragon to one of the following eastern/western versions." or `Your Dragon Fruit has been converted \ninto the {FormatUtil.arrowBracket(`Dragon ({v3})`, "Green")} Fruit at random.`,
				IsControllerActive = not state3,
				OnDiscountClick = not (flag4 or flag5) and function()
					if v() and not state3 then
						print("Discount")
						respondAsync(v4, nil)
					end
				end or nil,
				OnSelectionClick = function(p: string?)
					if not v() or state3 then
						return
					end

					print("selection", p)

					if state2 ~= p then
						setState(p)
					end
				end,
				OnCloseComplete = function()
					if not v() then
						return
					end

					print("Closed")
				end
			})
		})
	end

	root:render(createElement(component, {}, {}))
	self._CleanUp = cleanUp
end

function class:Close()
	if not self.IsOpen then
		return
	end

	self.IsOpen = false

	if self._CleanUp then
		self._CleanUp()
		self._CleanUp = nil
	end

	self.OnClose:Fire()
end

local folder = Instance.new("Folder")
folder.Name = "Root"
folder.Parent = script.Parent
return (setmetatable({
	_Root = folder,
	_CleanUp = nil,
	_UID = nil,
	IsOpen = false,
	_OnOpen = Signal.new(),
	OnClose = Signal.new(),
	IsFruitDealer = nil
}, class))