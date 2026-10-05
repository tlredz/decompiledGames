local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local currentCamera = workspace.CurrentCamera
local v = require3(ReplicatedStorage2.Controllers.CinematicController)
local v2 = require3(ReplicatedStorage2.Controllers.UI.DialogueController)
local v3 = {
	PreChange1 = {
		Title = "World Serpent",
		Text = "Your struggle is amusing to me, but now is the time I end this.",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventPart2_Phase4_VA1",
		Duration = 2
	},
	PreChange2 = {
		Title = "World Serpent",
		Text = "The worthy have proven themselves. I acknowledge your strength.",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventPart2_Phase4_VA2",
		Duration = 2
	}
}
return {
	Start = function(_, _, _, p)
		v2:SendText(v3.PreChange1)
		v:CreateCinematicFromConfiguration(p.Phase4.Section1)
		task.wait(5)
		v2:SendText(v3.PreChange2)
		task.wait(5)
		v:Reset()
		currentCamera.FieldOfView = 70
		task.wait(2)
	end
}