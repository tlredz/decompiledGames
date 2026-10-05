local function readonlytable(p)
	return (setmetatable({}, {
		__index = p,
		__metatable = false,
		__newindex = function(p2, p3, p4)
			error("Attempt to modify read-only table: " .. p2 .. ", key=" .. p3 .. ", value=" .. p4)
		end
	}))
end

return (readonlytable({
	Start = "Start",
	Complete = "Complete",
	Fail = "Fail"
}))