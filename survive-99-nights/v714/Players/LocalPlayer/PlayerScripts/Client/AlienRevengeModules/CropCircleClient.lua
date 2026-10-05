local CropCircleClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = {}
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { workspace.Items }

function IsAlienCorpse(model, p)
	if not (model and model:IsA("Model") and model.Name == p and model:GetAttribute("Dead")) then
		return false
	end

	if model:GetAttribute("RagdollBody") then
		return model.Parent == workspace.Items
	end

	return false
end

function TrySnap(instance, p)
	if instance:GetAttribute("CropCircleComplete") or v[p] or not IsAlienCorpse(
		p,
		instance:GetAttribute("AlienType") or "Alien"
	) then
		return
	end

	v[p] = true
	Client.Events.RequestCropCircleSnap:InvokeServer(instance, p)
	task.delay(0.5, function()
		v[p] = nil
	end)
end

function SetupCropCircle(instance)
	local touchZone = instance:WaitForChild("TouchZone")
	touchZone.Touched:Connect(function(otherPart)
		TrySnap(instance, otherPart.Parent)
	end)
	task.spawn(function()
		while not instance:GetAttribute("CropCircleComplete") do
			for _, v2 in pairs(workspace:GetPartsInPart(touchZone, overlapParams)) do
				task.spawn(TrySnap, instance, v2.Parent)
			end

			task.wait(0.4)
		end
	end)
end

function CropCircleClient.Init()
	Client.Utility.ForAllTagged("AlienCropCircle", SetupCropCircle)
end

return CropCircleClient