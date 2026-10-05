local Loader = {}
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("Boot"):display():traceback():build()
v.info("loading Loader")
local bindableEvent = Instance.new("BindableEvent")
local flag = false
v.info("loading Promise")
local Promise = require(game.ReplicatedStorage.Modules.Util.Promise)
local RunService = game:GetService("RunService")
local v2 = RunService:IsStudio() and false
v.info("loaded headers")

if v2 then
	v2 = {
		suffix = 0,
		completed = 0
	}
	local RunService2 = game:GetService("RunService")
	v2.suffix = RunService2:IsServer() and "Server" or "Client"
	v2.completed = {}
end

function Loader.OnLoaded()
	if flag then
		return Promise.resolve()
	end

	return Promise.fromEvent(bindableEvent.Event)
end

local function doRequire(moduleScript)
	return require(moduleScript)
end

function Loader.SpawnAll(items, items2)
	for k, item in items do
		for _, item2 in items2 do
			local v4 = item[item2]

			if type(v4) ~= "function" then
				continue
			end

			local v5 = k
			local v6 = item2
			local v7 = v4
			local v8 = item
			task.spawn(function()
				v.info((`calling {v5}.{v6}()`))
				debug.setmemorycategory(v5)
				v7(v8)
				v.info((`completed calling {v5}.{v6}()`))
			end)
			break
		end
	end

	bindableEvent:Fire()
	flag = true
	task.defer(function()
		bindableEvent:Destroy()
	end)

	if v2 then
		table.sort(v2.completed, function(a, b)
			return a.done < b.done
		end)
		warn("Name, TimeCompleted, TimeBalance")
		local total = 0

		for _, v3 in pairs(v2.completed) do
			total += v3.done
			print(v3.name)
			print(v3.done)
			print(total)
			warn("-")
		end

		warn("Done/" .. v2.suffix .. "/" .. total)
		print("\n")
		table.clear(v2.completed)
	end
end

function Loader.LoadChildrenFromLocations(list, callback)
	local result = {}

	for _, v3 in ipairs(list) do
		for _, moduleScript in v3:GetChildren() do
			if not moduleScript:IsA("ModuleScript") then
				continue
			end

			if callback and not callback(moduleScript) then
				v.info((`skipping load for {moduleScript.Name}`))
			else
				local now = tick()
				local now2 = nil
				local thread = nil
				local v4 = moduleScript
				local v5 = coroutine.running()
				thread = task.delay(15, function()
					thread = nil

					if not now2 then
						print(v4.Name, "IS YIELDING. Check for long yields outside of :Start", debug.traceback(v5))

						while not now2 do
							print(v4:GetFullName(), ":", tick() - now)
							task.wait(1)
						end

						print("\n")
					end
				end)
				local v7 = moduleScript
				local success, result2 = pcall(function()
					local extended = v.extend(v7.Name)
					extended.info("starting load")
					local lastTime = tick()
					local module = require(v7)
					local v9

					if typeof(module) == "table" then
						v9 = rawget(module, "WorldCriteria")
					else
						v9 = false
					end

					if v9 then
						local Realm = require(game.ReplicatedStorage.Util.Realm)
						local currentSeaAsync = Realm.getCurrentSeaAsync()

						for i, world in ipairs(v9.Worlds) do
							if currentSeaAsync ~= world then
								continue
							end

							result[v7.Name] = module
							extended.info((`completed load in {math.ceil(1000 * (tick() - lastTime))}ms`))
							return
						end

						if v9.OnFailure then
							result[v7.Name] = v9.OnFailure(module)
						else
							result[v7.Name] = {}
						end

						extended.info((`completed load in {math.ceil(1000 * (tick() - lastTime))}ms`))
					else
						extended.info((`completed load in {math.ceil(1000 * (tick() - lastTime))}ms`))
						result[v7.Name] = module
					end
				end)
				now2 = tick()

				if thread then
					task.cancel(thread)
					thread = nil
				end

				if not success then
					local v9 = moduleScript
					task.spawn(function()
						error("LOADER/CRITICAL [" .. v9.Name .. "] " .. result2)
					end)
				end

				if v2 then
					table.insert(v2.completed, {
						name = moduleScript.Name,
						done = now2 - now
					})
				end
			end
		end
	end

	return result
end

v.info("returning Loader")
return Loader