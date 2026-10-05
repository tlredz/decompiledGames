local v = newproxy(true)

getmetatable(v).__tostring = function()
	return "Object.None"
end

return v