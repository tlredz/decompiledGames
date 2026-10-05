local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PropsTextureApplyButton"
})
local PropEditable = require(ReplicatedStorage.Modules.Client.Components.Props.PropEditable)
local PropTextures = require(ReplicatedStorage.Modules.Shared.Props.PropTextures)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local textureName = self.Instance:GetAttribute("TextureName") or self.Instance.Name
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		local currentSelectedPropEditable = PropEditable.GetCurrentSelectedPropEditable()

		if currentSelectedPropEditable == nil then
			return
		end

		if self.Instance:GetAttribute("ResetTexture") then
			currentSelectedPropEditable:ApplyTexture("")
		elseif PropTextures.IsValid(textureName) then
			currentSelectedPropEditable:ApplyTexture(textureName)
		else
			warn("PropsTextureApplyButton: Invalid texture name:", textureName)
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v