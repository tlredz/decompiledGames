local Lock = {}
local v = {}
local count = 0
local Signal = require(game.ReplicatedStorage.Modules.Util.Signal)

function Lock.new(flag: boolean?)
	count += 1
	local v2

	if flag then
		v2 = nil
	else
		v2 = Signal.new()
	end

	local v3 = {
		_uid = tostring(count),
		_extensions = {},
		_locks = {},
		_extension = nil,
		Extend = function(self, flag2: boolean?)
			local v4 = Lock.new(flag2 == true)
			v4._extension = self._uid
			local v5 = self:DumpLocks()

			for _, v6 in pairs(v5) do
				v4:Lock(v6)
			end

			table.insert(self._extensions, v4)
			return v4
		end,
		Lock = function(self, p: string)
			if not self:GetLock(p) then
				table.insert(self._locks, p)

				for _, _extension in pairs(self._extensions) do
					_extension:Lock(p)
				end

				if v2 then
					v2:Fire(true, p)
				end
			end
		end,
		Unlock = function(self, p: string)
			local lock = self:GetLock(p)

			if lock then
				table.remove(self._locks, lock)

				for _, _extension in pairs(self._extensions) do
					_extension:Unlock(p)
				end

				if v2 then
					v2:Fire(false, p)
				end
			end
		end,
		IsLocked = function(p)
			return #p._locks > 0
		end,
		GetLock = function(self, p2: string)
			return table.find(self._locks, p2)
		end,
		DumpLocks = function(self)
			return self._locks
		end,
		ClearLocks = function(self)
			for k, _lock in pairs(self._locks) do
				self._locks[k] = nil

				if v2 then
					v2:Fire(false, _lock)
				end

				for _, _extension in pairs(self._extensions) do
					_extension:ClearLocks()
				end
			end
		end,
		Connect = function(self, callback)
			if v2 then
				return v2:Connect(callback)
			end

			return nil
		end
	}

	function v3:Destroy()
		if v2 then
			v2:Destroy()
			v2 = nil
		end

		if self._extension then
			local v4 = v[self._extension]

			for k, _extension in pairs(v4._extensions) do
				if _extension._uid == self._uid then
					table.remove(v4._extensions, k)
				end
			end
		else
			for _, _extension in pairs(self._extensions) do
				_extension:Destroy()
			end
		end

		v[v3._uid] = nil
		table.clear(self)
	end

	v[v3._uid] = v3
	return v3
end

return Lock