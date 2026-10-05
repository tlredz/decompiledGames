local WeatherMachineClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
WeatherMachineClient.TimeBetweenScans = 540
WeatherMachineClient.LastScan = -99999

function WeatherMachineClient.OpenWeatherMachineMenu(p)
	if os.time() - WeatherMachineClient.LastScan < WeatherMachineClient.TimeBetweenScans then
		return
	end

	Client.GemActivateClient.OpenMenu(p)
end

function WeatherMachineClient.onScanSuccess(instance)
	local main = instance:WaitForChild("Main")
	local attachment = main:WaitForChild("Attachment")
	local attachment2 = attachment:WaitForChild("Attachment")
	local v = {
		attachment:WaitForChild("SpottedBouncy"),
		attachment:WaitForChild("NormalCircularBouncy"),
		(attachment2:WaitForChild("SpottedCircle"))
	}
	task.spawn(function()
		for _ = 1, 3 do
			for _, v2 in pairs(v) do
				local v3 = v2
				task.spawn(function()
					v3:Emit(1)
					task.wait(0.05)
					v3:Emit(1)
					task.wait(0.05)
					v3:Emit(1)
				end)
			end

			main.WeatherNoise:Stop()
			main.WeatherNoise:Play()
			task.wait(0.5)
		end
	end)
end

local flag = false
Client.Events.RunWeatherMachineEffect:Connect(function()
	if flag then
		return
	end

	local weatherMachine = workspace.Structures:FindFirstChild("Weather Machine")

	if not weatherMachine then
		return
	end

	setActive(weatherMachine)
	wait(WeatherMachineClient.TimeBetweenScans)
	setIdle(weatherMachine)
end)

function setActive(data)
	flag = true
	data.Screen.Material = Enum.Material.Neon
	data.Screen.Color = Color3.fromRGB(32, 255, 65)
	data.Rod.Pole.Color = Color3.fromRGB(32, 255, 65)
	data.Rod.Part.Color = Color3.fromRGB(55, 255, 102)
	data.BigScreen.Decal.Color3 = Color3.fromRGB(0, 255, 20)
	data.Main.MachineHum:Play()
	data.Main.ProximityAttachment.ProximityInteraction.Enabled = false
end

function setIdle(data)
	flag = false
	data.Screen.Material = Enum.Material.Glass
	data.Screen.Color = Color3.fromRGB(27, 42, 53)
	data.Rod.Pole.Color = Color3.fromRGB(102, 156, 217)
	data.Rod.Part.Color = Color3.fromRGB(82, 124, 174)
	data.BigScreen.Decal.Color3 = Color3.fromRGB(255, 255, 255)
	data.Main.MachineHum:Stop()
	data.Main.ProximityAttachment.ProximityInteraction.Enabled = true
end

function WeatherMachineClient.Init()
	task.spawn(function()
		while true do
			task.wait(2)
			local weatherMachine = workspace.Structures:FindFirstChild("Weather Machine")

			if not (weatherMachine and flag) then
				continue
			end

			local attachment = weatherMachine:WaitForChild("Main"):WaitForChild("Attachment")
			local attachment2 = attachment:WaitForChild("Attachment")
			local v = {
				attachment:WaitForChild("SpottedBouncy"),
				attachment:WaitForChild("NormalCircularBouncy"),
				(attachment2:WaitForChild("SpottedCircle"))
			}

			for _, v2 in pairs(v) do
				v2:Emit(1)
			end
		end
	end)
end

return WeatherMachineClient