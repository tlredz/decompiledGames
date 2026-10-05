local __DEV__ = _G.__DEV__
require(script.Parent.Parent.Parent:WaitForChild("es7-types"))
return function(list)
	if __DEV__ then
		print("Luau now has a direct table.isfrozen call that can save the overhead of this library function call")
	end

	return table.isfrozen(list)
end