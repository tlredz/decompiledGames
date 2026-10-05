local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local InteractUIColorPicker = require(ReplicatedStorage.Modules.Client.UI.InteractUIColorPicker)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local v = Component.new({
	Tag = "GiftTable"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local uIColorPicker = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("NoResetGUIHandler"):WaitForChild("UIColorPicker")
	self._interactUIColorPicker = ComponentUtil.GetComponentFromInstance(uIColorPicker, InteractUIColorPicker)
	self.bowReference = self.Instance:WaitForChild("Bow")
	self.wrapReference = self.Instance:WaitForChild("Wrap")
	self.debounce = false
	local clickDetector = self.Instance:WaitForChild("FingerWrap"):WaitForChild("ClickDetector")
	self._Janitor:Add(clickDetector.MouseClick:Connect(function(_)
		local color = self.wrapReference.Color
		self._interactUIColorPicker:Open("Change Wrap Color", color, function(p)
			if self.debounce then
				return
			end

			self.debounce = true
			task.delay(0.2, function()
				self.debounce = false
			end)
			Remotes.fireServerComponent(self.Instance, "ChangeColor1", p)
		end)
	end))
	local clickDetector2 = self.Instance:WaitForChild("FingerBow"):WaitForChild("ClickDetector")
	self._Janitor:Add(clickDetector2.MouseClick:Connect(function(_)
		local color = self.bowReference.Color
		self._interactUIColorPicker:Open("Change Bow Color", color, function(p)
			if self.debounce then
				return
			end

			self.debounce = true
			task.delay(0.2, function()
				self.debounce = false
			end)
			Remotes.fireServerComponent(self.Instance, "ChangeColor2", p)
		end)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v