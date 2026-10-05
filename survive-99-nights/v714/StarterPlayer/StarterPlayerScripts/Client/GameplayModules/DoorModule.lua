local DoorModule = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Random.new()

function DoorModule.ToggleDoor(instance)
	local v = not instance:GetAttribute("DoorOpen")
	local v2 = not instance:GetAttribute("DoorType") and "DoorToggle" or "DoorToggle" .. instance:GetAttribute("DoorType")
	Client.Sound.Play(v2, {
		Volume = 0.35,
		Replicate = true,
		ReplicationProperties = {
			Instance = instance.PrimaryPart,
			Volume = 0.3
		}
	})
	Client.Events.ToggleDoor:FireAllClients(instance, v)
end

Client.Events.ToggleDoor:Connect(function(_, instance, doorOpen)
	if not instance or instance:GetAttribute("DoorLockedClient") then
		return
	end

	instance:SetAttribute("DoorOpen", doorOpen)
	DoorModule.SetDoorState(instance, doorOpen)

	if instance:FindFirstChild("DoorCover") then
		instance.DoorCover:Destroy()
	end

	if instance:GetAttribute("SingleUseDoor") then
		instance:SetAttribute("DoorLockedClient", true)
		instance:RemoveTag("Interaction")

		if instance:GetAttribute("DoorResets") then
			if instance.PrimaryPart:FindFirstChild("ProximityAttachment") then
				instance.PrimaryPart.ProximityAttachment.ProximityInteraction.Enabled = false
			end
		elseif instance.PrimaryPart:FindFirstChild("ProximityAttachment") then
			instance.PrimaryPart.ProximityAttachment:Destroy()
		end
	end
end)

function DoorModule.SetDoorState(instance, p)
	if instance:GetAttribute("DoubleDoor") then
		if p then
			instance.DoorLeft:PivotTo(instance.DoorLeft:GetAttribute("DoorOpenCF"))
			instance.DoorRight:PivotTo(instance.DoorRight:GetAttribute("DoorOpenCF"))
		else
			instance.DoorLeft:PivotTo(instance.DoorLeft:GetAttribute("DoorClosedCF"))
			instance.DoorRight:PivotTo(instance.DoorRight:GetAttribute("DoorClosedCF"))
		end
	elseif p then
		instance:PivotTo(instance:GetAttribute("DoorOpenCF"))
	else
		instance:PivotTo(instance:GetAttribute("DoorClosedCF"))
	end
end

return DoorModule