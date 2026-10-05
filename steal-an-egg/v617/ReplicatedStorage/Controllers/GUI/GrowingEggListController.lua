local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local AreaEggCycle = require(ReplicatedStorage.Shared.Util.AreaEggCycle)
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
require(ReplicatedStorage.Shared.Eggs.Types)
local EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
local EggState = require(ReplicatedStorage.Client.EggState)
require(ReplicatedStorage.Shared.Types.Eggs)
local GamepadBindings = require(ReplicatedStorage.Client.GamepadBindings)
local Time = require(ReplicatedStorage.Shared.Utils.Time)
local elapsed = Time.Elapsed
local GUI = require(ReplicatedStorage.Client.GUI)
local Hud = require(ReplicatedStorage.Client.Hud)
local GrowingEggListRow = require(ReplicatedStorage.Shared.Eggs.GrowingEggListRow)
local Log = require(ReplicatedStorage.Packages.Log)
local MenuNavigation = require(ReplicatedStorage.Client.MenuNavigation)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local PlacedEggRenderer = require(ReplicatedStorage.Shared.Eggs.PlacedEggRenderer)
local Products = require(ReplicatedStorage.Data.Products)
local Storefront = require(ReplicatedStorage.Client.Functions.Storefront)
local SlideDock = require(ReplicatedStorage.Client.UI.SlideDock)
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

			assert(v ~= nil, "GrowingEggs.Frame.ScrollingFrame has no Template row")
			return v
		end

		local function optionalBadge(instance, childName: string)
			if instance == nil then
				return nil
			end

			local child = instance:FindFirstChild(childName)

			if child == nil then
				return nil
			end

			return child
		end

		local localPlayer = Players.LocalPlayer
		local screenGui = GUI.GrowingEggs()
		local frame = screenGui.Frame
		local close = frame.Close
		local growAll = frame.Header.GrowAll
		local scrollingFrame = frame.ScrollingFrame
		local emptyLast = scrollingFrame:FindFirstChild("EmptyLast")
		local v = claimRowTemplate(scrollingFrame)
		local every = Hud.Every("EggsButton")
		local v2 = Hud.Find("EggsButton")
		local nightImage

		if v2 == nil then
			nightImage = nil
		else
			nightImage = v2:FindFirstChild("NightImage")
		end

		local nightText

		if v2 == nil then
			nightText = nil
		else
			nightText = v2:FindFirstChild("NightText")
		end

		local notification

		if v2 == nil then
			notification = nil
		else
			notification = v2:FindFirstChild("Notification")

			if notification == nil then
				notification = nil
			end
		end

		local textLabel

		if notification == nil then
			textLabel = nil
		else
			textLabel = notification.InletTexture.TextLabel
		end

		local shadow

		if textLabel == nil then
			shadow = nil
		else
			shadow = textLabel.Shadow
		end

		local readyNotification

		if v2 == nil then
			readyNotification = nil
		else
			readyNotification = v2:FindFirstChild("ReadyNotification")

			if readyNotification == nil then
				readyNotification = nil
			end
		end

		local textLabel2

		if readyNotification == nil then
			textLabel2 = nil
		else
			textLabel2 = readyNotification.InletTexture.TextLabel
		end

		local shadow2

		if textLabel2 == nil then
			shadow2 = nil
		else
			shadow2 = textLabel2.Shadow
		end

		local v3 = {}
		local v4 = {}
		local v5 = {}
		local v6 = {}
		local v7 = {}
		local v8 = {}
		local v9 = 0
		local v10 = 0
		local v11 = 0
		assert(screenGui:IsA("ScreenGui"), "PlayerGui.GrowingEggs must be a ScreenGui")
		assert(frame:IsA("GuiObject"), "GrowingEggs.Frame must be a GuiObject")
		assert(close:IsA("GuiButton"), "GrowingEggs.Frame.Close must be a GuiButton")
		assert(growAll:IsA("GuiButton"), "GrowingEggs.Frame.Header.GrowAll must be a GuiButton")
		assert(scrollingFrame:IsA("ScrollingFrame"), "GrowingEggs.Frame.ScrollingFrame must be a ScrollingFrame")
		assert(#every > 0, "the HUD has no EggsButton to open GrowingEggs with")
		screenGui.ResetOnSpawn = false
		GamepadBindings.TrackCloseButton(close)
		local v12 = SlideDock.new(screenGui, frame, SlideDock.EscortFramesOf(every))
		local v13 = Log.new()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setNightDecoration(visible: boolean)
			if nightImage ~= nil then
				nightImage.Visible = visible
			end

			if nightText ~= nil then
				nightText.Visible = visible
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setOpen(flag: boolean, flag2: boolean?)
			v12:SetOpen(flag, flag2)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getGrowthAlpha(record)
			local serverTimeNow = Workspace:GetServerTimeNow()
			return EggRecords.GrowthAlpha(
				record,
				serverTimeNow,
				record.GrowthSpeedMultiplier,
				EggRecords.CurrentNightCredit(record, serverTimeNow, record.GrowthSpeedMultiplier),
				localPlayer
			)
		end

		local function isReady(p)
			local serverTimeNow = Workspace:GetServerTimeNow()
			return EggRecords.GrowthAlpha(
				p,
				serverTimeNow,
				p.GrowthSpeedMultiplier,
				EggRecords.CurrentNightCredit(p, serverTimeNow, p.GrowthSpeedMultiplier),
				localPlayer
			) >= 1
		end

		local function getRemainingSeconds(record)
			if record.Placement == nil then
				return 0
			end

			local serverTimeNow = Workspace:GetServerTimeNow()

			if not (EggRecords.GrowthAlpha(
				record,
				serverTimeNow,
				record.GrowthSpeedMultiplier,
				EggRecords.CurrentNightCredit(record, serverTimeNow, record.GrowthSpeedMultiplier),
				localPlayer
			) >= 1) then
				local serverTimeNow2 = Workspace:GetServerTimeNow()
				return EggRecords.GrowthSecondsRemaining(
					record,
					serverTimeNow2,
					record.GrowthSpeedMultiplier,
					EggRecords.CurrentNightCredit(record, serverTimeNow2, record.GrowthSpeedMultiplier),
					localPlayer
				)
			end

			return 0
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getRemainingText(record)
			local placement = record.Placement

			if placement == nil or placement.ReadyAt ~= nil then
				return "Ready!"
			end

			local v14

			if record.Placement == nil then
				v14 = 0
			else
				local serverTimeNow = Workspace:GetServerTimeNow()

				if EggRecords.GrowthAlpha(
					record,
					serverTimeNow,
					record.GrowthSpeedMultiplier,
					EggRecords.CurrentNightCredit(record, serverTimeNow, record.GrowthSpeedMultiplier),
					localPlayer
				) >= 1 then
					v14 = 0
				else
					local serverTimeNow2 = Workspace:GetServerTimeNow()
					v14 = EggRecords.GrowthSecondsRemaining(
						record,
						serverTimeNow2,
						record.GrowthSpeedMultiplier,
						EggRecords.CurrentNightCredit(record, serverTimeNow2, record.GrowthSpeedMultiplier),
						localPlayer
					)
				end
			end

			if v14 <= 0 then
				return "Ready!"
			end

			return (elapsed(v14))
		end

		local function updateRow(data)
			local selectedObject = GuiService.SelectedObject
			local v14 = screenGui.Enabled and not MenuNavigation.IsSuspended() and not MenuNavigation.IsCursorActive() and (selectedObject == data.GrowButton or selectedObject == data.HatchButton)
			local record = data.Record
			local growthAlpha = getGrowthAlpha(record) -- equivalent call inferred; original call site unknown
			local v15 = growthAlpha >= 1
			local v16 = not v15 and Products.GetEggSkipGrowthProduct(getRemainingSeconds(record)) ~= nil
			local update = GrowingEggListRow.Update
			local eggIcon = EggRecords.EggIcon(record)
			local remainingText = getRemainingText(record) -- equivalent call inferred; original call site unknown
			update(data, eggIcon, growthAlpha, remainingText, v15, v16)

			if v14 then
				local hatchButton

				if v15 then
					hatchButton = data.HatchButton
				else
					hatchButton = data.GrowButton
				end

				if hatchButton.Visible and hatchButton.Active and hatchButton.Interactable then
					hatchButton.Selectable = true

					if GuiService.SelectedObject ~= hatchButton then
						GuiService.SelectedObject = hatchButton
					end
				end
			end
		end

		local function updateNotification(p, p2, p3, p4: number)
			if p == nil or p2 == nil or p3 == nil then
				return
			end

			local visible = p4 > 0
			p.Visible = visible

			if visible then
				local text = tostring(p4)
				p2.Text = text
				p3.Text = text
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updatePlacedNotification()
			local v14 = notification
			local v15 = textLabel
			local v16 = shadow
			local v17 = v9

			if v14 ~= nil and v15 ~= nil then
				if v16 == nil then
					return
				end

				local visible = v17 > 0
				v14.Visible = visible

				if visible then
					local text = tostring(v17)
					v15.Text = text
					v16.Text = text
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateReadyNotification()
			local v14 = readyNotification
			local v15 = textLabel2
			local v16 = shadow2
			local v17 = v10

			if v14 ~= nil and v15 ~= nil then
				if v16 == nil then
					return
				end

				local visible = v17 > 0
				v14.Visible = visible

				if visible then
					local text = tostring(v17)
					v15.Text = text
					v16.Text = text
				end
			end
		end

		local function clearPlacedNotification()
			v9 = 0
			table.clear(v7)
			updatePlacedNotification() -- equivalent call inferred; original call site unknown
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function clearReadyNotification()
			v10 = 0
			table.clear(v8)
			updateReadyNotification() -- equivalent call inferred; original call site unknown
		end

		local function incrementPlacedNotification(p: string)
			if screenGui.Enabled or v7[p] then
				return
			end

			v7[p] = true
			v9 += 1
			updatePlacedNotification() -- equivalent call inferred; original call site unknown
		end

		local function incrementReadyNotification(p: string)
			if screenGui.Enabled or v8[p] then
				return
			end

			v8[p] = true
			v10 += 1
			updateReadyNotification() -- equivalent call inferred; original call site unknown
		end

		local function consumePlacedNotification(p: string)
			if not v7[p] then
				return
			end

			v7[p] = nil
			v9 = math.max(v9 - 1, 0)
			updatePlacedNotification() -- equivalent call inferred; original call site unknown
		end

		local function consumeReadyNotification(p: string)
			if not v8[p] then
				return
			end

			v8[p] = nil
			v10 = math.max(v10 - 1, 0)
			updateReadyNotification() -- equivalent call inferred; original call site unknown
		end

		local function syncReadyState(p: string, p2, flag: boolean)
			local serverTimeNow = Workspace:GetServerTimeNow()
			local selected = EggRecords.GrowthAlpha(
				p2,
				serverTimeNow,
				p2.GrowthSpeedMultiplier,
				EggRecords.CurrentNightCredit(p2, serverTimeNow, p2.GrowthSpeedMultiplier),
				localPlayer
			) >= 1

			if selected and not v6[p] then
				v6[p] = true

				if flag and not screenGui.Enabled then
					if v8[p] then
						return selected
					end

					v8[p] = true
					v10 += 1
					local v15 = readyNotification
					local v16 = textLabel2
					local v17 = shadow2
					local v18 = v10

					if v15 ~= nil and v16 ~= nil then
						if v17 == nil then
							return selected
						end

						local visible = v18 > 0
						v15.Visible = visible

						if visible then
							local text = tostring(v18)
							v16.Text = text
							v17.Text = text
							return selected
						end
					end
				end
			elseif not selected and v6[p] then
				v6[p] = nil

				if not v8[p] then
					return selected
				end

				v8[p] = nil
				v10 = math.max(v10 - 1, 0)
				local v15 = readyNotification
				local v16 = textLabel2
				local v17 = shadow2
				local v18 = v10

				if v15 ~= nil and v16 ~= nil then
					if v17 == nil then
						return selected
					end

					local visible = v18 > 0
					v15.Visible = visible

					if visible then
						local text = tostring(v18)
						v16.Text = text
						v17.Text = text
					end
				end
			end

			return selected
		end

		local function compareRows(p, p2)
			local record = p.Record
			local serverTimeNow = Workspace:GetServerTimeNow()
			local v14 = EggRecords.GrowthAlpha(
				record,
				serverTimeNow,
				record.GrowthSpeedMultiplier,
				EggRecords.CurrentNightCredit(record, serverTimeNow, record.GrowthSpeedMultiplier),
				localPlayer
			) >= 1
			local record2 = p2.Record
			local serverTimeNow2 = Workspace:GetServerTimeNow()

			if v14 ~= (EggRecords.GrowthAlpha(
				record2,
				serverTimeNow2,
				record2.GrowthSpeedMultiplier,
				EggRecords.CurrentNightCredit(record2, serverTimeNow2, record2.GrowthSpeedMultiplier),
				localPlayer
			) >= 1) then
				return v14
			end

			local record3 = p.Record
			local v15

			if record3.Placement == nil then
				v15 = 0
			else
				local serverTimeNow3 = Workspace:GetServerTimeNow()

				if EggRecords.GrowthAlpha(
					record3,
					serverTimeNow3,
					record3.GrowthSpeedMultiplier,
					EggRecords.CurrentNightCredit(record3, serverTimeNow3, record3.GrowthSpeedMultiplier),
					localPlayer
				) >= 1 then
					v15 = 0
				else
					local serverTimeNow4 = Workspace:GetServerTimeNow()
					v15 = EggRecords.GrowthSecondsRemaining(
						record3,
						serverTimeNow4,
						record3.GrowthSpeedMultiplier,
						EggRecords.CurrentNightCredit(record3, serverTimeNow4, record3.GrowthSpeedMultiplier),
						localPlayer
					)
				end
			end

			local record4 = p2.Record
			local v16

			if record4.Placement == nil then
				v16 = 0
			else
				local serverTimeNow3 = Workspace:GetServerTimeNow()

				if EggRecords.GrowthAlpha(
					record4,
					serverTimeNow3,
					record4.GrowthSpeedMultiplier,
					EggRecords.CurrentNightCredit(record4, serverTimeNow3, record4.GrowthSpeedMultiplier),
					localPlayer
				) >= 1 then
					v16 = 0
				else
					local serverTimeNow4 = Workspace:GetServerTimeNow()
					v16 = EggRecords.GrowthSecondsRemaining(
						record4,
						serverTimeNow4,
						record4.GrowthSpeedMultiplier,
						EggRecords.CurrentNightCredit(record4, serverTimeNow4, record4.GrowthSpeedMultiplier),
						localPlayer
					)
				end
			end

			if v15 == v16 then
				return tostring(p.Uid) < tostring(p2.Uid)
			end

			return v15 < v16
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function pinEmptyLast()
			if emptyLast ~= nil then
				emptyLast.LayoutOrder = 1000000
			end
		end

		local function rowAction(data)
			local hatchButton

			if data.Ready then
				hatchButton = data.HatchButton
			else
				hatchButton = data.GrowButton
			end

			if hatchButton.Visible and hatchButton.Active and hatchButton.Interactable then
				return hatchButton
			end

			return nil
		end

		local function linkRows()
			local v14 = {}

			for _, v15 in v3 do
				table.insert(v14, v15)
			end

			table.sort(v14, function(a, b)
				return a.Root.LayoutOrder < b.Root.LayoutOrder
			end)
			local hatchButtons = {}

			for _, v15 in v14 do
				for _, v16 in { v15.GrowButton, v15.HatchButton } do
					v16.NextSelectionUp = nil
					v16.NextSelectionDown = nil
					v16.NextSelectionLeft = nil
					v16.NextSelectionRight = nil
				end

				local hatchButton

				if v15.Ready then
					hatchButton = v15.HatchButton
				else
					hatchButton = v15.GrowButton
				end

				if not (hatchButton.Visible and hatchButton.Active and hatchButton.Interactable) then
					hatchButton = nil
				end

				if hatchButton then
					table.insert(hatchButtons, hatchButton)
				end
			end

			growAll.NextSelectionUp = close
			growAll.NextSelectionLeft = growAll
			growAll.NextSelectionRight = close
			close.NextSelectionUp = close
			close.NextSelectionLeft = growAll
			close.NextSelectionRight = close
			growAll.NextSelectionDown = hatchButtons[1] or close
			close.NextSelectionDown = hatchButtons[1] or growAll

			for k, nextSelectionLeft in hatchButtons do
				nextSelectionLeft.NextSelectionUp = hatchButtons[k - 1] or growAll
				nextSelectionLeft.NextSelectionDown = hatchButtons[k + 1] or close
				nextSelectionLeft.NextSelectionLeft = nextSelectionLeft
				nextSelectionLeft.NextSelectionRight = close
			end
		end

		local function relayoutRows()
			local v14 = {}

			for _, v15 in pairs(v3) do
				table.insert(v14, v15)
			end

			table.sort(v14, compareRows)

			for i, v15 in ipairs(v14) do
				v15.Root.LayoutOrder = i
			end

			pinEmptyLast() -- equivalent call inferred; original call site unknown
			linkRows()
		end

		local function destroyRow(p: string)
			local v14 = v3[p]

			if v14 == nil then
				return
			end

			v3[p] = nil
			local selectedObject = GuiService.SelectedObject

			if screenGui.Enabled and not MenuNavigation.IsSuspended() and not MenuNavigation.IsCursorActive() and selectedObject and selectedObject:IsDescendantOf(v14.Root) then
				local v15 = nil
				local v16 = nil

				for _, v17 in v3 do
					local hatchButton

					if v17.Ready then
						hatchButton = v17.HatchButton
					else
						hatchButton = v17.GrowButton
					end

					if not (hatchButton.Visible and hatchButton.Active and hatchButton.Interactable) then
						hatchButton = nil
					end

					if not hatchButton then
						continue
					end

					if v17.Root.LayoutOrder >= v14.Root.LayoutOrder then
						if v15 == nil or v17.Root.LayoutOrder < v15.Root.LayoutOrder then
							v15 = v17
						end
					elseif v16 == nil or v17.Root.LayoutOrder > v16.Root.LayoutOrder then
						v16 = v17
					end
				end

				local v17 = v15 or v16
				local hatchButton

				if v17 then
					if v17.Ready then
						hatchButton = v17.HatchButton
					else
						hatchButton = v17.GrowButton
					end

					if not (hatchButton.Visible and hatchButton.Active and hatchButton.Interactable) then
						hatchButton = nil
					end
				else
					hatchButton = growAll
				end

				if hatchButton then
					hatchButton.Selectable = true
				end

				GuiService.SelectedObject = hatchButton
			end

			GrowingEggListRow.Destroy(v14)
			linkRows()
		end

		local function requestGrow(p: string)
			local skipGrowthForLocalEgg, v14 = PlacedEggRenderer.RequestSkipGrowthForLocalEgg(p)

			if not skipGrowthForLocalEgg then
				v13:AtWarning():Log((`Failed to request egg growth skip from list for {p}: {v14 or "unknown"}`))
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function showNoGrowingEggs(value: string?)
			Toast.Show({
				Text = value or "You have no growing eggs!",
				Seconds = 2,
				Color = Color3.fromRGB(255, 80, 80)
			})
		end

		local function requestGrowAll()
			local mayBuyGrowAll, v14 = EggState.MayBuyGrowAll()

			if not mayBuyGrowAll then
				showNoGrowingEggs(v14) -- equivalent call inferred; original call site unknown
				return
			end

			EggState.ForgetChosenSkip()
			Storefront.Prompt(Products.Directory.EggGrowAll.ProductId, true)
		end

		local function requestHatch(p: string)
			local v14, v15 = PlacedEggRenderer.ActivateLocalEgg(p)

			if not v14 then
				v13:AtWarning():Log((`Failed to hatch egg from list for {p}: {v15 or "unknown"}`))
			end
		end

		local function removeHatchingRow(p: string)
			v4[p] = true

			if v7[p] then
				v7[p] = nil
				v9 = math.max(v9 - 1, 0)
				local v14 = notification
				local v15 = textLabel
				local v16 = shadow
				local v17 = v9

				if v14 ~= nil and v15 ~= nil and v16 ~= nil then
					local visible = v17 > 0
					v14.Visible = visible

					if visible then
						local text = tostring(v17)
						v15.Text = text
						v16.Text = text
					end
				end
			end

			if v8[p] then
				v8[p] = nil
				v10 = math.max(v10 - 1, 0)
				local v14 = readyNotification
				local v15 = textLabel2
				local v16 = shadow2
				local v17 = v10

				if v14 ~= nil and v15 ~= nil and v16 ~= nil then
					local visible = v17 > 0
					v14.Visible = visible

					if visible then
						local text = tostring(v17)
						v15.Text = text
						v16.Text = text
					end
				end
			end

			destroyRow(p)
		end

		local function mountRow(k: string, record)
			local v14 = GrowingEggListRow.Mount(v, scrollingFrame, k, requestGrow, requestHatch)
			v14.Record = record
			v3[k] = v14
			v14.Trove:Add(ButtonFX(v14.GrowButton, 1.08))

			if v14.HatchButton ~= v14.GrowButton then
				v14.Trove:Add(ButtonFX(v14.HatchButton, 1.08))
			end

			updateRow(v14)
			return v14
		end

		local function refreshRows(flag: boolean, flag2: boolean)
			local ownerEggs = EggState.ReadOwnerEggs(localPlayer.UserId)
			local v14 = {}
			local v15 = {}

			for k, ownerEgg in pairs(ownerEggs) do
				if ownerEgg.Placement == nil then
					continue
				end

				v14[k] = true

				if not v5[k] then
					v5[k] = true

					if flag and not (screenGui.Enabled or v7[k]) then
						v7[k] = true
						v9 += 1
						local v16 = notification
						local v17 = textLabel
						local v18 = shadow
						local v19 = v9

						if v16 ~= nil and v17 ~= nil and v18 ~= nil then
							local visible = v19 > 0
							v16.Visible = visible

							if visible then
								local text = tostring(v19)
								v17.Text = text
								v18.Text = text
							end
						end
					end
				end

				local serverTimeNow = Workspace:GetServerTimeNow()
				local v16 = EggRecords.GrowthAlpha(
					ownerEgg,
					serverTimeNow,
					ownerEgg.GrowthSpeedMultiplier,
					EggRecords.CurrentNightCredit(ownerEgg, serverTimeNow, ownerEgg.GrowthSpeedMultiplier),
					localPlayer
				) >= 1

				if v16 and not v6[k] then
					v6[k] = true

					if flag2 and not (screenGui.Enabled or v8[k]) then
						v8[k] = true
						v10 += 1
						local v17 = readyNotification
						local v18 = textLabel2
						local v19 = shadow2
						local v20 = v10

						if v17 ~= nil and v18 ~= nil and v19 ~= nil then
							local visible = v20 > 0
							v17.Visible = visible

							if visible then
								local text = tostring(v20)
								v18.Text = text
								v19.Text = text
							end
						end
					end
				elseif not v16 and v6[k] then
					v6[k] = nil

					if v8[k] then
						v8[k] = nil
						v10 = math.max(v10 - 1, 0)
						local v17 = readyNotification
						local v18 = textLabel2
						local v19 = shadow2
						local v20 = v10

						if v17 ~= nil and v18 ~= nil and v19 ~= nil then
							local visible = v20 > 0
							v17.Visible = visible

							if visible then
								local text = tostring(v20)
								v18.Text = text
								v19.Text = text
							end
						end
					end
				end

				if v4[k] then
					destroyRow(k)
				else
					v15[k] = true
					local v17 = v3[k]

					if v17 == nil then
						mountRow(k, ownerEgg)
					else
						v17.Record = ownerEgg
						updateRow(v17)
					end
				end
			end

			for k in pairs(v3) do
				if not v15[k] then
					destroyRow(k)
				end
			end

			for k in pairs(v5) do
				if v14[k] then
					continue
				end

				if v7[k] then
					v7[k] = nil
					v9 = math.max(v9 - 1, 0)
					local v16 = notification
					local v17 = textLabel
					local v18 = shadow
					local v19 = v9

					if v16 ~= nil and v17 ~= nil and v18 ~= nil then
						local visible = v19 > 0
						v16.Visible = visible

						if visible then
							local text = tostring(v19)
							v17.Text = text
							v18.Text = text
						end
					end
				end

				if v8[k] then
					v8[k] = nil
					v10 = math.max(v10 - 1, 0)
					local v16 = readyNotification
					local v17 = textLabel2
					local v18 = shadow2
					local v19 = v10

					if v16 ~= nil and v17 ~= nil and v18 ~= nil then
						local visible = v19 > 0
						v16.Visible = visible

						if visible then
							local text = tostring(v19)
							v17.Text = text
							v18.Text = text
						end
					end
				end

				v5[k] = nil
				v6[k] = nil
				v4[k] = nil
			end

			relayoutRows()
		end

		local function updateVisibleRows()
			local serverTimeNow = Workspace:GetServerTimeNow()

			if serverTimeNow - v11 < 0.25 then
				return
			end

			v11 = serverTimeNow
			setNightDecoration(AreaEggCycle.IsNightPhase(serverTimeNow)) -- equivalent call inferred; original call site unknown
			local v14 = false

			for _, v15 in pairs(v3) do
				local v16 = v6[v15.Uid] == true
				local uid = v15.Uid
				local record = v15.Record
				local serverTimeNow2 = Workspace:GetServerTimeNow()
				local v17 = EggRecords.GrowthAlpha(
					record,
					serverTimeNow2,
					record.GrowthSpeedMultiplier,
					EggRecords.CurrentNightCredit(record, serverTimeNow2, record.GrowthSpeedMultiplier),
					localPlayer
				) >= 1

				if v17 and not v6[uid] then
					v6[uid] = true

					if not (screenGui.Enabled or v8[uid]) then
						v8[uid] = true
						v10 += 1
						local v18 = readyNotification
						local v19 = textLabel2
						local v20 = shadow2
						local v21 = v10

						if v18 ~= nil and v19 ~= nil and v20 ~= nil then
							local visible = v21 > 0
							v18.Visible = visible

							if visible then
								local text = tostring(v21)
								v19.Text = text
								v20.Text = text
							end
						end
					end
				elseif not v17 and v6[uid] then
					v6[uid] = nil

					if v8[uid] then
						v8[uid] = nil
						v10 = math.max(v10 - 1, 0)
						local v18 = readyNotification
						local v19 = textLabel2
						local v20 = shadow2
						local v21 = v10

						if v18 ~= nil and v19 ~= nil and v20 ~= nil then
							local visible = v21 > 0
							v18.Visible = visible

							if visible then
								local text = tostring(v21)
								v19.Text = text
								v20.Text = text
							end
						end
					end
				end

				v14 = v17 ~= v16 or v14
				updateRow(v15)
			end

			if v14 then
				relayoutRows()
			else
				linkRows()
			end
		end

		v.Visible = false
		setOpen(false, true) -- equivalent call inferred; original call site unknown
		local v14 = v9

		if notification ~= nil and textLabel ~= nil and shadow ~= nil then
			local visible = v14 > 0
			notification.Visible = visible

			if visible then
				local text = tostring(v14)
				textLabel.Text = text
				shadow.Text = text
			end
		end

		local v15 = v10

		if readyNotification ~= nil and textLabel2 ~= nil and shadow2 ~= nil then
			local visible = v15 > 0
			readyNotification.Visible = visible

			if visible then
				local text = tostring(v15)
				textLabel2.Text = text
				shadow2.Text = text
			end
		end

		setNightDecoration(AreaEggCycle.IsNightPhase(Workspace:GetServerTimeNow())) -- equivalent call inferred; original call site unknown
		refreshRows(false, true)

		for _, v16 in every do
			GUI.OnActivated(v16, function()
				setOpen(true, nil) -- equivalent call inferred; original call site unknown
				v9 = 0
				table.clear(v7)
				local v17 = notification
				local v18 = textLabel
				local v19 = shadow
				local v20 = v9

				if v17 ~= nil and v18 ~= nil and v19 ~= nil then
					local visible = v20 > 0
					v17.Visible = visible

					if visible then
						local text = tostring(v20)
						v18.Text = text
						v19.Text = text
					end
				end

				v10 = 0
				table.clear(v8)
				local v21 = readyNotification
				local v22 = textLabel2
				local v23 = shadow2
				local v24 = v10

				if v21 ~= nil and v22 ~= nil and v23 ~= nil then
					local visible = v24 > 0
					v21.Visible = visible

					if visible then
						local text = tostring(v24)
						v22.Text = text
						v23.Text = text
					end
				end

				refreshRows(true, true)
			end)
			ButtonFX(v16, 1.08)
		end

		GUI.OnActivated(close, function()
			setOpen(false, nil) -- equivalent call inferred; original call site unknown
		end)
		ButtonFX(close, 1.08)
		GUI.OnActivated(growAll, requestGrowAll)
		ButtonFX(growAll, 1.08)
		EggState.SnapshotRefreshed:Connect(function()
			refreshRows(true, true)
		end)
		EggState.OwnerRefreshed:Connect(function(p: number)
			if p == localPlayer.UserId then
				refreshRows(true, true)
			end
		end)
		EggState.OwnerCleared:Connect(function(p: number)
			if p ~= localPlayer.UserId then
				return
			end

			for k in pairs(v3) do
				destroyRow(k)
			end

			table.clear(v4)
			table.clear(v5)
			table.clear(v6)
			v9 = 0
			table.clear(v7)
			local v16 = notification
			local v17 = textLabel
			local v18 = shadow
			local v19 = v9

			if v16 ~= nil and v17 ~= nil and v18 ~= nil then
				local visible = v19 > 0
				v16.Visible = visible

				if visible then
					local text = tostring(v19)
					v17.Text = text
					v18.Text = text
				end
			end

			clearReadyNotification() -- equivalent call inferred; original call site unknown
		end)
		PlacedEggRenderer.LocalEggHatchStarted:Connect(removeHatchingRow)
		RunService.Heartbeat:Connect(updateVisibleRows)
	end
}