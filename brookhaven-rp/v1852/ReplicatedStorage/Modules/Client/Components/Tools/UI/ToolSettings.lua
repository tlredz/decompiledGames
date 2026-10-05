local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = Component.new({
	Tag = "ToolSettings"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.OnToolSettingOpened = Signal.new()
	self.OnToolSettingClosed = Signal.new()
	local button = self.Instance:WaitForChild("SettingFrame"):WaitForChild("LeftSide"):WaitForChild("Button")
	self.settingsFrame = self.Instance:WaitForChild("Settings")
	self._ToggleButton = button
end

function v:Start()
	self._Janitor:Add(self._ToggleButton.Activated:Connect(function()
		for _, frame in self.settingsFrame:GetChildren() do
			if frame:IsA("Frame") then
				frame.Visible = not frame.Visible
			end
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v