local EncodingService = game:GetService("EncodingService")

local function normalizeTraitSet(p)
	local clone = table.clone(p)

	for k, v in clone do
		clone[k] = string.match(v, "^%s*(.-)%s*$") or v
	end

	table.sort(clone)
	return clone
end

local function getTraitSetHash(p)
	local traitSet = normalizeTraitSet(p)

	if #traitSet == 0 then
		return "_none"
	end

	local buffer2 = buffer.fromstring(table.concat(traitSet, "\31"))
	return buffer.tostring(EncodingService:Base64Encode(EncodingService:ComputeBufferHash(
		buffer2,
		Enum.HashAlgorithm.Sha1
	)))
end

return getTraitSetHash