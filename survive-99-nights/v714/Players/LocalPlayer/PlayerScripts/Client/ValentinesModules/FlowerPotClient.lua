local FlowerPotClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)

function AddFlowerToPot(instance, p)
	p.Parent = nil
	instance:SetAttribute("HasFlower", true)
	local v = Client.Events.RequestAddFlowerToPot:InvokeServer(instance, p)

	if not (v and v.Success) then
		task.delay(1, function()
			instance:SetAttribute("HasFlower", nil)
			p.Parent = workspace.Items
		end)
	end
end

function FlowerPotAdded(instance)
	if instance.Parent ~= workspace.Structures then
		return
	end

	instance:WaitForChild("TouchZone").Touched:Connect(function(otherPart)
		if instance.Parent == nil or instance:GetAttribute("HasFlower") then
			return
		end

		local parent = otherPart.Parent

		if parent:HasTag("ValentinesFlower") then
			AddFlowerToPot(instance, parent)
		end
	end)
end

function FlowerPotClient.Init()
	Client.Utility.ForAllTagged("FlowerPot", FlowerPotAdded)
end

return FlowerPotClient