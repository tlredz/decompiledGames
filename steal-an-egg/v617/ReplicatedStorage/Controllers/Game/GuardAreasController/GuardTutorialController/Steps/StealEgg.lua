local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Client.GuardTutorialPresentation)
require(script.Parent.Types.Interface)
local color = Color3.fromRGB(255, 255, 255)
local StealEgg = {
	StepId = "StealEgg",
	IsSatisfied = function(object)
		return object:HasStolenFirstEgg() and not object:IsLocalPlayerInGameplay()
	end
}

function StealEgg.Bind(p, callback)
	local total = 0
	local v = false

	local function refresh()
		if v or not StealEgg.IsSatisfied(p) then
			return
		end

		v = true
		callback()
	end

	local changedConnection = p.Changed:Connect(refresh)
	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		total += dt

		if total < 0.1 then
			return
		end

		total = 0

		if not v then
			if not StealEgg.IsSatisfied(p) then
				return
			end

			v = true
			callback()
		end
	end)
	task.defer(refresh)
	return function()
		changedConnection:Disconnect()
		heartbeatConnection:Disconnect()
	end
end

function StealEgg.Present(object, object2)
	local function refreshPresentation()
		if StealEgg.IsSatisfied(object2) then
			object:DropEverything()
		elseif object2:IsCarryingAreaEgg() or object2:HasStolenFirstEgg() then
			object:DropAnnounce()
			object:RetargetBeam(object2:GetGameplayExitTarget())
		else
			local closestAreaEggTarget = object2:GetClosestAreaEggTarget()

			if closestAreaEggTarget == nil then
				object:DropBeam()
				object:AnnounceTyped("Steal an Egg!", color)
			else
				object:AnnounceTyped("Steal an Egg!", color)
				object:RetargetBeam(closestAreaEggTarget)
			end
		end
	end

	local function refreshMovingExitTarget()
		if StealEgg.IsSatisfied(object2) then
			object:DropEverything()
		elseif object2:IsCarryingAreaEgg() or object2:HasStolenFirstEgg() then
			object:DropAnnounce()
			object:RetargetBeam(object2:GetGameplayExitTarget())
		end
	end

	local changedConnection = object2.Changed:Connect(refreshPresentation)
	local total = 0
	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		total += dt

		if total < 0.1 then
			return
		end

		total = 0
		refreshMovingExitTarget()
	end)
	refreshPresentation()
	return function()
		changedConnection:Disconnect()
		heartbeatConnection:Disconnect()
		object:DropEverything()
	end
end

return StealEgg