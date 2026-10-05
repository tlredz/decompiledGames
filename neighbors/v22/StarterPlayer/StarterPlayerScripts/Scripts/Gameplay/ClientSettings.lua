for _, child in game.ReplicatedStorage.Assets.Tools:GetChildren() do
	local v = child
	pcall(function()
		require(v)
	end)
end

local Players = game:GetService("Players")
LocalPlayer = Players.LocalPlayer
LocalPlayer:GetAttributeChangedSignal("MuteToolSounds"):Connect(function()
	local SoundService = game:GetService("SoundService")
	local tools = SoundService:WaitForChild("Tools")
	tools.Volume = LocalPlayer:GetAttribute("MuteToolSounds") and 0 or 1
end)
LocalPlayer:GetAttributeChangedSignal("MuteWeather"):Connect(function()
	local SoundService = game:GetService("SoundService")
	local weather = SoundService:WaitForChild("Weather")
	weather.Volume = LocalPlayer:GetAttribute("MuteWeather") and 0 or 0.15
end)
LocalPlayer:GetAttributeChangedSignal("MuteMusic"):Connect(function()
	local SoundService = game:GetService("SoundService")
	local theme = SoundService:WaitForChild("Theme")
	theme.Volume = LocalPlayer:GetAttribute("MuteMusic") and 0 or 1
end)