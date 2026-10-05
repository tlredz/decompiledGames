local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "AutoSeat"
})
local v2 = false
local core = {}

function v:Construct()
	self.trove = Trove.new()
end

function v.Start(p)
	p.trove:Add(p.Instance.Touched:Connect(function(otherPart)
		if not p.Instance.Occupant and otherPart.Parent == localPlayer.Character then
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if not v2 and humanoid and not humanoid.Sit and not humanoid.PlatformStand and p.Instance.Parent and p.Instance.Parent:GetAttribute("OwnerUserId") and not (table.find(
				core,
				p.Instance.Parent:GetAttribute("OwnerUserId")
			) or localPlayer:GetAttribute("TeleportInProgress")) then
				v2 = true
				task.delay(15, function()
					v2 = false
				end)

				if localPlayer:GetAttribute("Fishing") then
					return
				end

				if localPlayer.Character and localPlayer.Character:GetAttribute("PlayingArcade") ~= nil then
					return
				else
					p.Instance:Sit(humanoid)
				end
			end
		end
	end))
end

function v.Stop(p)
	p.trove:Clean()
end

local function updateBlocklist()
	if localPlayer.UserId < 0 then
		return
	end

	core = StarterGui:GetCore("GetBlockedUserIds")
end

task.spawn(function()
	if localPlayer.UserId < 0 then
		return
	end

	local v3 = false

	while true do
		v3 = v3 or pcall(updateBlocklist)

		if v3 then
			break
		end

		task.wait(1)
	end

	Players.PlayerAdded:Connect(updateBlocklist)

	for _, v4 in { "PlayerBlockedEvent", "PlayerUnblockedEvent" } do
		local core2 = nil

		while not core2 do
			local v5 = v4
			pcall(function()
				core2 = StarterGui:GetCore(v5)
			end)

			if core2 then
				break
			else
				task.wait(1)
			end
		end

		core2.Event:Connect(updateBlocklist)
	end
end)
return v