local callbacks = {}
local v = nil
local NPCTable = {}

function NPCTable.onLoaded(callback)
	if v then
		callback(v)
	else
		table.insert(callbacks, callback)
	end
end

function NPCTable.connect(p)
	v = p

	for _, v2 in callbacks do
		v2(v)
	end
end

return NPCTable