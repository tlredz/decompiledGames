local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "AvatarEditorOpenContextButton"
})
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local AvatarEditorContext = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.AvatarEditor.AvatarEditorContext)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance

	if not instance:IsA("ImageButton") then
		warn("AvatarEditorOpenContextButton: Button is not an ImageButton")
		return
	end

	local value = instance.Context.Value

	if not value then
		warn("AvatarEditorOpenContextButton: Context object value is nil")
		return
	end

	local component = ComponentUtil.GetComponentFromInstance(value, AvatarEditorContext)

	if component then
		self._Janitor:Add(instance.Activated:Connect(function()
			local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
				self.Instance,
				"AvatarEditorContext",
				AvatarEditorContext
			)

			if not waitForAncestorComponent then
				local value2 = instance.ContextToClose.Value

				if not value2 then
					warn("AvatarEditorOpenContextButton: Current context object value is nil")
					return
				end

				waitForAncestorComponent = ComponentUtil.GetComponentFromInstance(value2, AvatarEditorContext)

				if waitForAncestorComponent then
					waitForAncestorComponent:Open()
				else
					warn("AvatarEditorOpenContextButton: Current AvatarEditorContext not found")
					return
				end
			end

			if waitForAncestorComponent then
				waitForAncestorComponent:Close()
			end

			if not component:IsOpen() then
				component:Open()
				return
			end

			component:Close()
			waitForAncestorComponent:Open()
		end))
	else
		warn("AvatarEditorOpenContextButton: AvatarEditorContext not found")
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v