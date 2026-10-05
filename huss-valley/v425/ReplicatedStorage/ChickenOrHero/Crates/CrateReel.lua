local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
return {
	new = function(instance, data, p, p2, p3, callback)
		local v = {
			generation = 0,
			sounds = {},
			tweens = {},
			timers = {}
		}
		local random = Random.new()

		function v.cancel(_)
			v.generation += 1

			if v.connection then
				v.connection:Disconnect()
				v.connection = nil
			end

			for _, sound in v.sounds do
				sound:Destroy()
			end

			for _, tween in v.tweens do
				tween:Cancel()
			end

			for k in v.timers do
				task.cancel(k)
			end

			table.clear(v.timers)
			table.clear(v.sounds)
			table.clear(v.tweens)
			instance:ClearAllChildren()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function later(duration, p4, fn)
			local thread = nil
			thread = task.delay(duration, function()
				v.timers[thread] = nil

				if p4 == v.generation and instance.Parent then
					fn()
				end
			end)
			v.timers[thread] = true
		end

		local function sound(name, p4, volume, value)
			local sound2 = Instance.new("Sound")
			sound2.Name = name
			sound2.SoundId = "rbxassetid://" .. p4
			sound2.Volume = volume
			sound2.PlaybackSpeed = value or 1
			sound2.Parent = SoundService
			table.insert(v.sounds, sound2)
			return sound2
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function animate(p4, duration, p5, p6)
			local tween = TweenService:Create(p4, TweenInfo.new(duration, p5, Enum.EasingDirection.Out), p6)
			table.insert(v.tweens, tween)
			tween:Play()
		end

		function v.play(_, data2, callback2)
			v:cancel()
			local generation = v.generation
			local backgroundColor = p3[(p2.get(data2.skin) or {}).Rarity] or data.Gold
			local v3 = data.make("Frame", instance, "ReelWindow", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.fromRGB(8, 17, 25),
				BorderSizePixel = 0,
				ClipsDescendants = true
			})
			data.corner(v3, 12)
			data.stroke(v3, data.Gold, 0.45)
			local v4 = data.make("Frame", v3, "Strip", {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(6804, 226),
				Position = UDim2.fromOffset(0, 17)
			})
			local v5 = {}

			for i = 1, 42 do
				local v6 = p.pick(data2.crate, random:NextInteger(1, 10000))
				local skin = i == 36 and data2.skin or v6.Skin
				local v7 = p2.get(skin)
				local backgroundColor2 = p3[v7.Rarity] or data.Muted
				local v9 = data.make("Frame", v4, "Card" .. i, {
					Position = UDim2.fromOffset((i - 1) * 162, 0),
					Size = UDim2.fromOffset(150, 226),
					BackgroundColor3 = Color3.new(1, 1, 1),
					BorderSizePixel = 0
				})
				data.corner(v9, 10)
				data.stroke(v9, backgroundColor2, 0.5)
				data.make("UIGradient", v9, "Tint", {
					Color = ColorSequence.new(Color3.fromRGB(35, 53, 65), Color3.fromRGB(13, 23, 34)),
					Rotation = 90
				})
				data.make("Frame", v9, "RarityLine", {
					Position = UDim2.new(0, 0, 1, -5),
					Size = UDim2.new(1, 0, 0, 5),
					BorderSizePixel = 0,
					BackgroundColor3 = backgroundColor2
				})
				callback(data.make("Frame", v9, "Art", {
					Position = UDim2.fromOffset(4, 15),
					Size = UDim2.fromOffset(142, 140),
					BackgroundTransparency = 1
				}), skin)
				local text = data.text(v9, "Name", v7.Name, 8, 159, 134, 36, 14, data.Paper)
				text.Font = Enum.Font.GothamBold
				text.TextXAlignment = Enum.TextXAlignment.Center
				local text_2 = data.text(v9, "Rarity", string.upper(v7.Rarity), 5, 198, 140, 18, 10, backgroundColor2)
				text_2.TextXAlignment = Enum.TextXAlignment.Center
				v5[i] = v9
			end

			local v6 = data.make("Frame", v3, "Pointer", {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.fromOffset(3, 260),
				BackgroundColor3 = data.Gold,
				BackgroundTransparency = 0.15,
				BorderSizePixel = 0,
				ZIndex = 20
			})
			data.make("Frame", v6, "Diamond", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(1, 10),
				Size = UDim2.fromOffset(16, 16),
				Rotation = 45,
				BackgroundColor3 = data.Gold,
				BorderSizePixel = 0,
				ZIndex = 21
			})
			local sound2 = Instance.new("Sound")
			sound2.Name = "CrateTick"
			sound2.SoundId = "rbxassetid://" .. 10128760939
			sound2.Volume = 0.16
			sound2.PlaybackSpeed = 1.3
			sound2.Parent = SoundService
			table.insert(v.sounds, sound2)
			local sound3 = Instance.new("Sound")
			sound3.Name = "CrateOpen"
			sound3.SoundId = "rbxassetid://" .. 10128766965
			sound3.Volume = 0.3
			sound3.PlaybackSpeed = 0.8
			sound3.Parent = SoundService
			table.insert(v.sounds, sound3)
			local sound4 = Instance.new("Sound")
			sound4.Name = "CrateReward"
			sound4.SoundId = "rbxassetid://" .. 82803453482376
			sound4.Volume = 0.42
			sound4.PlaybackSpeed = 1
			sound4.Parent = SoundService
			table.insert(v.sounds, sound4)
			sound3:Play()
			local total = 0
			local v7 = 0
			v.connection = RunService.RenderStepped:Connect(function(dt)
				if generation ~= v.generation then
					return
				end

				total += dt
				local v8 = math.clamp(total / 5.6, 0, 1)
				local v9 = (1 - (1 - v8) ^ 4) * 5346 + 399
				v4.Position = UDim2.new(0.5, -v9, 0, 17)
				local v10 = math.floor((v9 + 6) / 162) + 1

				if v10 == v7 then
					v6.BackgroundTransparency = math.min(0.35, v6.BackgroundTransparency + dt * 3)
				else
					v7 = v10
					sound2.PlaybackSpeed = (1 - v8) * 0.6 + 0.85
					sound2.TimePosition = 0
					sound2:Play()
					v6.BackgroundTransparency = 0
				end

				local halfOffset = instance.Size.X.Offset / 2

				for k, v12 in v5 do
					v12.Visible = math.abs((k - 1) * 162 + 75 - v9) < halfOffset + 162
				end

				if v8 < 1 then
					return
				end

				v.connection:Disconnect()
				v.connection = nil
				sound2.PlaybackSpeed = 0.65
				sound2:Play()
				local v12 = data.make("Frame", v3, "WinFlash", {
					Size = UDim2.fromScale(1, 1),
					BackgroundColor3 = backgroundColor,
					BackgroundTransparency = 0.25,
					BorderSizePixel = 0,
					ZIndex = 22
				})
				local quad = Enum.EasingStyle.Quad
				local tween = TweenService:Create(v12, TweenInfo.new(0.6, quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 1
				})
				table.insert(v.tweens, tween)
				tween:Play()
				animate(v5[36], 0.24, Enum.EasingStyle.Back, {
					BackgroundColor3 = backgroundColor:Lerp(Color3.fromRGB(20, 32, 45), 0.65)
				}) -- equivalent call inferred; original call site unknown

				local function fn()
					v3:Destroy()
					local v16 = data.make("Frame", instance, "RarityBurst", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromOffset(1, 1),
						BackgroundTransparency = 1,
						Rotation = -25
					})

					for i = 1, 16 do
						local v17 = i * 3.141592653589793 / 8
						local v18 = data.make("Frame", v16, "Ray" .. i, {
							AnchorPoint = Vector2.new(0.5, 1),
							Position = UDim2.fromOffset(math.sin(v17) * 28, -math.cos(v17) * 28),
							Size = UDim2.fromOffset(i % 2 == 0 and 18 or 7, 20),
							Rotation = math.deg(v17),
							BackgroundColor3 = backgroundColor,
							BackgroundTransparency = 0.45,
							BorderSizePixel = 0
						})
						data.corner(v18, 8)
						data.make("UIGradient", v18, "Fade", {
							Rotation = 90,
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 1),
								NumberSequenceKeypoint.new(0.5, 0.3),
								NumberSequenceKeypoint.new(1, 0.95)
							})
						})
						animate(v18, 0.75, Enum.EasingStyle.Quart, {
							Size = UDim2.fromOffset(i % 2 == 0 and 18 or 7, i % 2 == 0 and 120 or 145),
							BackgroundTransparency = 0.75
						}) -- equivalent call inferred; original call site unknown
					end

					local sine = Enum.EasingStyle.Sine
					local tween2 = TweenService:Create(v16, TweenInfo.new(2.4, sine, Enum.EasingDirection.Out), {
						Rotation = 35
					})
					table.insert(v.tweens, tween2)
					tween2:Play()

					for i = 1, 2 do
						local v17 = data.make("Frame", instance, "ShockRing" .. i, {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromOffset(30, 30),
							BackgroundTransparency = 1
						})
						data.corner(v17, 999)
						data.stroke(v17, backgroundColor, 0.15)
						v17.Outline.Thickness = i == 1 and 3 or 1
						local quart = Enum.EasingStyle.Quart
						animate(v17, i * 0.2 + 0.6, quart, {
							Size = UDim2.fromOffset(i * 40 + 210, i * 40 + 210)
						}) -- equivalent call inferred; original call site unknown
						local outline = v17.Outline
						local quad2 = Enum.EasingStyle.Quad
						local tween3 = TweenService:Create(outline, TweenInfo.new(1, quad2, Enum.EasingDirection.Out), {
							Transparency = 1
						})
						table.insert(v.tweens, tween3)
						tween3:Play()
					end

					for i = 1, 24 do
						local v17 = i * 3.141592653589793 / 12 + random:NextNumber(-0.1, 0.1)
						local number = random:NextNumber(80, 150)
						animate(data.make("Frame", instance, "Glint" .. i, {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromOffset(3, random:NextInteger(5, 11)),
							Rotation = math.deg(v17),
							BackgroundColor3 = backgroundColor:Lerp(Color3.new(1, 1, 1), 0.3),
							BorderSizePixel = 0
						}), random:NextNumber(0.65, 1.1), Enum.EasingStyle.Quart, {
							Position = UDim2.new(0.5, math.cos(v17) * number, 0.5, math.sin(v17) * number),
							BackgroundTransparency = 1,
							Size = UDim2.fromOffset(1, 1),
							Rotation = math.deg(v17) + 120
						}) -- equivalent call inferred; original call site unknown
					end

					local v17 = data.make("Frame", instance, "WinningKnife", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.15, 0.15),
						BackgroundTransparency = 1,
						Rotation = -70
					})
					local v18 = data.make("Frame", v17, "Halo", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromOffset(180, 180),
						Rotation = 45,
						BackgroundColor3 = backgroundColor,
						BackgroundTransparency = 0.9
					})
					data.corner(v18, 24)
					data.stroke(v18, backgroundColor, 0.45)
					callback(v17, data2.skin)
					sound3.PlaybackSpeed = 1.35
					sound3:Play()
					animate(v17, 0.65, Enum.EasingStyle.Back, {
						Size = UDim2.fromScale(1.12, 1.12),
						Rotation = 4
					}) -- equivalent call inferred; original call site unknown
					local sine2 = Enum.EasingStyle.Sine
					local tween3 = TweenService:Create(v18, TweenInfo.new(1.4, sine2, Enum.EasingDirection.Out), {
						Rotation = 135
					})
					table.insert(v.tweens, tween3)
					tween3:Play()

					local function fn2()
						sound4:Play()
						animate(v17, 0.55, Enum.EasingStyle.Sine, {
							Size = UDim2.fromScale(1, 1),
							Rotation = 0
						}) -- equivalent call inferred; original call site unknown
						local rarity = string.upper((p2.get(data2.skin) or {}).Rarity or "Common")
						local text = data.text(
							instance,
							"RarityStamp",
							data2.duplicate and rarity .. " · COLLECTED" or rarity .. " · UNLOCKED",
							0,
							12,
							instance.Size.X.Offset,
							24,
							13,
							backgroundColor
						)
						text.Font = Enum.Font.GothamBold
						text.TextXAlignment = Enum.TextXAlignment.Center
						text.TextTransparency = 1
						text.ZIndex = 3
						animate(text, 0.3, Enum.EasingStyle.Quart, {
							Position = UDim2.fromOffset(0, 0),
							TextTransparency = 0
						}) -- equivalent call inferred; original call site unknown
						callback2()
					end

					later(0.55, generation, fn2) -- equivalent call inferred; original call site unknown
				end

				later(0.35, generation, fn) -- equivalent call inferred; original call site unknown
			end)
		end

		return v
	end
}