local v = {
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g"
}
local v2 = {
	[0] = {
		1,
		1,
		1,
		1,
		1,
		1,
		0
	},
	[1] = {
		0,
		1,
		1,
		0,
		0,
		0,
		0
	},
	[2] = {
		1,
		1,
		0,
		1,
		1,
		0,
		1
	},
	[3] = {
		1,
		1,
		1,
		1,
		0,
		0,
		1
	},
	[4] = {
		0,
		1,
		1,
		0,
		0,
		1,
		1
	},
	[5] = {
		1,
		0,
		1,
		1,
		0,
		1,
		1
	},
	[6] = {
		1,
		0,
		1,
		1,
		1,
		1,
		1
	},
	[7] = {
		1,
		1,
		1,
		0,
		0,
		0,
		0
	},
	[8] = {
		1,
		1,
		1,
		1,
		1,
		1,
		1
	},
	[9] = {
		1,
		1,
		1,
		1,
		0,
		1,
		1
	}
}

local function applyDigitToFrame(digitFrame, p: number)
	if p == nil then
		for _, childName in pairs(v) do
			local child = digitFrame:FindFirstChild(childName)

			if child then
				child.Visible = false
			end
		end
	else
		local v3 = v2[p]

		if not v3 then
			return
		end

		for i, childName in ipairs(v) do
			local child = digitFrame:FindFirstChild(childName)

			if child then
				child.Visible = v3[i] == 1
			end
		end
	end
end

return {
	new = function(self)
		local frames = {}

		for _, frame in ipairs(self:GetChildren()) do
			if frame:IsA("Frame") and tonumber(frame.Name) then
				table.insert(frames, frame)
			end
		end

		table.sort(frames, function(a, b)
			return a.Name < b.Name
		end)
		local v3 = {
			digitFrames = frames
		}
		local _0 = self:FindFirstChild("0")
		local _02 = self.Display.DigitBackground:FindFirstChild("0")
		local overtimeTL = self.Parent:FindFirstChild("OvertimeTL")

		if _0 and _02 then
			_0.Visible = false
			_02.Visible = false
		end

		function v3.setNumber(p, p2: number)
			local v4 = tostring((math.floor(p2)))

			if #v4 > 6 then
				if overtimeTL then
					local v5 = tonumber(v4:sub(1, -5)) or 0
					overtimeTL.Text = string.format("%d DAYS", v5 // 24)
					overtimeTL.Visible = true
					self.Visible = false
				else
					v4 = "995959"
				end
			elseif overtimeTL then
				overtimeTL.Visible = false
				self.Visible = true
			end

			local count = #p.digitFrames
			local v5 = {}

			for i = 1, count do
				local v6 = #v4 - (count - i)
				local v7

				if v6 >= 1 then
					v7 = tonumber(v4:sub(v6, v6)) or nil
				end

				v5[i] = v7
			end

			for i, digitFrame in ipairs(p.digitFrames) do
				applyDigitToFrame(digitFrame, v5[i])
			end
		end

		return v3
	end
}