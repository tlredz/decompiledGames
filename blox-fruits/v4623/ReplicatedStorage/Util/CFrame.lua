local cFrame = CFrame
local CFrame_2 = {}

function CFrame_2.new(...)
	local v = cFrame.new(...)
	local v2

	if v == v then
		v2 = v
	else
		v2 = cFrame.new(v.Position)
	end

	if v2.Position.Magnitude > 1e20 then
		local v3 = ({ ... })[1]

		if typeof(v3) == "Vector3" then
			v2 = cFrame.new(v3)
		else
			local v4, v5, v6 = ...
			v2 = cFrame.new(v4, v5, v6)
		end
	end

	if v ~= v2 then
		local v3, v4, _, _ = debug.info(2, "lsfn")
		local TestService = game:GetService("TestService")
		TestService:Error((`{v4}:{v3}: Malformed CFrame created.`))
	end

	return v2
end

function CFrame_2.lookAt(p, p2, p3)
	local lookAt = cFrame.lookAt(p, p2, p3)
	local v

	if lookAt == lookAt then
		v = lookAt
	else
		v = cFrame.new(lookAt.Position)
	end

	if v.Position.Magnitude > 1e20 then
		v = cFrame.new(p)
	end

	if lookAt ~= v then
		local v2, v3, _, _ = debug.info(2, "lsfn")
		local TestService = game:GetService("TestService")
		TestService:Error((`{v3}:{v2}: Malformed CFrame created.`))
	end

	return v
end

return CFrame_2