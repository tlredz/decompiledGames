local BatHandlerClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = {
	FirstSpawn = function(instance)
		instance:WaitForChild("TriggerZone").Touched:Connect(function(otherPart)
			if localPlayer.Character and otherPart == localPlayer.Character.PrimaryPart then
				Client.Events.ScareOffBatEveryone:FireServer()
				Client.Events.FirstBatScareOff:Fire()
			end
		end)
		local cFrame = instance.Spawn.CFrame
		local _ = instance.WalkTo.Position
		local batClient = Client.BatClient.new(cFrame)
		batClient:SetMovement("Idle")
		Client.Events.FirstBatScareOff:Wait()
		batClient:Scream(2, true)
		task.wait(2.5)
		batClient:SetMovement("Hover")
		task.wait(0.2)
		local v2 = batClient:MoveTo(instance.Despawn.Position)
		task.wait(0.2)
		batClient:SetMovement("Flying", 0.6)
		task.wait(v2 - 0.25)
		batClient:Destroy()
	end,
	LandingFlyBy = function(data)
		local cFrame = data.Spawn.CFrame
		local position = data.Land.Position
		local batClient = Client.BatClient.new(cFrame)
		batClient:SetMovement("Flying")
		local v2 = batClient:MoveTo(position)
		task.wait(v2 * 0.35)
		batClient:SetMovement("Hover", 0.5)
		task.wait(v2 * 0.65 + 0.1)
		batClient:SetMovement("Idle", 0.5)
		batClient:ShowWarning(2.5)
		task.wait(2.5)
		batClient:Scream(3)
		task.wait(3.5)
		batClient:HideWarning()
		batClient:SetMovement("Hover")
		task.wait(0.1)
		local v3 = batClient:MoveTo(data.Despawn.Position)
		task.wait(0.2)
		batClient:SetMovement("Flying", 1.2)
		task.wait(v3 - 0.25)
		batClient:Destroy()
	end
}

function RunBatSequence(instance)
	local sequenceName = instance:GetAttribute("SequenceName")

	if sequenceName and v[sequenceName] then
		v[sequenceName](instance)
	end
end

Client.Events.RunBatAttack:Connect(function(p)
	RunBatSequence(p)
end)

function BatHandlerClient.Init()
	task.spawn(function()
		local room1Entry = workspace:WaitForChild("Map"):WaitForChild("Caves"):WaitForChild("CaveLevel1"):WaitForChild("Functional"):WaitForChild("BatAttacks"):WaitForChild("Room1Entry")
		RunBatSequence(room1Entry)
	end)
end

return BatHandlerClient