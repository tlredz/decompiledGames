local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local faye = require(ReplicatedStorage.Packages.faye)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local HexagoneLeft = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.HexagoneLeft)
local HexagoneRight = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.HexagoneRight)
local CommandBar = require(ReplicatedStorage.CAM.Client.Components.Misc.CommandBar)
local MenuConfig = require(script.Parent.Menu.MenuConfig)
local EmotesConfig = require(script.Parent.Emotes.EmotesConfig)
local Emotes = require(ReplicatedStorage.CAM.Emotes)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local Run_Handler = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.Run_Handler)
local Onboarding = require(ReplicatedStorage.CAM.Client.Modules.Onboarding)
local visibility = ReplicatedStorage.CAM.Client.Components.Layout.Visibility
local HUD = visibility.HUD
local v = visibility:FindFirstChild("Controls")

if v == nil then
	v = Instance.new("BoolValue")
	v.Name = "Controls"
	v.Value = true
	v.Parent = visibility
end

local v2 = gameSettings.KeybindTextSize.Y.Offset * 1.5
local info = faye.Info(0.2)
local color = Color3.new(0.156863, 0.156863, 0.156863)
local color2 = Color3.new()
local color3 = Color3.new(1, 1, 1)
local color4 = Color3.new(1, 1, 1)
local color5 = Color3.new(1, 1, 1)
local color6 = Color3.new()

local function Row(maid, horizontalAlignment)
	return maid:Create("UIListLayout")({
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = horizontalAlignment,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.Name,
		Padding = UDim.new(0, 0)
	})
end

local function KeyLabel(maid, name: string, p2: number, p3)
	return Utility.AddTag(maid:Create("Frame")({
		Name = name,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(p2 > 0 and 1 or 0, p2 * (4 + v2 / 2), 0.5, 0),
		Size = UDim2.new(0, gameSettings.KeybindTextSize.X.Offset, 0, v2),
		BackgroundTransparency = gameSettings.KeybindTextTransparency,
		Visible = p3 == nil or p3
	}), "UIkey")
end

return function(parent)
	local maid = faye.new()
	local initiateDestination = MenuConfig.InitiateDestination()
	local position = maid:Value(UDim2.new())
	local size = maid:Value(UDim2.new())

	local function measure()
		local guiInset = GuiService:GetGuiInset()
		local topbarInset = GuiService.TopbarInset
		local v3 = not (guiInset.Y > 0) and 36 or guiInset.Y
		local v4 = not (guiInset.Y > 0) and 0 or guiInset.Y
		position:Set(UDim2.new(0, topbarInset.Min.X, 0, -v4))
		size:Set(UDim2.new(1, -topbarInset.Min.X, 0, v3))
	end

	measure()
	maid:Connect(GuiService:GetPropertyChangedSignal("TopbarInset"), measure)
	maid:Connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), measure)
	local visible = maid:Value(HUD.Value == true)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refreshShown()
		if Platform_Handler.Platform.Value == "Mobile" then
			visible:Set(v.Value == true or initiateDestination.Value ~= "")
		else
			visible:Set(HUD.Value == true)
		end
	end

	maid:Connect(HUD.Changed, refreshShown)
	maid:Connect(v.Changed, refreshShown)
	maid:Connect(initiateDestination.Changed, refreshShown)
	maid:Connect(Platform_Handler.Platform.Changed.Event, refreshShown)
	refreshShown() -- equivalent call inferred; original call site unknown
	local v3 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function menuGuide()
		local set = Onboarding.Set
		local v5

		if visible:Get() and initiateDestination.Value == "" then
			v5 = v3
		end

		set("MenuOpener", v5)
	end

	local function menuSteps()
		local value4 = initiateDestination.Value
		local done = Onboarding.Done()

		if value4 == "Inventory" and done >= 3 and done < 5 then
			Onboarding.Complete(5)
		elseif value4 ~= "" and done == 3 then
			Onboarding.Complete(4)
		elseif value4 == "" and done == 5 then
			Onboarding.Complete(6)
		end
	end

	maid:Connect(initiateDestination.Changed, function()
		menuSteps()
		menuGuide() -- equivalent call inferred; original call site unknown
	end)
	maid:Connect(visible.Changed, menuGuide)
	maid:Add(function()
		Onboarding.Set("MenuOpener", nil)
	end)

	local function menuClosed(callback)
		return callback(initiateDestination) == ""
	end

	local value4 = maid:Value(Platform_Handler.Platform.Value == "Mobile")
	maid:Connect(Platform_Handler.Platform.Changed.Event, function()
		value4:Set(Platform_Handler.Platform.Value == "Mobile")
	end)
	local miscPartyHud = DataValue.new("Misc/PartyHud", true)
	local value5 = maid:Value(miscPartyHud:Get() ~= false)
	maid:Add(miscPartyHud.Changed:Connect(function(p2)
		value5:Set(p2 ~= false)
	end))
	maid:Add(miscPartyHud)

	local function toggleParty()
		SignalEvent.ToServer("PartyHud", not value5:Compare(true))
	end

	local bgColor = maid:Do(function(callback)
		local v6

		if callback(value5) then
			v6 = color4
		else
			v6 = color
		end

		return maid:Animation(v6, info)
	end)
	local fgColor = maid:Do(function(callback)
		local v7

		if callback(value5) then
			v7 = color5
		else
			v7 = color2
		end

		return maid:Animation(v7, info)
	end)
	local imageColor = maid:Do(function(callback)
		local v8

		if callback(value5) then
			v8 = color6
		else
			v8 = color3
		end

		return maid:Animation(v8, info)
	end)
	local miscQuestHud = DataValue.new("Misc/QuestHud", true)
	local value6 = maid:Value(miscQuestHud:Get() ~= false)
	maid:Add(miscQuestHud.Changed:Connect(function(p2)
		value6:Set(p2 ~= false)
	end))
	maid:Add(miscQuestHud)

	local function toggleQuests()
		SignalEvent.ToServer("QuestHud", not value6:Compare(true))
	end

	local bgColor2 = maid:Do(function(callback)
		local v9

		if callback(value6) then
			v9 = color4
		else
			v9 = color
		end

		return maid:Animation(v9, info)
	end)
	local fgColor2 = maid:Do(function(callback)
		local v10

		if callback(value6) then
			v10 = color5
		else
			v10 = color2
		end

		return maid:Animation(v10, info)
	end)
	local imageColor2 = maid:Do(function(callback)
		local v11

		if callback(value6) then
			v11 = color6
		else
			v11 = color3
		end

		return maid:Animation(v11, info)
	end)
	local image = maid:Do(function(callback)
		if callback(value6) then
			return BunchaIcons.QuestOn
		end

		return BunchaIcons.QuestOff
	end)
	local value7 = maid:Value(false)
	maid:Spawn(function()
		local data = Utility.GetData(Players.LocalPlayer, true)
		local quests

		if data ~= nil then
			quests = data:WaitForChild("Quests", 60)
		end

		local holder

		if quests == nil then
			holder = nil
		else
			holder = quests:WaitForChild("Holder", 60)
		end

		if holder == nil or not maid.IsActive then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refresh()
			value7:Set(#holder:GetChildren() > 0)
		end

		maid:Connect(holder.ChildAdded, refresh)
		maid:Connect(holder.ChildRemoved, refresh)
		refresh() -- equivalent call inferred; original call site unknown
	end)
	local value8 = maid:Value(Run_Handler.Shift_lock == 1)

	local function toggleShiftLock()
		Run_Handler.SetShiftLock(value8:Compare(true) and 0 or 1)
	end

	maid:Connect(Run_Handler.ShiftLockChanged.Event, function(p2)
		value8:Set(p2 == 1)
	end)
	local value9 = maid:Value(Platform_Handler.Platform.Value == "Mobile")
	maid:Connect(Platform_Handler.Platform.Changed.Event, function()
		value9:Set(Platform_Handler.Platform.Value == "Mobile")
	end)
	local bgColor3 = maid:Do(function(callback)
		local v13

		if callback(value8) then
			v13 = color4
		else
			v13 = color
		end

		return maid:Animation(v13, info)
	end)
	local fgColor3 = maid:Do(function(callback)
		local v14

		if callback(value8) then
			v14 = color5
		else
			v14 = color2
		end

		return maid:Animation(v14, info)
	end)
	local imageColor3 = maid:Do(function(callback)
		local v15

		if callback(value8) then
			v15 = color6
		else
			v15 = color3
		end

		return maid:Animation(v15, info)
	end)
	local image2 = maid:Do(function(callback)
		if callback(value8) then
			return BunchaIcons.ShiftLockOn
		end

		return BunchaIcons.ShiftLockOff
	end)
	local instancePropertySync = maid:InstancePropertySync(EmotesConfig.InitiateState(), "Value")
	local image3 = maid:Do(function(callback)
		if callback(instancePropertySync) then
			return BunchaIcons.EmotesOpen
		end

		return BunchaIcons.EmotesClosed
	end)
	local value10 = maid:Value(false)

	local function refreshOwned()
		value10:Set(Emotes.Owned(Players.LocalPlayer))
	end

	maid:Spawn(refreshOwned)
	maid:Connect(MarketplaceService.PromptGamePassPurchaseFinished, function(p2, _, flag: boolean)
		if p2 ~= Players.LocalPlayer or not flag then
			return
		end

		task.spawn(refreshOwned)
	end)
	maid:Create("Frame")({
		Parent = parent,
		Name = "TopBar",
		Position = position,
		Size = size,
		Visible = visible,
		ZIndex = 110,
		BackgroundTransparency = 1,
		maid:Create("Frame")({
			Name = "Left",
			Size = UDim2.fromScale(0.5, 1),
			BackgroundTransparency = 1,
			ZIndex = 2,
			Row(maid, Enum.HorizontalAlignment.Left),
			maid:State(function(callback, maid2)
				local v16 = callback(initiateDestination) ~= ""

				if v16 and callback(value9) ~= true then
					return nil
				end

				maid2:Add(function()
					v3 = nil
					menuGuide() -- equivalent call inferred; original call site unknown
				end)
				local v17 = maid2:Create("Frame")
				local v18 = {
					Name = "0MenuButton",
					After = function(p2)
						v3 = p2
						menuGuide() -- equivalent call inferred; original call site unknown
					end,
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1
				}
				local v19 = maid2:Create("UIAspectRatioConstraint")({})
				local image4

				if v16 then
					image4 = BunchaIcons.MenuClose
				else
					image4 = BunchaIcons.MenuIcon
				end

				do local _values = table.pack(v19, HexagoneLeft(maid2, {
	Image = image4,
	Clicked = MenuConfig.Toggle
}), KeyLabel(maid2, "Menu", 1)); for _k = 1, _values.n do v18[_k] = _values[_k] end end
				return v17(v18)
			end),
			maid:Create("Frame")({
				Name = "1zCommandsGap",
				Size = maid:Do(function(callback)
					if callback(value9) then
						return (UDim2.new())
					end

					return (UDim2.fromScale(1, 1))
				end),
				Visible = maid:Do(menuClosed),
				BackgroundTransparency = 1,
				Instance.new("UIAspectRatioConstraint")
			}),
			CommandBar(maid)
		}),
		maid:Create("Frame")({
			Name = "Centre",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(0.5, 1),
			Visible = maid:Do(menuClosed),
			BackgroundTransparency = 1,
			Row(maid, Enum.HorizontalAlignment.Center),
			maid:State(function(callback, object)
				if callback(value9) == true then
					return object:Create("Frame")({
						Name = "0MapButton",
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						object:Create("UIAspectRatioConstraint")({}),
						HexagoneLeft(object, {
							Image = BunchaIcons.MapIcon,
							Clicked = function()
								InputHandler.VirtualPress("Map")
								InputHandler.VirtualRelease("Map")
							end
						})
					})
				end

				return nil
			end),
			maid:State(function(callback, object)
				if callback(value9) == true and callback(value10) == true then
					return object:Create("Frame")({
						Name = "1EmotesButton",
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						object:Create("UIAspectRatioConstraint")({}),
						HexagoneLeft(object, {
							Image = image3,
							Clicked = function()
								InputHandler.VirtualPress("Emotes")
								InputHandler.VirtualRelease("Emotes")
							end
						})
					})
				end

				return nil
			end)
		}),
		maid:Create("Frame")({
			Name = "Right",
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromScale(0.5, 1),
			Visible = maid:Do(menuClosed),
			BackgroundTransparency = 1,
			Row(maid, Enum.HorizontalAlignment.Right),
			maid:Create("Frame")({
				Name = "0PartyButton",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				maid:Create("UIAspectRatioConstraint")({}),
				HexagoneRight(maid, {
					Image = maid:Do(function(callback)
						if callback(value5) then
							return BunchaIcons.PartyOn
						end

						return BunchaIcons.PartyOff
					end),
					BgColor = bgColor,
					FgColor = fgColor,
					ImageColor = imageColor,
					Clicked = toggleParty
				})
			}),
			maid:State(function(callback, object)
				if callback(value7) == true then
					return object:Create("Frame")({
						Name = "1QuestButton",
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						object:Create("UIAspectRatioConstraint")({}),
						HexagoneRight(object, {
							Image = image,
							BgColor = bgColor2,
							FgColor = fgColor2,
							ImageColor = imageColor2,
							Clicked = toggleQuests
						})
					})
				end

				return nil
			end),
			maid:State(function(callback, object)
				if callback(value9) == true then
					return object:Create("Frame")({
						Name = "2ShiftLockButton",
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						object:Create("UIAspectRatioConstraint")({}),
						HexagoneRight(object, {
							Image = image2,
							BgColor = bgColor3,
							FgColor = fgColor3,
							ImageColor = imageColor3,
							Clicked = toggleShiftLock
						})
					})
				end

				return nil
			end)
		})
	})
	return function()
		maid:Destroy()
	end
end