local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local create = Vide.create
local color = Color3.fromRGB(255, 226, 70)
local color2 = Color3.fromRGB(255, 214, 120)
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 235, 82), Color3.fromRGB(235, 164, 24))
local colorSequence2 = ColorSequence.new(Color3.fromRGB(255, 220, 90), Color3.fromRGB(224, 125, 24))
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy)
local rbxassetfontsfamiliesGothamSSmjson2 = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
return {
	mount = function(playerGui)
		local source = Vide.source(false)
		local source2 = Vide.source(2)
		local source3 = Vide.source("ROLLING...")
		local source4 = Vide.source(color)
		local source5 = Vide.source(1)
		local count = 0
		local v = nil
		local isA = playerGui:IsA("PlayerGui")
		local v2 = Vide.mount(function()
			local v3 = create(isA and "ScreenGui" or "Frame")
			local v4 = {
				Name = "LuckyMinuteReveal",
				DisplayOrder = isA and 28800 or nil,
				IgnoreGuiInset = not isA and nil,
				ResetOnSpawn = not isA and nil
			}
			local size

			if not isA then
				size = UDim2.fromScale(1, 1)
			end

			v4.Size = size
			v4.BackgroundTransparency = not isA and 1 or nil
			v4.Enabled = isA and function()
				return source()
			end or nil
			v4.Visible = not isA and function()
				return source()
			end or nil
			do local _values = table.pack(Vide.action(function(p)
	v = p
end), create("Frame")({
	Name = "Shadow",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 4, 0.14, 6),
	Size = UDim2.fromOffset(340, 104),
	BackgroundColor3 = Color3.fromRGB(72, 48, 12),
	BackgroundTransparency = 0.35,
	BorderSizePixel = 0,
	create("UICorner")({
		CornerRadius = UDim.new(0.14, 0)
	})
}), create("Frame")({
	Name = "Card",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0.14, 0),
	Size = UDim2.fromOffset(340, 104),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderSizePixel = 0,
	create("UIScale")({
		Scale = function()
			return source5()
		end
	}),
	create("UICorner")({
		CornerRadius = UDim.new(0.14, 0)
	}),
	create("UIStroke")({
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = Color3.new(1, 1, 1),
		Thickness = 0.02,
		StrokeSizingMode = 1
	}),
	create("UIGradient")({
		Color = function()
			if source4() == color2 then
				return colorSequence2
			end

			return colorSequence
		end,
		Rotation = 90
	}),
	create("TextLabel")({
		Position = UDim2.fromScale(0.05, 0.07),
		Size = UDim2.fromScale(0.9, 0.21),
		BackgroundTransparency = 1,
		FontFace = rbxassetfontsfamiliesGothamSSmjson,
		Text = "LUCKY MINUTE",
		TextColor3 = color2,
		TextScaled = true,
		create("UIStroke")({
			Color = Color3.fromRGB(91, 57, 8),
			Thickness = 0.05,
			StrokeSizingMode = 1
		})
	}),
	create("TextLabel")({
		Position = UDim2.fromScale(0.05, 0.27),
		Size = UDim2.fromScale(0.9, 0.48),
		BackgroundTransparency = 1,
		FontFace = rbxassetfontsfamiliesGothamSSmjson,
		Text = function()
			return (`x{source2()} XP`)
		end,
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
		create("UIStroke")({
			Color = Color3.fromRGB(20, 20, 20),
			Thickness = 0.055,
			StrokeSizingMode = 1
		})
	}),
	create("TextLabel")({
		Position = UDim2.fromScale(0.08, 0.76),
		Size = UDim2.fromScale(0.84, 0.17),
		BackgroundTransparency = 1,
		FontFace = rbxassetfontsfamiliesGothamSSmjson2,
		Text = function()
			return source3()
		end,
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
		create("UIStroke")({
			Color = Color3.fromRGB(20, 20, 20),
			Thickness = 0.045,
			StrokeSizingMode = 1
		})
	})
})); for _k = 1, _values.n do v4[_k] = _values[_k] end end
			return v3(v4)
		end, playerGui)
		return {
			reveal = function(p: number, p2: number, p3: number, p4: number)
				count += 1
				local v3 = count
				source(true)
				source3("ROLLING YOUR XP BOOST...")
				source4(color)
				source5(1)
				task.spawn(function()
					local lastTime = os.clock()

					while count == v3 and os.clock() - lastTime < p3 do
						local v4 = math.clamp((os.clock() - lastTime) / p3, 0, 1)
						source2(math.random(2, 100))
						source5(source5() > 1 and 0.995 or 1.015)
						task.wait(v4 * v4 * 0.18 + 0.045)
					end

					if count == v3 then
						source2(p)
						source5(1.12)
						local formatted = `{math.max(1, (math.ceil(p2)))} SECONDS`
						local v5

						if p >= 76 then
							v5 = `JACKPOT! ACTIVE FOR {formatted}`
						else
							v5 = `ACTIVE FOR {formatted}`
						end

						source3(v5)
						local v7

						if p >= 76 then
							v7 = color2
						else
							v7 = color
						end

						source4(v7)
						task.wait(0.1)
						source5(0.97)
						task.wait(0.08)
						source5(1.035)
						task.wait(0.08)
						source5(1)
						task.wait((math.max(0, p4 - 0.26)))

						if count == v3 then
							source(false)
						end
					end
				end)
			end,
			destroy = function()
				count += 1
				v2()

				if v then
					v:Destroy()
					v = nil
				end
			end
		}
	end
}