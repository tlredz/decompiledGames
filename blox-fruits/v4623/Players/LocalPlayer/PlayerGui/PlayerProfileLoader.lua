local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local PlayerProfile = require(ReplicatedStorage.React.Components.PlayerProfile)
require(ReplicatedStorage.React.Components.PlayerProfile.Types)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
require(ReplicatedStorage.React.Components.Inventory.Types)
local Inventory = require(ReplicatedStorage.Controllers.UI.Inventory)
local HUD = require(ReplicatedStorage.Controllers.UI.HUD)
local IdMap = require(ReplicatedStorage.IdMap)
local ItemId = require(ReplicatedStorage.Economy.ItemId)
local GlobalUtil = require(ReplicatedStorage.GlobalUtil)
local ItemConfig = require(ReplicatedStorage.ItemConfig)
local Notification = require(ReplicatedStorage:WaitForChild("Notification"))
local AnalyticsUtil = require(ReplicatedStorage.Util.AnalyticsUtil)
local ImageUtil

if GlobalUtil.FFlags.IsUnitTest then
	ImageUtil = nil
else
	ImageUtil = require(ReplicatedStorage.Modules.Asset.ImageUtil)
end

local PlayerProfileLookup = require(ReplicatedStorage.Controllers.UI.PlayerProfileLookup)
local CONSTANTS = require(ReplicatedStorage.React.Components.PlayerProfile.CONSTANTS)
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local getPlayerProfileData = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GetPlayerProfileData")
local getPlayerStats = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GetPlayerStats")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlayerProfile"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 1
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
local frame = Instance.new("Frame")
frame.Name = "ROOT"
frame.BackgroundTransparency = 1
frame.Size = UDim2.new(1, 0, 1, 0)
frame.Parent = screenGui
screenGui.Parent = playerGui
local bindableEvent = Instance.new("BindableEvent")
bindableEvent.Name = "OpenPlayerProfile"
bindableEvent.Parent = screenGui

function rootComponent(_)
	local state, setState = React.useState(TableUtil.deepCopy(CONSTANTS.DEFAULT_LOADED_PLAYER))
	local state2, setState2 = React.useState("Profile")
	local state3, setState3 = React.useState(false)
	local state4, setState4 = React.useState(false)
	local state5, setState5 = React.useState(false)
	local state6, setState6 = React.useState(false)
	local state7, setState7 = React.useState(0)
	local state8, setState8 = React.useState({})
	local state9, setState9 = React.useState({})
	local state10, setState10 = React.useState(false)
	local state11, setState11 = React.useState(false)
	local ref = React.useRef(0)
	local setLoadedPlayer = React.useCallback(function(p: number?, flag: boolean?, flag2: boolean?)
		local userId = p or state.UserId
		task.spawn(function()
			if userId ~= Players.LocalPlayer.UserId then
				AnalyticsUtil.reportActivity("PlayerProfile/ViewedSelf")
			elseif Players:GetPlayerByUserId(userId) then
				AnalyticsUtil.reportActivity("PlayerProfile/ViewedInServer")
			elseif Players.LocalPlayer:IsFriendsWith(userId) then
				AnalyticsUtil.reportActivity("PlayerProfile/ViewedGlobalFriend")
			else
				AnalyticsUtil.reportActivity("PlayerProfile/ViewedGlobal")
			end
		end)
		local profileData = flag2 and state.ProfileData or getPlayerProfileData:InvokeServer(userId)

		if profileData == nil then
			Notification.new("<Color=Red>User has no Blox Fruits data.<Color=/>"):Display()
			setState10(false)
		elseif profileData == false then
			Notification.new("<Color=Red>Request failed because of rate limits. Try again shortly.<Color=/>"):Display()
			setState10(false)
		else
			local current = ref.current + 1
			ref.current = current

			if flag == true then
				setState10(true)
			end

			setState(TableUtil.deepCopy(CONSTANTS.DEFAULT_LOADED_PLAYER))
			setState11(true)
			task.spawn(function()
				local v4 = getPlayerProfileData:InvokeServer(userId)

				if ref.current ~= current then
					return
				end

				if v4 == nil then
					Notification.new("<Color=Red>User has no Blox Fruits data.<Color=/>"):Display()
					setState10(false)
				elseif v4 == false then
					Notification.new("<Color=Red>Request failed because of rate limits. Try again shortly.<Color=/>"):Display()
					setState10(false)
				else
					local v5 = {
						UserId = userId,
						IsLocalPlayer = Players.LocalPlayer.UserId == userId,
						IsPreviewMode = false,
						OwnedBackgrounds = {},
						NewBackgrounds = {},
						ProfileData = GlobalUtil.FFlags.IsUnitTest == false and v4 or CONSTANTS.DEFAULT_PROFILE_DATA
					}

					if v5.IsLocalPlayer then
						local v6, ownedBackgrounds, v8 = ReplicatedStorage.Remotes.GetProfileBackgroundList:InvokeServer()

						if ref.current ~= current then
							return
						end

						if v6 then
							v5.OwnedBackgrounds = ownedBackgrounds
							v5.NewBackgrounds = v8 or {}
						end
					end

					setState(v5)
					setState11(false)
				end
			end)
		end
	end, { state })
	local clearNewBackground = React.useCallback(function(p: string)
		task.spawn(function()
			pcall(function()
				ReplicatedStorage.Remotes.UpdatePlayerProfileValue:InvokeServer("ClearNewBackground", p)
			end)
		end)
		setState(function(p2)
			if p2.NewBackgrounds[p] == nil then
				return p2
			end

			local clone = table.clone(p2.NewBackgrounds)
			clone[p] = nil
			local clone2 = table.clone(p2)
			clone2.NewBackgrounds = clone
			return clone2
		end)
	end, {})
	local patchProfileData = React.useCallback(function(items)
		setState(function(p)
			local clone = table.clone(p.ProfileData)

			for k, item in items do
				if item == CONSTANTS.CLEAR then
					item = nil
				end

				clone[k] = item
			end

			local clone2 = table.clone(p)
			clone2.ProfileData = clone
			return clone2
		end)
	end, {})
	React.useEffect(function()
		if GlobalUtil.FFlags.IsUnitTest == false then
			setState8((getPlayerStats:InvokeServer()))
		end
	end, { state4 })
	React.useEffect(function()
		local function openMethod(p: number?)
			AnalyticsUtil.reportActivity("PlayerProfile/Opened")
			setLoadedPlayer(p or Players.LocalPlayer.UserId, true)
		end

		local eventConnection = bindableEvent.Event:Connect(openMethod)
		local Global = require(game.ReplicatedStorage.Global)

		function Global.closePlayerProfile()
			setState10(false)
		end

		local Global2 = require(game.ReplicatedStorage.Global)

		function Global2.getProfileOpen()
			return state10
		end

		task.spawn(function()
			while not HUD.IsInitialized do
				task.wait()
			end

			assert(HUD.IsInitialized, "bad HUD")
			HUD:RegisterPage("PlayerProfile", function(...)
				return openMethod(...)
			end, function(...)
				local Global3 = require(game.ReplicatedStorage.Global)
				return Global3.closePlayerProfile()
			end, function()
				local Global3 = require(game.ReplicatedStorage.Global)
				return Global3.getProfileOpen()
			end)
		end)
		return function()
			eventConnection:Disconnect()
		end
	end, {})
	React.useEffect(function()
		if state10 ~= false then
			local thread = task.spawn(function()
				local v4 = {}

				for _, v5 in Inventory:GetTiles() do
					local unwrapped = ItemConfig.match(v5.ItemId):unwrap()

					if not (unwrapped.Inventory.CanShowcase and unwrapped.Index.IdType ~= "Title" and unwrapped.Index.ItemId ~= IdMap.Title["true egglord"]) then
						continue
					end

					table.insert(v4, v5)
				end

				local unwrapOr = ItemId.getId("Carp", "Fish"):unwrapOr(0)
				local v5 = ItemConfig.tryGet(unwrapOr)

				if v5 and v5.Display.Sprite then
					local v6 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("getTitles")
					print("allTitles", v6)
					local names = {}

					for _, v7 in v6 do
						if v7.Name ~= "(LOCKED)" then
							table.insert(names, v7.Name)
						end
					end

					local v7 = {}

					for _, v8 in names do
						local nullable = ItemId.getId(v8, "Title"):asNullable()
						local v9

						if nullable then
							v9 = ItemConfig.tryGet(nullable)
						end

						local v10

						if v9 and v9.Display.Sprite and v9.Display.Sprite.Image ~= v5.Display.Sprite.Image and not v7[v9.Index.ItemId] then
							v7[v9.Index.ItemId] = true
							v10 = true
						else
							v10 = false
						end

						if v9 and v10 then
							local sprite = v9.Display.Sprite
							local v11

							if ImageUtil then
								v11 = ImageUtil.getAssetSprite(v8)
							end

							if v11 and not sprite then
								local icon = v11.Icon

								if icon and icon.Image ~= "rbxasset://textures/ui/PlayerList/Block@3x.png" then
									table.freeze({
										Image = icon.Image,
										ImageRectOffset = icon.ImageRectOffset,
										ImageRectSize = icon.ImageRectSize
									})
								end
							end
						end

						if v10 and nullable then
							table.insert(v4, {
								ItemId = nullable
							})
						end
					end
				end

				table.freeze(v4)
				setState9(v4)
			end)
			return function()
				task.cancel(thread)
			end
		end

		ref.current += 1
		setState11(false)
		setState9({})
	end, { state10 })
	return React.createElement(PlayerProfile, {
		IsOpen = state10,
		OnExit = function()
			assert(PlayerProfileLookup.IsInitialized, "bad PlayerProfileLookUp")
			PlayerProfileLookup:Open(false)
		end,
		SetIsOpen = setState10,
		IsLoading = state11,
		ClearNewBackground = clearNewBackground,
		PatchProfileData = patchProfileData,
		SelectedStatSlotId = state7,
		SetSelectedStatSlotId = setState7,
		Category = state2,
		SetCategory = setState2,
		StatSelectionVisible = state4,
		Stats = state8,
		SetStatSelectionVisible = setState4,
		SettingsVisible = state3,
		SetSettingsVisible = setState3,
		LoadedPlayer = state,
		SetLoadedPlayer = setLoadedPlayer,
		InventoryItems = state9,
		StatusSelectionVisible = state5,
		SetStatusSelectionVisible = setState5,
		BackgroundSelectionVisible = state6,
		SetBackgroundSelectionVisible = setState6
	})
end

task.spawn(function()
	local function process(text: string)
		local v = string.split(text, "/")

		if v[1] == "profile" and v[2] then
			local v2 = tonumber(v[2])

			if v2 == nil then
				local success, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, Players, v[2])

				if success and type(userIdFromNameAsync) == "number" then
					v2 = userIdFromNameAsync
				end
			end

			if v2 then
				bindableEvent:Fire(v2)
			end
		end
	end

	local TextChatService = game:GetService("TextChatService")
	TextChatService.SendingMessage:Connect(function(p)
		process(p.Text)
	end)
	game.Players.LocalPlayer.Chatted:Connect(process)
end)

while not Inventory:GetIfInitialized() do
	task.wait()
end

ReactRoblox.createRoot(screenGui:WaitForChild("ROOT")):render(React.createElement(rootComponent, {}))