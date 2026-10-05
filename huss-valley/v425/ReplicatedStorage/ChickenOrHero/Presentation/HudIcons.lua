return {
	draw = function(parent, p, p2)
		local frame = Instance.new("Frame")
		frame.Name = "Icon"
		frame.Size = UDim2.fromOffset(24, 24)
		frame.BackgroundTransparency = 1
		frame.Parent = parent

		local function line(p3, p4, p5, p6, value)
			local frame2 = Instance.new("Frame")
			frame2.BorderSizePixel = 0
			frame2.BackgroundColor3 = p2
			frame2.Position = UDim2.fromOffset(p3, p4)
			frame2.Size = UDim2.fromOffset(p5, p6)
			frame2.Rotation = value or 0
			frame2.Parent = frame
			return frame2
		end

		local function outline(p3, p4, p5, p6, p7)
			local frame2 = Instance.new("Frame")
			frame2.BorderSizePixel = 0
			frame2.BackgroundColor3 = p2
			frame2.Position = UDim2.fromOffset(p3, p4)
			frame2.Size = UDim2.fromOffset(p5, p6)
			frame2.Rotation = 0
			frame2.Parent = frame
			frame2.BackgroundTransparency = 1
			local uIStroke = Instance.new("UIStroke")
			uIStroke.Color = p2
			uIStroke.Thickness = 1.5
			uIStroke.Parent = frame2

			if p7 then
				local uICorner = Instance.new("UICorner")
				uICorner.CornerRadius = UDim.new(0, p7)
				uICorner.Parent = frame2
			end

			return frame2
		end

		if p == "Shop" then
			outline(4, 8, 16, 13, 2)
			outline(8, 3, 8, 9, 4)
			local frame2 = Instance.new("Frame")
			frame2.BorderSizePixel = 0
			frame2.BackgroundColor3 = p2
			frame2.Position = UDim2.fromOffset(6, 8)
			frame2.Size = UDim2.fromOffset(12, 2)
			frame2.Rotation = 0
			frame2.Parent = frame
			return frame
		elseif p == "Inventory" then
			local frame2 = Instance.new("Frame")
			frame2.BorderSizePixel = 0
			frame2.BackgroundColor3 = p2
			frame2.Position = UDim2.fromOffset(11, 1)
			frame2.Size = UDim2.fromOffset(5, 14)
			frame2.Rotation = 35
			frame2.Parent = frame
			local frame3 = Instance.new("Frame")
			frame3.BorderSizePixel = 0
			frame3.BackgroundColor3 = p2
			frame3.Position = UDim2.fromOffset(5, 13)
			frame3.Size = UDim2.fromOffset(13, 2)
			frame3.Rotation = 35
			frame3.Parent = frame
			local frame4 = Instance.new("Frame")
			frame4.BorderSizePixel = 0
			frame4.BackgroundColor3 = p2
			frame4.Position = UDim2.fromOffset(6, 16)
			frame4.Size = UDim2.fromOffset(3, 7)
			frame4.Rotation = 35
			frame4.Parent = frame
			return frame
		elseif p == "Spectate" then
			outline(2, 6, 20, 12, 8)
			outline(9, 9, 6, 6, 4)
			return frame
		elseif p == "Journey" then
			local frame2 = Instance.new("Frame")
			frame2.BorderSizePixel = 0
			frame2.BackgroundColor3 = p2
			frame2.Position = UDim2.fromOffset(6, 6)
			frame2.Size = UDim2.fromOffset(2, 13)
			frame2.Rotation = 0
			frame2.Parent = frame
			local frame3 = Instance.new("Frame")
			frame3.BorderSizePixel = 0
			frame3.BackgroundColor3 = p2
			frame3.Position = UDim2.fromOffset(7, 18)
			frame3.Size = UDim2.fromOffset(11, 2)
			frame3.Rotation = 0
			frame3.Parent = frame
			outline(3, 2, 8, 8, 2)
			outline(15, 15, 7, 7, 2)
			return frame
		elseif p == "AFK" then
			local frame2 = Instance.new("Frame")
			frame2.BorderSizePixel = 0
			frame2.BackgroundColor3 = p2
			frame2.Position = UDim2.fromOffset(6, 4)
			frame2.Size = UDim2.fromOffset(4, 16)
			frame2.Rotation = 0
			frame2.Parent = frame
			local frame3 = Instance.new("Frame")
			frame3.BorderSizePixel = 0
			frame3.BackgroundColor3 = p2
			frame3.Position = UDim2.fromOffset(14, 4)
			frame3.Size = UDim2.fromOffset(4, 16)
			frame3.Rotation = 0
			frame3.Parent = frame
			return frame
		elseif p == "Settings" then
			for _, v in {
				{ 5, 7 },
				{ 12, 16 },
				{ 19, 9 }
			} do
				local v2 = v[1]
				local frame2 = Instance.new("Frame")
				frame2.BorderSizePixel = 0
				frame2.BackgroundColor3 = p2
				frame2.Position = UDim2.fromOffset(v2, 3)
				frame2.Size = UDim2.fromOffset(1, 18)
				frame2.Rotation = 0
				frame2.Parent = frame
				outline(v[1] - 2, v[2], 5, 4, 1)
			end

			return frame
		elseif p == "Music" then
			local frame2 = Instance.new("Frame")
			frame2.BorderSizePixel = 0
			frame2.BackgroundColor3 = p2
			frame2.Position = UDim2.fromOffset(9, 4)
			frame2.Size = UDim2.fromOffset(2, 14)
			frame2.Rotation = 0
			frame2.Parent = frame
			local frame3 = Instance.new("Frame")
			frame3.BorderSizePixel = 0
			frame3.BackgroundColor3 = p2
			frame3.Position = UDim2.fromOffset(18, 2)
			frame3.Size = UDim2.fromOffset(2, 14)
			frame3.Rotation = 0
			frame3.Parent = frame
			local frame4 = Instance.new("Frame")
			frame4.BorderSizePixel = 0
			frame4.BackgroundColor3 = p2
			frame4.Position = UDim2.fromOffset(9, 3)
			frame4.Size = UDim2.fromOffset(11, 2)
			frame4.Rotation = -10
			frame4.Parent = frame
			outline(3, 15, 7, 5, 3)
			outline(12, 13, 7, 5, 3)
			return frame
		elseif p == "Servers" then
			for _, v in { 3, 13 } do
				outline(2, v, 20, 7, 1)
				local v2 = v + 3
				local frame2 = Instance.new("Frame")
				frame2.BorderSizePixel = 0
				frame2.BackgroundColor3 = p2
				frame2.Position = UDim2.fromOffset(5, v2)
				frame2.Size = UDim2.fromOffset(2, 2)
				frame2.Rotation = 0
				frame2.Parent = frame
				local v3 = v + 3
				local frame3 = Instance.new("Frame")
				frame3.BorderSizePixel = 0
				frame3.BackgroundColor3 = p2
				frame3.Position = UDim2.fromOffset(10, v3)
				frame3.Size = UDim2.fromOffset(8, 1)
				frame3.Rotation = 0
				frame3.Parent = frame
			end

			return frame
		elseif p == "Updates" then
			outline(4, 2, 16, 20, 1)
			local frame2 = Instance.new("Frame")
			frame2.BorderSizePixel = 0
			frame2.BackgroundColor3 = p2
			frame2.Position = UDim2.fromOffset(7, 6)
			frame2.Size = UDim2.fromOffset(10, 2)
			frame2.Rotation = 0
			frame2.Parent = frame

			for _, v in { 11, 15, 18 } do
				local frame3 = Instance.new("Frame")
				frame3.BorderSizePixel = 0
				frame3.BackgroundColor3 = p2
				frame3.Position = UDim2.fromOffset(7, v)
				frame3.Size = UDim2.fromOffset(10, 1)
				frame3.Rotation = 0
				frame3.Parent = frame
			end

			return frame
		elseif p == "Coins" then
			outline(3, 3, 18, 18, 12)
			outline(7, 7, 10, 10, 6)
			local frame2 = Instance.new("Frame")
			frame2.BorderSizePixel = 0
			frame2.BackgroundColor3 = p2
			frame2.Position = UDim2.fromOffset(11, 7)
			frame2.Size = UDim2.fromOffset(2, 10)
			frame2.Rotation = 0
			frame2.Parent = frame
			return frame
		else
			if p ~= "Gems" then
				return frame
			end

			local outline_2 = outline(5, 5, 14, 14, 1)
			outline_2.Rotation = 45
			local frame2 = Instance.new("Frame")
			frame2.BorderSizePixel = 0
			frame2.BackgroundColor3 = p2
			frame2.Position = UDim2.fromOffset(11, 4)
			frame2.Size = UDim2.fromOffset(1, 17)
			frame2.Rotation = 0
			frame2.Parent = frame
			local frame3 = Instance.new("Frame")
			frame3.BorderSizePixel = 0
			frame3.BackgroundColor3 = p2
			frame3.Position = UDim2.fromOffset(5, 11)
			frame3.Size = UDim2.fromOffset(14, 1)
			frame3.Rotation = 0
			frame3.Parent = frame
			return frame
		end
	end
}