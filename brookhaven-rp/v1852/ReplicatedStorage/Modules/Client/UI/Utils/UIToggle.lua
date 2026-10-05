local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = Component.new({
	Tag = "UIToggle"
})

function v:SetState(visible: boolean)
	self.checkmark.Visible = visible
	self.onToggle:Fire(visible)
end

function v.isOn(p)
	return p.checkmark.Visible
end

function v:SetInteractable(flag: boolean)
	self.Interactable = flag
	self.checkmark.ImageTransparency = flag and 0 or 0.5
	self.toggle.Selectable = flag
	self.toggle.Interactable = flag
end

function v:Construct()
	self._Janitor = Janitor.new()
	self.toggle = self.Instance:WaitForChild("Toggle")
	self.checkmark = self.toggle:WaitForChild("Checkmark")
	self.onToggle = Signal.new()
	self._Janitor:Add(self.toggle.Activated:Connect(function()
		if self.Interactable == false then
			return
		end

		self:SetState(not self.checkmark.Visible)
	end))
end

function v.Start(_) end

function v:Stop()
	self._Janitor:Destroy()
end

return v