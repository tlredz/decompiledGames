local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local Signal = require(ReplicatedStorage.Packages.Signal)
local MusicController = require(ReplicatedStorage.Modules.Client.Music.MusicController)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local v = Component.new({
	Tag = "HelicopterControl"
})

function v:Construct()
	self._Janitor = Janitor.new()
	local helicopterButtons = self.Instance:WaitForChild("HelicopterControl"):WaitForChild("HelicopterButtons")
	self._hoistButton = helicopterButtons:WaitForChild("Hoists")
	self._regSpeedFrame = self.Instance:WaitForChild("HeliSpeedUI"):WaitForChild("Speed"):WaitForChild("Speed")
	self._helicopterButtons = helicopterButtons
	self.OnVerticalUpStarted = Signal.new()
	self.OnVerticalUpEnded = Signal.new()
	self.OnVerticalDownStarted = Signal.new()
	self.OnVerticalDownEnded = Signal.new()
	self._verticalUpDown = false
	self._verticalDownDown = false
	self.Speed = 50
	self.MaxSpeed = 0
	self:SetMaxSpeed(0)
end

function v:Start()
	local regSpeed = self._helicopterButtons:WaitForChild("RegSpeed")
	local mobileControls = self.Instance:WaitForChild("MobileControls")
	self._Janitor:Add(regSpeed.Activated:Connect(function()
		PanelController.TogglePanelByGroup("HelicopterControl", "HeliSpeedUI", "HelicopterControls")
	end))
	local music = self._helicopterButtons:WaitForChild("Music")
	self._Janitor:Add(music.Activated:Connect(function()
		MusicController.OpenMusicMenu("helicopter audio", AdFeatures.CAR_MUSIC)
	end))
	self._Janitor:Add(self._hoistButton.Activated:Connect(function()
		PanelController.TogglePanelByGroup("HoistControls", "HoistControls", "HelicopterControls")
	end))
	self:SetupSpeedButtons()
	self:SetSpeed(self.Speed)
	self._Janitor:Add(self._helicopterButtons:WaitForChild("VerticalUp").MouseButton1Down:Connect(function()
		self._verticalUpDown = true
		self.OnVerticalUpStarted:Fire()
	end))
	self._Janitor:Add(self._helicopterButtons:WaitForChild("VerticalUp").MouseButton1Up:Connect(function()
		self._verticalUpDown = false
		self.OnVerticalUpEnded:Fire()
	end))
	self._Janitor:Add(self._helicopterButtons:WaitForChild("VerticalDown").MouseButton1Down:Connect(function()
		self._verticalDownDown = true
		self.OnVerticalDownStarted:Fire()
	end))
	self._Janitor:Add(self._helicopterButtons:WaitForChild("VerticalDown").MouseButton1Up:Connect(function()
		self._verticalDownDown = false
		self.OnVerticalDownEnded:Fire()
	end))
	self._Janitor:Add(mobileControls:WaitForChild("VerticalUp").MouseButton1Down:Connect(function()
		self._verticalUpDown = true
		self.OnVerticalUpStarted:Fire()
	end))
	self._Janitor:Add(mobileControls:WaitForChild("VerticalUp").MouseButton1Up:Connect(function()
		self._verticalUpDown = false
		self.OnVerticalUpEnded:Fire()
	end))
	self._Janitor:Add(mobileControls:WaitForChild("VerticalDown").MouseButton1Down:Connect(function()
		self._verticalDownDown = true
		self.OnVerticalDownStarted:Fire()
	end))
	self._Janitor:Add(mobileControls:WaitForChild("VerticalDown").MouseButton1Up:Connect(function()
		self._verticalDownDown = false
		self.OnVerticalDownEnded:Fire()
	end))
	self._Janitor:Add(UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if self._verticalUpDown then
				self._verticalUpDown = false
				self.OnVerticalUpEnded:Fire()
			end

			if self._verticalDownDown then
				self._verticalDownDown = false
				self.OnVerticalDownEnded:Fire()
			end
		end
	end))
	self._Janitor:Add(self._regSpeedFrame.Speed.FocusLost:Connect(function()
		local text = tonumber(self._regSpeedFrame.Speed.Text) or self.Speed
		self:SetSpeed(text)
	end))
end

function v:SetMaxSpeed(maxSpeed: number)
	self.MaxSpeed = maxSpeed
	self:SetSpeed(maxSpeed)
	self._regSpeedFrame.MaxSpeed.Text = `Max Speed {maxSpeed}`
end

function v:SetupSpeedButtons()
	self._Janitor:Add(self._regSpeedFrame.Lower.Activated:Connect(function()
		self:SetSpeed(self.Speed - 10)
	end))
	self._Janitor:Add(self._regSpeedFrame.Add.Activated:Connect(function()
		self:SetSpeed(self.Speed + 10)
	end))
end

function v:SetSpeed(value: number)
	local v2 = math.clamp(value, 0, self.MaxSpeed)
	self.Speed = v2
	self._regSpeedFrame.Speed.Text = v2
end

function v:SetHoistButtonVisible(visible: boolean)
	self._hoistButton.Visible = visible
end

function v:Stop()
	self._Janitor:Destroy()
end

return v