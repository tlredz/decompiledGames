local HappyPlotsClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local RunService = game:GetService("RunService")

function StrainAgainstJam(instance)
	local horizontalGear = instance:FindFirstChild("HorizontalGear", true)
	local blades = instance:FindFirstChild("Blades", true)
	local pivot = horizontalGear and horizontalGear:GetPivot()
	local pivot2 = blades and blades:GetPivot()
	Client.TweenModule.new(function(p)
		if not instance:HasTag("StuckWindmill") then
			return true
		end

		local v = math.sin(3.141592653589793 * p) * 0.08726646259971647

		if horizontalGear and horizontalGear.Parent then
			horizontalGear:PivotTo(pivot * CFrame.Angles(0, v, 0))
		end

		if blades and blades.Parent then
			blades:PivotTo(pivot2 * CFrame.Angles(v, 0, 0))
		end
	end, 0.5):Play()
	task.wait(0.5)

	if not instance:HasTag("StuckWindmill") then
		return
	end

	if horizontalGear and horizontalGear.Parent then
		horizontalGear:PivotTo(pivot)
	end

	if blades and blades.Parent then
		blades:PivotTo(pivot2)
	end
end

function StuckWindmillAdded(instance)
	task.spawn(function()
		while instance.Parent and instance:HasTag("StuckWindmill") do
			task.wait(1.5)

			if instance.Parent and instance:HasTag("StuckWindmill") then
				StrainAgainstJam(instance)
			else
				break
			end
		end
	end)
end

function MovingWindmillAdded(instance)
	local horizontalGear = nil
	local blades = nil
	local pivot = nil
	local pivot2 = nil
	local v = 0
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if not (instance.Parent and instance:HasTag("MovingWindmill")) then
			renderSteppedConnection:Disconnect()
			return
		end

		if not (horizontalGear and horizontalGear.Parent) then
			horizontalGear = instance:FindFirstChild("HorizontalGear", true)
			pivot = horizontalGear and horizontalGear:GetPivot()
		end

		if not (blades and blades.Parent) then
			blades = instance:FindFirstChild("Blades", true)
			pivot2 = blades and blades:GetPivot()
		end

		v = (v + 0.5235987755982988 * dt) % 6.283185307179586

		if horizontalGear then
			horizontalGear:PivotTo(pivot * CFrame.Angles(0, v, 0))
		end

		if blades then
			blades:PivotTo(pivot2 * CFrame.Angles(v, 0, 0))
		end
	end)
end

function HappyPlotsClient.Init()
	Client.Utility.ForAllTagged("StuckWindmill", StuckWindmillAdded)
	Client.Utility.ForAllTagged("MovingWindmill", MovingWindmillAdded)
end

return HappyPlotsClient