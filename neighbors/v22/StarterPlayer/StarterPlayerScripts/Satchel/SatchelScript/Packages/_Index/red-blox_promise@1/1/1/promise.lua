local Spawn = require(script.Parent.Spawn)
local Promise = {}
Promise.__index = Promise

function Promise.new(callback)
	local object = setmetatable({}, Promise)
	object.Status = "Pending"
	object.OnResolve = {}
	object.OnReject = {}
	object.Value = {}
	object.Thread = coroutine.create(xpcall)
	task.spawn(object.Thread, callback, function(p)
		object:_Reject(p)
	end, function(...)
		object:_Resolve(...)
	end, function(...)
		object:_Reject(...)
	end)
	return object
end

function Promise.Resolve(...)
	local self = setmetatable({}, Promise)
	self.Status = "Resolved"
	self.OnResolve = {}
	self.OnReject = {}
	self.Value = { ... }
	self.Thread = nil
	return self
end

function Promise.Reject(...)
	local self = setmetatable({}, Promise)
	self.Status = "Rejected"
	self.OnResolve = {}
	self.OnReject = {}
	self.Value = { ... }
	self.Thread = nil
	return self
end

function Promise.All(list)
	if #list == 0 then
		return Promise.Resolve({})
	end

	return Promise.new(function(callback, callback2)
		local flag = false
		local count = 0
		local v = {}

		for k, v2 in list do
			if v2.Status == "Resolved" then
				count += 1
				v[k] = v2.Value[1]
			elseif v2.Status == "Rejected" then
				callback2(v2.Value[1])
				flag = true
				break
			else
				local v3 = k
				table.insert(v2.OnResolve, function(p)
					if flag then
						return
					end

					count += 1
					v[v3] = p

					if count == #list then
						callback(v)
						flag = true
					end
				end)
				table.insert(v2.OnReject, function(p)
					if flag then
						return
					end

					callback2(p)
					flag = true
				end)
			end
		end

		if count == #list then
			callback(v)
			flag = true
		end
	end)
end

function Promise.AllSettled(list)
	if #list == 0 then
		return Promise.Resolve({})
	end

	return Promise.new(function(callback, _)
		local flag = false
		local count = 0
		local v = {}

		for k, v2 in list do
			if v2.Status == "Resolved" then
				count += 1
				v[k] = "Resolved"
			elseif v2.Status == "Rejected" then
				count += 1
				v[k] = "Rejected"
			else
				local v3 = k
				table.insert(v2.OnResolve, function(p)
					if flag then
						return
					end

					count += 1
					v[v3] = "Resolved"

					if count == #list then
						callback(v)
						flag = true
					end
				end)
				local v4 = k
				table.insert(v2.OnReject, function(p)
					if flag then
						return
					end

					count += 1
					v[v4] = "Rejected"

					if count == #list then
						callback(v)
						flag = true
					end
				end)
			end
		end

		if count == #list then
			callback(v)
			flag = true
		end
	end)
end

function Promise.Any(list)
	if #list == 0 then
		return Promise.Reject({})
	end

	return Promise.new(function(callback, callback2)
		local flag = false
		local count = 0
		local v = {}

		for k, v2 in list do
			if v2.Status == "Resolved" then
				callback(v2.Value[1])
				flag = true
				break
			elseif v2.Status == "Rejected" then
				count += 1
				v[k] = v2.Value[1]
			else
				table.insert(v2.OnResolve, function(p)
					if flag then
						return
					end

					callback(p)
					flag = true
				end)
				local v3 = k
				table.insert(v2.OnReject, function(p)
					if flag then
						return
					end

					count += 1
					v[v3] = p

					if count == #list then
						callback2(v)
						flag = true
					end
				end)
			end
		end

		if count == #list then
			callback2(v)
			flag = true
		end
	end)
end

function Promise.Race(list)
	if #list == 0 then
		return Promise.Reject("No promises to resolve.")
	end

	return Promise.new(function(callback, callback2)
		local flag = false

		for _, v in list do
			if v.Status == "Resolved" then
				callback(unpack(v.Value))
				flag = true
				break
			elseif v.Status == "Rejected" then
				callback2(unpack(v.Value))
				flag = true
				break
			else
				table.insert(v.OnResolve, function(p)
					if flag then
						return
					end

					callback(p)
					flag = true
				end)
				table.insert(v.OnReject, function(p)
					if flag then
						return
					end

					callback2(p)
					flag = true
				end)
			end
		end
	end)
end

function Promise.Retry(p: number, callback, ...)
	local v = { ... }
	return Promise.new(function(callback2, callback3)
		local count = 0

		while count < p do
			count += 1
			local v2 = { pcall(callback, unpack(v)) }

			if table.remove(v2, 1) then
				callback2(unpack(v2))
				break
			end

			if count ~= p then
				continue
			end

			callback3(unpack(v2))
			break
		end
	end)
end

function Promise.RetryWithDelay(p: number, duration: number, callback, ...)
	local v = { ... }
	return Promise.new(function(callback2, callback3)
		local count = 0

		while count < p do
			count += 1
			local v2 = { pcall(callback, unpack(v)) }

			if table.remove(v2, 1) then
				callback2(unpack(v2))
				break
			end

			if count == p then
				callback3(unpack(v2))
				break
			else
				task.wait(duration)
			end
		end
	end)
end

function Promise:_Resolve(...)
	assert(self.Status == "Pending", "Cannot resolve a promise that is not pending.")
	self.Status = "Resolved"
	self.Value = table.pack(...)

	for _, v in self.OnResolve do
		Spawn(v, ...)
	end

	task.defer(task.cancel, self.Thread)
end

function Promise:_Reject(...)
	assert(self.Status == "Pending", "Cannot reject a promise that is not pending.")
	self.Status = "Rejected"
	self.Value = table.pack(...)

	for _, v in self.OnReject do
		Spawn(v, ...)
	end

	task.defer(task.cancel, self.Thread)
end

function Promise:Then(callback, callback2)
	return Promise.new(function(callback3, callback4)
		local function PromiseResolutionProcedure(data2, ...)
			if type(data2) == "table" and getmetatable(data2) == Promise then
				if data2.Status == "Pending" then
					table.insert(data2.OnResolve, callback3)
					table.insert(data2.OnReject, callback4)
				elseif data2.Status == "Resolved" then
					callback3(unpack(data2.Value))
				elseif data2.Status == "Rejected" then
					callback4(unpack(data2.Value))
				end
			else
				callback3(data2, ...)
			end
		end

		if self.Status == "Pending" then
			if callback then
				table.insert(self.OnResolve, function(...)
					PromiseResolutionProcedure(callback(...))
				end)
			else
				table.insert(self.OnResolve, PromiseResolutionProcedure)
			end

			if callback2 then
				table.insert(self.OnReject, function(...)
					PromiseResolutionProcedure(callback2(...))
				end)
			else
				table.insert(self.OnReject, callback4)
			end
		elseif self.Status == "Resolved" then
			if callback then
				PromiseResolutionProcedure(callback(unpack(self.Value)))
			else
				callback3(unpack(self.Value))
			end
		elseif self.Status == "Rejected" then
			if callback2 then
				PromiseResolutionProcedure(callback2(unpack(self.Value)))
			else
				callback4(unpack(self.Value))
			end
		end
	end)
end

function Promise:Catch(callback)
	return self:Then(nil, callback)
end

function Promise:Finally(callback)
	return self:Then(function(...)
		callback(self.Status)
		return self
	end, function(_)
		callback(self.Status)
		return self
	end)
end

function Promise.Await(data)
	if data.Status == "Resolved" then
		return unpack(data.Value)
	end

	if data.Status == "Rejected" then
		return error(unpack(data.Value))
	end

	local thread = coroutine.running()

	local function Resume()
		task.spawn(thread)
	end

	table.insert(data.OnResolve, Resume)
	table.insert(data.OnReject, Resume)
	coroutine.yield()

	if data.Status == "Resolved" then
		return unpack(data.Value)
	end

	return error(unpack(data.Value))
end

function Promise.StatusAwait(data)
	if not (data.Status ~= "Resolved" and data.Status ~= "Rejected") then
		return data.Status, unpack(data.Value)
	end

	local thread = coroutine.running()

	local function Resume()
		coroutine.resume(thread)
	end

	table.insert(data.OnResolve, Resume)
	table.insert(data.OnReject, Resume)
	coroutine.yield()
	return data.Status, unpack(data.Value)
end

return Promise