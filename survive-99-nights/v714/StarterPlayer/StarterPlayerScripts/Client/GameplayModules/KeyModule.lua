local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Random.new()

function KeyAdded(instance)
	instance:WaitForChild("Handle")

	if instance.PrimaryPart and instance:IsDescendantOf(workspace) then
		local primaryPart = instance.PrimaryPart
		Client.Sound.Play("KeyDrop", {
			Instance = primaryPart
		})
		primaryPart.Touched:Connect(function(otherPart)
			if otherPart.Name == "KeyInteraction" and otherPart.Parent:GetAttribute("LockNumber") == instance:GetAttribute("UnlocksDoor") then
				instance.Parent = game.ReplicatedStorage.TempStorage
				local v = Client.Events.KeyUsed:InvokeServer(instance, otherPart.Parent)

				if v and v.Success then
					instance:Destroy()
				else
					print("failed")
					task.delay(1, function()
						instance:PivotTo(otherPart.CFrame * CFrame.new(-16, 0, 0) + createVector(0, 6, 0))
						instance.Parent = workspace.Items
					end)
				end
			end
		end)
	end
end

Client.Utility.ForAllTagged("KeyModel", KeyAdded)
return {}