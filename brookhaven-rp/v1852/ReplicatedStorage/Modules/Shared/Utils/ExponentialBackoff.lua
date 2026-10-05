return {
	Backoff = function(callback, duration: number, p: number, p2: number?)
		local count = 0

		while true do
			count += 1

			if callback() == true then
				break
			end

			if p2 ~= nil and p2 <= count then
				return false
			end

			task.wait(duration)
			duration *= p
		end

		return true
	end
}