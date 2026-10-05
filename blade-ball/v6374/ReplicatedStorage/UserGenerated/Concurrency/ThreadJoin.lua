local function ThreadJoin(thread: thread, p: number?)
	local lastTime = os.clock()

	while coroutine.status(thread) ~= "dead" do
		if p ~= nil and p <= os.clock() - lastTime then
			return false
		end

		task.wait()
	end

	return true
end

return ThreadJoin