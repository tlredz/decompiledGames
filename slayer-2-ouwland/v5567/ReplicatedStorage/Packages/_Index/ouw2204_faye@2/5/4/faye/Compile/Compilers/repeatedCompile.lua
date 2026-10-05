local typeof2 = typeof
require(script.Parent.Parent.Parent.FayeTypes)
return function(p: number, p2, p3, callback, p4)
	if p2 ~= nil then
		if typeof2(p) ~= "number" and typeof(p4.Instance[p]) ~= "RBXScriptSignal" then
			p4.Instance[p] = p2
		elseif p3 == nil then
			callback(p4, (typeof2(p2) ~= "table" or p2.__type ~= nil or not p2) and { p2 } or p2)
		else
			callback(p4, {
				[p2] = p3
			})
		end
	end
end