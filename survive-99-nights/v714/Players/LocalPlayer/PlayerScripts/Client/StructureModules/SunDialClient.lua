local SunDialClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = false

function AddSunDial(instance)
	if instance:IsDescendantOf(workspace.Structures) and not v then
		v = true
		local sunDial = Client.Interface.TopRight.Frame.SunDial
		local _ = workspace.CurrentCamera
		game:GetService("RunService")
		local topRight = Client.Interface.TopRight
		topRight.Visible = true

		if sunDial.Visible ~= true then
			topRight:SetAttribute("EnabledSoFar", topRight:GetAttribute("EnabledSoFar") + 1)
			sunDial.LayoutOrder = topRight:GetAttribute("EnabledSoFar")
		end

		sunDial.Visible = true
	end
end

function secondsToTime(p)
	local v2 = math.floor(p / 60)
	local v3 = p % 60
	return string.format("%d:%02d", v2, v3)
end

function SunDialClient.Init()
	task.spawn(function()
		workspace:GetAttributeChangedSignal("SecondsLeft"):Connect(function()
			Client.Interface.TopRight.Frame.SunDial.RealTimer.Text = secondsToTime(workspace:GetAttribute("SecondsLeft"))
		end)
		workspace:GetAttributeChangedSignal("State"):Connect(function()
			task.spawn(function()
				wait(3)
				local sunDial = Client.Interface.TopRight.Frame.SunDial

				if workspace:GetAttribute("State") == "Day" then
					sunDial.RainLabel.Image = "rbxassetid://100299758402529"
				else
					sunDial.RainLabel.Image = "rbxassetid://71043129916600"
				end
			end)
		end)
	end)
	Client.Utility.ForAllTagged("SunDial", AddSunDial)
end

return SunDialClient