local v = {}
local Debris = {
	AddItem = function(_, obj, time: number, onDestroy)
		assert(typeof(time) == "number", "ONG BRO??")
		local v2 = {
			Obj = obj,
			Time = time,
			Tick = tick(),
			OnDestroy = onDestroy,
			Traceback = debug.traceback()
		}
		table.insert(v, v2)
	end,
	update = function(self)
		for k, v2 in pairs(v) do
			local obj = v2.Obj

			if tick() - v2.Tick > v2.Time then
				if obj.Parent then
					if v2.OnDestroy then
						v2.OnDestroy(v2.Obj)
					end

					if typeof(obj) == "table" then
						obj:Destroy()
					elseif typeof(obj) == "Instance" then
						obj:Destroy()
					end
				elseif v2.OnDestroy then
					v2.OnDestroy(v2.Obj)
				end

				v[k] = nil
			elseif not obj.Parent then
				if v2.OnDestroy then
					v2.OnDestroy(v2.Obj)
				end

				v[k] = nil
			end
		end
	end
}

function UpdateMain()
	while wait(0.5) do
		local success, result = pcall(function()
			Debris:update()
		end)

		if not success then
			warn("Error in Debris update:", result)
		end
	end
end

coroutine.wrap(function()
	UpdateMain()
end)()
return Debris