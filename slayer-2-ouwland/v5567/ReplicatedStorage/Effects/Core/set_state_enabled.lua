return function(object, p, p2)
	if object and p and p2 then
		local v = typeof(p) ~= "table" and { p } or p

		for _, v2 in pairs(v) do
			object:SetStateEnabled(v2, p2)
		end
	end
end