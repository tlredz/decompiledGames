local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameContext = require(ReplicatedStorage.Modules.Core.GameContext)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local TrinketCatalogController = {}
local v = {
	tweens = nil
}
local flag = false
local v2 = nil
local activatedConnection = nil
local v3 = false
local fn

function TrinketCatalogController.getSelected()
	return v2
end

local function updatePreviewTitle(instance, module, childName)
	local title = instance:FindFirstChild("Title")

	if not title then
		return
	end

	local name = module.Name or childName
	local titleWithDrop = title:FindFirstChild("TitleWithDrop")

	if titleWithDrop and GameContext.updateTextWithDropSupport then
		GameContext.updateTextWithDropSupport(titleWithDrop, name)
		local titleTop = titleWithDrop:FindFirstChild("TitleTop")

		if titleTop then
			GameContext.updateTextWithDropSupport(titleTop, name)
		end
	else
		local toonName = title:FindFirstChild("ToonName")

		if toonName then
			toonName.Text = name
		end
	end

	local preview = title:FindFirstChild("Preview")
	local itemImage = preview and preview:FindFirstChild("ItemImage")

	if itemImage then
		itemImage.Image = module.Icon or ""
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updatePreviewDescription(instance, module)
	local description = instance:FindFirstChild("Description")
	local descriptionText = description and description:FindFirstChild("DescriptionText")

	if descriptionText then
		descriptionText.Text = module.Description or "No description available."
	end
end

local function isCurrentlyEquipped(p)
	local player = GameContext.Player
	local child = ReplicatedStorage.PlayerData:FindFirstChild((tostring(player.UserId)))
	local equippedTrinket1 = child and child:FindFirstChild("EquippedTrinket1")
	local equippedTrinket2 = child and child:FindFirstChild("EquippedTrinket2")
	return equippedTrinket1 and equippedTrinket1.Value == p and true or equippedTrinket2 and equippedTrinket2.Value == p
end

local function setEquipButtonText(folder, text)
	local v4 = nil

	for _, label in pairs(folder:GetDescendants()) do
		if not label:IsA("TextLabel") then
			continue
		end

		v4 = label
		break
	end

	if not v4 and folder:IsA("TextButton") then
		v4 = folder
	end

	if v4 then
		v4.Text = text
	end
end

local function updateSelectedTrinket(instance, childName)
	v2 = childName
	local child = ReplicatedStorage.TrinketData:FindFirstChild(childName)

	if not child then
		return
	end

	local module = require(child)
	updatePreviewTitle(instance, module, childName)
	updatePreviewDescription(instance, module) -- equivalent call inferred; original call site unknown
	local equip = instance:FindFirstChild("Equip")

	if equip then
		setEquipButtonText(equip, isCurrentlyEquipped(childName) and "Unequip" or "Equip")
	end
end

local function handleEquipResult(p, result, instance)
	local v4

	if result == true or result == "Slot1" or result == "Slot2" or result == "Removed1" or result == "Removed2" then
		v4 = true
	elseif p == "UnEquip" then
		v4 = result == nil
	else
		v4 = false
	end

	if v4 then
		local name = v2
		local child = ReplicatedStorage.TrinketData:FindFirstChild(v2)

		if child then
			local success, result2 = pcall(require, child)

			if success and result2.Name then
				name = result2.Name
			end
		end

		if p == "Equip" then
			if GameContext.TextMessage then
				GameContext.TextMessage("Equipped " .. name .. "!")
			end

			Audio:PlayOne("Sounds.UI.ChangeTrinket")
		else
			if GameContext.TextMessage then
				GameContext.TextMessage("Unequipped " .. name .. "!")
			end

			Audio:PlayOne("Sounds.UI.Buttons.Click")
		end

		task.wait(0.1)

		if GameContext.Update_Stats then
			GameContext.Update_Stats()
		end

		if GameContext.Update_Slots then
			GameContext.Update_Slots()
		end

		updateSelectedTrinket(instance, v2)
	else
		if GameContext.ErrorMessage then
			if result == "Equip" then
				GameContext.ErrorMessage("No empty trinket slots! Unequip a trinket first.")
			elseif result == "DontOwn" then
				GameContext.ErrorMessage("You don't own this trinket!")
			elseif result == "UnEquip" then
				GameContext.ErrorMessage("Unequip one of your trinkets first!")
			else
				GameContext.ErrorMessage("Failed to equip trinket: " .. tostring(result))
			end
		end

		if GameContext.Update_Stats then
			GameContext.Update_Stats()
		end

		if GameContext.Update_Slots then
			GameContext.Update_Slots()
		end

		updateSelectedTrinket(instance, v2)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setupEquipButton(previewPane)
	local equip = previewPane:FindFirstChild("Equip")

	if not equip then
		return
	end

	if activatedConnection then
		activatedConnection:Disconnect()
	end

	activatedConnection = equip.Activated:Connect(function()
		if not v2 or v3 then
			fn(previewPane)
			return
		end

		v3 = true
		local equipTrinket = ReplicatedStorage:FindFirstChild("EquipTrinket")

		if equipTrinket then
			local v4 = isCurrentlyEquipped(v2) and "UnEquip" or "Equip"
			local success, result = pcall(function()
				return equipTrinket:InvokeServer(v2, v4)
			end)

			if success then
				handleEquipResult(v4, result, previewPane)
			elseif GameContext.ErrorMessage then
				GameContext.ErrorMessage("Error calling server: " .. tostring(result))
			end

			v3 = false
		else
			if GameContext.ErrorMessage then
				GameContext.ErrorMessage("EquipTrinket RemoteFunction not found!")
			end

			v3 = false
		end
	end)
end

local function findTrinketToSelect(trinketsCatalog)
	local player = GameContext.Player
	local child = ReplicatedStorage.PlayerData:FindFirstChild((tostring(player.UserId)))

	if child then
		local equippedTrinket1 = child:FindFirstChild("EquippedTrinket1")
		local equippedTrinket2 = child:FindFirstChild("EquippedTrinket2")

		if equippedTrinket1 and equippedTrinket1.Value ~= "" and equippedTrinket1.Value ~= "None" then
			return equippedTrinket1.Value
		end

		if equippedTrinket2 and equippedTrinket2.Value ~= "" and equippedTrinket2.Value ~= "None" then
			return equippedTrinket2.Value
		end
	end

	for _, guiObject in pairs(trinketsCatalog:GetChildren()) do
		if not ((guiObject:IsA("Frame") or guiObject:IsA("ImageButton")) and guiObject.Name ~= "TrinketTemplate" and guiObject.Name ~= "Template" and guiObject.Name ~= "UIGridLayout") then
			continue
		end

		if not guiObject.Visible then
			continue
		end

		local locked = guiObject:FindFirstChild("Locked")

		if not (locked and locked.Visible) then
			return guiObject:GetAttribute("CodeName") or guiObject.Name
		end
	end

	return nil
end

local function findButtonByCodeName(trinketsCatalog, trinketToSelect)
	for _, guiObject in pairs(trinketsCatalog:GetChildren()) do
		if (guiObject:IsA("Frame") or guiObject:IsA("ImageButton")) and guiObject:GetAttribute("CodeName") == trinketToSelect then
			return guiObject
		end
	end

	return trinketsCatalog:FindFirstChild(trinketToSelect)
end

local function clearAllSelections()
	for _, v4 in pairs(CollectionService:GetTagged("SelectedTrinketLoadout")) do
		CollectionService:RemoveTag(v4, "SelectedTrinketLoadout")
		local selected = v4:FindFirstChild("Selected")

		if selected then
			selected.Visible = false
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function selectTrinketButton(instance, p, p2)
	clearAllSelections()
	CollectionService:AddTag(instance, "SelectedTrinketLoadout")
	local selected = instance:FindFirstChild("Selected")

	if selected then
		selected.Visible = true
	end

	v2 = p
	updateSelectedTrinket(p2, p)
end

local function renderEmptyState(previewPane)
	v2 = nil
	local title = previewPane:FindFirstChild("Title")

	if title then
		local toonName = title:FindFirstChild("ToonName") or title:FindFirstChild("TrinketName")

		if toonName then
			toonName.Text = "No Trinkets Owned"
		end

		local preview = title:FindFirstChild("Preview")
		local itemImage = preview and preview:FindFirstChild("ItemImage")

		if itemImage then
			itemImage.Image = ""
		end
	end

	local description = previewPane:FindFirstChild("Description")
	local descriptionText = description and description:FindFirstChild("DescriptionText")

	if descriptionText then
		descriptionText.Text = "You don't own any trinkets yet. Find or purchase trinkets to equip them here!"
	end
end

fn = function(instance)
	local margin = GameContext.Gui.SelectionFrame:FindFirstChild("Margin")
	local catalogFrame = margin and margin:FindFirstChild("CatalogFrame")
	local trinketsCatalog = catalogFrame and catalogFrame:FindFirstChild("Trinkets") and catalogFrame.Trinkets:FindFirstChild("TrinketsCatalog")

	if trinketsCatalog then
		for _, frame in pairs(trinketsCatalog:GetChildren()) do
			if not (frame:IsA("Frame") and frame.Name ~= "TrinketTemplate" and frame.Name ~= "Template" and frame.Name ~= "UIGridLayout") then
				continue
			end

			if not frame.Visible then
				continue
			end

			local codeName = frame:GetAttribute("CodeName") or frame.Name
			selectTrinketButton(frame, codeName, instance) -- equivalent call inferred; original call site unknown
			return
		end
	end

	if GameContext.ErrorMessage then
		GameContext.ErrorMessage("Please select a trinket first")
	end
end

local function setTrinketButtonIcon(clone, data)
	local characterImage = clone:FindFirstChild("CharacterImage") or clone:FindFirstChild("ItemImage") or clone:FindFirstChild("Icon") or clone:FindFirstChild("TrinketImage")

	if characterImage then
		characterImage.Image = data.Icon or ""
	else
		warn("[TrinketCatalogController] No image element in trinket button")
	end
end

local function setTrinketButtonName(clone, data, module)
	local name = data.Name or module.Name
	local titleWithDrop = clone:FindFirstChild("TitleWithDrop")

	if titleWithDrop and GameContext.updateTextWithDropSupport then
		GameContext.updateTextWithDropSupport(titleWithDrop, name)
		local titleTop = titleWithDrop:FindFirstChild("TitleTop")

		if titleTop then
			GameContext.updateTextWithDropSupport(titleTop, name)
		end
	else
		local characterName = clone:FindFirstChild("CharacterName")

		if characterName then
			characterName.Text = name
		end
	end

	clone:SetAttribute("DisplayName", name)
end

local function buildTrinketButton(trinketsCatalog, trinketTemplate, p, previewPane)
	local module = p.module
	local data = p.data
	local clone = trinketTemplate:Clone()
	clone.Name = data.Name or module.Name
	clone.Visible = true
	clone.Active = true
	clone:SetAttribute("CodeName", module.Name)
	clone.Parent = trinketsCatalog
	setTrinketButtonIcon(clone, data)
	setTrinketButtonName(clone, data, module)
	local selected = clone:FindFirstChild("Selected")

	if selected then
		selected.Visible = false
	end

	local equipped = clone:FindFirstChild("Equipped")

	if equipped then
		equipped.Visible = false
	end

	local tweens = v.tweens
	clone.MouseEnter:Connect(function()
		Audio:PlayOne("Sounds.UI.SkillCheck.Ticks.TinyTick")
		tweens:playTween(clone.UIScale, TweenInfo.new(0.1), {
			Scale = 1.04
		})
	end)
	clone.MouseLeave:Connect(function()
		tweens:playTween(clone.UIScale, TweenInfo.new(0.1), {
			Scale = 1
		})
	end)
	local flag2 = false
	clone.Activated:Connect(function()
		Audio:PlayOne("Sounds.UI.Buttons.Click")

		if flag2 then
			return
		end

		flag2 = true
		local codeName = clone:GetAttribute("CodeName") or module.Name
		selectTrinketButton(clone, codeName, previewPane) -- equivalent call inferred; original call site unknown
		task.wait(0.2)
		flag2 = false
	end)
end

function TrinketCatalogController.populate()
	if flag then
		return
	end

	local gui = GameContext.Gui
	local player = GameContext.Player
	local margin = gui.SelectionFrame:FindFirstChild("Margin")

	if not margin then
		warn("[TrinketCatalogController] Margin not found")
		return
	end

	local catalogFrame = margin:FindFirstChild("CatalogFrame")

	if not catalogFrame then
		warn("[TrinketCatalogController] CatalogFrame not found")
		return
	end

	local trinkets = catalogFrame:FindFirstChild("Trinkets")

	if not trinkets then
		warn("[TrinketCatalogController] Trinkets frame not found")
		return
	end

	local trinketsCatalog = trinkets:FindFirstChild("TrinketsCatalog")

	if not trinketsCatalog then
		warn("[TrinketCatalogController] TrinketsCatalog not found")
		return
	end

	local trinketTemplate = trinketsCatalog:FindFirstChild("TrinketTemplate") or trinketsCatalog:FindFirstChild("Template")

	if not trinketTemplate then
		warn("[TrinketCatalogController] Template not found")
		return
	end

	trinketTemplate.Visible = false

	for _, child in pairs(trinketsCatalog:GetChildren()) do
		if child ~= trinketTemplate and child.Name ~= "UIGridLayout" then
			child:Destroy()
		end
	end

	local previewPane = trinkets:FindFirstChild("PreviewPane")
	local child = ReplicatedStorage.PlayerData:FindFirstChild((tostring(player.UserId)))
	local trinkets2 = child and child:FindFirstChild("Trinkets")

	if not trinkets2 then
		return
	end

	local v4 = {}

	for _, moduleScript in pairs(ReplicatedStorage.TrinketData:GetChildren()) do
		if not (moduleScript:IsA("ModuleScript") and trinkets2:FindFirstChild(moduleScript.Name)) then
			continue
		end

		local success, result = pcall(require, moduleScript)

		if success and result then
			table.insert(v4, {
				module = moduleScript,
				data = result,
				displayName = result.Name or moduleScript.Name
			})
		end
	end

	table.sort(v4, function(a, b)
		return a.displayName:lower() < b.displayName:lower()
	end)

	if previewPane then
		for _, v5 in pairs(v4) do
			buildTrinketButton(trinketsCatalog, trinketTemplate, v5, previewPane)
		end
	end

	if GameContext.Update_Stats then
		GameContext.Update_Stats()
	end

	if GameContext.Update_Slots then
		GameContext.Update_Slots()
	end

	flag = true

	if previewPane then
		local trinketToSelect = findTrinketToSelect(trinketsCatalog)

		if trinketToSelect then
			local buttonByCodeName = findButtonByCodeName(trinketsCatalog, trinketToSelect)

			if buttonByCodeName then
				selectTrinketButton(buttonByCodeName, trinketToSelect, previewPane) -- equivalent call inferred; original call site unknown
			end
		else
			renderEmptyState(previewPane)
		end

		CollectionService:GetInstanceAddedSignal("SelectedTrinketLoadout"):Connect(function(instance)
			if instance.Parent and instance.Parent.Name == "TrinketsCatalog" then
				local codeName = instance:GetAttribute("CodeName")

				if codeName and codeName ~= "" then
					updateSelectedTrinket(previewPane, codeName)
				else
					warn("[TrinketCatalogController] Invalid trinket code name in selection listener")
				end
			end
		end)
		setupEquipButton(previewPane) -- equivalent call inferred; original call site unknown
	end

	task.spawn(function()
		task.wait(0.1)

		if GameContext.Update_Stats then
			GameContext.Update_Stats()
		end

		if GameContext.Update_Slots then
			GameContext.Update_Slots()
		end
	end)
end

function TrinketCatalogController.reset()
	flag = false
end

function TrinketCatalogController.refreshEquippedCheckmarks()
	local gui = GameContext.Gui
	local player = GameContext.Player
	local selectionFrame = gui:FindFirstChild("SelectionFrame")

	if not (selectionFrame and selectionFrame.Visible) then
		return
	end

	local margin = selectionFrame:FindFirstChild("Margin")
	local catalogFrame = margin and margin:FindFirstChild("CatalogFrame")
	local trinkets = catalogFrame and catalogFrame:FindFirstChild("Trinkets")
	local trinketsCatalog = trinkets and trinkets:FindFirstChild("TrinketsCatalog")

	if not trinketsCatalog then
		return
	end

	local child = ReplicatedStorage.PlayerData:FindFirstChild((tostring(player.UserId)))
	local equippedTrinket1 = child and child:FindFirstChild("EquippedTrinket1")
	local equippedTrinket2 = child and child:FindFirstChild("EquippedTrinket2")

	for _, guiObject in pairs(trinketsCatalog:GetChildren()) do
		if not ((guiObject:IsA("Frame") or guiObject:IsA("ImageButton")) and guiObject.Name ~= "TrinketTemplate" and guiObject.Name ~= "UIGridLayout") then
			continue
		end

		local equipped = guiObject:FindFirstChild("Equipped")

		if equipped then
			equipped.Visible = equippedTrinket1 and equippedTrinket1.Value == guiObject.Name and true or equippedTrinket2 and equippedTrinket2.Value == guiObject.Name
		end
	end
end

function TrinketCatalogController.init(options)
	v = options or {}
	GameContext.ensureTrinketCatalogPopulated = TrinketCatalogController.populate
	GameContext.resetTrinketCatalog = TrinketCatalogController.reset
	GameContext.getCurrentlySelectedTrinket = TrinketCatalogController.getSelected
	GameContext.Update_Stats = TrinketCatalogController.refreshEquippedCheckmarks
end

return TrinketCatalogController