local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local v = require3(ReplicatedStorage2.Controllers.CinematicController)
local v2 = require3(ReplicatedStorage2.Controllers.UI.DialogueController)
local v3 = {
	[2] = {
		Title = "World Serpent",
		Text = "You think your tiny collection of warriors will do anything to me!?",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventPart2_Phase2_VA1",
		Duration = 3
	},
	[3] = {
		Title = "World Serpent",
		Text = "Your arrogance will be your downfall. This ends now!",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventPart2_Phase3_VA1",
		Duration = 3
	}
}
return {
	Start = function(_, p: number)
		local currentCamera = Workspace.CurrentCamera
		local v4 = v3[p]

		if not (currentCamera and v4) then
			return false
		end

		local fieldOfView = currentCamera.FieldOfView
		TweenService:Create(currentCamera, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
			FieldOfView = math.max(35, fieldOfView - 20)
		}):Play()
		v:Shake(2.5, p * 2 + 8, 1.5)
		v2:SendText(v4)
		task.wait(4)
		TweenService:Create(currentCamera, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
			FieldOfView = fieldOfView
		}):Play()
		v:Reset()
		return true
	end
}