local CmdrTextUtil = {}

function CmdrTextUtil.isCommandStage(value)
	return not tostring(value or ""):find("%s")
end

function CmdrTextUtil.getActiveArgIndex(value, list)
	local v = tostring(value or ""):match("%s$") ~= nil
	local v2 = math.max(0, #list - 1)

	if v then
		return v2 + 1
	end

	return (math.max(1, v2))
end

function CmdrTextUtil.getCurrentTokenPrefix(value, list)
	if tostring(value or ""):match("%s$") then
		return ""
	end

	return list[#list] or ""
end

function CmdrTextUtil.buildGhostLineForCurrentToken(value, p)
	if not p or p == "" then
		return ""
	end

	local v = tostring(value or "")

	if v:match("%s$") then
		return v .. p
	end

	local v2 = v:match("([^%s]+)$") or ""
	return v:sub(1, #v - #v2) .. p
end

function CmdrTextUtil.buildArgsText(p)
	local args = p and p.Args or {}

	if #args == 0 then
		return ""
	end

	local v = {}

	for _, arg in ipairs(args) do
		local v2 = arg.Optional and "?" or ""
		local v3 = arg.Variadic and "..." or ""
		v[#v + 1] = string.format("<%s%s%s>", arg.Name, v2, v3)
	end

	return table.concat(v, " ")
end

function CmdrTextUtil.buildRemainingArgsText(p, p2)
	local args = p and p.Args or {}

	if #args == 0 then
		return ""
	end

	local v = math.max(1, tonumber(p2) or 1)

	if #args < v then
		return ""
	end

	local v2 = {}

	for i = v, #args do
		local arg = args[i]
		local v3 = arg.Optional and "?" or ""
		v2[#v2 + 1] = string.format("<%s%s>", arg.Name, v3)
	end

	return table.concat(v2, " ")
end

return CmdrTextUtil