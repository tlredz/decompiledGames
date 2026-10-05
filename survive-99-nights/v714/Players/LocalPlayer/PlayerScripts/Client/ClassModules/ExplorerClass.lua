local ExplorerClass = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local flag = false
local instances = {}
local v = {}
local explorerChestHighlight = nil

function ChestAdded(instance)
	if instance:GetAttribute(localPlayer.UserId .. "Opened") then
		return
	end

	table.insert(instances, instance)
	local connection = nil
	connection = instance:GetAttributeChangedSignal(localPlayer.UserId .. "Opened"):Connect(function()
		if instance:GetAttribute(localPlayer.UserId .. "Opened") then
			ChestRemoved(instance)
			connection:Disconnect()
		end
	end)
end

function ChestRemoved(p)
	local index = table.find(instances, p)

	if index then
		table.remove(instances, index)
	end

	local index2 = table.find(v, p)

	if index2 then
		table.remove(v, index2)
	end
end

function UpdateCloseChests()
	v = {}
	local position = localPlayer.Character and localPlayer.Character:GetPivot().Position

	if position then
		for _, v2 in pairs(instances) do
			if (v2:GetPivot().Position - position).Magnitude < 60 then
				table.insert(v, v2)
			end
		end
	end
end

function GetClosestChest()
	local v2 = nil
	local v3 = 1e999
	local position = localPlayer.Character and localPlayer.Character:GetPivot().Position

	if not position then
		return v2, v3
	end

	for _, v4 in pairs(v) do
		local magnitude = (v4:GetPivot().Position - position).Magnitude

		if not (magnitude < v3) then
			continue
		end

		v2 = v4
		v3 = magnitude
	end

	return v2, v3
end

function HighlightClosestChest(adornee, p)
	if adornee then
		explorerChestHighlight.Adornee = adornee
		explorerChestHighlight.Enabled = true
		local fillTransparency = math.clamp((p + 5) / 30 * 0.5, 0.5, 1)
		explorerChestHighlight.FillTransparency = fillTransparency
	else
		explorerChestHighlight.Adornee = nil
		explorerChestHighlight.Enabled = false
	end
end

function DetectNearbyChests()
	Client.Utility.ForAllTagged("Chest", ChestAdded, ChestRemoved)
	task.spawn(function()
		while true do
			task.wait(2)
			UpdateCloseChests()
		end
	end)
	task.spawn(function()
		while true do
			HighlightClosestChest(GetClosestChest())
			task.wait()
		end
	end)
end

function ChestPromptAdded(p)
	p.HoldDuration = math.min(p.HoldDuration, 4.4)
end

function EnableClass()
	if flag then
		return
	end

	flag = true
	explorerChestHighlight = workspace:WaitForChild("Highlights"):WaitForChild("ExplorerChestHighlight")
	Client.Utility.ForAllTagged("ItemChestPrompt", ChestPromptAdded)
	task.spawn(function()
		DetectNearbyChests()
	end)
end

function ExplorerClass.Init()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function check()
		if localPlayer:GetAttribute("Class") == "Explorer" and (localPlayer:GetAttribute("ClassLevel") or 0) >= 3 then
			EnableClass()
		end
	end

	localPlayer:GetAttributeChangedSignal("Class"):Connect(check)
	localPlayer:GetAttributeChangedSignal("ClassLevel"):Connect(check)
	localPlayer:GetAttributeChangedSignal("Talent"):Connect(check)
	check() -- equivalent call inferred; original call site unknown
end

return ExplorerClass