local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

if RunService:IsServer() then
	return {
		apply = function(instance, p: string)
			local formatted = `Gradients_{p}`
			instance:AddTag(formatted)
			return function()
				instance:RemoveTag(formatted)
			end
		end,
		hasEffect = function(_: string)
			return false
		end
	}
end

local Observers = require(ReplicatedStorage.Packages.Observers)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local modulesByName = {}
local v = {}
local names = {}

for _, moduleScript in script.Effects:GetChildren() do
	local name = moduleScript.Name
	local module = require(moduleScript)
	modulesByName[name] = module
	v[moduleScript.Name] = {}
	table.insert(names, moduleScript.Name)
end

local function hasEffect(p: string)
	return modulesByName[p] ~= nil
end

local function apply(instance, value: string)
	assert(typeof(value) == "string", "effect is not a string")
	local v2 = assert(modulesByName[value], "Effect not found").apply(instance, value)
	local enabled = v2.main.Enabled
	v2.main.Enabled = true
	local enabled2

	if v2.stroke then
		enabled2 = v2.stroke.Enabled
	else
		enabled2 = nil
	end

	local v3 = nil
	local enabled3 = nil

	if v2.stroke then
		local parent = v2.stroke.Parent

		if parent and parent:IsA("UIStroke") then
			v3 = parent
			enabled3 = v3.Enabled
			v3.Enabled = true
		end

		v2.stroke.Enabled = true
	end

	local enabled4

	if v2.shine then
		enabled4 = v2.shine.Enabled
	else
		enabled4 = nil
	end

	if v2.shine then
		v2.shine.Enabled = true
	end

	local v4 = {
		enabled = true,
		main = v2.main,
		stroke = v2.stroke,
		shine = v2.shine
	}
	table.insert(v[value], v4)
	local destroyingConnection = nil
	local ancestryChangedConnection = nil

	local function cleanup()
		if destroyingConnection then
			destroyingConnection:Disconnect()
			destroyingConnection = nil
		end

		if ancestryChangedConnection then
			ancestryChangedConnection:Disconnect()
			ancestryChangedConnection = nil
		end

		local index = table.find(v[value], v4)

		if index then
			table.remove(v[value], index)
		end

		if v2 and v2.cleanup then
			v2.main.Enabled = enabled

			if v2.stroke and enabled2 ~= nil then
				v2.stroke.Enabled = enabled2
			end

			if v3 and enabled3 ~= nil then
				v3.Enabled = enabled3
			end

			if v2.shine and enabled4 ~= nil then
				v2.shine.Enabled = enabled4
			end

			v2.cleanup()
			v2 = nil
		end
	end

	local enabledChangedConnection = nil

	local function onAncestryUpdate()
		if enabledChangedConnection then
			enabledChangedConnection:Disconnect()
			enabledChangedConnection = nil
		end

		local layerCollector = instance:FindFirstAncestorWhichIsA("LayerCollector")

		if not layerCollector then
			v4.enabled = true
			return
		end

		v4.enabled = layerCollector.Enabled
		enabledChangedConnection = layerCollector:GetPropertyChangedSignal("Enabled"):Connect(function()
			v4.enabled = layerCollector.Enabled
		end)
	end

	ancestryChangedConnection = instance.AncestryChanged:Connect(onAncestryUpdate)
	onAncestryUpdate()
	destroyingConnection = instance.Destroying:Connect(cleanup)
	return cleanup
end

local v2 = 1
RunService.PreRender:Connect(function(dt)
	local instant = FFlags:GetInstant("Gradients.DistributeLoad", true)
	local instant2 = FFlags:GetInstant("Gradients.DistributeLoadBudget", 0.001)
	debug.profilebegin("Gradients:Simulate")
	local v3 = 1
	local v4 = not instant and 1e999 or instant2

	while v3 < #names and v4 > 0 do
		local v5 = names[v2]
		v3 += 1
		v2 += 1

		if v2 > #names then
			v2 = 1
		end

		local v6 = v[v5]

		if #v6 == 0 then
			continue
		end

		debug.profilebegin(v5)
		debug.profilebegin("Simulate")
		local lastTime = os.clock()
		local simulate = modulesByName[v5].simulate(dt)
		debug.profileend()
		debug.profilebegin("Apply")

		for _, v7 in v6 do
			if not v7.enabled then
				continue
			end

			if simulate.main then
				v7.main.Color = simulate.main
			end

			if simulate.mainTransparency then
				v7.main.Transparency = simulate.mainTransparency
			end

			if simulate.mainRotation ~= nil then
				v7.main.Rotation = simulate.mainRotation
			end

			if simulate.perLabel then
				simulate.perLabel(v7.main)
			end

			if v7.shine then
				if simulate.shine then
					v7.shine.Color = simulate.shine
				end

				if simulate.shineTransparency then
					v7.shine.Transparency = simulate.shineTransparency
				end

				if simulate.shineOffset then
					v7.shine.Offset = simulate.shineOffset
				end
			end

			if not (v7.stroke and simulate.stroke) then
				continue
			end

			v7.stroke.Color = simulate.stroke

			if simulate.strokeTransparency then
				v7.stroke.Transparency = simulate.strokeTransparency
			end
		end

		v4 -= os.clock() - lastTime
		debug.profileend()
		debug.profileend()
	end

	debug.profileend()
end)

for k in v do
	local v3 = k
	Observers.observeTag(`Gradients_{k}`, function(p)
		return (apply(p, v3))
	end)
end

return table.freeze({
	apply = apply,
	hasEffect = hasEffect
})