return {
	Timeout = function(callback, p: number, value: string?)
		local unixTimestamp = DateTime.now().UnixTimestamp

		while not callback() do
			task.wait()

			if p <= DateTime.now().UnixTimestamp - unixTimestamp then
				error(value or "Timed out")
			end
		end
	end
}