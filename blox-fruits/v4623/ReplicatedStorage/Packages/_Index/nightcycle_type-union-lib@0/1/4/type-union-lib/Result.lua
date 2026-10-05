local Constructors = require(script.Parent.Constructors)
local Result = {
	ok = Constructors.Result.ok,
	err = Constructors.Result.err,
	transpose = Constructors.Result.transpose,
	flatten = Constructors.Result.flatten
}

function Result.map(p, callback)
	if p.IsOk then
		return Result.ok(callback(p.Value))
	end

	return p
end

function Result.mapErr(p, callback)
	if p.IsErr then
		return Result.err(callback(p.Value))
	end

	return p
end

function Result.match(p, callback, callback2)
	if p.IsOk then
		return callback(p.Value)
	end

	return callback2(p.Value)
end

function Result.from(flag: boolean, p)
	if flag == true then
		return Result.ok(p)
	end

	return Result.err(p)
end

function Result.try(callback)
	local v, v2 = callback()
	return Result.from(v, v2)
end

function Result.asNullable(p)
	if p.IsOk then
		return p.Value
	end

	return nil
end

return Result