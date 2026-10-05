local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local KeybindHints = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.KeybindHints)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local Skills_Provider = require(ReplicatedStorage.CAM.Client.Controllers.Skills_Provider)
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local manage_cd = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.manage_cd)
local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local Row = require(script.Row)
local BlockRegen = require(script.Parent.HudBottomRight.BlockRegen)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local Mounted = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.Mounted)
local CombatAvailable = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.CombatAvailable)
local Emotes = require(ReplicatedStorage.CAM.Emotes)
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
local curPower = ReplicatedStorage.CAM.Client.Controllers.Skills_Provider:WaitForChild("CurPower")
local localPlayer = Players.LocalPlayer
return function(maid, data)
	local v = {
		RowHeight = data.RowHeight or 18,
		TextXAlignment = data.TextXAlignment,
		SlideDirection = data.HorizontalAlignment == Enum.HorizontalAlignment.Left and -1 or 1
	}
	local settingsHudKeybindHelper = DataValue.new("Settings/Hud/KeybindHelper", true, "Account")
	local v2 = settingsHudKeybindHelper:Get() ~= false
	local value = maid:Value({})
	local v3 = {}
	local size = maid:Value(UDim2.fromOffset(0, 0))

	local function lineFor(p)
		local value3 = Platform_Handler.Platform.Value

		if data.OnlyOn[value3] ~= true then
			return nil
		end

		local pad = p.Text[value3]

		if pad == nil and Platform_Handler.IsGamepad() then
			pad = p.Text.Pad
		end

		return pad
	end

	local function cooling(p: string)
		local character = localPlayer.Character
		local SHC

		if character ~= nil then
			SHC = character:FindFirstChild("SHC")
		end

		if SHC == nil then
			return false
		end

		local success, result = pcall(manage_cd.filter_cd_name, localPlayer, p)

		if success then
			if result == nil then
				result = p
			end
		else
			result = p
		end

		return SHC:FindFirstChild(result) ~= nil
	end

	local combo_duration = Combat_presets.combo_duration or 1.5

	local function comboStarted()
		local child = ReplicatedStorage.Player_Service.Values:FindFirstChild(localPlayer.Name)
		local comboTrackerClient

		if child ~= nil then
			comboTrackerClient = child:FindFirstChild("ComboTrackerClient")
		end

		if comboTrackerClient == nil then
			return false
		end

		local time = comboTrackerClient:FindFirstChild("Time")
		local v4 = time == nil and 0 or time.Value
		return comboTrackerClient.Value > 1 and os.clock() - v4 <= combo_duration
	end

	local v4 = false

	local function met(hint)
		local when = hint.When

		if when == nil then
			return true
		end

		if when.NotOnCooldown ~= nil then
			local notOnCooldown = when.NotOnCooldown
			local character = localPlayer.Character
			local SHC

			if character ~= nil then
				SHC = character:FindFirstChild("SHC")
			end

			local v5

			if SHC == nil then
				v5 = false
			else
				local success, result = pcall(manage_cd.filter_cd_name, localPlayer, notOnCooldown)

				if success then
					if result == nil then
						result = notOnCooldown
					end
				else
					result = notOnCooldown
				end

				v5 = SHC:FindFirstChild(result) ~= nil
			end

			if v5 then
				return false
			end
		end

		if when.ToolEquipped == true and Character_info_provider.Get_equipped_tool(localPlayer) == nil or when.NotWhileDown ~= nil and InputHandler.IsDown(when.NotWhileDown) then
			return false
		end

		if when.ComboStarted ~= nil and comboStarted() ~= when.ComboStarted or when.CombatAvailable ~= nil and CombatAvailable.Is() ~= when.CombatAvailable then
			return false
		end

		if when.Mounted == nil or Mounted.Is() == when.Mounted then
			return when.EmotesOwned == nil or v4 == when.EmotesOwned
		end

		return false
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function put(hint, flag: boolean)
		if v3[hint.Name] == flag then
			return
		end

		v3[hint.Name] = flag

		if flag then
			value:Add(hint.Name, hint)
		else
			value:Remove(hint.Name)
		end
	end

	local function refresh()
		local v5 = {}
		local hintsByGroup = {}

		for _, hint in KeybindHints.Hints do
			local v6 = v2

			if v6 then
				v6 = false
				local value3 = Platform_Handler.Platform.Value
				local pad

				if data.OnlyOn[value3] == true then
					pad = hint.Text[value3]

					if pad == nil and Platform_Handler.IsGamepad() then
						pad = hint.Text.Pad
					end
				end

				if pad ~= nil then
					v6 = met(hint)
				end
			end

			v5[hint] = v6
			local group = hint.Group

			if not (v6 and group ~= nil) then
				continue
			end

			local v7 = hintsByGroup[group]

			if v7 == nil or (hint.Priority or 0) > (v7.Priority or 0) then
				hintsByGroup[group] = hint
			end
		end

		for _, hint in KeybindHints.Hints do
			local v6 = v5[hint]

			if v6 and hint.Group ~= nil and hintsByGroup[hint.Group] ~= hint then
				v6 = false
			end

			put(hint, v6) -- equivalent call inferred; original call site unknown
		end
	end

	local function replatform()
		for _, hint in KeybindHints.Hints do
			put(hint, false) -- equivalent call inferred; original call site unknown
		end

		refresh()
	end

	maid:Connect(Platform_Handler.Platform.Changed.Event, replatform)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function askEmotes()
		task.spawn(function()
			local v5 = Emotes.Owned(localPlayer) == true

			if not maid.IsActive or v5 == v4 then
				return
			end

			v4 = v5
			refresh()
		end)
	end

	maid:Connect(MarketplaceService.PromptGamePassPurchaseFinished, function(p, _: number, flag: boolean)
		if p == localPlayer and flag == true then
			askEmotes() -- equivalent call inferred; original call site unknown
		end
	end)
	task.spawn(function()
		local v5 = Emotes.Owned(localPlayer) == true

		if not maid.IsActive or v5 == v4 then
			return
		end

		v4 = v5
		refresh()
	end)
	maid:Add(InputHandler.Rebound:Connect(replatform), true)
	maid:Add(settingsHudKeybindHelper.Changed:Connect(function(p)
		v2 = p ~= false
		refresh()
	end))
	maid:Add(settingsHudKeybindHelper)
	maid:Add(Skills_Provider.Keys_Changed:Connect(refresh))

	local function bindEquipped(instance)
		local equipped = instance:FindFirstChild("Equipped")

		if equipped == nil then
			maid:Connect(instance.ChildAdded, function(p)
				if p.Name ~= "Equipped" then
					return
				end

				maid:Connect(p.Changed, refresh)
				refresh()
			end)
			return
		end

		maid:Connect(equipped.Changed, refresh)
		refresh()
	end

	local items_Config = localPlayer:FindFirstChild("Items_Config")

	if items_Config == nil then
		maid:Connect(localPlayer.ChildAdded, function(p)
			if p.Name == "Items_Config" then
				bindEquipped(p)
			end
		end)
	else
		bindEquipped(items_Config)
	end

	local connections = {}

	local function bindCharacter(character)
		for _, connection in connections do
			maid:Remove(connection)
			connection:Disconnect()
		end

		table.clear(connections)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function bindSHC(instance)
			table.insert(connections, maid:Connect(instance.ChildAdded, refresh))
			table.insert(connections, maid:Connect(instance.ChildRemoved, refresh))
			refresh()
		end

		table.insert(connections, maid:Connect(character:GetAttributeChangedSignal("OnHorse"), refresh))
		local SHC = character:FindFirstChild("SHC")

		if SHC == nil then
			table.insert(connections, maid:Connect(character.ChildAdded, function(instance)
				if instance.Name == "SHC" then
					bindSHC(instance) -- equivalent call inferred; original call site unknown
				end
			end))
		else
			bindSHC(SHC) -- equivalent call inferred; original call site unknown
		end

		refresh()
	end

	if localPlayer.Character ~= nil then
		bindCharacter(localPlayer.Character)
	end

	maid:Connect(localPlayer.CharacterAdded, bindCharacter)
	maid:Connect(curPower.Changed, refresh)
	task.spawn(function()
		local child = ReplicatedStorage.Player_Service.Values:WaitForChild(localPlayer.Name, 60)

		if child == nil or not maid.IsActive then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function bindTracker(p)
			maid:Connect(p.Changed, function()
				refresh()
				maid:Delay(combo_duration + 0.1, refresh)
			end)
		end

		local comboTrackerClient = child:FindFirstChild("ComboTrackerClient")

		if comboTrackerClient ~= nil then
			bindTracker(comboTrackerClient) -- equivalent call inferred; original call site unknown
		end

		maid:Connect(child.ChildAdded, function(p)
			if p.Name == "ComboTrackerClient" then
				bindTracker(p) -- equivalent call inferred; original call site unknown
			end
		end)
	end)

	for _, hint in KeybindHints.Hints do
		local notWhileDown

		if hint.When ~= nil then
			notWhileDown = hint.When.NotWhileDown
		end

		if notWhileDown ~= nil then
			maid:Add(InputHandler.ListenTo(notWhileDown, function()
				refresh()
			end), true)
		end
	end

	refresh()
	return maid:Create("Frame")({
		Name = "KeybindHelper",
		LayoutOrder = data.LayoutOrder or 0,
		Size = size,
		BackgroundTransparency = 1,
		maid:Create("UIListLayout")({
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = data.HorizontalAlignment or Enum.HorizontalAlignment.Right,
			VerticalAlignment = data.VerticalAlignment or Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 2),
			AbsoluteContentSizeOnChangedInit = function(_, point: Vector2)
				local v6

				if data.FillWidth then
					v6 = UDim2.new(1, 0, 0, point.Y)
				else
					v6 = UDim2.fromOffset(point.X, point.Y)
				end

				size:Set(v6)
			end
		}),
		BlockRegen(maid, data.OnlyOn),
		maid:AdvancedIterate(value, function(_, p, p2)
			local value3 = Platform_Handler.Platform.Value
			local pad

			if data.OnlyOn[value3] == true then
				pad = p.Text[value3]

				if pad == nil and Platform_Handler.IsGamepad() then
					pad = p.Text.Pad
				end
			end

			if pad == nil then
				return nil
			end

			return Row(p2, pad, v)
		end)
	})
end