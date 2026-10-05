local Floor0VotingController = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameContext = require(ReplicatedStorage.Modules.Core.GameContext)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

-- equivalent calls inferred from this helper; original call sites unknown
local function isGamepadPreferred()
	return UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
end

local v = nil

function Floor0VotingController.init(options)
	v = options or {}
end

function Floor0VotingController.setReadyUpButton(readyUpButton)
	v.readyUpButton = readyUpButton
end

function Floor0VotingController.setRoundTimer(roundTimer)
	v.roundTimer = roundTimer
end

function Floor0VotingController.setQuickLinks(quickLinks)
	v.quickLinks = quickLinks
end

local function findTeamFrame()
	local gui = GameContext.Gui
	local margin = gui.SelectionFrame:FindFirstChild("Margin")
	local teamFrame = margin and margin:FindFirstChild("TeamFrame")

	if teamFrame then
		return teamFrame
	end

	if v.quickLinks then
		local teamFrame2 = v.quickLinks:FindFirstChild("TeamFrame")

		if teamFrame2 and teamFrame2.Value then
			return teamFrame2.Value
		end
	end

	return gui.SelectionFrame:FindFirstChild("TeamFrame")
end

function Floor0VotingController.updateReadyButtonWithTimer()
	local readyUpButton = v.readyUpButton

	if not (readyUpButton and readyUpButton) then
		return
	end

	local title = readyUpButton:FindFirstChild("Title") or readyUpButton
	local count = 0

	for _, playerReadyState in pairs(GameContext.playerReadyStates) do
		if playerReadyState then
			count += 1
		end
	end

	local count2 = #Players:GetPlayers()
	local _ = v.roundTimer
	readyUpButton:FindFirstChild("Background")

	if GameContext.localPlayerReady then
		title.Text = "Ready! ✓ (" .. count .. "/" .. count2 .. ")"
	else
		title.Text = "Ready Up! (" .. count .. "/" .. count2 .. ")"
	end

	if title == readyUpButton then
		readyUpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		title.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
end

function Floor0VotingController.updateReadyButtonVisualSimple()
	local readyUpButton = v.readyUpButton
	local value = readyUpButton and readyUpButton.Value and readyUpButton.Value

	if value then
		local title = value:FindFirstChild("Title") or value
		local background = value:FindFirstChild("Background")

		if GameContext.localPlayerReady then
			title.Text = "READY! ✓"

			if background then
				background.ImageColor3 = Color3.fromRGB(0, 200, 0)
			else
				value.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
			end
		else
			title.Text = "READY UP"

			if background then
				background.ImageColor3 = Color3.fromRGB(0, 150, 0)
			else
				value.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
			end
		end

		if title == value then
			value.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			title.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end
end

function Floor0VotingController.updateReadyCheckmarks()
	local teamFrame = findTeamFrame()

	if teamFrame then
		for _, guiObject in pairs(teamFrame:GetChildren()) do
			if not (guiObject:IsA("GuiObject") and guiObject.Name ~= "Template" and guiObject.Name ~= "TeamTemplate") then
				continue
			end

			local readyText = guiObject:FindFirstChild("ReadyText")
			local visible = GameContext.playerReadyStates[guiObject.Name] == true

			if not readyText then
				continue
			end

			readyText.Visible = visible

			if v.floor0Shop and v.floor0Shop.UpdateTeamFrameReady then
				v.floor0Shop.UpdateTeamFrameReady(guiObject, visible)
			end
		end
	end

	Floor0VotingController.updateReadyButtonWithTimer()
end

function Floor0VotingController.setPlayerReady(p, localPlayerReady)
	GameContext.playerReadyStates[p] = localPlayerReady
	Floor0VotingController.updateReadyCheckmarks()

	if p == GameContext.Player.Name then
		GameContext.localPlayerReady = localPlayerReady
	end
end

function Floor0VotingController.updateTeamFloor0Inventory(childName, childName2)
	local teamFrame = findTeamFrame()

	if not teamFrame then
		return
	end

	local child = teamFrame:FindFirstChild(childName)

	if not child then
		return
	end

	local purchasedItems = child:FindFirstChild("PurchasedItems")

	if not purchasedItems then
		return
	end

	for i = 1, 3 do
		local child2 = purchasedItems:FindFirstChild("BoughtItem_" .. i)

		if not child2 then
			continue
		end

		local itemImage = child2:FindFirstChild("ItemImage")

		if not (itemImage and (not itemImage.Visible or itemImage.Image == "")) then
			continue
		end

		local child3 = ReplicatedStorage.ItemModules:FindFirstChild(childName2)

		if not child3 then
			continue
		end

		local success, result = pcall(require, child3)

		if not (success and result) then
			continue
		end

		itemImage.Image = result.Icon
		itemImage.Visible = true
		itemImage.Parent.Visible = true
		itemImage:SetAttribute("OriginalImage", result.Icon)
		itemImage:SetAttribute("IsPurchasedItem", true)
		local parent = itemImage.Parent.Parent

		if parent and not parent.Visible then
			parent.Visible = true
		end

		local parent2 = itemImage.Parent

		if parent2 and not parent2.Visible then
			parent2.Visible = true
			break
		else
			break
		end
	end
end

function Floor0VotingController.setupEventListeners()
	local floor0PurchaseUpdate = ReplicatedStorage.Events:FindFirstChild("Floor0PurchaseUpdate")

	if floor0PurchaseUpdate then
		floor0PurchaseUpdate.OnClientEvent:Connect(function(p, p2)
			Floor0VotingController.updateTeamFloor0Inventory(p, p2)
		end)
	end

	local readyStateUpdate = ReplicatedStorage.Events:FindFirstChild("ReadyStateUpdate")

	if readyStateUpdate then
		readyStateUpdate.OnClientEvent:Connect(function(p, p2)
			Floor0VotingController.setPlayerReady(p, p2)
		end)
	end
end

local function hideTeamReadyVisuals()
	local teamFrame = findTeamFrame()

	if not teamFrame then
		return
	end

	for _, guiObject in pairs(teamFrame:GetChildren()) do
		if not (guiObject:IsA("GuiObject") and guiObject.Name ~= "Template" and guiObject.Name ~= "TeamTemplate") then
			continue
		end

		local readyCheckmark = guiObject:FindFirstChild("ReadyCheckmark")
		local readyText = guiObject:FindFirstChild("ReadyText")

		if readyCheckmark then
			readyCheckmark.Visible = false
		end

		if readyText then
			readyText.Visible = false
		end
	end
end

function Floor0VotingController.setupVotingConnection()
	local gui = GameContext.Gui
	workspace.Info.Voting.Changed:Connect(function()
		if workspace.Info.Voting.Value == true then
			gui.SelectionFrame.Visible = true

			if GameContext.resetToonCatalog then
				GameContext.resetToonCatalog()
			end

			if GameContext.resetTrinketCatalog then
				GameContext.resetTrinketCatalog()
			end

			Floor0VotingController.setupEssentialConnections()
			task.spawn(function()
				task.wait()
				local floor0ShopApi = GameContext.floor0ShopApi

				if floor0ShopApi and floor0ShopApi.setupFloor0Shop then
					floor0ShopApi.setupFloor0Shop()
				end
			end)
			task.spawn(function()
				task.wait(0.1)

				if GameContext.ensureToonCatalogPopulated then
					GameContext.ensureToonCatalogPopulated()
				end

				if GameContext.ensureTrinketCatalogPopulated then
					GameContext.ensureTrinketCatalogPopulated()
				end
			end)
			GameContext.playerReadyStates = {}
			GameContext.localPlayerReady = false
			task.spawn(function()
				task.wait(0.2)
				hideTeamReadyVisuals()
			end)
			Floor0VotingController.updateReadyCheckmarks()

			if GameContext.setupCatalogSearchListeners then
				GameContext.setupCatalogSearchListeners()
			end
		else
			gui.SelectionFrame.Visible = false
			GuiService.SelectedObject = nil
			local floor0ShopApi = GameContext.floor0ShopApi

			if floor0ShopApi and floor0ShopApi.hideFloor0Shop then
				floor0ShopApi.hideFloor0Shop()
			end

			GameContext.playerReadyStates = {}
			GameContext.localPlayerReady = false
			hideTeamReadyVisuals()
			Floor0VotingController.updateReadyCheckmarks()
		end
	end)
end

function Floor0VotingController.setupFloor0Shop(data)
	local gui = GameContext.Gui
	local player = GameContext.Player
	local v2 = {
		setupCountdownTimer = function(gameStarting)
			if not gameStarting then
				local margin = gui.SelectionFrame:FindFirstChild("Margin")
				local bottomFrame = margin and margin:FindFirstChild("BottomFrame")
				local readyStatus = bottomFrame and bottomFrame:FindFirstChild("ReadyStatus")
				gameStarting = readyStatus and readyStatus:FindFirstChild("GameStarting")

				if not gameStarting then
					warn("[Floor0VotingController] Timer label not found in new UI structure")
					return
				end
			end

			gameStarting.Text = workspace.Info.Voting.Value == true and "Round starting in..." or "--"
		end
	}

	function v2.setupFloor0Shop()
		data.Floor0ShopClient.setupShop(gui, data.TextMessage, data.ErrorMessage, function()
			Audio:PlayOne("Sounds.UI.Buttons.Click")
		end)
		local readyUpButton = v.readyUpButton

		if readyUpButton then
			Floor0VotingController.updateReadyButtonWithTimer()

			if data.GuiAnimations then
				data.GuiAnimations.SetupButtonAnimationsSimple(readyUpButton)
			end

			local flag = false
			readyUpButton.Activated:Connect(function()
				if flag then
					return
				end

				flag = true
				local readyUpEvent = ReplicatedStorage.Events:FindFirstChild("ReadyUpEvent")

				if readyUpEvent then
					if GameContext.localPlayerReady then
						readyUpEvent:FireServer("UnReady")
						Floor0VotingController.setPlayerReady(player.Name, false)
					else
						readyUpEvent:FireServer("ReadyUp")
						Floor0VotingController.setPlayerReady(player.Name, true)
					end

					Floor0VotingController.updateReadyButtonWithTimer()
					Audio:PlayOne("Sounds.UI.Buttons.Click")
				end

				task.wait(1)
				flag = false
			end)
		end

		if v.roundTimer then
			v2.setupCountdownTimer(v.roundTimer)
		end
	end

	function v2.hideFloor0Shop()
		data.Floor0ShopClient.hideShop(gui)

		if data.ClearTextMessages then
			data.ClearTextMessages()
		end
	end

	return v2
end

function Floor0VotingController.setupReadyStateListeners()
	local readyStateUpdate = ReplicatedStorage.Events:FindFirstChild("ReadyStateUpdate")

	if readyStateUpdate then
		readyStateUpdate.OnClientEvent:Connect(function(p, p2)
			Floor0VotingController.setPlayerReady(p, p2)
		end)
	end

	local function checkReadyUpPlayers()
		local readyUpPlayers = workspace.Info:WaitForChild("ReadyUpPlayers")

		for _, boolValue in pairs(readyUpPlayers:GetChildren()) do
			if boolValue:IsA("BoolValue") then
				Floor0VotingController.setPlayerReady(boolValue.Name, true)
			end
		end

		readyUpPlayers.ChildAdded:Connect(function(boolValue)
			if boolValue:IsA("BoolValue") then
				Floor0VotingController.setPlayerReady(boolValue.Name, true)
			end
		end)
		readyUpPlayers.ChildRemoved:Connect(function(boolValue)
			if boolValue:IsA("BoolValue") then
				Floor0VotingController.setPlayerReady(boolValue.Name, false)
			end
		end)
	end

	task.spawn(checkReadyUpPlayers)
end

function Floor0VotingController.setupEssentialConnections()
	local gui = GameContext.Gui
	local player = GameContext.Player
	local margin = gui.SelectionFrame:FindFirstChild("Margin")

	if not margin then
		return
	end

	local catalogFrame = margin:FindFirstChild("CatalogFrame")
	local bottomFrame = margin:FindFirstChild("BottomFrame")

	if catalogFrame then
		local toons = catalogFrame:FindFirstChild("Toons")
		local trinkets = catalogFrame:FindFirstChild("Trinkets")
		GuiService.SelectedObject = isGamepadPreferred() and toons or nil

		if toons then
			local toTrinkets = toons:FindFirstChild("ToTrinkets")

			if toTrinkets then
				toTrinkets.Activated:Connect(function()
					if toons then
						toons.Visible = false
					end

					if trinkets then
						trinkets.Visible = true
						local previewPane = trinkets and trinkets:FindFirstChild("PreviewPane")
						local equip = previewPane and previewPane:FindFirstChild("Equip")
						v.readyUpButton.NextSelectionUp = equip

						if GameContext.ensureTrinketCatalogPopulated then
							GameContext.ensureTrinketCatalogPopulated()
						end

						if GameContext.Update_Stats then
							GameContext.Update_Stats()
						end

						if GameContext.Update_Slots then
							GameContext.Update_Slots()
						end
					end
				end)
			end

			local previewPane = toons:FindFirstChild("PreviewPane")

			if previewPane then
				if not previewPane.Abilities.Ability1:GetAttribute("Loaded") then
					previewPane.Abilities.Ability1:SetAttribute("Loaded", true)
					previewPane.Abilities.Ability1.Expand.Activated:Connect(function()
						gui.AbilityDetails.Visible = true
						GuiService.SelectedObject = isGamepadPreferred() and gui.AbilityDetails.Exit or nil
					end)
					gui.AbilityDetails.Exit.Activated:Connect(function()
						gui.AbilityDetails.Visible = false
						local abilities = previewPane and previewPane:FindFirstChild("Abilities")
						local ability1 = abilities and abilities:FindFirstChild("Ability1")
						local expand = ability1 and ability1:FindFirstChild("Expand") or previewPane
						GuiService.SelectedObject = isGamepadPreferred() and expand or nil
					end)
				end

				if not previewPane.Abilities.Ability2:GetAttribute("Loaded") then
					previewPane.Abilities.Ability2:SetAttribute("Loaded", true)
					previewPane.Abilities.Ability2.Expand.Activated:Connect(function()
						gui.AbilityDetails.Visible = true
						GuiService.SelectedObject = isGamepadPreferred() and gui.AbilityDetails.Exit or nil
					end)
				end
			end
		end

		local toToons = trinkets and trinkets:FindFirstChild("ToToons")

		if toToons then
			toToons.Activated:Connect(function()
				if trinkets then
					trinkets.Visible = false
				end

				if toons then
					toons.Visible = true
					local previewPane = toons and toons:FindFirstChild("PreviewPane")
					local equip = previewPane and previewPane:FindFirstChild("Equip")
					v.readyUpButton.NextSelectionUp = equip

					if GameContext.ensureToonCatalogPopulated then
						GameContext.ensureToonCatalogPopulated()
					end
				end
			end)
		end

		if trinkets then
			local previewPane = trinkets:FindFirstChild("PreviewPane")
			local loadouts = previewPane and previewPane:FindFirstChild("Loadouts")

			if loadouts then
				if loadouts:GetAttribute("LoadoutConnectionMade") then
					return
				end

				loadouts:SetAttribute("LoadoutConnectionMade", true)
				local flag = false
				loadouts.Activated:Connect(function()
					if flag then
						return
					end

					flag = true
					task.spawn(function()
						task.wait(0.2)
						flag = false
					end)
					local dropdown = loadouts:FindFirstChild("Dropdown")

					if dropdown then
						dropdown.Visible = not dropdown.Visible
					end

					local abilities = dropdown and dropdown.Visible and (dropdown:FindFirstChild("Abilities") or dropdown:FindFirstChild("LoadoutContainer") or dropdown:FindFirstChild("Loadouts") or dropdown)

					if abilities then
						local children = {}
						local child = abilities:FindFirstChild("Loadout" .. 1)

						if child then
							children[1] = child
						end

						local child2 = abilities:FindFirstChild("Loadout" .. 2)

						if child2 then
							children[2] = child2
						end

						local child3 = abilities:FindFirstChild("Loadout" .. 3)

						if child3 then
							children[3] = child3
						end

						for i = 1, 3 do
							local button = children[i]

							if not button then
								continue
							end

							button.LayoutOrder = i
							local title = button:FindFirstChild("Title")

							if title then
								title.Text = "Loadout " .. i
							end

							local trinkets2 = button:FindFirstChild("Trinkets")
							local child4 = trinkets2 and game.ReplicatedStorage.PlayerData:FindFirstChild((tostring(player.UserId)))

							if child4 then
								local attribute = child4:GetAttribute("Loadout" .. i .. "_Slot_1") or ""
								local attribute2 = child4:GetAttribute("Loadout" .. i .. "_Slot_2") or ""
								local trinket1 = trinkets2:FindFirstChild("Trinket1")

								if trinket1 then
									local titleWithDrop = trinket1:FindFirstChild("TitleWithDrop")
									local itemImage = trinket1:FindFirstChild("ItemImage")

									if attribute == "" or attribute == "None" then
										if titleWithDrop and GameContext.updateTextWithDropSupport then
											GameContext.updateTextWithDropSupport(titleWithDrop, "Empty")
											local titleTop = titleWithDrop:FindFirstChild("TitleTop")

											if titleTop then
												GameContext.updateTextWithDropSupport(titleTop, "Empty")
											end
										end

										if itemImage then
											itemImage.Visible = false
										end
									else
										local child5 = ReplicatedStorage.TrinketData:FindFirstChild(attribute)

										if child5 then
											local module = require(child5)

											if titleWithDrop and GameContext.updateTextWithDropSupport then
												GameContext.updateTextWithDropSupport(titleWithDrop, module.Name)
												local titleTop = titleWithDrop:FindFirstChild("TitleTop")

												if titleTop then
													GameContext.updateTextWithDropSupport(titleTop, module.Name)
												end
											end

											if itemImage then
												itemImage.Image = module.Icon
												itemImage.Visible = true
											end
										end
									end
								end

								local trinket2 = trinkets2:FindFirstChild("Trinket2")

								if trinket2 then
									local titleWithDrop = trinket2:FindFirstChild("TitleWithDrop")
									local itemImage = trinket2:FindFirstChild("ItemImage")

									if attribute2 == "" or attribute2 == "None" then
										if titleWithDrop and GameContext.updateTextWithDropSupport then
											GameContext.updateTextWithDropSupport(titleWithDrop, "Empty")
											local titleTop = titleWithDrop:FindFirstChild("TitleTop")

											if titleTop then
												GameContext.updateTextWithDropSupport(titleTop, "Empty")
											end
										end

										if itemImage then
											itemImage.Visible = false
										end
									else
										local child5 = ReplicatedStorage.TrinketData:FindFirstChild(attribute2)

										if child5 then
											local module = require(child5)

											if titleWithDrop and GameContext.updateTextWithDropSupport then
												GameContext.updateTextWithDropSupport(titleWithDrop, module.Name)
												local titleTop = titleWithDrop:FindFirstChild("TitleTop")

												if titleTop then
													GameContext.updateTextWithDropSupport(titleTop, module.Name)
												end
											end

											if itemImage then
												itemImage.Image = module.Icon
												itemImage.Visible = true
											end
										end
									end
								end
							end

							if button:GetAttribute("LoadoutConnected" .. i) then
								continue
							end

							button:SetAttribute("LoadoutConnected" .. i, true)

							if not (button:IsA("TextButton") or button:IsA("ImageButton")) then
								for _, button2 in pairs(button:GetDescendants()) do
									if not (button2:IsA("TextButton") or button2:IsA("ImageButton")) then
										continue
									end

									button = button2
									break
								end
							end

							if not (button:IsA("TextButton") or button:IsA("ImageButton")) then
								continue
							end

							local v2 = i
							button.Activated:Connect(function()
								if game.ReplicatedStorage.EquipTrinketLoadout:InvokeServer("Slot" .. v2) then
									if GameContext.TextMessage then
										GameContext.TextMessage("Loadout " .. v2 .. " equipped!")
									end

									if GameContext.Update_Stats then
										GameContext.Update_Stats()
									end

									if GameContext.Update_Slots then
										GameContext.Update_Slots()
									end

									local v3 = GameContext.getCurrentlySelectedTrinket and GameContext.getCurrentlySelectedTrinket() or nil

									if v3 then
										local margin2 = gui.SelectionFrame:FindFirstChild("Margin")
										local catalogFrame2 = margin2 and margin2:FindFirstChild("CatalogFrame")
										local trinkets3 = catalogFrame2 and catalogFrame2:FindFirstChild("Trinkets")
										local previewPane2 = trinkets3 and trinkets3:FindFirstChild("PreviewPane")
										local equip = previewPane2 and previewPane2:FindFirstChild("Equip")

										if equip then
											local child5 = game.ReplicatedStorage.PlayerData:FindFirstChild((tostring(player.UserId)))
											local equippedTrinket1 = child5 and child5:FindFirstChild("EquippedTrinket1")
											local equippedTrinket2 = child5 and child5:FindFirstChild("EquippedTrinket2")
											local v4 = equippedTrinket1 and equippedTrinket1.Value == v3 and true or equippedTrinket2 and equippedTrinket2.Value == v3
											local v5 = nil

											for i2, label in pairs(equip:GetDescendants()) do
												if not label:IsA("TextLabel") then
													continue
												end

												v5 = label
												break
											end

											if not v5 and equip:IsA("TextButton") then
												v5 = equip
											end

											if v5 then
												v5.Text = v4 and "Unequip" or "Equip"
											end
										end
									end

									dropdown.Visible = false
								elseif GameContext.ErrorMessage then
									GameContext.ErrorMessage("Failed to equip loadout " .. v2)
								end
							end)
						end
					end

					task.wait(0.1)
					flag = false
				end)
			end
		end
	end

	local readyStatus = bottomFrame and not v.readyUpButton and bottomFrame:FindFirstChild("ReadyStatus")

	if readyStatus then
		v.readyUpButton = readyStatus:FindFirstChild("ReadyUp")
		v.roundTimer = readyStatus:FindFirstChild("GameStarting")
	end
end

return Floor0VotingController