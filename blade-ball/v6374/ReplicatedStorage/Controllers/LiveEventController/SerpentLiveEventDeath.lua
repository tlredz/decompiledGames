local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.Utils)
local v2 = require3(ReplicatedStorage2.Controllers.CinematicController)
local v3 = require3(ReplicatedStorage2.Controllers.UI.DialogueController)
local v4 = {
	Finale = {
		Title = "World Serpent",
		Text = "You are not as insignificant as I thought. I grant you my respect.",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventPart2_Death_VA1",
		Duration = 2
	}
}
return {
	Start = function(_, p, parent, p2)
		parent:WaitForChild("AnimationController"):LoadAnimation(script.DeathAnimation):Play()
		local _ = p or workspace.Map:FindFirstChild("Fantasy")
		v3:SendText(v4.Finale)
		v.Sounds:Play("LiveEvent_SerpentRoarEnding")
		v2:CreateCinematicFromConfiguration(p2.Death.Section1).Removed:Wait()
		v2:CreateCinematicFromConfiguration(p2.Death.Section2).Removed:Wait()
		v2:CreateCinematicFromConfiguration(p2.Death.Section3).Removed:Wait()
		v2:CreateCinematicFromConfiguration(p2.Death.Section4).Removed:Wait()
		local highlight = Instance.new("Highlight")
		highlight.Name = "SerpentHighlight"
		highlight.FillColor = Color3.new(1, 1, 1)
		highlight.FillTransparency = 1
		highlight.Parent = parent
		v.Thread.LoopFor(0.5, function(p3)
			highlight.FillTransparency = 1 - p3
		end).Ended:Connect(function()
			local v5 = math.max(
				v.Visual:PlayEffects(parent.BottomJaw.DeathEffect1),
				v.Visual:PlayEffects(parent.BottomJaw.DeathEffect2)
			)
			v.Thread.LoopFor(v5, function(p3)
				parent.BottomJaw.Transparency = p3
				parent["BottomJaw.001"].Transparency = p3
				highlight.FillTransparency = p3
				highlight.OutlineTransparency = p3
			end)
		end)
		task.wait(6)
		v2:Reset()
	end
}