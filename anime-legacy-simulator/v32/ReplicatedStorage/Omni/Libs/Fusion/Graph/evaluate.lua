local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local evaluate

evaluate = function(object, flag: boolean)
	if object.validity == "busy" then
		return External.logError("infiniteLoop")
	end

	local v = object.lastChange == nil
	local v2 = object.validity == "invalid"

	if not (v or v2 or flag) then
		return false
	end

	local v3 = v or flag

	if not v3 then
		for k in object.dependencySet do
			evaluate(k, false)

			if not (k.lastChange > object.lastChange) then
				continue
			end

			v3 = true
			break
		end
	end

	local v4

	if v3 then
		for k in object.dependencySet do
			k.dependentSet[object] = nil
			object.dependencySet[k] = nil
		end

		object.validity = "busy"
		v4 = object:_evaluate() or v
	else
		v4 = false
	end

	if v4 then
		object.lastChange = os.clock()
	end

	object.validity = "valid"
	return v4
end

return evaluate