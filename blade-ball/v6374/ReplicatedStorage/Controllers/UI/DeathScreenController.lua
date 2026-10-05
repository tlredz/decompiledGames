local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = nil
local playerGui = Players.LocalPlayer.PlayerGui
local remoteEvent = v:RemoteEvent("StunnedEvent")
local remoteEvent2 = v:RemoteEvent("CustomRespawnEvent")
local remoteEvent3 = v:RemoteEvent("CustomRespawnFinished")
local remoteEvent4 = v:RemoteEvent("DisableRespawnScreen")
local deathScreen = playerGui:WaitForChild("DeathScreen")
local v3 = false
local v4 = false
local flag = false
local DeathScreenController = {
	Init = function(_)
		v2 = require3(script.Parent.SpectateController)
	end,
	Start = function(_)
		remoteEvent4.OnClientEvent:Connect(function(flag2: boolean)
			v3 = flag2

			if flag2 then
				v4 = true
			else
				v4 = false
			end

			leaveDeathScreen()
		end)
		remoteEvent2.OnClientEvent:Connect(function(p: number)
			deathScreenStart(p)
		end)
		remoteEvent.OnClientEvent:Connect(function(p: number)
			if not flag then
				deathScreenStart(p, true)
				return
			end

			leaveDeathScreen()
			task.wait(0.05)
		end)
		remoteEvent3.OnClientEvent:Connect(function()
			leaveDeathScreen()
		end)
		Players:GetPropertyChangedSignal("CharacterAutoLoads"):Connect(function()
			task.wait()

			if Players.CharacterAutoLoads == true then
				leaveDeathScreen()
			end
		end)
	end
}

function leaveDeathScreen()
	if flag or v3 then
		v4 = true
	end

	v2:Leave()
end

function deathScreenEnd()
	local tween = TweenService:Create(deathScreen.BG, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
		BackgroundTransparency = 1
	})
	TweenService:Create(deathScreen.Content.Denomination, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
		TextTransparency = 1
	}):Play()
	TweenService:Create(deathScreen.Content.Header1, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
		TextTransparency = 1
	}):Play()
	TweenService:Create(deathScreen.Content.Header2, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
		TextTransparency = 1
	}):Play()
	TweenService:Create(deathScreen.Content.RespawnTimer, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
		TextTransparency = 1
	}):Play()
	TweenService:Create(deathScreen.Content.Subheader, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
		TextTransparency = 1
	}):Play()
	TweenService:Create(deathScreen.Content.Denomination.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
		Transparency = 1
	}):Play()
	TweenService:Create(deathScreen.Content.Header1.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
		Transparency = 1
	}):Play()
	TweenService:Create(deathScreen.Content.Header2.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
		Transparency = 1
	}):Play()
	TweenService:Create(deathScreen.Content.RespawnTimer.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
		Transparency = 1
	}):Play()
	local tween2 = TweenService:Create(deathScreen.Content.Header2, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
		Position = UDim2.fromScale(0.5, -1)
	})
	local tween3 = TweenService:Create(deathScreen.Content.Header1, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
		Position = UDim2.fromScale(0.5, -1.061)
	})
	local tween4 = TweenService:Create(deathScreen.Content.Subheader, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
		Position = UDim2.fromScale(0.5, 1.86)
	})
	local tween5 = TweenService:Create(deathScreen.Content.RespawnTimer, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
		Position = UDim2.fromScale(0.5, 1.96)
	})
	local tween6 = TweenService:Create(deathScreen.Content.Denomination, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
		Position = UDim2.fromScale(0.5, 2)
	})
	local tween7 = TweenService:Create(deathScreen.Content.UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
		Scale = 2
	})
	tween2:Play()
	tween3:Play()
	tween4:Play()
	tween5:Play()
	tween6:Play()
	tween7:Play()
	tween:Play()
	tween.Completed:Once(function()
		deathScreen.Enabled = false
	end)
	flag = false
end

function deathScreenStart(p: number, flag2: boolean?)
	if v3 or flag then
		return
	end

	flag = true
	local v5 = p or Players.RespawnTime
	local v6 = os.clock() + v5
	deathScreen.Content.Header1.Text = "ELIMINATED"
	deathScreen.Content.Subheader.Text = "<stroke color=\"rgb(0,0,0)\" joins=\"Round\" thickness=\"4\">YOU WILL <font color=\"rgb(73, 211, 31)\">RESPAWN</font> IN</stroke>"
	deathScreen.Content.RespawnTimer.TextColor3 = Color3.fromRGB(73, 211, 31)
	deathScreen.BG.BackgroundTransparency = 1
	deathScreen.Content.Denomination.TextTransparency = 1
	deathScreen.Content.Header1.TextTransparency = 1
	deathScreen.Content.Header2.TextTransparency = 1
	deathScreen.Content.RespawnTimer.TextTransparency = 1
	deathScreen.Content.Subheader.TextTransparency = 1
	deathScreen.Content.Denomination.UIStroke.Transparency = 1
	deathScreen.Content.Header1.UIStroke.Transparency = 1
	deathScreen.Content.Header2.UIStroke.Transparency = 1
	deathScreen.Content.RespawnTimer.UIStroke.Transparency = 1
	local tween = TweenService:Create(deathScreen.BG, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
		BackgroundTransparency = 0
	})
	TweenService:Create(deathScreen.Content.Denomination, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
		TextTransparency = 0
	}):Play()
	TweenService:Create(deathScreen.Content.Header1, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
		TextTransparency = 0
	}):Play()
	TweenService:Create(deathScreen.Content.Header2, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
		TextTransparency = 0
	}):Play()
	TweenService:Create(deathScreen.Content.RespawnTimer, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
		TextTransparency = 0
	}):Play()
	TweenService:Create(deathScreen.Content.Subheader, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
		TextTransparency = 0
	}):Play()
	TweenService:Create(deathScreen.Content.Denomination.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
		Transparency = 0
	}):Play()
	TweenService:Create(deathScreen.Content.Header1.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
		Transparency = 0
	}):Play()
	TweenService:Create(deathScreen.Content.Header2.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
		Transparency = 0
	}):Play()
	TweenService:Create(deathScreen.Content.RespawnTimer.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
		Transparency = 0
	}):Play()

	if flag2 then
		deathScreen.Content.Header1.Text = "STUNNED"
		deathScreen.Content.Subheader.Text = "<stroke color=\"rgb(0,0,0)\" joins=\"Round\" thickness=\"4\">YOU WILL BE BACK IN</stroke>"
		deathScreen.Content.RespawnTimer.TextColor3 = Color3.fromRGB(121, 161, 255)
		deathScreen.Content.Header1.Visible = true
		deathScreen.Content.Header2.Visible = true
	else
		deathScreen.Content.Header1.Visible = false
		deathScreen.Content.Header2.Visible = false
	end

	deathScreen.Content.Header1.Position = UDim2.fromScale(0.5, -1)
	deathScreen.Content.Header2.Position = UDim2.fromScale(0.5, -1.061)
	local tween2 = TweenService:Create(deathScreen.Content.Header2, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
		Position = UDim2.fromScale(0.5, 0)
	})
	local tween3 = TweenService:Create(deathScreen.Content.Header1, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
		Position = UDim2.fromScale(0.5, 0.061)
	})
	deathScreen.Content.UIScale.Scale = 2
	deathScreen.Content.Subheader.Position = UDim2.fromScale(0.5, 1.86)
	deathScreen.Content.RespawnTimer.Position = UDim2.fromScale(0.5, 1.96)
	deathScreen.Content.Denomination.Position = UDim2.fromScale(0.5, 2)
	deathScreen.Content.RespawnTimer.Text = ""
	local tween4 = TweenService:Create(deathScreen.Content.Subheader, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
		Position = UDim2.fromScale(0.5, 0.86)
	})
	local tween5 = TweenService:Create(deathScreen.Content.RespawnTimer, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
		Position = UDim2.fromScale(0.5, 0.96)
	})
	local tween6 = TweenService:Create(deathScreen.Content.Denomination, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
		Position = UDim2.fromScale(0.5, 1)
	})
	local tween7 = TweenService:Create(deathScreen.Content.UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
		Scale = 1
	})
	deathScreen.Enabled = true
	tween:Play()
	task.wait(0.15)
	tween2:Play()
	tween3:Play()
	tween4:Play()
	tween5:Play()
	tween6:Play()
	tween7:Play()
	tween7.Completed:Wait()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(_: number)
		local now = os.clock()
		local text = math.max(math.floor((v6 - now) * 10) / 10, 0)
		deathScreen.Content.RespawnTimer.Text = text
		deathScreen.Content.Denomination.Text = text == 1 and "Second" or "Seconds"

		if text == 0 or v4 then
			v4 = false
			heartbeatConnection:Disconnect()
			deathScreenEnd()
		end
	end)
end

return DeathScreenController