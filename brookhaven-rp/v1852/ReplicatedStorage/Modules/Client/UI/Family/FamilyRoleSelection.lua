local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local FamilyRoles = require(ReplicatedStorage.Modules.Shared.Family.FamilyRoles)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local v = Component.new({
	Tag = "FamilyRoleSelection"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._list = self.Instance:WaitForChild("Selectors"):WaitForChild("List")
	self._interactButtons = self.Instance:WaitForChild("InteractButtons")
	self._selectedRole = nil
end

function v:Start()
	for _, familyRole in FamilyRoles do
		local clone = self._list.Role:Clone()
		clone.Title.Text = familyRole
		clone.Visible = true
		clone.Name = familyRole
		clone.Parent = self._list
		local selectedRole = familyRole
		clone.Activated:Connect(function()
			self._selectedRole = selectedRole

			for i, guiObject in self._list:GetChildren() do
				if not guiObject:IsA("GuiObject") then
					continue
				end

				if guiObject.Name == self._selectedRole then
					guiObject.CheckBox:AddTag("Checked")
				else
					guiObject.CheckBox:RemoveTag("Checked")
				end
			end

			Platform.Select(self._interactButtons)
		end)
	end

	self._Janitor:Add(self._interactButtons.Yes.Activated:Connect(function()
		if not self._selectedRole then
			NotificationController.NotifyCenter("Please select a role")
			return
		end

		Remotes.fireServer("SetFamilyRole", self._selectedRole)
		self.Instance.Visible = false
	end))
	self._Janitor:Add(self._list.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self._list.CanvasSize = UDim2.fromOffset(0, self._list.UIListLayout.AbsoluteContentSize.Y + 10)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v