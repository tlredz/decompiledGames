local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LegacyGame8Settings = require(ReplicatedStorage.Modules.Client.UI.LegacyGame8Settings)
local cemeteryRemote = LegacyGame8Settings.CemeteryRemote
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "LegacyNamePrompt"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.Request = self.Instance:GetAttribute("LegacyNamePrompt_Request")

	if typeof(self.Request) ~= "string" then
		warn("LegacyNamePrompt_Request is not a string!")
	end
end

function v:Start()
	local v2 = false
	self._Janitor:Add(self.Instance.FocusLost:Connect(function()
		if not v2 then
			v2 = true
			cemeteryRemote:FireServer(self.Request, self.Instance.Text)
			wait(0.5)
			v2 = false
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v