local Option = {}
Option.__index = Option

function Option._new(p)
	return (setmetatable({
		ClassName = "Option",
		_v = p,
		_s = p ~= nil
	}, Option))
end

function Option.Some(p)
	assert(p ~= nil, "Option.Some() value cannot be nil")
	return Option._new(p)
end

function Option.Wrap(p)
	if p == nil then
		return Option.None
	end

	return Option.Some(p)
end

function Option.Is(p)
	return type(p) == "table" and getmetatable(p) == Option
end

function Option.Assert(p)
	assert(Option.Is(p), "Result was not of type Option")
end

function Option.Deserialize(instance)
	local v

	if type(instance) == "table" then
		v = instance.ClassName == "Option"
	else
		v = false
	end

	assert(v, "Invalid data for deserializing Option")
	return instance.Value == nil and Option.None or Option.Some(instance.Value)
end

function Option:Serialize()
	return {
		ClassName = self.ClassName,
		Value = self._v
	}
end

function Option:Match(p)
	local some = p.Some
	local none = p.None
	assert(type(some) == "function", "Missing 'Some' match")
	assert(type(none) == "function", "Missing 'None' match")

	if self:IsSome() then
		return some(self:Unwrap())
	end

	return none()
end

function Option:IsSome()
	return self._s
end

function Option:IsNone()
	return not self._s
end

function Option:Expect(p)
	assert(self:IsSome(), p)
	return self._v
end

function Option:ExpectNone(p)
	assert(self:IsNone(), p)
end

function Option:Unwrap()
	return self:Expect("Cannot unwrap option of None type")
end

function Option:UnwrapOr(p)
	if self:IsSome() then
		return self:Unwrap()
	end

	return p
end

function Option:UnwrapOrElse(callback)
	if self:IsSome() then
		return self:Unwrap()
	end

	return callback()
end

function Option:And(p)
	if self:IsSome() then
		return p
	end

	return Option.None
end

function Option:AndThen(callback)
	if not self:IsSome() then
		return Option.None
	end

	local v = callback(self:Unwrap())
	Option.Assert(v)
	return v
end

function Option:Or(p)
	if self:IsSome() then
		return self
	end

	return p
end

function Option:OrElse(callback)
	if self:IsSome() then
		return self
	end

	local v = callback()
	Option.Assert(v)
	return v
end

function Option:XOr(object2)
	local isSome = self:IsSome()

	if isSome == object2:IsSome() then
		return Option.None
	end

	if isSome then
		return self
	end

	return object2
end

function Option:Filter(callback)
	if self:IsNone() or not callback(self._v) then
		return Option.None
	end

	return self
end

function Option:Contains(p)
	return self:IsSome() and self._v == p
end

function Option:__tostring()
	if self:IsSome() then
		return "Option<" .. typeof(self._v) .. ">"
	end

	return "Option<None>"
end

function Option:__eq(object2)
	if not Option.Is(object2) then
		return false
	end

	if self:IsSome() and object2:IsSome() then
		return self:Unwrap() == object2:Unwrap()
	end

	if self:IsNone() and object2:IsNone() then
		return true
	end

	return false
end

Option.None = Option._new()
return Option