local createVector = vector.create
local QuicksandHandler = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = false

function StandingOnQuicksand(p)
	local position = p.Position
	local raycastResult = workspace:Raycast(position, createVector(0, -5, 0), Client.CollisionUtility.DefaultParams)
	local magnitude = raycastResult and (raycastResult.Position - p.Position).Magnitude

	if raycastResult and raycastResult.Instance:GetAttribute("Quicksand") then
		return true, magnitude
	end
end

function CharacterAdded(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	Client.WalkspeedController.RemoveSpeedChange("Quicksand")
	humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
		if not Client.PlayerHandler.Alive then
			return
		end

		if not v and StandingOnQuicksand(humanoidRootPart) then
			v = true
			local v2 = 0

			while localPlayer.Character and humanoidRootPart.Parent ~= nil do
				local v3 = task.wait()
				local v4, v5 = StandingOnQuicksand(humanoidRootPart)

				if not v4 then
					break
				end

				if not (v5 < 4.1) then
					continue
				end

				v2 = math.clamp(v2 + 1.9 * v3, 0, 1.9)
				local v6 = 16 - v2 / 1.9 * 10
				Client.WalkspeedController.SetOverallSpeed("Quicksand", v6, "Traps")
				humanoid.HipHeight = -v2
			end

			humanoid.HipHeight = 0
			v = false
			Client.WalkspeedController.RemoveSpeedChange("Quicksand")
		end
	end)
end

function QuicksandHandler.Init()
	task.spawn(function()
		localPlayer.CharacterAdded:Connect(CharacterAdded)

		if localPlayer.Character then
			CharacterAdded(localPlayer.Character)
		end
	end)
end

return QuicksandHandler