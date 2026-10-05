local StrongholdCountdownClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local touchedConnection = nil
local strongholdUpdateText = nil
local v = {}
local v2 = {
	Stronghold = {
		Text = "The Cultist Stronghold"
	}
}
local v3 = {
	Color3.fromRGB(195, 255, 0),
	Color3.fromRGB(255, 238, 0),
	Color3.fromRGB(255, 157, 0),
	Color3.fromRGB(255, 64, 0),
	Color3.fromRGB(255, 0, 0)
}

function StrongholdCountdownClient.DisplayTitle(p, value)
	if table.find(v, p .. value) then
		return
	end

	Client.Sound.Play("StrongholdEnter")
	local v4 = value or 1
	table.insert(v, p .. value)

	if v2[p].Text then
		strongholdUpdateText.Text = v2[p].Text
		strongholdUpdateText.LevelCount.Text = "LEVEL " .. v4
		strongholdUpdateText.LevelCount.TextColor3 = v3[v4] or v3[5]
	end

	strongholdUpdateText.LevelCount.TextTransparency = 1
	strongholdUpdateText.TextTransparency = 1
	strongholdUpdateText.Visible = true
	TweenService:Create(strongholdUpdateText, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		TextTransparency = 0
	}):Play()
	TweenService:Create(
		strongholdUpdateText.UIStroke,
		TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{
			Transparency = 0
		}
	):Play()
	TweenService:Create(
		strongholdUpdateText.LevelCount,
		TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{
			TextTransparency = 0
		}
	):Play()
	TweenService:Create(
		strongholdUpdateText.LevelCount.UIStroke,
		TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{
			Transparency = 0
		}
	):Play()
	wait(4)
	TweenService:Create(strongholdUpdateText, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		TextTransparency = 1
	}):Play()
	TweenService:Create(
		strongholdUpdateText.UIStroke,
		TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{
			Transparency = 1
		}
	):Play()
	TweenService:Create(
		strongholdUpdateText.LevelCount,
		TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{
			TextTransparency = 1
		}
	):Play()
	TweenService:Create(
		strongholdUpdateText.LevelCount.UIStroke,
		TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{
			Transparency = 1
		}
	):Play()
	wait(2)
	strongholdUpdateText.Visible = false
end

function StrongholdAdded(instance)
	local functional = instance:WaitForChild("Functional")

	if instance.Name == "AlienMothership" then
		return
	end

	local surfaceGui = functional:WaitForChild("Sign"):WaitForChild("SurfaceGui")
	local v4 = 0

	local function beginCountdown()
		local openTime = functional:GetAttribute("OpenTime")
		local v5 = v4 + 1
		v4 = v5

		if touchedConnection then
			touchedConnection:Disconnect()
		end

		if openTime then
			surfaceGui.Frame.Level.Text = "LEVEL " .. functional:GetAttribute("Level")
			surfaceGui.Frame.Level.TextColor3 = v3[functional:GetAttribute("Level")] or v3[5]
			task.spawn(function()
				wait(5)
				surfaceGui.Frame.Level.Text = "LEVEL " .. functional:GetAttribute("Level")
				surfaceGui.Frame.Level.TextColor3 = v3[functional:GetAttribute("Level")] or v3[5]
			end)

			while v4 == v5 do
				local v6 = openTime - workspace:GetServerTimeNow()

				if v6 < 0 then
					print("less than 0")
					surfaceGui.Enabled = false
					return
				else
					if v6 <= 60 then
						surfaceGui.Frame.Body.Text = convertToS(v6)
					else
						surfaceGui.Frame.Body.Text = convertToMS(v6)
					end

					surfaceGui.Enabled = true
					RunService.RenderStepped:Wait()
				end
			end
		else
			surfaceGui.Enabled = false
		end
	end

	functional:GetAttributeChangedSignal("OpenTime"):Connect(beginCountdown)
	beginCountdown()

	if instance and instance:FindFirstChild("Functional") and instance.Functional:FindFirstChild("TitleAppear") then
		touchedConnection = instance.Functional.TitleAppear.Touched:Connect(function(otherPart)
			if otherPart.Parent and localPlayer.Character and otherPart.Parent == localPlayer.Character then
				touchedConnection:Disconnect()
				StrongholdCountdownClient.DisplayTitle(instance.Name, instance.Functional:GetAttribute("Level") or 1)
			end
		end)
	end
end

function convertToS(p)
	return string.format("%02is", p % 60)
end

function convertToMS(p)
	return string.format("%02im %02is", p / 60 % 60, p % 60)
end

function StrongholdCountdownClient.Init()
	Client.Utility.ForAllTagged("Stronghold", StrongholdAdded)
	task.spawn(function()
		strongholdUpdateText = localPlayer.PlayerGui.Interface:WaitForChild("StrongholdUpdateText")
	end)
end

return StrongholdCountdownClient