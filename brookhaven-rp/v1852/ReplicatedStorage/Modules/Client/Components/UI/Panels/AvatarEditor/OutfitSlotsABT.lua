local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "OutfitSlotsABT"
})
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local v2 = false
local v3 = nil
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local CameraController = require(ReplicatedStorage.Modules.Client.UI.CameraController)
local SavedSlotsController = require(ReplicatedStorage.Modules.Client.AvatarEditor.SavedSlotsController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local ConfirmationPanel = require(ReplicatedStorage.Modules.Client.UI.ConfirmationPanel)
local buttonsByName = {}
local v4 = nil

local function slotInteractionButtonPopOutInAnimation(instance, flag: boolean)
	if instance.Visible == flag then
		return nil
	end

	instance.Visible = false
	instance:RemoveTag("HoverAndActivationFX")

	if not flag then
		return nil
	end

	local clone = instance:Clone()
	clone.Parent = instance.Parent
	clone.Visible = true
	local backgroundTransparency = instance.BackgroundTransparency
	local imageTransparency = instance.Icon.ImageTransparency
	local position = instance.Position
	clone.BackgroundTransparency = 1
	clone.Icon.ImageTransparency = 1
	clone.Name = instance.Name .. "AnimationCopy"
	clone.Position = UDim2.new(1, 0, 0.5, 0)
	local v5 = math.abs(position.X.Scale - clone.Position.X.Scale) / 4.25 + 0.3
	Debris:AddItem(clone, v5)
	local tween = TweenService:Create(clone, TweenInfo.new(v5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = position,
		BackgroundTransparency = backgroundTransparency
	})
	TweenService:Create(clone.Icon, TweenInfo.new(v5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		ImageTransparency = imageTransparency
	}):Play()
	tween.Completed:Once(function(p)
		Debris:AddItem(clone, 0)

		if p == Enum.PlaybackState.Completed then
			if clone then
				clone.Visible = false
			end

			instance.Visible = true
			instance:AddTag("HoverAndActivationFX")
		end
	end)
	tween:Play()
	return tween
end

function v:AvatarMenuClosed()
	self:ToggleOverlappingUIVisibility(true)

	for _, v5 in buttonsByName do
		self:ToggleSlotVisibility(v5, false)
	end

	v4 = nil
end

function v:ToggleSlotVisibility(data, flag: boolean)
	if flag and data.UIStroke.Thickness ~= 0.05 then
		TweenService:Create(data.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Thickness = 0.05,
			Color = Color3.fromRGB(255, 255, 0)
		}):Play()
	elseif not flag and data.UIStroke.Thickness ~= 0.03 then
		TweenService:Create(data.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Thickness = 0.03,
			Color = Color3.fromRGB(0, 0, 0)
		}):Play()
	end

	if self.ongoingAnimationTweens[data] then
		for _, v5 in self.ongoingAnimationTweens[data] do
			if v5.PlaybackState == Enum.PlaybackState.Playing then
				v5:Cancel()
			end
		end

		self.ongoingAnimationTweens[data] = nil
	end

	local v5 = slotInteractionButtonPopOutInAnimation(data.Save, flag)
	local v6 = slotInteractionButtonPopOutInAnimation(data.Wear, flag)
	local v7 = slotInteractionButtonPopOutInAnimation(data.Edit, flag)

	if v5 or v6 or v7 then
		if not self.ongoingAnimationTweens[data] then
			self.ongoingAnimationTweens[data] = {}
		end

		table.insert(self.ongoingAnimationTweens[data], v5)
		table.insert(self.ongoingAnimationTweens[data], v6)
		table.insert(self.ongoingAnimationTweens[data], v7)
	end
end

function v:ToggleOverlappingUIVisibility(visible: boolean)
	for _, v5 in CollectionService:GetTagged("TopLevelAvatarButtons") do
		v5.Visible = visible
	end
end

function v:OnLoadOutfit()
	task.wait(0.5)

	if not (Players.LocalPlayer.Character and v3.Instance.Visible) then
		return
	end

	CameraController.SetAvatarEditorCamera()
end

function v.SaveOutfit(_, p)
	local name = tonumber(p.Name)
	local text = p.SlotName.Text

	if string.len(text) > 15 then
		NotificationController.NotifyEditor("Max 15 Characters")
		return
	end

	local v5, v6 = SavedSlotsController.SaveOutfit(name, text)

	if v5 then
		NotificationController.NotifyEditor("Saved Slot " .. p.Name)
	else
		NotificationController.NotifyEditor(v6)
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
	local buttons = self.Instance:FindFirstChild("Buttons") or self.Instance

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ButtonAdded(button)
		if button:IsA("ImageButton") then
			button.SlotName.PlaceholderText = "Outfit " .. button.Name
			buttonsByName[button.Name] = button
			button.Visible = true
		end
	end

	for _, child in buttons:GetChildren() do
		ButtonAdded(child) -- equivalent call inferred; original call site unknown
	end

	self._Janitor:Add(SavedSlotsController.OnSavedSlotsLoaded:Connect(function(items)
		for k, item in items do
			local v5 = buttonsByName[tostring(k)]

			if v5 then
				v5.SlotName.Text = item or ""
			end
		end
	end))
	local AvatarEditorMenu = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.AvatarEditor.AvatarEditorMenu)
	v2 = AvatarEditorMenu
end

function v:Start()
	for _, v5 in buttonsByName do
		local v6 = v5
		self._Janitor:Add(v5.Activated:Connect(function()
			if v4 == v6 then
				for k, v7 in buttonsByName do
					self:ToggleSlotVisibility(v7, false)
				end

				self:ToggleOverlappingUIVisibility(true)
				v4 = nil
			else
				v4 = v6

				for k, v7 in buttonsByName do
					self:ToggleSlotVisibility(v7, v7 == v6)
				end

				self:ToggleOverlappingUIVisibility(false)
			end
		end))
		local v7 = v5
		self._Janitor:Add(v5.Save.Activated:Connect(function()
			if self.debounce then
				return
			end

			self.debounce = true
			task.delay(0.5, function()
				self.debounce = false
			end)
			local panel = PanelController.GetPanel("NoResetGUIHandler", "ConfirmationPanel")

			if not panel then
				return
			end

			ComponentUtil.FindAndWaitForAncestorComponent(panel.Instance, "ConfirmationPanel", ConfirmationPanel):Init(
				"Are you sure you want to save this outfit?",
				function(flag: boolean)
					if flag then
						self:SaveOutfit(v7)
					end
				end
			)
		end))
		local v8 = v5
		self._Janitor:Add(v5.Wear.Activated:Connect(function()
			if self.debounce then
				return
			end

			self.debounce = true
			task.delay(0.5, function()
				self.debounce = false
			end)
			local name = tonumber(v8.Name)

			if not Players.LocalPlayer.Character then
				return
			end

			local outfit, v9 = SavedSlotsController.LoadOutfit(name)

			if not outfit then
				NotificationController.NotifyEditor(v9)
				return
			end

			NotificationController.NotifyEditor(v9)
			self:OnLoadOutfit(name)
		end))
		local text = nil
		local v9 = v5
		self._Janitor:Add(v5.Edit.Activated:Connect(function()
			local slotName = v9.SlotName
			slotName.TextEditable = true
			slotName.Interactable = true
			slotName.TextColor3 = Color3.new(1, 1, 0)
			text = slotName.Text

			if slotName.Text == "Outfit " .. v9.Name then
				slotName.Text = ""
			end

			slotName:CaptureFocus()
		end))
		local v10 = v5
		self._Janitor:Add(v5.SlotName:GetPropertyChangedSignal("Text"):Connect(function()
			if string.len(v10.SlotName.Text) > 15 then
				NotificationController.NotifyEditor("Max 15 Characters")
				v10.SlotName.TextColor3 = Color3.new(1, 0.5, 0.5)
				TweenService:Create(
					v10.SlotName,
					TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						TextColor3 = Color3.new(1, 1, 0)
					}
				):Play()
				v10.SlotName.Text = v10.SlotName.Text:sub(1, 15)
			end
		end))
		local v11 = v5
		self._Janitor:Add(v5.SlotName.FocusLost:Connect(function()
			local slotName = v11.SlotName
			slotName.TextEditable = false
			slotName.Interactable = false
			local name = tonumber(v11.Name)
			local text2 = slotName.Text

			if string.len(text2) > 15 then
				NotificationController.NotifyEditor("Max 15 Characters")
				slotName.Text = slotName.Text:sub(1, 15)
			else
				if slotName.Text:gsub(" ", "") == "" then
					slotName.Text = "Outfit " .. v11.Name
				end

				if slotName.Text == text then
					TweenService:Create(
						v11.SlotName,
						TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							TextColor3 = Color3.new(1, 1, 1)
						}
					):Play()
					return
				end

				v11.SlotName.TextColor3 = Color3.new(0.5, 1, 0.5)
				local renameSavedSlot, v12, text3 = SavedSlotsController.RenameSavedSlot(name, text2)

				if renameSavedSlot and text2 ~= text3 then
					v11.SlotName.Text = text3
				end

				TweenService:Create(
					v11.SlotName,
					TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						TextColor3 = Color3.new(1, 1, 1)
					}
				):Play()
			end
		end))
	end

	v3 = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "AvatarEditorMenu", v2)
	self._Janitor:Add(v3.OnVisibleChanged:Connect(function(p)
		if not p then
			self:AvatarMenuClosed()
		end
	end))
	local buttons = self.Instance.Buttons

	if buttons then
		self._Janitor:Add(buttons:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			if v4 then
				self:AvatarMenuClosed()
			end
		end))
	end

	self.ongoingAnimationTweens = {}
end

function v:Stop()
	self._Janitor:Destroy()
	self.ongoingAnimationTweens = nil
end

return v