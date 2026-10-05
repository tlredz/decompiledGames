local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "WordsBoard"
})
local playerGui = Players.LocalPlayer.PlayerGui

function v:Construct()
	self._Janitor = Janitor.new()
	self._uiJanitor = self._Janitor:Add(Janitor.new())
end

function v:Start()
	local cemeteryName = playerGui:WaitForChild("MainGUIHandler"):WaitForChild("Menu"):WaitForChild("CemeteryName")
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "ShowUI", function()
		self._uiJanitor:Cleanup()
		cemeteryName.Visible = true
		local D = cemeteryName.A.B.C.D
		self._uiJanitor:Add(D.FocusLost:Once(function()
			Remotes.fireServerComponent(self.Instance, "SetText", D.Text)
			cemeteryName.Visible = false
			D.Text = ""
		end))
		self._uiJanitor:Add(cemeteryName:GetPropertyChangedSignal("Visible"):Connect(function()
			self._uiJanitor:Cleanup()
		end))
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v