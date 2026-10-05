local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "AvatarEditorReworkABTest"
})
local ABTest = require(GameSdkShared.Modules.ABTest)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local categoryEnabled = false
local uiSizeEnabled = false

function v:FetchAvatarEditorReworkABTestVariables()
	local v2, v3 = ABTest.GetExperimentVariables("avatar-editor-rework"):timeout(7):await()

	if v2 then
		categoryEnabled = v3.categoryEnabled
		uiSizeEnabled = v3.uiSizeEnabled
	end

	return categoryEnabled, uiSizeEnabled
end

function v.IsAvatarEditorReworkABTestEnabled(_)
	return categoryEnabled
end

function v.IsAvatarEditorReworkUISizeEnabled(_)
	return uiSizeEnabled
end

function v:ChangeCategories()
	self._avatarsButton.Visible = true
	self._charactersButton.Visible = false
	self._avatarsButton.LayoutOrder = 1
	self._bodyButton.LayoutOrder = 2
	self._clothesButton.LayoutOrder = 3
	self._accessoriesButton.LayoutOrder = 4
	self._animationsButton.LayoutOrder = 5
	self._clothesButton.Icon.Image = "rbxassetid://137906975521461"
end

function v:ChangeSubCategories()
	local accessories = self._subcategories:FindFirstChild("Accessories")

	if not accessories then
		warn("Accessories subcategory not found in AB Test. Is it renamed?")
		return
	end

	local hairAccessory_2 = accessories:FindFirstChild("HairAccessory")
	hairAccessory_2.Visible = false
	local hat = accessories:FindFirstChild("Hat")
	local faceAccessory = accessories:FindFirstChild("FaceAccessory")
	local neckAccessory = accessories:FindFirstChild("NeckAccessory")
	local shoulderAccessory = accessories:FindFirstChild("ShoulderAccessory")
	local frontAccessory = accessories:FindFirstChild("FrontAccessory")
	local backAccessory = accessories:FindFirstChild("BackAccessory")
	local waistAccessory = accessories:FindFirstChild("WaistAccessory")
	hat.LayoutOrder = 1
	faceAccessory.LayoutOrder = 2
	neckAccessory.LayoutOrder = 3
	shoulderAccessory.LayoutOrder = 4
	frontAccessory.LayoutOrder = 5
	backAccessory.LayoutOrder = 6
	waistAccessory.LayoutOrder = 7
	local body = self._subcategories:FindFirstChild("Body")

	if not body then
		warn("Body subcategory not found in AB Test. Is it renamed?")
		return
	end

	local bundleBodyParts = body:FindFirstChild("Bundle: BodyParts")
	bundleBodyParts.LayoutOrder = 1
	bundleBodyParts.Visible = true
	local bundleDynamicHead = body:FindFirstChild("Bundle: DynamicHead")
	bundleDynamicHead.Visible = true
	bundleDynamicHead.LayoutOrder = 2
	local hairAccessory = body:FindFirstChild("HairAccessory")
	hairAccessory.Visible = true
	hairAccessory.LayoutOrder = 3
	local body_2 = body:FindFirstChild("Body")
	body_2.Visible = true
	local dynamicandClassicHeads = body:FindFirstChild("Dynamic and Classic Heads")
	dynamicandClassicHeads.Visible = false
	local head = body:FindFirstChild("Head")
	head.Visible = false
	body:FindFirstChild("UIListLayout"):Destroy()
	local uIGridLayout = Instance.new("UIGridLayout")
	uIGridLayout.CellPadding = UDim2.new(0.005, 0, 0, 0)
	uIGridLayout.CellSize = UDim2.new(0.13, 0, 1, 0)
	uIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIGridLayout.StartCorner = Enum.StartCorner.TopLeft
	uIGridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	uIGridLayout.FillDirection = Enum.FillDirection.Horizontal
	uIGridLayout.Parent = body
	local clothes = self._subcategories:FindFirstChild("Clothes")
	local mergedShirtPants = clothes:FindFirstChild("Merged: Shirt/Pants")
	mergedShirtPants.Visible = false
	local shirt = clothes:FindFirstChild("Shirt")
	shirt.Visible = true
	local pants = clothes:FindFirstChild("Pants")
	pants.Visible = true
end

function v:ChangeTopLevelButtons()
	self.Instance.Parent.TopLevelButtons.Position = UDim2.fromScale(0.12, 0.815)
	self.Instance.Parent.TopLevelButtons.Size = UDim2.fromScale(0.12, 0.09)
end

function v:ChangeOutfitSlots()
	self._reorderLayeredClothingButton.Visible = true
	self._outfitSlots.Container.Visible = false
	self._outfitSlots.ContainerABT.Visible = true
	self:ChangeTopLevelButtons()
end

function v:ChangeAskRevertCharacter()
	self.Instance.Parent.AskRevertCharacter.Buttons.Position = UDim2.fromScale(0.33, 0.58)
	self.Instance.Parent.AskRevertCharacter.Label.Position = UDim2.fromScale(0.33, 0.92)
end

function v:EnableAvatarEditorRework()
	self:ChangeCategories()
	self:ChangeSubCategories()
	self:ChangeOutfitSlots()
end

function v:ChangeUISize()
	self.Instance.Size = UDim2.new(0.46, 0, 1, 0)
	self.Instance.Parent.AvatarEditorSearch.Position = UDim2.new(0.94, 0, 0.16, 0)
	self:ChangeTopLevelButtons()
end

function v:UpdateUltrawideAspectConstraint()
	if Platform.IsKeyboard() then
		local currentCamera = workspace.CurrentCamera

		if not currentCamera then
			return
		end

		local viewportSize = currentCamera.ViewportSize

		if viewportSize.X / viewportSize.Y > 1.7777777777777777 then
			if not self._ultrawideAspectConstraint then
				self._ultrawideAspectConstraint = Instance.new("UIAspectRatioConstraint")
				self._ultrawideAspectConstraint.Name = "UltrawideAspectConstraint"
				self._ultrawideAspectConstraint.AspectRatio = 1.08
				self._ultrawideAspectConstraint.DominantAxis = Enum.DominantAxis.Width
				self._ultrawideAspectConstraint.AspectType = Enum.AspectType.FitWithinMaxSize
				self._ultrawideAspectConstraint.Parent = self.Instance
			end
		elseif self._ultrawideAspectConstraint then
			self._ultrawideAspectConstraint:Destroy()
			self._ultrawideAspectConstraint = nil
		end
	elseif self._ultrawideAspectConstraint then
		self._ultrawideAspectConstraint:Destroy()
		self._ultrawideAspectConstraint = nil
	end
end

function v:ControlChangesAfterFaceAndClassicHeadsRemoval()
	local body = self._subcategories:FindFirstChild("Body")

	if not body then
		warn("Body subcategory not found in AB Test. Is it renamed?")
		return
	end

	local head = body:FindFirstChild("Head")
	head.Visible = false
	local faces = body:FindFirstChild("Faces")
	faces.Visible = false
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._categories = self.Instance:FindFirstChild("CategoryTabs")
	self._subcategories = self.Instance:FindFirstChild("SubCategoryTabs")
	self._avatarsButton = self._categories:FindFirstChild("Avatars")
	self._charactersButton = self._categories:FindFirstChild("Characters")
	self._accessoriesButton = self._categories:FindFirstChild("Accessories")
	self._bodyButton = self._categories:FindFirstChild("Body")
	self._clothesButton = self._categories:FindFirstChild("Clothes")
	self._animationsButton = self._categories:FindFirstChild("WalkStyle")
	self._reorderLayeredClothingButton = self.Instance.Parent.CurrentlyWearing:FindFirstChild("ReorderLayeredClothing")
	self._outfitSlots = self.Instance.Parent.Outfits
end

function v:Start()
	local avatarEditorReworkABTestVariables, v2 = self:FetchAvatarEditorReworkABTestVariables()

	if avatarEditorReworkABTestVariables then
		self:EnableAvatarEditorRework()
	else
		self:ControlChangesAfterFaceAndClassicHeadsRemoval()
	end

	if v2 then
		self:ChangeUISize()
		self:ChangeAskRevertCharacter()
		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			self:UpdateUltrawideAspectConstraint()
			self._Janitor:Add(currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				self:UpdateUltrawideAspectConstraint()
			end))
		end
	end
end

function v:Stop()
	if self._ultrawideAspectConstraint then
		self._ultrawideAspectConstraint:Destroy()
		self._ultrawideAspectConstraint = nil
	end

	self._Janitor:Destroy()
end

return v