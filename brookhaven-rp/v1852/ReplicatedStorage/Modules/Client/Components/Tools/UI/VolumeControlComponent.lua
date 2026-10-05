local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VolumeControlComponent"
})
local v2 = false
local Remotes = require(ReplicatedStorage.Packages.Remotes)

function v:Construct()
	self._Janitor = Janitor.new()
	local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
	v2 = ReplicatedDataController
	local slider = self.Instance:WaitForChild("Slider")
	self.fillArea = slider:WaitForChild("FillArea")
	self.volumeText = slider:WaitForChild("SliderText")
	self.minusButton = self.Instance:WaitForChild("Minus")
	self.plusButton = self.Instance:WaitForChild("Plus")
	self.volume = 50
end

function v:UpdateText()
	self.volume = math.clamp(self.volume, 5, 100)
	self.fillArea.Size = UDim2.new(self.volume / 100, 0, self.fillArea.Size.Y.Scale, self.fillArea.Size.Y.Offset)
	self.volumeText.Text = `{self.volume}`
	Remotes.fireServerComponent(self.Instance, "VolumeChangeRequest", self.volume)
end

function v:Start()
	self._Janitor:Add(self.minusButton.MouseButton1Click:connect(function()
		self.volume = math.ceil(self.volume / 5) * 5
		self.volume -= 5
		self:UpdateText()
	end))
	self._Janitor:Add(self.plusButton.MouseButton1Click:connect(function()
		self.volume = math.floor(self.volume / 5) * 5
		self.volume += 5
		self:UpdateText()
	end))
	self._Janitor:Add(self.volumeText.FocusLost:Connect(function(p)
		if p then
			local text = tonumber(self.volumeText.Text)

			if text then
				self.volume = math.clamp(text, 5, 100)

				if self.volume ~= self.volume then
					self.volume = 50
				end

				self:UpdateText()
			else
				self:UpdateText()
			end
		end
	end))
	v2.GetClientReplicaPromise():andThen(function(p)
		self.volume = p.Data.musicPlayerVolume
		self:UpdateText()
	end)
	self:UpdateText()
end

function v:Stop()
	self._Janitor:Destroy()
end

return v