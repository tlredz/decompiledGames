local frozen = table.freeze({
	["0"] = "\0",
	["1"] = "\1",
	["2"] = "\2",
	["3"] = "\3",
	["4"] = "\4",
	["5"] = "\5",
	["6"] = "\6",
	["7"] = "\7",
	["8"] = "\8",
	["9"] = "\t"
})
return table.freeze({
	from_double = function(p: number)
		local v2, v3, v4 = string.match(tostring(p), "^(%d+)%.?(%d*)e?([+-]?%d*)$")
		local v5, v6 = string.match(v2 .. v3, "^0*(%d-)(0*)$")
		local v7 = { string.byte(string.gsub(v5, ".", frozen), 1, -1) }
		return v7, #v7, (tonumber(v4) or 0) - #v3 + #v6
	end
})