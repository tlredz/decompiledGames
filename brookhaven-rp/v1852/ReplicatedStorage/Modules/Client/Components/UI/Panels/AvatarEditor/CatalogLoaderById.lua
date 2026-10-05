local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "CatalogLoaderById"
})
local WearingController = require(ReplicatedStorage.Modules.Client.AvatarEditor.WearingController)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(self.Instance.FocusLost:connect(function()
		local text = self.Instance.Text

		if tonumber(text) then
			WearingController.WearAsset(text)
		else
			self.Instance.Text = "Enter ID#"
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v