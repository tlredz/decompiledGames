local function read(callback)
	if type(callback) == "function" then
		return (callback())
	end

	return callback
end

return read