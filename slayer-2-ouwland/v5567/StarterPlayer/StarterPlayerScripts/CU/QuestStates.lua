local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local questStates = ReplicatedStorage:WaitForChild("QuestStates")
local cleanit = require(ReplicatedStorage.Packages.cleanit)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local localPlayer = Players.LocalPlayer
local v = {}

local function getState(name: string)
	local v2 = v[name]

	if v2 ~= nil then
		return v2
	end

	local moduleScript = questStates:FindFirstChild(name)

	if moduleScript == nil or not moduleScript:IsA("ModuleScript") then
		return nil
	end

	local success, result = pcall(require, moduleScript)

	if success and typeof(result) == "table" then
		v[name] = result
		return result
	end

	warn(`[QuestStates] Failed to load state module '{name}':`, result)
	return nil
end

local v2 = {}

local function asFunction(callback)
	if typeof(callback) == "function" then
		return callback
	end

	return nil
end

local function callDo(callback, p, p2)
	if typeof(callback) ~= "function" then
		callback = nil
	end

	if callback == nil then
		return
	end

	task.spawn(function()
		local success, result = pcall(callback, localPlayer, p, p2)

		if not success then
			warn(`[QuestStates] Do error ({p.Name}):`, result)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopTask(p, p2)
	local task2 = p.tasks[p2]

	if task2 == nil then
		return
	end

	p.tasks[p2] = nil
	task.spawn(function()
		if task2.stop ~= nil then
			local success, result = pcall(task2.stop, localPlayer, p2, task2.clean)

			if not success then
				warn(`[QuestStates] task Stop error ({p2.Name}):`, result)
			end
		end

		task2.clean:Destroy()
	end)
end

local function questAdded(instance)
	local state = getState(instance.Name)

	if not (state ~= nil and v2[instance] == nil) then
		return
	end

	local tasks = instance:WaitForChild("Tasks", 5)

	if tasks == nil or instance.Parent == nil or v2[instance] ~= nil then
		return
	end

	local v3 = {
		clean = cleanit.new(),
		questStop = 0,
		tasks = 0,
		watch = 0
	}
	local stop = state.Stop

	if typeof(stop) ~= "function" then
		stop = nil
	end

	v3.questStop = stop
	v3.tasks = {}
	v3.watch = cleanit.new()
	v2[instance] = v3
	local v4 = state.Do
	local clean = v3.clean

	if typeof(v4) ~= "function" then
		v4 = nil
	end

	if v4 ~= nil then
		task.spawn(function()
			local success, result = pcall(v4, localPlayer, instance, clean)

			if not success then
				warn(`[QuestStates] Do error ({instance.Name}):`, result)
			end
		end)
	end

	local tasks2 = state.Tasks

	if typeof(tasks2) == "table" then
		for _, child in ipairs(tasks:GetChildren()) do
			local task2 = tasks2[child.Name]

			if typeof(task2) ~= "table" then
				continue
			end

			local value = child:FindFirstChild("Value")
			local max = child:FindFirstChild("Max")

			if not (value ~= nil and max ~= nil) then
				continue
			end

			local v5 = child
			local v6 = value
			local v7 = max
			local v8 = task2

			local function activate()
				if v2[instance] ~= v3 or v3.tasks[v5] ~= nil or v6.Value >= v7.Value or not Quests.TaskNeedMet(v5) then
					return
				end

				local v9 = {
					clean = cleanit.new(),
					stop = 0
				}
				local stop2 = v8.Stop

				if typeof(stop2) ~= "function" then
					stop2 = nil
				end

				v9.stop = stop2
				v3.tasks[v5] = v9
				local v10 = v8.Do
				local v11 = v5
				local clean2 = v9.clean

				if typeof(v10) ~= "function" then
					v10 = nil
				end

				if v10 == nil then
					return
				end

				task.spawn(function()
					local success, result = pcall(v10, localPlayer, v11, clean2)

					if not success then
						warn(`[QuestStates] Do error ({v11.Name}):`, result)
					end
				end)
			end

			activate()
			local v9 = value
			local v10 = max
			local v11 = child
			local activate2 = activate
			v3.watch:Connect(value.Changed, function()
				if v9.Value >= v10.Value then
					stopTask(v3, v11) -- equivalent call inferred; original call site unknown
				elseif v3.tasks[v11] == nil then
					task.defer(activate2)
				end
			end)
			local need = child:FindFirstChild("Need")
			local child2

			if not (need == nil or need.Value == "") then
				child2 = tasks:FindFirstChild(need.Value) or nil
			end

			local value2

			if child2 ~= nil then
				value2 = child2:FindFirstChild("Value") or nil
			end

			if value2 == nil then
				continue
			end

			local activate3 = activate
			v3.watch:Connect(value2.Changed, function()
				task.defer(activate3)
			end)
		end
	end
end

local function questRemoved(p)
	local v3 = v2[p]

	if v3 == nil then
		return
	end

	v2[p] = nil
	v3.watch:Destroy()

	for k in pairs(v3.tasks) do
		stopTask(v3, k) -- equivalent call inferred; original call site unknown
	end

	task.spawn(function()
		if v3.questStop ~= nil then
			local success, result = pcall(v3.questStop, localPlayer, p, v3.clean)

			if not success then
				warn(`[QuestStates] quest Stop error ({p.Name}):`, result)
			end
		end

		v3.clean:Destroy()
	end)
end

local holder = Utility.GetData(localPlayer, true):WaitForChild("Quests"):WaitForChild("Holder")

for _, child in ipairs(holder:GetChildren()) do
	task.spawn(questAdded, child)
end

holder.ChildAdded:Connect(questAdded)
holder.ChildRemoved:Connect(questRemoved)