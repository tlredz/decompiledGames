local FastDefer = require(script.FastDefer)
local Promise = require(script.Promise)
local object = setmetatable({}, {
	__tostring = function()
		return "LinkToInstanceIndex"
	end
})
local Janitor = {
	ClassName = "Janitor",
	CurrentlyCleaning = true,
	SuppressInstanceReDestroy = false,
	UnsafeThreadCleanup = false
}
Janitor.__index = Janitor
local object2 = setmetatable({}, {
	__mode = "ks"
})
local v = {
	["function"] = true,
	thread = true,
	RBXScriptConnection = "Disconnect"
}

function Janitor.new()
	return (setmetatable({
		CurrentlyCleaning = false
	}, Janitor))
end

function Janitor.Is(p)
	return type(p) == "table" and getmetatable(p) == Janitor
end

Janitor.instanceof = Janitor.Is
local destroy = game.Destroy

local function Remove(p, p2)
	local v2 = object2[p]

	if not v2 then
		return p
	end

	local v3 = v2[p2]

	if not v3 then
		return p
	end

	local v4 = p[v3]

	if v4 then
		if v4 == true then
			if type(v3) == "function" then
				v3()
			else
				local v5

				if coroutine.running() ~= v3 then
					v5 = pcall(function()
						task.cancel(v3)
					end)
				end

				if not v5 then
					if p.UnsafeThreadCleanup then
						FastDefer(function()
							task.cancel(v3)
						end)
					else
						task.defer(function()
							task.cancel(v3)
						end)
					end
				end
			end
		elseif v4 == "Destroy" then
			if p.SuppressInstanceReDestroy and typeof(v3) == "Instance" then
				pcall(destroy, v3)
			else
				local destroy2 = v3.Destroy

				if destroy2 then
					destroy2(v3)
				end
			end
		elseif v4 == "Disconnect" then
			local disconnect = v3.Disconnect

			if disconnect then
				disconnect(v3)
			end
		else
			local v5 = v3[v4]

			if v5 then
				v5(v3)
			end
		end

		p[v3] = nil
	end

	v2[p2] = nil
	return p
end

local function Add(p, p2, p3, p4)
	if p4 then
		Remove(p, p4)
		local v2 = object2[p]

		if not v2 then
			v2 = {}
			object2[p] = v2
		end

		v2[p4] = p2
	end

	local typeName = typeof(p2)
	local v2 = p3 or v[typeName] or "Destroy"

	if typeName == "function" or typeName == "thread" then
		if v2 ~= true then
			warn(string.format(
				"Object is a %* and as such expected `true?` for the method name and instead got %*. Traceback: %*",
				typeName,
				tostring(v2),
				debug.traceback(nil, 2)
			))
		end
	elseif not p2[v2] then
		warn(string.format(
			"Object %* doesn't have method %*, are you sure you want to add it? Traceback: %*",
			tostring(p2),
			tostring(v2),
			debug.traceback(nil, 2)
		))
	end

	p[p2] = v2
	return p2
end

Janitor.Add = Add

function Janitor.AddObject(p, p2, p3, p4, ...)
	return (Add(p, p2.new(...), p3, p4))
end

function Janitor.Get(p, p2)
	local v2 = object2[p]

	if v2 then
		return v2[p2]
	end

	return nil
end

function Janitor.AddPromise(p, object3, p2)
	if not Promise then
		return object3
	end

	if not Promise.is(object3) then
		error(string.format(
			"Invalid argument #1 to 'Janitor:AddPromise' (Promise expected, got %* (%*)) Traceback: %*",
			typeof(object3),
			tostring(object3),
			debug.traceback(nil, 2)
		))
	end

	if object3:getStatus() ~= Promise.Status.Started then
		return object3
	end

	if p2 == nil then
		p2 = newproxy(false)
	end

	local add = Add(p, Promise.new(function(callback, _, callback2)
		if callback2(function()
			object3:cancel()
		end) then
			return
		end

		callback(object3)
	end), "cancel", p2)
	add:finally(function()
		local v3 = p2
		local v4 = object2[p]
		local v5

		if v4 then
			v5 = v4[v3]
		end

		if v5 == add then
			Remove(p, p2)
		end
	end)
	return add
end

Janitor.Remove = Remove

function Janitor:RemoveNoClean(p2)
	local v2 = object2[self]
	local v3 = v2 and v2[p2]

	if v3 then
		self[v3] = nil
		v2[p2] = nil
	end

	return self
end

function Janitor.RemoveList(p, ...)
	if not object2[p] then
		return p
	end

	local v2 = select("#", ...)

	if v2 == 1 then
		return (Remove(p, ...))
	end

	if v2 == 2 then
		local v3, v4 = ...
		Remove(p, v3)
		Remove(p, v4)
		return p
	elseif v2 == 3 then
		local v3, v4, v5 = ...
		Remove(p, v3)
		Remove(p, v4)
		Remove(p, v5)
		return p
	else
		for i = 1, v2 do
			Remove(p, select(i, ...))
		end
	end

	return p
end

function Janitor:RemoveListNoClean(...)
	local v2 = object2[self]

	if not v2 then
		return self
	end

	local v3 = select("#", ...)

	if v3 == 1 then
		local v4 = ...
		local v5 = v2[v4]

		if v5 then
			self[v5] = nil
			v2[v4] = nil
		end

		return self
	elseif v3 == 2 then
		local v4, v5 = ...
		local v6 = v2[v4]

		if v6 then
			self[v6] = nil
			v2[v4] = nil
		end

		local v7 = v2[v5]

		if v7 then
			self[v7] = nil
			v2[v5] = nil
		end

		return self
	elseif v3 == 3 then
		local v4, v5, v6 = ...
		local v7 = v2[v4]

		if v7 then
			self[v7] = nil
			v2[v4] = nil
		end

		local v8 = v2[v5]

		if v8 then
			self[v8] = nil
			v2[v5] = nil
		end

		local v9 = v2[v6]

		if v9 then
			self[v9] = nil
			v2[v6] = nil
		end

		return self
	else
		for i = 1, v3 do
			local v4 = select(i, ...)
			local v5 = v2[v4]

			if not v5 then
				continue
			end

			self[v5] = nil
			v2[v4] = nil
		end
	end

	return self
end

function Janitor.GetAll(p)
	local v2 = object2[p]

	if v2 then
		return (table.freeze(table.clone(v2)))
	end

	return {}
end

local function Cleanup(p)
	if not p.CurrentlyCleaning then
		local suppressInstanceReDestroy = p.SuppressInstanceReDestroy
		local unsafeThreadCleanup = p.UnsafeThreadCleanup
		p.CurrentlyCleaning = nil
		p.SuppressInstanceReDestroy = nil
		p.UnsafeThreadCleanup = nil
		local v2, v3 = next(p)

		while v2 and v3 do
			if v3 == true then
				if type(v2) == "function" then
					v2()
				else
					local v4

					if coroutine.running() ~= v2 then
						v4 = pcall(function()
							task.cancel(v2)
						end)
					end

					if not v4 then
						local v5 = v2

						if unsafeThreadCleanup then
							local v6 = v5
							FastDefer(function()
								task.cancel(v6)
							end)
						else
							local v6 = v5
							task.defer(function()
								task.cancel(v6)
							end)
						end
					end
				end
			elseif v3 == "Destroy" then
				if p.SuppressInstanceReDestroy and typeof(v2) == "Instance" then
					pcall(destroy, v2)
				else
					local destroy2 = v2.Destroy

					if destroy2 then
						destroy2(v2)
					end
				end
			elseif v3 == "Disconnect" then
				local disconnect = v2.Disconnect

				if disconnect then
					disconnect(v2)
				end
			else
				local v4 = v2[v3]

				if v4 then
					v4(v2)
				end
			end

			p[v2] = nil
			local v4
			v4, v3 = next(p, v2)
			v2 = v4
		end

		local v4 = object2[p]

		if v4 then
			table.clear(v4)
			object2[p] = nil
		end

		p.CurrentlyCleaning = false
		p.SuppressInstanceReDestroy = suppressInstanceReDestroy
		p.UnsafeThreadCleanup = unsafeThreadCleanup
	end
end

Janitor.Cleanup = Cleanup

function Janitor.Destroy(list)
	Cleanup(list)
	table.clear(list)
	setmetatable(list, nil)
end

Janitor.__call = Cleanup

local function LinkToInstance(p, instance, flag: boolean?)
	local v2

	if flag then
		v2 = newproxy(false)
	else
		v2 = object
	end

	return (Add(p, instance.Destroying:Connect(function()
		Cleanup(p)
	end), "Disconnect", v2))
end

Janitor.LinkToInstance = LinkToInstance
Janitor.LegacyLinkToInstance = LinkToInstance

function Janitor.LinkToInstances(p, ...)
	local maid = Janitor.new()

	for i = 1, select("#", ...) do
		local v2 = select(i, ...)

		if typeof(v2) == "Instance" then
			maid:Add(LinkToInstance(p, v2, true), "Disconnect")
		end
	end

	return maid
end

function Janitor.__tostring(_)
	return "Janitor"
end

return Janitor