local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StatEntry = require(script.StatEntry)
require(ReplicatedStorage.React.Components.Inventory.Types)
local PseudoEnum = require(ReplicatedStorage.PseudoEnum)
local Inventory = require(ReplicatedStorage.React.Components.Inventory)
local Config = require(ReplicatedStorage.React.Contexts.Inventory.Config)
local ItemSelection = require(ReplicatedStorage.React.Contexts.ItemSelection)
local AccessoriesShared = require(ReplicatedStorage.AccessoriesShared)
local RarityUtil = require(ReplicatedStorage.Modules.Asset.RarityUtil)
local React = require(ReplicatedStorage.Packages.React)
require(script.Types)
local useDynamicAccessories = require(ReplicatedStorage.React.Hooks.Player.useDynamicAccessories)
local ItemId = require(ReplicatedStorage.Economy.ItemId)
local GlobalUtil = require(ReplicatedStorage.GlobalUtil)
local ItemConfig = require(ReplicatedStorage.ItemConfig)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local FastTile = require(ReplicatedStorage.React.Components.Inventory.Main.TileGrid.FastTile)
local useAttribute = require(ReplicatedStorage.React.Hooks.Instance.useAttribute)
local FormatUtil = require(ReplicatedStorage.React.FormatUtil)
local AssetItemData = require(ReplicatedStorage.Util.AssetItemData)
local EasingStyles = require(ReplicatedStorage.Util.EasingStyles)
local Notification

if GlobalUtil.FFlags.IsUnitTest then
	Notification = nil
else
	Notification = require(game.ReplicatedStorage.Notification)
end

require(game.ReplicatedStorage.Spritesheets)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local selectItem = PseudoEnum.InventoryAction.SelectItem
local v = {
	Title = "Item Selection",
	Actions = { selectItem },
	FavoritingEnabled = false,
	NewCountEnabled = false,
	Layout = {
		Wardrobe = {
			Brackets = { PseudoEnum.InventoryItemBracket.Trinkets },
			SortingTypes = { PseudoEnum.InventorySortType.Rarity }
		}
	}
}
TableUtil.deepFreeze(v)
local renderSteppedConnection = nil

local function performMergeCutscene(name: string, grade: number, modifiers)
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	local currentCamera = workspace.CurrentCamera
	local clone = ReplicatedStorage.MergeSceneRig:Clone()
	clone.Parent = currentCamera
	clone.Camera.Transparency = 1
	local sprite = {
		Image = "",
		ImageRectOffset = Vector2.zero,
		ImageRectSize = Vector2.zero
	}
	local sprite2 = {
		Image = "",
		ImageRectOffset = Vector2.zero,
		ImageRectSize = Vector2.zero
	}
	local rarity = "Common"
	local nullable = ItemId.getId(`{name} {FormatUtil.romanNumeral(grade)}`, "Accessory"):asNullable()

	if nullable then
		local v2 = ItemConfig.tryGet(nullable)

		if v2 and v2.Display.Sprite then
			sprite = v2.Display.Sprite
		end
	end

	local nullable2 = ItemId.getId(`{name} {FormatUtil.romanNumeral(grade + 1)}`, "Accessory"):asNullable()

	if nullable2 then
		local v2 = ItemConfig.tryGet(nullable2)

		if v2 then
			if v2.Display.Sprite then
				sprite2 = v2.Display.Sprite
			end

			rarity = v2.Quality.Rarity or "Common"
		end
	end

	for i = 1, 3 do
		local child = clone:FindFirstChild("Card" .. i)

		if not child then
			continue
		end

		child.SurfaceGui.ResultItem.GradeIndicator.TextLabel.Text = `Grade {FormatUtil.romanNumeral(grade)}`
		child.SurfaceGui.ResultItem.GradeIndicator.TextLabel.TextLabel.Text = `Grade {FormatUtil.romanNumeral(grade)}`
		child.SurfaceGui.ResultItem.ItemImage.Image = sprite.Image
		child.SurfaceGui.ResultItem.ItemImage.ImageRectOffset = sprite.ImageRectOffset
		child.SurfaceGui.ResultItem.ItemImage.ImageRectSize = sprite.ImageRectSize
	end

	local finalCard = clone:FindFirstChild("FinalCard")

	if finalCard then
		finalCard.SurfaceGui.ResultItem.GradeIndicator.TextLabel.Text = `Grade {FormatUtil.romanNumeral(grade + 1)}`
		finalCard.SurfaceGui.ResultItem.GradeIndicator.TextLabel.TextLabel.Text = `Grade {FormatUtil.romanNumeral(grade + 1)}`
		finalCard.SurfaceGui.ResultItem.ItemImage.Image = sprite2.Image
		finalCard.SurfaceGui.ResultItem.ItemImage.ImageRectOffset = sprite2.ImageRectOffset
		finalCard.SurfaceGui.ResultItem.ItemImage.ImageRectSize = sprite2.ImageRectSize
	end

	local v2 = RarityUtil.tryGetRarity(rarity)
	clone.Stats.SurfaceGui.VanityItemInfo.ItemName.Text = `{not (#modifiers > 0) and "" or table.concat(modifiers, " ") .. " "}{name} {FormatUtil.romanNumeral(grade + 1)}`
	clone.Stats.SurfaceGui.rarity.ItemName.Text = rarity
	local itemName = clone.Stats.SurfaceGui.rarity.ItemName
	local textColor

	if v2 then
		textColor = v2.Color
	else
		textColor = CONSTANTS.COLOR.PALETTE.WHITE
	end

	itemName.TextColor3 = textColor
	clone.Stats.SurfaceGui.rarity.ItemName.ItemName.Text = rarity

	-- equivalent calls inferred from this helper; original call sites unknown
	local function playSound(instance)
		local clone2 = instance:Clone()
		clone2.Parent = currentCamera
		clone2:Play()
		task.delay(10, clone2.Destroy, clone2)
	end

	local card1 = clone.Card1
	local card2 = clone.Card2
	local card3 = clone.Card3
	local finalCard2 = clone.FinalCard
	local cFrame = clone.Focus.CFrame
	local lastTime = tick()
	local v4 = false
	local v5 = false
	local emitters = {}
	local sizesByEmitter = {}
	local cFrame2 = clone.Stats.CFrame
	clone.Stats.CFrame *= CFrame.new(0, 10, 0)
	local cFrame3 = clone.Stats.CFrame
	playSound(clone.Sounds.WindUp) -- equivalent call inferred; original call site unknown
	local RunService = game:GetService("RunService")
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v6 = tick() - lastTime + 3
		local identity = CFrame.identity
		local v7, v8

		if v6 >= 4 then
			local v9 = EasingStyles.InCubic((v6 - 4) / 0.9)
			v7 = math.max(math.lerp(4, 0, v9), 0)
			v8 = math.lerp(2, 1.35, v9)
		else
			v8 = 2
			v7 = 4
		end

		if v4 == false then
			v4 = true

			for _, emitter in clone.VFX.StartUp:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true

				if string.find(emitter.Name, "swirly") == nil then
					emitter.TimeScale = 0.75
					table.insert(emitters, emitter)
				end

				sizesByEmitter[emitter] = emitter.Size
			end
		end

		local fieldOfView

		if v6 >= 3 and v6 <= 4.9 then
			local v10 = math.lerp(0, 1, EasingStyles.InQuint(math.min(v6 - 3, 1.9) / 1.9))
			identity = CFrame.new((math.random() - 0.5) * 0.4 * v10, (math.random() - 0.5) * 0.4 * v10, 0)
			fieldOfView = math.lerp(70, 45, v10)

			for k, v11 in sizesByEmitter do
				local numberSequenceKeypoints = {}

				for k2, keypoint in v11.Keypoints do
					numberSequenceKeypoints[k2] = NumberSequenceKeypoint.new(
						keypoint.Time,
						math.lerp(keypoint.Value, keypoint.Value * 0.1, v10),
						(math.lerp(keypoint.Envelope, keypoint.Envelope * 0.1, v10))
					)
				end

				k.Size = NumberSequence.new(numberSequenceKeypoints)
			end
		else
			fieldOfView = 70
		end

		local mouseLocation = UserInputService:GetMouseLocation()
		local viewportSize = currentCamera.ViewportSize
		local rotation = CFrame.new(
			createVector(0, 0, 0),
			createVector(-0, -0, -100) + Vector3.new(
				mouseLocation.X / viewportSize.X - 0.5,
				-(mouseLocation.Y / viewportSize.Y - 0.5),
				0
			) * 3
		).Rotation
		local identity2 = CFrame.identity

		if v6 > 4.9 then
			v7 = 1000
			fieldOfView = math.lerp(45, 70, EasingStyles.OutBack(math.min(v6 - 4.9, 2) / 2))
			local v10 = math.lerp(1, 0, EasingStyles.InQuint(math.min(v6 - 4.9, 0.5) / 0.5))
			identity = CFrame.new((math.random() - 0.5) * 0.1 * v10, (math.random() - 0.5) * 0.1 * v10, 0)
			identity2 = cFrame * CFrame.new(
				math.sin(v6 * 0.5) * 0.05,
				math.lerp(-0.5, 0, EasingStyles.OutBack(math.min(v6 - 4.9, 2) / 2)) + math.sin(v6) * 0.1,
				2.5
			) * CFrame.identity:Lerp(rotation:Inverse(), 10)

			if v5 == false then
				v5 = true

				for _, emitter in clone.VFX.StartUp:GetDescendants() do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter.Enabled = false
					emitter:Clear()
					emitter.Size = sizesByEmitter[emitter]
				end

				for _, emitter in clone.VFX.FinalEmit:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				for _, emitter in clone.Screen:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				playSound(clone.Sounds:FindFirstChild(rarity) or clone.Sounds.Common) -- equivalent call inferred; original call site unknown
			end

			if v6 > 5.5 then
				clone.Stats.CFrame = cFrame3:Lerp(cFrame2, EasingStyles.InQuart(math.min(v6 - 5.5, 0.5) / 0.5))

				if v6 > 6 then
					local v11 = math.lerp(1, 0, EasingStyles.InQuint(math.min(v6 - 6, 0.1) / 0.1))
					identity = CFrame.new((math.random() - 0.5) * 0.3 * v11, (math.random() - 0.5) * 0.3 * v11, 0)

					if v6 >= 6.75 then
						clone.Stats.SurfaceGui.rarity.ItemName.ItemName.UIGradient.Offset = Vector2.new((math.lerp(
							-0.45,
							0.45,
							EasingStyles.OutQuad(math.min(v6 - 6.75, 0.7) / 0.7)
						)))

						if v6 >= 10 then
							if renderSteppedConnection then
								renderSteppedConnection:Disconnect()
								renderSteppedConnection = nil
							end

							clone:Destroy()
							pcall(function()
								game.Players.LocalPlayer.PlayerGui.Main.Enabled = true
								local accessoryMerge = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("AccessoryMerge")

								if accessoryMerge then
									accessoryMerge.Enabled = true
								end
							end)
						end
					end
				end
			end
		end

		local v10 = math.lerp(1, 2, v6 / v8)

		for _, v11 in emitters do
			v11.TimeScale = v10 * 0.4 * 0.75
		end

		local v11 = v6 * v10
		local v12 = v11 + 2.0943951023931953
		local v13 = v11 + 4.1887902047863905
		card1.CFrame = cFrame * CFrame.new(math.sin(v11) * v7, math.cos(v11) * v7, 0)
		card2.CFrame = cFrame * CFrame.new(math.sin(v12) * v7, math.cos(v12) * v7, 0)
		card3.CFrame = cFrame * CFrame.new(math.sin(v13) * v7, math.cos(v13) * v7, 0)
		finalCard2.CFrame = identity2

		if clone.Parent then
			currentCamera.CFrame = clone.Camera.CFrame * identity * rotation
			currentCamera.FieldOfView = fieldOfView
		end
	end)
end

local createElement = React.createElement

function inventoryPopUp(props)
	local state, setState = React.useState(nil)
	return createElement(Config.Provider, {
		value = v
	}, {
		ItemSelectionContext = createElement(ItemSelection.Provider, {
			value = {
				Selection = state,
				SetSelection = function(itemId, networkedUID)
					if itemId == nil then
						setState(nil)
					else
						setState({
							ItemId = itemId,
							NetworkedUID = networkedUID
						})
					end
				end
			}
		}, {
			Inventory = createElement(Inventory, {
				IsOpen = props.SelectingItemForSlot ~= nil,
				OnAction = function(p)
					if p == selectItem then
						props.OnItemSelected(props.SelectingItemForSlot, state)
					end
				end,
				OnExit = function()
					props.SetSelectingItemForSlot(nil)
					props.OnItemSelected(props.SelectingItemForSlot, nil)
				end,
				OnExitComplete = function() end,
				Tiles = props.Items
			})
		})
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getStatValue(p: string, p2: number)
	local nullable = AssetItemData.fromLegacyName(p):asNullable()

	if nullable == nil then
		return nil
	end

	return AssetItemData.solve(nullable, p2):asNullable()
end

return function(data)
	local v2 = useDynamicAccessories()
	local reforgeCost = AccessoriesShared.GetReforgeCost()
	local v3 = useAttribute(Players.LocalPlayer, "SimulationData")
	local v4 = React.useMemo(function()
		local result = {}

		if v2 == nil then
			return result
		end

		for k, v5 in v2 do
			if v5.Type ~= "Trinket" then
				continue
			end

			local id = ItemId.getId(v5.Name .. " " .. FormatUtil.romanNumeral(v5.Grade), "Accessory")

			if id:isOk() then
				table.insert(result, {
					NetworkedUID = k,
					ItemId = id:unwrap()
				})
			else
				warn((`AccessoryMerge: Failed to get ItemId for accessory "{v5.Name}": {id:unwrapErr().Type}`))
			end
		end

		return result
	end, { v2 })
	local state, setState = React.useState(nil)
	local v5 = React.useMemo(function()
		if data.Item2 == nil or AccessoriesShared.GetTrinketData(data.Item2.Name) == nil then
			return state
		end

		setState(nil)

		if data.IsReforging then
			return {
				Name = data.Item2.Name,
				Rarity = AccessoriesShared.GetItemRarity(data.Item2.Name, data.Item2.Grade) or "Common",
				Grade = data.Item2.Grade,
				ShowNextGrade = false,
				Modifiers = data.Item2.Modifiers
			}
		end

		return {
			Name = data.Item2.Name,
			Rarity = AccessoriesShared.GetItemRarity(data.Item2.Name, data.Item2.Grade + 1) or "Common",
			Grade = data.Item2.Grade,
			ShowNextGrade = true,
			Modifiers = data.Item2.Modifiers
		}
	end, {
		data.Item1,
		data.Item2,
		data.Item3,
		state
	})
	local elements = {}
	local elements2 = {}
	local v6 = {}

	if v5 then
		local trinketData = AccessoriesShared.GetTrinketData(v5.Name)

		if trinketData then
			local stat = trinketData.Stats[v5.Grade + (v5.ShowNextGrade and 1 or 0)]
			local count = 0

			if stat then
				for k, new in stat do
					local statValue = getStatValue(AccessoriesShared.STAT_MAPPINGS[k], new) -- equivalent call inferred; original call site unknown
					v6[k] = {
						IsModifier = false,
						StatValue = statValue,
						Mystery = false,
						Index = count,
						New = new
					}
					count += 1
				end
			end

			local stat2 = trinketData.Stats[v5.Grade]

			if stat2 then
				for k, old in stat2 do
					local v8 = v6[k]

					if not (v8 and v8.New ~= old) then
						continue
					end

					v8.Old = old
					local statValue = getStatValue(AccessoriesShared.STAT_MAPPINGS[k], old) -- equivalent call inferred; original call site unknown
					v8.OldStatValue = statValue
				end
			end
		end

		local count = #v5.Modifiers

		if count > 0 then
			for k, modifier in v5.Modifiers do
				local modifierData = AccessoriesShared.GetModifierData(modifier)

				if not modifierData then
					continue
				end

				for k2, effect in modifierData.Effects do
					local sea3 = effect.Sea3
					local v7 = {
						IsModifier = true,
						Mystery = data.IsReforging,
						StatValue = 0,
						Index = 0,
						New = 0,
						ModifierName = 0
					}
					local statValue = getStatValue(AccessoriesShared.EFFECT_MAPPINGS[k2], sea3) -- equivalent call inferred; original call site unknown
					v7.StatValue = statValue
					v7.Index = k
					v7.New = sea3
					v7.ModifierName = modifier
					v6[k2] = v7
				end
			end
		end

		if v5.ShowNextGrade then
			if v5.Grade == 2 and count == 0 then
				v6["Bonus Modifier"] = {
					IsModifier = true,
					Mystery = true,
					Index = 5,
					New = 0
				}
			elseif v5.Grade == 3 and count == 1 then
				v6["Bonus Modifier"] = {
					IsModifier = true,
					Mystery = true,
					Index = 6,
					New = 0
				}
			end
		end
	end

	for k, v7 in v6 do
		if not (v7.StatValue ~= nil or v7.Mystery ~= false) then
			continue
		end

		local element = createElement(StatEntry, {
			Modifier = v7.IsModifier and {
				Name = v7.ModifierName or k,
				Rerolling = data.IsReforging
			} or nil,
			StatValue = v7.StatValue,
			OldStatValue = v7.OldStatValue,
			Mystery = v7.Mystery,
			Index = v7.Index
		})

		if v7.IsModifier then
			elements2[k] = element
		else
			elements[k] = element
		end
	end

	local items = React.useMemo(function()
		local result = {}

		if not v2 then
			return result
		end

		for _, v8 in v4 do
			if not ((not data.Item1 or v8.NetworkedUID ~= data.Item1.Id) and (not data.Item2 or v8.NetworkedUID ~= data.Item2.Id) and (not data.Item3 or v8.NetworkedUID ~= data.Item3.Id)) then
				continue
			end

			local v9 = v2[v8.NetworkedUID or "N/A"]

			if data.Item2 ~= nil then
				local v10 = v2[data.Item2.Id]

				if v9 == nil or v10 == nil or v9.Name ~= v10.Name or v9.Grade ~= v10.Grade then
					continue
				end
			end

			if data.IsReforging and v9.Grade < 3 or not (data.IsReforging ~= false or not (v9.Grade >= 4)) then
				continue
			end

			table.insert(result, v8)
		end

		return result
	end, {
		v4,
		data.Item1,
		data.Item2,
		data.Item3,
		data.IsReforging
	})
	local v8, v9 = React.useMemo(function()
		local sprite = {
			Image = "rbxassetid://92321938036133",
			ImageRectSize = Vector2.zero,
			ImageRectOffset = Vector2.zero
		}
		local sprite2 = {
			Image = "rbxassetid://92321938036133",
			ImageRectSize = Vector2.zero,
			ImageRectOffset = Vector2.zero
		}

		if v5 == nil then
			return sprite, sprite2
		end

		local nullable = ItemId.getId(`{v5.Name} {FormatUtil.romanNumeral(v5.Grade)}`, "Accessory"):asNullable()

		if nullable ~= nil then
			local v10 = ItemConfig.tryGet(nullable)

			if v10 and v10.Display.Sprite then
				sprite = v10.Display.Sprite
			end
		end

		local nullable2 = ItemId.getId(`{v5.Name} {FormatUtil.romanNumeral(v5.Grade + 1)}`, "Accessory"):asNullable()

		if nullable2 ~= nil then
			local v10 = ItemConfig.tryGet(nullable2)

			if v10 and v10.Display.Sprite then
				sprite2 = v10.Display.Sprite
			end
		end

		return sprite, sprite2
	end, { data.Item2 })
	local v10 = React.useMemo(function()
		local v11 = {}

		if data.Item1 ~= nil then
			v11[1] = ItemId.getId(data.Item1.Name .. " " .. FormatUtil.romanNumeral(data.Item1.Grade), "Accessory"):asNullable()
		end

		if data.Item2 ~= nil then
			v11[2] = ItemId.getId(data.Item2.Name .. " " .. FormatUtil.romanNumeral(data.Item2.Grade), "Accessory"):asNullable()
		end

		if data.Item3 ~= nil then
			v11[3] = ItemId.getId(data.Item3.Name .. " " .. FormatUtil.romanNumeral(data.Item3.Grade), "Accessory"):asNullable()
		end

		if v5 then
			v11[4] = ItemId.getId(
				v5.Name .. " " .. FormatUtil.romanNumeral(v5.Grade + (v5.ShowNextGrade and 1 or 0)),
				"Accessory"
			):asNullable()
		end

		return v11
	end, { data.Item1, data.Item2, data.Item3 })
	local modifiers = React.useMemo(function()
		if v5 ~= nil and data.IsReforging then
			return (table.create(#v5.Modifiers, "???"))
		end

		local v12

		if not (v5 == nil or not v5.Modifiers[1] and (not v5.ShowNextGrade or v5.Grade ~= 2)) then
			v12 = v5.Modifiers[1] or "???"
		end

		local v13

		if not (v5 == nil or not v5.Modifiers[2] and (not v5.ShowNextGrade or v5.Grade ~= 3)) then
			v13 = v5.Modifiers[2] or "???"
		end

		local v14 = {}

		if v12 then
			table.insert(v14, v12)
		end

		if v13 then
			table.insert(v14, v13)
		end

		return v14
	end, { v5 })
	local state2, setState2 = React.useState(nil)

	if not data.IsOpen then
		return nil
	end

	local fragment = React.Fragment
	local v14 = {
		inventoryFrame = createElement("Frame", {
			ZIndex = 10000,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Size = UDim2.new(1, 0, 1, 0)
		}, {
			inventory = createElement(inventoryPopUp, {
				SelectingItemForSlot = state2,
				SetSelectingItemForSlot = setState2,
				OnItemSelected = function(p: number, p2)
					print("Selected item for slot", p, p2)
					local v15

					if v2 and p2 and p2.NetworkedUID then
						v15 = v2[p2.NetworkedUID]
					end

					if p2 == nil or p2.NetworkedUID == nil or v15 == nil then
						data.SetItemInSlot(p, nil)

						if p == 2 then
							data.SetItemInSlot(1, nil)
							data.SetItemInSlot(2, nil)
							data.SetItemInSlot(3, nil)
						end
					else
						local grade = v15.Grade
						local clone = table.clone(v15.Modifiers)
						local v16 = {
							Name = v15.Name,
							Id = p2.NetworkedUID,
							Grade = grade,
							Modifiers = clone
						}
						local v17 = false

						for i = 1, 3 do
							local v18 = data[`Item{i}`]

							if not (v18 and v18.Id == p2.NetworkedUID) then
								continue
							end

							data.SetItemInSlot(i, nil)

							if i == 2 then
								v17 = true
							end
						end

						if v17 == false then
							data.SetItemInSlot(p, v16)
						else
							data.SetItemInSlot(1, nil)
							data.SetItemInSlot(2, nil)
							data.SetItemInSlot(3, nil)
						end

						setState2(nil)
					end
				end,
				Items = items
			})
		}),
		window = 0
	}
	local v17 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(21, 21, 21),
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		Position = UDim2.fromScale(0.499455, 0.499688),
		Size = UDim2.fromScale(0.9, 0.9),
		ZIndex = CONSTANTS.LAYER.RAISED
	}
	local children = {
		constraint = createElement("UISizeConstraint", {
			MaxSize = Vector2.new(700, 700)
		}),
		main = 0,
		uICorner = 0,
		uIStroke = 0,
		title = 0,
		uIAspectRatioConstraint = 0
	}
	local v20 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0, 0.11846),
		Size = UDim2.fromScale(1, 0.88154),
		ZIndex = CONSTANTS.LAYER.RAISED
	}
	local v24 = {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		LayoutOrder = 2,
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.fromScale(1, 0.14453)
	}
	local v25 = {
		uIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = CONSTANTS.SPACING.PADDING.SCALE.MD,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}),
		mergeButton = 0,
		uICorner = 0
	}
	local v28 = {
		BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
		BorderColor3 = CONSTANTS.COLOR.PRIMARY.BORDER,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
		FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
		Position = UDim2.fromScale(0.454775, 0.15),
		Size = UDim2.fromScale(data.IsReforging and 0.48 or 0.2107, 0.7),
		Text = "",
		TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		TextScaled = true,
		TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		[React.Event.MouseButton1Click] = function()
			if data.IsReforging == false then
				print("merging", data.Item1, data.Item2, data.Item3)

				if data.Item1 and data.Item2 and data.Item3 then
					local v29, v30 = ReplicatedStorage.Remotes.AccessoryInteract:InvokeServer(
						"a",
						data.Item1.Id,
						data.Item2.Id,
						data.Item3.Id
					)
					local grade = data.Item1.Grade

					if v29 then
						data.SetItemInSlot(1, nil)
						data.SetItemInSlot(2, nil)
						data.SetItemInSlot(3, nil)
						local rarity = AccessoriesShared.GetItemRarity(v30.Item.Name, v30.Item.Grade) or "Common"
						setState({
							Grade = v30.Item.Grade,
							Name = v30.Item.Name,
							Modifiers = v30.Item.Modifiers,
							Rarity = rarity,
							ShowNextGrade = false
						})
						pcall(function()
							game.Players.LocalPlayer.PlayerGui.Main.Enabled = false
							local accessoryMerge = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("AccessoryMerge")

							if accessoryMerge then
								accessoryMerge.Enabled = false
							end
						end)
						performMergeCutscene(v30.Item.Name, grade, v30.Item.Modifiers)
					end

					print(v29, v30)
				elseif Notification then
					Notification.new("<Color=Red>3 Trinkets required to fuse!<Color=/>"):Display()
				end
			else
				print("reforging", data.Item2)

				if data.Item2 then
					local v29, v30 = ReplicatedStorage.Remotes.AccessoryInteract:InvokeServer("c", data.Item2.Id)

					if v29 then
						data.SetItemInSlot(1, nil)
						data.SetItemInSlot(2, nil)
						data.SetItemInSlot(3, nil)
						local rarity = AccessoriesShared.GetItemRarity(v30.Name, v30.Grade) or "Common"
						setState({
							Grade = v30.Grade,
							Name = v30.Name,
							Modifiers = v30.Modifiers,
							Rarity = rarity,
							ShowNextGrade = false
						})
					end

					print(v29, v30)
				end
			end
		end
	}
	local v29 = {
		trans = createElement("Frame", {
			BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.HIGHLIGHT,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromOffset(2, 2),
			Size = UDim2.new(1, -4, 0.4, 0),
			ZIndex = CONSTANTS.LAYER.BASE
		}),
		textLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.TITLE,
			Position = data.IsReforging and UDim2.fromScale(0.58, 0.55) or UDim2.fromScale(0.5, 0.55),
			Size = data.IsReforging and UDim2.fromScale(0.814117, 0.737969) or UDim2.fromScale(0.95, 0.75),
			Text = data.IsReforging and `{AccessoriesShared.GetReforgeCost()} Simulation Data` or "Fuse",
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true,
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			uIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN,
				ZIndex = CONSTANTS.LAYER.BASE
			}),
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.5, 0.45),
				Size = UDim2.fromScale(1, 1),
				Text = data.IsReforging and `{AccessoriesShared.GetReforgeCost()} Simulation Data` or "Fuse",
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true
			}, {
				uIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN,
					ZIndex = CONSTANTS.LAYER.BASE
				})
			})
		}),
		imageLabel = 0
	}
	local imageLabel

	if data.IsReforging then
		imageLabel = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://109946525658150",
			Position = UDim2.fromScale(0.09, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.135686, 0.876338)
		})
	end

	v29.imageLabel = imageLabel
	v25.mergeButton = createElement("TextButton", v28, v29)
	v25.uICorner = createElement("UICorner", {
		CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
	})
	local v21 = {
		footer = createElement("Frame", v24, v25),
		content = 0
	}
	local v33 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0, 1.62911e-7),
		Size = UDim2.fromScale(1, 0.848782)
	}
	local v37 = {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		Position = UDim2.fromScale(0.620105, 0.5),
		Size = UDim2.fromScale(0.354783, 0.932113)
	}
	local v38 = {
		uIStroke = createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		uICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0.02, 0)
		}),
		subHeader = createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(77, 77, 77),
			BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(-0.0043943, 0.264603),
			Size = UDim2.fromScale(1.00196, 0.0896749)
		}, {
			uIGradient = createElement("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.298879, 0.24375),
					NumberSequenceKeypoint.new(0.500623, 0.075),
					NumberSequenceKeypoint.new(0.699875, 0.2375),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),
			itemName = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.565),
				Size = UDim2.fromScale(0.9, 0.75),
				Text = v5 == nil and "" or `{v5.Name} {AccessoriesShared.GetGradeSuffix(v5.Grade + (v5.ShowNextGrade and 1 or 0))}` or "",
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true
			}, {
				uIStroke = createElement("UIStroke", {
					Thickness = 1.7
				}),
				textLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.DISPLAY,
					Position = UDim2.fromScale(0.5, 0.44),
					Size = UDim2.fromScale(1, 1),
					Text = v5 == nil and "" or `{v5.Name} {AccessoriesShared.GetGradeSuffix(v5.Grade + (v5.ShowNextGrade and 1 or 0))}` or "",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true
				}, {
					uIStroke = createElement("UIStroke", {
						Thickness = 1.7
					})
				})
			})
		}),
		rarity = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.BODY,
			Position = UDim2.fromScale(0.5, 0.365),
			RichText = true,
			Size = UDim2.fromScale(0.8, 0.0475),
			Text = v5 == nil and "" or v5.Rarity or "",
			TextColor3 = v5 ~= nil and RarityUtil.tryGetRarity(v5.Rarity).Color or CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextStrokeTransparency = CONSTANTS.ALPHA.MID,
			TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = CONSTANTS.LAYER.OVERLAY
		}),
		descriptionContent = createElement("Frame", {
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			BackgroundTransparency = 0.999,
			BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0, 0.43),
			Size = UDim2.fromScale(0.997569, 0.54507)
		}, {
			stats = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.fromScale(0.9, 0)
			}, {
				uIListLayout = createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = CONSTANTS.SPACING.PADDING.SCALE.SM,
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				uIGradient = createElement("UIGradient", {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0.298879, 0.24375),
						NumberSequenceKeypoint.new(0.500623, 0.075),
						NumberSequenceKeypoint.new(0.699875, 0.2375),
						NumberSequenceKeypoint.new(1, 1)
					})
				}),
				entries = createElement(React.Fragment, nil, elements)
			}),
			modifiers = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0.5, 0.179411),
				Size = UDim2.fromScale(0.9, 0.537506)
			}, {
				uIListLayout = createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0.04, 0),
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				uIGradient = createElement("UIGradient", {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0.298879, 0.24375),
						NumberSequenceKeypoint.new(0.500623, 0.075),
						NumberSequenceKeypoint.new(0.699875, 0.2375),
						NumberSequenceKeypoint.new(1, 1)
					})
				}),
				entries = createElement(React.Fragment, nil, elements2)
			}),
			uIListLayout = createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0.04, 0),
				SortOrder = Enum.SortOrder.LayoutOrder
			})
		}),
		itemDisplay = 0
	}
	local v41 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		ClipsDescendants = true,
		Position = UDim2.fromScale(2.15396e-7, 3.70741e-8),
		Size = UDim2.fromScale(0.997569, 0.266468)
	}
	local v44 = {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		LayoutOrder = -1,
		Position = UDim2.fromScale(0.5, 0.95),
		Size = UDim2.fromScale(0.902, 0.191786),
		ZIndex = CONSTANTS.LAYER.RAISED
	}
	local tag

	if not (v5 == nil or not v5.Modifiers[1] and (v5 == nil or not v5.ShowNextGrade or v5.Grade ~= 2)) then
		tag = createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BackgroundTransparency = v5.Modifiers[1] == nil and 0.5 or 0.2,
			Position = UDim2.fromScale(1, 0.5),
			Size = UDim2.fromScale(0, 1),
			ZIndex = CONSTANTS.LAYER.OVERLAY
		}, {
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.new(0, 1, 0.95, 0),
				Text = v5.Modifiers[1] or "???",
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true
			}),
			uICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.LG
			}),
			uIPadding = createElement("UIPadding", {
				PaddingLeft = CONSTANTS.SPACING.PADDING.OFFSET.SM,
				PaddingRight = CONSTANTS.SPACING.PADDING.OFFSET.SM
			})
		})
	end

	local tag2

	if not (v5 == nil or not v5.Modifiers[2] and (v5 == nil or not v5.ShowNextGrade or v5.Modifiers[1] == nil or v5.Grade ~= 3)) then
		tag2 = createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BackgroundTransparency = v5.Modifiers[2] == nil and 0.5 or 0.2,
			Position = UDim2.fromScale(1, 0.5),
			Size = UDim2.fromScale(0, 1),
			ZIndex = CONSTANTS.LAYER.OVERLAY
		}, {
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.new(0, 1, 0.95, 0),
				Text = v5.Modifiers[2] or "???",
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true
			}),
			uICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.LG
			}),
			uIPadding = createElement("UIPadding", {
				PaddingLeft = CONSTANTS.SPACING.PADDING.OFFSET.SM,
				PaddingRight = CONSTANTS.SPACING.PADDING.OFFSET.SM
			})
		})
	end

	local children2 = {
		tags = createElement("Frame", v44, {
			tag = tag,
			tag2 = tag2,
			uIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = CONSTANTS.SPACING.PADDING.SCALE.SM,
				SortOrder = Enum.SortOrder.LayoutOrder
			})
		}),
		itemImage = 0,
		itemType = 0,
		rarityFadeBackdrop = 0,
		iconRight = 0,
		iconLeft = 0,
		gradeLevel = 0
	}
	local itemImage

	if v5 ~= nil then
		itemImage = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = (v5.ShowNextGrade and v9 or v8).Image,
			ImageRectSize = (v5.ShowNextGrade and v9 or v8).ImageRectSize,
			ImageRectOffset = (v5.ShowNextGrade and v9 or v8).ImageRectOffset,
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.8, 0.8)
		})
	end

	children2.itemImage = itemImage
	local itemType

	if v5 ~= nil then
		itemType = createElement("TextLabel", {
			AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.BODY_ITALIC,
			Position = UDim2.fromScale(0.476, 0.25),
			Size = UDim2.fromScale(0.431594, 0.225),
			Text = "Trinket",
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextStrokeTransparency = CONSTANTS.ALPHA.MID,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = CONSTANTS.LAYER.OVERLAY
		})
	end

	children2.itemType = itemType
	local rarityFadeBackdrop

	if v5 ~= nil then
		rarityFadeBackdrop = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://123256103361128",
			ImageRectSize = Vector2.new(360, 220),
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromScale(1, 1),
			ZIndex = CONSTANTS.LAYER.BASE
		})
	end

	children2.rarityFadeBackdrop = rarityFadeBackdrop
	children2.iconRight = createElement("ImageLabel", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = "rbxassetid://127503254560275",
		ImageRectOffset = Vector2.new(400, 0),
		ImageRectSize = Vector2.new(100, 100),
		Position = UDim2.fromScale(0.966961, 0.0561631),
		Size = UDim2.fromOffset(21, 21),
		Visible = false
	})
	children2.iconLeft = createElement("ImageLabel", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = "rbxassetid://127503254560275",
		ImageRectOffset = Vector2.new(400, 0),
		ImageRectSize = Vector2.new(100, 100),
		Position = UDim2.fromScale(0.870366, 0.0561631),
		Size = UDim2.fromOffset(21, 21),
		Visible = false
	})
	children2.gradeLevel = createElement("TextLabel", {
		AnchorPoint = Vector2.new(1, 1),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.TITLE,
		Position = UDim2.fromScale(0.965, 0.25),
		Size = UDim2.fromScale(0.551874, 0.225),
		Text = not v5 and "" or `Grade {AccessoriesShared.GetGradeSuffix(v5.Grade)}{not v5.ShowNextGrade and "" or ` > Grade {AccessoriesShared.GetGradeSuffix(v5.Grade + 1)}`}` or "",
		TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextYAlignment = Enum.TextYAlignment.Top,
		ZIndex = CONSTANTS.LAYER.RAISED
	}, {
		uIStroke = createElement("UIStroke", {
			Thickness = 1.7
		})
	})
	v38.itemDisplay = createElement("Frame", v41, children2)
	local v34 = {
		itemInspect = createElement("Frame", v37, v38),
		machine = 0
	}
	local v53 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.038, 0.04),
		Size = UDim2.fromScale(0.542668, 0.919453)
	}
	local v56 = {
		Active = true,
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.INK_900,
		Position = UDim2.fromScale(0.31295, 0.592593),
		Selectable = true,
		Size = UDim2.fromScale(0.370504, 0.401559)
	}
	local v57 = {
		uICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.SM
		}),
		uIStroke = 0,
		outlineGlow = 0,
		gradeIndicator = 0,
		itemImage = 0,
		tile = 0
	}
	local uIStroke

	if v5 == nil then
		local color

		if v5 == nil then
			color = CONSTANTS.COLOR.PALETTE.BLACK
		else
			color = Color3.fromRGB(255, 238, 60)
		end

		uIStroke = createElement("UIStroke", {
			Color = color,
			Thickness = 2.5
		})
	end

	v57.uIStroke = uIStroke
	local outlineGlow

	if v5 == nil then
		local v62 = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://139486962053154",
			ImageColor3 = Color3.fromRGB(221, 188, 0),
			ImageTransparency = 0,
			Position = 0,
			ScaleType = 0,
			Size = 0,
			SliceCenter = 0,
			ZIndex = -999
		}
		v62.ImageTransparency = 0.4
		v62.Position = UDim2.fromScale(0.5, 0.5)
		v62.ScaleType = Enum.ScaleType.Fit
		v62.Size = UDim2.fromScale(1.32, 1.32)
		v62.SliceCenter = Rect.new(58, 62, 213, 230)
		outlineGlow = createElement("ImageLabel", v62)
	end

	v57.outlineGlow = outlineGlow
	v57.gradeIndicator = nil
	local itemImage2

	if v5 ~= nil then
		itemImage2 = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = ((data.IsReforging or v5 and v5.Grade == 4) and v8 or v9).Image,
			ImageRectSize = ((data.IsReforging or v5 and v5.Grade == 4) and v8 or v9).ImageRectSize,
			ImageRectOffset = ((data.IsReforging or v5 and v5.Grade == 4) and v8 or v9).ImageRectOffset,
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.8, 0.8)
		})
	end

	v57.itemImage = itemImage2
	local tile

	if not (v5 == nil or not v10[4]) then
		tile = createElement(FastTile, {
			Size = UDim2.new(1, 0, 1, 0),
			Selectable = false,
			ForceAsLabel = true,
			ZIndex = CONSTANTS.LAYER.RAISED,
			IsSelected = false,
			Variant = "Elevated",
			DrawContext = "Default",
			Info = {
				ItemId = v10[4]
			},
			ForceAccessoryItem = {
				Equipped = false,
				Grade = v5.Grade + (v5.ShowNextGrade and 1 or 0),
				Name = v5.Name,
				Type = "Trinket",
				Modifiers = modifiers
			}
		})
	end

	v57.tile = tile
	local children3 = {
		resultItem = createElement("Frame", v56, v57),
		itemLeft = 0,
		itemCenter = 0,
		itemRight = 0,
		circuitBottom = 0,
		circuitLeft = 0,
		circuitRight = 0,
		uIAspectRatioConstraint = 0
	}
	local itemLeft

	if not data.IsReforging then
		local v65 = {
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.INK_900,
			BackgroundTransparency = data.Item1 == nil and 0 or 1,
			Position = UDim2.fromScale(0, 0.00584795),
			Size = UDim2.fromScale(0.278777, 0.302144),
			[React.Event.MouseButton1Click] = function()
				if data.Item2 ~= nil and not data.IsReforging then
					setState2(1)
				end
			end
		}
		local tile2

		if not (v10[1] == nil or data.Item1 == nil) then
			tile2 = createElement(FastTile, {
				Size = UDim2.new(1, 0, 1, 0),
				Selectable = false,
				ForceAsLabel = true,
				IsSelected = false,
				Variant = "Elevated",
				DrawContext = "Default",
				Info = {
					ItemId = v10[1],
					NetworkedUID = data.Item1.Id
				}
			})
		end

		local v66 = {
			tile = tile2,
			uICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.SM
			}),
			uIStroke = 0,
			outlineGlow = 0,
			addTextLabel = 0,
			addTextLabel2 = 0,
			materialCost = 0,
			itemImage = 0,
			gradeIndicator = 0
		}
		local uIStroke2

		if data.Item1 == nil then
			local color

			if data.Item1 == nil then
				color = CONSTANTS.COLOR.PALETTE.BLACK
			else
				color = Color3.fromRGB(255, 238, 60)
			end

			uIStroke2 = createElement("UIStroke", {
				Color = color,
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
			})
		end

		v66.uIStroke = uIStroke2
		local _ = data.Item1 == nil
		v66.outlineGlow = nil
		v66.addTextLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
			Position = UDim2.fromScale(0.5, 0.326618),
			RichText = true,
			Size = UDim2.fromScale(0.713367, 0.748355),
			Text = "+",
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextTransparency = CONSTANTS.ALPHA.HALF,
			ZIndex = CONSTANTS.LAYER.RAISED,
			Visible = data.Item2 ~= nil and data.Item1 == nil and data.IsReforging == false
		})
		v66.addTextLabel2 = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.TITLE,
			Position = UDim2.fromScale(0.494, 0.671796),
			Size = UDim2.fromScale(0.9, 0.23),
			Text = "Add Item",
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextTransparency = CONSTANTS.ALPHA.HALF,
			ZIndex = CONSTANTS.LAYER.RAISED,
			Visible = data.Item2 ~= nil and data.Item1 == nil and data.IsReforging == false
		})
		local materialCost

		if data.IsReforging and data.Item2 ~= nil then
			materialCost = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.8, 0.34),
				Text = `{math.min(reforgeCost, v3 or 0)}/{reforgeCost}`,
				TextColor3 = reforgeCost <= (v3 or 0) and Color3.fromRGB(50, 225, 15) or Color3.fromRGB(225, 15, 15),
				TextScaled = true
			}, {
				uIStroke = createElement("UIStroke", {
					Color = Color3.fromRGB(2, 49, 6),
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
				})
			})
		end

		v66.materialCost = materialCost
		local v80 = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = data.IsReforging and "rbxassetid://109946525658150" or v8.Image,
			ImageRectSize = data.IsReforging and Vector2.zero or v8.ImageRectSize,
			ImageRectOffset = data.IsReforging and Vector2.zero or v8.ImageRectOffset,
			ImageTransparency = 0,
			Position = 0,
			ScaleType = 0,
			Size = 0
		}
		local imageTransparency

		if data.IsReforging then
			imageTransparency = data.Item2 == nil and 0.5 or 0
		else
			imageTransparency = data.Item2 == nil and 1 or data.Item1 == nil and 0.9 or 0
		end

		v80.ImageTransparency = imageTransparency
		v80.Position = UDim2.fromScale(0.5, 0.5)
		v80.ScaleType = Enum.ScaleType.Fit
		v80.Size = UDim2.fromScale(0.8, 0.8)
		v66.itemImage = createElement("ImageLabel", v80)
		local _ = data.Item1 == nil
		v66.gradeIndicator = nil
		itemLeft = createElement("ImageButton", v65, v66)
	end

	children3.itemLeft = itemLeft
	local v65 = {
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.INK_900,
		BackgroundTransparency = data.Item2 == nil and 0 or 1,
		Position = UDim2.fromScale(0.359712, 0.105263),
		Size = UDim2.fromScale(0.278777, 0.302144),
		[React.Event.MouseButton1Click] = function()
			data.SetItemInSlot(2, nil)
			setState2(2)
		end
	}
	local children4 = {
		uICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.SM
		}),
		uIStroke = 0,
		outlineGlow = 0,
		addTextLabel = 0,
		addTextLabel2 = 0,
		itemImage = 0,
		tile = 0,
		gradeIndicator = 0
	}
	local uIStroke3

	if data.Item2 == nil then
		local color

		if data.Item2 == nil then
			color = CONSTANTS.COLOR.PALETTE.BLACK
		else
			color = Color3.fromRGB(255, 238, 60)
		end

		uIStroke3 = createElement("UIStroke", {
			Color = color,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		})
	end

	children4.uIStroke = uIStroke3
	local _ = data.Item2 == nil
	children4.outlineGlow = nil
	children4.addTextLabel = createElement("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.TITLE,
		Position = UDim2.fromScale(0.494, 0.671796),
		Size = UDim2.fromScale(0.9, 0.23),
		Text = "Add Item",
		TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		TextScaled = true,
		TextTransparency = CONSTANTS.ALPHA.HALF,
		Visible = data.Item2 == nil,
		ZIndex = CONSTANTS.LAYER.RAISED
	})
	children4.addTextLabel2 = createElement("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
		Position = UDim2.fromScale(0.5, 0.326618),
		RichText = true,
		Size = UDim2.fromScale(0.713367, 0.748355),
		Text = "+",
		TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		TextScaled = true,
		TextTransparency = CONSTANTS.ALPHA.HALF,
		Visible = data.Item2 == nil,
		ZIndex = CONSTANTS.LAYER.RAISED
	})
	children4.itemImage = createElement("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = v8.Image,
		ImageRectSize = v8.ImageRectSize,
		ImageRectOffset = v8.ImageRectOffset,
		Position = UDim2.fromScale(0.5, 0.5),
		ScaleType = Enum.ScaleType.Fit,
		ImageTransparency = data.Item2 == nil and 1 or 0,
		Size = UDim2.fromScale(0.8, 0.8)
	})
	local tile3

	if not (v10[2] == nil or data.Item2 == nil) then
		tile3 = createElement(FastTile, {
			Size = UDim2.new(1, 0, 1, 0),
			Selectable = false,
			ForceAsLabel = true,
			IsSelected = false,
			Variant = "Elevated",
			DrawContext = "Default",
			Info = {
				ItemId = v10[2],
				NetworkedUID = data.Item2.Id
			}
		})
	end

	children4.tile = tile3
	local _ = data.Item2 == nil
	children4.gradeIndicator = nil
	children3.itemCenter = createElement("ImageButton", v65, children4)
	local itemRight

	if not data.IsReforging then
		local v71 = {
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.INK_900,
			BackgroundTransparency = data.Item3 == nil and 0 or 1,
			Position = UDim2.fromScale(0.728417, 0),
			Size = UDim2.fromScale(0.278777, 0.302144),
			[React.Event.MouseButton1Click] = function()
				if data.Item2 ~= nil and not data.IsReforging then
					setState2(3)
				end
			end
		}
		local tile2

		if not (v10[3] == nil or data.Item3 == nil) then
			tile2 = createElement(FastTile, {
				Size = UDim2.new(1, 0, 1, 0),
				Selectable = false,
				ForceAsLabel = true,
				IsSelected = false,
				Variant = "Elevated",
				DrawContext = "Default",
				Info = {
					ItemId = v10[3],
					NetworkedUID = data.Item3.Id
				}
			})
		end

		local children5 = {
			tile = tile2,
			uICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.SM
			}),
			uIStroke = 0,
			outlineGlow = 0,
			addTextLabel = 0,
			addTextLabel2 = 0,
			itemImage = 0,
			gradeIndicator = 0
		}
		local uIStroke2

		if data.Item3 == nil then
			local color

			if data.Item3 == nil then
				color = CONSTANTS.COLOR.PALETTE.BLACK
			else
				color = Color3.fromRGB(255, 238, 60)
			end

			uIStroke2 = createElement("UIStroke", {
				Color = color,
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
			})
		end

		children5.uIStroke = uIStroke2
		local _ = data.Item3 == nil
		children5.outlineGlow = nil
		children5.addTextLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.TITLE,
			Position = UDim2.fromScale(0.494, 0.671796),
			Size = UDim2.fromScale(0.9, 0.23),
			Text = "Add Item",
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextTransparency = CONSTANTS.ALPHA.HALF,
			ZIndex = CONSTANTS.LAYER.RAISED,
			Visible = data.Item2 ~= nil and data.Item3 == nil and data.IsReforging == false
		})
		children5.addTextLabel2 = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
			Position = UDim2.fromScale(0.5, 0.326618),
			RichText = true,
			Size = UDim2.fromScale(0.713367, 0.748355),
			Text = "+",
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextTransparency = CONSTANTS.ALPHA.HALF,
			ZIndex = CONSTANTS.LAYER.RAISED,
			Visible = data.Item2 ~= nil and data.Item3 == nil and data.IsReforging == false
		})
		children5.itemImage = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = data.IsReforging and "rbxassetid://109946525658150" or v8.Image,
			ImageRectSize = data.IsReforging and Vector2.zero or v8.ImageRectSize,
			ImageRectOffset = data.IsReforging and Vector2.zero or v8.ImageRectOffset,
			ImageTransparency = data.IsReforging and 0.5 or data.Item2 == nil and 1 or data.Item3 == nil and 0.9 or 0,
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.8, 0.8)
		})
		local _ = data.Item3 == nil
		children5.gradeIndicator = nil
		itemRight = createElement("ImageButton", v71, children5)
	end

	children3.itemRight = itemRight
	children3.circuitBottom = createElement("ImageLabel", {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = "rbxassetid://76866744060751",
		ImageTransparency = data.Item2 and 0 or 0.5,
		Position = UDim2.fromScale(0.278777, 0.31384),
		ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.fromScale(0.429856, 0.276803),
		ZIndex = -9
	}, {
		uIGradient = createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.HEADER.BACKGROUND),
				ColorSequenceKeypoint.new(0.509499, CONSTANTS.COLOR.PALETTE.GOLD_450),
				ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.HEADER.BACKGROUND)
			})
		})
	})
	local circuitLeft

	if not data.IsReforging then
		circuitLeft = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://71201398081056",
			ImageTransparency = data.Item1 and 0 or 0.5,
			Position = UDim2.fromScale(0.0431655, 0.148148),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.309353, 0.251462),
			ZIndex = -9
		}, {
			uIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.HEADER.BACKGROUND),
					ColorSequenceKeypoint.new(0.509499, CONSTANTS.COLOR.PALETTE.GOLD_450),
					ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.HEADER.BACKGROUND)
				})
			})
		})
	end

	children3.circuitLeft = circuitLeft
	local circuitRight

	if not data.IsReforging then
		circuitRight = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://112594312905804",
			ImageTransparency = data.Item3 and 0 or 0.5,
			Position = UDim2.fromScale(0.642086, 0.148148),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.309353, 0.251462),
			ZIndex = -9
		}, {
			uIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.HEADER.BACKGROUND),
					ColorSequenceKeypoint.new(0.243333, CONSTANTS.COLOR.PALETTE.GOLD_450),
					ColorSequenceKeypoint.new(0.493333, CONSTANTS.COLOR.HEADER.BACKGROUND),
					ColorSequenceKeypoint.new(0.751667, CONSTANTS.COLOR.PALETTE.GOLD_450),
					ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.HEADER.BACKGROUND)
				})
			})
		})
	end

	children3.circuitRight = circuitRight
	children3.uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
		AspectRatio = 1.08382
	})
	v34.machine = createElement("Frame", v53, children3)
	v21.content = createElement("Frame", v33, v34)
	children.main = createElement("Frame", v20, v21)
	children.uICorner = createElement("UICorner", {
		CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.XXS
	})
	children.uIStroke = createElement("UIStroke", {
		Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
	})
	children.title = createElement("Frame", {
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		Position = UDim2.fromScale(0, 3.91313e-8),
		Size = UDim2.fromScale(1, 0.11846)
	}, {
		uICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
		}),
		uIStroke = createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		uIGradient = createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.HEADER.BACKGROUND),
				ColorSequenceKeypoint.new(0.509499, CONSTANTS.COLOR.PALETTE.GOLD_450),
				ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.HEADER.BACKGROUND)
			})
		}),
		textLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			Position = UDim2.fromScale(0.5, 0.55),
			Size = UDim2.fromScale(0.8, 0.75),
			Text = data.IsReforging and "Reforging Machine" or "Fusion Machine",
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true
		}, {
			uIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
			}),
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.45),
				Size = UDim2.fromScale(1, 1),
				Text = data.IsReforging and "Reforging Machine" or "Fusion Machine",
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true
			}, {
				uIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
				})
			})
		}),
		close = createElement("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = CONSTANTS.COLOR.DANGER.BACKGROUND,
			BorderColor3 = CONSTANTS.COLOR.DANGER.BORDER,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
			FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
			LayoutOrder = -999,
			Position = UDim2.fromScale(0.985, 0.5),
			Size = UDim2.fromScale(0.0535928, 0.7),
			Text = "",
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true,
			TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			ZIndex = CONSTANTS.LAYER.RAISED,
			[React.Event.MouseButton1Click] = function()
				data.SetItemInSlot(1, nil)
				data.SetItemInSlot(2, nil)
				data.SetItemInSlot(3, nil)
				setState(nil)
				data.SetIsOpen(false)
			end
		}, {
			trans = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = CONSTANTS.COLOR.DANGER.HIGHLIGHT,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.94, 0.47)
			}),
			icon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://127503254560275",
				ImageRectSize = Vector2.new(100, 100),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				ZIndex = 4
			}),
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
		})
	})
	children.uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
		AspectRatio = 1.37401
	})
	v14.window = createElement("Frame", v17, children)
	return (createElement(fragment, nil, v14))
end