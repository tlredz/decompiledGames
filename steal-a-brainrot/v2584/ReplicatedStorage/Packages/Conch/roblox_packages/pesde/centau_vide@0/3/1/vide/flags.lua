local function inline_test()
	return debug.info(1, "n")
end

return {
	strict = debug.info(1, "n") == "inline_test",
	batch = false
}