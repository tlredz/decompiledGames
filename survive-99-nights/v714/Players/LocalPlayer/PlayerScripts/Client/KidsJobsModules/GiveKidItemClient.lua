local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = {}

function KidJobsEnabled(p)
	return p == "DinoKid" or game.ReplicatedStorage.Configs:GetAttribute("OtherKidsHaveJobs") == true
end

function IsKidsOwnTrinket(instance, p)
	local pingName = instance:GetAttribute("PingName")

	if pingName == nil then
		return false
	end

	local v2 = pingName .. "'s "
	return string.sub(p.Name, 1, #v2) == v2
end

function KidCanReceive(instance, p)
	if instance:GetAttribute("Friending") then
		return true
	end

	if instance:GetAttribute("Rescued") and KidJobsEnabled(instance:GetAttribute("KidId")) then
		return IsKidsOwnTrinket(instance, p)
	end

	return false
end

function LostChildAdded(instance)
	local giveItemAttachment = instance:WaitForChild("HumanoidRootPart"):WaitForChild("GiveItemAttachment", 10)
	local giveItemPrompt = giveItemAttachment and giveItemAttachment:WaitForChild("GiveItemPrompt", 5)

	if giveItemPrompt == nil then
		warn("No GiveItemPrompt on kid", instance:GetAttribute("KidId"))
		return
	end

	local v2 = {
		Prompt = giveItemPrompt,
		Connections = {}
	}
	table.insert(v2.Connections, giveItemPrompt.Triggered:Connect(function()
		local v3 = GetHeldItem()

		if v3 and KidCanReceive(instance, v3) then
			AttemptGiveKidItem(instance, v3)
		end
	end))

	for _, v3 in pairs({
		"Friending",
		"Rescued",
		"Hunger",
		"NeedsFire",
		"NeedsBandage",
		"NeedsCake",
		"NeedsSleep"
	}) do
		table.insert(v2.Connections, instance:GetAttributeChangedSignal(v3):Connect(CheckHeldItem))
	end

	v[instance] = v2
	CheckHeldItem()
end

function AttemptGiveKidItem(instance, p)
	if instance:GetAttribute("HoldingItem") then
		return
	end

	if (workspace:GetAttribute("CultistsAtFire") or 0) > 0 then
		Client.PopUpUI.AddPopUp("You can't do this while there are cultists around", "warning")
		return
	end

	local parent = p.Parent

	if parent ~= workspace.Items and parent ~= localPlayer.Inventory or not CanGiveItem(p) then
		return
	end

	p.Parent = game.ReplicatedStorage.TempStorage
	local v2 = Client.Events.AttemptGiveKidItem:InvokeServer(instance, p)

	if not (v2 and v2.Success) then
		task.delay(0.5, function()
			p.Parent = parent
		end)
	end
end

function LostChildRemoved(p)
	if v[p] then
		for _, connection in pairs(v[p].Connections) do
			connection:Disconnect()
		end

		v[p] = nil
	end
end

function CanGiveItem(p)
	return Client.Utility.CanGiveItemToChild(localPlayer, p)
end

function GetHeldItem()
	local draggingItem = Client.InteractionHandler.GetDraggingItem()

	if draggingItem and CanGiveItem(draggingItem) then
		return draggingItem
	end

	local currentlyEquipped = Client.InventoryHandler.GetCurrentlyEquipped()

	if currentlyEquipped and CanGiveItem(currentlyEquipped) then
		return currentlyEquipped
	end
end

function TrinketShortName(instance, p)
	local pingName = instance:GetAttribute("PingName")
	local v2 = pingName and pingName .. "'s "

	if v2 and string.sub(p.Name, 1, #v2) == v2 then
		return (string.sub(p.Name, #v2 + 1))
	end

	return p.Name
end

function CheckHeldItem()
	local v2 = GetHeldItem()

	for k, v3 in pairs(v) do
		local enabled

		if v2 == nil then
			enabled = false
		else
			enabled = KidCanReceive(k, v2)
		end

		if enabled then
			if k:GetAttribute("Friending") then
				v3.Prompt.ActionText = "Give " .. v2.Name
			else
				v3.Prompt.ActionText = "Befriend with " .. TrinketShortName(k, v2)
			end
		end

		v3.Prompt.Enabled = enabled
		local proximityAttachment = k.PrimaryPart and k.PrimaryPart:FindFirstChild("ProximityAttachment")
		local proximityInteraction = proximityAttachment and proximityAttachment:FindFirstChild("ProximityInteraction")

		if proximityInteraction then
			proximityInteraction.Enabled = not (enabled or Client.KidClueClient.CluePromptBlocked(k))
		end
	end
end

local GiveKidItemClient = {
	CheckHeldItem = CheckHeldItem
}

function ConnectItemChanged()
	Client.Events.StartDraggingItem:Connect(CheckHeldItem)
	Client.Events.ItemDraggingEnded:Connect(CheckHeldItem)
	Client.Events.EquippedItemChanged:Connect(CheckHeldItem)
	CheckHeldItem()
end

function GiveKidItemClient.Init()
	Client.Utility.ForAllTagged("ChildNPC", LostChildAdded, LostChildRemoved)
	game.ReplicatedStorage.Configs:GetAttributeChangedSignal("OtherKidsHaveJobs"):Connect(CheckHeldItem)
	ConnectItemChanged()
end

return GiveKidItemClient