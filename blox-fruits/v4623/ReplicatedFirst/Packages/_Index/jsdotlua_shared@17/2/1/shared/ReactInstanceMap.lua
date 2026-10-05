local luaupolyfill = require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local error2 = luaupolyfill.Error
local inspect = luaupolyfill.util.inspect
local getComponentName = require(script.Parent:WaitForChild("getComponentName"))

local function isValidFiber(data)
	return data.tag ~= nil and data.subtreeFlags ~= nil and data.lanes ~= nil and data.childLanes ~= nil
end

local ReactInstanceMap = {}

function ReactInstanceMap:remove()
	self._reactInternals = nil
end

function ReactInstanceMap:get()
	local _reactInternals = self._reactInternals
	local v

	if _reactInternals.tag == nil or _reactInternals.subtreeFlags == nil or _reactInternals.lanes == nil then
		v = false
	else
		v = _reactInternals.childLanes ~= nil
	end

	if not v then
		error(error2.new("invalid fiber in " .. (getComponentName(self) or "UNNAMED Component") .. " during get from ReactInstanceMap! " .. inspect(_reactInternals)))
		return _reactInternals
	end

	if _reactInternals.alternate == nil then
		return _reactInternals
	end

	local alternate = _reactInternals.alternate
	local v2

	if alternate.tag == nil or alternate.subtreeFlags == nil or alternate.lanes == nil then
		v2 = false
	else
		v2 = alternate.childLanes ~= nil
	end

	if not v2 then
		error(error2.new("invalid alternate fiber (" .. (getComponentName(self) or "UNNAMED alternate") .. ") in " .. (getComponentName(self) or "UNNAMED Component") .. " during get from ReactInstanceMap! " .. inspect(_reactInternals.alternate)))
	end

	return _reactInternals
end

function ReactInstanceMap:has()
	return self._reactInternals ~= nil
end

function ReactInstanceMap:set(reactInternals)
	local return_ = reactInternals

	while return_ ~= nil do
		local v

		if return_.tag == nil or return_.subtreeFlags == nil or return_.lanes == nil then
			v = false
		else
			v = return_.childLanes ~= nil
		end

		if v then
			if return_.alternate ~= nil then
				local alternate = return_.alternate
				local v2

				if alternate.tag == nil or alternate.subtreeFlags == nil or alternate.lanes == nil then
					v2 = false
				else
					v2 = alternate.childLanes ~= nil
				end

				if not v2 then
					local v3 = "invalid alternate fiber (" .. (getComponentName(self) or "UNNAMED alternate") .. ") in " .. (getComponentName(self) or "UNNAMED Component") .. " being set in ReactInstanceMap! " .. inspect(return_.alternate) .. "\n"

					if reactInternals ~= return_ then
						v3 ..= " (from original fiber " .. (getComponentName(self) or "UNNAMED Component") .. ")"
					end

					error(error2.new(v3))
				end
			end
		else
			local v2 = "invalid fiber in " .. (getComponentName(self) or "UNNAMED Component") .. " being set in ReactInstanceMap! " .. inspect(return_) .. "\n"

			if reactInternals ~= return_ then
				v2 ..= " (from original fiber " .. (getComponentName(self) or "UNNAMED Component") .. ")"
			end

			error(error2.new(v2))
		end

		return_ = return_.return_
	end

	self._reactInternals = reactInternals
end

return ReactInstanceMap