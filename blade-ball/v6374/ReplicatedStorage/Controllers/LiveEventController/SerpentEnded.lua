local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local v = require3(ReplicatedStorage2.Common.Utils)
local v2 = require3(ReplicatedStorage2.Controllers.CinematicController)
local v3 = require3(ReplicatedStorage2.Controllers.UI.DialogueController)
return {
	Start = function(_, p, list)
		local WAIT_INTERVAL = 1
		local screenGui = Instance.new("ScreenGui")
		Debris:AddItem(screenGui, 30)
		screenGui.DisplayOrder = 99
		screenGui.Name = "BlackScreen"
		screenGui.ResetOnSpawn = false
		screenGui.Parent = localPlayer.PlayerGui
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 1, 36)
		frame.Position = UDim2.new(0, 0, 0, -36)
		frame.BackgroundColor3 = Color3.new(0, 0, 0)
		frame.BorderSizePixel = 0
		frame.BackgroundTransparency = 1
		frame.Parent = screenGui
		TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
			BackgroundTransparency = 0
		}):Play()
		local dragon = p.VANITY.Dragon
		dragon:SetAttribute("DisabledAttack", true)

		if #list > 0 then
			local v4 = {
				Title = "World Serpent",
				Text = "%s have proven themselves worthy, but they will need a clan to resurrect me. I will be awaiting your finest legion.",
				TitleColor = Color3.fromRGB(87, 146, 253),
				Sound = "LiveEvent_SerpentVAFinal",
				Duration = 2
			}
			local v5 = {}

			for _, v6 in pairs(list) do
				table.insert(
					v5,
					v.ValueConvertor:FormatMarkupColor("<b>" .. v6.Name .. "</b>", Color3.fromRGB(255, 255, 0))
				)
			end

			v4.Text = v4.Text:format(table.concat(v5, " and "))
			v3:SendText(v4)
		end

		task.wait(WAIT_INTERVAL)
		TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
			BackgroundTransparency = 1
		}):Play()
		v2:CreateCinematicFromConfiguration(p.Cinematic.CloseUp).Removed:Wait()
		task.wait(3)
		v.Sounds:Play("LiveEvent_SerpentRoarEnding")
		p.VANITY.Dragon.AnimationController:LoadAnimation(script.DespawnAnimation):Play()
		v2:Shake(3, 15, 4.5)
		local pivot = dragon:GetPivot()
		v.Thread.LoopFor(4.5, function(p2)
			dragon:SetPrimaryPartCFrame(pivot * CFrame.new(0, -50 * p2, 0))
		end)
		v2:CreateCinematicFromConfiguration(p.Cinematic.Ending1).Removed:Wait()
		v2:CreateCinematicFromConfiguration(p.Cinematic.Ending2).Removed:Wait()
		v2:CreateCinematicFromConfiguration(p.Cinematic.Ending3).Removed:Wait()
		v2:CreateCinematicFromConfiguration(p.Cinematic.Ending4).Removed:Wait()
		task.wait(WAIT_INTERVAL)
		TweenService:Create(frame, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			BackgroundTransparency = 0
		}):Play()
		task.wait(WAIT_INTERVAL)
		v2:Reset()
		dragon:SetAttribute("DisabledAttack", nil)
		CollectionService:RemoveTag(dragon, "Cinematic")
		task.wait(WAIT_INTERVAL)
		TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
			BackgroundTransparency = 0
		}):Play()
		task.wait(0.5)
		dragon:Destroy()
		screenGui:Destroy()
	end
}