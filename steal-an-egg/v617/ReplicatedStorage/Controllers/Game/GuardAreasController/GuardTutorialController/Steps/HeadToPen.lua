local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Client.GuardTutorialPresentation)
require(script.Parent.Types.Interface)
local color = Color3.fromRGB(255, 255, 255)
local HeadToPen = {
	StepId = "HeadToPen",
	IsSatisfied = function(object)
		return object:HasReturnedToPen()
	end
}

function HeadToPen.Bind(p, callback)
	local total = 0
	local v = false

	local function refresh()
		if v or not HeadToPen.IsSatisfied(p) then
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
			if not HeadToPen.IsSatisfied(p) then
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

function HeadToPen.Present(object, object2)
	local function refreshPresentation()
		if HeadToPen.IsSatisfied(object2) then
			object:DropEverything()
			return
		end

		local plotSpawnTarget = object2:GetPlotSpawnTarget()
		object:AnnounceTyped("Go to your Pen!", color)

		if plotSpawnTarget == nil then
			object:DropBeam()
		else
			object:RetargetBeam(plotSpawnTarget)
		end
	end

	local changedConnection = object2.Changed:Connect(refreshPresentation)
	refreshPresentation()
	return function()
		changedConnection:Disconnect()
		object:DropEverything()
	end
end

return HeadToPen