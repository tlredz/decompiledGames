local TrinketMachine = {}
local Maid = require(game.ReplicatedStorage.Util.Maid)
local maid = Maid.new()
local RunService = game:GetService("RunService")

if RunService:IsRunning() then
	TrinketMachine.TrinketMachine = workspace:FindFirstChild("Recreation3 Finished V1", true)
else
	local recreation3FinishedV1 = workspace:FindFirstChild("Recreation3 Finished V1", true)

	if recreation3FinishedV1 then
		TrinketMachine.TrinketMachine = recreation3FinishedV1:Clone()
	end
end

maid:GiveTask(task.spawn(function()
	if workspace:GetAttribute("MAP") ~= "Dungeons" then
		return
	end

	repeat
		task.wait()
	until workspace:FindFirstChild("Recreation3 Finished V1", true)

	TrinketMachine.TrinketMachine = workspace:FindFirstChild("Recreation3 Finished V1", true)
	task.defer(function()
		TrinketMachine.TrinketMachine.AncestryChanged:Once(function()
			maid:DoCleaning()
		end)
	end)
	local emitters = {}
	local emitters2 = {}

	for _, emitter in pairs(TrinketMachine.TrinketMachine:WaitForChild("Black", 60):GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			table.insert(emitters, emitter)
		end
	end

	for _, emitter in pairs(TrinketMachine.TrinketMachine:WaitForChild("Neon", 60):GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			table.insert(emitters2, emitter)
		end
	end

	for _, emitter in pairs(TrinketMachine.TrinketMachine:WaitForChild("spinny", 60):GetDescendants()) do
		if emitter:IsA("ParticleEmitter") and emitter.Brightness ~= 1 then
			table.insert(emitters2, emitter)
		end
	end

	local v = 0.001
	local effort = 0
	local flag = true
	local thread = coroutine.wrap(function()
		flag = false

		local function update()
			for _, v2 in pairs(emitters2) do
				v2.Rate = v * 1
				v2.Speed = NumberRange.new(v * 0.5 + 1, v * 1 + 1)
			end

			for _, v2 in pairs(emitters) do
				v2.Rate = v * 2
				v2.Speed = NumberRange.new(v * 1 + 1, v * 2 + 1)
			end
		end

		while task.wait() do
			while effort < v do
				v = math.max(v - 2 * task.wait(), effort)
				update()
			end

			while v < effort do
				v = math.min(v + 2 * task.wait(), effort)
				update()
			end
		end

		flag = true
	end)
	effort = 10

	if flag then
		thread()
	end

	TrinketMachine.TrinketMachine:GetAttributeChangedSignal("Effort"):Connect(function()
		effort = TrinketMachine.TrinketMachine:GetAttribute("Effort") or 0

		if not flag then
			return
		end

		thread()
	end)
end))
return TrinketMachine