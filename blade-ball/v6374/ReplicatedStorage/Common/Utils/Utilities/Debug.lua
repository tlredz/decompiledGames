local Debug = {
	info = function(...)
		local v = ""

		for _, v2 in pairs({ ... }) do
			if type(v2) == "string" then
				v ..= v2
			else
				v ..= tostring(v2) or "nil"
			end
		end

		local v2 = (debug.info(3, "s") or ".?"):match("%.([%a%d _-]*)$") or "?"
		local v3 = debug.info(3, "l") or "?"
		local v4 = debug.info(3, "n") or "?"
		local v5 = (debug.info(2, "s") or ".?"):match("%.([%a%d _-]*)$") or "?"
		local v6 = debug.info(2, "l") or "?"
		local v7 = debug.info(2, "n") or "?"
		return string.format("[%s:%s:%s] -> [%s:%s:%s] : %s", v2, v4, v3, v5, v7, v6, v)
	end
}

function Debug.printTable(items, count, p)
	local v = p or tostring(items) .. "\n"
	local v2 = count or 0

	for k, item in pairs(items) do
		if type(item) == "table" then
			v = (v .. string.rep("  ", v2) .. "[" .. typeof(item) .. "] " .. tostring(k) .. ":\n") .. Debug.printTable(
				item,
				v2 + 1
			)
		else
			v ..= string.rep("  ", v2) .. "[" .. typeof(item) .. "] " .. tostring(k) .. ": " .. tostring(item) .. "\n"
		end
	end

	if v2 == 0 then
		print(v)
	end

	return v
end

function Debug.printl(...)
	local v = debug.info(2, "l") or "?"
	print(v .. ":", unpack({ ... }))
end

local function outputContent(callback, ...)
	local v = string.split(debug.info(3, "s") or { "Unidentified Script" }, ".")
	callback(
		"[" .. v[#v] .. "/" .. (debug.info(3, "n") or "Unidentified Function") .. "](Ln. " .. (debug.info(3, "l") or "?") .. ")",
		...
	)
end

function Debug.printcontext(...)
	outputContent(print, ...)
end

function Debug.warncontext(...)
	outputContent(warn, ...)
end

function Debug.pcall(...)
	local success, result = pcall(...)

	if success then
		return result
	end

	Debug.warn(result)
	return false
end

function Debug.Get()
	return Debug.print, Debug.warn
end

function Debug.Part(position, size, p, value)
	local part = Instance.new("Part")
	part.Transparency = 0.5
	part.Color = p or Color3.new(1, 0, 0)
	part.Size = size
	part.CFrame = typeof(position) == "CFrame" and position or CFrame.new(position)
	part.CanCollide = false
	part.Anchored = true
	part.Name = "DamagedPart"
	part.Parent = workspace
	task.defer(function()
		task.wait(value or 1)
		part:Destroy()
	end)
	return part
end

function Debug.Line(p, p2, value, p3, value2)
	local v = value or 0.1
	local part = Instance.new("Part")
	part.Transparency = 0.5
	part.Color = p3 or Color3.new(1, 0, 0)
	part.Size = Vector3.new(v, v, (p - p2).Magnitude)
	part.CFrame = CFrame.new((p + p2) / 2, p2)
	part.CanCollide = false
	part.Anchored = true
	part.Name = "DamagedPart"
	part.Parent = workspace
	task.defer(function()
		task.wait(value2 or 1)
		part:Destroy()
	end)
	return part
end

return Debug