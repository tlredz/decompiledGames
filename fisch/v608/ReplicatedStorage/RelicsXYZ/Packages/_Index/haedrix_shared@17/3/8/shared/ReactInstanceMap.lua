local parent = script.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local LuauPolyfill = require(parent.LuauPolyfill)
local error2 = LuauPolyfill.Error
local inspect = LuauPolyfill.util.inspect
local getComponentName = require(script.Parent.getComponentName)
script:FindFirstAncestor("ReactUtils")
local __DEV__ = ReactGlobals.__DEV__
local SafeFlags = require(parent.SafeFlags)
local v = SafeFlags.createGetFFlag("ReactInstanceMapDisableErrorChecking")()

local function isValidFiber(data)
	return data.tag ~= nil and data.subtreeFlags ~= nil and data.lanes ~= nil and data.childLanes ~= nil
end

local ReactInstanceMap = {
	remove = function(self)
		self._reactInternals = nil
	end
}

if v and not __DEV__ then
	function ReactInstanceMap:get()
		return self._reactInternals
	end
else
	function ReactInstanceMap:get()
		local _reactInternals = self._reactInternals
		local v2

		if _reactInternals.tag == nil or _reactInternals.subtreeFlags == nil or _reactInternals.lanes == nil then
			v2 = false
		else
			v2 = _reactInternals.childLanes ~= nil
		end

		if not v2 then
			error(error2.new("invalid fiber in " .. (getComponentName(self) or "UNNAMED Component") .. " during get from ReactInstanceMap! " .. inspect(_reactInternals)))
			return _reactInternals
		end

		if _reactInternals.alternate == nil then
			return _reactInternals
		end

		local alternate = _reactInternals.alternate
		local v3

		if alternate.tag == nil or alternate.subtreeFlags == nil or alternate.lanes == nil then
			v3 = false
		else
			v3 = alternate.childLanes ~= nil
		end

		if not v3 then
			error(error2.new("invalid alternate fiber (" .. (getComponentName(self) or "UNNAMED alternate") .. ") in " .. (getComponentName(self) or "UNNAMED Component") .. " during get from ReactInstanceMap! " .. inspect(_reactInternals.alternate)))
		end

		return _reactInternals
	end
end

function ReactInstanceMap:has()
	return self._reactInternals ~= nil
end

if v and not __DEV__ then
	function ReactInstanceMap:set(reactInternals)
		self._reactInternals = reactInternals
	end

	return ReactInstanceMap
end

function ReactInstanceMap:set(reactInternals)
	local return_ = reactInternals

	while return_ ~= nil do
		local v2

		if return_.tag == nil or return_.subtreeFlags == nil or return_.lanes == nil then
			v2 = false
		else
			v2 = return_.childLanes ~= nil
		end

		if v2 then
			if return_.alternate ~= nil then
				local alternate = return_.alternate
				local v3

				if alternate.tag == nil or alternate.subtreeFlags == nil or alternate.lanes == nil then
					v3 = false
				else
					v3 = alternate.childLanes ~= nil
				end

				if not v3 then
					local v4 = "invalid alternate fiber (" .. (getComponentName(self) or "UNNAMED alternate") .. ") in " .. (getComponentName(self) or "UNNAMED Component") .. " being set in ReactInstanceMap! " .. inspect(return_.alternate) .. "\n"

					if reactInternals ~= return_ then
						v4 ..= " (from original fiber " .. (getComponentName(self) or "UNNAMED Component") .. ")"
					end

					error(error2.new(v4))
				end
			end
		else
			local v3 = "invalid fiber in " .. (getComponentName(self) or "UNNAMED Component") .. " being set in ReactInstanceMap! " .. inspect(return_) .. "\n"

			if reactInternals ~= return_ then
				v3 ..= " (from original fiber " .. (getComponentName(self) or "UNNAMED Component") .. ")"
			end

			error(error2.new(v3))
		end

		return_ = return_.return_
	end

	self._reactInternals = reactInternals
end

return ReactInstanceMap