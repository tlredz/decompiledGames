local RunService = game:GetService("RunService")

local function createFlashcast(options)
	local v = options or {}
	local v2 = {}
	local eventConnection = nil
	local v3 = {
		worldRoot = v.worldRoot or workspace,
		event = v.event or RunService.PostSimulation,
		getBullets = function(_)
			return v2
		end
	}

	function v3.spawnBullet(_, behavior, vector: Vector3, vector2: Vector3, raycastParams)
		local v4 = {
			behavior = behavior,
			position = vector,
			direction = vector2,
			raycastParams = raycastParams,
			distanceTraveled = 0,
			raycastResults = {},
			desiredFramerate = behavior.desiredFramerate
		}
		v4.lastTick = os.clock() - 1 / v4.desiredFramerate
		v4.data = {}

		function v4:move(position: Vector3)
			local v5 = position - v4.position
			local raycastResult = v3.worldRoot:Raycast(v4.position, v5, v4.raycastParams)

			if raycastResult then
				table.insert(v4.raycastResults, raycastResult)
			end

			v4.position = position
			v4.distanceTraveled += v5.Magnitude
			v4.touched = raycastResult
		end

		function v4:stop()
			local index = table.find(v2, v4)

			if index ~= nil then
				table.remove(v2, index)
			end
		end

		function v4.isStopped(_)
			return table.find(v2, v4) == nil
		end

		table.insert(v2, v4)
		return v4
	end

	function v3:stepBullet(object, p: number)
		task.spawn(function()
			for _, _beforeStepCallback in object.behavior._beforeStepCallbacks do
				_beforeStepCallback(object, p)
			end

			object:move(object.position + object.direction * p)

			for _, _afterStepCallback in object.behavior._afterStepCallbacks do
				_afterStepCallback(object, p)
			end
		end)
	end

	function v3:step()
		for _, v4 in v2 do
			local v5 = os.clock() - v4.lastTick

			if v5 < 1 / v4.desiredFramerate then
				continue
			end

			v4.lastTick = os.clock()
			v3:stepBullet(v4, v5)
		end
	end

	function v3:clear()
		for _, v4 in v2 do
			v4:stop()
		end
	end

	function v3.destroy(_)
		eventConnection:Disconnect()
		v3:clear()
	end

	eventConnection = v3.event:Connect(function()
		v3:step()
	end)
	return v3
end

return {
	new = createFlashcast,
	createBehavior = function()
		local beforeStepCallbacks = {}
		local afterStepCallbacks = {}
		local v3 = {
			_beforeStepCallbacks = beforeStepCallbacks,
			_afterStepCallbacks = afterStepCallbacks,
			desiredFramerate = 1e999
		}

		function v3.setDesiredFramerate(_, desiredFramerate: number)
			v3.desiredFramerate = desiredFramerate
			return v3
		end

		function v3.beforeStep(_, callback)
			table.insert(beforeStepCallbacks, callback)
			return v3
		end

		function v3.afterStep(_, callback)
			table.insert(afterStepCallbacks, callback)
			return v3
		end

		return v3
	end
}