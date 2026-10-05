local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = require(ReplicatedStorage.Data.Assets)
local AssetEarnings = require(ReplicatedStorage.Shared.Util.AssetEarnings)
local AssetItems = require(ReplicatedStorage.Shared.Util.AssetItems)
local AssetRoster = require(ReplicatedStorage.Client.AssetRoster)
local BaseUpgrade = require(ReplicatedStorage.Client.BaseUpgrade)
local Bases = require(ReplicatedStorage.Data.Bases)
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
require(ReplicatedStorage.Shared.Globals.Constants)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local GUI = require(ReplicatedStorage.Client.GUI)
local SwapGradient = require(ReplicatedStorage.Shared.Utils.SwapGradient)
local Hud = require(ReplicatedStorage.Client.Hud)
local GamepadBindings = require(ReplicatedStorage.Client.GamepadBindings)
local MenuNavigation = require(ReplicatedStorage.Client.MenuNavigation)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local PetPenCapacityGuidanceController = require(script.PetPenCapacityGuidanceController)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
local SlideDock = require(ReplicatedStorage.Client.UI.SlideDock)
local Trove = require(ReplicatedStorage.Packages.Trove)
local color = Color3.fromRGB(255, 70, 70)
local color2 = Color3.fromRGB(85, 255, 85)
local colorSequence = ColorSequence.new(Color3.fromRGB(214, 17, 17), Color3.fromRGB(253, 20, 20))
local color3 = Color3.fromRGB(72, 0, 0)
local color4 = Color3.fromRGB(255, 103, 103)
return {
	Start = function()
		local function claimRowTemplate(scrollingFrame)
			local v = nil

			for _, guiObject in scrollingFrame:GetChildren() do
				if not (guiObject.Name == "Template" and guiObject:IsA("GuiObject")) then
					continue
				end

				if v == nil then
					v = guiObject
				else
					guiObject:Destroy()
				end
			end

			assert(v ~= nil, "ActivePets.Frame.ScrollingFrame has no Template row")
			return v
		end

		local function shadowFor(instance)
			local textLabel = instance:FindFirstChild("TextLabel")

			if textLabel == nil or not textLabel:IsA("TextLabel") then
				return instance
			end

			return textLabel
		end

		local localPlayer = Players.LocalPlayer
		local screenGui = GUI.ActivePets()
		local frame = screenGui.Frame
		local title = frame.Header.Title
		local textLabel = title:FindFirstChild("TextLabel")

		if textLabel == nil or not textLabel:IsA("TextLabel") then
			textLabel = title
		end

		local plusEquip = frame.Header.PlusEquip
		local textLabel2 = plusEquip:FindFirstChild("TextLabel")
		local scrollingFrame = frame.ScrollingFrame
		local emptyLast = scrollingFrame:FindFirstChild("EmptyLast")
		local v = claimRowTemplate(scrollingFrame)
		local close = frame.Close
		local equipBest = frame.EquipBest
		local every = Hud.Every("PetsButton")
		local uIGradient = plusEquip:FindFirstChildOfClass("UIGradient")
		local uIStroke = plusEquip:FindFirstChild("UIStroke")
		local uIStrokeClr = plusEquip:FindFirstChild("UIStrokeClr")
		local color5

		if uIGradient == nil then
			color5 = nil
		else
			color5 = uIGradient.Color
		end

		local color6

		if uIStroke == nil then
			color6 = nil
		else
			color6 = uIStroke.Color
		end

		local color7

		if uIStrokeClr == nil then
			color7 = nil
		else
			color7 = uIStrokeClr.Color
		end

		local v2 = {}
		local v3 = {}
		local v4 = 0
		local v5 = false
		local v6 = 0
		assert(screenGui:IsA("ScreenGui"), "PlayerGui.ActivePets must be a ScreenGui")
		assert(frame:IsA("GuiObject"), "ActivePets.Frame must be a GuiObject")
		assert(title:IsA("TextLabel"), "ActivePets.Frame.Header.Title must be a TextLabel")
		assert(plusEquip:IsA("GuiButton"), "ActivePets.Frame.Header.PlusEquip must be a GuiButton")
		local v7

		if textLabel2 == nil then
			v7 = false
		else
			v7 = textLabel2:IsA("TextLabel")
		end

		assert(v7, "ActivePets.Frame.Header.PlusEquip.TextLabel must be a TextLabel")
		assert(scrollingFrame:IsA("ScrollingFrame"), "ActivePets.Frame.ScrollingFrame must be a ScrollingFrame")
		assert(close:IsA("GuiButton"), "ActivePets.Frame.Close must be a GuiButton")
		assert(equipBest:IsA("GuiButton"), "ActivePets.Frame.EquipBest must be a GuiButton")
		assert(#every > 0, "the HUD has no PetsButton to open ActivePets with")
		local textLabel3 = textLabel2:FindFirstChild("TextLabel")

		if textLabel3 == nil or not textLabel3:IsA("TextLabel") then
			textLabel3 = textLabel2
		end

		screenGui.ResetOnSpawn = false
		plusEquip.AutoButtonColor = false
		GamepadBindings.TrackCloseButton(close)
		local v8 = SlideDock.new(screenGui, frame, SlideDock.EscortFramesOf(every))

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setOpen(flag: boolean, flag2: boolean?)
			v8:SetOpen(flag, flag2)
		end

		local function getCapacity(p)
			local getAssetEquipCapacity = Bases.GetAssetEquipCapacity
			local v9

			if p ~= nil then
				v9 = p.BaseUpgradeLevel
			end

			return getAssetEquipCapacity(v9)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setTextWithShadow(p, p2, text: string)
			p.Text = text
			p2.Text = text
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function formatDisplayNameWithRate(p)
			return p.DisplayName .. " ($" .. Simple.FormatCompact(p.Rate, ".#") .. "/s)"
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function ownsButtonSelection()
			return screenGui.Enabled and frame.Visible and not (MenuNavigation.IsSuspended() or MenuNavigation.IsCursorActive())
		end

		local function keepRowVisible(p)
			if not ownsButtonSelection() or GuiService.SelectedObject ~= p then
				return
			end

			local v9 = p.AbsolutePosition.Y - scrollingFrame.AbsolutePosition.Y
			local v10 = v9 + p.AbsoluteSize.Y
			local Y = scrollingFrame.AbsoluteWindowSize.Y

			if not (v9 < 0) then
				v9 = not (Y < v10) and 0 or v10 - Y
			end

			if v9 ~= 0 then
				local canvasPosition = scrollingFrame.CanvasPosition
				local v11 = math.max(0, scrollingFrame.AbsoluteCanvasSize.Y - Y)
				scrollingFrame.CanvasPosition = Vector2.new(
					canvasPosition.X,
					(math.clamp(canvasPosition.Y + v9, 0, v11))
				)
			end
		end

		local function updateNavigation()
			local nextSelectionLeft

			if plusEquip.Active then
				nextSelectionLeft = plusEquip
			else
				nextSelectionLeft = close
			end

			local button

			if #v3 > 0 then
				button = v3[1].Button
			else
				button = equipBest
			end

			local button2

			if #v3 > 0 then
				button2 = v3[#v3].Button
			else
				button2 = nextSelectionLeft
			end

			plusEquip.NextSelectionUp = close
			plusEquip.NextSelectionDown = button
			plusEquip.NextSelectionLeft = plusEquip
			plusEquip.NextSelectionRight = close
			close.NextSelectionUp = close
			close.NextSelectionDown = button
			close.NextSelectionLeft = nextSelectionLeft
			close.NextSelectionRight = close
			equipBest.NextSelectionUp = button2
			equipBest.NextSelectionDown = close
			equipBest.NextSelectionLeft = equipBest
			equipBest.NextSelectionRight = close

			for k, v10 in v3 do
				local button3 = v10.Button
				button3:SetAttribute("DefaultFocus", k == 1)
				local nextSelectionUp

				if k == 1 then
					nextSelectionUp = nextSelectionLeft
				else
					nextSelectionUp = v3[k - 1].Button
				end

				button3.NextSelectionUp = nextSelectionUp
				local nextSelectionDown

				if k == #v3 then
					nextSelectionDown = equipBest
				else
					nextSelectionDown = v3[k + 1].Button
				end

				button3.NextSelectionDown = nextSelectionDown
				button3.NextSelectionLeft = button3
				button3.NextSelectionRight = close
			end

			equipBest:SetAttribute("DefaultFocus", #v3 == 0)
		end

		local function updateHeader(p, p2: number)
			local getAssetEquipCapacity = Bases.GetAssetEquipCapacity
			local v9

			if p ~= nil then
				v9 = p.BaseUpgradeLevel
			end

			setTextWithShadow(title, textLabel, `{p2}/{getAssetEquipCapacity(v9)} Active`) -- equivalent call inferred; original call site unknown
			local cost

			if p ~= nil then
				local _, v12 = BaseUpgrade.ResolveNextTier(p)

				if v12 ~= nil then
					cost = v12.Cost
				end
			end

			setTextWithShadow(
				textLabel2,
				textLabel3,
				cost == nil and "MAX EQUIP" or `+1 EQUIP [${Simple.FormatCompact(math.floor(cost), ".#")}]`
			) -- equivalent call inferred; original call site unknown

			if cost == nil and GuiService.SelectedObject == plusEquip and ownsButtonSelection() then
				local v14 = GuiService
				local selectedObject

				if #v3 > 0 then
					selectedObject = v3[1].Button
				else
					selectedObject = equipBest
				end

				v14.SelectedObject = selectedObject
			end

			plusEquip.Active = cost ~= nil
			local v14

			if cost == nil or p == nil then
				v14 = false
			else
				v14 = cost <= p.Money
			end

			local v15

			if cost == nil then
				v15 = false
			else
				v15 = not v14
			end

			if uIGradient ~= nil then
				local v16 = uIGradient
				local color8

				if v15 then
					color8 = colorSequence
				else
					color8 = color5
				end

				v16.Color = color8
			end

			if uIStroke ~= nil then
				local v16 = uIStroke
				local color8

				if v15 then
					color8 = color3
				else
					color8 = color6
				end

				v16.Color = color8
			end

			if uIStrokeClr ~= nil then
				local v16 = uIStrokeClr
				local color8

				if v15 then
					color8 = color4
				else
					color8 = color7
				end

				v16.Color = color8
			end

			updateNavigation()
		end

		local function compareEntries(data, data2)
			if data.Rank ~= data2.Rank then
				return data.Rank > data2.Rank
			end

			if data.Rate == data2.Rate then
				return data.UID < data2.UID
			end

			return data.Rate > data2.Rate
		end

		local function buildEntries(data)
			if data == nil then
				return {}
			end

			local result = {}

			for _, equippedAsset in ipairs(data.EquippedAssets) do
				local v9 = data.Inventory[equippedAsset]

				if v9 == nil then
					continue
				end

				local decoded = AssetItems.Decode(v9)
				local v10 = Assets.Directory[decoded.Category]
				local rarity = v10.Rarity
				local displayName

				if v10.DisplayName == "" then
					displayName = decoded.Category
				else
					displayName = v10.DisplayName
				end

				local v11 = {
					UID = equippedAsset,
					DisplayName = displayName,
					Icon = v10.Icon,
					Rate = AssetEarnings.LiveRatePerSecond(decoded, data.Gamepasses, data.Products, Players.LocalPlayer),
					Rank = rarity.Rank,
					RarityGradient = rarity.RarityGradient
				}
				table.insert(result, v11)
			end

			table.sort(result, compareEntries)
			return result
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function requestUnequip(UID: string)
			local doffAsset, text = AssetRoster.DoffAsset(UID)

			if not doffAsset and text ~= nil then
				Toast.Show({
					Text = text,
					Color = color,
					Seconds = 2
				})
			end
		end

		local function updateRow(state, p, layoutOrder: number)
			state.Root.LayoutOrder = layoutOrder

			if state.Gradient ~= p.RarityGradient then
				SwapGradient(state.Label, p.RarityGradient)

				if state.Shadow ~= state.Label then
					SwapGradient(state.Shadow, p.RarityGradient)
				end

				state.Gradient = p.RarityGradient
			end

			local label = state.Label
			local shadow = state.Shadow
			local text = formatDisplayNameWithRate(p) -- equivalent call inferred; original call site unknown
			setTextWithShadow(label, shadow, text) -- equivalent call inferred; original call site unknown
			state.Icon.Image = p.Icon or ""
		end

		local function mountRow(entry, layoutOrder: number)
			local maid = Trove.new()
			local clone = v:Clone()
			clone.Name = `Pet_{entry.UID}`
			clone.LayoutOrder = layoutOrder
			clone.Visible = true
			clone:SetAttribute("PetListRowClone", true)
			maid:Add(clone)
			local spacer = clone.Spacer
			local textLabel4 = spacer.TextLabel
			local textLabel5 = textLabel4:FindFirstChild("TextLabel")

			if textLabel5 == nil or not textLabel5:IsA("TextLabel") then
				textLabel5 = textLabel4
			end

			local icon = spacer.Icon
			local unequip = spacer.Unequip
			unequip.Selectable = true
			SwapGradient(textLabel4, nil)

			if textLabel5 ~= textLabel4 then
				SwapGradient(textLabel5, nil)
			end

			maid:Connect(unequip.Activated, function()
				requestUnequip(entry.UID) -- equivalent call inferred; original call site unknown
			end)
			maid:Connect(unequip.SelectionGained, function()
				keepRowVisible(unequip)
			end)
			maid:Add(ButtonFX(unequip, 1.08))
			local v9 = {
				Root = clone,
				Button = unequip,
				Label = textLabel4,
				Shadow = textLabel5,
				Icon = icon,
				Gradient = nil,
				Trove = maid
			}
			updateRow(v9, entry, layoutOrder)
			clone.Parent = scrollingFrame
			return v9
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function pinEmptyLast()
			if emptyLast ~= nil then
				emptyLast.LayoutOrder = 1000000
			end
		end

		local function refresh()
			local selectedObject = GuiService.SelectedObject
			local v9 = nil
			local v10 = nil

			for k, v12 in v3 do
				if selectedObject ~= v12.Button then
					continue
				end

				v10 = v12
				v9 = k
				break
			end

			local v12 = Save.Await(localPlayer)
			local entries = buildEntries(v12)
			local v13 = {}
			local v14 = {}
			local v15 = false

			for i, entry in ipairs(entries) do
				if v13[entry.UID] then
					continue
				end

				v13[entry.UID] = true
				local v16 = v2[entry.UID]

				if v16 == nil then
					v16 = mountRow(entry, #v14 + 1)
					v2[entry.UID] = v16
				else
					updateRow(v16, entry, #v14 + 1)
				end

				table.insert(v14, v16)

				if v3[i] ~= v16 then
					v15 = true
				end
			end

			local v16 = v15 or #v14 ~= #v3
			v3 = v14
			v6 = #v14
			pinEmptyLast() -- equivalent call inferred; original call site unknown
			updateHeader(v12, v6)

			if v9 ~= nil and v10 ~= nil and not table.find(v14, v10) and ownsButtonSelection() and GuiService.SelectedObject == selectedObject then
				local v17 = GuiService
				local selectedObject2

				if #v14 > 0 then
					selectedObject2 = v14[math.min(v9, #v14)].Button
				else
					selectedObject2 = equipBest
				end

				v17.SelectedObject = selectedObject2
			end

			for k, v17 in v2 do
				if v13[k] then
					continue
				end

				v2[k] = nil
				v17.Trove:Destroy()
			end

			if v16 and v9 ~= nil then
				local selectedObject2 = GuiService.SelectedObject

				if selectedObject2 ~= nil and selectedObject2:IsDescendantOf(scrollingFrame) then
					task.defer(function()
						if selectedObject2.Parent ~= nil then
							keepRowVisible(selectedObject2)
						end
					end)
				end
			end
		end

		local function refreshUpgradeHeader()
			updateHeader(Save.Await(localPlayer), v6)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function showEquipBestDebounceNotification()
			Toast.Show({
				Text = "Please wait a bit before equipping bests again!",
				Seconds = 2,
				Color = Color3.fromRGB(255, 170, 0)
			})
		end

		local function requestEquipBest()
			local serverTimeNow = workspace:GetServerTimeNow()

			if v5 or serverTimeNow - v4 < 5 then
				showEquipBestDebounceNotification() -- equivalent call inferred; original call site unknown
				return
			end

			v4 = serverTimeNow
			v5 = true
			local v9, v10 = Remotes.Haul.WearBest:InvokeServer()
			v5 = false

			if v9 == true then
				refresh()
			else
				Toast.Show({
					Text = typeof(v10) ~= "string" and "Please wait a bit before equipping bests again!" or v10,
					Seconds = 2,
					Color = color
				})
			end
		end

		local function requestBaseUpgrade()
			BaseUpgrade.PurchaseNextTier()
		end

		v.Visible = false
		setOpen(false, true) -- equivalent call inferred; original call site unknown
		refresh()
		PetPenCapacityGuidanceController.Initialize()

		for _, v9 in every do
			GUI.OnActivated(v9, function()
				PetPenCapacityGuidanceController.AcknowledgePetsBadge()
				setOpen(true, nil) -- equivalent call inferred; original call site unknown
				refresh()
			end)
			ButtonFX(v9, 1.08)
		end

		GUI.OnActivated(close, function()
			setOpen(false, nil) -- equivalent call inferred; original call site unknown
		end)
		ButtonFX(close, 1.08)
		GUI.OnActivated(plusEquip, requestBaseUpgrade)
		ButtonFX(plusEquip, 1.08)
		GUI.OnActivated(equipBest, function()
			PetPenCapacityGuidanceController.AcknowledgeEquipBestBadge()
			requestEquipBest()
		end)
		ButtonFX(equipBest, 1.08)
		Save.WatchFields({
			"Inventory",
			"EquippedAssets",
			"BaseUpgradeLevel",
			"Gamepasses",
			"Products"
		}, refresh)
		Save.Watch("Money"):Connect(refreshUpgradeHeader)
		AssetRoster.SnapshotRefreshed:Connect(refresh)
		AssetRoster.OwnerRefreshed:Connect(function(p: number)
			if p == localPlayer.UserId then
				refresh()
			end
		end)
		AssetRoster.OwnerCleared:Connect(function(p: number)
			if p == localPlayer.UserId then
				refresh()
			end
		end)
		Remotes.Homestead.BaseTierRaised.OnClientEvent:Connect(function()
			Toast.Show({
				Text = "Successfully upgraded your base!",
				Color = color2,
				Seconds = 0.7
			})
			refresh()
		end)
	end
}