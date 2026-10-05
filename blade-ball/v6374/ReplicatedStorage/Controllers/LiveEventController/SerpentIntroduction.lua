local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local v = require3(ReplicatedStorage2.Common.Utils)
local currentCamera = workspace.CurrentCamera
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local v2 = require3(ReplicatedStorage2.Controllers.CinematicController)
local v3 = require3(ReplicatedStorage2.Controllers.UI.DialogueController)
local v4 = {
	IntroductionA = {
		Title = "???",
		Text = "Which fool thought it would be a good idea to awaken the serpent?",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEvent_SerpentVA1",
		Duration = 2
	},
	IntroductionB = {
		Title = "World Serpent",
		Text = "They send <b>" .. v.ValueConvertor:FormatMarkupColor("YOU", Color3.fromRGB(255, 0, 0)) .. "</b> to resurrect me? Is this a joke?",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEvent_SerpentVA2",
		Duration = 2
	},
	PreFight1 = {
		Title = "World Serpent",
		Text = "You have been fighting each other for decades now. But are you ready to see what you are TRULY fighting for?",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEvent_SerpentVA3",
		Duration = 2
	},
	PreFight2 = {
		Title = "World Serpent",
		Text = "Prove yourselves worthy. Fight each other to the last remaining team. [laughs]",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEvent_SerpentVA4",
		Duration = 2
	}
}
return {
	Start = function(_, p)
		local v5 = p or workspace.Map:FindFirstChild("Fantasy")

		if not v5 then
			warn("[SerpentIntroduction] Fantasy map is missing")
			return false
		end

		v5.VANITY.Dragon:SetAttribute("DisabledAttack", true)
		task.wait(2)
		v.Sounds:Play("LiveEvent_SerpentRumble", v5.VANITY.Dragon.PrimaryPart)

		for _, child in pairs(localPlayer.PlayerGui:GetChildren()) do
			if child.Name ~= "BlackScreen" then
				continue
			end

			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(child.Frame, tweenInfo, {
				BackgroundTransparency = 1
			}):Play()
			local v6 = child
			task.delay(1, function()
				v6:Destroy()
			end)
		end

		v5.VANITY.Dragon.AnimationController:LoadAnimation(script.SpawnAnimation):Play()
		task.spawn(function()
			for i = 1, 3 do
				v2:Shake(3, i * 5, 0.5)
				task.wait(0.5)
			end
		end)
		currentCamera.FieldOfView = 20
		v2:CreateCinematicFromConfiguration(v5.Cinematic.Intro1).Removed:Wait()
		v3:SendText(v4.IntroductionA)
		task.delay(0.5, function()
			v3:SendText(v4.IntroductionB)
		end)
		TweenService:Create(currentCamera, TweenInfo.new(2, Enum.EasingStyle.Linear), {
			FieldOfView = 60
		}):Play()
		v.Sounds:Play("LiveEvent_SerpentRoar1")
		v2:CreateCinematicFromConfiguration(v5.Cinematic.Intro2).Removed:Wait()
		v3:SendText(v4.PreFight1)
		v2:CreateCinematicFromConfiguration(v5.Cinematic.Intro3).Removed:Wait()
		TweenService:Create(currentCamera, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {
			FieldOfView = 120
		}):Play()
		v2:Shake(20, 45, 3)
		v.Sounds:Play("LiveEvent_SerpentRoar2")
		v2:CreateCinematicFromConfiguration(v5.Cinematic.Intro4).Removed:Wait()
		TweenService:Create(currentCamera, TweenInfo.new(4, Enum.EasingStyle.Linear), {
			FieldOfView = 90
		}):Play()
		task.delay(3.25, function()
			v2:Shake(3, 15, 2)
			v.Sounds:Play("LiveEvent_SerpentRoar3")
		end)
		v2:CreateCinematicFromConfiguration(v5.Cinematic.Intro5).Removed:Wait()
		v3:SendText(v4.PreFight2)
		CollectionService:AddTag(v5.VANITY.Dragon, "LiveEventSerpent")
		task.wait(3)
		v5.VANITY.Dragon:SetAttribute("DisabledAttack", nil)
		currentCamera.FieldOfView = 70
		v2:Reset()
	end
}