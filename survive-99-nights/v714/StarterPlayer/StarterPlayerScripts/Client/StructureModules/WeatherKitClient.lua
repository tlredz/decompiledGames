local WeatherKitClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = false

function AddWeatherKit(instance)
	if instance:IsDescendantOf(workspace.Structures) and not v then
		v = true
		local rain = Client.Interface.TopRight.Frame.Rain
		local _ = workspace.CurrentCamera
		game:GetService("RunService")
		local topRight = Client.Interface.TopRight
		topRight.Visible = true

		if rain.Visible ~= true then
			topRight:SetAttribute("EnabledSoFar", topRight:GetAttribute("EnabledSoFar") + 1)
			rain.LayoutOrder = topRight:GetAttribute("EnabledSoFar")
		end

		rain.Visible = true
	end
end

function WeatherKitClient.Init()
	task.spawn(function()
		workspace:WaitForChild("Map"):GetAttributeChangedSignal("RainChance"):Connect(function()
			Client.Interface.TopRight.Frame.Rain.RealTimer.Text = "%" .. workspace.Map:GetAttribute("RainChance")
		end)
	end)
end

Client.Utility.ForAllTagged("WeatherKit", AddWeatherKit)
return WeatherKitClient