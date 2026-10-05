local isValueObject = require(script.Parent.isValueObject)
return function(callback, callback2)
	if callback == callback2 or callback ~= callback and callback2 ~= callback2 then
		return true
	end

	if not (callback and callback2) then
		return false
	end

	if typeof(callback) == "function" and typeof(callback2) == "function" then
		callback = callback()
		callback2 = callback2()

		if callback == callback2 or callback ~= callback and callback2 ~= callback2 then
			return true
		end

		if not (callback and callback2) then
			return false
		end
	end

	return isValueObject(callback) and isValueObject(callback2) and callback.equals(callback2) and true or false
end