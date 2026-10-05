local v = {
	DracoWings = function(instance)
		if not instance:WaitForChild("UpperTorso", 5) then
			return
		end

		local Wings = require(game.ReplicatedStorage.Util.Wings)
		local v2 = Wings.Attach({
			Root = instance.UpperTorso,
			Size = 1,
			Permanent = true,
			Type = "DracoWings"
		}):Activate()
		return function()
			v2:Destroy(nil, true)
		end
	end
}
local v2 = {}

local function check(instance)
	if not v2[instance] then
		v2[instance] = {
			con = {},
			threads = {},
			active = {}
		}
	end

	for k, v3 in pairs(v) do
		local v4 = "Accessory_" .. k
		local v6 = v3

		local function fn()
			local active = v2[instance].active

			if instance:GetAttribute(v4) and not active[v4] then
				active[v4] = v6(instance)
			elseif not instance:GetAttribute(v4) and active[v4] then
				active[v4]()
				active[v4] = nil
			end
		end

		table.insert(v2[instance].con, instance:GetAttributeChangedSignal(v4):Connect(fn))
		table.insert(v2[instance].threads, task.delay(0.1, function()
			fn()
		end))
	end
end

workspace:WaitForChild("Characters")
workspace.Characters.ChildAdded:Connect(function(child)
	check(child)
end)
workspace.Characters.ChildRemoved:Connect(function(child)
	if v2[child] then
		for _, connection in pairs(v2[child].con) do
			connection:Disconnect()
		end

		for _, thread in pairs(v2[child].threads) do
			local v3 = thread
			pcall(function()
				task.cancel(v3)
			end)
		end

		for _, callback in pairs(v2[child].active) do
			task.spawn(callback)
		end
	end

	v2[child] = nil
end)

for _, child in pairs(workspace.Characters:GetChildren()) do
	local v3 = child
	task.spawn(function()
		check(v3)
	end)
end