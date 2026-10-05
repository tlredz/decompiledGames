local Sync = {}
local import = _G.import("global")
local import2 = _G.import("event")
local import3 = _G.import("dictUtil")
local v = nil
local RunService = game:GetService("RunService")

local function processShared(p, p2, playerSave, playerSession, ...)
	v = v or _G.import("processCollection")
	local v2 = v:get(p2)

	if not v2 then
		error("No Shared process named " .. p2)
	end

	local v3 = { v2(p, playerSave, playerSession, ...) }
	return table.remove(v3, 1), v3
end

if RunService:IsServer() then
	function Sync.server(p, p2, ...)
		import2.fire(p2, p, ...)
	end

	function Sync.listen(p, callback)
		local function fn(p2, ...)
			os.clock()
			local v2, v3 = processShared(
				p2,
				p,
				import.get("playerSave", p2),
				import.get("playerSession", p2),
				unpack({ ... })
			)

			if v2 ~= true then
				return false, v2, unpack(v3)
			end

			if not callback then
				return true
			end

			local v4 = callback and { callback(unpack(v3)) }

			if v4 then
				return true, unpack(v4)
			end
		end

		import2.remoteConnect(p, fn, {
			Returning = true
		})
		import2.connect(p, fn, {
			Returning = true
		})
	end
else
	function Sync.request(p, callback, callback2, callback3, p2, p3)
		return function(...)
			local localPlayer = game.Players.LocalPlayer
			local v2 = { ... }
			local v3, v4 = processShared(
				localPlayer,
				p,
				import.get("playerSave", localPlayer),
				import.get("playerSession", localPlayer),
				...
			)

			if v3 == true then
				task.spawn(function()
					local arrayMerge = import3.arrayMerge(v2, p2 and v4 or {})
					local v5 = { import2[p3 and "fastFire" or "remoteFire"](p, unpack(arrayMerge)) }

					if table.remove(v5, 1) == true then
						if callback3 then
							callback3(unpack(v5))
						end
					elseif callback2 then
						callback2(unpack(v5))
					end
				end)

				if callback then
					callback(unpack(v4))
					return true
				end
			elseif v3 ~= nil and callback2 then
				callback2(v3, unpack(v4))
			end

			return v3
		end
	end
end

function Sync.common(p, p2, ...)
	local v2, v3 = processShared(p, p2, import.get("playerSave", p), import.get("playerSession", p), ...)
	return v2, unpack(v3)
end

return Sync