local React = require(game.ReplicatedStorage.Packages.React)
local OutlinedMaterialIconsHD = require(game.ReplicatedStorage.Packages.OutlinedMaterialIconsHD)
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
local Util = require(game.ReplicatedStorage.React.Components.Inventory.Main.BuildMenu.Util)
local MiscButton = require(script.MiscButton)
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
local useRace = require(game.ReplicatedStorage.React.Hooks.Player.useRace)
local useAura = require(game.ReplicatedStorage.React.Hooks.Player.useAura)
local useAirJump = require(game.ReplicatedStorage.React.Hooks.Player.useAirJump)
local useFlashStep = require(game.ReplicatedStorage.React.Hooks.Player.useFlashStep)
local useInstinct = require(game.ReplicatedStorage.React.Hooks.Player.useInstinct)
local useRarityData = require(game.ReplicatedStorage.React.Hooks.Item.useRarityData)
local useSelection = require(game.ReplicatedStorage.React.Hooks.Item.useSelection)
local useTemporaryDescription = require(game.ReplicatedStorage.React.Hooks.Inventory.useTemporaryDescription)
local createElement = React.createElement
return function(_)
	local broken_image = OutlinedMaterialIconsHD.broken_image
	local badgeLock = Spritesheets.MAP["Badge Lock"] or OutlinedMaterialIconsHD.lock
	local _, _, v = useSelection()
	local _, v2 = useTemporaryDescription()
	local v3 = useRace()
	local v5

	if v3 then
		v5 = v3.ItemId or nil
	end

	local v6 = useMatch(v5)
	local v7 = useInstinct()
	local v8 = useMatch(v7.ItemId)
	local v9 = useAirJump()
	local v10 = useMatch(v9.ItemId)
	local v11 = useFlashStep()
	local v13

	if v11 then
		v13 = v11.ItemId or nil
	end

	local v14 = useMatch(v13)
	local v15 = useAura()
	local v17

	if v15 then
		v17 = v15.SkinItemId or nil
	end

	local v18 = useMatch(v17)
	local v20

	if v15 then
		v20 = v15.SkinItemId or nil
	end

	local v21 = useRarityData(v20)
	local color

	if v21 then
		color = v21.Color
	else
		color = Color3.new()
	end

	local v24 = {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.989999, 0),
		Size = UDim2.fromScale(0.2, 0.95),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		ZIndex = 2
	}
	local v25 = {
		UIListLayout = createElement("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Right
		}),
		Race = 0,
		AuraInfo = 0,
		Instinct = 0,
		AirJump = 0,
		FlashStep = 0
	}
	local icon

	if v6 then
		icon = v6.Display.Sprite or broken_image
	else
		icon = badgeLock
	end

	v25.Race = createElement(MiscButton, {
		IsUnlocked = true,
		Icon = icon,
		Text = not v3 and "" or `{v3.Type} V{v3.Level}`,
		BackgroundColor3 = Color3.fromHex("#3F6E2C"),
		BorderColor3 = Color3.fromHex("#D8B74D"),
		CropPadding = UDim.new(0.15, 0),
		Size = UDim2.new(0.2, -5, 0.2, -5),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		LayoutOrder = 1,
		OnClick = v3 and function()
			v(v3.ItemId, nil)
		end or nil
	})
	local v32 = {
		IsUnlocked = v15.Level ~= nil,
		Icon = 0,
		Text = 0,
		Level = 0,
		BackgroundColor3 = 0,
		BorderColor3 = 0,
		Size = 0,
		SizeConstraint = 0,
		LayoutOrder = 2,
		OnClick = 0
	}
	local icon2

	if v18 and v15.Level then
		icon2 = v18.Display.Sprite or broken_image
	else
		icon2 = badgeLock
	end

	v32.Icon = icon2
	v32.Text = not v18 and "Aura" or v18.Display.Name or v18.Index.StorageKey
	local level

	if v15 and v15.Level and v15.Level > 1 then
		level = v15.Level
	end

	v32.Level = level
	v32.BackgroundColor3 = color
	v32.BorderColor3 = color:Lerp(Color3.new(1, 1, 1), 0.5)
	v32.Size = UDim2.new(0.2, -5, 0.2, -5)
	v32.SizeConstraint = Enum.SizeConstraint.RelativeYY

	function v32.OnClick()
		v(v15.SkinItemId)

		if v15.Level == nil then
			v2(
				Util.tutorialMessage(
					"You feel a strength waiting deep inside…",
					"Aura increases your defense and lets you hit through elemental protection.",
					"Visit the Ability Teacher on Snow or Magma Island in Sea 1 to learn the Aura technique"
				),
				v15.SkinItemId
			)
		elseif v15.Level < v15.MaxLevel then
			v2(
				Util.tutorialMessage(
					"A solid power wraps around your body…",
					"Aura boosts your defense and lets your attacks break through elemental barriers. Training by getting hits and grow stronger.",
					"Gaining max level will allow you to unlock Aura Colors"
				),
				v15.SkinItemId
			)
		else
			v2(
				Util.tutorialMessage(
					"Your Aura has reached its peak!",
					"You’re now ready to unlock cool Aura colors and customize your power.",
					"Visit Barista to craft new Aura colors"
				),
				v15.SkinItemId
			)
		end
	end

	v25.AuraInfo = createElement(MiscButton, v32)
	local v37 = {
		IsUnlocked = v7.Level ~= nil,
		Icon = 0,
		Text = 0,
		BackgroundColor3 = 0,
		BorderColor3 = 0,
		Size = 0,
		SizeConstraint = 0,
		LayoutOrder = 3,
		OnClick = 0
	}
	local icon3

	if v8 and v7.Level and v7.Level > 0 then
		icon3 = v8.Display.Sprite or broken_image
	else
		icon3 = badgeLock
	end

	v37.Icon = icon3
	v37.Text = not v8 and "Instinct" or v8.Display.Name or v8.Index.StorageKey
	v37.BackgroundColor3 = Color3.new(0, 0, 0)
	v37.BorderColor3 = Color3.fromHSV(0, 0, 0.3)
	v37.Size = UDim2.new(0.2, -5, 0.2, -5)
	v37.SizeConstraint = Enum.SizeConstraint.RelativeYY

	function v37.OnClick()
		v(v7.ItemId)

		if v7.Level == nil then
			v2(
				Util.tutorialMessage(
					"The world feels slower...",
					"Awaken your instincts and gain the power to dodge the next incoming attack.",
					"Did you know? After finishing the Saber Puzzle quest and reaching level 300, you can buy Instinct from the Ability Teacher on Upper Sky Island."
				),
				v7.ItemId
			)
		elseif v7.Level and v7.Level < v7.MaxLevel then
			v2(
				Util.tutorialMessage(
					"Train your Instinct to its limit. When you master it, something greater awaits.",
					nil,
					"You can track your dodging mastery by speaking to the Instinct Teacher in Sea 1. When your Instinct reaches max level, you will be able to awaken its second form in Sea 3."
				),
				v7.ItemId
			)
		elseif v7.Version >= v7.MaxVersion then
			v2(Util.tutorialMessage([[
Your Instinct has been trained to perfection.
But legends say that greater power may appear to those who wait.]]), v7.ItemId)
		elseif v7.Level >= v7.MaxLevel then
			v2(
				Util.tutorialMessage(
					"Your Instinct has reached its final stage. Ready for the next upgrade?",
					nil,
					"Complete the Citizen quest to earn the Musketeer Hat, then find the Hungry Man on Turtle Island who holds the key to Instinct’s second form."
				),
				v7.ItemId
			)
		end
	end

	v25.Instinct = createElement(MiscButton, v37)
	local v41 = {
		IsUnlocked = v9.JumpCount ~= nil,
		Icon = 0,
		Level = nil,
		Text = 0,
		BackgroundColor3 = 0,
		BorderColor3 = 0,
		Size = 0,
		SizeConstraint = 0,
		LayoutOrder = 4,
		OnClick = 0
	}
	local icon4

	if v10 and v9.JumpCount then
		icon4 = v10.Display.Sprite or broken_image
	else
		icon4 = badgeLock
	end

	v41.Icon = icon4
	v41.Text = not (v9.JumpCount and v9.JumpCount > 1) and "Air Jump" or `Air Jump +{v9.JumpCount}`
	v41.BackgroundColor3 = Color3.new(0, 0, 0)
	v41.BorderColor3 = Color3.fromHSV(0, 0, 0.3)
	v41.Size = UDim2.new(0.2, -5, 0.2, -5)
	v41.SizeConstraint = Enum.SizeConstraint.RelativeYY

	function v41.OnClick()
		v(v9.ItemId)

		if v9.JumpCount then
			v2(
				Util.tutorialMessage(
					"Reaching the heavens!",
					"Sky Jump is now active, enabling mutilple jumps in the middle of the air.",
					"Did you know that the Angel race and certain accessories allow players to perform better jumps?"
				),
				v9.ItemId
			)
		else
			v2(
				Util.tutorialMessage(
					"Don’t let gravity hold you back…",
					"Sky Jump's will allow you do multiple air jumps in the middle of the air.",
					"Visit the Ability Teacher on Snow or Magma Island in Sea 1 to learn the Sky Jump technique."
				),
				v9.ItemId
			)
		end
	end

	v25.AirJump = createElement(MiscButton, v41)
	local v45 = {
		IsUnlocked = v11.IsUnlocked == true,
		Icon = 0,
		Text = "Flash Step",
		BackgroundColor3 = 0,
		BorderColor3 = 0,
		Size = 0,
		SizeConstraint = 0,
		LayoutOrder = 5,
		OnClick = 0
	}

	if v11.IsUnlocked and v14 then
		badgeLock = v14.Display.Sprite or broken_image
	end

	v45.Icon = badgeLock
	v45.BackgroundColor3 = Color3.new(0, 0, 0)
	v45.BorderColor3 = Color3.fromHSV(0, 0, 0.3)
	v45.Size = UDim2.new(0.2, -5, 0.2, -5)
	v45.SizeConstraint = Enum.SizeConstraint.RelativeYY

	function v45.OnClick()
		v(v11.ItemId)

		if v11.IsUnlocked == false then
			v2(
				Util.tutorialMessage(
					"One step closer to victory",
					"Unlock Fast Step to teleport instantly within medium range.",
					"Visit the Ability Teacher on Snow or Magma Island in Sea 1 to learn the Flash Step technique."
				),
				v11.ItemId
			)
		else
			v2(
				Util.tutorialMessage(
					"Your steps feel weightless…",
					"Flash Step is now active, enabling instant teleportation to your targeted point.",
					"Did you know that some fruits and races have different flash step variations?"
				),
				v11.ItemId
			)
		end
	end

	v25.FlashStep = createElement(MiscButton, v45)
	return createElement("Frame", v24, v25)
end