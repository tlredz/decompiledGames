local RunService = game:GetService("RunService")
game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local packages = ReplicatedStorage:WaitForChild("Packages")
require(packages.Net)
require(packages.Debounce)
local Synchronizer = require(packages.Synchronizer)
local datas = ReplicatedStorage:WaitForChild("Datas")
local Animals = require(datas.Animals)
local compass = ReplicatedStorage:WaitForChild("Models").ToolsExtras.Compass.Compass
local parent = script.Parent
local handle = parent:WaitForChild("Handle")
local parent2 = parent.Parent.Parent
local v = nil
local renderSteppedConnection = nil
parent.Equipped:Connect(function()
	local v2 = {}
	local plots = workspace.Plots

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	if v then
		v:Destroy()
		v = nil
	end

	for _, model in plots:GetChildren() do
		if not model:IsA("Model") then
			continue
		end

		local name = model.Name
		local v3 = Synchronizer:GetAllChannels()[name]

		if not (v3 and v3.CacheTable) then
			continue
		end

		local cacheTable = v3.CacheTable

		if not ((not cacheTable.Owner or cacheTable.Owner ~= parent2) and cacheTable.AnimalList) then
			continue
		end

		for _, v4 in cacheTable.AnimalList do
			if typeof(v4) == "table" then
				table.insert(v2, {
					Plot = name,
					AnimalIndex = v4.Index
				})
			end
		end
	end

	table.sort(v2, function(a, b)
		return Animals[a.AnimalIndex].Generation > Animals[b.AnimalIndex].Generation
	end)
	local total = 0

	if next(v2) then
		local spawn = plots[v2[1].Plot]:FindFirstChild("Spawn")

		if not spawn then
			return
		end

		local clone = compass:Clone()
		clone.CFrame = CFrame.new()
		clone.Parent = parent.Handle
		v = clone
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			if not (v and (parent2.Character and spawn)) then
				return
			end

			total += dt
			local cframe = CFrame.lookAt(handle.CFrame.Position, spawn.Position)
			local v3 = math.sin(total * 2 * 3.141592653589793 * 1.2) * 0.35
			local v4 = cframe * CFrame.new(0, 0, v3)
			v.CFrame = handle.CFrame:ToObjectSpace(v4)
		end)
	end
end)
parent.Unequipped:Connect(function()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	if v then
		v:Destroy()
		v = nil
	end
end)