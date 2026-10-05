local v = {
	DELETE = table.freeze({
		_o = 0
	}),
	ADD = function(p)
		return table.freeze({
			_o = 1,
			_v = p
		})
	end,
	SUB = function(p)
		return table.freeze({
			_o = 2,
			_v = p
		})
	end,
	MULT = function(p)
		return table.freeze({
			_o = 3,
			_v = p
		})
	end,
	DIV = function(p)
		return table.freeze({
			_o = 4,
			_v = p
		})
	end,
	POW = function(p: number)
		return table.freeze({
			_o = 5,
			_v = p
		})
	end,
	CONCAT = function(p)
		return table.freeze({
			_o = 6,
			_v = p
		})
	end,
	DEFAULT = function(p)
		return table.freeze({
			_o = 7,
			_v = p
		})
	end,
	MAP = function(p, p2)
		return table.freeze({
			_o = 8,
			_v = p,
			_d = p2
		})
	end,
	REPLACE = function(p)
		return table.freeze({
			_o = 9,
			_v = p
		})
	end,
	INSERT = function(p, flag: boolean?)
		return table.freeze({
			_o = 10,
			_v = p,
			_e = flag
		})
	end,
	REMOVE = function(p)
		return table.freeze({
			_o = 11,
			_v = p
		})
	end,
	MAP_BY_KEY = function(p, p2, p3)
		return table.freeze({
			_o = 12,
			_v = p,
			_k = p2,
			_d = p3
		})
	end
}
return table.freeze(v)