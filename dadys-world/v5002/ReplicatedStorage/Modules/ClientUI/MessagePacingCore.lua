local MessagePacingCore = {
	MAX_PENDING = 3,
	holdSeconds = function(value: string)
		local count = 0

		for _ in string.gmatch(value, "%S+") do
			count += 1
		end

		return (math.max(1.5, count / 3 + 1))
	end,
	new = function()
		return {
			pending = {},
			showing = nil
		}
	end
}

function MessagePacingCore.enqueue(p, value)
	if type(value) ~= "string" or value == "" or (value == p.showing or table.find(p.pending, value)) then
		return false
	end

	table.insert(p.pending, value)

	if #p.pending > MessagePacingCore.MAX_PENDING then
		table.remove(p.pending, 1)
	end

	return true
end

function MessagePacingCore:interrupt(value)
	if type(value) ~= "string" or value == "" then
		return false
	end

	local index = table.find(self.pending, value)

	if index then
		table.remove(self.pending, index)
	end

	table.insert(self.pending, 1, value)

	if #self.pending > MessagePacingCore.MAX_PENDING then
		table.remove(self.pending, 2)
	end

	self.showing = nil
	return true
end

function MessagePacingCore:take()
	local showing = table.remove(self.pending, 1)
	self.showing = showing
	return showing
end

function MessagePacingCore:clear()
	table.clear(self.pending)
	self.showing = nil
end

return MessagePacingCore