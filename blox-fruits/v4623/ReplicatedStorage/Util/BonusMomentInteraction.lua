local RunService = game:GetService("RunService")
local AttributeCounter = require(game.ReplicatedStorage.Util.AttributeCounter)
local IsTransformed = require(game.ReplicatedStorage.Util.IsTransformed)
local v = {}
local v2 = 0

function v.isTransformed(p)
	if p then
		return AttributeCounter.active(p, "FULL_TRANSFORMATION") or AttributeCounter.active(p, "SPECIAL_TRANSFORMATION") or IsTransformed(
			p,
			true,
			true
		)
	end

	return true
end

function v.acquireBusy(instance)
	if v.isTransformed(instance) then
		return nil, "Transformed"
	end

	local busy = instance:FindFirstChild("Busy")

	if not busy or not busy:IsA("BoolValue") or busy.Value then
		return nil, "Busy"
	end

	local destroyable = AttributeCounter.destroyable(instance, "BONUS_MOMENT_BUSY")
	local destroyingConnection = nil
	local v3 = {
		destroyed = false,
		Destroy = function(self)
			if self.destroyed then
				return
			end

			self.destroyed = true

			if destroyingConnection then
				destroyingConnection:Disconnect()
				destroyingConnection = nil
			end

			destroyable:Destroy()

			if busy.Parent == instance and not AttributeCounter.active(instance, "BONUS_MOMENT_BUSY") then
				busy.Value = false
			end
		end
	}
	busy.Value = true
	destroyingConnection = instance.Destroying:Once(function()
		v3:Destroy()
	end)
	return v3, nil
end

function v.getLiveCharacter(player)
	local character = player.Character

	if not (character and character:IsDescendantOf(workspace)) then
		return nil, nil, nil
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoid and not (humanoid.Health <= 0) then
		return character, humanoidRootPart, humanoid
	end

	return character, nil, humanoid
end

function v.getContainers(player)
	local v3 = {}
	local backpack = player:FindFirstChildOfClass("Backpack")

	if backpack then
		table.insert(v3, backpack)
	end

	if player.Character then
		table.insert(v3, player.Character)
	end

	return v3
end

function v.isOwnedItem(player, p)
	local parent = p.Parent
	return parent ~= nil and (parent == player.Character or parent == player:FindFirstChildOfClass("Backpack"))
end

function v.getTransformedReason()
	return "Transformed"
end

function v.isTransformedReason(p)
	return p == "Transformed"
end

function v.notifyTransformed()
	if not RunService:IsClient() then
		return
	end

	local now = os.clock()

	if now - v2 < 1 then
		return
	end

	v2 = now
	local Notification = require(game.ReplicatedStorage.Notification)
	Notification.new("<Color=Red>You cannot do that while transformed.<Color=/>"):Display()
end

return table.freeze(v)