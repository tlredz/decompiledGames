local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.packages.Observers)
local FlyingDutchmanFerry = require(ReplicatedStorage.shared.modules.FlyingDutchmanFerry)
local v = {}
local v2 = {}
local FlyingDutchmanFerryController = {
	GetShipCFrame = function(_, instance)
		return v[instance] or instance:GetPivot()
	end,
	IsTracked = function(_, p)
		return v[p] ~= nil
	end,
	OnStep = function(_, callback)
		v2[callback] = true
		return function()
			v2[callback] = nil
		end
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function track(instance)
	v[instance] = instance:GetPivot()
	return function()
		v[instance] = nil
	end
end

local function step()
	local serverTimeNow = workspace:GetServerTimeNow()

	for k in v do
		if k.Parent then
			local shipCFrame, v3 = FlyingDutchmanFerry.GetShipCFrame(k, serverTimeNow)

			if shipCFrame then
				k:PivotTo(shipCFrame)
				v[k] = shipCFrame
			else
				v[k] = k:GetPivot()
			end

			for k2 in v2 do
				k2(k, v[k], v3, serverTimeNow)
			end
		else
			v[k] = nil
		end
	end
end

function FlyingDutchmanFerryController.Start(_)
	if not FlyingDutchmanFerry.Enabled then
		return
	end

	Observers.observeTag(FlyingDutchmanFerry.SHIP_TAG, function(model)
		if model:IsA("Model") and model:IsDescendantOf(workspace) then
			return track(model)
		else
			return nil
		end
	end)
	task.spawn(function()
		local v3 = os.clock() + 60

		while os.clock() < v3 do
			local demoShip = FlyingDutchmanFerry.FindDemoShip()

			if demoShip then
				if v[demoShip] then
					break
				end

				local v4 = track(demoShip) -- equivalent call inferred; original call site unknown
				demoShip.Destroying:Once(v4)
				break
			else
				task.wait(1)
			end
		end
	end)
	RunService.PreSimulation:Connect(step)
end

return FlyingDutchmanFerryController