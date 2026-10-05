local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIToggle = require(ReplicatedStorage.Modules.Client.UI.Utils.UIToggle)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "WeatherControlTab"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.db = false
end

function v:Start()
	for _, button in self.Instance:WaitForChild("Lighting"):WaitForChild("Frame"):GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local v2 = button
		button.MouseButton1Click:Connect(function()
			if self.db then
				return
			end

			self.db = true
			task.delay(0.25, function()
				self.db = false
			end)
			Remotes.fireServerComponent(self.Instance, "SetLighting", v2.Name, true)
		end)
	end

	for _, button in self.Instance:WaitForChild("Weather"):WaitForChild("Frame"):GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local v2 = button
		button.MouseButton1Click:Connect(function()
			if self.db then
				return
			end

			self.db = true
			task.delay(0.25, function()
				self.db = false
			end)
			local checkmark = v2:WaitForChild("Checkmark")
			Remotes.fireServerComponent(self.Instance, "SetWeather", v2.Name, not checkmark.Visible)
		end)
	end

	for _, button in self.Instance:WaitForChild("Skybox"):WaitForChild("Frame"):GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local v2 = button
		button.MouseButton1Click:Connect(function()
			if self.db then
				return
			end

			self.db = true
			task.delay(0.25, function()
				self.db = false
			end)
			local checkmark = v2:WaitForChild("Checkmark")
			Remotes.fireServerComponent(self.Instance, "SetWeather", v2.Name, not checkmark.Visible)
		end)
	end

	local bubbleUI = self.Instance:WaitForChild("Other"):WaitForChild("BubbleUI")
	local component = ComponentUtil.GetComponentFromInstance(bubbleUI, UIToggle)
	self._Janitor:Add(component.onToggle:Connect(function(_)
		Remotes.fireServerComponent(self.Instance, "SetBubbleUI", component:isOn())
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v