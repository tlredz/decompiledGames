local Buffer = require(script.Parent.Buffer)

local function lz4(p: string)
	local buffer = Buffer(p)
	local v2 = string.unpack("<I4", buffer:read(4))
	local v3 = string.unpack("<I4", buffer:read(4))

	if string.unpack("<I4", buffer:read(4)) ~= 0 then
		error("provided chunk is not lz4 data")
	end

	if v2 == 0 then
		return buffer:read(v3)
	end

	local buffer2 = Buffer("")
	local lastTime = tick()
	local v5 = 1

	while true do
		local v6 = string.byte(buffer:read())
		local v7 = bit32.rshift(v6, 4)
		local v8 = bit32.band(v6, 15) + 4

		if v7 >= 15 then
			repeat
				local v9 = string.byte(buffer:read())
				v7 += v9
			until v9 ~= 255
		end

		buffer2:append((buffer:read(v7)))
		buffer2:toEnd()

		if tick() - lastTime > 2 then
			lastTime = tick()
			print("Extracting", v5)
			v5 += 1
			task.wait()
		end

		if buffer2.Length < v3 then
			local v9 = string.unpack("<I2", buffer:read(2))

			if v8 >= 19 then
				repeat
					local v10 = string.byte(buffer:read())
					v8 += v10
				until v10 ~= 255
			end

			buffer2:seek(-v9)
			local offset = buffer2.Offset
			local v10 = buffer2:read(v8)
			local lastUnreadBytes = buffer2.LastUnreadBytes

			if lastUnreadBytes then
				repeat
					buffer2.Offset = offset
					local v11 = buffer2:read(lastUnreadBytes)
					lastUnreadBytes = buffer2.LastUnreadBytes
					v10 ..= v11

					if tick() - lastTime > 2 then
						lastTime = tick()
						print("Extracting unread", v5, lastUnreadBytes)
						v5 += 1
						task.wait()
					end
				until lastUnreadBytes <= 0
			end

			buffer2:append(v10)
			buffer2:toEnd()
		end

		if v3 <= buffer2.Length then
			return buffer2.Source
		end
	end
end

return lz4