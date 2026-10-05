local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameContext = require(ReplicatedStorage.Modules.Core.GameContext)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local v = nil
local flag = false

local function safeAccess(value)
	local gui = GameContext.Gui

	for childName in string.gmatch(value, "[^%.]+") do
		if childName == "Gui" then
			gui = GameContext.Gui
		else
			gui = gui and gui:FindFirstChild(childName)
		end

		if not gui then
			return nil
		end
	end

	return gui
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getLoadoutFrame()
	return (safeAccess("Gui.SelectionFrame.TrinketsFrame.LoadoutSlotFrame"))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSlotButtonFrame(p)
	local loadoutFrame = getLoadoutFrame() -- equivalent call inferred; original call site unknown
	return loadoutFrame and loadoutFrame:FindFirstChild("SlotButtonFrame_" .. p)
end

local function updateSlotVisuals(p, attribute, attribute2)
	local slotButtonFrame = getSlotButtonFrame(p) -- equivalent call inferred; original call site unknown

	if not slotButtonFrame then
		return
	end

	local loadout_Slot = slotButtonFrame:FindFirstChild("Loadout_Slot")
	local slotVisualizationFrame = loadout_Slot and loadout_Slot:FindFirstChild("SlotVisualizationFrame")

	if not slotVisualizationFrame then
		return
	end

	local function applySlot(childName, childName2)
		local child = slotVisualizationFrame:FindFirstChild(childName)

		if not child then
			return
		end

		local itemImage = child:FindFirstChild("ItemImage")

		if not itemImage then
			return
		end

		if childName2 and childName2 ~= "" then
			local child2 = ReplicatedStorage.TrinketData:FindFirstChild(childName2)

			if child2 then
				local module = require(child2)
				itemImage.Image = module.Icon
				itemImage.Visible = true
			end
		else
			itemImage.Visible = false
		end
	end

	applySlot("Slot1", attribute)
	applySlot("Slot2", attribute2)
end

local function refreshEquipButtonText()
	local v2 = GameContext.getCurrentlySelectedTrinket and GameContext.getCurrentlySelectedTrinket()

	if not v2 then
		return
	end

	local margin = GameContext.Gui.SelectionFrame:FindFirstChild("Margin")
	local catalogFrame = margin and margin:FindFirstChild("CatalogFrame")
	local trinkets = catalogFrame and catalogFrame:FindFirstChild("Trinkets")
	local previewPane = trinkets and trinkets:FindFirstChild("PreviewPane")
	local equip = previewPane and previewPane:FindFirstChild("Equip")

	if not equip then
		return
	end

	local player = GameContext.Player
	local child = ReplicatedStorage.PlayerData:FindFirstChild((tostring(player.UserId)))
	local equippedTrinket1 = child and child:FindFirstChild("EquippedTrinket1")
	local equippedTrinket2 = child and child:FindFirstChild("EquippedTrinket2")
	local v3 = equippedTrinket1 and equippedTrinket1.Value == v2 and true or equippedTrinket2 and equippedTrinket2.Value == v2
	local v4 = nil

	for _, label in pairs(equip:GetDescendants()) do
		if not label:IsA("TextLabel") then
			continue
		end

		v4 = label
		break
	end

	if not v4 and equip:IsA("TextButton") then
		v4 = equip
	end

	if v4 then
		v4.Text = v3 and "Unequip" or "Equip"
	end
end

local function onLoadoutActivated(p)
	return function()
		if flag then
			return
		end

		flag = true
		local replicatedData = v.ReplicatedData
		local attribute = replicatedData:GetAttribute("Loadout" .. p .. "_Slot_1") or ""
		local attribute2 = replicatedData:GetAttribute("Loadout" .. p .. "_Slot_2") or ""

		if attribute == "" and attribute2 == "" then
			flag = false
			return
		end

		if ReplicatedStorage.EquipTrinketLoadout:InvokeServer("Slot" .. p) then
			Audio:PlayOne("Sounds.UI.TapePickup")

			if GameContext.Update_Slots then
				GameContext.Update_Slots()
			end

			if GameContext.Update_Stats then
				GameContext.Update_Stats()
			end

			if GameContext.TextMessage then
				GameContext.TextMessage("LOADOUT " .. p .. " EQUIPPED", true)
			end

			refreshEquipButtonText()
		elseif GameContext.ErrorMessage then
			GameContext.ErrorMessage("Failed to equip loadout!")
		end

		flag = false
	end
end

local function wireLoadoutActivated(p)
	local slotButtonFrame = getSlotButtonFrame(p) -- equivalent call inferred; original call site unknown
	local loadout_Slot = slotButtonFrame and slotButtonFrame:FindFirstChild("Loadout_Slot")

	if loadout_Slot then
		loadout_Slot.Activated:Connect(function()
			if flag then
				return
			end

			flag = true
			local replicatedData = v.ReplicatedData
			local attribute = replicatedData:GetAttribute("Loadout" .. p .. "_Slot_1") or ""
			local attribute2 = replicatedData:GetAttribute("Loadout" .. p .. "_Slot_2") or ""

			if attribute == "" and attribute2 == "" then
				flag = false
				return
			end

			if ReplicatedStorage.EquipTrinketLoadout:InvokeServer("Slot" .. p) then
				Audio:PlayOne("Sounds.UI.TapePickup")

				if GameContext.Update_Slots then
					GameContext.Update_Slots()
				end

				if GameContext.Update_Stats then
					GameContext.Update_Stats()
				end

				if GameContext.TextMessage then
					GameContext.TextMessage("LOADOUT " .. p .. " EQUIPPED", true)
				end

				refreshEquipButtonText()
			elseif GameContext.ErrorMessage then
				GameContext.ErrorMessage("Failed to equip loadout!")
			end

			flag = false
		end)
	end
end

return {
	init = function(p)
		v = p
		local replicatedData = v.ReplicatedData

		for i = 1, 3 do
			local attribute = replicatedData:GetAttribute("Loadout" .. i .. "_Slot_1") or ""
			local attribute2 = replicatedData:GetAttribute("Loadout" .. i .. "_Slot_2") or ""
			updateSlotVisuals(i, attribute, attribute2)
			local v2 = i
			replicatedData:GetAttributeChangedSignal("Loadout" .. i .. "_Slot_1"):Connect(function()
				updateSlotVisuals(
					v2,
					replicatedData:GetAttribute("Loadout" .. v2 .. "_Slot_1") or "",
					replicatedData:GetAttribute("Loadout" .. v2 .. "_Slot_2") or ""
				)
			end)
			local v3 = i
			replicatedData:GetAttributeChangedSignal("Loadout" .. i .. "_Slot_2"):Connect(function()
				updateSlotVisuals(
					v3,
					replicatedData:GetAttribute("Loadout" .. v3 .. "_Slot_1") or "",
					replicatedData:GetAttribute("Loadout" .. v3 .. "_Slot_2") or ""
				)
			end)
			pcall(wireLoadoutActivated, i)
		end

		pcall(function()
			local loadoutFrame = getLoadoutFrame() -- equivalent call inferred; original call site unknown

			if not (loadoutFrame and v.GuiAnimations) then
				return
			end

			for i = 1, 3 do
				local child = loadoutFrame:FindFirstChild("SlotButtonFrame_" .. i)
				local loadout_Slot = child and child:FindFirstChild("Loadout_Slot")

				if loadout_Slot then
					v.GuiAnimations.SetupButtonAnimationsSimple(loadout_Slot)
				end
			end
		end)
	end
}