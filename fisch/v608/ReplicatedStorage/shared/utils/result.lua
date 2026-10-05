return function(flag: boolean, err)
	if flag then
		return {
			success = true,
			value = err
		}
	end

	return {
		success = false,
		trace = debug.traceback(),
		err = err
	}
end