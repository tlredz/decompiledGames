local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "AvatarList"
})
local v2 = false
local WearingController = require(ReplicatedStorage.Modules.Client.AvatarEditor.WearingController)
local ConfirmationPanel = require(ReplicatedStorage.Modules.Client.UI.ConfirmationPanel)
local Debris = game:GetService("Debris")
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local AvatarEditorMenu = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.AvatarEditor.AvatarEditorMenu)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local v3 = {
	Skye = 1,
	Brian = 2
}

local function applyCornerIcon(clone, data)
	if data.Image == nil or data.Image == "" then
		return
	end

	local emptyMesh = clone:FindFirstChild("EmptyMesh")

	if not emptyMesh then
		return
	end

	emptyMesh.Position = UDim2.fromScale(0.1, 0.4)
	emptyMesh.Size = UDim2.fromScale(0.8, 0.8)
	emptyMesh.Visible = true
	emptyMesh.Image = data.Image

	if data.Position ~= nil then
		emptyMesh.Position = UDim2.new(
			data.Position.X.Scale,
			data.Position.X.Offset,
			data.Position.Y.Scale,
			data.Position.Y.Offset
		)
	end

	if data.Size ~= nil then
		emptyMesh.Size = UDim2.new(data.Size.X.Scale, data.Size.X.Offset, data.Size.Y.Scale, data.Size.Y.Offset)
	end
end

function v:Build(items)
	self._confirmationPanelObj = PanelController.GetPanel("NoResetGUIHandler", "AvatarEditorConfirmationPanel")

	if not self._confirmationPanelObj then
		return
	end

	self._confirmationPanel = ComponentUtil.FindAndWaitForAncestorComponent(
		self._confirmationPanelObj.Instance,
		"ConfirmationPanel",
		ConfirmationPanel
	)
	self._clickJanitor:Cleanup()
	local uIGridLayout = self.Instance:FindFirstChild("UIGridLayout")

	if uIGridLayout then
		uIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	end

	for k, item in items do
		local clone = self.templateButton:Clone()
		clone.Name = item.Name
		clone.LayoutOrder = k
		clone.Icon.Image = "rbxthumb://type=Asset&id=" .. item.Id .. "&w=150&h=150"
		local feminine = item.Feminine
		local child = clone:FindFirstChild(feminine and "FeminineSymbol" or "MaleSymbol")
		local child2 = clone:FindFirstChild(feminine and "MaleSymbol" or "FeminineSymbol")

		if child then
			child.Visible = true
		end

		if child2 then
			Debris:AddItem(child2, 0)
		end

		local cornerIconData = item.CornerIconData
		local v4 = cornerIconData == nil and v3[item.Name] ~= nil and {
			Image = "rbxassetid://106931571839436"
		} or cornerIconData

		if v4 ~= nil then
			applyCornerIcon(clone, v4)
		end

		local v5 = item

		local function onActivated()
			if self.selectDebounce then
				return
			end

			self.selectDebounce = true
			task.delay(0.5, function()
				self.selectDebounce = false
			end)

			if self._confirmationPanelObj and self._confirmationPanelObj:IsOpen() then
				self._confirmationPanelObj:Close()
			else
				self._confirmationPanel:Init("Loading an outfit will replace your current one!", function(flag: boolean)
					if flag then
						WearingController.ChangePlayerToAvatar(v5.Name)
					else
						print("User did not confirm")
					end
				end)
			end
		end

		clone.Parent = self.Instance
		self._clickJanitor:Add(clone.Activated:Connect(onActivated))
	end

	local absoluteContentSize = uIGridLayout.AbsoluteContentSize
	self.Instance.CanvasSize = UDim2.new(0, 0, 0, absoluteContentSize.Y)
end

function v:Destroy()
	for _, button in self.Instance:GetChildren() do
		if button:IsA("ImageButton") then
			button:Destroy()
		end
	end

	self.Instance.CanvasPosition = Vector2.new(0, 0)
	self._clickJanitor:Cleanup()
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._clickJanitor = Janitor.new()
	self.selectDebounce = false
	local AvatarsConfig = require(ReplicatedStorage.Modules.Shared.DB.AvatarEditor.Avatars.AvatarsConfig)
	v2 = AvatarsConfig
end

function v:Start()
	self.templateButton = self.Instance:FindFirstChild("TemplateButton")
	self.templateButton.Parent = nil
	local config = v2.getConfig()
	local v4 = {}

	for _, v5 in config do
		table.insert(v4, v5)
	end

	table.sort(v4, function(a, b)
		local v5 = v3[a.Name]
		local v6 = v3[b.Name]
		local v7 = v5 ~= nil
		local v8 = v6 ~= nil

		if v7 ~= v8 then
			return v7
		end

		if v7 and v8 then
			return v5 < v6
		end

		return a.Feminine and not b.Feminine
	end)
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"AvatarEditorMenu",
		AvatarEditorMenu
	)
	self._Janitor:Add(waitForAncestorComponent.Instance:GetPropertyChangedSignal("Visible"):Connect(function(p)
		if not p and self._confirmationPanelObj and self._confirmationPanelObj:IsOpen() then
			self._confirmationPanelObj:Close()
		end
	end))
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if self.Instance.Visible then
			self:Build(v4)
			return
		end

		if self._confirmationPanelObj and self._confirmationPanelObj:IsOpen() then
			self._confirmationPanelObj:Close()
		end

		self:Destroy()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v