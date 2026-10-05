game:GetService("RunService")
local module = require("./PassiveHandler")
local StarshellDrops = {
	Morph = function(p, _, object)
		local reel_bar = object.reel_bar

		if not reel_bar then
			return
		end

		local drops = script:FindFirstChild("Drops")
		local children = drops and drops:GetChildren() or {}

		if #children == 0 then
			warn("StarshellDrops: reel_bar.Drops not found -- is ReelGuiName set to starshellrod?")
			return
		end

		local dropInterval = p.config.DropInterval or 4
		local dropProgress = p.config.DropProgress or 6
		local waveSpeed = p.config.WaveSpeed or 0.4
		local waveWidth = p.config.WaveWidth or 0.1
		local stunDuration = p.config.StunDuration or 1
		local shoreMaxAccel = p.config.ShoreMaxAccel or 10
		local random = object:GetRandom(5151)
		local waveImage = p.config.WaveImage or "rbxassetid://119083331355734"
		local waveImageFlipped = p.config.WaveImageFlipped or "rbxassetid://81587689930722"
		local total = 0
		local v = 1
		local parent = reel_bar:FindFirstChild("Wave")

		if not parent then
			if waveImage then
				parent = Instance.new("ImageLabel")
				parent.Image = waveImage
				parent.BackgroundTransparency = 1
				parent.ScaleType = Enum.ScaleType.Fit
			else
				parent = Instance.new("Frame")
				parent.BackgroundColor3 = Color3.fromRGB(120, 205, 255)
				parent.BackgroundTransparency = 0.55
				parent.BorderSizePixel = 0
				local uICorner = Instance.new("UICorner")
				uICorner.CornerRadius = UDim.new(0, 8)
				uICorner.Parent = parent
			end

			parent.Name = "Wave"
			parent.AnchorPoint = Vector2.new(0.5, 0.5)
			parent.Position = UDim2.fromScale(0, -0.5)
			parent.Size = UDim2.fromScale(waveWidth * 2, 1.4)
			parent.ZIndex = 4
			parent.Parent = reel_bar
			p.reelTrove:Add(parent)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function faceWave()
			if waveImage and parent:IsA("ImageLabel") then
				local v3 = parent
				local image

				if v > 0 then
					image = waveImage
				else
					image = waveImageFlipped
				end

				v3.Image = image
			end
		end

		if waveImage and parent:IsA("ImageLabel") then
			local image

			if v > 0 then
				image = waveImage
			else
				image = waveImageFlipped
			end

			parent.Image = image
		end

		local v3 = {}

		local function removeShell(i: number, flag: boolean)
			local v4 = v3[i]
			table.remove(v3, i)
			v4.landed = false
			local gui = v4.gui
			local icon = gui:FindFirstChild("Icon")

			if icon and icon:IsA("ImageLabel") then
				object.logicTweens:Create(icon, TweenInfo.new(0.25), {
					ImageTransparency = 1
				}):Play()
			end

			object.logicTweens:Create(gui, TweenInfo.new(0.25), {
				Position = UDim2.fromScale(v4.x, flag and -0.65 or -0.25)
			}):Play()
			object:DelayLogic(0.25, function()
				if gui then
					gui:Destroy()
				end
			end)
		end

		task.spawn(function()
			object:WaitUntilReady()

			while reel_bar.Parent do
				object:WaitLogic(dropInterval * random:NextNumber(0.5, 1.5))

				if not reel_bar.Parent then
					break
				end

				if not object.active then
					continue
				end

				local clone = children[random:NextInteger(1, #children)]:Clone()
				clone.AnchorPoint = Vector2.new(0.5, 0.5)
				local v4 = clone.Size.X.Scale * 0.5
				local fishPosition = object.fishPosition
				local v5 = object.barSize + 0.3
				local v6 = math.clamp(random:NextNumber(fishPosition - v5, fishPosition + v5), v4, 1 - v4)
				clone.Position = UDim2.fromScale(v6, -18.25)
				clone.Visible = true
				clone.Parent = reel_bar
				p.reelTrove:Add(clone)
				local v7 = {
					gui = clone,
					x = v6,
					landed = false
				}
				table.insert(v3, v7)
				local icon = clone:FindFirstChild("Icon")

				if icon and icon:IsA("ImageLabel") then
					icon.ImageTransparency = 1
					object.logicTweens:Create(icon, TweenInfo.new(0.48), {
						ImageTransparency = 0
					}):Play()
				end

				local v8 = object.logicTweens:Create(
					clone,
					TweenInfo.new(1.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Position = UDim2.fromScale(v6, -0.25)
					}
				)
				v8.Completed:Once(function()
					v7.landed = true
				end)
				v8:Play()
			end
		end)
		local flag = false
		local v4 = 0
		local v5 = 0
		local rod = object.core and object.core.rod
		local maxAcceleration = not rod and 1e999 or rod.MaxAcceleration or 1e999
		local fish = object.core and object.core.fish

		-- equivalent calls inferred from this helper; original call sites unknown
		local function fishHalfWidth()
			local fish2 = reel_bar:FindFirstChild("fish")

			if fish2 then
				return fish2.AbsoluteSize.X / math.max(reel_bar.AbsoluteSize.X, 1) * 0.5
			end

			return 0.03
		end

		p.reelTrove:Add(function()
			if rod then
				rod.MaxAcceleration = maxAcceleration
			end

			if fish then
				fish.MovementBehaviorEnabled = true
			end
		end)
		p.reelTrove:Add(object.OnLogicStep:Connect(function(p2)
			if not object.active then
				return
			end

			local now = os.clock()
			total += v * waveSpeed * p2

			if total >= 1 then
				total = 1
				v = -1
				faceWave() -- equivalent call inferred; original call site unknown
			elseif total <= 0 then
				total = 0
				v = 1
				faceWave() -- equivalent call inferred; original call site unknown
			end

			parent.Position = UDim2.fromScale(total, -0.5)
			local fishPosition = object.fishPosition
			local v7 = fishHalfWidth() -- equivalent call inferred; original call site unknown

			for i = #v3, 1, -1 do
				local v8 = v3[i]

				if not v8.landed then
					continue
				end

				local v9 = v8.gui.Size.X.Scale * 0.5

				if object:IsInBar(v8.x, v9) then
					object:AddProgress(dropProgress)
					object.fx:SpawnShake(object.reel_bar, 0.2, 1.8, 0.01, true)
					removeShell(i, true)
				elseif math.abs(total - v8.x) <= waveWidth + v9 then
					removeShell(i, false)
				end
			end

			if rod then
				local v9 = rod
				local maxAcceleration2

				if math.abs(object.barPosition - total) <= waveWidth + object.barSize * 0.5 then
					maxAcceleration2 = shoreMaxAccel
				else
					maxAcceleration2 = maxAcceleration
				end

				v9.MaxAcceleration = maxAcceleration2
			end

			if fish then
				if flag then
					if v4 <= now then
						flag = false
						fish.MovementBehaviorEnabled = true
						v5 = now + 4
					end
				elseif v5 <= now and math.abs(fishPosition - total) <= waveWidth + v7 then
					flag = true
					v4 = now + stunDuration
					local v8 = v > 0 and 1 or -1
					local v9 = v8 > 0 and 0.85 or 0.15
					fish.MovementBehaviorEnabled = false
					fish:ForceMoveTo(v9, 0.5, v8 * 0.8)
					object.fx:SpawnShake(object.reel_bar, 0.2, 1.5, 0.01, true)
				end
			end
		end))
	end
}
setmetatable(StarshellDrops, module)
return StarshellDrops