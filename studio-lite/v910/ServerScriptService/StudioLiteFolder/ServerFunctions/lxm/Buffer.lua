require(script.Parent.Types)

local function Buffer(source, p)
	return {
		Offset = 0,
		Source = source,
		Length = string.len(source),
		IsFinished = false,
		LastUnreadBytes = 0,
		AllowOverflows = p or true,
		read = function(self, value2: number?, flag: boolean?)
			local v = value2 or 1
			local v2 = flag == nil or flag
			local v3 = string.sub(self.Source, self.Offset + 1, self.Offset + v)
			local lastUnreadBytes = v - string.len(v3)

			if lastUnreadBytes > 0 and not self.AllowOverflows then
				error("Buffer went out of bounds and AllowOverflows is false")
			end

			if v2 then
				self:seek(v)
			end

			self.LastUnreadBytes = lastUnreadBytes
			return v3
		end,
		seek = function(self, value2: number)
			self.Offset = math.clamp(self.Offset + (value2 or 1), 0, self.Length)
			self.IsFinished = self.Offset >= self.Length
		end,
		append = function(self, p2: string)
			self.Source ..= p2
			self.Length = string.len(self.Source)
			self:seek(0)
		end,
		toEnd = function(self)
			self:seek(self.Length)
		end,
		readNumber = function(self, value2: string?, flag: boolean?)
			local v = value2 or "I1"
			local v2 = string.packsize(v)
			local v3 = self:read(v2, flag)

			if #v3 < v2 then
				print("SL_ lxm.Buffer Stream.readNumber chunk size:", #v3, "fmt:", v, "packsize:", v2)
				return 1
			else
				return (string.unpack(v, v3))
			end
		end,
		readByte = function(self, flag: boolean?)
			return string.byte(self:read(1, flag))
		end
	}
end

return Buffer