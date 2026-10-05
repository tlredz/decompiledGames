local EggHunterClass = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local flag = false
local v = {}
local v2 = {}
local explorerChestHighlight = nil

function ChestAdded(p)
	table.insert(v, p)
end

function ChestRemoved(p)
	local index = table.find(v, p)

	if index then
		table.remove(v, index)
	end

	local index2 = table.find(v2, p)

	if index2 then
		table.remove(v2, index2)
	end
end

function UpdateCloseChests()
	v2 = {}
	local position = localPlayer.Character and localPlayer.Character:GetPivot().Position

	if position then
		for _, v3 in pairs(v) do
			if (v3:GetPivot().Position - position).Magnitude < 60 then
				table.insert(v2, v3)
			end
		end
	end
end

function GetClosestChest()
	local v3 = nil
	local v4 = 1e999
	local position = localPlayer.Character and localPlayer.Character:GetPivot().Position

	if not position then
		return v3, v4
	end

	for _, v5 in pairs(v2) do
		local magnitude = (v5:GetPivot().Position - position).Magnitude

		if not (magnitude < v4) then
			continue
		end

		v3 = v5
		v4 = magnitude
	end

	return v3, v4
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
	Client.Utility.ForAllTagged("EasterEgg", ChestAdded, ChestRemoved)
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

function EnableClass()
	if flag then
		return
	end

	flag = true
	explorerChestHighlight = workspace:WaitForChild("Highlights"):WaitForChild("ExplorerChestHighlight")
	task.spawn(function()
		DetectNearbyChests()
	end)
end

function EggHunterClass.Init()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function check()
		if localPlayer:GetAttribute("Class") == "Egg Hunter" and (localPlayer:GetAttribute("ClassLevel") or 0) >= 3 then
			EnableClass()
		end
	end

	localPlayer:GetAttributeChangedSignal("Class"):Connect(check)
	localPlayer:GetAttributeChangedSignal("ClassLevel"):Connect(check)
	localPlayer:GetAttributeChangedSignal("Talent"):Connect(check)
	check() -- equivalent call inferred; original call site unknown
end

return EggHunterClass