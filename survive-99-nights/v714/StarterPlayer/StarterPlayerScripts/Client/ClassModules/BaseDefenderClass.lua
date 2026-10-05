local BaseDefenderClass = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local flag = false
local v = nil
local v2 = nil
local v3 = nil
local v4 = {}

function AttemptUpgradeDefense(instance)
	print("wants to upgrade defense", instance:GetFullName())
	instance:SetAttribute("Upgrading", true)
	HighlightClosestStructure()
	task.delay(2, function()
		instance:SetAttribute("Upgrading", nil)
		HighlightClosestStructure()
	end)
	Client.Events.RequestUpgradeDefense:FireServer(instance)
end

function GetClosestStructure()
	local v5 = nil
	local v6 = 1e999

	if localPlayer.Character == nil then
		return
	end

	local currentlyEquipped = Client.InventoryHandler.GetCurrentlyEquipped()

	if currentlyEquipped and currentlyEquipped.Name == "Hammer" then
		return
	end

	local position = localPlayer.Character:GetPivot().Position

	for k in pairs(v4) do
		if k.Parent ~= workspace.Structures or k:GetAttribute("Upgrading") then
			continue
		end

		local magnitude = (position - k:GetPivot().Position).Magnitude

		if not (magnitude < v6) then
			continue
		end

		v5 = k
		v6 = magnitude
	end

	return v5, v6
end

function HighlightClosestStructure()
	local v5, v6 = GetClosestStructure()
	local v7 = nil

	if v5 and v6 <= 10 then
		v7 = v5
	end

	if v7 ~= v3 then
		if v7 then
			v2.WorldCFrame = v7:GetPivot()
			v.Enabled = true
		else
			v.Enabled = false
		end
	end

	v3 = v7
end

function LoopCheckClosestStructures()
	task.spawn(function()
		while true do
			HighlightClosestStructure()
			task.wait(1)
		end
	end)
end

function CreatePrompt()
	local attachment = Instance.new("Attachment")
	attachment.Parent = workspace.Terrain
	v2 = attachment
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.MaxActivationDistance = 8
	proximityPrompt.ActionText = "Upgrade (3 Scrap)"
	proximityPrompt.HoldDuration = 0.5
	proximityPrompt.Enabled = false
	proximityPrompt.Parent = attachment
	proximityPrompt.RequiresLineOfSight = false
	v = proximityPrompt
	proximityPrompt.Triggered:Connect(function()
		print("upgrade", v3)
		AttemptUpgradeDefense(v3)
	end)
end

function DefenseAdded(instance)
	if instance:GetAttribute("Upgraded") then
		return
	end

	v4[instance] = true
	instance:GetAttributeChangedSignal("Upgraded"):Connect(function()
		v4[instance] = nil
	end)
end

function DefenseRemoved(p)
	v4[p] = nil
end

function LoadDefenses()
	Client.Utility.ForAllTagged("DefenceStructure", DefenseAdded, DefenseRemoved)
end

function EnableClass()
	if flag then
		return
	end

	flag = true
	CreatePrompt()
	LoadDefenses()
	LoopCheckClosestStructures()
end

function BaseDefenderClass.Init()
	local function check()
		if localPlayer:GetAttribute("Class") == "Base Defender" and (localPlayer:GetAttribute("ClassLevel") or 1) >= 2 then
			EnableClass()
		end

		if Client.Utility.HasTalent(localPlayer, "UpgradeDefenses") then
			EnableClass()
		end
	end

	localPlayer:GetAttributeChangedSignal("Class"):Connect(check)
	localPlayer:GetAttributeChangedSignal("ClassLevel"):Connect(check)
	localPlayer:GetAttributeChangedSignal("Talent"):Connect(check)
	check()
end

return BaseDefenderClass