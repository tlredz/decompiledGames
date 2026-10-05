local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Client.GuardTutorialPresentation)
require(script.Parent.Types.Interface)
local SurfaceButtons = require(ReplicatedStorage.Client.UI.SurfaceButtons)
local color = Color3.fromRGB(255, 255, 255)
local ExpandPen = {
	StepId = "ExpandPen"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function shouldPresent(object)
	return object:CanAffordFirstBaseExpansion() and not object:IsLocalPlayerInGameplay()
end

function ExpandPen.IsSatisfied(object)
	return object:HasFinishedFirstBaseExpansion()
end

function ExpandPen.Bind(p, callback)
	local total = 0
	local v = false

	local function refresh()
		if v or not ExpandPen.IsSatisfied(p) then
			return
		end

		v = true
		callback()
	end

	local changedConnection = p.Changed:Connect(refresh)
	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		total += dt

		if total >= 0.1 then
			total = 0

			if not v then
				if not ExpandPen.IsSatisfied(p) then
					return
				end

				v = true
				callback()
			end
		end
	end)
	task.defer(refresh)
	return function()
		changedConnection:Disconnect()
		heartbeatConnection:Disconnect()
	end
end

function ExpandPen.Present(object, object2)
	local total = 0
	local v = false
	local flag = false
	local v2 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clear()
		if not v then
			return
		end

		v = false
		flag = false
		v2 = nil
		object:DropEverything()
	end

	local function refresh()
		if not ExpandPen.IsSatisfied(object2) and shouldPresent(object2) then
			local plotUpgradeSignTarget = object2:GetPlotUpgradeSignTarget()

			if plotUpgradeSignTarget == nil then
				if not v then
					return
				end

				v = false
				flag = false
				v2 = nil
				object:DropEverything()
				return
			elseif v and v2 == plotUpgradeSignTarget then
				if flag then
					return
				end

				local v4 = SurfaceButtons.Find(plotUpgradeSignTarget, "FirstUpgrade")

				if v4 ~= nil then
					object:MarkTapTarget(v4, true)
					flag = true
				end

				return
			else
				v = true
				v2 = plotUpgradeSignTarget
				object:AnnounceTyped("Upgrade your Pen!", color)
				object:PointBeamAt(plotUpgradeSignTarget.Position + createVector(0, -1, 0))
				local v4 = SurfaceButtons.Find(plotUpgradeSignTarget, "FirstUpgrade")

				if v4 ~= nil then
					object:MarkTapTarget(v4, true)
					flag = true
				end

				return
			end
		end

		clear() -- equivalent call inferred; original call site unknown
	end

	local changedConnection = object2.Changed:Connect(refresh)
	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		total += dt

		if total >= 0.1 then
			total = 0
			refresh()
		end
	end)
	refresh()
	return function()
		changedConnection:Disconnect()
		heartbeatConnection:Disconnect()
		clear() -- equivalent call inferred; original call site unknown
	end
end

return ExpandPen