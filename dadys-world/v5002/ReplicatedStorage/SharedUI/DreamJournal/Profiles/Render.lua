local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UITemplates = require(ReplicatedStorage.SharedUtils.UITemplates)
local ToonViewport = require(ReplicatedStorage.SharedUtils.ToonViewport)
local GuiAnimations = require(ReplicatedStorage.Modules.GuiAnimations)
local ProfileCardConfig = require(ReplicatedStorage.SharedData.ProfileCardConfig)
local ProfileStats = require(ReplicatedStorage.SharedData.ProfileStats)
local ProfileBackgrounds = require(ReplicatedStorage.SharedData.ProfileBackgrounds)
local ProfileBackdropColors = require(ReplicatedStorage.SharedData.ProfileBackdropColors)
local ProfileFrames = require(ReplicatedStorage.SharedData.ProfileFrames)
local ProfileBackdrops = require(ReplicatedStorage.SharedData.ProfileBackdrops)
local ProfileEffects = require(ReplicatedStorage.SharedUI.ProfileEffects)
local ToonCard = require(script.Parent.ToonCard)
local Sources = require(script.Parent.Sources)
local Render = {}
local v = {
	Medals = "MedalCard",
	Toons = "ItemCard",
	Twisteds = "ItemCard",
	Trinkets = "ItemCard",
	Stickers = "ItemCard"
}
local v2 = {
	Toons = true,
	Trinkets = true
}
local v3 = {
	Toons = true,
	Twisteds = true
}
local v4 = {
	Stickers = "Shared.Journal.sticker"
}

local function stylesheetFor(p: string, instance)
	local v5 = v4[p]

	if not v5 or typeof(instance) == "Instance" and instance:GetAttribute("stylesheet") then
		return nil
	end

	return v5
end

local function findAuthoredTemplate(scrollingFrame, name: string)
	if not scrollingFrame then
		return nil
	end

	local guiObject = scrollingFrame:FindFirstChild(name .. "Template")

	if guiObject and guiObject:IsA("GuiObject") then
		return guiObject
	end

	for _, guiObject2 in ipairs(scrollingFrame:GetChildren()) do
		if guiObject2:IsA("GuiObject") and string.match(guiObject2.Name, "Template$") then
			return guiObject2
		end
	end

	return nil
end

local v5 = {
	Toons = UITemplates.Types.Toon,
	Twisteds = UITemplates.Types.Twisted,
	Trinkets = UITemplates.Types.Trinket
}

local function child(instance, childName: string)
	return instance and instance:FindFirstChild(childName) or nil
end

local function resolveButton(button)
	if not button then
		return nil
	end

	if button:IsA("GuiButton") then
		return button
	end

	return button:FindFirstChildWhichIsA("GuiButton", true)
end

local function firstChild(instance, ...)
	if not instance then
		return nil
	end

	for _, childName in ipairs({ ... }) do
		local child2 = instance:FindFirstChild(childName)

		if child2 then
			return child2
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setText(label, text: string)
	if label and label:IsA("TextLabel") then
		label.Text = text
	end
end

local function slotImageLabels(image)
	local result = {}

	for _, childName in ipairs({
		"ItemImage",
		"ImageLabel",
		"Icon",
		"ImageShadow"
	}) do
		local image2 = image:FindFirstChild(childName, true)

		if image2 and image2:IsA("ImageLabel") then
			table.insert(result, image2)
		end
	end

	local v6 = #result == 0 and (image:IsA("ImageLabel") and image or image:FindFirstChildWhichIsA("ImageLabel", true))

	if v6 then
		table.insert(result, v6)
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setVisible(guiObject, visible: boolean)
	if guiObject and guiObject:IsA("GuiObject") then
		guiObject.Visible = visible
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setInteractable(guiObject, interactable: boolean)
	if guiObject and guiObject:IsA("GuiObject") then
		guiObject.Interactable = interactable
	end
end

local function roundCorners(guiObject)
	if not (guiObject and guiObject:IsA("GuiObject")) then
		return
	end

	local v6 = guiObject:FindFirstChildOfClass("UICorner")

	if not v6 then
		v6 = Instance.new("UICorner")
		v6.Parent = guiObject
	end

	v6.CornerRadius = UDim.new(1, 0)
end

local function wireScrollbar(p, instance, p2)
	if not (instance and p2 and p.tweens) then
		return
	end

	if instance:FindFirstChild("Thumb") then
		pcall(p.tweens.customScrollbar, instance, p2)
	else
		warn("[Profiles] " .. instance:GetFullName() .. " has no Thumb; scrollbar not wired")
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function statValue(p, p2: string)
	local statValues = p.StatValues

	if statValues and statValues[p2] ~= nil then
		return statValues[p2]
	end

	return ProfileStats.ReadValue(p, p2)
end

local function sectionKey(p)
	if type(p) ~= "table" then
		return ""
	end

	local v6 = type(p.Items) ~= "table" and {} or p.Items or {}
	return tostring(p.Type) .. "|" .. table.concat(v6, ",")
end

local function clearRendered(instance)
	if not instance then
		return
	end

	for _, guiObject in ipairs(instance:GetChildren()) do
		if not (guiObject:IsA("GuiObject") and guiObject:GetAttribute("TemplateKey") ~= nil) then
			continue
		end

		UITemplates.Release(guiObject)
		guiObject:Destroy()
	end
end

function Render.Mount(controller, parent)
	local margin

	if parent then
		margin = parent:FindFirstChild("Margin") or nil
	else
		margin = nil
	end

	if not margin then
		warn("[Profiles] page has no Margin frame")
		return nil
	end

	local header

	if margin then
		header = margin:FindFirstChild("Header") or nil
	else
		header = nil
	end

	local favorites

	if margin then
		favorites = margin:FindFirstChild("Favorites") or nil
	end

	local sections

	if margin then
		sections = margin:FindFirstChild("Sections") or nil
	end

	local titleSpot = firstChild(header, "TitleSpot", "TitleSlot")
	local sideButtons

	if parent then
		sideButtons = parent:FindFirstChild("SideButtons") or nil
	else
		sideButtons = nil
	end

	if not sideButtons then
		if margin then
			sideButtons = margin:FindFirstChild("SideButtons") or nil
		else
			sideButtons = nil
		end
	end

	local function pageButton(childName: string)
		local v7 = sideButtons
		local child2

		if v7 then
			child2 = v7:FindFirstChild(childName) or nil
		end

		if not child2 then
			child2 = header and header:FindFirstChild(childName) or nil
		end

		return child2
	end

	if not sections then
		warn("[Profiles] page has no Sections container")
		return nil
	end

	local v7 = {
		controller = controller,
		page = parent,
		margin = margin,
		sectionsFrame = sections,
		headerFrame = header,
		favoritesFrame = favorites,
		editButton = 0,
		confirmButton = 0,
		editColorButton = 0,
		backdropButton = 0,
		nameLabel = 0,
		titleSpot = 0,
		titleEditButton = 0,
		favorites = 0,
		sections = 0,
		typeTemplates = 0,
		removeButtonTemplate = 0,
		equippedTemplate = 0,
		trinketSlots = 0,
		picker = nil,
		typePicker = nil,
		_sectionKeys = 0,
		_favoritesKey = nil
	}
	local editButton

	if sideButtons then
		editButton = sideButtons:FindFirstChild("EditButton") or nil
	end

	if not editButton then
		if header then
			editButton = header:FindFirstChild("EditButton") or nil
		else
			editButton = nil
		end
	end

	v7.editButton = editButton
	local confirmButton

	if sideButtons then
		confirmButton = sideButtons:FindFirstChild("ConfirmButton") or nil
	end

	if not confirmButton then
		if header then
			confirmButton = header:FindFirstChild("ConfirmButton") or nil
		else
			confirmButton = nil
		end
	end

	v7.confirmButton = confirmButton
	local editColor

	if sideButtons then
		editColor = sideButtons:FindFirstChild("EditColor") or nil
	end

	if not editColor then
		if header then
			editColor = header:FindFirstChild("EditColor") or nil
		else
			editColor = nil
		end
	end

	if not editColor then
		if sideButtons then
			editColor = sideButtons:FindFirstChild("EditColorButton") or nil
		else
			editColor = nil
		end

		if not editColor then
			if header then
				editColor = header:FindFirstChild("EditColorButton") or nil
			else
				editColor = nil
			end
		end
	end

	v7.editColorButton = editColor
	local backdropButton

	if sideButtons then
		backdropButton = sideButtons:FindFirstChild("BackdropButton") or nil
	end

	if not backdropButton then
		if header then
			backdropButton = header:FindFirstChild("BackdropButton") or nil
		else
			backdropButton = nil
		end
	end

	local editBackdrop = backdropButton or sideButtons and sideButtons:FindFirstChild("EditBackdrop") or nil

	if not editBackdrop then
		if header then
			editBackdrop = header:FindFirstChild("EditBackdrop") or nil
		else
			editBackdrop = nil
		end
	end

	v7.backdropButton = editBackdrop
	local nameLabel

	if header then
		nameLabel = header:FindFirstChild("NameLabel") or nil
	end

	v7.nameLabel = nameLabel
	v7.titleSpot = titleSpot
	v7.titleEditButton = titleSpot and titleSpot:FindFirstChild("EditButton") or nil
	v7.favorites = {}
	v7.sections = {}
	v7.typeTemplates = {}
	local removeButtonTemplate

	if margin then
		removeButtonTemplate = margin:FindFirstChild("RemoveButton") or nil
	end

	v7.removeButtonTemplate = removeButtonTemplate
	local equipped

	if parent then
		equipped = parent:FindFirstChild("Equipped") or nil
	end

	if not equipped then
		if margin then
			equipped = margin:FindFirstChild("Equipped") or nil
		else
			equipped = nil
		end
	end

	v7.equippedTemplate = equipped
	v7.trinketSlots = {}
	v7._sectionKeys = {}

	if not v7.removeButtonTemplate then
		warn("[Profiles] Margin has no RemoveButton; entries will not be removable")
	end

	local function mountBackdropSurface(childName: string)
		local v10 = parent
		local folder

		if v10 then
			folder = v10:FindFirstChild(childName) or nil
		end

		if not folder then
			local v11 = margin

			if v11 then
				folder = v11:FindFirstChild(childName) or nil
			else
				folder = nil
			end
		end

		local v11 = {
			frame = folder,
			labels = {},
			quadrants = {},
			authoredImages = {}
		}

		if not folder then
			return v11
		end

		for _, image in ipairs(folder:GetDescendants()) do
			if image:IsA("ImageLabel") then
				table.insert(v11.labels, image)
			end
		end

		if folder:IsA("ImageLabel") then
			table.insert(v11.labels, folder)
		end

		for _, childName2 in ipairs(ProfileBackdrops.Quadrants) do
			local image = folder:FindFirstChild(childName2)

			if not (image and image:IsA("ImageLabel")) then
				continue
			end

			v11.quadrants[childName2] = image
			v11.authoredImages[childName2] = image.Image
		end

		if next(v11.quadrants) == nil then
			warn("[Profiles] " .. childName .. " has no TL/TR/BL/BR labels; backdrop images will not apply to it")
		end

		return v11
	end

	v7.backdrop = mountBackdropSurface("Background")
	v7.backdropOversize = mountBackdropSurface("Background_OVERSIZE")

	if not v7.backdrop.frame then
		warn("[Profiles] page has no Background frame; the backdrop colour will not apply")
	end

	for i = 1, 2 do
		local v10 = "Slot" .. i
		local child2

		if header then
			child2 = header:FindFirstChild(v10) or nil
		end

		if child2 then
			v7.trinketSlots[i] = {
				frame = child2,
				labels = slotImageLabels(child2)
			}
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function addButtonFeedback(button)
		if button and button:IsA("GuiButton") then
			pcall(GuiAnimations.SetupButtonAnimationsSimple, button)
		end
	end

	addButtonFeedback(v7.editButton) -- equivalent call inferred; original call site unknown
	addButtonFeedback(v7.confirmButton) -- equivalent call inferred; original call site unknown
	addButtonFeedback(v7.editColorButton) -- equivalent call inferred; original call site unknown
	addButtonFeedback(v7.titleEditButton) -- equivalent call inferred; original call site unknown
	addButtonFeedback(v7.backdropButton) -- equivalent call inferred; original call site unknown

	for _, childName in ipairs(ProfileCardConfig.FavoriteOrder) do
		local child2

		if favorites then
			child2 = favorites:FindFirstChild(childName) or nil
		end

		local favorites2 = v7.favorites
		local v10 = {
			frame = child2,
			button = child2 and child2:FindFirstChild("Button", true),
			editButton = 0,
			empty = 0
		}
		local editButton2

		if child2 then
			editButton2 = child2:FindFirstChild("EditButton") or nil
		end

		v10.editButton = editButton2
		v10.empty = child2 and child2:FindFirstChild("Empty") or nil
		favorites2[childName] = v10
	end

	if not sections:FindFirstChild("SmallB") then
		local smallA = sections:FindFirstChild("SmallA")

		if smallA and smallA:IsA("GuiObject") then
			local clone = smallA:Clone()
			clone.Name = "SmallB"
			clone.Parent = sections
		else
			warn("[Profiles] no SmallA to clone SmallB from")
		end
	end

	for _, childName in ipairs(ProfileCardConfig.SlotOrder) do
		local child2

		if sections then
			child2 = sections:FindFirstChild(childName) or nil
		end

		local types

		if child2 then
			types = child2:FindFirstChild("Types") or nil
		end

		local controls

		if child2 then
			controls = child2:FindFirstChild("Controls") or nil
		end

		local v10 = {
			frame = child2,
			typesFolder = types,
			types = {},
			controls = controls,
			baseZIndex = not child2 and 1 or child2.ZIndex or 1,
			typeLabel = 0,
			editButton = 0,
			confirmButton = 0,
			changeTypeButton = 0,
			deleteButton = 0,
			moveLeftButton = 0,
			moveRightButton = 0,
			noOp = 0
		}
		local typeLabel

		if child2 then
			typeLabel = child2:FindFirstChild("TypeLabel") or nil
		end

		v10.typeLabel = typeLabel
		local editButton2

		if child2 then
			editButton2 = child2:FindFirstChild("EditButton") or nil
		end

		v10.editButton = editButton2
		local confirmButton2

		if child2 then
			confirmButton2 = child2:FindFirstChild("ConfirmButton") or nil
		end

		v10.confirmButton = confirmButton2
		local changeTypeButton = firstChild(controls, "ChangeTypeButton", "ChangeButton")

		if not changeTypeButton then
			if child2 then
				changeTypeButton = child2:FindFirstChild("ChangeTypeButton") or nil
			else
				changeTypeButton = nil
			end
		end

		v10.changeTypeButton = changeTypeButton
		local deleteButton = firstChild(controls, "DeleteButton", "RemoveButton")

		if not deleteButton then
			if child2 then
				deleteButton = child2:FindFirstChild("DeleteButton") or nil
			else
				deleteButton = nil
			end
		end

		v10.deleteButton = deleteButton
		local moveLeftButton

		if child2 then
			moveLeftButton = child2:FindFirstChild("MoveLeftButton") or nil
		end

		v10.moveLeftButton = moveLeftButton
		local moveRightButton

		if child2 then
			moveRightButton = child2:FindFirstChild("MoveRightButton") or nil
		end

		v10.moveRightButton = moveRightButton
		v10.noOp = child2 and child2:FindFirstChild("NoOp") or nil

		if types then
			for _, guiObject in ipairs(types:GetChildren()) do
				if not guiObject:IsA("GuiObject") then
					continue
				end

				local scrollingFrame

				if guiObject then
					scrollingFrame = guiObject:FindFirstChild("ScrollingFrame") or nil
				end

				if scrollingFrame then
					if scrollingFrame then
						scrollingFrame = scrollingFrame:FindFirstChild("AddContentButton") or nil
					else
						scrollingFrame = nil
					end
				end

				local v16 = {
					frame = guiObject,
					scroll = scrollingFrame,
					addContentButton = scrollingFrame,
					addContentClickable = 0,
					addSectionButton = 0,
					template = 0
				}

				if scrollingFrame then
					if not scrollingFrame:IsA("GuiButton") then
						scrollingFrame = scrollingFrame:FindFirstChildWhichIsA("GuiButton", true)
					end
				else
					scrollingFrame = nil
				end

				v16.addContentClickable = scrollingFrame
				local addSectionButton

				if guiObject then
					addSectionButton = guiObject:FindFirstChild("AddSectionButton") or nil
				end

				v16.addSectionButton = addSectionButton
				v16.template = findAuthoredTemplate(scrollingFrame, guiObject.Name)

				if v16.template then
					v16.template.Parent = nil

					if not v7.typeTemplates[guiObject.Name] then
						v7.typeTemplates[guiObject.Name] = v16.template
					end
				end

				if guiObject.Name == "Thumbnail" then
					local v18

					if guiObject then
						v18 = guiObject:FindFirstChild("Buttons") or nil
					end

					local v19 = v18 or guiObject
					local thumbnail = {
						frame = guiObject,
						background = firstChild(guiObject, "Background", "BackgroundTemplate"),
						subject = firstChild(guiObject, "Subject", "SubjectTemplate"),
						viewport = guiObject:FindFirstChildOfClass("ViewportFrame"),
						sticker = firstChild(guiObject, "Sticker", "StickerTemplate"),
						artFrame = firstChild(guiObject, "Frame", "FrameTemplate"),
						backgroundButton = 0,
						subjectButton = 0,
						stickerButton = 0,
						frameButton = 0
					}
					local backgroundButton

					if v19 then
						backgroundButton = v19:FindFirstChild("BackgroundButton") or nil
					end

					thumbnail.backgroundButton = backgroundButton
					local subjectButton

					if v19 then
						subjectButton = v19:FindFirstChild("SubjectButton") or nil
					end

					thumbnail.subjectButton = subjectButton
					local stickerButton

					if v19 then
						stickerButton = v19:FindFirstChild("StickerButton") or nil
					end

					thumbnail.stickerButton = stickerButton
					thumbnail.frameButton = v19 and v19:FindFirstChild("FrameButton") or nil
					v16.thumbnail = thumbnail

					if not v16.thumbnail.sticker then
						warn("[Profiles] Thumbnail has no Sticker or StickerTemplate child")
					end

					local _ = v16.thumbnail.sticker

					if v16.thumbnail.viewport then
						ToonViewport.EnableRotation(v16.thumbnail.viewport)
					end
				end

				if v16.addContentButton then
					v16.addContentButton.LayoutOrder = 1000
				end

				v10.types[guiObject.Name] = v16
			end
		else
			warn("[Profiles] section " .. childName .. " has no Types folder")
		end

		v7.sections[childName] = v10
	end

	local function mountPopup(childName: string)
		local child2 = parent and parent:FindFirstChild(childName) or nil

		if not child2 then
			return nil
		end

		local v11

		if child2 then
			v11 = child2:FindFirstChild("Margin") or nil
		end

		local margin2 = v11 or child2
		local scrollingFrame

		if margin2 then
			scrollingFrame = margin2:FindFirstChild("ScrollingFrame") or nil
		end

		local v15

		if margin2 then
			v15 = margin2:FindFirstChild("Scrolling") or nil
		end

		wireScrollbar(controller, v15, scrollingFrame)
		child2.Visible = false
		local noOp

		if margin2 then
			noOp = margin2:FindFirstChild("NoOp") or nil
		end

		local noOpLabel

		if noOp then
			noOpLabel = noOp:IsA("TextLabel") and noOp or noOp:FindFirstChildWhichIsA("TextLabel", true)
		end

		local v17 = {
			frame = child2,
			margin = margin2,
			scroll = scrollingFrame,
			basePosition = child2.Position,
			headerLabel = 0,
			counterLabel = 0,
			noOp = 0,
			noOpLabel = 0,
			noOpDefaultText = 0,
			closeButton = 0,
			confirmButton = 0
		}
		local headerLabel

		if margin2 then
			headerLabel = margin2:FindFirstChild("HeaderLabel") or nil
		end

		v17.headerLabel = headerLabel
		local counterLabel

		if margin2 then
			counterLabel = margin2:FindFirstChild("CounterLabel") or nil
		end

		v17.counterLabel = counterLabel
		v17.noOp = noOp
		v17.noOpLabel = noOpLabel
		v17.noOpDefaultText = noOpLabel and noOpLabel.Text or nil
		local closeButton

		if margin2 then
			closeButton = margin2:FindFirstChild("CloseButton") or nil
		end

		v17.closeButton = closeButton
		v17.confirmButton = margin2 and margin2:FindFirstChild("ConfirmButton") or nil
		return v17
	end

	v7.picker = mountPopup("Picker")
	v7.typePicker = mountPopup("SectionTypePicker")

	if v7.picker and v7.picker.scroll then
		for _, guiObject in ipairs(v7.picker.scroll:GetChildren()) do
			local v10 = guiObject:IsA("GuiObject") and string.match(guiObject.Name, "^(%a+)Template$")

			if not v10 then
				continue
			end

			guiObject.Parent = nil
			v7.typeTemplates[v10] = guiObject
		end
	end

	local popupBlocker

	if parent then
		popupBlocker = parent:FindFirstChild("PopupBlocker") or nil
	end

	if not popupBlocker then
		popupBlocker = Instance.new("TextButton")
		popupBlocker.Name = "PopupBlocker"
		popupBlocker.Parent = parent
	end

	popupBlocker.AnchorPoint = Vector2.new(0.5, 0.5)
	popupBlocker.Position = UDim2.fromScale(0.5, 0.5)
	popupBlocker.Size = UDim2.fromScale(4, 4)
	popupBlocker.BackgroundColor3 = Color3.new(0, 0, 0)
	popupBlocker.BackgroundTransparency = 0.5
	popupBlocker.Text = ""
	popupBlocker.AutoButtonColor = false
	popupBlocker.Active = true
	popupBlocker.Selectable = false
	popupBlocker.Visible = false
	v7.popupBlocker = popupBlocker
	local confirmDialog = parent and parent:FindFirstChild("ConfirmDialog") or nil

	if confirmDialog then
		local v11

		if confirmDialog then
			v11 = confirmDialog:FindFirstChild("Margin") or nil
		end

		local margin2 = v11 or confirmDialog
		confirmDialog.Visible = false
		local confirmDialog2 = {
			frame = confirmDialog,
			margin = margin2,
			basePosition = confirmDialog.Position,
			headerLabel = 0,
			messageLabel = 0,
			yesButton = 0,
			noButton = 0
		}
		local headerLabel

		if margin2 then
			headerLabel = margin2:FindFirstChild("HeaderLabel") or nil
		end

		confirmDialog2.headerLabel = headerLabel
		local messageLabel

		if margin2 then
			messageLabel = margin2:FindFirstChild("MessageLabel") or nil
		end

		confirmDialog2.messageLabel = messageLabel
		local yesButton

		if margin2 then
			yesButton = margin2:FindFirstChild("YesButton") or nil
		end

		confirmDialog2.yesButton = yesButton
		confirmDialog2.noButton = margin2 and margin2:FindFirstChild("NoButton") or nil
		v7.confirmDialog = confirmDialog2
	else
		warn("[Profiles] page has no ConfirmDialog; section deletion will be unavailable")
	end

	if not v7.typePicker then
		return v7
	end

	local typeTemplate = v7.typePicker.scroll and v7.typePicker.scroll:FindFirstChild("TypeTemplate")

	if typeTemplate then
		typeTemplate.Parent = nil
		v7.typePicker.template = typeTemplate
		return v7
	else
		warn("[Profiles] SectionTypePicker has no TypeTemplate button")
	end

	return v7
end

local function applyTitle(p, p2)
	local titleSpot = p.titleSpot

	if not titleSpot then
		return
	end

	local username = titleSpot:FindFirstChild("Username", true)

	if username and username:IsA("TextLabel") then
		username.Text = p2.Username or ""
	end

	local equippedTitle = p2.EquippedTitle
	local v6

	if type(equippedTitle) == "string" and equippedTitle ~= "" then
		v6 = equippedTitle ~= "None"
	else
		v6 = false
	end

	local v7

	if v6 then
		v7 = UITemplates.Describe(UITemplates.Types.Title, equippedTitle)

		if v7.Missing then
			v7 = nil
		end
	end

	local gradient

	if v7 then
		gradient = v7.Gradient or nil
	end

	local display = titleSpot:FindFirstChild("Display")

	if display then
		local v8 = "None"

		if v7 and gradient then
			local image = display:FindFirstChild(gradient)

			if image and image:IsA("ImageLabel") then
				v8 = gradient
			end
		end

		for _, image in ipairs(display:GetChildren()) do
			if image:IsA("ImageLabel") then
				image.Visible = image.Name == v8
			end
		end
	end

	local image2 = not v7 and "" or v7.Image or ""

	for _, childName in ipairs({ "ImageLabel", "ImageShadow" }) do
		local image = titleSpot:FindFirstChild(childName)

		if image and image:IsA("ImageLabel") then
			image.Image = image2
		end
	end

	local displayName = titleSpot:FindFirstChild("DisplayName", true)

	if displayName and displayName:IsA("TextLabel") then
		displayName.Visible = v7 ~= nil
		displayName.Text = not v7 and "" or "[" .. v7.Name .. "]" or ""

		for _, uIGradient in ipairs(displayName:GetChildren()) do
			if uIGradient:IsA("UIGradient") then
				uIGradient.Enabled = uIGradient.Name == gradient
			end
		end
	end

	local description = titleSpot:FindFirstChild("Description", true)

	if description and description:IsA("TextLabel") then
		description.Text = v7 and v7.Description or ""
	end

	titleSpot:SetAttribute("Difficulty", gradient)
	titleSpot:SetAttribute("ItemId", v6 and equippedTitle or "")
end

local function applyTrinketSlots(p, p2)
	local equippedTrinkets = p2.EquippedTrinkets
	local v6 = type(equippedTrinkets) ~= "table" and {} or equippedTrinkets

	for i = 1, 2 do
		local trinketSlot = p.trinketSlots[i]

		if not trinketSlot then
			continue
		end

		local v7 = v6[i]
		local v8

		if type(v7) == "string" and v7 ~= "" then
			v8 = v7 ~= "None"
		else
			v8 = false
		end

		local v9

		if v8 then
			v9 = UITemplates.Describe(UITemplates.Types.Trinket, v7)

			if v9.Missing then
				v9 = nil
			end
		end

		for _, label in ipairs(trinketSlot.labels) do
			label.Image = not v9 and "" or v9.Icon or ""
			label.Visible = v9 ~= nil
		end

		trinketSlot.frame:SetAttribute("ItemId", v9 and v7 or "")
	end
end

local function favoritesKey(p)
	local v6 = {}

	for _, v7 in ipairs(ProfileCardConfig.FavoriteOrder) do
		local v8

		if type(p) == "table" then
			v8 = p[v7] or nil
		end

		table.insert(
			v6,
			(type(v8) ~= "table" and "" or tostring(v8.Type) or "") .. "|" .. (type(v8) ~= "table" and "" or tostring(v8.Id) or "")
		)
	end

	return table.concat(v6, ";")
end

local function applyFavorites(state, p)
	local profileCard = p.ProfileCard
	local v6 = type(profileCard) ~= "table" and {} or profileCard.Favorites or {}
	local favoritesKey2 = favoritesKey(v6)

	if state._favoritesKey == favoritesKey2 then
		return
	end

	state._favoritesKey = favoritesKey2

	for _, v8 in ipairs(ProfileCardConfig.FavoriteOrder) do
		local favorite = state.favorites[v8]

		if not (favorite and favorite.frame) then
			continue
		end

		clearRendered(favorite.frame)
		local v9

		if type(v6) == "table" then
			v9 = v6[v8] or nil
		end

		local v10 = type(v9) ~= "table" and "" or v9.Id or ""
		local v11

		if type(v9) == "table" then
			v11 = v5[v9.Type] or nil
		end

		favorite.filled = type(v10) == "string" and v10 ~= "" and v11 ~= nil

		if not favorite.filled then
			continue
		end

		local v13 = UITemplates.Render("SlotCard", v11, v10, {
			parent = favorite.frame,
			styleController = state.controller.styleController,
			useIcon = true
		})

		if not (v13 and v3[v9.Type]) then
			continue
		end

		for _, v14 in ipairs({ "Image", "Shadow" }) do
			roundCorners(UITemplates.GetRole(v13, v14))
		end
	end
end

local function applyBackdropImage(p, p2)
	local profileCard = p2.ProfileCard
	local resolve = ProfileBackdrops.Resolve
	local v6

	if type(profileCard) == "table" then
		v6 = profileCard.BackdropImage or nil
	end

	local resolved = resolve(v6)
	local v7 = ProfileBackdrops.Get(resolved)
	local oversize

	if v7 == nil then
		oversize = false
	else
		oversize = v7.Oversize
	end

	local backdrop = p.backdrop

	if oversize and p.backdropOversize and p.backdropOversize.frame then
		backdrop = p.backdropOversize
	end

	for _, v8 in ipairs({ p.backdrop, p.backdropOversize }) do
		if not (v8 and v8.frame) then
			continue
		end

		setVisible(v8.frame, v8 == backdrop) -- equivalent call inferred; original call site unknown
	end

	if next(backdrop.quadrants) == nil then
		return resolved ~= ProfileBackdrops.DefaultKey, backdrop
	end

	for k, quadrant in pairs(backdrop.quadrants) do
		local image = not v7 and "" or v7.Images[k] or ""

		if image == "" then
			image = backdrop.authoredImages[k] or ""
		end

		quadrant.Image = image
	end

	return resolved ~= ProfileBackdrops.DefaultKey, backdrop
end

local function applyBackdropColor(p, p2, flag: boolean, p3)
	local v6 = p3 or p.backdrop

	if not (v6 and #v6.labels > 0) then
		return
	end

	local profileCard = p2.ProfileCard
	local v7

	if type(profileCard) == "table" then
		v7 = profileCard.BackdropColor or nil
	end

	local color = flag and Color3.new(1, 1, 1) or ProfileBackdropColors.GetColor(v7)

	for _, label in ipairs(v6.labels) do
		label.ImageColor3 = color
	end
end

local uDim = UDim2.fromScale(0.5, 0.5)
local vector = Vector2.new(0.5, 0.5)

function Render.SetStickerTextOnly(guiObject, value: string?)
	if not (guiObject and guiObject:IsA("GuiObject")) then
		return
	end

	local v6

	if type(value) == "string" then
		v6 = Sources.IsTextOnly(value)
	else
		v6 = false
	end

	local label = guiObject:FindFirstChild("Label", true)

	if label and label:IsA("TextLabel") then
		if label:GetAttribute("ProfileAuthoredLabelPosition") == nil then
			label:SetAttribute("ProfileAuthoredLabelPosition", label.Position)
			label:SetAttribute("ProfileAuthoredLabelSize", label.Size)
			label:SetAttribute("ProfileAuthoredLabelAnchor", label.AnchorPoint)
			label:SetAttribute("ProfileAuthoredLabelWrapped", label.TextWrapped)
		end

		local profileAuthoredLabelSize = label:GetAttribute("ProfileAuthoredLabelSize")

		if v6 then
			label.Text = Sources.StickerText(value)
			label.Position = uDim
			label.AnchorPoint = vector
			label.Size = UDim2.new(
				profileAuthoredLabelSize.X.Scale,
				profileAuthoredLabelSize.X.Offset,
				profileAuthoredLabelSize.Y.Scale * 1.5,
				(math.round(profileAuthoredLabelSize.Y.Offset * 1.5))
			)
			label.TextWrapped = true
			label.Visible = true
		else
			label.Position = label:GetAttribute("ProfileAuthoredLabelPosition")
			label.AnchorPoint = label:GetAttribute("ProfileAuthoredLabelAnchor")
			label.Size = profileAuthoredLabelSize
			label.TextWrapped = label:GetAttribute("ProfileAuthoredLabelWrapped")
		end
	end

	for _, childName in ipairs({ "ImageLabel", "ImageShadow" }) do
		local guiObject2 = guiObject:FindFirstChild(childName, true)

		if guiObject2 and guiObject2:IsA("GuiObject") then
			guiObject2.Visible = not v6
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setPrintEffect(thumbnail, effect: string?)
	if thumbnail.effectKey == effect then
		return
	end

	if thumbnail.effectHandle then
		thumbnail.effectHandle.Stop()
		thumbnail.effectHandle = nil
	end

	thumbnail.effectKey = effect

	if effect then
		thumbnail.effectHandle = ProfileEffects.Start(effect, thumbnail.background)
	end
end

function Render.StopThumbnailEffects(p)
	if not (p and p.sections) then
		return
	end

	for _, section in pairs(p.sections) do
		local thumbnail = section and section.types and section.types.Thumbnail
		local thumbnail2 = thumbnail and thumbnail.thumbnail

		if not (thumbnail2 and thumbnail2.effectHandle) then
			continue
		end

		thumbnail2.effectHandle.Stop()
		thumbnail2.effectHandle = nil
		thumbnail2.effectKey = nil
	end
end

local function applyThumbnail(type2, p)
	local thumbnail = type2.thumbnail
	local profileCard = p.ProfileCard
	local thumbnail2

	if type(profileCard) == "table" then
		thumbnail2 = profileCard.Thumbnail or nil
	end

	if not (thumbnail and thumbnail.frame) then
		return
	end

	if type(thumbnail2) == "table" then
		local v6 = thumbnail.background and thumbnail.background:IsA("ImageLabel") and (ProfileBackgrounds.Get(thumbnail2.Background) or ProfileBackgrounds.Get(ProfileBackgrounds.DefaultKey))

		if v6 then
			thumbnail.background.Image = v6.Image
			setPrintEffect(thumbnail, v6.Effect) -- equivalent call inferred; original call site unknown
		end

		local subject = thumbnail2.Subject or ""
		local visible

		if thumbnail2.SubjectMode == "Model" then
			visible = subject ~= ""
		else
			visible = false
		end

		if thumbnail.subject and thumbnail.subject:IsA("ImageLabel") then
			local describe = UITemplates.Describe(UITemplates.Types.Toon, subject)
			thumbnail.subject.Image = describe.Image
			thumbnail.subject.Visible = not visible and describe.Image ~= ""
		end

		if thumbnail.viewport then
			thumbnail.viewport.Visible = visible

			if visible then
				task.spawn(ToonViewport.Show, thumbnail.viewport, subject, thumbnail2.SubjectSkin or "")
			else
				ToonViewport.Clear(thumbnail.viewport)
			end
		end

		if thumbnail.sticker and thumbnail.sticker:IsA("GuiObject") then
			UITemplates.Release(thumbnail.sticker)
			local sticker = thumbnail2.Sticker
			local visible2

			if type(sticker) == "string" then
				visible2 = sticker ~= ""
			else
				visible2 = false
			end

			thumbnail.sticker.Visible = visible2

			if visible2 then
				local populate = UITemplates.Populate(thumbnail.sticker, UITemplates.Types.Sticker, sticker, {
					owned = true
				})
				local label = thumbnail.sticker:FindFirstChild("Label", true)

				if label and label:IsA("TextLabel") then
					label.Text = populate.Description or ""
					label.Visible = true
				end

				local textButton = thumbnail.sticker:FindFirstChild("TextButton", true)

				if textButton and textButton:IsA("GuiButton") then
					textButton.Active = false
					textButton.Visible = false
				end

				Render.SetStickerTextOnly(thumbnail.sticker, sticker)
			end
		end

		if thumbnail.artFrame and thumbnail.artFrame:IsA("ImageLabel") then
			local frame = thumbnail2.Frame
			local v8

			if type(frame) == "string" and frame ~= "" then
				v8 = ProfileFrames.Get(frame) or nil
			end

			local enabled

			if v8 == nil then
				enabled = false
			else
				enabled = v8.Enabled
			end

			thumbnail.artFrame.Visible = enabled

			if enabled then
				thumbnail.artFrame.Image = v8.Image

				if v8.Color then
					thumbnail.artFrame.BackgroundColor3 = v8.Color
					thumbnail.artFrame.BackgroundTransparency = v8.Image == "" and 0 or 1
				end
			end
		end
	else
		setVisible(thumbnail.frame, false) -- equivalent call inferred; original call site unknown
	end
end

local function applySection(data, p, p2: string)
	local section = data.sections[p2]
	local profileCard = p.ProfileCard
	local v6 = type(profileCard) ~= "table" and {} or profileCard.Sections or {}
	local v7

	if type(v6) == "table" then
		v7 = v6[p2] or nil
	end

	if not section or not section.frame or type(v7) ~= "table" then
		return
	end

	local type2 = v7.Type
	local v8 = type(v7.Items) ~= "table" and {} or v7.Items or {}
	local isEmptyType = ProfileCardConfig.IsEmptyType(type2)
	local isComposite = ProfileCardConfig.IsComposite(type2)
	setText(section.typeLabel, isEmptyType and "" or ProfileCardConfig.GetTypeDisplayName(type2)) -- equivalent call inferred; original call site unknown

	if type(v7.Position) == "number" then
		section.frame.LayoutOrder = v7.Position
	end

	section.frame:SetAttribute("SectionType", (tostring(type2)))
	section.frame:SetAttribute("Empty", isEmptyType)
	section.frame:SetAttribute("Composite", isComposite)

	for k, type3 in pairs(section.types) do
		setVisible(type3.frame, k == type2) -- equivalent call inferred; original call site unknown
	end

	local type3 = section.types[type2]

	if type3 then
		setVisible(section.noOp, not (isEmptyType or isComposite) and #v8 == 0) -- equivalent call inferred; original call site unknown

		if isEmptyType then
			data._sectionKeys[p2] = sectionKey(v7)
		elseif isComposite then
			if type2 == "Thumbnail" then
				applyThumbnail(type3, p)
			end

			data._sectionKeys[p2] = sectionKey(v7)
		else
			local scroll = type3.scroll

			if not scroll then
				warn("[Profiles] " .. p2 .. " type " .. type2 .. " has no ScrollingFrame")
				return
			end

			local v11 = sectionKey(v7)

			if data._sectionKeys[p2] == v11 then
				if type2 == "Stats" then
					for _, guiObject in ipairs(scroll:GetChildren()) do
						if not (guiObject:IsA("GuiObject") and guiObject:GetAttribute("TemplateKey") ~= nil) then
							continue
						end

						local itemId = guiObject:GetAttribute("ItemId")

						if not (type(itemId) == "string" and itemId ~= "") then
							continue
						end

						local populate = UITemplates.Populate
						local stat = UITemplates.Types.Stat
						local v13 = statValue(p, itemId) -- equivalent call inferred; original call site unknown
						populate(guiObject, stat, itemId, {
							value = v13
						})
					end
				end
			else
				data._sectionKeys[p2] = v11
				clearRendered(scroll)
				local template = type3.template or v[type2]
				local v12 = ProfileCardConfig.TypeToDescriptorType[type2]

				if not (template and v12) then
					warn("[Profiles] no entry template for " .. tostring(type2))
					return
				end

				local hasFixedSlots = ProfileCardConfig.HasFixedSlots(type2)
				local count = #v8

				if hasFixedSlots then
					count = math.max(count, ProfileCardConfig.GetLimit(p2, type2))
				end

				local v13

				if hasFixedSlots then
					v13 = #v8 + 1 or nil
				end

				if type3.addContentButton then
					type3.addContentButton.LayoutOrder = v13 or 1000
				end

				for i = 1, count do
					local v14 = v8[i]
					local v15 = v14 == nil
					local v16 = {
						parent = scroll,
						layoutOrder = (hasFixedSlots or not v15) and i or i + 2000,
						styleController = data.controller.styleController,
						stylesheet = 0,
						owned = 0
					}
					local stylesheet = v4[type2]

					if stylesheet then
						if typeof(template) == "Instance" and template:GetAttribute("stylesheet") then
							stylesheet = nil
						end
					else
						stylesheet = nil
					end

					v16.stylesheet = stylesheet
					v16.owned = not v15

					if v2[type2] then
						v16.useIcon = true
						v16.hideShadow = true
					end

					if v15 then
						local v18 = UITemplates.Render(template, v12, "", v16)

						if v18 then
							setVisible(v18:FindFirstChild("Margin"), false) -- equivalent call inferred; original call site unknown

							if i == v13 then
								v18:SetAttribute("AddSlot", true)
							end
						end
					else
						if type2 == "Stats" then
							local v18 = statValue(p, v14) -- equivalent call inferred; original call site unknown
							v16.value = v18
						elseif type2 == "Medals" then
							local dreamJournal = p.DreamJournal
							local v18 = dreamJournal and dreamJournal.Achievements and dreamJournal.Achievements[v14]
							local v19 = (type(v18) ~= "table" or type(v18.Progress) ~= "number") and 0 or v18.Progress or 0
							local requirement = UITemplates.Describe(UITemplates.Types.Medal, v14).Attributes.Requirement or 0
							v16.progress = requirement > 0 and math.clamp(v19 / requirement * 100, 0, 100) or 0
						end

						local parent = UITemplates.Render(template, v12, v14, v16)

						if parent and type2 == "Toons" then
							ToonCard.Decorate(parent, v14, p)
						end

						if parent and type2 == "Stickers" then
							local label = parent:FindFirstChild("Label", true)

							if label and label:IsA("TextLabel") then
								label.Visible = false
							end
						end

						if parent and data.removeButtonTemplate then
							local clone = data.removeButtonTemplate:Clone()
							clone.Name = "RemoveButton"
							clone.Visible = false
							clone.Parent = parent

							if clone:IsA("GuiButton") then
								local v19 = v14
								clone.Activated:Connect(function()
									if data.onRemoveItem then
										data.onRemoveItem(p2, v19)
									end
								end)
							end
						end
					end
				end
			end
		end
	else
		warn("[Profiles] " .. p2 .. " has no Types frame for " .. tostring(type2))
		data._sectionKeys[p2] = sectionKey(v7)
	end
end

function Render.Apply(p, p2)
	if not p or type(p2) ~= "table" then
		return
	end

	local nameLabel = p.nameLabel
	local displayName = p2.DisplayName or ""
	setText(nameLabel, displayName) -- equivalent call inferred; original call site unknown
	local v6, v7 = applyBackdropImage(p, p2)
	applyBackdropColor(p, p2, v6, v7)
	applyTitle(p, p2)
	applyTrinketSlots(p, p2)
	applyFavorites(p, p2)

	for _, v8 in ipairs(ProfileCardConfig.SlotOrder) do
		applySection(p, p2, v8)
	end

	Render.SetEditable(p, p2.IsSelf == true and p.editingEnabled ~= false, p2)
end

function Render.SetEditable(data, flag: boolean, p)
	local visible2 = flag and data.page:GetAttribute("EditMode") == true
	local v7

	if type(p) == "table" then
		v7 = p.IsSelf ~= true
	else
		v7 = false
	end

	setInteractable(data.headerFrame, not v7) -- equivalent call inferred; original call site unknown
	setInteractable(data.favoritesFrame, not v7) -- equivalent call inferred; original call site unknown
	setVisible(data.editButton, flag and not visible2) -- equivalent call inferred; original call site unknown
	setVisible(data.confirmButton, visible2) -- equivalent call inferred; original call site unknown
	setVisible(data.backdropButton, visible2) -- equivalent call inferred; original call site unknown
	local profileCard

	if type(p) == "table" then
		profileCard = p.ProfileCard or nil
	end

	local isDefault = ProfileBackdrops.IsDefault
	local v11

	if type(profileCard) == "table" then
		v11 = profileCard.BackdropImage or nil
	end

	local default = isDefault(v11)
	setVisible(data.editColorButton, visible2 and default) -- equivalent call inferred; original call site unknown
	setVisible(data.titleEditButton, visible2) -- equivalent call inferred; original call site unknown

	for _, v13 in ipairs(ProfileCardConfig.FavoriteOrder) do
		local favorite = data.favorites[v13]

		if not favorite then
			continue
		end

		setVisible(favorite.empty, visible2 and not favorite.filled) -- equivalent call inferred; original call site unknown
		setVisible(favorite.editButton, visible2) -- equivalent call inferred; original call site unknown
	end

	local sections

	if type(p) == "table" and type(p.ProfileCard) == "table" then
		sections = p.ProfileCard.Sections
	end

	for _, v13 in ipairs(ProfileCardConfig.SlotOrder) do
		local section = data.sections[v13]

		if not (section and section.frame) then
			continue
		end

		local empty = section.frame:GetAttribute("Empty") == true
		local v14 = visible2 and section.frame:GetAttribute("Editing") == true
		section.frame.ZIndex = section.baseZIndex + (v14 and 10 or 0)
		setVisible(section.editButton, visible2 and not (empty or v14)) -- equivalent call inferred; original call site unknown
		setVisible(section.confirmButton, v14) -- equivalent call inferred; original call site unknown
		setVisible(section.controls, v14) -- equivalent call inferred; original call site unknown
		setVisible(section.changeTypeButton, v14) -- equivalent call inferred; original call site unknown
		setVisible(section.deleteButton, v14 and not empty) -- equivalent call inferred; original call site unknown
		setVisible(section.moveLeftButton, v14 and ProfileCardConfig.CanMove(sections, v13, -1)) -- equivalent call inferred; original call site unknown
		setVisible(section.moveRightButton, v14 and ProfileCardConfig.CanMove(sections, v13, 1)) -- equivalent call inferred; original call site unknown
		local v19

		if type(sections) == "table" then
			v19 = sections[v13] or nil
		end

		local v20 = (type(v19) ~= "table" or type(v19.Items) ~= "table") and 0 or #v19.Items or 0
		local type2

		if type(v19) == "table" then
			type2 = v19.Type or nil
		end

		local v21 = type2 == "Stickers" or ProfileCardConfig.IsComposite(type2)
		setInteractable(section.frame, not v7 or v21) -- equivalent call inferred; original call site unknown

		for k, type3 in pairs(section.types) do
			setVisible(type3.addSectionButton, visible2) -- equivalent call inferred; original call site unknown
			local v23 = v20 < ProfileCardConfig.GetLimit(v13, k)
			local active = v14 and v23 and not (ProfileCardConfig.IsEmptyType(k) or ProfileCardConfig.IsComposite(k))
			setVisible(type3.addContentButton, active) -- equivalent call inferred; original call site unknown

			if type3.addContentClickable then
				type3.addContentClickable.Active = active
			end

			if type3.scroll then
				for _, guiObject in ipairs(type3.scroll:GetChildren()) do
					if not (guiObject:IsA("GuiObject") and guiObject:GetAttribute("TemplateKey") ~= nil) then
						continue
					end

					local removeButton = guiObject:FindFirstChild("RemoveButton", true)

					if removeButton and removeButton:IsA("GuiButton") then
						removeButton.Visible = v14
						removeButton.Active = v14
					end

					if guiObject:GetAttribute("TemplateType") == UITemplates.Types.Sticker then
						local textButton = guiObject:FindFirstChild("TextButton", true)

						if textButton and textButton:IsA("GuiButton") then
							textButton.Active = not visible2
							textButton.Interactable = not visible2
						end
					end

					if guiObject:GetAttribute("AddSlot") == true then
						guiObject.Visible = not active
					end
				end
			end

			if not type3.thumbnail then
				continue
			end

			local visible = v14 and type3.frame.Visible
			setVisible(type3.thumbnail.backgroundButton, visible) -- equivalent call inferred; original call site unknown
			setVisible(type3.thumbnail.subjectButton, visible) -- equivalent call inferred; original call site unknown
			setVisible(type3.thumbnail.stickerButton, visible) -- equivalent call inferred; original call site unknown
			setVisible(type3.thumbnail.frameButton, visible) -- equivalent call inferred; original call site unknown
		end
	end
end

function Render:Invalidate()
	if self then
		self._sectionKeys = {}
		self._favoritesKey = nil
	end
end

return Render