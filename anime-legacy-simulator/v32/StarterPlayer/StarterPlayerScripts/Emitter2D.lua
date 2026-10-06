local CollectionService = game:GetService("CollectionService")
game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local count = 0
local v = script:IsA("LocalScript") == false
local modulesByName = {}
local connections = {}
local fn

local function fn2(instance, module)
	if module.Module:GetAttribute("Enabled") then
		local v2 = module.EntityList[instance]

		if v2 then
			warn(module.ClassName .. " client entity for [" .. instance:GetFullName() .. "] already exists (" .. v2.ID .. ")")
			return v2
		end

		count += 1
		local v3 = module.new()
		v3.ID = count
		module.EntityList[instance] = v3

		function v3.Deactivate(_)
			fn(instance, module)
		end

		v3.Thread = task.spawn(function()
			module.EntityLoadingCount += 1
			v3.Loading = true
			v3:Initiate(instance)
			v3.Loading = false
			module.EntityLoadingCount -= 1
		end)
	end
end

fn = function(p, state)
	local v2 = state.EntityList[p]

	if v2 then
		state.EntityList[p] = nil
		v2.Destroyed = true

		if coroutine.status(v2.Thread) ~= "dead" then
			task.cancel(v2.Thread)
			v2.Loading = false
			state.EntityLoadingCount -= 1
		end

		v2:Destroy()
	end
end

for _, moduleScript in script:GetDescendants() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module2 = moduleScript
	task.spawn(function()
		local name = module2.Name

		if module2:GetAttribute("Require_UserId") then
			name ..= "_" .. localPlayer.UserId
		end

		local module = require(module2)
		module.Module = module2
		module.ClassName = name
		module.Destroyed = false
		module.EntityList = {}
		module.EntityCount = 0
		module.EntityLoadingCount = 0
		table.insert(connections, CollectionService:GetInstanceAddedSignal(name):Connect(function(p)
			fn2(p, module)
		end))
		table.insert(connections, CollectionService:GetInstanceRemovedSignal(name):Connect(function(p)
			fn(p, module)
		end))

		if module2:GetAttribute("Asynchronous") then
			for k, v3 in CollectionService:GetTagged(name) do
				fn2(v3, module)
			end
		else
			for k, v3 in CollectionService:GetTagged(name) do
				task.spawn(fn2, v3, module)
			end
		end

		table.insert(connections, module2:GetAttributeChangedSignal("Enabled"):Connect(function()
			if module2:GetAttribute("Enabled") then
				for k, v3 in CollectionService:GetTagged(name) do
					task.spawn(fn2, v3, module)
				end
			else
				for k, v3 in CollectionService:GetTagged(name) do
					task.spawn(fn, v3, module)
				end
			end
		end))
		modulesByName[name] = module
	end)
end

if v then
	table.insert(connections, script.Parent.Events.Deactivate.Event:Connect(function()
		for _, connection in connections do
			connection:Disconnect()
		end

		for _, v2 in modulesByName do
			for k in v2.EntityList do
				task.spawn(fn, k, v2)
			end
		end
	end))
end