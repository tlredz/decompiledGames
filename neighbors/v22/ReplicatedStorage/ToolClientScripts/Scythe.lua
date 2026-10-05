local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Tool)
local Janitor = require(ReplicatedStorage.Modules.Janitor)
local Scythe = {}

function Scythe.Initialize(player)
	player._janitor = Janitor.new()
	player._janitor:LinkToInstance(player.Tool)
	print("client initliazed")
	player._janitor:Add(player.Tool.Equipped:Connect(function()
		local v = player:PlayAnimation("Idle")
		print("Playing Idle")

		if v then
			v.Looped = true
		end
	end))
	player._janitor:Add(player.Tool.Unequipped:Connect(function()
		player:StopAnimation("Idle")
		player:StopAnimation("Run")
	end))
	player._janitor:Add(player.Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		if player.Tool.Parent ~= player.Character then
			return
		end

		if player.Humanoid.MoveDirection.Magnitude > 0.1 then
			player:StopAnimation("Idle")
			local v = player:PlayAnimation("Run")

			if v then
				v.Looped = true
			end
		else
			player:StopAnimation("Run")
			local v = player:PlayAnimation("Idle")

			if v then
				v.Looped = true
			end
		end
	end))
	local v = player.Tool.Parent == player.Character and player:PlayAnimation("Idle")

	if v then
		v.Looped = true
	end
end

function Scythe.Activated(object)
	if object.Player:GetAttribute("Safezone") or object.Player:GetAttribute("Protected") then
		return
	end

	object:StopAnimation("Run")
	object:StopAnimation("Idle")
end

return Scythe