local Component = require(game.ReplicatedStorage.Modules.Component)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local v = Component.new({
	Tag = "PvpSessionComponent",
	Ancestors = { game.Players.LocalPlayer }
})
local IrisLog = require(game.ReplicatedStorage.Util.IrisLog)
local pvpDirector = IrisLog.new("PvpDirector", 2, {
	Hidden = true
})
local logAppendWrapper = pvpDirector:getLogAppendWrapper(script, true)
pvpDirector:getLogPcallWrapper(script)
local v2 = {
	Bronze = Color3.new(0.811765, 0.6, 0.262745),
	Silver = Color3.new(0.768627, 0.768627, 0.768627),
	Gold = Color3.new(0.898039, 0.74902, 0),
	Platinum = Color3.new(0.717647, 0.952941, 1),
	Diamond = Color3.new(0.160784, 0.482353, 1),
	Master = Color3.new(0.745098, 0.431373, 1)
}

local function formatRankColor(newRankName: string)
	for k, v3 in v2 do
		if newRankName:find(k) then
			return (`<font color="rgb({math.floor(v3.R * 255)},{math.floor(v3.G * 255)},{math.floor(v3.B * 255)})">{newRankName}</font>`)
		end
	end
end

local function setAttributeHandler(object, attributeName: string, callback)
	object.Maid:GiveTask(object.Instance:GetAttributeChangedSignal(attributeName):Connect(function()
		callback(object.Instance:GetAttribute(attributeName))
	end))
	callback(object.Instance:GetAttribute(attributeName))
end

function v.SetSpectating(_) end

function v.SteppedUpdate(p)
	if p.numSpectators and p.numSpectators > 0 then
		local objectSpace = CFrame.new(workspace.CurrentCamera.CameraSubject.RootPart.CFrame.Position):ToObjectSpace(workspace.CurrentCamera.CFrame)
		p.CameraEvent:FireServer(objectSpace)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatTime(p)
	local v3 = math.floor(p / 60)
	local v4 = p % 60
	return string.format("%01d:%02d", v3, v4)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatTime2(p)
	local v3 = math.floor(p / 60)
	local v4 = p % 60
	local v5 = math.floor(v4)
	local v6 = math.floor((v4 - v5) * 1000)
	return string.format("%01d:%02d.%03d", v3, v5, v6)
end

function v:SetPlayerToSpectate(player)
	self.Maid.SpectatingCFrameConnection = nil

	if not player then
		return
	end

	local onClientEventConnection = nil
	local renderSteppedConnection = nil

	function self.Maid.SpectatingCFrameConnection()
		onClientEventConnection:Disconnect()
		renderSteppedConnection:Disconnect()
	end

	local v3 = nil
	local v4 = nil
	tick()
	local humanoidRootPart = player.Character.HumanoidRootPart
	onClientEventConnection = self.CameraEvent.OnClientEvent:Connect(function(p2)
		v4 = p2
	end)
	local RunService = game:GetService("RunService")
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		if not v3 then
			if not v4 then
				return
			end

			v3 = v4
		end

		v3 = v3:Lerp(v4, 0.9)

		if v3 ~= v3 then
			v3 = v4
		end

		workspace.CurrentCamera.CFrame = CFrame.new(humanoidRootPart.CFrame.Position):ToWorldSpace(v3)
	end)
end

local function fn(object)
	local clone = script.ContinueScreen:Clone()
	task.spawn(function()
		clone.Parent = game.Players.LocalPlayer.PlayerGui
		clone.Exit.Activated:Connect(function()
			object.Instance:FireServer("Exit")
		end)
	end)
	return clone
end

function ApplyHpBar(data, p, p2)
	local v3 = math.max(1, p2 + 1)
	local v4, v5

	if v3 > 1 then
		local v6 = math.floor(data.AbsoluteSize.X * (p2 + p) / v3 + 0.5)
		v4 = math.floor(p / (p + p2) * v6)
		v5 = v6 - v4
	else
		v4 = math.floor(data.AbsoluteSize.X * p + 0.5)
		v5 = math.floor(data.AbsoluteSize.X * p2 + 0.5)
	end

	data.Fill.Size = UDim2.new(0, v4, 1, 0)

	if not (p2 > 0) then
		data.OverFill.Visible = false
		return
	end

	data.OverFill.Visible = true
	data.OverFill.Size = UDim2.new(0, v5, 1, 0)
	data.OverFill.Position = UDim2.fromOffset(v4, 0)
end

function v:DisplayEndGameStats2v2(items, p)
	print(items, p)

	local function commaNumber(value)
		repeat
			local v3
			value, v3 = string.gsub(value, "^(-?%d+)(%d%d%d)", "%1,%2")
		until v3 == 0

		return value
	end

	local pvpMode = nil

	for _, item in items do
		pvpMode = item.PvpMode
		break
	end

	if pvpMode ~= "2v2" then
		return
	end

	local clone = script.PvPEventResult:Clone()
	local main = clone.Modal.Main
	local v4 = {}

	for _, frame in main.Players:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local children = frame:GetChildren()
		table.insert(v4, { frame, children })
		table.sort(children, function(a, b)
			return a.Name < b.Name
		end)
	end

	table.sort(v4, function(a, b)
		return a[1].Name < b[1].Name
	end)
	local item = items[game.Players.LocalPlayer.Name]
	local textLabel = main.Header.TextLabel

	if item.Stats.Winner then
		textLabel.Text = "Victory!"
		textLabel.DefeatUIGradient:Destroy()
		textLabel.VictoryUIGradient.Enabled = true
	else
		textLabel.Text = "Defeat.."
		textLabel.VictoryUIGradient:Destroy()
		textLabel.DefeatUIGradient.Enabled = true
	end

	local timer = main.Header.Timer
	local v5 = p.EndingTime - p.StartTime
	local v6 = math.floor(v5 / 60)
	local v7 = v5 % 60
	timer.Text = `Match Time: {string.format("%01d:%02d", v6, v7)}`
	local _ = item.TeamId
	local v8 = {}
	local v9 = {
		TotalDamage = {},
		FruitDmg = {},
		MeleeDmg = {},
		SwordDmg = {},
		GunDmg = {},
		Kills = {},
		DamageTanked = {}
	}
	local onActivated

	for k, item2 in items do
		local player = game.Players[k]
		local stats = item2.Stats
		local teamId = item2.TeamId
		local v10 = table.remove(v4[teamId][2], 1)
		local playerFrameId = #v4[teamId][2] > 0 and 1 or 2

		if not v10 then
			error("grr")
		end

		local portrait = v10.Portrait
		portrait.Image.Image = `https://www.roblox.com/headshot-thumbnail/image?userId={player.UserId}&width=420&height=420&format=png`
		portrait.WinIcon.Visible = stats.Winner and true or false
		portrait.DeathIcon.Visible = item2.Dead and true or false
		local statusGradient = portrait.StatusGradient
		local backgroundColor

		if stats.Winner then
			backgroundColor = Color3.fromRGB(233, 210, 49)
		else
			backgroundColor = Color3.fromRGB(161, 35, 35)
		end

		statusGradient.BackgroundColor3 = backgroundColor
		v10.Username.Text = player.DisplayName
		item2.TeamFrameId = teamId
		item2.PlayerFrameId = playerFrameId
		print("FreeFrame", v10, teamId, playerFrameId)
		v8[`T{teamId}P{playerFrameId}`] = item2
		v8[item2] = `T{teamId}P{playerFrameId}`
		item2.AchievementLabel = v10.Achievement
		item2.AchievementLabel.Text = ""
		table.insert(
			v9.TotalDamage,
			{
				item2,
				stats.DamageDealt.Fruit + stats.DamageDealt.Gun + stats.DamageDealt.Melee + stats.DamageDealt.Sword
			}
		)
		table.insert(v9.FruitDmg, { item2, stats.DamageDealt.Fruit })
		table.insert(v9.GunDmg, { item2, stats.DamageDealt.Gun })
		table.insert(v9.MeleeDmg, { item2, stats.DamageDealt.Melee })
		table.insert(v9.SwordDmg, { item2, stats.DamageDealt.Sword })
		table.insert(v9.Kills, { item2, stats.Kills })
		table.insert(v9.DamageTanked, { item2, stats.DamageTaken })
	end

	for _, descendant in clone:GetDescendants() do
		if not descendant.Name:find("StatTextLabel") then
			continue
		end

		warn("found", descendant:GetFullName())
		descendant.Text = "-"
	end

	local statistics = clone.Modal.Main.Statistics
	local additionalStats = clone.Modal.Main.AdditionalStats
	local v10 = {}

	for k, v11 in v8 do
		if typeof(k) ~= "string" then
			continue
		end

		statistics.RankChange[k .. "StatTextLabel"].Text = formatRankColor(v11.NewRankName)
		statistics.RankChange[k .. "StatTextLabel"].TextColor3 = Color3.new(1, 1, 1)
		statistics.RankChange[k .. "StatTextLabel"].RichText = true

		if v11.NewRankName == "Master" then
			statistics.RankChange[k .. "StatTextLabel"].Text = `{formatRankColor(v11.NewRankName)} {v11.MMRChange > 0 and "+" or "-"}{v11.MMRChange}BP`
		end
	end

	for childName, list in v9 do
		table.sort(list, function(a, b)
			return a[2] > b[2]
		end)
		local button = statistics:FindFirstChild(childName) or additionalStats:FindFirstChild(childName)

		if not button then
			continue
		end

		if button:IsA("ImageButton") then
			warn("Connect button")
			local v11 = button

			onActivated = function()
				warn("Connect button 2", additionalStats, additionalStats.Visible)
				additionalStats.Visible = not additionalStats.Visible

				if additionalStats.Visible then
					v11.Icon1.Rotation = 180
				else
					v11.Icon1.Rotation = 0
				end
			end

			button.Activated:Connect(onActivated)
		else
			for _, label in button:GetChildren() do
				if label:IsA("TextLabel") and label.Name ~= "Name" then
					label.Text = ""
				end
			end
		end

		for k, v11 in list do
			local parent = button[v8[v11[1]] .. "StatTextLabel"]

			if k == 1 and v11[2] > 0 then
				parent.TextColor3 = Color3.fromRGB(255, 236, 57)
				local clone_2 = script.UIStrokeHighStat:Clone()
				clone_2.Parent = parent
				v10[v11[1]] = v10[v11[1]] or childName
			else
				parent.TextColor3 = Color3.fromRGB(255, 255, 255)
			end

			parent.Text = commaNumber(tostring(math.round(v11[2] * 1) / 1))
		end
	end

	for k, v11 in v10 do
		if not k.AchievementLabel then
			continue
		end

		k.AchievementLabel.Text = ""

		if v11 == "FruitDmg" then
			k.AchievementLabel.Text = "Fruit Main"
		elseif v11 == "MeleeDmg" then
			k.AchievementLabel.Text = "Martial Artist"
		elseif v11 == "SwordDmg" then
			k.AchievementLabel.Text = "Swordmaster"
		elseif v11 == "GunDmg" then
			k.AchievementLabel.Text = "Sharpshooter"
		elseif v11 == "DamageTanked" then
			k.AchievementLabel.Text = "Tank"
		elseif v11 == "Kills" then
			k.AchievementLabel.Text = "Assassin"
		end
	end

	clone.Modal.Position = UDim2.fromScale(5, 5)
	clone.Parent = game.Players.LocalPlayer.PlayerGui
	task.wait(2)
	clone.Modal.Position = UDim2.fromScale(0.5, 0.5)
	local activatedConnection = nil
	activatedConnection = clone.Modal.Title.Close.Activated:Connect(function()
		activatedConnection:Disconnect()
		clone:Destroy()
	end)
	local inputBeganConnection = nil
	local UserInputService = game:GetService("UserInputService")
	inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.ButtonB then
			inputBeganConnection:Disconnect()
			clone:Destroy()
		elseif input.KeyCode == Enum.KeyCode.ButtonY then
			onActivated()
		end
	end)
end

function v:Start()
	logAppendWrapper((`PvpSessionComponent constructed for LocalPlayer ({self.Instance:GetFullName()})`))
	self.Maid = Maid.new()
	self.CameraEvent = self.Instance:WaitForChild("CameraEvent", 99)
	local teamId = self.Instance:GetAttribute("TeamId")
	local v3 = nil
	setAttributeHandler(self, "State", function(p)
		if p == "Waiting" then
			self.Maid.CancelButton = fn(self)
			return
		end

		if p == "Playing" then
		end

		self.Maid.CancelButton = nil
	end)
	setAttributeHandler(self, "Spectators", function(value)
		logAppendWrapper((`Spectators changing: {value}`))
		self.numSpectators = value or 0
	end)
	self.Maid:GiveTask(function()
		game.Players.LocalPlayer.PlayerGui.Backpack.Enabled = true
	end)

	local function setSpectate(childName)
		v3 = childName
		self.Maid.BackpackTask = task.delay(0.1, function()
			if v3 then
				game.Players.LocalPlayer.PlayerGui.Backpack.Enabled = false
			else
				game.Players.LocalPlayer.PlayerGui.Backpack.Enabled = true
			end
		end)
		logAppendWrapper((`Spectating: {childName}`))

		if childName then
			self:SetPlayerToSpectate(game.Players:FindFirstChild(childName))
		else
			self:SetPlayerToSpectate(nil)
		end
	end

	setAttributeHandler(self, "Spectating", setSpectate)
	setAttributeHandler(self, "ShowEndStatsScreen", function(p)
		if not p then
			return
		end

		pcall(function()
			setSpectate(p)
		end)
		coroutine.running()
		self.Instance.OnClientEvent:Connect(function(p2, p3, p4)
			print("RECEIVER", p2, p3, p4)

			if p2 == "EndGameStats" then
				self:DisplayEndGameStats2v2(p3, p4)
			end
		end)
	end)
	setAttributeHandler(self, "MatchEndTime", function(matchEndTime)
		if not matchEndTime then
			self.Maid.matchTimer = nil
			return
		end

		task.wait(1)
		self.Maid.matchTimer = task.spawn(function()
			repeat
				task.wait()
			until self.pvpHud

			self.matchEndTime = matchEndTime

			while task.wait() do
				local v4 = matchEndTime - workspace:GetServerTimeNow()

				if v4 > 10 then
					local matchTimer = self.pvpHud.matchTimer
					matchTimer.Text = formatTime(v4)
				elseif v4 < 0 then
					local matchTimer = self.pvpHud.matchTimer
					matchTimer.Text = "+" .. formatTime2(math.abs(v4))
				else
					self.pvpHud.matchTimer.TextColor3 = Color3.new(1, 0.34902, 0.34902)
					local matchTimer = self.pvpHud.matchTimer
					matchTimer.Text = formatTime2(v4)
				end
			end
		end)
	end)
	setAttributeHandler(self, "MatchStartTimer", function(matchEndTime)
		if matchEndTime then
			self.Maid.matchTimer = task.spawn(function()
				repeat
					task.wait()
				until self.pvpHud

				self.matchEndTime = matchEndTime

				while task.wait() do
					local v4 = matchEndTime - workspace:GetServerTimeNow()

					if v4 > 10 then
						local matchTimer = self.pvpHud.matchTimer
						matchTimer.Text = formatTime(v4)
					elseif v4 < 0 then
						self.pvpHud.matchTimer.Text = "FIGHT!"
					else
						self.pvpHud.matchTimer.TextColor3 = Color3.new(1, 0.34902, 0.34902)
						local matchTimer = self.pvpHud.matchTimer
						matchTimer.Text = formatTime2(v4)
					end
				end
			end)
		else
			self.Maid.matchTimer = nil
		end
	end)
	setAttributeHandler(self, "OutOfBounds", function(flag: boolean)
		if flag then
			if self.pvpHud then
				local returnAlert = self.pvpHud.returnAlert
				local thread = task.spawn(function()
					local character = game.Players.LocalPlayer.Character
					local humanoid = character and character:FindFirstChild("Humanoid")

					if not humanoid or humanoid.Health <= 0 then
						self.Maid.OutOfBoundsScreen = nil
						return
					end

					local lastTime = tick()

					while task.wait() do
						returnAlert.TextTransparency = math.lerp(1, 0, (math.clamp((tick() - lastTime) / 2, 0, 1)))
						local v4 = math.sin(os.clock() % 1 / 1 * 3.141592653589793 * 2) * 0.5 + 0.5
						returnAlert.TextColor3 = Color3.fromHSV(0, 0.9, v4)
					end
				end)

				function self.Maid.OutOfBoundsScreen()
					pcall(task.cancel, thread)
					returnAlert.TextTransparency = 1
				end
			end
		else
			self.Maid.OutOfBoundsScreen = nil
		end
	end)
	local pvpArenaPointer = self.Instance:WaitForChild("pvpArenaPointer", 100)

	if pvpArenaPointer.Value then
		local value = pvpArenaPointer.Value

		local function handlePvpInfoAdded(instance)
			local clone = script.PvpHUD:Clone()
			self.Maid:GiveTask(clone)
			self.pvpHud = clone
			clone.Parent = game.Players.LocalPlayer.PlayerGui

			local function handlePvpTeamInfoAdded(child)
				local v4 = child.Name == tostring(teamId)

				local function pvpPlayerInfoAdded(child2)
					logAppendWrapper((`HealthBar Added: {child2.Value}`))
					local clone2 = clone.Folder.HP:Clone()
					local value2 = child2.Value
					clone2.NameLabel.Text = `{value2.DisplayName}`

					local function onHealthUpdated(health, maxHealth)
						if not clone2:FindFirstChild("HpLabel") then
							return
						end

						clone2.HpLabel.Text = `{math.round(health / maxHealth * 100)}%`
						ApplyHpBar(clone2, health / maxHealth, 0)

						if health <= 0 then
							clone2.HpLabel.Text = "ELIMINATED"
							clone2.Fill.BackgroundColor3 = Color3.fromRGB(109, 109, 109)
							clone2.Fill.Trans.BackgroundColor3 = Color3.fromRGB(56, 56, 56)
						end
					end

					if v4 then
						clone2.Parent = clone.HealthBarsAlly
					else
						clone2.Parent = clone.HealthBarsEnemy
						clone2.Fill.BackgroundColor3 = Color3.fromRGB(255, 59, 0)
						clone2.Fill.Trans.BackgroundColor3 = Color3.fromRGB(198, 26, 0)
					end

					local character = value2.Character
					local humanoid = character and character:FindFirstChild("Humanoid")

					if humanoid then
						onHealthUpdated(humanoid.Health, humanoid.MaxHealth)
						humanoid.HealthChanged:Connect(function()
							onHealthUpdated(humanoid.Health, humanoid.MaxHealth)
						end)
					end

					clone2.Visible = true
				end

				self.Maid:GiveTask(child.ChildAdded:Connect(function(child2)
					pvpPlayerInfoAdded(child2)
				end))

				for _, child2 in child:GetChildren() do
					pvpPlayerInfoAdded(child2)
				end
			end

			self.Maid:GiveTask(instance.ChildAdded:Connect(function(child)
				handlePvpTeamInfoAdded(child)
			end))

			for _, child in instance:GetChildren() do
				handlePvpTeamInfoAdded(child)
			end
		end

		if value:FindFirstChild("pvpTeamsInfo") then
			handlePvpInfoAdded(value:FindFirstChild("pvpTeamsInfo"))
		end

		self.Maid:GiveTask(value.ChildAdded:Connect(function(child)
			if child.Name == "pvpTeamsInfo" then
				handlePvpInfoAdded(child)
			end
		end))
	end
end

function v.Stop(p)
	p.Maid:Destroy()
end

return v