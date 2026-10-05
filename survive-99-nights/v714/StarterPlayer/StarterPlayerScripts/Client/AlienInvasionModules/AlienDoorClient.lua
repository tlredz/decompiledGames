game:GetService("ReplicatedStorage")
local AlienDoorClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)

function OpenDoor(instance, value)
	if instance:GetAttribute("Opened") then
		return
	end

	instance:SetAttribute("Opened", true)
	local children = instance:GetChildren()
	local pivots = {}

	for _, v in pairs(children) do
		if v.Name == "DoorPiece" then
			pivots[v] = v:GetPivot()
		end
	end

	Client.TweenModule.new(function(p)
		for k, v in pairs(pivots) do
			local v2 = math.sqrt(p) * 45
			local v3 = p ^ 2 * 48
			k.CFrame = v * CFrame.Angles(0, math.rad(-v2), 0) * CFrame.new(0, 0, 4.5 * p) * CFrame.Angles(
				0,
				math.rad(-v3),
				0
			)
		end
	end, value or 0.4, "Quad"):Play()
	Client.Sound.Play("AlienDoorOpen", {
		Volume = 1,
		Position = instance:GetPivot().Position,
		PlaybackSpeed = 2
	})
end

Client.Events.OpenAlienDoor:Connect(OpenDoor)

function AlienDoorClient.Init() end

return AlienDoorClient