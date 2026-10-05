local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "UIColorLimitedPicker"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._InputJanitor = Janitor.new()
	self.OnColorPicked = Signal.new()
	self.OnColorConfirmed = Signal.new()
	self.OnColorPanelRequestClose = Signal.new()
	self._Janitor:Add(self.OnColorPicked)
	self._Janitor:Add(self.OnColorConfirmed)
	self._Janitor:Add(self.OnColorPanelRequestClose)
	local colorPicksFrame = self.Instance:WaitForChild("ColorPicks"):WaitForChild("ColorPicksFrame")
	self.blocker = colorPicksFrame:WaitForChild("Blocker")
	self.colorLimitsGrid = colorPicksFrame:WaitForChild("Grid")
	self.closeButton = colorPicksFrame:WaitForChild("Background"):WaitForChild("Close")
end

function v:Start()
	self._Janitor:Add(self.OnColorConfirmed:Connect(function(p)
		Remotes.fireServerComponent(self.Instance, "SetColor", p)
	end))
	self._Janitor:Add(self.closeButton.Activated:Connect(function()
		self.OnColorPanelRequestClose:Fire()
	end))
end

function v:SetColors(list)
	for _, guiObject in self.colorLimitsGrid:GetChildren() do
		if guiObject:IsA("GuiObject") and guiObject.Name ~= "Template" then
			guiObject:Destroy()
		end
	end

	for _, backgroundColor in list do
		local clone = self.colorLimitsGrid.Template:Clone()
		clone.Name = "Color"
		clone.BackgroundColor3 = backgroundColor
		clone.Parent = self.colorLimitsGrid
		clone.Visible = true
		local v3 = backgroundColor
		clone.Activated:Connect(function()
			if self.isDebouncing then
				return
			end

			self.isDebouncing = true
			self.OnColorConfirmed:Fire(v3)
			task.wait(0.2)
			self.isDebouncing = false
		end)
	end

	self.colorLimitsGrid.UIGridLayout.CellSize = UDim2.new(1 / #list, -2, 1, 0)
end

function v:Stop()
	self._Janitor:Destroy()
	self._InputJanitor:Destroy()
end

return v