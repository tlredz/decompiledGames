return function(p)
	local function fn() end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getDisconnectable(array, object)
		return {
			_array = array,
			_object = object,
			connected = true,
			Disconnect = function(self)
				self.connected = false
				self.Disconnect = fn
				local index = table.find(self._array, self._object)
				assert(
					index,
					"Couldn't disconnect this function: it wasn't found! Check for multiple functions with no upvalues"
				)
				return table.remove(self._array, index)
			end
		}
	end

	function p:Once(callback)
		table.insert(self.__firstf, callback)

		for k, v in pairs(self.__registered) do
			task.spawn(callback, k, v, self.__env)
		end

		return self
	end

	function p:ConnectOnce(object)
		table.insert(self.__firstf, object)

		for k, v in pairs(self.__registered) do
			task.defer(object, k, v, self.__env)
		end

		return getDisconnectable(self.__firstf, object)
	end

	function p:DestroyNamedConnections(p3)
		if self.__namedf and self.__namedf[p3] then
			self.__namedf[p3]:Disconnect()
			self.__namedf[p3] = nil
		end
	end

	function p:NamedOnce(p2, callback)
		if not self.__namedf then
			self.__namedf = {}
		end

		if self.__namedf[p2] then
			return self.__namedf[p2]
		end

		local connection = nil

		local function fn2(...)
			local v = callback(...)

			if v == nil or v then
				connection:Disconnect()
			end
		end

		connection = getDisconnectable(self.__firstf, fn2)
		self.__namedf[p2] = connection
		table.insert(self.__firstf, fn2)

		for k, v in pairs(self.__registered) do
			task.defer(fn2, k, v, self.__env)
		end

		return connection
	end

	function p:ConnectOnceDropExtra(callback)
		local connection = nil

		local function fn2(...)
			local v = callback(...)

			if v == nil or v then
				connection:Disconnect()
			end
		end

		connection = getDisconnectable(self.__firstf, fn2)
		table.insert(self.__firstf, fn2)

		for k, v in pairs(self.__registered) do
			task.defer(fn2, k, v, self.__env)
		end

		return connection
	end

	function p:Seen(callback)
		table.insert(self.__seenf, callback)

		for k, v in pairs(self.__registered) do
			task.spawn(callback, k, v, self.__env)
		end

		return self
	end

	function p:Unseen(p3)
		table.insert(self.__unseenf, p3)
		return self
	end

	function p:DoOnce(p3, p4)
		for _, v in ipairs(self.__firstf) do
			v(p3, p4, self.__env)
		end
	end

	function p:See(p3, p4)
		for _, v in ipairs(self.__seenf) do
			v(p3, p4, self.__env)
		end
	end

	function p:Unsee(p3, p4)
		for _, v in ipairs(self.__unseenf) do
			v(p3, p4, self.__env)
		end
	end
end