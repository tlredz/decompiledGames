local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local AvatarEditorCodeValidation = require(ReplicatedStorage.Modules.Shared.Utils.Codes.AvatarEditorCodeValidation)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local ConfirmationPanel = require(ReplicatedStorage.Modules.Client.UI.ConfirmationPanel)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local v = Component.new({
	Tag = "AvatarEditorCodes"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:ShowNotification(text: string, color: Color3?)
	local textColor = color or Color3.new(0, 0, 0)
	local statusMessage = self.Instance:WaitForChild("StatusMessage")
	local textLabel = statusMessage:WaitForChild("TextLabel")
	textLabel.Text = text
	textLabel.TextColor3 = textColor
	statusMessage.Visible = true
	task.wait(string.len(text) / 25 + 3)
	statusMessage.Visible = false
end

function v:SetInteractable(interactable: boolean, p)
	if not (self and self.Instance) then
		return
	end

	for _, v2 in p or { self.loadButton, self.exportButton, self.input and self.input.Parent } do
		v2.Interactable = interactable
		local shade = v2:FindFirstChild("Shade")

		if shade then
			shade.Visible = not interactable
		end
	end
end

local v2 = nil

function v:FlashInputTextColor(color: Color3)
	if not self.input then
		return
	end

	if v2 and v2.PlaybackState == Enum.PlaybackState.Playing then
		v2:Cancel()
	end

	self.input.TextColor3 = Color3.new(1, 1, 1)
	v2 = TweenService:Create(
		self.input,
		TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, true, 0.125),
		{
			TextColor3 = color
		}
	)
	v2:Play()
end

function v:OnOpened()
	self.input.Text = ""
	self:SetInteractable(true)
	self._Janitor:Add(self.loadButton.Activated:Connect(function()
		local text = self.input.Text

		if AvatarEditorCodeValidation.DoesCodeLookValid(text) then
			local panel = PanelController.GetPanel("NoResetGUIHandler", "ConfirmationPanel")

			if not panel then
				return
			end

			self:SetInteractable(false)
			ComponentUtil.FindAndWaitForAncestorComponent(panel.Instance, "ConfirmationPanel", ConfirmationPanel):Init(
				"Loading an outfit will replace your current one!",
				function(flag: boolean)
					if not flag then
						self:SetInteractable(true)
						return
					end

					local v3, v4 = Remotes.invokeServer("AvatarEditorOutfitCodes", "Load", text)

					if v3 then
						self.input.Text = ""
						self:SetInteractable(true, { self.input and self.input.Parent })
						self:FlashInputTextColor(Color3.new(0.5, 1, 0.5))
						task.spawn(self.ShowNotification, self, "Success! New outfit equipped!", Color3.new(0, 0, 0))
					else
						self.input.Text = ""
						self:ShowNotification(v4, Color3.new(1, 0, 0))
					end

					task.wait(1)
					self:SetInteractable(true)
				end
			)
		else
			self:FlashInputTextColor(Color3.new(1, 0, 0))
			self:ShowNotification("Invalid code - Please check and try again!", Color3.new(1, 0, 0))
			self:SetInteractable(true)
		end
	end))
	self._Janitor:Add(self.exportButton.Activated:Connect(function()
		self:SetInteractable(false)
		local v3, text = Remotes.invokeServer("AvatarEditorOutfitCodes", "Export")

		if v3 then
			self.input.Text = text
			self:SetInteractable(true, { self.input and self.input.Parent })
			self:FlashInputTextColor(Color3.new(0.5, 1, 0.5))
			task.spawn(self.ShowNotification, self, "Copy this code to share your outfit!", Color3.new(0, 0, 0))
			task.wait(5)
		else
			self:ShowNotification(text, Color3.new(1, 0, 0))
			task.wait(1)
		end

		self:SetInteractable(true)
	end))
end

function v:OnClosed()
	self:SetInteractable(true)

	if self._Janitor then
		self._Janitor:Cleanup()
	end
end

function v:Start()
	self.input = self.Instance:WaitForChild("InputContainer"):WaitForChild("TextBox")
	self.loadButton = self.Instance:WaitForChild("Load")
	self.exportButton = self.Instance:WaitForChild("Export")
	self.openConnection = self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if self.Instance.Visible then
			self:OnOpened()
		else
			self:OnClosed()
		end
	end)
end

function v:Stop()
	if self.openConnection then
		self.openConnection:Disconnect()
	end

	self._Janitor:Destroy()
end

return v