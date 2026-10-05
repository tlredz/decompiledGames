local TeamDisplayController = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local GameContext = require(ReplicatedStorage.Modules.Core.GameContext)
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local Floor0Shop = require(ReplicatedStorage.Modules.Floor0.Floor0Shop)
local v = nil

function TeamDisplayController.init(options)
	v = options or {}
end

function TeamDisplayController.setTeamFrameTemplate(teamFrameTemplate)
	v.teamFrameTemplate = teamFrameTemplate
end

function TeamDisplayController.setQuickLinks(quickLinks)
	v.quickLinks = quickLinks
end

local connectionsByName = {}
TeamDisplayController.teamFrameConnections = connectionsByName

function TeamDisplayController.setupAll()
	local gui = GameContext.Gui
	local player = GameContext.Player
	local teamFrameTemplate = v.teamFrameTemplate
	local quickLinks = v.quickLinks

	local function createTeamMemberFrame(childName, p)
		local tower = TowerLUT:GetTower(p)

		if not tower then
			warn("[GMM] Tower data not found for", p)
			return
		end

		local module = require(tower)
		local value = nil
		local uI_Elements = quickLinks and quickLinks:FindFirstChild("UI_Elements")

		if uI_Elements then
			local teamFrame = uI_Elements:FindFirstChild("TeamFrame")

			if teamFrame and teamFrame.Value then
				value = teamFrame.Value
			end
		end

		if not value then
			local margin = gui.SelectionFrame:FindFirstChild("Margin")

			if margin then
				value = margin:FindFirstChild("TeamFrame")
			end
		end

		local parent = value or gui.SelectionFrame:FindFirstChild("TeamFrame")

		if not parent then
			warn("[GMM] TeamFrame not found for player", childName)
			return
		end

		local clone

		if teamFrameTemplate then
			clone = teamFrameTemplate:Clone()
		else
			local teamTemplate = parent:FindFirstChild("TeamTemplate") or parent:FindFirstChild("Template")

			if teamTemplate then
				clone = teamTemplate:Clone()
			else
				warn("Template not found in TeamFrame")
				return
			end
		end

		clone.Parent = parent
		clone.Name = childName
		clone.Active = true
		local playerName = clone:FindFirstChild("PlayerName") or clone:FindFirstChild("Username")

		if playerName then
			playerName.Text = childName
		else
			for _, label in pairs(clone:GetChildren()) do
				if not label:IsA("TextLabel") then
					continue
				end

				if not (label.Name:lower():find("name") or label.Name:lower():find("user")) then
					continue
				end

				label.Text = childName
				break
			end
		end

		Floor0Shop.UpdateTeamFrameReady(clone, false)
		local characterName = clone:FindFirstChild("CharacterName")

		if characterName then
			characterName.Text = "Playing As: " .. module.Name
		end

		for _, frame in pairs(clone:GetChildren()) do
			if not frame:IsA("Frame") then
				continue
			end

			for _, guiObject in pairs(frame:GetChildren()) do
				if not guiObject:IsA("ImageLabel") then
					guiObject:IsA("ImageButton")
				end
			end
		end

		local v3 = nil

		for _, guiObject in pairs(clone:GetDescendants()) do
			if not (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) then
				continue
			end

			if not (guiObject.Name:lower():find("character") or guiObject.Name:lower():find("image") or guiObject.Name:lower():find("icon") or guiObject.Name:lower():find("toon") or guiObject.Name:lower():find("player")) then
				continue
			end

			v3 = guiObject
			break
		end

		if v3 then
			v3.Image = module.Icon or ""
			v3.ScaleType = Enum.ScaleType.Fit
		else
			warn("[GMM] No image element found in team frame template - NOT creating new one")
		end

		clone.Visible = true
		local readyCheckmark = clone:FindFirstChild("ReadyCheckmark")

		if readyCheckmark then
			readyCheckmark.Visible = GameContext.playerReadyStates[childName] == true
		end

		local trinketSlot1 = clone:FindFirstChild("TrinketSlot1")
		local trinketSlot2 = clone:FindFirstChild("TrinketSlot2")

		local function updatePlayerTrinkets()
			local child = ReplicatedStorage.PlayerData:FindFirstChild((tostring(game.Players:FindFirstChild(childName) and game.Players[childName].UserId or "")))

			if child then
				if trinketSlot1 and trinketSlot1.Name == "TrinketSlot1" then
					local equippedTrinket1 = child:FindFirstChild("EquippedTrinket1")

					if equippedTrinket1 and equippedTrinket1.Value ~= "None" then
						local child2 = ReplicatedStorage.TrinketData:FindFirstChild(equippedTrinket1.Value)

						if child2 then
							local module2 = require(child2)
							local itemImage = trinketSlot1:FindFirstChild("ItemImage")

							if itemImage and itemImage.Parent.Name == "TrinketSlot1" then
								itemImage.Image = module2.Icon
								itemImage.Visible = true
							end
						end
					else
						local itemImage = trinketSlot1:FindFirstChild("ItemImage")

						if itemImage and itemImage.Parent.Name == "TrinketSlot1" and not itemImage:GetAttribute("IsPurchasedItem") then
							itemImage.Visible = false
						end
					end
				end

				if trinketSlot2 and trinketSlot2.Name == "TrinketSlot2" then
					local equippedTrinket2 = child:FindFirstChild("EquippedTrinket2")

					if equippedTrinket2 and equippedTrinket2.Value ~= "None" then
						local child2 = ReplicatedStorage.TrinketData:FindFirstChild(equippedTrinket2.Value)

						if child2 then
							local module2 = require(child2)
							local itemImage = trinketSlot2:FindFirstChild("ItemImage")

							if itemImage and itemImage.Parent.Name == "TrinketSlot2" then
								itemImage.Image = module2.Icon
								itemImage.Visible = true
							end
						end
					else
						local itemImage = trinketSlot2:FindFirstChild("ItemImage")

						if itemImage and itemImage.Parent.Name == "TrinketSlot2" and not itemImage:GetAttribute("IsPurchasedItem") then
							itemImage.Visible = false
						end
					end
				end
			end
		end

		local purchasedItems = clone:FindFirstChild("PurchasedItems")

		if purchasedItems then
			local function updateFloor0Purchases()
				local floor0ShopFunction = ReplicatedStorage:FindFirstChild("Floor0ShopFunction")

				if floor0ShopFunction then
					local success, result = pcall(function()
						return floor0ShopFunction:InvokeServer("GetPurchases", childName)
					end)

					if success and result then
						if type(result) == "table" then
							for _, _ in pairs(result) do

							end
						end

						local flag = false

						if type(result) == "table" and result.purchases then
							for k, _ in pairs(result.purchases) do
								if not (type(k) == "string" and k ~= "success") then
									continue
								end

								flag = true
								break
							end
						end

						if flag then
							for i = 1, 3 do
								local child = purchasedItems:FindFirstChild("BoughtItem_" .. i)

								if not child then
									continue
								end

								local itemImage = child:FindFirstChild("ItemImage")

								if not itemImage then
									continue
								end

								itemImage.Visible = false
								itemImage.Image = ""
							end
						end

						if flag then
							local v5 = 1

							for childName2, _ in pairs(result.purchases) do
								if not (v5 <= 3) then
									continue
								end

								local child = purchasedItems:FindFirstChild("BoughtItem_" .. v5)
								local itemImage = child and child:FindFirstChild("ItemImage")

								if itemImage then
									local child2 = ReplicatedStorage.ItemModules:FindFirstChild(childName2)

									if child2 then
										local success2, result2 = pcall(require, child2)

										if success2 then
											itemImage.Image = result2.Icon
											itemImage.Visible = true
										end
									else
										local Floor0Shop2 = require(ReplicatedStorage.Modules.Floor0.Floor0Shop)
										local shopData = Floor0Shop2.GetShopData()

										if shopData[childName2] then
											itemImage.Image = shopData[childName2].icon
											itemImage.Visible = true
										end
									end
								end

								v5 += 1
							end
						end
					end
				end
			end

			updateFloor0Purchases()
			local floor0PurchaseUpdate = ReplicatedStorage.Events:FindFirstChild("Floor0PurchaseUpdate")

			if floor0PurchaseUpdate then
				floor0PurchaseUpdate.OnClientEvent:Connect(function(p2)
					if p2 == childName then
						updateFloor0Purchases()
					end
				end)
			end
		end

		updatePlayerTrinkets()
		task.spawn(function()
			while clone.Parent do
				task.wait(1)
				updatePlayerTrinkets()
			end
		end)
		return clone
	end

	local v2 = {}

	local function verifyAndSyncTeamFrames()
		local margin = gui.SelectionFrame:FindFirstChild("Margin")
		local v3

		if margin then
			v3 = margin:FindFirstChild("TeamFrame")
		end

		local v4 = v3 or gui.SelectionFrame:FindFirstChild("TeamFrame")

		if not v4 then
			return
		end

		local v5 = {}

		for _, stringValue in pairs(workspace.Info.PickedCharacters:GetChildren()) do
			if stringValue:IsA("StringValue") then
				v5[stringValue.Name] = stringValue.Value
			end
		end

		for childName, v6 in pairs(v5) do
			if v4:FindFirstChild(childName) then
				local child = v4:FindFirstChild(childName)

				if child then
					if childName == player.Name and child.LayoutOrder ~= 1 then
						child.LayoutOrder = 1
					end

					local tower = TowerLUT:GetTower(v6)

					if tower then
						local module = require(tower)
						local characterName = child:FindFirstChild("CharacterName")

						if characterName then
							local text = "Playing As: " .. module.Name

							if characterName.Text ~= text then
								characterName.Text = text
							end
						end

						local characterImage = child:FindFirstChild("CharacterImage") or child:FindFirstChild("PlayerImage")

						if characterImage and characterImage.Image ~= module.Icon then
							characterImage.Image = module.Icon
						end
					end
				end
			else
				local teamMemberFrame = createTeamMemberFrame(childName, v6)

				if teamMemberFrame then
					if childName == player.Name then
						teamMemberFrame.LayoutOrder = 1
					else
						local v7 = 1

						for _, guiObject in pairs(v4:GetChildren()) do
							if not (guiObject:IsA("GuiObject") and guiObject.Name ~= "Template" and guiObject.Name ~= "TeamTemplate" and guiObject.Name ~= player.Name) then
								continue
							end

							v7 += 1
						end

						teamMemberFrame.LayoutOrder = v7 + 1
					end

					if not v2[childName] then
						local child = workspace.Info.PickedCharacters:FindFirstChild(childName)

						if child then
							local v7 = teamMemberFrame
							v2[childName] = child.Changed:Connect(function(p)
								local tower = TowerLUT:GetTower(p)

								if tower then
									local module = require(tower)
									local characterName = v7:FindFirstChild("CharacterName")

									if characterName then
										characterName.Text = "Playing As: " .. module.Name
									end

									local characterImage = v7:FindFirstChild("CharacterImage") or v7:FindFirstChild("PlayerImage")

									if characterImage then
										characterImage.Image = module.Icon
									end
								end
							end)
						end
					end
				end
			end
		end

		for _, guiObject in pairs(v4:GetChildren()) do
			if not guiObject:IsA("GuiObject") or guiObject.Name == "Template" or guiObject.Name == "TeamTemplate" or v5[guiObject.Name] then
				continue
			end

			guiObject:Destroy()

			if not v2[guiObject.Name] then
				continue
			end

			v2[guiObject.Name]:Disconnect()
			v2[guiObject.Name] = nil
		end
	end

	workspace.Info.PickedCharacters.ChildAdded:Connect(function(stringValue)
		if stringValue:IsA("StringValue") then
			local margin = gui.SelectionFrame:FindFirstChild("Margin")
			local v3

			if margin then
				v3 = margin:FindFirstChild("TeamFrame")
			end

			local v4 = v3 or gui.SelectionFrame:FindFirstChild("TeamFrame")
			local v5 = v4 and not v4:FindFirstChild(stringValue.Name) and createTeamMemberFrame(
				stringValue.Name,
				stringValue.Value
			)

			if v5 then
				if stringValue.Name == player.Name then
					v5.LayoutOrder = 1
					task.defer(function()
						local success, result = pcall(verifyAndSyncTeamFrames)

						if not success then
							warn("[GMM] Team frame sync error after local player creation:", result)
						end
					end)
				else
					local v6 = 1

					for _, guiObject in pairs(v4:GetChildren()) do
						if not (guiObject:IsA("GuiObject") and guiObject.Name ~= "Template" and guiObject.Name ~= "TeamTemplate" and guiObject.Name ~= player.Name) then
							continue
						end

						v6 += 1
					end

					v5.LayoutOrder = v6 + 1
				end

				v2[stringValue.Name] = stringValue.Changed:Connect(function(p)
					local tower = TowerLUT:GetTower(p)

					if tower then
						local module = require(tower)
						local characterName = v5:FindFirstChild("CharacterName")

						if characterName then
							characterName.Text = "Playing As: " .. module.Name
						end

						local characterImage = v5:FindFirstChild("CharacterImage") or v5:FindFirstChild("PlayerImage")

						if characterImage then
							characterImage.Image = module.Icon
						end
					end

					task.defer(function()
						local success, result = pcall(verifyAndSyncTeamFrames)

						if not success then
							warn("[GMM] Team frame sync error after character change:", result)
						end
					end)
				end)
			end
		end
	end)
	Players.PlayerRemoving:Connect(function(player2)
		local margin = gui.SelectionFrame:FindFirstChild("Margin")
		local v3

		if margin then
			v3 = margin:FindFirstChild("TeamFrame")
		end

		local v4 = v3 or gui.SelectionFrame:FindFirstChild("TeamFrame")

		if v4 and v4:FindFirstChild(player2.Name) then
			v4:FindFirstChild(player2.Name):Destroy()
		end

		if v2[player2.Name] then
			v2[player2.Name]:Disconnect()
			v2[player2.Name] = nil
		end
	end)
	TeamDisplayController.createTeamMemberFrame = createTeamMemberFrame
end

local function resolveTeamFrame()
	local gui = GameContext.Gui
	local margin = gui.SelectionFrame:FindFirstChild("Margin")
	local teamFrame = margin and margin:FindFirstChild("TeamFrame")

	if teamFrame then
		return teamFrame
	end

	if v and v.quickLinks then
		local teamFrame2 = v.quickLinks:FindFirstChild("TeamFrame")

		if teamFrame2 and teamFrame2.Value then
			return teamFrame2.Value
		end
	end

	return gui.SelectionFrame:FindFirstChild("TeamFrame")
end

function TeamDisplayController.seedInitialFrames()
	local player = GameContext.Player
	local pickedCharacters = workspace.Info:FindFirstChild("PickedCharacters")

	if not pickedCharacters or #pickedCharacters:GetChildren() == 0 then
		return
	end

	local stringValues = {}
	local v2 = nil

	for _, stringValue in ipairs(pickedCharacters:GetChildren()) do
		if not stringValue:IsA("StringValue") then
			continue
		end

		if stringValue.Name == player.Name then
			v2 = stringValue
		else
			table.insert(stringValues, stringValue)
		end
	end

	local function seedOne(data, layoutOrder)
		local tower = TowerLUT:GetTower(data.Value)
		local teamFrame = resolveTeamFrame()

		if not tower or not teamFrame or teamFrame:FindFirstChild(data.Name) then
			return
		end

		local teamMemberFrame = TeamDisplayController.createTeamMemberFrame(data.Name, data.Value)

		if not teamMemberFrame then
			return
		end

		teamMemberFrame.LayoutOrder = layoutOrder

		if not connectionsByName[data.Name] then
			connectionsByName[data.Name] = data.Changed:Connect(function()
				local tower2 = TowerLUT:GetTower(data.Value)

				if not tower2 then
					return
				end

				local module = require(tower2)
				local characterName = teamMemberFrame:FindFirstChild("CharacterName")

				if characterName then
					characterName.Text = "Playing As: " .. module.Name
				end

				local characterImage = teamMemberFrame:FindFirstChild("CharacterImage") or teamMemberFrame:FindFirstChild("PlayerImage")

				if characterImage then
					characterImage.Image = module.Icon
				end
			end)
		end
	end

	local v3 = 1

	if v2 then
		seedOne(v2, v3)
		v3 = 2
	end

	for _, v4 in ipairs(stringValues) do
		seedOne(v4, v3)
		v3 += 1
	end
end

return TeamDisplayController