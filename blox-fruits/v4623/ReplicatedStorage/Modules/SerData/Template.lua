local Utility = require(script.Parent.Utility)
local Template = {}

function Template.encode(_: nil)
	local writer = Utility.newWriter()
	writer(16, 0)
	return Utility.Trim(writer(16, 36925))
end

function Template.decode(buf: buffer)
	local reader = Utility.newReader(buf)
	local v = reader(16)
	local v2 = nil

	if v ~= 0 then
		error((`UNSUPPORTED FORMAT VERSION -> {v}`))
	end

	local v3 = reader(16)

	if v3 ~= 36925 then
		error((`CORRUPT END IDENTIFIER -> {v3}`))
	end

	return v2
end

return Template