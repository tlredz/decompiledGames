game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameContext = require(ReplicatedStorage.Modules.Core.GameContext)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

local function refreshEquipButtonText(value)
	local gui = GameContext.Gui
	local player = GameContext.Player

	if (GameContext.getCurrentlySelectedTrinket and GameContext.getCurrentlySelectedTrinket()) ~= value then
		return
	end

	local margin = gui.SelectionFrame:FindFirstChild("Margin")
	local catalogFrame = margin and margin:FindFirstChild("CatalogFrame")
	local trinkets = catalogFrame and catalogFrame:FindFirstChild("Trinkets")
	local previewPane = trinkets and trinkets:FindFirstChild("PreviewPane")
	local equip = previewPane and previewPane:FindFirstChild("Equip")

	if not equip then
		return
	end

	local child = ReplicatedStorage.PlayerData:FindFirstChild((tostring(player.UserId)))
	local equippedTrinket1 = child and child:FindFirstChild("EquippedTrinket1")
	local equippedTrinket2 = child and child:FindFirstChild("EquippedTrinket2")
	local v = equippedTrinket1 and equippedTrinket1.Value == value and true or equippedTrinket2 and equippedTrinket2.Value == value
	local v2 = nil

	for _, label in pairs(equip:GetDescendants()) do
		if not label:IsA("TextLabel") then
			continue
		end

		v2 = label
		break
	end

	if not v2 and equip:IsA("TextButton") then
		v2 = equip
	end

	if v2 then
		v2.Text = v and "Unequip" or "Equip"
	end
end

local function handleUnequip(instance, p, p2)
	local player = GameContext.Player
	p.Activated:Connect(function()
		local itemImage = instance:FindFirstChild("ItemImage")

		if not itemImage or itemImage.Image == "" then
			return
		end

		local child = ReplicatedStorage.PlayerData:FindFirstChild((tostring(player.UserId)))

		if not child then
			return
		end

		local child2 = child:FindFirstChild("EquippedTrinket" .. p2)

		if not child2 or not child2.Value or child2.Value == "None" or child2.Value == "" then
			return
		end

		local value = child2.Value

		if not ReplicatedStorage.EquipTrinket:InvokeServer(value, "UnEquip") then
			return
		end

		Audio:PlayOne("Sounds.UI.Buttons.Click")

		if GameContext.TextMessage then
			GameContext.TextMessage("Unequipped " .. value)
		end

		refreshEquipButtonText(value)

		if GameContext.Update_Stats then
			GameContext.Update_Stats()
		end

		if GameContext.Update_Slots then
			GameContext.Update_Slots()
		end
	end)
end

return {
	setupAll = function()
		local player = GameContext.Player
		local character = GameContext.Character
		local selectionFrame = player.PlayerGui:WaitForChild("ScreenGui").SelectionFrame
		local margin = selectionFrame:FindFirstChild("Margin")
		local catalogFrame = margin and margin:FindFirstChild("CatalogFrame")
		local trinkets = catalogFrame and catalogFrame:FindFirstChild("Trinkets")
		local previewPane = trinkets and trinkets:FindFirstChild("PreviewPane")
		local equipped = previewPane and previewPane:FindFirstChild("Equipped")
		local equippedTrinkets = equipped and equipped:FindFirstChild("EquippedTrinkets")

		if not equippedTrinkets then
			warn("[TrinketSlotController] EquippedTrinkets not found in UI hierarchy")
			return
		end

		local equippedTrinket1 = equippedTrinkets:FindFirstChild("EquippedTrinket1")
		local equippedTrinket2 = equippedTrinkets:FindFirstChild("EquippedTrinket2")

		if not (equippedTrinket1 and equippedTrinket2) then
			warn("[TrinketSlotController] Equipped trinket frames not found")
			return
		end

		local equipped2 = equippedTrinket1:FindFirstChild("Equipped")
		local equipped3 = equippedTrinket2:FindFirstChild("Equipped")

		if not (equipped2 and equipped3) then
			warn("[TrinketSlotController] Exit buttons not found in trinket slots")
			return
		end

		equipped2.Visible = false
		equipped3.Visible = false
		local visibleChangedConnection = selectionFrame:GetPropertyChangedSignal("Visible"):Connect(function()
			if selectionFrame.Visible then
				local itemImage = equippedTrinket1:FindFirstChild("ItemImage")
				local itemImage2 = equippedTrinket2:FindFirstChild("ItemImage")
				local v = equipped2

				if itemImage then
					if itemImage.Image == "" then
						itemImage = false
					else
						itemImage = itemImage.Visible
					end
				end

				v.Visible = itemImage
				local v2 = equipped3

				if itemImage2 then
					if itemImage2.Image == "" then
						itemImage2 = false
					else
						itemImage2 = itemImage2.Visible
					end
				end

				v2.Visible = itemImage2
			else
				equipped2.Visible = false
				equipped3.Visible = false
			end
		end)
		local itemImage = equippedTrinket1:FindFirstChild("ItemImage")
		local itemImage2 = equippedTrinket2:FindFirstChild("ItemImage")
		local imageChangedConnection = nil
		local visibleChangedConnection2 = nil
		local imageChangedConnection2, visibleChangedConnection3

		if itemImage then
			imageChangedConnection2 = itemImage:GetPropertyChangedSignal("Image"):Connect(function()
				if selectionFrame.Visible then
					equipped2.Visible = itemImage.Image ~= "" and itemImage.Visible
				end
			end)
			visibleChangedConnection3 = itemImage:GetPropertyChangedSignal("Visible"):Connect(function()
				if selectionFrame.Visible then
					equipped2.Visible = itemImage.Image ~= "" and itemImage.Visible
				end
			end)
		else
			imageChangedConnection2 = nil
			visibleChangedConnection3 = nil
		end

		if itemImage2 then
			imageChangedConnection = itemImage2:GetPropertyChangedSignal("Image"):Connect(function()
				if selectionFrame.Visible then
					equipped3.Visible = itemImage2.Image ~= "" and itemImage2.Visible
				end
			end)
			visibleChangedConnection2 = itemImage2:GetPropertyChangedSignal("Visible"):Connect(function()
				if selectionFrame.Visible then
					equipped3.Visible = itemImage2.Image ~= "" and itemImage2.Visible
				end
			end)
		end

		local player2 = GameContext.Player
		local v = 1
		equipped2.Activated:Connect(function()
			local itemImage3 = equippedTrinket1:FindFirstChild("ItemImage")

			if not itemImage3 or itemImage3.Image == "" then
				return
			end

			local child = ReplicatedStorage.PlayerData:FindFirstChild((tostring(player2.UserId)))

			if not child then
				return
			end

			local child2 = child:FindFirstChild("EquippedTrinket" .. v)

			if not child2 or not child2.Value or child2.Value == "None" or child2.Value == "" then
				return
			end

			local value = child2.Value

			if not ReplicatedStorage.EquipTrinket:InvokeServer(value, "UnEquip") then
				return
			end

			Audio:PlayOne("Sounds.UI.Buttons.Click")

			if GameContext.TextMessage then
				GameContext.TextMessage("Unequipped " .. value)
			end

			refreshEquipButtonText(value)

			if GameContext.Update_Stats then
				GameContext.Update_Stats()
			end

			if GameContext.Update_Slots then
				GameContext.Update_Slots()
			end
		end)
		local player3 = GameContext.Player
		local v2 = 2
		equipped3.Activated:Connect(function()
			local itemImage3 = equippedTrinket2:FindFirstChild("ItemImage")

			if not itemImage3 or itemImage3.Image == "" then
				return
			end

			local child = ReplicatedStorage.PlayerData:FindFirstChild((tostring(player3.UserId)))

			if not child then
				return
			end

			local child2 = child:FindFirstChild("EquippedTrinket" .. v2)

			if not child2 or not child2.Value or child2.Value == "None" or child2.Value == "" then
				return
			end

			local value = child2.Value

			if not ReplicatedStorage.EquipTrinket:InvokeServer(value, "UnEquip") then
				return
			end

			Audio:PlayOne("Sounds.UI.Buttons.Click")

			if GameContext.TextMessage then
				GameContext.TextMessage("Unequipped " .. value)
			end

			refreshEquipButtonText(value)

			if GameContext.Update_Stats then
				GameContext.Update_Stats()
			end

			if GameContext.Update_Slots then
				GameContext.Update_Slots()
			end
		end)

		if character then
			character.AncestryChanged:Connect(function(_, parent)
				if parent == nil then
					visibleChangedConnection:Disconnect()

					if imageChangedConnection2 then
						imageChangedConnection2:Disconnect()
					end

					if visibleChangedConnection3 then
						visibleChangedConnection3:Disconnect()
					end

					if imageChangedConnection then
						imageChangedConnection:Disconnect()
					end

					if visibleChangedConnection2 then
						visibleChangedConnection2:Disconnect()
					end
				end
			end)
		end
	end
}