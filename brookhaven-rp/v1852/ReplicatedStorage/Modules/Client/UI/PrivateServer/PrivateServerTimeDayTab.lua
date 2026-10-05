local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local v = Component.new({
	Tag = "PrivateServerTimeDayTab"
})
require(ReplicatedStorage.Modules.Client.UI.Utils.UIToggle)
local PrivateServerControlsPanel = require(ReplicatedStorage.Modules.Client.UI.PrivateServer.PrivateServerControlsPanel)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:SetupTimeControls()
	local content = self.Instance:WaitForChild("Time"):WaitForChild("Content")
	local minus = content:WaitForChild("Minus")
	local plus = content:WaitForChild("Plus")
	local timeDisplay = content:WaitForChild("TimeDisplay")
	local _1Cloc1k = ReplicatedStorage.RE:WaitForChild("1Cloc1k")
	self._Janitor:Add(_1Cloc1k.OnClientEvent:Connect(function(text)
		timeDisplay.Text = text
	end))
	self._Janitor:Add(minus.Activated:Connect(function()
		Remotes.fireServerComponent(self.Instance, "ChangeTime", false)
	end))
	self._Janitor:Add(plus.Activated:Connect(function()
		Remotes.fireServerComponent(self.Instance, "ChangeTime", true)
	end))
	local content2 = self.Instance:WaitForChild("Day"):WaitForChild("Content")
	local minus2 = content2:WaitForChild("Minus")
	local plus2 = content2:WaitForChild("Plus")
	self._Janitor:Add(minus2.Activated:Connect(function()
		Remotes.fireServerComponent(self.Instance, "ChangeDay", false)
	end))
	self._Janitor:Add(plus2.Activated:Connect(function()
		Remotes.fireServerComponent(self.Instance, "ChangeDay", true)
	end))
end

function v:TimeSpeedControls()
	local content = self.Instance:WaitForChild("TimeSpeed"):WaitForChild("Content")

	for _, button in content:GetDescendants() do
		if not button:IsA("ImageButton") then
			continue
		end

		local v2 = button
		self._Janitor:Add(button.Activated:Connect(function()
			local timeSpeed = v2:GetAttribute("timeSpeed")
			local checkmark = v2:WaitForChild("Checkmark")

			for i, button2 in content:GetDescendants() do
				if not button2:IsA("ImageButton") then
					continue
				end

				local checkmark_2 = button2:WaitForChild("Checkmark")
				checkmark_2.Visible = false
			end

			checkmark.Visible = true
			Remotes.fireServerComponent(self.Instance, "ChangeTimeSpeed", timeSpeed)
		end))
	end
end

function v:Start()
	self.panelRef = ComponentUtil.FindComponentByAncestor(
		self.Instance,
		"PrivateServerControlsPanel",
		PrivateServerControlsPanel
	)
	self:SetupTimeControls()
	self:TimeSpeedControls()
end

function v:Stop()
	self._Janitor:Destroy()
end

return v