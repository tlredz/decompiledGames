local v = newproxy(true)

getmetatable(v).__tostring = function()
	return "Freeze.None"
end

return v