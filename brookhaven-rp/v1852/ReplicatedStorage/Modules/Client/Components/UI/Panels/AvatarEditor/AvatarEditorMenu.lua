local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local GamepadService = game:GetService("GamepadService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local Signal = require(ReplicatedStorage.Packages.Signal)
local CameraController = require(ReplicatedStorage.Modules.Client.UI.CameraController)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local UIAnimationEffects = require(ReplicatedStorage.Modules.Client.UI.UIAnimationEffects)
local ABLazyPanelController = require(ReplicatedStorage.Modules.Client.UI.ABLazyPanelController)
local ABTest = require(GameSdkShared.Modules.ABTest)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local AvatarEditorRequests = require(ReplicatedStorage.Modules.Shared.Game.AvatarEditorRequests)
local _1Bab1yFollo1w = nil
local v = {
	"Hat",
	"HairAccessory",
	"FaceAccessory",
	"BackAccessory",
	"WaistAccessory",
	"NeckAccessory",
	"FrontAccessory",
	"ShoulderAccessory",
	"Bundle: Shoes",
	"DressSkirtAccessory",
	"JacketAccessory",
	"Pants",
	"PantsAccessory",
	"Shirt",
	"Merged: Shirt/Pants",
	"ShirtAccessory",
	"ShortsAccessory",
	"SweaterAccessory",
	"TShirtAccessory",
	"Bundle: DynamicHead",
	"Dynamic and Classic Heads",
	"Bundle: BodyParts"
}
local v2 = {
	"All",
	"Idle",
	"Walk",
	"Run",
	"Jump",
	"Fall",
	"Climb",
	"Swim"
}
local flag = false
local v3 = false
local v4 = Component.new({
	Tag = "AvatarEditorMenu"
})
local nows = {}

function v4:SetupTabButtonsSelection(items, p, flag2: boolean)
	local v5 = nil

	for _, item in items do
		item.SelectedIcon.Visible = item == p

		if item:HasTag("AvatarEditorOpenContextButton") then
			continue
		end

		if item.Name == "Body" and not flag2 and flag then
			item.Visible = false
		end

		if item:GetAttribute("DefaultSelected") and not flag then
			v5 = item
		end

		local v6 = item
		self._clickJanitor:Add(item.Activated:Connect(function()
			self:ClickButton(items, v6, flag2, true)
		end))
		local v7 = item
		self._clickJanitor:Add(item.MouseEnter:Connect(function()
			if not self._originalButtonSizes[v7] then
				local size = v7.Size
				self._originalButtonSizes[v7] = size
			end

			TweenService:Create(v7, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = v7.Size + UDim2.new(0.005, 0, 0.005, 0),
				BackgroundColor3 = Color3.new(0.95, 0.95, 0.95)
			}):Play()
		end))
		local v8 = item
		self._clickJanitor:Add(item.MouseLeave:Connect(function()
			local _originalButtonSiz = self._originalButtonSizes[v8]

			if not _originalButtonSiz then
				return
			end

			TweenService:Create(v8, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = _originalButtonSiz,
				BackgroundColor3 = Color3.new(1, 1, 1)
			}):Play()
		end))
	end

	if v5 then
		self:ClickButton(items, v5, flag2, false)
	end
end

function v4:SetAnimationCatalogSearchEnabled(flag2: boolean)
	self._animationCatalogSearchEnabled = flag2 == true
end

function v4:IsAnimationCatalogSearchEnabled()
	return self._animationCatalogSearchEnabled == true
end

function v4:ShouldShowSearchForSubcategory(p: string?)
	if p == nil then
		return false
	end

	if table.find(v, p) ~= nil or self:IsAnimationCatalogSearchEnabled() and table.find(v2, p) ~= nil then
		return true
	end

	return false
end

function v4:IsPerformingSearch()
	return self._performingSearch
end

function v4:SetPerformingSearch(performingSearch: boolean)
	self._performingSearch = performingSearch
end

function v4:OpenDefaultAnimationSubcategory()
	if not self:IsAnimationCatalogSearchEnabled() then
		return
	end

	local catalog = self.Instance:FindFirstChild("Catalog")
	local subCategoryTabs = catalog and catalog:FindFirstChild("SubCategoryTabs")
	local walkStyle = subCategoryTabs and subCategoryTabs:FindFirstChild("WalkStyle")

	if walkStyle == nil then
		return
	end

	local all = walkStyle:FindFirstChild("All")

	if all == nil or not all:IsA("GuiButton") or all.Visible ~= true then
		return
	end

	local targetPanel = all:GetAttribute("TargetPanel")

	if typeof(targetPanel) ~= "string" or targetPanel == "" then
		return
	end

	self:ClickButton(self:CollectButtonsFromFolder(walkStyle), all, false, false)
	PanelController.ToggleGroup("AvatarEditorSubcategories", false)
	PanelController.SetAttribute("NoResetGUIHandler", targetPanel, "Subcategory", all.Name)
	PanelController.Open("NoResetGUIHandler", targetPanel)
end

function v4:ClickButton(items, instance, p, p2)
	if self:IsPerformingSearch() then
		NotificationController.NotifyClickDebounce(1, true)
		return
	end

	local targetPanel = instance:GetAttribute("TargetPanel")
	local catalog = self.Instance.Catalog
	local subCategoryTabs = catalog:WaitForChild("SubCategoryTabs")
	local container = catalog.Container

	if p2 then
		local now = tick()
		table.insert(nows, now)

		if #nows > 5 then
			table.remove(nows, 1)
		end

		while #nows > 0 and tick() - nows[1] > 1.6 do
			table.remove(nows, 1)
		end

		local total = 0

		for k, v5 in nows do
			local v6

			if k == #nows then
				v6 = now - v5
			else
				v6 = nows[k + 1] - v5
			end

			total += v6
		end

		local v5 = total / #nows

		if #nows >= 5 and v5 < 0.4 then
			local v6 = (0.4 - v5) * 3
			local backgroundTransparencies = {}

			local function GreyOutButton(p3)
				p3.Interactable = false
				p3.Active = false
				p3.Selectable = false
				backgroundTransparencies[p3] = p3.BackgroundTransparency
				TweenService:Create(p3, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					BackgroundTransparency = math.max(p3.BackgroundTransparency * 2, 0.75)
				}):Play()
			end

			local function RestoreButton(p3)
				TweenService:Create(p3, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					BackgroundTransparency = backgroundTransparencies[p3]
				}):Play()
				task.delay(0.1, function()
					p3.Interactable = true
					p3.Active = true
					p3.Selectable = true
				end)
			end

			for _, v7 in CollectionService:GetTagged("ToggleSubcategoryButton") do
				GreyOutButton(v7)
			end

			for _, v7 in CollectionService:GetTagged("ToggleCategoryButton") do
				GreyOutButton(v7)
			end

			NotificationController.NotifyClickDebounce(v6 * 2.5)
			task.delay(v6, function()
				for _, v7 in CollectionService:GetTagged("ToggleSubcategoryButton") do
					RestoreButton(v7)
				end

				for _, v7 in CollectionService:GetTagged("ToggleCategoryButton") do
					RestoreButton(v7)
				end
			end)
			return
		end
	end

	local size = self._originalButtonSizes[instance] or instance.Size
	local v6 = {
		Size = size - UDim2.new(0.0075, 0, 0.0075, 0),
		BackgroundColor3 = Color3.new(0.75, 0.75, 0.75)
	}
	local selectedIcon = instance:FindFirstChild("SelectedIcon")
	local v7 = selectedIcon and selectedIcon.Visible and {
		Size = size - UDim2.new(0.002, 0, 0.002, 0),
		BackgroundColor3 = Color3.new(0.975, 0.975, 0.975)
	} or v6
	local tween = TweenService:Create(
		instance,
		TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		v7
	)
	tween.Completed:Once(function(p3)
		if p3 == Enum.PlaybackState.Completed then
			TweenService:Create(instance, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = size,
				BackgroundColor3 = Color3.new(1, 1, 1)
			}):Play()
		end
	end)
	tween:Play()
	local _currentSelectedCategory = nil

	if p then
		_currentSelectedCategory = self._currentSelectedCategory
	elseif self._currentSelectedSubcategory then
		if self._currentSelectedSubcategory.SelectedIcon.Visible then
			_currentSelectedCategory = self._currentSelectedSubcategory or nil
		else
			_currentSelectedCategory = nil
		end
	end

	if p then
		self._lastOpenedCategory = targetPanel
		self._currentSelectedCategory = instance

		if p2 then
			TelemetryController.SendClientInteraction("avatarTopInteraction", {
				topButton = targetPanel
			})
			Remotes.fireServer(AvatarEditorRequests.SET_AVATAR_EDITOR_CONTEXT, targetPanel, nil)
		end

		if targetPanel == "Accessories" then
			self._lastOpenedSubcategory = "SearchAllRoblox"
		elseif targetPanel == "Body" then
			self._lastOpenedSubcategory = "ScaleFrame"
		else
			self._lastOpenedSubcategory = nil
		end

		if self._currentSelectedSubcategory then
			self._currentSelectedSubcategory.SelectedIcon.Visible = false
		end

		if self._lastOpenedSubcategory then
			PanelController.SetAttribute("NoResetGUIHandler", self._lastOpenedSubcategory, "Subcategory", targetPanel)
		end

		local subCategorySize = instance:GetAttribute("SubCategorySize")

		if subCategorySize then
			subCategoryTabs.Size = subCategorySize
			local v8 = subCategoryTabs.Size.Y.Scale - subCategoryTabs:GetAttribute("DefaultSizeY")
			container.Size = UDim2.new(
				container.Size.X.Scale,
				container.Size.X.Offset,
				container:GetAttribute("DefaultSizeY") - v8,
				container.Size.Y.Offset
			)
		end

		self:HideSearchOption()
		self.OnCategoryChanged:Fire(instance, instance.Name)

		if instance.Name == "WalkStyle" and self:IsAnimationCatalogSearchEnabled() then
			task.defer(function()
				if self:IsAnimationCatalogSearchEnabled() then
					self:OpenDefaultAnimationSubcategory()
				end
			end)
		end
	else
		self._lastOpenedSubcategory = targetPanel
		self._currentSelectedSubcategory = instance
		self.OnSubcategoryChanged:Fire(instance, instance.Name)
		self._lastOpenedSubcategoryName = instance.Name

		if p2 then
			Remotes.fireServer(AvatarEditorRequests.SET_AVATAR_EDITOR_CONTEXT, self._lastOpenedCategory, instance.Name)
			TelemetryController.SendClientInteraction("avatarSubInteraction", {
				assetType = instance.Name,
				source = self._lastOpenedCategory or ""
			})
		end

		if self:ShouldShowSearchForSubcategory(self._lastOpenedSubcategoryName) then
			self:ShowSearchOption()
		else
			self:HideSearchOption()
		end
	end

	for _, item in items do
		if item.SelectedIcon.Visible and item ~= instance then
			item.SelectedIcon.Visible = false
		end

		if item ~= instance then
			continue
		end

		local v8 = item
		task.spawn(function()
			if not p2 then
				v8.SelectedIcon.Visible = true
				return
			end

			v8.SelectedIcon.Visible = true
			v8.SelectedIcon.ImageTransparency = 0.98
			local v9 = nil

			if _currentSelectedCategory and _currentSelectedCategory ~= v8 then
				v9 = UIAnimationEffects.SlingIconTo(_currentSelectedCategory.SelectedIcon, v8.SelectedIcon, 0.25) * 0.7
			elseif _currentSelectedCategory == v8 then
				UIAnimationEffects.GrowShrink(
					v8.SelectedIcon,
					0.25,
					UDim2.new(v8.SelectedIcon.Size.X.Scale, 0, v8.SelectedIcon.Size.Y.Scale, 0),
					math.max(v8.SelectedIcon.AbsoluteSize.X, v8.SelectedIcon.AbsoluteSize.Y) / 31.2
				)
			end

			v8.SelectedIcon.ImageTransparency = 0

			if not v8.SelectedIcon.Visible then
				return
			end

			UIAnimationEffects.WiggleWithDampening(v8.SelectedIcon, 1.4, v9)
		end)
	end
end

function v4:ShowSearchOption()
	PanelController.Open("NoResetGUIHandler", "AvatarEditorSearch")
end

function v4:HideSearchOption()
	if PanelController.IsOpen("NoResetGUIHandler", "AvatarEditorSearch") then
		PanelController.Close("NoResetGUIHandler", "AvatarEditorSearch")
	end
end

function v4:CollectButtonsFromFolder(instance)
	local buttons = {}

	for _, button in instance:GetChildren() do
		if button:IsA("ImageButton") then
			table.insert(buttons, button)
		end
	end

	return buttons
end

function v4:SetupCategoryAndSubcategoryButtons()
	local catalog = self.Instance.Catalog
	local categoryTabs = catalog:WaitForChild("CategoryTabs")

	for _, button in categoryTabs:GetChildren() do
		if button:IsA("TextButton") or button:IsA("ImageButton") then
			button.SelectionOrder = 2000
		end
	end

	local buttons = {}

	for _, button in categoryTabs:GetChildren() do
		if not button:IsA("ImageButton") or button:HasTag("ClosePanelButton") then
			continue
		end

		table.insert(buttons, button)
	end

	self:SetupTabButtonsSelection(buttons, self._currentSelectedCategory, true)
	local v5 = {}

	for _, frame in catalog.SubCategoryTabs:GetChildren() do
		if frame:IsA("Frame") then
			v5[frame.Name] = self:CollectButtonsFromFolder(frame)
		end
	end

	for _, v6 in v5 do
		self:SetupTabButtonsSelection(v6, self._currentSelectedSubcategory)
	end

	if self._isInitialSetup then
		self._isInitialSetup = false

		if flag then
			self:ClickButton(buttons, categoryTabs:FindFirstChild("Avatars"), true, false)
		else
			self:ClickButton(buttons, categoryTabs:FindFirstChild("Body"), true, false)
		end
	end
end

function v4:HandleFollowCharacter(p: string)
	local followCharacterName = Players.LocalPlayer.PlayersBag:FindFirstChild("FollowCharacterName")
	local v5 = followCharacterName.Value ~= "NoFollowCharacter" and ({
		remove = "TempDeleteFollowCharacter",
		spawn = "CharacterFollowSpawnPlayer"
	})[p]

	if v5 then
		_1Bab1yFollo1w:FireServer(v5, p == "spawn" and followCharacterName.Value)
	end
end

function v4:RemoveFollowCharacter()
	self:HandleFollowCharacter("remove")
end

function v4:SpawnFollowCharacter()
	self:HandleFollowCharacter("spawn")
end

function v4:GetCurrentCategoryContext()
	return self._lastOpenedCategory, self._lastOpenedSubcategoryName
end

function v4:SetLastOpenedSubcategory(lastOpenedSubcategory: string)
	self._lastOpenedSubcategory = lastOpenedSubcategory
end

function v4:UnsetCurrentSubcategory()
	self._currentSelectedSubcategory = nil
end

function v4:SetInitialButton()
	local buttons = {}

	for _, button in self.Instance.Catalog:WaitForChild("CategoryTabs"):GetChildren() do
		if not button:IsA("ImageButton") or button:HasTag("ClosePanelButton") then
			continue
		end

		table.insert(buttons, button)
	end

	for _, v5 in buttons do
		local targetPanel = v5:GetAttribute("TargetPanel")

		if not (self.InitialCategory ~= nil and targetPanel == self.InitialCategory) then
			continue
		end

		self.InitialCategory = nil
		self:ClickButton(buttons, v5, true, false)
	end
end

function v4:FetchAvatarEditorReworkABTestVariables()
	local v5, v6 = ABTest.GetExperimentVariables("avatar-editor-rework"):timeout(7):await()
	local v7, v8 = ABTest.GetExperimentVariable("console-controls", "enabled"):timeout(7):await()
	local categoryEnabled, uiSizeEnabled

	if v5 then
		categoryEnabled = v6.categoryEnabled
		uiSizeEnabled = v6.uiSizeEnabled
	else
		categoryEnabled = false
		uiSizeEnabled = false
	end

	return categoryEnabled, uiSizeEnabled, not v7 or v8
end

function v4:FetchAccessoryAdjustmentsABTestEnabled()
	local v5, v6 = ABTest.GetExperimentVariables("avatar-editor-camera-move"):timeout(7):await()

	if v5 then
		return v6.enabled == true
	end

	return false
end

function v4:HookupTopLevelButtons()
	local v5, v6 = ABTest.GetExperimentVariable("upload-avatar-to-roblox", "access-outfit-saving"):timeout(7):await()
	local topLevelButtonsOriginal = self.Instance:FindFirstChild("TopLevelButtonsOriginal")

	if v5 and v6 then
		if topLevelButtonsOriginal then
			topLevelButtonsOriginal:Destroy()
		end

		topLevelButtonsOriginal = self.Instance:FindFirstChild("TopLevelButtons")
	else
		local topLevelButtons = self.Instance:FindFirstChild("TopLevelButtons")

		if topLevelButtons then
			topLevelButtons:Destroy()
		end
	end

	if not topLevelButtonsOriginal then
		return
	end

	self._hoverJanitor:Cleanup()
	topLevelButtonsOriginal.Visible = true
	local resetCharacter = topLevelButtonsOriginal:FindFirstChild("ResetCharacter")
	local spinner = resetCharacter:FindFirstChild("Spinner")
	local buyAll = topLevelButtonsOriginal:FindFirstChild("BuyAll")
	local robux = buyAll:FindFirstChild("Robux")
	local saveToRoblox = topLevelButtonsOriginal:FindFirstChild("SaveToRoblox")

	if not (resetCharacter and buyAll and spinner and robux) then
		return
	end

	local size = spinner.Size
	local v7 = false
	local thread = nil

	for _, v8 in UIAnimationEffects.ConnectButtonHoverAndActivationFX(resetCharacter, spinner, {
		Hover = function(p2)
			TweenService:Create(p2, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Size = size + UDim2.new(0.04, 0, 0.04, 0)
			}):Play()

			if not v7 then
				TweenService:Create(p2, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Rotation = -10
				}):Play()
			end
		end,
		HoverEnd = function(p2)
			TweenService:Create(p2, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Size = size
			}):Play()

			if not v7 then
				TweenService:Create(p2, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Rotation = 0
				}):Play()
			end
		end,
		Activate = function(p2)
			if thread then
				task.cancel(thread)
			end

			local tween = TweenService:Create(
				p2,
				TweenInfo.new(0.01, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
				{
					Size = size
				}
			)
			tween:Play()
			tween:Cancel()
			p2.Size = size
			local rotation = math.floor(p2.Rotation / 360) * 360 - 360
			TweenService:Create(p2, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, true, 0), {
				Size = size + UDim2.new(0.1, 0, 0.1, 0)
			}):Play()
			TweenService:Create(p2, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Rotation = rotation
			}):Play()
			v7 = true
			thread = task.delay(1, function()
				v7 = false
				p2.Rotation %= 360
			end)
		end
	}) do
		self._hoverJanitor:Add(v8)
	end

	local size2 = robux.Size

	for _, v8 in UIAnimationEffects.ConnectButtonHoverAndActivationFX(buyAll, robux, {
		Hover = {
			info = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			properties = {
				Size = size2 + UDim2.new(0.1, 0, 0.1, 0)
			}
		},
		HoverEnd = {
			info = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			properties = {
				Size = size2
			}
		}
	}) do
		self._hoverJanitor:Add(v8)
	end

	self._hoverJanitor:Add(resetCharacter.Activated:Connect(function()
		TelemetryController.SendClientInteraction("avatarEditorUI", {
			button = "Reset"
		})
	end))

	if saveToRoblox then
		self._hoverJanitor:Add(saveToRoblox.Activated:Connect(function()
			TelemetryController.SendClientInteraction("avatarEditorUI", {
				button = "SaveToRoblox"
			})
		end))
	end
end

function v4:VirtualCursorChanged()
	if GamepadService.GamepadCursorEnabled then
		self._originalChatWindowHeight = TextChatService.ChatWindowConfiguration.HeightScale
		TweenService:Create(
			TextChatService.ChatWindowConfiguration,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				HeightScale = self._originalChatWindowHeight / 2
			}
		):Play()
	elseif self._originalChatWindowHeight then
		TweenService:Create(
			TextChatService.ChatWindowConfiguration,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				HeightScale = self._originalChatWindowHeight
			}
		):Play()
		self._originalChatWindowHeight = nil
	end
end

function v4.PullABPanels(p)
	local v5 = nil

	while not v5 do
		v5 = ABLazyPanelController.LoadABLazyPanel("avatar-editor-improvements", "category-panels")

		if not v5 then
			task.wait(0.5)
		end
	end

	if v5 then
		Debris:AddItem(p.Instance.Catalog:FindFirstChild("CategoryTabs"), 0)
		Debris:AddItem(p.Instance.Catalog:FindFirstChild("SubCategoryTabs"), 0)
		local clone = v5.CategoryTabs:Clone()
		clone.Parent = p.Instance.Catalog
		local clone_2 = v5.SubCategoryTabs:Clone()
		clone_2.Parent = p.Instance.Catalog
	end
end

function v4:HandleABControlRepositioning()
	if ABTest.GetExperimentVariable("avatar-editor-improvements", "has-new-content"):expect() then
		return
	end

	for _, v5 in CollectionService:GetTagged("OldAvatarEditorAB") do
		if v5:GetAttribute("OldPosition") then
			v5.Position = v5:GetAttribute("OldPosition")
			v5:SetAttribute("OldPosition", nil)
		end

		if not v5:GetAttribute("OldSize") then
			continue
		end

		v5.Size = v5:GetAttribute("OldSize")
		v5:SetAttribute("OldSize", nil)
	end
end

function v4:HandleShareButtonABTest()
	if not ABTest.GetExperimentVariable("ae-outfit-sharing", "has-share-button"):expect() then
		return
	end

	for _, v5 in CollectionService:GetTagged("AEShareButton") do
		v5.Visible = true
	end
end

function v4:PerformABTestUISetup()
	self:HandleABControlRepositioning()
	self:HandleShareButtonABTest()
end

function v4:OpenAvatarEditor()
	self._openGeneration += 1
	local _openGeneration = self._openGeneration
	PanelController.ToggleGroup("HUD", false)
	self:SetupCategoryAndSubcategoryButtons()
	self:PerformABTestUISetup()
	local localPlayer = Players.LocalPlayer
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

	if _openGeneration == self._openGeneration and self.Instance.Visible then
		local humanoid

		if character then
			humanoid = character:FindFirstChild("Humanoid")
		else
			humanoid = nil
		end

		self:RemoveFollowCharacter()

		if self._isAccessoryAdjustmentsExperimentEnabled then
			local humanoid2

			if character then
				humanoid2 = character:FindFirstChild("Humanoid")
			end

			if humanoid2 and humanoid2:IsA("Humanoid") then
				CameraController.SetCustomCamera(workspace.CurrentCamera.CFrame, humanoid2, nil, false)
			end
		else
			CameraController.SetAvatarEditorCamera(true)
		end

		if humanoid then
			if not self._isAccessoryAdjustmentsExperimentEnabled then
				local floorMaterial = humanoid.FloorMaterial
				self._Janitor:Add(humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
					if floorMaterial == Enum.Material.Air then
						task.wait(0.2)
						CameraController.SetAvatarEditorCamera()
					end

					floorMaterial = humanoid.FloorMaterial
				end), "Disconnect", "FloorMaterialChanged")
			end

			self._Janitor:Add(humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
				PanelController.Close("NoResetGUIHandler", "AvatarEditorMenu")
			end))
			self._Janitor:Add(humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
				PanelController.Close("NoResetGUIHandler", "AvatarEditorMenu")
			end))
		end

		self._Janitor:Add(GamepadService:GetPropertyChangedSignal("GamepadCursorEnabled"):Connect(function()
			self:VirtualCursorChanged()
		end), "Disconnect", "GamepadCursorEnabledChanged")
		self:VirtualCursorChanged()
		self:SetInitialButton()
		self:HookupTopLevelButtons()
		PanelController.ToggleGroup("AvatarEditor", false)
		PanelController.ToggleGroup("AvatarEditorSubcategories", false)
		PanelController.Open("NoResetGUIHandler", self._lastOpenedCategory)

		if self._lastOpenedSubcategory then
			PanelController.Open("NoResetGUIHandler", self._lastOpenedSubcategory)
		end

		if self:ShouldShowSearchForSubcategory(self._lastOpenedSubcategoryName) then
			self:ShowSearchOption()
		end

		self._avatarEditorOpenTime = tick()
	elseif not self.Instance.Visible then
		PanelController.ToggleGroup("HUD", true)
	end
end

function v4:CloseAvatarEditor()
	PanelController.ToggleGroup("HUD", true)
	self._Janitor:Remove("FloorMaterialChanged")
	self._Janitor:Remove("GamepadCursorEnabledChanged")

	if self._originalChatWindowHeight then
		TweenService:Create(
			TextChatService.ChatWindowConfiguration,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				HeightScale = self._originalChatWindowHeight
			}
		):Play()
		self._originalChatWindowHeight = nil
	end

	self._clickJanitor:Cleanup()
	self._Janitor:Cleanup()
	CameraController.SetDefaultCamera()
	self:SpawnFollowCharacter()

	if self._avatarEditorOpenTime then
		TelemetryController.SendClientInteraction("closeAvatarEditor", tick() - self._avatarEditorOpenTime)
		self._avatarEditorOpenTime = nil
	end
end

function v4:Construct()
	self._endJanitor = Janitor.new()
	self._Janitor = Janitor.new()
	self._hoverJanitor = Janitor.new()
	self._clickJanitor = Janitor.new()
	self._originalButtonSizes = setmetatable({}, {
		__mode = "k"
	})
	self.editorSearchComponent = ComponentUtil.GetComponentFromInstance(
		self.Instance:WaitForChild("AvatarEditorSearch"),
		ComponentUtil.FindAndWaitForComponentByTag(self.Instance, "AvatarEditorSearch")
	)
	self._isInitialSetup = true
	self._currentSelectedCategory = nil
	self._currentSelectedSubcategory = nil
	self._isConsoleControlsEnabled = true
	self._isAccessoryAdjustmentsExperimentEnabled = false
	self._animationCatalogSearchEnabled = false
	self._openGeneration = 0
	self._lastOpenedCategory = "ScaleFrame"
	self.OnVisibleChanged = Signal.new()
	self.OnSubcategoryChanged = Signal.new()
	self.OnCategoryChanged = Signal.new()
	_1Bab1yFollo1w = ReplicatedStorage.RE:WaitForChild("1Bab1yFollo1w")
end

function v4:Start()
	local localPlayer = Players.LocalPlayer
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	self._endJanitor:Add(self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		self.OnVisibleChanged:Fire(self.Instance.Visible)
	end))
	local humanoid

	if character then
		humanoid = character:FindFirstChild("Humanoid")
	end

	if humanoid then
		humanoid.Seated:Connect(function()
			PanelController.Close("NoResetGUIHandler", "AvatarEditorMenu")
		end)
	end

	self._endJanitor:Add(localPlayer.CharacterAdded:Connect(function(character2)
		character2:WaitForChild("Humanoid").Seated:Connect(function()
			PanelController.Close("NoResetGUIHandler", "AvatarEditorMenu")
		end)
	end))
	self._endJanitor:Add(PanelController.OnPanelOpened:Connect(function(_, p)
		if p == "AvatarEditorMenu" then
			local character2 = localPlayer.Character
			local humanoid2 = character2 and character2:FindFirstChildOfClass("Humanoid")

			if humanoid2 then
				humanoid2:UnequipTools()
			end

			PanelController.ToggleGroup("HouseControl", false)
			self:OpenAvatarEditor()
		end
	end))
	self._endJanitor:Add(PanelController.OnPanelClosed:Connect(function(_, p)
		if p == "AvatarEditorMenu" then
			self._openGeneration += 1
			local character2 = localPlayer.Character

			if not character2 then
				self:CloseAvatarEditor()
				return
			end

			local humanoid = character2:WaitForChild("Humanoid")
			humanoid.WalkSpeed = StarterPlayer.CharacterWalkSpeed
			PanelController.ToggleGroup("TopDetails", true)
			self:CloseAvatarEditor()
		end
	end))
	local avatarEditorReworkABTestVariables, v5, isConsoleControlsEnabled = self:FetchAvatarEditorReworkABTestVariables()

	if avatarEditorReworkABTestVariables then
		flag = true
	end

	if v5 then
		v3 = true
	end

	self._isConsoleControlsEnabled = isConsoleControlsEnabled
	self._isAccessoryAdjustmentsExperimentEnabled = self:FetchAccessoryAdjustmentsABTestEnabled()
end

function v4:Stop()
	self._endJanitor:Destroy()
	self._Janitor:Destroy()
	self._hoverJanitor:Destroy()
	self._clickJanitor:Destroy()
end

return v4