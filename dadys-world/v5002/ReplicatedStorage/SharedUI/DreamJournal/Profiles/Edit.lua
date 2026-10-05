local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local Network = require(ReplicatedStorage.SharedUtils.Network)
local DisplayMessage = require(ReplicatedStorage.Modules.DisplayMessage)
local UITemplates = require(ReplicatedStorage.SharedUtils.UITemplates)
local ProfileCardConfig = require(ReplicatedStorage.SharedData.ProfileCardConfig)
local ProfileStats = require(ReplicatedStorage.SharedData.ProfileStats)
local ProfileBackdropColors = require(ReplicatedStorage.SharedData.ProfileBackdropColors)
local ProfileFrames = require(ReplicatedStorage.SharedData.ProfileFrames)
local ProfileBackdrops = require(ReplicatedStorage.SharedData.ProfileBackdrops)
local Sources = require(script.Parent.Sources)
local Render = require(script.Parent.Render)
local ToonCard = require(script.Parent.ToonCard)
local Edit = {}
Edit.__index = Edit
local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v = {
	Toons = true,
	Twisteds = true,
	Trinkets = true,
	Backgrounds = true,
	Backdrops = true
}
local v2 = {
	Toons = "Toon",
	Twisteds = "Twisted",
	Trinkets = "Trinket"
}
local v3 = {
	Twisteds = "You haven’t encountered any yet"
}
local v4 = {
	Toons = true,
	Trinkets = true
}

local function roundImage(guiObject)
	if not (guiObject and guiObject:IsA("GuiObject")) then
		return
	end

	local v5 = guiObject:FindFirstChildOfClass("UICorner")

	if not v5 then
		v5 = Instance.new("UICorner")
		v5.Parent = guiObject
	end

	v5.CornerRadius = UDim.new(1, 0)
end

local v5 = {
	["Thumbnail.Background"] = {
		entryType = "Backgrounds",
		header = "Choose a background"
	},
	["Thumbnail.Sticker"] = {
		entryType = "Stickers",
		header = "Choose a sticker"
	},
	["Thumbnail.Frame"] = {
		entryType = "Frames",
		header = "Choose a frame"
	},
	BackdropImage = {
		entryType = "Backdrops",
		header = "Choose a backdrop"
	}
}

local function favoriteTargetOf(p: string)
	return "Favorites." .. p
end

local function favoriteSlotFromTarget(value: string)
	local v6 = string.match(value, "^Favorites%.(.+)$")

	if v6 and ProfileCardConfig.GetFavoriteSlot(v6) then
		return v6
	end

	return nil
end

local v6 = {
	Medals = "MedalCard",
	Toons = "ItemCard",
	Twisteds = "ItemCard",
	Trinkets = "ItemCard",
	Stickers = "ItemCard",
	Backgrounds = "ItemCard",
	Frames = "ItemCard",
	Backdrops = "ItemCard"
}
local v7 = {
	Frames = "Backgrounds",
	Backdrops = "Backgrounds"
}
local v8 = {
	Stats = UITemplates.Types.Stat,
	Medals = UITemplates.Types.Medal,
	Toons = UITemplates.Types.Toon,
	Twisteds = UITemplates.Types.Twisted,
	Trinkets = UITemplates.Types.Trinket,
	Stickers = UITemplates.Types.Sticker,
	Backgrounds = UITemplates.Types.Background,
	Frames = UITemplates.Types.Frame,
	Backdrops = UITemplates.Types.Backdrop
}
local deepCopy

deepCopy = function(items)
	if type(items) ~= "table" then
		return items
	end

	local result = {}

	for k, item in pairs(items) do
		result[k] = deepCopy(item)
	end

	return result
end

local function normalizeDraft(profileCard)
	local v9 = deepCopy(profileCard)
	local v10 = type(v9) ~= "table" and {} or v9
	v10.Favorites = type(v10.Favorites) ~= "table" and {} or v10.Favorites or {}

	for _, v11 in ipairs(ProfileCardConfig.FavoriteOrder) do
		local favoriteSlot = ProfileCardConfig.GetFavoriteSlot(v11)
		local favorite = v10.Favorites[v11]

		if type(favorite) ~= "table" then
			favorite = {
				Type = favoriteSlot.Default,
				Id = ""
			}
			v10.Favorites[v11] = favorite
		end

		if not ProfileCardConfig.IsFavoriteTypeAllowed(v11, favorite.Type) then
			favorite.Type = favoriteSlot.Default
			favorite.Id = ""
		end

		if type(favorite.Id) ~= "string" then
			favorite.Id = ""
		end
	end

	v10.Thumbnail = type(v10.Thumbnail) ~= "table" and {} or v10.Thumbnail or {}
	v10.Thumbnail.Background = type(v10.Thumbnail.Background) ~= "string" and "Default" or v10.Thumbnail.Background or "Default"

	if v10.Thumbnail.SubjectType ~= nil then
		if v10.Thumbnail.SubjectType == "Twisted" then
			v10.Thumbnail.Subject = ""
			v10.Thumbnail.SubjectSkin = ""
		end

		v10.Thumbnail.SubjectType = nil
	end

	v10.Thumbnail.Subject = type(v10.Thumbnail.Subject) ~= "string" and "" or v10.Thumbnail.Subject or ""
	v10.Thumbnail.SubjectSkin = type(v10.Thumbnail.SubjectSkin) ~= "string" and "" or v10.Thumbnail.SubjectSkin or ""

	if not ProfileCardConfig.IsSubjectAllowed(v10.Thumbnail.Subject) then
		v10.Thumbnail.Subject = ""
		v10.Thumbnail.SubjectSkin = ""
	end

	v10.Thumbnail.SubjectMode = v10.Thumbnail.SubjectMode == "Model" and "Model" or "Image"
	v10.Thumbnail.Sticker = type(v10.Thumbnail.Sticker) ~= "string" and "" or v10.Thumbnail.Sticker or ""
	v10.Thumbnail.Frame = type(v10.Thumbnail.Frame) ~= "string" and "" or v10.Thumbnail.Frame or ""
	v10.BackdropImage = ProfileBackdrops.Resolve(v10.BackdropImage)
	v10.BackdropColor = ProfileBackdropColors.Normalize(v10.BackdropColor)
	v10.Sections = type(v10.Sections) ~= "table" and {} or v10.Sections or {}

	for _, v11 in ipairs(ProfileCardConfig.SlotOrder) do
		local section = v10.Sections[v11]

		if type(section) ~= "table" then
			section = {
				Type = ProfileCardConfig.NoneType,
				Items = {},
				Position = ProfileCardConfig.DefaultPositions[v11]
			}
			v10.Sections[v11] = section
		end

		if not ProfileCardConfig.IsTypeAllowed(v11, section.Type) then
			section.Type = ProfileCardConfig.NoneType
			section.Items = {}
		end

		if type(section.Items) ~= "table" then
			section.Items = {}
		end

		if not (ProfileCardConfig.IsEmptyType(section.Type) or ProfileCardConfig.IsComposite(section.Type)) then
			continue
		end

		section.Items = {}
	end

	if not ProfileCardConfig.ValidatePositions(v10.Sections) then
		for _, v11 in ipairs(ProfileCardConfig.SlotOrder) do
			v10.Sections[v11].Position = ProfileCardConfig.DefaultPositions[v11]
		end
	end

	v10.Version = nil
	return v10
end

function Edit.new(controller, view, page)
	local object = setmetatable({
		controller = controller,
		view = view,
		page = page,
		draft = nil,
		snapshot = nil,
		pickerSelection = {},
		pickerTarget = "",
		pickerType = "",
		pickerLimit = 1,
		pickerExclude = {},
		typePickerSlot = "",
		saving = false
	}, Edit)

	function view.onRemoveItem(p4: string, p5: string)
		object:RemoveItem(p4, p5)
	end

	object:_wire()
	return object
end

function Edit:SetSnapshot(snapshot)
	self.snapshot = snapshot
end

function Edit:IsEditing()
	return self.page:GetAttribute("EditMode") == true
end

function Edit:GetDisplaySnapshot()
	if not self.snapshot then
		return nil
	end

	if not (self:IsEditing() and self.draft) then
		return self.snapshot
	end

	local result = {}

	for k, v9 in pairs(self.snapshot) do
		result[k] = v9
	end

	result.ProfileCard = self.draft
	return result
end

function Edit:_repaint()
	local displaySnapshot = self:GetDisplaySnapshot()

	if displaySnapshot then
		Render.Apply(self.view, displaySnapshot)
	end
end

function Edit:_setDirty(dirty: boolean)
	self.page:SetAttribute("Dirty", dirty)
end

function Edit:_showBlockerFor(guiObject)
	local popupBlocker = self.view.popupBlocker

	if not (popupBlocker and guiObject and guiObject:IsA("GuiObject")) then
		return
	end

	if guiObject.ZIndex <= 1 then
		warn("[Profiles] " .. guiObject.Name .. " ZIndex is too low to block clicks behind it")
	end

	popupBlocker.ZIndex = guiObject.ZIndex - 1
	popupBlocker.Visible = true
end

function Edit:_animatePopupIn(p)
	local frame = p and p.frame
	local basePosition = p and p.basePosition
	local tweens = self.controller.tweens

	if not (frame and basePosition and tweens) then
		return
	end

	local _popupTween = self._popupTween
	self._popupTween = nil

	if _popupTween then
		_popupTween:Cancel()
		_popupTween:Destroy()
	end

	frame.Position = basePosition + UDim2.fromScale(0, 0.04)
	self._popupTween = tweens.playTween(frame, tweenInfo, {
		Position = basePosition
	})
end

function Edit:_hideBlocker()
	local popupBlocker = self.view.popupBlocker

	if popupBlocker then
		popupBlocker.Visible = false
	end
end

function Edit:_closePopupsExcept(p: string?)
	if p ~= "picker" then
		self:ClosePicker()
	end

	if p ~= "typePicker" then
		self:CloseTypePicker()
	end

	if p ~= "confirm" then
		self:CloseConfirm()
	end
end

function Edit:SetSectionEditing(p: string, flag: boolean)
	self:_closePopupsExcept(nil)

	for _, v9 in ipairs(ProfileCardConfig.SlotOrder) do
		local section = self.view.sections[v9]

		if section and section.frame then
			section.frame:SetAttribute("Editing", flag and v9 == p)
		end
	end

	Render.SetEditable(self.view, true, self:GetDisplaySnapshot())
end

function Edit:_clearSectionEditing()
	for _, v9 in ipairs(ProfileCardConfig.SlotOrder) do
		local section = self.view.sections[v9]

		if section and section.frame then
			section.frame:SetAttribute("Editing", false)
		end
	end
end

function Edit:Enter()
	if self:IsEditing() or not self.snapshot then
		return
	end

	self.draft = normalizeDraft(self.snapshot.ProfileCard)
	self.page:SetAttribute("EditMode", true)
	self:_setDirty(false)
	self:_clearSectionEditing()
	Render.Invalidate(self.view)
	self:_repaint()
end

function Edit:Exit(flag: boolean)
	if not self:IsEditing() then
		return
	end

	self:ClosePicker()
	self:CloseTypePicker()
	self:CloseConfirm()
	self:_clearSectionEditing()
	self.page:SetAttribute("EditMode", false)
	self:_setDirty(false)

	if flag then
		self.draft = nil
	end

	Render.Invalidate(self.view)

	if self.page.Visible and self.controller.gui.Visible then
		self:_repaint()
	end
end

function Edit:Save()
	if not self:IsEditing() or not self.draft or self.saving then
		return
	end

	self.saving = true
	local profileCardSave, v10 = Network:Get("ProfileCardSave", (deepCopy(self.draft)))
	self.saving = false

	if profileCardSave == true then
		self.draft = nil
		self:Exit(true)
		return true
	else
		if profileCardSave == false then
			DisplayMessage(tostring(v10 or "That profile couldn't be saved."), nil, nil, true)
		else
			DisplayMessage("Couldn't save your profile just then. Try again in a moment.", nil, nil, true)
		end

		return false
	end
end

function Edit:SetSectionType(p: string, p2: string)
	if not (self.draft and ProfileCardConfig.IsTypeAllowed(p, p2)) then
		return
	end

	local section = self.draft.Sections[p]

	if section.Type == p2 then
		return
	end

	section.Type = p2
	section.Items = {}
	self:_setDirty(true)
	Render.Invalidate(self.view)
	self:_repaint()
end

function Edit:MoveSection(p: string, p2: number)
	if not self.draft then
		return
	end

	self:_closePopupsExcept(nil)
	local sections = self.draft.Sections
	local section = sections[p]

	if type(section) ~= "table" then
		return
	end

	local position = section.Position + p2

	if position < 1 or ProfileCardConfig.PositionCount < position then
		return
	end

	for _, v10 in ipairs(ProfileCardConfig.SlotOrder) do
		if not (v10 ~= p and sections[v10].Position == position) then
			continue
		end

		sections[v10].Position = section.Position
		section.Position = position
		self:_setDirty(true)
		self:_repaint()
		break
	end
end

function Edit:RemoveItem(p: string, p2: string)
	if not self.draft then
		return
	end

	local section = self.draft.Sections[p]

	if type(section) ~= "table" or type(section.Items) ~= "table" then
		return
	end

	if ProfileCardConfig.IsEmptyType(section.Type) or ProfileCardConfig.IsComposite(section.Type) then
		return
	end

	local index = table.find(section.Items, p2)

	if not index then
		return
	end

	table.remove(section.Items, index)
	self:_setDirty(true)
	Render.Invalidate(self.view)
	self:_repaint()
end

function Edit:DeleteSection(p: string)
	if not self.draft then
		return
	end

	local section = self.draft.Sections[p]

	if type(section) ~= "table" or ProfileCardConfig.IsEmptyType(section.Type) then
		return
	end

	section.Type = ProfileCardConfig.NoneType
	section.Items = {}
	self:_setDirty(true)
	self:SetSectionEditing(p, false)
	Render.Invalidate(self.view)
	self:_repaint()
end

function Edit:CloseConfirm()
	self._confirmAction = nil
	self.page:SetAttribute("ConfirmOpen", false)
	local confirmDialog = self.view.confirmDialog

	if confirmDialog and confirmDialog.frame then
		confirmDialog.frame.SelectionGroup = false
		local selectedObject = GuiService.SelectedObject

		if selectedObject and selectedObject:IsDescendantOf(confirmDialog.frame) then
			GuiService.SelectedObject = nil
		end

		confirmDialog.frame.Visible = false
	end

	self:_hideBlocker()
end

function Edit:CanConfirm()
	local confirmDialog = self.view.confirmDialog
	return confirmDialog ~= nil and confirmDialog.frame ~= nil and confirmDialog.yesButton ~= nil and confirmDialog.yesButton:IsA("GuiButton")
end

function Edit:OpenConfirm(text: string, text2: string, confirmAction)
	local confirmDialog = self.view.confirmDialog

	if not self:CanConfirm() then
		warn("[Profiles] no usable ConfirmDialog authored; refusing to act unconfirmed")
		return false
	end

	self:_closePopupsExcept("confirm")
	self._confirmAction = confirmAction
	self.page:SetAttribute("ConfirmOpen", true)

	if confirmDialog.headerLabel and confirmDialog.headerLabel:IsA("TextLabel") then
		confirmDialog.headerLabel.Text = text
	end

	if confirmDialog.messageLabel and confirmDialog.messageLabel:IsA("TextLabel") then
		confirmDialog.messageLabel.Text = text2
	end

	confirmDialog.frame.Visible = true
	self:_showBlockerFor(confirmDialog.frame)
	self:_animatePopupIn(confirmDialog)
	confirmDialog.frame.SelectionGroup = true
	confirmDialog.frame.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
	confirmDialog.frame.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
	confirmDialog.frame.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
	confirmDialog.frame.SelectionBehaviorRight = Enum.SelectionBehavior.Stop

	if UserInputService.PreferredInput ~= Enum.PreferredInput.Gamepad then
		return true
	end

	local noButton = confirmDialog.noButton or confirmDialog.yesButton

	if noButton and noButton:IsA("GuiButton") then
		noButton.Selectable = true
		GuiService.SelectedObject = noButton
	end

	return true
end

function Edit:GuardLeave(callback)
	if self:IsEditing() and self.page:GetAttribute("Dirty") == true then
		if not self:CanConfirm() then
			warn("[Profiles] Back guard: cannot prompt -- ConfirmDialog/YesButton missing from the page; leaving unguarded")
			return false
		end

		if self.page:GetAttribute("ConfirmOpen") ~= true then
			return self:OpenConfirm(
				"Unsaved Changes",
				"You have unsaved changes, are you sure you want to close?",
				function()
					self:Exit(true)
					callback()
				end
			) == true
		end

		self:CloseConfirm()
		return true
	else
		local RunService = game:GetService("RunService")

		if RunService:IsStudio() then
			print(
				"[Profiles] Back guard: nothing to protect (editing =",
				self:IsEditing(),
				", dirty =",
				self.page:GetAttribute("Dirty"),
				")"
			)
		end

		return false
	end
end

function Edit:CloseTypePicker()
	self.typePickerSlot = ""
	self.page:SetAttribute("TypePickerSlot", "")

	if self.view.typePicker and self.view.typePicker.frame then
		self.view.typePicker.frame.Visible = false
	end

	self:_hideBlocker()
end

function Edit:OpenTypePicker(typePickerSlot: string)
	local typePicker = self.view.typePicker

	if not (self:IsEditing() and self.draft and typePicker and typePicker.scroll and typePicker.template) then
		return
	end

	self:_closePopupsExcept("typePicker")
	self.typePickerSlot = typePickerSlot
	self.page:SetAttribute("TypePickerSlot", typePickerSlot)
	local section = self.draft.Sections[typePickerSlot]
	local v9

	if type(section) == "table" then
		v9 = ProfileCardConfig.IsEmptyType(section.Type)
	else
		v9 = false
	end

	if typePicker.headerLabel and typePicker.headerLabel:IsA("TextLabel") then
		typePicker.headerLabel.Text = v9 and "Add Section" or "Change Section"
	end

	for _, button in ipairs(typePicker.scroll:GetChildren()) do
		if button:IsA("GuiButton") then
			button:Destroy()
		end
	end

	local v10 = {}

	for _, id in ipairs(ProfileCardConfig.GetOfferedTypes(typePickerSlot)) do
		local isTypeInUse = ProfileCardConfig.IsTypeInUse(self.draft.Sections, id, typePickerSlot)
		local typeDisplayName = ProfileCardConfig.GetTypeDisplayName(id)

		if isTypeInUse then
			typeDisplayName = typeDisplayName .. " (in use)" or typeDisplayName
		end

		table.insert(v10, {
			Id = id,
			Label = typeDisplayName,
			Disabled = isTypeInUse
		})
	end

	self:_fillListPopup(v10, function(p)
		self:SetSectionType(typePickerSlot, p)
		self:CloseTypePicker()
	end)
end

function Edit:_fillListPopup(list, callback)
	local typePicker = self.view.typePicker

	if not (typePicker and typePicker.scroll and typePicker.template) then
		return
	end

	for _, button in ipairs(typePicker.scroll:GetChildren()) do
		if button:IsA("GuiButton") then
			button:Destroy()
		end
	end

	for i, v9 in ipairs(list) do
		local clone = typePicker.template:Clone()
		clone.Name = v9.Id
		clone.LayoutOrder = i
		clone.Text = v9.Label
		clone.Visible = true
		clone.Parent = typePicker.scroll

		if v9.Color then
			clone.BackgroundColor3 = v9.Color
			clone.BackgroundTransparency = 0
		end

		clone:SetAttribute("Selected", v9.Selected == true)

		if v9.Disabled then
			clone.Active = false
			clone.Interactable = false
			clone.AutoButtonColor = false
			clone.TextTransparency = 0.55
			clone:SetAttribute("Disabled", true)
		else
			clone:SetAttribute("Disabled", false)
			local v10 = v9
			clone.Activated:Connect(function()
				callback(v10.Id)
			end)
		end
	end

	if typePicker.noOp and typePicker.noOp:IsA("GuiObject") then
		typePicker.noOp.Visible = #list == 0
	end

	if typePicker.scroll and typePicker.scroll:IsA("ScrollingFrame") then
		typePicker.scroll.CanvasPosition = Vector2.new(0, 0)
	end

	typePicker.frame.Visible = true
	self:_showBlockerFor(typePicker.frame)
	self:_animatePopupIn(typePicker)
end

function Edit:SetBackdropColor(p: string)
	if not self.draft then
		return
	end

	local normalized = ProfileBackdropColors.Normalize(p)

	if self.draft.BackdropColor == normalized then
		return
	end

	self.draft.BackdropColor = normalized
	self:_setDirty(true)
	self:_repaint()
end

function Edit:OpenColorPicker()
	if not (self:IsEditing() and self.draft) then
		return
	end

	self:_closePopupsExcept("typePicker")
	self.typePickerSlot = ""
	self.page:SetAttribute("TypePickerSlot", "")
	local typePicker = self.view.typePicker

	if typePicker and typePicker.headerLabel and typePicker.headerLabel:IsA("TextLabel") then
		typePicker.headerLabel.Text = "Choose a Color"
	end

	local normalized = ProfileBackdropColors.Normalize(self.draft.BackdropColor)
	local v9 = {}

	for _, id in ipairs(ProfileBackdropColors.GetOrdered()) do
		table.insert(v9, {
			Id = id,
			Label = ProfileBackdropColors.GetDisplayName(id),
			Color = ProfileBackdropColors.GetColor(id),
			Selected = ProfileBackdropColors.Normalize(id) == normalized
		})
	end

	self:_fillListPopup(v9, function(p)
		self:SetBackdropColor(p)
		self:CloseTypePicker()
	end)
end

function Edit:OpenSubjectPicker()
	if not (self:IsEditing() and self.draft and self.view.typePicker) then
		return
	end

	self:_closePopupsExcept("typePicker")
	local typePicker = self.view.typePicker

	if typePicker.headerLabel and typePicker.headerLabel:IsA("TextLabel") then
		typePicker.headerLabel.Text = "Choose a Character"
	end

	local v9 = {}

	for _, v10 in ipairs(Sources.ForType(self.snapshot, "Toons")) do
		if not (v10.Owned and ProfileCardConfig.IsSubjectAllowed(v10.Id)) then
			continue
		end

		local describe = UITemplates.Describe(UITemplates.Types.Toon, v10.Id)
		table.insert(v9, {
			Id = v10.Id,
			Label = describe.Name
		})
	end

	self:_fillListPopup(v9, function(p)
		self:OpenSubjectVariantPicker(p)
	end)
end

function Edit:OpenSubjectVariantPicker(subject: string)
	local typePicker = self.view.typePicker

	if not (typePicker and self.draft) then
		return
	end

	self:_closePopupsExcept("typePicker")

	if typePicker.headerLabel and typePicker.headerLabel:IsA("TextLabel") then
		typePicker.headerLabel.Text = "Choose a Look"
	end

	self:_fillListPopup(Sources.SubjectVariants(self.snapshot, subject), function(subjectSkin)
		local thumbnail = self.draft.Thumbnail
		thumbnail.Subject = subject

		if subjectSkin == ProfileCardConfig.SubjectImageOption then
			thumbnail.SubjectMode = "Image"
			thumbnail.SubjectSkin = ""
		elseif subjectSkin == ProfileCardConfig.SubjectDefaultSkin then
			thumbnail.SubjectMode = "Model"
			thumbnail.SubjectSkin = ""
		else
			thumbnail.SubjectMode = "Model"
			thumbnail.SubjectSkin = subjectSkin
		end

		self:CloseTypePicker()
		self:_setDirty(true)
		Render.Invalidate(self.view)
		self:_repaint()
	end)
end

function Edit:ClosePicker()
	self.pickerTarget = ""
	self.pickerType = ""
	self.pickerSelection = {}
	self.pickerExclude = {}
	self.page:SetAttribute("PickerType", "")
	self.page:SetAttribute("PickerTarget", "")
	self:_applyPickerLayout()

	if self.view.picker and self.view.picker.frame then
		self.view.picker.frame.Visible = false
	end

	self:_hideBlocker()
end

function Edit:OpenPicker(pickerTarget: string)
	if not (self:IsEditing() and self.draft and self.view.picker) then
		return
	end

	self:_closePopupsExcept("picker")
	local v9 = v5[pickerTarget]
	local v10 = string.match(pickerTarget, "^Favorites%.(.+)$")

	if not (v10 and ProfileCardConfig.GetFavoriteSlot(v10)) then
		v10 = nil
	end

	if v10 then
		self:_clearSectionEditing()
		Render.SetEditable(self.view, true, self:GetDisplaySnapshot())
	end

	self.pickerExclude = {}
	local type2, header, pickerLimit

	if v10 then
		local favorite = self.draft.Favorites[v10]
		type2 = favorite.Type
		local v12 = v2[type2]
		header = v12 and "Choose a favorite " .. v12 or "Choose a favorite"
		self.pickerSelection = favorite.Id == "" and {} or { favorite.Id } or {}
		pickerLimit = 1
	elseif v9 then
		type2 = v9.entryType
		header = v9.header
		self.pickerSelection = {}
		pickerLimit = 1
	else
		local section = self.draft.Sections[pickerTarget]

		if not section or ProfileCardConfig.IsEmptyType(section.Type) or ProfileCardConfig.IsComposite(section.Type) then
			return
		end

		type2 = section.Type
		self.pickerExclude = {}

		for _, item in ipairs(section.Items) do
			self.pickerExclude[item] = true
		end

		pickerLimit = math.max(0, ProfileCardConfig.GetLimit(pickerTarget, type2) - #section.Items)
		header = "Choose " .. ProfileCardConfig.GetTypeDisplayName(type2)
		self.pickerSelection = {}
	end

	self.pickerTarget = pickerTarget
	self.pickerType = type2
	self.pickerLimit = pickerLimit
	self.page:SetAttribute("PickerTarget", pickerTarget)
	self.page:SetAttribute("PickerType", type2)
	self:_populatePicker(header)
	self.view.picker.frame.Visible = true
	self:_showBlockerFor(self.view.picker.frame)
	self:_animatePopupIn(self.view.picker)
end

function Edit:_isSelected(p2: string)
	return table.find(self.pickerSelection, p2) ~= nil
end

function Edit:_updateCounter()
	local picker = self.view.picker

	if picker and picker.counterLabel and picker.counterLabel:IsA("TextLabel") then
		picker.counterLabel.Text = string.format("%d / %d", #self.pickerSelection, self.pickerLimit or 1)
	end
end

function Edit:_setCellSelected(parent, selected: boolean)
	parent:SetAttribute("Selected", selected)
	local equipped = parent:FindFirstChild("Equipped")

	if selected then
		if equipped then
			equipped.Visible = true
			return
		end

		local equippedTemplate = self.view.equippedTemplate

		if not equippedTemplate then
			return
		end

		local clone = equippedTemplate:Clone()
		clone.Name = "Equipped"
		clone.Visible = true
		clone.Parent = parent
	elseif equipped then
		equipped:Destroy()
	end
end

function Edit:_togglePick(p: string, p2)
	local index = table.find(self.pickerSelection, p)

	if index then
		table.remove(self.pickerSelection, index)
	else
		if #self.pickerSelection >= (self.pickerLimit or 1) then
			if self.pickerLimit ~= 1 then
				return
			end

			table.clear(self.pickerSelection)
		end

		table.insert(self.pickerSelection, p)
	end

	if self.view.picker and self.view.picker.scroll then
		for _, guiObject in ipairs(self.view.picker.scroll:GetChildren()) do
			if not (guiObject:IsA("GuiObject") and guiObject:GetAttribute("TemplateKey") ~= nil) then
				continue
			end

			local itemId = guiObject:GetAttribute("ItemId")
			self:_setCellSelected(guiObject, type(itemId) == "string" and (self:_isSelected(itemId) or false))
		end
	elseif p2 then
		self:_setCellSelected(p2, self:_isSelected(p))
	end

	self:_updateCounter()
end

function Edit:_applyPickerLayout()
	local picker = self.view.picker
	local scroll = picker and picker.scroll
	local uIGridLayout = scroll and scroll:FindFirstChildOfClass("UIGridLayout")

	if not uIGridLayout then
		return
	end

	local authoredCellSize = uIGridLayout:GetAttribute("AuthoredCellSize")

	if authoredCellSize == nil then
		authoredCellSize = uIGridLayout.CellSize
		uIGridLayout:SetAttribute("AuthoredCellSize", authoredCellSize)
	end

	if self.pickerType ~= "Stats" then
		uIGridLayout.CellSize = authoredCellSize
		return
	end

	local scrollBarThickness = scroll:IsA("ScrollingFrame") and scroll.ScrollBarThickness or 0
	uIGridLayout.CellSize = UDim2.new(1, -scrollBarThickness, authoredCellSize.Y.Scale, authoredCellSize.Y.Offset)
end

function Edit:_populatePicker(text: string)
	local picker = self.view.picker

	if not (picker and picker.scroll) then
		return
	end

	self:_applyPickerLayout()

	for _, guiObject in ipairs(picker.scroll:GetChildren()) do
		if not (guiObject:IsA("GuiObject") and guiObject:GetAttribute("TemplateKey") ~= nil) then
			continue
		end

		UITemplates.Release(guiObject)
		guiObject:Destroy()
	end

	if picker.headerLabel and picker.headerLabel:IsA("TextLabel") then
		picker.headerLabel.Text = text
	end

	local pickerTarget = self.pickerTarget
	local v9 = string.match(pickerTarget, "^Favorites%.(.+)$")

	if not (v9 and ProfileCardConfig.GetFavoriteSlot(v9)) then
		v9 = nil
	end

	local v10 = v9 and not ProfileCardConfig.FavoriteRequiresOwnership(self.pickerType) and {
		IgnoreOwnership = true
	} or nil
	local v11 = self.pickerTarget == "Thumbnail.Sticker"

	if v11 then
		v10 = v10 or {}
		v10.IncludeTextOnly = true
	end

	local v12 = {}

	for _, v13 in ipairs(Sources.ForType(self.snapshot, self.pickerType, v10)) do
		if not v13.Owned or self.pickerExclude[v13.Id] then
			continue
		end

		table.insert(v12, v13)
	end

	if self.pickerType == "Frames" then
		table.insert(v12, 1, {
			Id = ProfileFrames.NoneKey,
			Owned = true
		})
	end

	if picker.noOp and picker.noOp:IsA("GuiObject") then
		picker.noOp.Visible = #v12 == 0
	end

	if picker.noOpLabel then
		picker.noOpLabel.Text = v3[self.pickerType] or picker.noOpDefaultText or ""
	end

	local v13 = v7[self.pickerType] or self.pickerType
	local v14 = self.view.typeTemplates[v13] or v6[v13]
	local v15 = v8[self.pickerType]

	if not (v14 and v15) then
		warn("[Profiles] no picker template for " .. tostring(self.pickerType))
		return
	end

	local useIcon = true
	local pickerTarget2 = self.pickerTarget
	local v17 = string.match(pickerTarget2, "^Favorites%.(.+)$")

	if not (v17 and ProfileCardConfig.GetFavoriteSlot(v17)) then
		v17 = nil
	end

	if v17 == nil then
		useIcon = v4[self.pickerType] == true
	end

	local hideShadow = v[self.pickerType] == true

	for i, v19 in ipairs(v12) do
		local v20 = {
			parent = picker.scroll,
			layoutOrder = i,
			styleController = self.controller.styleController,
			owned = v19.Owned,
			useIcon = useIcon,
			hideShadow = hideShadow,
			animate = false,
			attributes = {
				Selected = self:_isSelected(v19.Id)
			}
		}

		if self.pickerType == "Stats" then
			v20.value = ProfileStats.ReadValue(self.snapshot, v19.Id)
		end

		if v19.Owned then
			local v21 = v19

			function v20.onActivated(p)
				self:_togglePick(v21.Id, p)
			end
		end

		local v21 = UITemplates.Render(v14, v15, v19.Id, v20)

		if not v21 then
			continue
		end

		self:_setCellSelected(v21, self:_isSelected(v19.Id))

		if self.pickerType == "Toons" then
			ToonCard.Decorate(v21, v19.Id, self.snapshot)
		end

		if useIcon and self.pickerType == "Twisteds" then
			roundImage(UITemplates.GetRole(v21, "Image"))
		end

		if v11 then
			Render.SetStickerTextOnly(v21, v19.Id)
		end
	end

	if picker.scroll and picker.scroll:IsA("ScrollingFrame") then
		picker.scroll.CanvasPosition = Vector2.new(0, 0)
	end

	self:_updateCounter()
end

function Edit:ConfirmPicker()
	if not self.draft or self.pickerTarget == "" then
		return
	end

	local pickerTarget = self.pickerTarget
	local v9 = string.match(pickerTarget, "^Favorites%.(.+)$")

	if not (v9 and ProfileCardConfig.GetFavoriteSlot(v9)) then
		v9 = nil
	end

	local background = self.pickerSelection[1] or ""

	if v9 then
		self.draft.Favorites[v9].Id = background
	elseif pickerTarget == "Thumbnail.Background" then
		local thumbnail = self.draft.Thumbnail

		if background == "" or not background then
			background = self.draft.Thumbnail.Background
		end

		thumbnail.Background = background
	elseif pickerTarget == "Thumbnail.Sticker" then
		self.draft.Thumbnail.Sticker = background
	elseif pickerTarget == "Thumbnail.Frame" then
		self.draft.Thumbnail.Frame = background
	elseif pickerTarget == "BackdropImage" then
		local draft = self.draft

		if background == "" or not background then
			background = ProfileBackdrops.DefaultKey
		end

		draft.BackdropImage = background
	else
		local section = self.draft.Sections[pickerTarget]

		if section then
			local limit = ProfileCardConfig.GetLimit(pickerTarget, section.Type)

			for _, v11 in ipairs(self.pickerSelection) do
				if limit <= #section.Items then
					break
				elseif not table.find(section.Items, v11) then
					table.insert(section.Items, v11)
				end
			end
		end
	end

	self:ClosePicker()
	self:_setDirty(true)
	Render.Invalidate(self.view)
	self:_repaint()
end

function Edit:_wire()
	local controller = self.controller
	local view = self.view

	if view.editButton and view.editButton:IsA("GuiButton") then
		controller:BindButton(view.editButton, function()
			self:Enter()
		end)
	end

	if view.confirmButton and view.confirmButton:IsA("GuiButton") then
		controller:BindButton(view.confirmButton, function()
			self:Save()
		end)
	end

	if view.editColorButton and view.editColorButton:IsA("GuiButton") then
		controller:BindButton(view.editColorButton, function()
			self:OpenColorPicker()
		end)
	end

	if view.backdropButton and view.backdropButton:IsA("GuiButton") then
		controller:BindButton(view.backdropButton, function()
			self:OpenPicker("BackdropImage")
		end)
	end

	for _, v9 in ipairs(ProfileCardConfig.FavoriteOrder) do
		local favorite = view.favorites[v9]

		if not favorite then
			continue
		end

		local v10 = v9

		local function openFavoritePicker()
			self:OpenPicker("Favorites." .. v10)
		end

		if favorite.button and favorite.button:IsA("GuiButton") then
			controller:BindButton(favorite.button, openFavoritePicker)
		end

		if favorite.editButton and favorite.editButton:IsA("GuiButton") then
			controller:BindButton(favorite.editButton, openFavoritePicker)
		end
	end

	for _, v9 in ipairs(ProfileCardConfig.SlotOrder) do
		local section = view.sections[v9]

		if not section then
			continue
		end

		for _, type2 in pairs(section.types) do
			if type2.addSectionButton and type2.addSectionButton:IsA("GuiButton") then
				local v10 = v9
				controller:BindButton(type2.addSectionButton, function()
					self:OpenTypePicker(v10)
				end)
			end

			if type2.addContentClickable then
				local v10 = v9
				controller:BindButton(type2.addContentClickable, function()
					self:OpenPicker(v10)
				end)
			end

			local thumbnail = type2.thumbnail

			if not thumbnail then
				continue
			end

			if thumbnail.subjectButton and thumbnail.subjectButton:IsA("GuiButton") then
				controller:BindButton(thumbnail.subjectButton, function()
					self:OpenSubjectPicker()
				end)
			end

			local v10 = {
				{ thumbnail.backgroundButton, "Thumbnail.Background" },
				{ thumbnail.stickerButton, "Thumbnail.Sticker" },
				{ thumbnail.frameButton, "Thumbnail.Frame" }
			}

			for _, v11 in ipairs(v10) do
				local button = v11[1]
				local v12 = v11[2]

				if not (button and button:IsA("GuiButton")) then
					continue
				end

				local v13 = v12
				controller:BindButton(button, function()
					self:OpenPicker(v13)
				end)
			end
		end

		if section.editButton and section.editButton:IsA("GuiButton") then
			local v10 = v9
			controller:BindButton(section.editButton, function()
				self:SetSectionEditing(v10, true)
			end)
		end

		if section.confirmButton and section.confirmButton:IsA("GuiButton") then
			local v10 = v9
			controller:BindButton(section.confirmButton, function()
				self:SetSectionEditing(v10, false)
			end)
		end

		if section.changeTypeButton and section.changeTypeButton:IsA("GuiButton") then
			local v10 = v9
			controller:BindButton(section.changeTypeButton, function()
				self:OpenTypePicker(v10)
			end)
		end

		if section.deleteButton and section.deleteButton:IsA("GuiButton") then
			local v10 = v9
			controller:BindButton(section.deleteButton, function()
				local v11 = self.draft and self.draft.Sections[v10]

				if v11 and not ProfileCardConfig.IsEmptyType(v11.Type) then
					self:OpenConfirm(
						"Remove Section",
						"Remove this " .. ProfileCardConfig.GetTypeDisplayName(v11.Type) .. " section?",
						function()
							self:DeleteSection(v10)
						end
					)
				end
			end)
		end

		if section.moveLeftButton and section.moveLeftButton:IsA("GuiButton") then
			local v10 = v9
			controller:BindButton(section.moveLeftButton, function()
				self:MoveSection(v10, -1)
			end)
		end

		if not (section.moveRightButton and section.moveRightButton:IsA("GuiButton")) then
			continue
		end

		local v10 = v9
		controller:BindButton(section.moveRightButton, function()
			self:MoveSection(v10, 1)
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function bindClose(p, fn)
		if p and p.closeButton and p.closeButton:IsA("GuiButton") then
			controller:BindButton(p.closeButton, fn)
		end
	end

	local function fn()
		self:ClosePicker()
	end

	bindClose(view.picker, fn) -- equivalent call inferred; original call site unknown

	local function fn2()
		self:CloseTypePicker()
	end

	bindClose(view.typePicker, fn2) -- equivalent call inferred; original call site unknown

	if view.picker and view.picker.confirmButton and view.picker.confirmButton:IsA("GuiButton") then
		controller:BindButton(view.picker.confirmButton, function()
			self:ConfirmPicker()
		end)
	end

	local confirmDialog = view.confirmDialog

	if confirmDialog then
		if confirmDialog.yesButton and confirmDialog.yesButton:IsA("GuiButton") then
			controller:BindButton(confirmDialog.yesButton, function()
				local _confirmAction = self._confirmAction
				self:CloseConfirm()

				if _confirmAction then
					_confirmAction()
				end
			end)
		end

		if confirmDialog.noButton and confirmDialog.noButton:IsA("GuiButton") then
			controller:BindButton(confirmDialog.noButton, function()
				self:CloseConfirm()
			end)
		end
	end
end

return Edit