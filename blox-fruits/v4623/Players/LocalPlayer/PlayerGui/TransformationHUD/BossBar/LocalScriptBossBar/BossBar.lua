local Util = require(game.ReplicatedStorage.Util)
local TextUtil = require(game.ReplicatedStorage:WaitForChild("Modules").Util.TextUtil)
local TweenService = game:GetService("TweenService")
local notification = game.ReplicatedStorage.Notification
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local parent = script.Parent.Parent
local uDim = UDim2.new(0.5, 0, -0.2, 0)
local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v = false
local v2 = nil

local function shownPosition()
	return UDim2.new(0.5, 0, 0.06, notification:GetAttribute("Offset") or 0)
end

local function slideBar(p)
	if p == v then
		return
	end

	v = p

	if v2 then
		v2:Cancel()
		v2 = nil
	end

	if p then
		parent.Position = uDim
		parent.Visible = true
		v2 = TweenService:Create(parent, tweenInfo, {
			Position = UDim2.new(0.5, 0, 0.06, notification:GetAttribute("Offset") or 0)
		})
		v2:Play()
	else
		local tween = TweenService:Create(parent, tweenInfo, {
			Position = uDim
		})
		v2 = tween
		tween.Completed:Connect(function()
			if not v and v2 == tween then
				parent.Visible = false
			end
		end)
		tween:Play()
	end
end

parent.Visible = false
local v3 = nil
local enemy = nil
local v5 = nil
local v6 = {}
local v7 = {}
local ratios = {}
local v8 = {}
local BossBar = {
	Changed = Util.Signal2.new()
}
local v9 = {}
local v10 = {}
local v11 = false
local v12 = {
	Health = {
		Color3.fromRGB(39, 202, 28):Lerp(Color3.fromRGB(255, 255, 255), 0.4),
		Color3.fromRGB(39, 202, 28),
		Color3.fromRGB(39, 202, 28):Lerp(Color3.fromRGB(0, 0, 0), 0.3)
	},
	SubHealth = {
		Color3.fromRGB(202, 190, 28):Lerp(Color3.fromRGB(255, 255, 255), 0.4),
		Color3.fromRGB(202, 190, 28),
		Color3.fromRGB(202, 190, 28):Lerp(Color3.fromRGB(0, 0, 0), 0.3)
	},
	Hurt = {
		Color3.fromRGB(135, 41, 43):Lerp(Color3.fromRGB(255, 255, 255), 0.3),
		Color3.fromRGB(135, 41, 43),
		Color3.fromRGB(135, 41, 43):Lerp(Color3.fromRGB(0, 0, 0), 0.3)
	},
	Background = {
		Color3.fromRGB(56, 56, 56):Lerp(Color3.fromRGB(255, 255, 255), 0.2),
		Color3.fromRGB(56, 56, 56),
		Color3.fromRGB(56, 56, 56):Lerp(Color3.fromRGB(0, 0, 0), 0.3)
	},
	Armor = {
		Color3.fromRGB(162, 179, 189):Lerp(Color3.fromRGB(255, 255, 255), 0.5),
		Color3.fromRGB(162, 179, 189),
		Color3.fromRGB(162, 179, 189):Lerp(Color3.fromRGB(0, 0, 0), 0.3)
	}
}
local dropList = script.Parent.Parent.DropList
local dropsTextLabel = script.Parent.Parent.DropsTextLabel
local flag = true

-- equivalent calls inferred from this helper; original call sites unknown
local function clearBossBarDropPreview()
	if flag then
		return
	end

	flag = true
	Effect.new("DropPreview"):play({
		Phase = "ClearBossBar",
		DropList = dropList,
		DropsTextLabel = dropsTextLabel
	})
end

function getEnemies()
	local children = workspace.Enemies:GetChildren()

	for _, child in pairs(workspace.SeaBeasts:GetChildren()) do
		table.insert(children, child)
	end

	return children
end

function getRatio(humanoid)
	if humanoid:IsA("Humanoid") then
		return humanoid.Health / humanoid.MaxHealth, humanoid.Health, humanoid.MaxHealth
	end

	return humanoid.Value / humanoid.MaxValue, humanoid.Value, humanoid.MaxValue
end

function updateRatio(p, p2)
	local ratio, v13, v14 = getRatio(p)
	local v15 = math.round(v13)
	local v16 = math.round(v14)
	p2.TextLabel.Text = TextUtil.commaValue(v15) .. "/" .. TextUtil.commaValue(v16)
	local v17 = ratio - ratios[p2]

	if v17 < 0 then
		local v18 = 0.2 * (1 + v17) + 0.2
		table.insert(v9[p2], {
			v17 / v18,
			v18,
			os.clock(),
			0,
			os.clock() + v18 * 1.5
		})
	else
		v8[p2] += v17
	end

	ratios[p2] = ratio
	updateRender(p2)
end

function updateRender(p, p2)
	if v7[p] and v7[p][1] == ratios[p] and v7[p][2] == v8[p] and not p2 then
		return
	end

	v7[p] = { ratios[p], v8[p] }
	local v13 = ratios[p]
	local v14 = v8[p]
	local v15

	if math.min(v13, 1) >= math.min(v14, 1) or math.sqrt(v14 ^ 2 - v13 ^ 2) <= 0.001 then
		if not (v13 < 0.999) then
			v15 = {
				{ 0, "Health" },
				{ 1, "Health" }
			}
		elseif v13 < 0.001 then
			v15 = {
				{ 0, "Background" },
				{ 1, "Background" }
			}
		else
			v15 = {
				{ 0, "Health" },
				{ v13, "Health" },
				{ v13 + 0.001, "Background" },
				{ 1, "Background" }
			}
		end
	elseif v14 < 0.999 then
		if v13 < 0.001 then
			v15 = {
				{ 0, "Hurt" }
			}
		else
			v15 = {
				{ 0, "Health" },
				{ v13, "Health" }
			}

			if v13 + 0.001 < v14 then
				table.insert(v15, { v13 + 0.001, "Hurt" })
			end
		end

		if not (v14 < 0.001) then
			table.insert(v15, { v14, "Hurt" })
			table.insert(v15, { v14 + 0.001, "Background" })
		end

		table.insert(v15, { 1, "Background" })
	else
		v15 = v13 < 0.999 and {
			{ 0, "Health" },
			{ v13, "Health" },
			{ v13 + 0.001, "Hurt" },
			{ 1, "Hurt" }
		} or {
			{ 0, "Health" },
			{ 1, "Health" }
		}
	end

	local v16 = { "AccentTop", "Fill", "AccentBottom" }

	for i = 1, 3 do
		local colorSequenceKeypoints = {}

		for _, v17 in pairs(v15) do
			if v17[2] == "Health" and v6[p] then
				v17[2] = "Armor"
			elseif v17[2] == "Health" and p.Name == "Subbar" then
				v17[2] = "SubHealth"
			end

			table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(v17[1], v12[v17[2]][i]))
		end

		local v17 = i
		local _, _ = pcall(function()
			p.Bar[v16[v17]].UIGradient.Color = ColorSequence.new(colorSequenceKeypoints)
		end)
	end
end

function HookObject(state, instance)
	if instance and instance:GetAttribute("HealthEnabled") ~= false then
		if state.Name == "Border" and v ~= true then
			v = true

			if v2 then
				v2:Cancel()
				v2 = nil
			end

			parent.Position = uDim
			parent.Visible = true
			v2 = TweenService:Create(parent, tweenInfo, {
				Position = UDim2.new(0.5, 0, 0.06, notification:GetAttribute("Offset") or 0)
			})
			v2:Play()
		end

		if BossBar[state] and BossBar[state].Enemy == instance then
			return
		end

		if BossBar[state] then
			BossBar[state].Maid:DoCleaning()
		end

		local health = instance:FindFirstChild("Health") or instance:FindFirstChildOfClass("Humanoid")

		if not health then
			return
		end

		if state.Name == "Subbar" then
			state.Visible = true
		end

		local maid = Util.Maid.new()
		BossBar[state] = {
			Enemy = instance,
			Maid = maid
		}
		v9[state] = {}
		BossBar.Changed:Fire()

		if v6[state] then
			v6[state]:Cancel()
			v6[state] = nil
		end

		local ratio, _, _ = getRatio(health)
		ratios[state] = ratio
		v8[state] = ratio
		updateRatio(health, state)

		if health:IsA("Humanoid") then
			maid:GiveTask(health:GetPropertyChangedSignal("Health"):Connect(function()
				updateRatio(health, state)

				if health:GetAttribute("HackerHeal") then
				end
			end))
			maid:GiveTask(health:GetPropertyChangedSignal("MaxHealth"):Connect(function()
				updateRatio(health, state)
			end))
			maid:GiveTask(health:GetAttributeChangedSignal("HackerHeal"):Connect(function()
				if health:GetAttribute("HackerHeal") then
					maid.HackerHeal = task.spawn(function()
						local function generateHackerNumber(p: number)
							local now = os.clock()
							local v13 = 1
							local total = 0

							for i = 1, p do
								total += math.floor(math.abs((math.sin(now * (1.7 ^ (i - 1) * 7) + p * 1.618033 + i * 2.399963))) * 10) % 10 * v13
								v13 *= 10
							end

							return total
						end

						while health:GetAttribute("HackerHeal") do
							local v13 = tostring(health.Health):len() + 1
							local v14 = tostring(health.MaxHealth):len() + 2
							updateRatio(health, state)
							state.TextLabel.Text = TextUtil.commaValue((generateHackerNumber(v13))) .. "/" .. TextUtil.commaValue((generateHackerNumber(v14)))
							task.wait()
						end

						updateRatio(health, state)
					end)
				else
					maid.HackerHeal = nil
				end
			end))
		else
			maid:GiveTask(health:GetPropertyChangedSignal("Value"):Connect(function()
				updateRatio(health, state)
			end))
			maid:GiveTask(health:GetPropertyChangedSignal("MaxValue"):Connect(function()
				updateRatio(health, state)
			end))
		end

		if state.Name == "Border" then
			local _ = instance.Name
			local displayName

			if health:IsA("Humanoid") then
				displayName = health.DisplayName or instance.Name
				maid:GiveTask(health:GetPropertyChangedSignal("DisplayName"):Connect(function()
					displayName = health.DisplayName or instance.Name
					script.Parent.Parent.TextLabel.Text = displayName
					script.Parent.Parent.TextLabel.Shadow.Text = displayName
				end))
			else
				displayName = health:GetAttribute("DisplayName") or instance.Name
				maid:GiveTask(health:GetAttributeChangedSignal("DisplayName"):Connect(function()
					displayName = health:GetAttribute("DisplayName") or instance.Name
					script.Parent.Parent.TextLabel.Text = displayName
					script.Parent.Parent.TextLabel.Shadow.Text = displayName
				end))
			end

			maid:GiveTask(health.Parent:GetAttributeChangedSignal("Armored"):Connect(function()
				if health.Parent:GetAttribute("Armored") then
					state.Armored.Visible = true
					local v13 = v6
					local TweenService2 = game:GetService("TweenService")
					v13[state] = TweenService2:Create(
						state.Bar.Shine.UIGradient,
						TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 1e999, false, 5),
						{
							Offset = Vector2.new(0.7, 0)
						}
					)
					v6[state]:Play()
				else
					if v6[state] then
						v6[state]:Cancel()
					end

					state.Armored.Visible = false
					v6[state] = nil
					state.Bar.Shine.UIGradient.Offset = Vector2.new(-0.7, 0)
				end

				updateRender(state, true)
			end))

			if health.Parent:GetAttribute("Armored") then
				state.Armored.Visible = true
				local v13 = v6
				local TweenService2 = game:GetService("TweenService")
				v13[state] = TweenService2:Create(
					state.Bar.Shine.UIGradient,
					TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 1e999, false, 5),
					{
						Offset = Vector2.new(0.7, 0)
					}
				)
				v6[state]:Play()
			else
				if v6[state] then
					v6[state]:Stop()
				end

				state.Armored.Visible = false
				v6[state] = nil
				state.Bar.Shine.UIGradient.Offset = Vector2.new(-0.7, 0)
			end

			script.Parent.Parent.TextLabel.Text = displayName
			script.Parent.Parent.TextLabel.Shadow.Text = displayName
			flag = false
			Effect.new("DropPreview"):play({
				Phase = "BossBar",
				Enemy = instance,
				DropList = dropList,
				DropsTextLabel = dropsTextLabel
			})
			maid:GiveTask(clearBossBarDropPreview)
		end

		updateRender(state, true)
	else
		if state.Name == "Border" and v11 then
			return
		end

		if state.Name == "Subbar" then
			state.Visible = false
		else
			slideBar(false)
		end

		if BossBar[state] then
			BossBar[state].Maid:DoCleaning()
			BossBar[state] = nil
			BossBar.Changed:Fire()
		end

		if state.Name == "Border" then
			clearBossBarDropPreview() -- equivalent call inferred; original call site unknown
		end
	end
end

local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
	for k in pairs(v9) do
		if not BossBar[k] then
			continue
		end

		if BossBar[k].Enemy.Parent then
			local v13 = {}
			local v14 = false

			for _, v15 in pairs(v9[k]) do
				v14 = true

				if os.clock() < v15[5] then
					v15[3] = os.clock()
					table.insert(v13, v15)
				else
					local v16 = math.min(v15[2] - v15[4], os.clock() - v15[3])

					if not (v16 < 0) then
						v8[k] += v15[1] * v16
						v15[3] = os.clock()
						v15[4] += v16
						table.insert(v13, v15)
					end
				end
			end

			if not v14 then
				v8[k] = ratios[k]
			end

			v9[k] = v13
			updateRender(k, v14)
		else
			HookObject(k, nil)
		end
	end
end)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage.Remotes.SegmentHit.OnClientEvent:Connect(function(p)
	local Global = require(game.ReplicatedStorage.Global)
	local encoded = Global.Encode(p)

	if encoded:FindFirstChild("SegmentOf") then
		local value = encoded.SegmentOf.Value

		if value then
			v5 = value
			enemy = value
		end

		if v3 == encoded then
			return
		else
			v3 = encoded
		end
	else
		v5 = encoded

		if enemy == encoded then
			return
		else
			enemy = encoded
		end
	end

	HookObject(script.Parent.Parent.Border, enemy)
	HookObject(script.Parent.Parent.Subbar, v3)
end)
task.spawn(function()
	while task.wait(0.1) do
		local character = game.Players.LocalPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoidRootPart and not (humanoid and humanoid.Health <= 0) then
			if enemy and not v10[enemy] then
				local humanoid2 = enemy:FindFirstChildOfClass("Humanoid")
				local health = enemy:FindFirstChild("Health")

				if (humanoid2 and humanoid2.Health <= 0 or health and health.Value <= 0) and enemy:FindFirstChild("DropPreview") then
					v10[enemy] = true
					v11 = true
					Effect.new("DropPreview"):play({
						Phase = "CollectBossBar",
						Enemy = enemy,
						DropList = dropList,
						DropsTextLabel = dropsTextLabel
					})
					task.delay(1.1, function()
						v11 = false

						if not enemy then
							HookObject(script.Parent.Parent.Border, nil)
						end
					end)
				end
			end

			local primaryPart = v5 and (v5.PrimaryPart or v5:FindFirstChild("HumanoidRootPart"))
			local parent2 = v5 and v5.Parent

			if parent2 then
				if primaryPart then
					if (primaryPart.Position - humanoidRootPart.Position).Magnitude <= 3500 and v5:GetAttribute("HealthEnabled") ~= false then
						parent2 = not (v5:FindFirstChildOfClass("Humanoid") and v5.Humanoid.Health <= 0 and true or v5:FindFirstChild("Health") and v5.Health.Value <= 0)
					else
						parent2 = false
					end
				else
					parent2 = primaryPart
				end
			end

			if parent2 then
				if enemy ~= v5 then
					v3 = nil
					enemy = v5
				end
			else
				v5 = nil
			end

			local primaryPart2 = enemy and (enemy.PrimaryPart or enemy:FindFirstChild("HumanoidRootPart"))

			if not enemy or not enemy.Parent or not primaryPart2 or (primaryPart2.Position - humanoidRootPart.Position).Magnitude > 3500 or enemy:GetAttribute("HealthEnabled") == false or enemy:FindFirstChildOfClass("Humanoid") and enemy.Humanoid.Health <= 0 or enemy:FindFirstChild("Health") and enemy.Health.Value <= 0 then
				v3 = nil
				enemy = nil
				local v13 = { 1e999 }

				for _, v14 in pairs(getEnemies()) do
					local primaryPart3 = v14.PrimaryPart or v14:FindFirstChild("HumanoidRootPart")

					if not primaryPart3 or not v14:GetAttribute("RaidBoss") or v14:GetAttribute("HealthEnabled") == false or v14:FindFirstChild("SegmentOf") then
						continue
					end

					if not (v14:FindFirstChild("Health") and v14.Health.Value > 0 or v14:FindFirstChildOfClass("Humanoid") and v14.Humanoid.Health > 0) then
						continue
					end

					local magnitude = (primaryPart3.Position - humanoidRootPart.Position).Magnitude

					if magnitude < v13[1] then
						v13 = { magnitude, v14 }
					end
				end

				if v13[1] < 3500 then
					enemy = v13[2]
				end
			end

			if enemy and (not v3 or (v3:FindFirstChildOfClass("Humanoid") and v3.Humanoid.Health > 0 or v3:FindFirstChild("Health") and v3.Health.Value > 0) and v3:GetAttribute("HealthEnabled") ~= false) then
				local v13 = { 1e999 }

				for _, v14 in pairs(getEnemies()) do
					local primaryPart3 = v14.PrimaryPart or v14:FindFirstChild("HumanoidRootPart")

					if not (primaryPart3 and v14:FindFirstChild("SegmentOf") and v14:GetAttribute("HealthEnabled") ~= false and v14.SegmentOf.Value == enemy) then
						continue
					end

					local magnitude = (primaryPart3.Position - humanoidRootPart.Position).Magnitude

					if magnitude < v13[1] then
						v13 = { magnitude, v14 }
					end
				end

				if v13[1] < 3500 then
					v3 = v13[2]
				end
			end

			HookObject(script.Parent.Parent.Border, enemy)
			HookObject(script.Parent.Parent.Subbar, v3)
		elseif v5 or enemy or v3 then
			v5 = nil
			enemy = nil
			v3 = nil
			HookObject(script.Parent.Parent.Border, nil)
			HookObject(script.Parent.Parent.Subbar, nil)
		end
	end
end)
return BossBar