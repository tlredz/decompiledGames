local HttpService = game:GetService("HttpService")

function base64Encode(value)
	local count = #value
	local total = 1
	local v = {}

	while total <= count do
		local v2 = value:byte(total) or 0
		local v3 = value:byte(total + 1) or 0
		local v4 = value:byte(total + 2) or 0
		local v5 = v2 * 65536 + v3 * 256 + v4
		local v6 = math.floor(v5 / 262144) % 64 + 1
		local v7 = math.floor(v5 / 4096) % 64 + 1
		local v8 = math.floor(v5 / 64) % 64 + 1
		local v9 = v5 % 64 + 1
		v[#v + 1] = ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"):sub(v6, v6)
		v[#v + 1] = ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"):sub(v7, v7)

		if count < total + 1 then
			v[#v + 1] = "=="
			break
		end

		if count < total + 2 then
			v[#v + 1] = ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"):sub(v8, v8) .. "="
			break
		else
			v[#v + 1] = ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"):sub(v8, v8) .. ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"):sub(
				v9,
				v9
			)
			total += 3
		end
	end

	return table.concat(v)
end

return {
	TriggerClip = function(_, eventId, eventName, options)
		local v = options or {}
		local gameEvent = {
			eventId = eventId,
			eventName = eventName,
			triggerActions = { "SaveClip" },
			clipOptions = {
				duration = v.duration or 30,
				captureDelayMs = v.captureDelayMs
			}
		}

		if v.contextTags and next(v.contextTags) then
			gameEvent.contextTags = v.contextTags
		end

		local v3 = {
			gameEvent = gameEvent,
			universeId = game.GameId
		}
		print("[_MAPIEvent][v1/event/invoke]", base64Encode(HttpService:JSONEncode(v3)))
	end
}