local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
game:GetService("RunService")

function StrongholdComplete(p)
	task.spawn(function()
		wait(40)

		if p then
			Client.PopUpUI.AddPopUp("the stronghold opens again later")
		end
	end)
	print("are you in fortress?", p)
end

Client.Events.StrongholdComplete:Connect(StrongholdComplete)

function StrongholdOpenGate(instance)
	local originalCF = instance:GetAttribute("OriginalCF")
	Client.TweenModule.new(function(p)
		instance:PivotTo(originalCF + Vector3.new(0, 9 * p, 0))
	end, 2, "Quad"):Play()

	if instance.PrimaryPart:FindFirstChild("GateOpen") then
		instance.PrimaryPart.GateOpen:Play()
	end
end

Client.Events.StrongholdOpenGate:Connect(StrongholdOpenGate)
return {}