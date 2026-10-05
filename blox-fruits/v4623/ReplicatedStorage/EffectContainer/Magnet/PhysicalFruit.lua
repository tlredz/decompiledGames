local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local object = setmetatable({}, {
	__mode = "k"
})

local function setEmitters(folder, enabled: boolean)
	if not folder then
		return
	end

	for _, emitter in ipairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end
end

return function(p)
	local fruit = p.Fruit

	if not fruit or (workspace.CurrentCamera.CFrame.Position - fruit:GetPivot().Position).Magnitude > 800 then
		return
	end

	local v = object[fruit]

	if v then
		v()
	end

	local boostAura1 = fruit:FindFirstChild("BoostAura1")
	local boostAura2 = fruit:FindFirstChild("BoostAura2")
	local exhaustVFX = fruit:FindFirstChild("ExhaustVFX")
	local magnetAura = fruit:FindFirstChild("MagnetAura")

	local function setSmoke(enabled: boolean)
		if not exhaustVFX then
			return
		end

		for _, emitter in ipairs(exhaustVFX:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") and emitter.Name == "Smoke" then
				emitter.Enabled = enabled
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function enableVFX()
		setEmitters(boostAura1, true)
		setEmitters(boostAura2, true)
		setEmitters(exhaustVFX, true)
		setEmitters(magnetAura, false)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function disableVFX()
		setEmitters(boostAura1, false)
		setEmitters(boostAura2, false)
		setEmitters(exhaustVFX, false)
		setEmitters(magnetAura, true)
	end

	Util.Anims:Preload("MagnetFruitToolAnimLoop")
	local magnetFruitToolAnimLoop = Util.Anims:Get(fruit, "MagnetFruitToolAnimLoop")
	magnetFruitToolAnimLoop.Looped = true
	magnetFruitToolAnimLoop:Play()
	local v2 = true
	local flag = false
	local connections = {}
	local cleanup

	cleanup = function()
		if flag then
			return
		end

		flag = true
		v2 = false

		if object[fruit] == cleanup then
			object[fruit] = nil
		end

		for _, connection in ipairs(connections) do
			local connection2 = connection
			pcall(function()
				connection2:Disconnect()
			end)
		end

		table.clear(connections)
		pcall(function()
			magnetFruitToolAnimLoop:Stop()
		end)
		disableVFX() -- equivalent call inferred; original call site unknown
	end

	object[fruit] = cleanup
	table.insert(connections, fruit.AncestryChanged:Connect(function()
		if v2 and not fruit:IsDescendantOf(workspace) then
			cleanup()
		end
	end))
	table.insert(connections, fruit.Destroying:Connect(function()
		cleanup()
	end))
	disableVFX() -- equivalent call inferred; original call site unknown

	local function crossed(p2: number, p3: number, p4: number)
		if not (p3 <= p4) then
			return p3 < p2 or p2 <= p4
		end

		return p3 < p2 and p2 <= p4
	end

	local timePosition = magnetFruitToolAnimLoop.TimePosition
	table.insert(connections, RunService.RenderStepped:Connect(function()
		if not v2 then
			return
		end

		if not fruit:IsDescendantOf(workspace) then
			cleanup()
			return
		end

		local timePosition2 = magnetFruitToolAnimLoop.TimePosition
		local v3 = timePosition
		local v4

		if v3 <= timePosition2 then
			if v3 < 3.066666666666667 then
				v4 = timePosition2 >= 3.066666666666667
			else
				v4 = false
			end
		else
			v4 = v3 < 3.066666666666667 or timePosition2 >= 3.066666666666667
		end

		if v4 then
			setSmoke(true)
		end

		local v5 = timePosition
		local v6

		if v5 <= timePosition2 then
			if v5 < 4.566666666666666 then
				v6 = timePosition2 >= 4.566666666666666
			else
				v6 = false
			end
		else
			v6 = v5 < 4.566666666666666 or timePosition2 >= 4.566666666666666
		end

		if v6 then
			enableVFX() -- equivalent call inferred; original call site unknown
		end

		local v7 = timePosition
		local v8

		if v7 <= timePosition2 then
			if v7 < 5.166666666666667 then
				v8 = timePosition2 >= 5.166666666666667
			else
				v8 = false
			end
		else
			v8 = v7 < 5.166666666666667 or timePosition2 >= 5.166666666666667
		end

		if v8 then
			disableVFX() -- equivalent call inferred; original call site unknown
		end

		timePosition = timePosition2
	end))
end