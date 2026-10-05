return {
	new = function(method, callback2)
		return {
			_toKey = callback2,
			_Cache = {},
			_method = method,
			get = function(self, ...)
				local _toKey = self._toKey(...)
				return self._Cache[_toKey]
			end,
			reset = function(p, ...)
				local _toKey = p._toKey(...)
				p._Cache[_toKey] = nil
			end,
			set = function(self, p2, ...)
				local _toKey = self._toKey(...)
				self._Cache[_toKey] = p2
			end,
			call = function(self, ...)
				local v = self:get(...)

				if v ~= nil then
					return v
				end

				local _method = self._method(...)
				self:set(_method, ...)
				return _method
			end
		}
	end
}