local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = Component.new({
	Tag = "HoistControls"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._selectedHoist = "MidHoist"
	self._upDown = false
	self._downDown = false
	self.ChangeAttachment = self._Janitor:Add(Signal.new())
	self.UpStateChanged = self._Janitor:Add(Signal.new())
	self.DownStateChanged = self._Janitor:Add(Signal.new())
end

function v:UpdateChecked()
	for _, button in self.Instance.Buttons:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		if button.Name == self._selectedHoist then
			button.Check:AddTag("Checked")
		else
			button.Check:RemoveTag("Checked")
		end
	end
end

function v:Start()
	local buttons = self.Instance:WaitForChild("Buttons")
	local controls = self.Instance:WaitForChild("Controls")

	for _, button in buttons:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local v2 = button
		self._Janitor:Add(button.Activated:Connect(function()
			self:SelectHoist(v2.Name)
			self:UpdateChecked()
		end))
	end

	local upButton = controls:WaitForChild("UpButton")
	local downButton = controls:WaitForChild("DownButton")
	local changeAttachment = controls:WaitForChild("ChangeAttachment")
	self._Janitor:Add(upButton.MouseButton1Down:Connect(function()
		self._upDown = true
		self.UpStateChanged:Fire(true)
	end))
	self._Janitor:Add(upButton.MouseButton1Up:Connect(function()
		self._upDown = false
		self.UpStateChanged:Fire(false)
	end))
	self._Janitor:Add(downButton.MouseButton1Down:Connect(function()
		self._downDown = true
		self.DownStateChanged:Fire(true)
	end))
	self._Janitor:Add(downButton.MouseButton1Up:Connect(function()
		self._downDown = false
		self.DownStateChanged:Fire(false)
	end))
	self._Janitor:Add(changeAttachment.Activated:Connect(function()
		self.ChangeAttachment:Fire()
	end))
	self._Janitor:Add(UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if self._upDown then
				self._upDown = false
				self.UpStateChanged:Fire(false)
			end

			if self._downDown then
				self._downDown = false
				self.DownStateChanged:Fire(false)
			end
		end
	end))
	self:UpdateChecked()
end

function v:SelectHoist(selectedHoist: string)
	self._selectedHoist = selectedHoist
end

function v:GetSelectedHoist()
	return self._selectedHoist
end

function v:Stop()
	self._Janitor:Destroy()
end

return v