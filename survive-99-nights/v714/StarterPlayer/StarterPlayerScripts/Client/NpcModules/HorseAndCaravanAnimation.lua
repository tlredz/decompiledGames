local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local RunService = game:GetService("RunService")

function HorseAndCaravanAdded(instance)
	if instance.Parent ~= workspace.Characters then
		return
	end

	local mainCaravan = instance:WaitForChild("Caravan"):WaitForChild("MainCaravan")
	local wheelLeft = mainCaravan:WaitForChild("WheelLeft")
	local wheelRight = mainCaravan:WaitForChild("WheelRight")
	local C0 = wheelLeft.C0
	local C02 = wheelRight.C0
	local pivot = instance:GetPivot()

	while instance.Parent do
		local pivot2 = instance:GetPivot()
		local magnitude = ((pivot2.Position - pivot.Position) * createVector(1, 0, 1)).Magnitude

		if magnitude > 0.001 then
			local v = math.rad(20 * magnitude)
			C0 *= CFrame.Angles(v, 0, 0)
			C02 *= CFrame.Angles(-v, 0, 0)
			wheelLeft.C0 = C0
			wheelRight.C0 = C02
		end

		RunService.RenderStepped:Wait()
		pivot = pivot2
	end
end

Client.Utility.ForAllTagged("HorseAndCaravan", HorseAndCaravanAdded)
return {}