local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LegacyGame8Settings = require(ReplicatedStorage.Modules.Client.UI.LegacyGame8Settings)
local cemeteryRemote = LegacyGame8Settings.CemeteryRemote
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "LegacyColor"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.Request = self.Instance:GetAttribute("LegacyColor_Request")

	if typeof(self.Request) ~= "string" then
		warn("LegacyColor is not a string!")
	end
end

function v:Start()
	local v2 = false

	for _, child in pairs(self.Instance:GetChildren()) do
		if not child:isA("ImageButton") then
			continue
		end

		local v3 = child
		self._Janitor:Add(child.Activated:connect(function()
			if not v2 then
				v2 = true

				if v3.Name == "Colors" and v3:FindFirstChild("Color") then
					cemeteryRemote:FireServer(self.Request, v3.Color)
				end

				wait(0.3)
				v2 = false
			end
		end))
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v