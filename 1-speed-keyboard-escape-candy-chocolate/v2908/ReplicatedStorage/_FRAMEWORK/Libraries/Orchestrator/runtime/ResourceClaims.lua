local object = setmetatable({}, {
	__mode = "k"
})
local ResourceClaims = {}

function ResourceClaims.claim(p, p2, p3: string)
	local v = object[p2]

	if v == nil then
		v = {}
		object[p2] = v
	end

	local v2 = v[p3]

	if v2 ~= nil and v2 ~= p then
		return false, v2
	end

	v[p3] = p
	return true, nil
end

function ResourceClaims.isOwner(p, p2, p3: string)
	local v = object[p2]
	return v ~= nil and v[p3] == p
end

function ResourceClaims.release(p, p2, p3: string)
	local v = object[p2]

	if v ~= nil and v[p3] == p then
		v[p3] = nil

		if next(v) == nil then
			object[p2] = nil
		end
	end
end

function ResourceClaims.releaseOwner(p)
	for k, v in object do
		for k2, v2 in v do
			if v2 == p then
				v[k2] = nil
			end
		end

		if next(v) == nil then
			object[k] = nil
		end
	end
end

return ResourceClaims