local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "OutfitSlots"
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
local v5 = 1

function v:AvatarMenuClosed()
	self:ToggleOverlappingUIVisibility(true)

	for _, v6 in buttonsByName do
		self:ToggleSlotVisibility(v6, false)
	end

	v4 = nil
end

local function SlotInteractionButtonPopOutInAnimation(instance, flag: boolean)
	if instance.Visible == flag then
		return
	end

	instance.Visible = false
	instance:RemoveTag("HoverAndActivationFX")

	if not flag then
		return
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
	local v6 = math.abs(position.X.Scale - clone.Position.X.Scale) / 4.25 + 0.3
	Debris:AddItem(clone, v6)
	local tween = TweenService:Create(clone, TweenInfo.new(v6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = position,
		BackgroundTransparency = backgroundTransparency
	})
	TweenService:Create(clone.Icon, TweenInfo.new(v6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
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
		for _, v6 in self.ongoingAnimationTweens[data] do
			if v6.PlaybackState == Enum.PlaybackState.Playing then
				v6:Cancel()
			end
		end

		self.ongoingAnimationTweens[data] = nil
	end

	local slotInteractionButtonPopOutInAnimation = SlotInteractionButtonPopOutInAnimation(data.Save, flag)
	local slotInteractionButtonPopOutInAnimation2 = SlotInteractionButtonPopOutInAnimation(data.Wear, flag)
	local slotInteractionButtonPopOutInAnimation3 = SlotInteractionButtonPopOutInAnimation(data.Edit, flag)

	if slotInteractionButtonPopOutInAnimation or slotInteractionButtonPopOutInAnimation2 or slotInteractionButtonPopOutInAnimation3 then
		if not self.ongoingAnimationTweens[data] then
			self.ongoingAnimationTweens[data] = {}
		end

		table.insert(self.ongoingAnimationTweens[data], slotInteractionButtonPopOutInAnimation)
		table.insert(self.ongoingAnimationTweens[data], slotInteractionButtonPopOutInAnimation2)
		table.insert(self.ongoingAnimationTweens[data], slotInteractionButtonPopOutInAnimation3)
	end
end

function v:ToggleOverlappingUIVisibility(visible: boolean)
	for _, v6 in CollectionService:GetTagged("TopLevelAvatarButtons") do
		v6.Visible = visible
	end
end

function v:OnLoadOutfit()
	task.wait(0.5)

	if not (Players.LocalPlayer.Character and v3.Instance.Visible) then
		return
	end

	CameraController.SetAvatarEditorCamera()
end

function v:ShowNextSlotPage()
	v5 += 1

	if v5 > 5 then
		v5 = 1
	end

	local v6 = (v5 - 1) * 5 + 1
	local v7 = v6 + 5 - 1

	for _, v8 in buttonsByName do
		local name = tonumber(v8.Name)
		v8.Visible = v6 <= name and name <= v7
	end

	self:ToggleOverlappingUIVisibility(true)
end

function v:ShowPreviousSlotPage()
	v5 -= 1

	if v5 < 1 then
		v5 = 5
	end

	local v6 = (v5 - 1) * 5 + 1
	local v7 = v6 + 5 - 1

	for _, v8 in buttonsByName do
		local name = tonumber(v8.Name)
		v8.Visible = v6 <= name and name <= v7
	end

	self:ToggleOverlappingUIVisibility(true)
end

function v.SaveOutfit(_, p)
	local name = tonumber(p.Name)
	local text = p.SlotName.Text

	if string.len(text) > 15 then
		NotificationController.NotifyEditor("Max 15 Characters")
		return
	end

	local v6, v7 = SavedSlotsController.SaveOutfit(name, text)

	if v6 then
		NotificationController.NotifyEditor("Saved Slot " .. p.Name)
	else
		NotificationController.NotifyEditor(v7)
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
	local buttons = self.Instance:FindFirstChild("Buttons")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ButtonAdded(button)
		if button:IsA("ImageButton") then
			button.SlotName.PlaceholderText = "Outfit " .. button.Name
			buttonsByName[button.Name] = button
		end
	end

	buttons.ChildAdded:Connect(ButtonAdded)

	for _, child in buttons:GetChildren() do
		ButtonAdded(child) -- equivalent call inferred; original call site unknown
	end

	self._Janitor:Add(SavedSlotsController.OnSavedSlotsLoaded:Connect(function(items)
		for k, item in items do
			local v6 = buttonsByName[tostring(k)]

			if v6 then
				v6.SlotName.Text = item or ""
			end
		end
	end))
	local AvatarEditorMenu = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.AvatarEditor.AvatarEditorMenu)
	v2 = AvatarEditorMenu
end

function v:Start()
	for _, v6 in buttonsByName do
		local v7 = v6
		self._Janitor:Add(v6.Activated:Connect(function()
			if v4 == v7 then
				for k, v8 in buttonsByName do
					self:ToggleSlotVisibility(v8, false)
				end

				self:ToggleOverlappingUIVisibility(true)
				v4 = nil
			else
				v4 = v7

				for k, v8 in buttonsByName do
					self:ToggleSlotVisibility(v8, v8 == v7)
				end

				self:ToggleOverlappingUIVisibility(false)
			end
		end))
		local panel = PanelController.GetPanel("NoResetGUIHandler", "ConfirmationPanel")

		if not panel then
			return
		end

		local v8 = ComponentUtil.FindAndWaitForAncestorComponent(panel.Instance, "ConfirmationPanel", ConfirmationPanel)
		local v9 = v6
		self._Janitor:Add(v6.Save.Activated:Connect(function()
			v8:Init("Are you sure you want to save this outfit?", function(flag: boolean)
				if flag then
					self:SaveOutfit(v9)
				end
			end)
		end))
		local v10 = v6
		self._Janitor:Add(v6.Wear.Activated:Connect(function()
			local name = tonumber(v10.Name)

			if not Players.LocalPlayer.Character then
				return
			end

			local outfit, v11 = SavedSlotsController.LoadOutfit(name)

			if not outfit then
				NotificationController.NotifyEditor(v11)
				return
			end

			NotificationController.NotifyEditor(v11)
			self:OnLoadOutfit(name)
		end))
		local text = nil
		local v11 = v6
		self._Janitor:Add(v6.Edit.Activated:Connect(function()
			local slotName = v11.SlotName
			slotName.TextEditable = true
			slotName.Interactable = true
			slotName.TextColor3 = Color3.new(1, 1, 0)
			text = slotName.Text

			if slotName.Text == "Outfit " .. v11.Name then
				slotName.Text = ""
			end

			slotName:CaptureFocus()
		end))
		local v12 = v6
		self._Janitor:Add(v6.SlotName:GetPropertyChangedSignal("Text"):Connect(function()
			if string.len(v12.SlotName.Text) > 15 then
				NotificationController.NotifyEditor("Max 15 Characters")
				v12.SlotName.TextColor3 = Color3.new(1, 0.5, 0.5)
				TweenService:Create(
					v12.SlotName,
					TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						TextColor3 = Color3.new(1, 1, 0)
					}
				):Play()
				v12.SlotName.Text = v12.SlotName.Text:sub(1, 15)
			end
		end))
		local v13 = v6
		self._Janitor:Add(v6.SlotName.FocusLost:Connect(function()
			local slotName = v13.SlotName
			slotName.TextEditable = false
			slotName.Interactable = false
			local name = tonumber(v13.Name)
			local text2 = slotName.Text

			if string.len(text2) > 15 then
				NotificationController.NotifyEditor("Max 15 Characters")
				slotName.Text = slotName.Text:sub(1, 15)
			else
				if slotName.Text:gsub(" ", "") == "" then
					slotName.Text = "Outfit " .. v13.Name
				end

				if slotName.Text == text then
					TweenService:Create(
						v13.SlotName,
						TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							TextColor3 = Color3.new(1, 1, 1)
						}
					):Play()
					return
				end

				v13.SlotName.TextColor3 = Color3.new(0.5, 1, 0.5)
				local renameSavedSlot, v14, text3 = SavedSlotsController.RenameSavedSlot(name, text2)

				if renameSavedSlot and text2 ~= text3 then
					v13.SlotName.Text = text3
				end

				TweenService:Create(
					v13.SlotName,
					TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						TextColor3 = Color3.new(1, 1, 1)
					}
				):Play()
			end
		end))
	end

	local prevPage = self.Instance:FindFirstChild("PrevPage")
	local nextPage = self.Instance:FindFirstChild("NextPage")
	self._Janitor:Add(prevPage.Activated:Connect(function()
		self:ShowPreviousSlotPage()
	end))
	self._Janitor:Add(nextPage.Activated:Connect(function()
		self:ShowNextSlotPage()
	end))

	local function HookupButtonHoverClickFX(data, udim: UDim2)
		local size = data.Size
		local position = data.Position
		self._Janitor:Add(data.MouseEnter:Connect(function()
			TweenService:Create(data, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = size + UDim2.new(0.02, 0, 0.02, 0),
				Position = position
			}):Play()
			TweenService:Create(data.ImageLabel, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				ImageColor3 = Color3.new(1, 1, 0.5)
			}):Play()
		end))
		self._Janitor:Add(data.MouseLeave:Connect(function()
			TweenService:Create(data, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Size = size,
				Position = position
			}):Play()
			TweenService:Create(data.ImageLabel, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				ImageColor3 = Color3.new(1, 1, 1)
			}):Play()
		end))
		self._Janitor:Add(data.Activated:Connect(function()
			local tween = TweenService:Create(
				data,
				TweenInfo.new(0.125, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Size = size - UDim2.new(0.0075, 0, 0.0075, 0),
					Position = position + udim
				}
			)
			tween.Completed:Once(function(p)
				if p == Enum.PlaybackState.Completed then
					if data.GuiState == Enum.GuiState.Hover then
						TweenService:Create(data, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
							Size = size + UDim2.new(0.02, 0, 0.02, 0),
							Position = position
						}):Play()
					else
						TweenService:Create(data, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
							Size = size,
							Position = position
						}):Play()
					end
				end
			end)
			tween:Play()
			local tween2 = TweenService:Create(
				data.ImageLabel,
				TweenInfo.new(0.125, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					ImageColor3 = Color3.new(0.95, 0.95, 0.475)
				}
			)
			tween2.Completed:Once(function(p)
				if p == Enum.PlaybackState.Completed then
					if data.GuiState == Enum.GuiState.Hover then
						TweenService:Create(
							data.ImageLabel,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								ImageColor3 = Color3.new(1, 1, 0.5)
							}
						):Play()
					else
						TweenService:Create(
							data.ImageLabel,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								ImageColor3 = Color3.new(1, 1, 1)
							}
						):Play()
					end
				end
			end)
			tween2:Play()
		end))
	end

	HookupButtonHoverClickFX(prevPage, UDim2.new(0, 0, -0.00375, 0))
	HookupButtonHoverClickFX(nextPage, UDim2.new(0, 0, 0.00375, 0))
	v3 = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "AvatarEditorMenu", v2)
	v3.OnVisibleChanged:Connect(function(p)
		if not p then
			self:AvatarMenuClosed()
		end
	end)
	self.ongoingAnimationTweens = {}
end

function v:Stop()
	self._Janitor:Destroy()
	self.ongoingAnimationTweens = nil
end

return v