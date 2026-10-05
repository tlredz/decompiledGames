local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Skill_Controller = require(ReplicatedStorage.CAM.Client.Controllers.Skill_Controller)
require(ReplicatedStorage.Packages.cleanit)
local DashHandler = {
	LastDid = 0,
	LifeCleaner = nil,
	Letter = function(point: Vector2)
		if math.abs(point.X) > math.abs(point.Y) then
			if point.X > 0 then
				return "D"
			end

			return "A"
		elseif point.Y < 0 then
			return "W"
		else
			return "S"
		end
	end
}

function DashHandler.MovementLetter()
	local Players = game:GetService("Players")
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local currentCamera = workspace.CurrentCamera

	if humanoid == nil or currentCamera == nil then
		return "W"
	end

	local moveDirection = humanoid.MoveDirection

	if moveDirection.Magnitude < 0.1 then
		return "W"
	end

	local lookVector = currentCamera.CFrame.LookVector
	local vector = Vector3.new(lookVector.X, 0, lookVector.Z)

	if vector.Magnitude < 0.01 then
		return "W"
	end

	local unit = vector.Unit
	local vector2 = Vector3.new(-unit.Z, 0, unit.X)
	return DashHandler.Letter(Vector2.new(moveDirection:Dot(vector2), -moveDirection:Dot(unit)))
end

function DashHandler.Perform(p: string)
	local attempt_Hold = Skill_Controller.Attempt_Hold("Dash", p)

	if attempt_Hold == true then
		Skill_Controller.StopHold("Dash")
	end

	DashHandler.LastDid = tick()
	return attempt_Hold == true
end

return DashHandler