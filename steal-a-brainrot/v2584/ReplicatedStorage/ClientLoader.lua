if workspace.StreamingEnabled then
	if not workspace:FindFirstChild("Map") then
		workspace.PersistentLoaded:Wait()
		print("[STREAMING ENABLED BUILD]: PersistentModels loaded")
	end

	workspace:WaitForChild("Map")
	workspace:WaitForChild("Plots")
else
	print("[STREAMING DISABLED BUILD]: Client starting")
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("StarterGui")
game:GetService("RunService")
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local Players = game:GetService("Players")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local v = {}
local count = 0
local count2 = 0

for _, child in ReplicatedStorage:WaitForChild("ReplicatedGui"):GetChildren() do
	child.Parent = playerGui
end

task.spawn(require, ReplicatedStorage.Packages.PlayerMouse)
task.spawn(require, script.UIStrokeAdjuster)
task.spawn(require, ReplicatedStorage.Packages.FFlags)
task.spawn(require, ReplicatedStorage.Packages.Net)
task.spawn(require, ReplicatedStorage.Packages.Debounce)

for _, moduleScript in controllers:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local v2 = false
	local v3 = moduleScript
	task.delay(10, function()
		if not v2 then
			print((`Module {v3:GetFullName()} is taking too long to Require`))
		end
	end)
	local v4 = nil
	local v5 = nil
	local v6 = moduleScript
	task.spawn(function()
		debug.setmemorycategory(v6.Name)
		v4, v5 = xpcall(require, warn, v6)
	end)

	while v4 == nil do
		task.wait()
	end

	v2 = true

	if not v4 then
		continue
	end

	v[moduleScript.Name] = v5
	count += 1
end

for k, v2 in v do
	local v3 = k
	local v4 = v2
	task.spawn(function()
		debug.setmemorycategory(v3)
		local v5 = false
		task.delay(10, function()
			if not v5 then
				print((`Module {v3} is taking too long to Load`))
			end
		end)

		if v4.Load then
			v4:Load()
		end

		v5 = true
		count2 += 1
	end)
end

while count ~= count2 do
	task.wait()
end

for k, v2 in v do
	local v3 = k
	local v4 = v2
	task.spawn(function()
		debug.setmemorycategory(v3)

		if v4.Start then
			v4:Start()
		end
	end)
end

for _, moduleScript in ReplicatedStorage:WaitForChild("Components"):GetChildren() do
	if moduleScript:IsA("ModuleScript") then
		xpcall(require, warn, moduleScript)
	end
end

for _, script2 in ReplicatedStorage:WaitForChild("ClientToolScripts"):GetChildren() do
	if script2:IsA("Script") then
		script2.Enabled = true
	end
end

local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
ReplicatorClient.init()