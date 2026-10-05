local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local PumpkinCartClient = {}

function TiltCart(instance)
	local pivot = instance:GetPivot()
	local tiltAngle = math.rad((instance:GetAttribute("TiltAngle")))
	Client.TweenModule.new(function(p)
		instance:PivotTo(pivot * CFrame.Angles(0, tiltAngle * p, 0))
	end, 1.2, "Bounce", "Out"):Play()
end

function AddPumpkin(instance, p)
	local parent = p.Parent

	if instance:GetAttribute("Lifted") or parent == nil or parent.Name ~= "Pumpkin" or parent.Parent ~= workspace.Items then
		return
	end

	if parent:GetAttribute("Owner") and parent:GetAttribute("Owner") ~= localPlayer.UserId then
		return
	end

	parent.Parent = game.ReplicatedStorage.TempStorage
	local v = Client.Events.RequestAddPumpkinToCart:InvokeServer(parent, instance)

	if v and v.Success then
		Client.Sound.Play("PumpkinCartPlace", {
			Duplicate = true,
			Replicate = true,
			ReplicationProperties = {
				Position = instance:GetPivot().Position
			}
		})
	else
		task.delay(0.5, function()
			if parent.Parent then
				parent.Parent = workspace.Items
			end
		end)
	end
end

function CartAdded(instance)
	instance:GetAttributeChangedSignal("Lifted"):Connect(function()
		TiltCart(instance)
	end)
	instance:WaitForChild("TouchZone").Touched:Connect(function(otherPart)
		AddPumpkin(instance, otherPart)
	end)
end

function PumpkinCartClient.Init()
	Client.Utility.ForAllTagged("PumpkinCart", CartAdded)
end

return PumpkinCartClient