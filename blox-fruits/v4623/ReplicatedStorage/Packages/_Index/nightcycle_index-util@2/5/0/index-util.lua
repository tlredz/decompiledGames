local Signal = require(script.Parent:WaitForChild("Signal"))
local Option = require(script.Parent:WaitForChild("Option"))
local Future = require(script.Parent:WaitForChild("Future"))

local function log(...) end

local IndexUtil = {}

function IndexUtil.waitForMatch(instance, callback, duration: number?, flag: boolean?)
	local v = true
	local destroyingConnection = nil
	local descendantAddedConnection = nil
	local v2 = Signal.new()
	local thread = nil

	local function fn(flag2: boolean)
		if not v then
			return
		end

		log("cleaning Up waitForMatch")
		v = false
		destroyingConnection:Disconnect()
		descendantAddedConnection:Disconnect()
		v2:Fire()
		v2:Destroy()

		if thread and flag2 == false then
			task.cancel(thread)
		end
	end

	destroyingConnection = instance.Destroying:Connect(function()
		fn(false)
	end)

	if duration then
		thread = task.delay(duration, function()
			fn(true)
		end)
	end

	local v3 = nil
	descendantAddedConnection = instance.DescendantAdded:Connect(function(descendant)
		if v3 then
			return
		end

		local v4 = callback(descendant)

		if v4 then
			log("found match")
			v3 = v4
			v2:Fire()
		end
	end)
	v3 = IndexUtil.findFirstMatch(instance, callback, flag)

	if not v3 then
		v2:Wait()
	end

	fn(false)
	return v3
end

function IndexUtil.matchChildAsync(p, value, object)
	return Future.from(function()
		return Option.try(function()
			if typeof(value) == "string" then
				return IndexUtil.waitForMatch(p, function(p2)
					if p2.Name == value then
						return p2
					end

					return nil
				end, object:unwrapOr(nil), false)
			end

			return IndexUtil.waitForMatch(p, value, object:unwrapOr(nil), false)
		end)
	end)
end

function IndexUtil.matchDescendantAsync(p, value, object)
	return Future.from(function()
		return Option.try(function()
			if typeof(value) == "string" then
				return IndexUtil.waitForMatch(p, function(p2)
					if p2.Name == value then
						return p2
					end

					return nil
				end, object:unwrapOr(nil), true)
			end

			return IndexUtil.waitForMatch(p, value, object:unwrapOr(nil), true)
		end)
	end)
end

function IndexUtil.findFirstMatch(folder, callback, flag: boolean?)
	if flag then
		for _, descendant in ipairs(folder:GetDescendants()) do
			local v = callback(descendant)

			if v then
				return v
			end
		end
	else
		for _, child in ipairs(folder:GetChildren()) do
			local v = callback(child)

			if v then
				return v
			end
		end
	end

	return nil
end

function IndexUtil.matchChild(p, value)
	return Option.try(function()
		if typeof(value) == "string" then
			return IndexUtil.findFirstMatch(p, function(p2)
				if p2.Name == value then
					return p2
				end

				return nil
			end, false)
		end

		return IndexUtil.findFirstMatch(p, value, false)
	end)
end

function IndexUtil.matchDescendant(p, value)
	return Option.try(function()
		if typeof(value) == "string" then
			return IndexUtil.findFirstMatch(p, function(p2)
				if p2.Name == value then
					return p2
				end

				return nil
			end, true)
		end

		return IndexUtil.findFirstMatch(p, value, true)
	end)
end

function IndexUtil.findFirstPath(value: string)
	local v = string.split(value, "/")

	if v[1] == "game" then
		table.remove(v, 1)
	end

	local game2 = game
	local index

	index = function(p: number)
		local v2 = v[p]

		if not v2 then
			return game2
		end

		local child = game2:FindFirstChild(v2)

		if not child then
			return nil
		end

		assert(child)
		game2 = child
		return index(p + 1)
	end

	return index(1)
end

function IndexUtil.matchPath(p: string)
	return Option.try(function()
		return IndexUtil.findFirstPath(p)
	end)
end

function IndexUtil.waitForPath(value: string, value2: number?)
	local v = string.split(value, "/")

	if v[1] == "game" then
		table.remove(v, 1)
	end

	local game2 = game
	local index

	index = function(p: number)
		local v2 = v[p]

		if not v2 then
			return game2
		end

		local child = game2:WaitForChild(v2, value2 or 10)
		assert(child, (`no instance at "{v2}" for path "{value}" under {game2:GetFullName()}`))
		game2 = child
		return index(p + 1)
	end

	return index(1)
end

function IndexUtil.matchPathAsync(p: string, object)
	return Future.from(function()
		return Option.try(function()
			return IndexUtil.waitForPath(p, (object:unwrapOr(nil)))
		end)
	end)
end

function IndexUtil.waitForLocalPath(p, value: string, value2: number?)
	local v = string.split(value, "/")

	if v[1] == "." then
		table.remove(v, 1)
	end

	local v2 = p
	local index

	index = function(p2: number)
		local v3 = v[p2]

		if not v3 then
			return v2
		end

		local child = v2:WaitForChild(v3, value2 or 10)
		assert(child, (`no instance at "{v3}" for path "{value}" under {v2:GetFullName()}`))
		v2 = child
		return index(p2 + 1)
	end

	return index(1)
end

function IndexUtil.matchLocalPathAsync(p, p2: string, object)
	return Future.from(function()
		return Option.try(function()
			return IndexUtil.waitForLocalPath(p, p2, (object:unwrapOr(nil)))
		end)
	end)
end

function IndexUtil.findFirstLocalPath(p, value: string)
	local v = string.split(value, "/")

	if v[1] == "." then
		table.remove(v, 1)
	end

	local v2 = p
	local index

	index = function(p2: number)
		local v3 = v[p2]

		if not v3 then
			return v2
		end

		local child = v2:FindFirstChild(v3)

		if not child then
			return nil
		end

		assert(child)
		v2 = child
		return index(p2 + 1)
	end

	return index(1)
end

function IndexUtil.matchLocalPath(p, p2: string)
	return Option.try(function()
		return IndexUtil.findFirstLocalPath(p, p2)
	end)
end

return IndexUtil