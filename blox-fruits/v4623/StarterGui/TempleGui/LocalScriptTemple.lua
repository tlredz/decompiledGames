local createVector = vector.create
local templeofTime = game.ReplicatedStorage.MapStash:WaitForChild("Temple of Time", 1) or workspace.Map:WaitForChild(
	"Temple of Time",
	1
)

if templeofTime then
	local Util = require(game.ReplicatedStorage.Util)
	local signal2 = Util.Signal2
	require(game.ReplicatedStorage.Util.WaitForStream)

	function quadBezier(p, p2, p3, p4)
		local p5 = p2.p
		local p6 = p3.p
		local p7 = p4.p
		return (CFrame.new((1 - p) ^ 2 * p5 + 2 * (1 - p) * p * p6 + p ^ 2 * p7, (p4 * CFrame.new(0, 0, -25)).p))
	end

	local innerClock = templeofTime:WaitForChild("InnerClock")
	innerClock:WaitForChild("Glow")
	innerClock:WaitForChild("Container")
	local clock = templeofTime:WaitForChild("Clock", 99999)
	local clockBackground = templeofTime:WaitForChild("ClockBackground", 99999)
	local Buttons = require(script.Buttons)
	local positionsByChild = {}
	local count = 0
	local v = true
	local v2 = false
	local raceDetails = nil

	for _, child in pairs(script.Parent.GearButtons:GetChildren()) do
		positionsByChild[child] = child.Position
	end

	local v3 = {
		DefaultGear = Color3.fromRGB(126, 104, 63),
		AlphaGear = Color3.fromRGB(139, 17, 19),
		OmegaGear = Color3.fromRGB(42, 74, 149),
		NewGear = Color3.fromRGB(162, 162, 162),
		WeakAlphaBack = Color3.fromRGB(255, 131, 133),
		StrongAlphaBack = Color3.fromRGB(255, 0, 4),
		WeakOmegaBack = Color3.fromRGB(162, 189, 232),
		StrongOmegaBack = Color3.fromRGB(51, 141, 200),
		MixedBack = Color3.fromRGB(201, 124, 255),
		DefaultBack = Color3.fromRGB(162, 162, 162)
	}
	local children = {}

	for _, child in pairs(innerClock:GetChildren()) do
		if child.Name:match("Gear") then
			table.insert(children, child)
		end
	end

	Buttons.Gear1.GearType = "Default"
	Buttons.Gear4.GearType = "Default"
	Buttons.Gear5.GearType = "Default"
	Buttons.Gear2.GearType = "Alpha"
	Buttons.Gear2.CanSelect = false
	Buttons.Gear3.CanSelect = false
	local v4 = {
		Gear1 = { "EMPTY", "EMPTY" },
		Alpha = { "EMPTY", "EMPTY" },
		Omega = { "EMPTY", "EMPTY" },
		Gear5 = { "Energy Training", [[
Improves transformation duration and energy gain.
<i><font color="#FFEB9B">Obtained from trainer.</font></i>]] }
	}
	local v5 = {
		Human = {
			{
				"Ancient Powers",
				"Upon transforming, receive MAX STATS as well as increased damage and speed, and heal by 10%."
			},
			{
				"Psycho",
				"Flash Step now has 3 charges, which temporarily make the user invisible and faster upon use.",
				"Flash Step charges now regen faster, dash distance increases, and moves cannot be cancelled anymore upon taking damage."
			},
			{
				"Limit Break",
				"Allows the user to become stronger as they fight through a rage meter.",
				"Your rage meter now lasts longer, and is uncapped to 150%."
			}
		},
		Fishman = {
			{
				"Ancient Powers",
				"Upon transforming, receive MAX STATS as well as increased damage and speed, and heal by 10%."
			},
			{
				"Leviathan's Armor",
				"Gain a water shield which regenerates by dealing damage (weaker on NPCs).",
				"Your shield capacity is increased, as well as its regen per hit."
			},
			{
				"Whirlpool",
				"Hits apply a water debuff on enemies, slowing their speed and slightly lowering their defense. Effect stacks.",
				"Duration and slowness are increased greatly."
			}
		},
		Skypiea = {
			{
				"Ancient Powers",
				"Upon transforming, receive MAX STATS as well as increased damage and speed, and heal by 10%."
			},
			{
				"Prince of the Skies",
				"Allows the user to glide in the air by holding the dash button, and free flight by holding the jump button.",
				"All effects are increased greatly."
			},
			{
				"King's Rule",
				"Adds an aura around the user with multiple effects: slowness, damage, energy drain, screen distortion.",
				"All effects are increased greatly."
			}
		},
		Ghoul = {
			{
				"Ancient Powers",
				"Upon transforming, receive MAX STATS as well as increased damage and speed, and heal by 10%."
			},
			{
				"Blood Siphon",
				"All attacks gain Life Leech (weaker on NPCs).",
				"The Life Leech effect is increased greatly."
			},
			{
				"Domain Expansion",
				"Adds a dark field around the user with multiple effects: slowness, health regen negation, blindness. All night passives become available during the day and cooldowns are reduced.",
				"Upon dashing, crows will attack nearby enemies. Increases your field range."
			}
		},
		Cyborg = {
			{
				"Ancient Powers",
				"Upon transforming, receive MAX STATS as well as increased damage and speed, and heal by 10%."
			},
			{
				"Energy Control",
				"Damage dealt now chains to nearby enemies through orbs. Allows the user to Super Jump (must have Instinct enabled).",
				"The effects of chain damage increase. Super Jump now deals damage and no longer requires Instinct to be enabled."
			},
			{
				"Aftershock",
				"Attacks now apply an electrifying effect that disables the opponent's Instinct ability temporarily.",
				"The electrifying effect becomes stronger and lasts longer."
			}
		},
		Mink = {
			{
				"Ancient Powers",
				"Upon transforming, receive MAX STATS as well as increased damage and speed, and heal by 10%."
			},
			{
				"Lightning Cloak",
				"Dashes become much longer due to electricity.",
				"Allows the user to Super Dash by holding the dash button."
			},
			{
				"Whirlwind",
				"Leaves a tornado behind when dashing. Tornadoes will trap enemies temporarily.",
				"Tornadoes become much stronger."
			}
		}
	}

	local function IsDraco()
		local data = game.Players.LocalPlayer:FindFirstChild("Data")

		if not data then
			return
		end

		local race = data:FindFirstChild("Race")

		if not (race and race:FindFirstChild("Evolved")) then
			return
		end

		if race.Value == "Draco" then
			return true
		end
	end

	function SpinGears()
		count += 1
		local v6 = count
		task.spawn(function()
			while v6 == count do
				local v7 = task.wait() * 3

				for _, v8 in pairs(children) do
					v8.CFrame *= CFrame.Angles(
						0,
						math.rad(v7 * (v8:GetAttribute("Direction") or 1)) * (v8.Size.X < 4 and 2 or 1),
						0
					)
				end
			end
		end)
	end

	local race = nil
	local changedConnection = nil
	local diedConnection = nil

	function EaseIn()
		local data = game.Players.LocalPlayer:FindFirstChild("Data")
		local v6

		if data then
			local race2 = data:FindFirstChild("Race")

			if race2 and race2:FindFirstChild("Evolved") then
				v6 = race2.Value == "Draco" or nil
			end
		end

		if v6 then
			return
		end

		for k, position in pairs(positionsByChild) do
			k.Position = position
			k.AnchorPoint = Vector2.new(0, 0)
		end

		local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")

		if humanoid and humanoid.Health <= 0 then
			return
		end

		local v7 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("TempleClock", "Check")

		if not v7 then
			warn("no res")
			return
		end

		if v7.Race == "Draco" then
			return
		end

		local busy = game.Players.LocalPlayer.Character:FindFirstChild("Busy")

		if busy then
			busy.Value = true

			if changedConnection then
				changedConnection:Disconnect()
				changedConnection = nil
			end

			changedConnection = busy.Changed:Connect(function()
				busy.Value = true
			end)
		end

		local humanoid2 = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")

		if humanoid2 then
			if diedConnection then
				diedConnection:Disconnect()
				diedConnection = nil
			end

			diedConnection = humanoid2.Died:Connect(function()
				EaseOut()
			end)
		end

		race = v7.Race
		v = v7.HadPoint == true
		v2 = v7.RaceLevel >= 2
		raceDetails = v7.RaceDetails
		Buttons.Gear2.GearType = v7.RaceDetails.Gears[1] == "A" and "Alpha" or v7.RaceDetails.Gears[1] == "B" and "Omega" or "Blank"
		Buttons.Gear3.GearType = v7.RaceDetails.Gears[2] == "A" and "Alpha" or v7.RaceDetails.Gears[2] == "B" and "Omega" or "Blank"
		Buttons.Gear4.GearType = v7.RaceDetails.Gears[3] == "A" and "Alpha" or v7.RaceDetails.Gears[3] == "B" and "Omega" or "Blank"
		local gear2 = Buttons.Gear2
		gear2.Unlocked = v7.RaceDetails.A + v7.RaceDetails.B >= 0 and v2
		local gear3 = Buttons.Gear3
		gear3.Unlocked = v7.RaceDetails.A + v7.RaceDetails.B >= 1 and v2
		local gear4 = Buttons.Gear4
		gear4.Unlocked = v7.RaceDetails.A + v7.RaceDetails.B >= 2 and v2
		Buttons.Gear5.CanSelect = false
		Buttons.Gear5.Unlocked = false

		if v7.RaceDetails.C >= 1 then
			Buttons.Gear5.Unlocked = true
		end

		Buttons.Gear1.Unlocked = true

		if v2 then
			Buttons.Gear1.CanSelect = false
			Buttons.Gear1.GearType = "Default"
		else
			Buttons.Gear1.CanSelect = true
			Buttons.Gear1.GearType = "Blank"
			v = true
		end

		if v then
			local gear22 = Buttons.Gear2
			gear22.CanSelect = v7.RaceDetails.A + v7.RaceDetails.B == 0 and v2
			local gear32 = Buttons.Gear3
			gear32.CanSelect = v7.RaceDetails.A + v7.RaceDetails.B == 1 and v2
			local gear42 = Buttons.Gear4
			gear42.CanSelect = v7.RaceDetails.A + v7.RaceDetails.B >= 2 and v2

			if v7.RaceDetails.A + v7.RaceDetails.B >= 3 then
				Buttons.Gear2.CanSelect = true
				Buttons.Gear3.CanSelect = true
				Buttons.Gear4.CanSelect = true

				if Buttons.Gear2.GearType == "Alpha" and Buttons.Gear3.GearType == "Alpha" and Buttons.Gear4.GearType == "Omega" then
					Buttons.Gear4.CanSelect = false
				elseif Buttons.Gear2.GearType == "Omega" and Buttons.Gear3.GearType == "Omega" and Buttons.Gear4.GearType == "Alpha" then
					Buttons.Gear4.CanSelect = false
				elseif Buttons.Gear2.GearType == "Alpha" and Buttons.Gear3.GearType == "Omega" and Buttons.Gear4.GearType == "Omega" then
					Buttons.Gear4.CanSelect = false
					Buttons.Gear2.CanSelect = false
				elseif Buttons.Gear2.GearType == "Omega" and Buttons.Gear3.GearType == "Alpha" and Buttons.Gear4.GearType == "Omega" then
					Buttons.Gear4.CanSelect = false
					Buttons.Gear3.CanSelect = false
				elseif Buttons.Gear2.GearType == "Omega" and Buttons.Gear3.GearType == "Alpha" and Buttons.Gear4.GearType == "Alpha" then
					Buttons.Gear4.CanSelect = false
					Buttons.Gear2.CanSelect = false
				elseif Buttons.Gear2.GearType == "Alpha" and Buttons.Gear3.GearType == "Omega" and Buttons.Gear4.GearType == "Alpha" then
					Buttons.Gear4.CanSelect = false
					Buttons.Gear3.CanSelect = false
				end
			end
		else
			Buttons.Gear2.CanSelect = false
			Buttons.Gear3.CanSelect = false
			Buttons.Gear4.CanSelect = false
		end

		v4.Gear1 = v5[v7.Race][1]
		v4.Alpha = v5[v7.Race][2]
		v4.Omega = v5[v7.Race][3]
		warn(v4)

		for _, button in pairs(Buttons) do
			if button.Unlocked then
				local color = Color3.fromRGB(126, 104, 63)

				if button.GearType == "Alpha" then
					color = v3.AlphaGear
				elseif button.GearType == "Omega" then
					color = v3.OmegaGear
				elseif button.GearType ~= "Default" then
					color = Color3.fromRGB(68, 68, 68)
				end

				button.gear.Size = button.gear.Size * createVector(1, 0, 1) + createVector(0, 0.854, 0)
				button.gear.Color = color
				button.gear.Transparency = 0

				if button.GearType == "Blank" then
					button.gear.Material = Enum.Material.Neon
				else
					button.gear.Material = Enum.Material.Metal
				end
			else
				button.gear.Size = button.gear.Size * createVector(1, 0, 1) + createVector(0, 0.01, 0)
				button.gear.Color = Color3.fromRGB(68, 68, 68)
				button.gear.Material = Enum.Material.Neon
				button.gear.Transparency = 0.99
			end

			button.MouseLeave:Fire()
		end

		script.Parent.Parent.Main.Enabled = false
		script.Parent.Parent.Backpack.Enabled = false
		local cFrame = workspace.CurrentCamera.CFrame
		local v11 = clock.Center.CFrame * CFrame.Angles(-1.5707963267948966, 0, 3.141592653589793) * CFrame.new(
			0,
			0,
			15
		)
		local v12 = cFrame:Lerp(v11, 0.5) * CFrame.new(0, 0, 10)
		workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

		if v then
			script.Parent.Title.TextLabel.Text = "Choose a gear to replace."
			script.Parent.Title.TextLabel.TextLabel.Text = "Choose a gear to replace."
		else
			script.Parent.Title.TextLabel.Text = "Come back when you complete the trials again."
			script.Parent.Title.TextLabel.TextLabel.Text = "Come back when you complete the trials again."
		end

		SpinGears()
		local v13 = 0

		while v13 < 1 do
			v13 = math.min(v13 + task.wait() * 1.6, 1)
			workspace.CurrentCamera.CFrame = quadBezier(v13, cFrame, v12, v11)

			if v13 >= 0.6 then
				local transparency = (v13 - 0.6) / 0.4

				for _, part in pairs(clock:GetChildren()) do
					if part:IsA("MeshPart") then
						part.Transparency = transparency
					elseif part:IsA("Part") then
						part.Decal.Transparency = transparency
					end
				end

				for _, part in pairs(clockBackground:GetChildren()) do
					if part:IsA("MeshPart") then
						part.Transparency = transparency
					end
				end

				innerClock.Glow.Transparency = 1 - transparency * 0.8
			end

			innerClock.Container.Transparency = 1 - v13 * 2
		end

		script.Parent.Enabled = true
		templeofTime.Prompt.ProximityPrompt.Enabled = false
	end

	function EaseOut()
		local data = game.Players.LocalPlayer:FindFirstChild("Data")
		local v6

		if data then
			local race2 = data:FindFirstChild("Race")

			if race2 and race2:FindFirstChild("Evolved") then
				v6 = race2.Value == "Draco" or nil
			end
		end

		if v6 then
			return
		end

		for _, part in pairs(clock:GetChildren()) do
			if part:IsA("MeshPart") then
				part.Transparency = 0
			elseif part:IsA("Part") then
				part.Decal.Transparency = 0
			end
		end

		for _, part in pairs(clockBackground:GetChildren()) do
			if part:IsA("MeshPart") then
				part.Transparency = 0
			end
		end

		innerClock.Glow.Transparency = 1
		script.Parent.Enabled = false
		local GuiService = game:GetService("GuiService")
		GuiService.SelectedObject = nil

		for _, highlight in pairs(innerClock:GetDescendants()) do
			if highlight:IsA("Highlight") then
				highlight.Enabled = false
			end
		end

		script.Parent.Parent.Main.Enabled = true
		script.Parent.Parent.Backpack.Enabled = true
		count += 1
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		templeofTime.Prompt.ProximityPrompt.Enabled = true

		if changedConnection then
			changedConnection:Disconnect()
			changedConnection = nil
		end

		if diedConnection then
			diedConnection:Disconnect()
			diedConnection = nil
		end

		local busy = game.Players.LocalPlayer.Character:FindFirstChild("Busy")

		if busy then
			busy.Value = false
		end
	end

	function UpdateBackground()
		local count2 = 0
		local count3 = 0

		for _, button in pairs(Buttons) do
			if button.GearType == "Alpha" then
				count3 += 1
			elseif button.GearType == "Omega" then
				count2 += 1
			end
		end

		local defaultBack = v3.DefaultBack

		if count3 == 2 then
			defaultBack = v3.StrongAlphaBack
		elseif count3 == 1 and count2 == 0 then
			defaultBack = v3.WeakAlphaBack
		elseif count2 == 2 then
			defaultBack = v3.StrongOmegaBack
		elseif count2 == 1 and count3 == 0 then
			defaultBack = v3.WeakOmegaBack
		elseif count2 == 1 and count3 == 1 then
			defaultBack = v3.MixedBack
		end

		local TweenService = game:GetService("TweenService")
		TweenService:Create(innerClock.Container, TweenInfo.new(0.4), {
			Color = defaultBack
		}):Play()
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(clockBackground.Container, TweenInfo.new(0.4), {
			Color = defaultBack
		}):Play()
	end

	function Shatter(p, color)
		local clone = script.Model:Clone()
		clone:SetPrimaryPartCFrame(p.CFrame * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.new(0.21, 0, 0))
		clone.Parent = workspace

		for _, child in pairs(clone:GetChildren()) do
			if child.Name == "Center" then
				continue
			end

			local cFrame = child.CFrame
			child.CFrame = p.CFrame * CFrame.Angles(
				-math.rad(math.random() * 100),
				math.rad(math.random() * 100 - 50),
				0
			) * CFrame.new(0, 0, 12 + math.random() * 3) * CFrame.Angles(
				math.random() * 2 * 3.141592653589793,
				math.random() * 2 * 3.141592653589793,
				math.random() * 2 * 3.141592653589793
			)
			child.Material = Enum.Material.Neon
			child.Color = color
			child.Size *= createVector(0, 1, 1)
			local TweenService = game:GetService("TweenService")
			TweenService:Create(child, TweenInfo.new(3), {
				CFrame = cFrame
			}):Play()
			local v6 = child
			task.delay(3.7, function()
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(v6, TweenInfo.new(0.4), {
					CFrame = p.CFrame * CFrame.Angles(
						-math.rad(math.random() * 100),
						math.rad(math.random() * 100 - 50),
						0
					) * CFrame.new(0, 0, 12 + math.random() * 3) * CFrame.Angles(
						math.random() * 2 * 3.141592653589793,
						math.random() * 2 * 3.141592653589793,
						math.random() * 2 * 3.141592653589793
					)
				}):Play()
			end)
			game.Debris:AddItem(child, 4.2)
		end

		task.wait(3.7)
	end

	function ShowPopup(p, p2)
		if p == "Gear1" then
			game.ReplicatedStorage.Remotes.CommF_:InvokeServer("TempleClock", "SpendPoint")
			return "Default"
		end

		local v6 = {}
		local v7

		if p == "Gear1" or p == "Gear5" then
			v7 = { "Default" }
		elseif p == "Gear4" then
			if raceDetails.A == 2 and raceDetails.B == 0 then
				v7 = { "Omega" }
			elseif raceDetails.B == 2 and raceDetails.A == 0 then
				v7 = { "Alpha" }
			elseif raceDetails.A == 1 and raceDetails.B == 1 then
				v7 = { "Alpha", "Omega" }
			else
				v7 = v6
			end
		elseif p2.GearType == "Alpha" and raceDetails.B < 2 then
			v7 = { "Omega" }
		elseif p2.GearType == "Omega" and raceDetails.A < 2 then
			v7 = { "Alpha" }
		else
			v7 = {}

			if raceDetails.A < 2 then
				table.insert(v7, "Alpha")
			end

			if raceDetails.B < 2 then
				table.insert(v7, "Omega")
			end

			local _ = #v7 == 0
		end

		for _, button in pairs(script.Parent.Popup.Gears:GetChildren()) do
			if not button:IsA("TextButton") then
				continue
			end

			if table.find(v7, button.Name) then
				button.Visible = true
			else
				button.Visible = false
			end
		end

		script.Parent.Popup.Visible = true
		local v8 = signal2.new()
		local activatedConnection = script.Parent.Popup2.Info.Frame.Equip.Activated:Connect(function()
			v8:Fire(script.Parent.Popup2:GetAttribute("SelectedGear"))
		end)
		local activatedConnection2 = script.Parent.Popup.Info.Frame.Exit.Activated:Connect(function()
			v8:Fire(false)
		end)
		local v9 = v8:Wait()
		activatedConnection:Disconnect()
		activatedConnection2:Disconnect()
		script.Parent.Popup.Visible = false
		game.ReplicatedStorage.Remotes.CommF_:InvokeServer("TempleClock", "SpendPoint", p, v9)
		return v9
	end

	local flag = false

	for _, button in pairs(script.Parent.Popup.Gears:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		local v6 = button
		button.Activated:Connect(function()
			local total = 1

			if v6.Name == "Alpha" then
				total += raceDetails.A
			elseif v6.Name == "Omega" then
				total += raceDetails.B
			end

			script.Parent.Popup.Visible = false
			script.Parent.Popup2.Visible = true
			script.Parent.Popup2:SetAttribute("SelectedGear", v6.Name)

			if total == 2 then
				script.Parent.Popup2.Container.List.TextLabel.Text = "Upgrade: "
			else
				script.Parent.Popup2.Container.List.TextLabel.Text = ""
			end

			script.Parent.Popup2.Container.List.TextLabel.Text = script.Parent.Popup2.Container.List.TextLabel.Text .. (v4[v6.Name][total + 1] or "Unsocket the current gear. Any effects granted by the current gear will be removed.")
			script.Parent.Popup2.Title.Text = v6.Name == "Blank" and "Unsocket" or v4[v6.Name][1] .. " (Tier " .. total .. ")"

			if v6.Name == "Blank" then
				script.Parent.Popup2.Info.Frame.Equip.TextLabel.Text = "Continue"
			else
				script.Parent.Popup2.Info.Frame.Equip.TextLabel.Text = "Equip"
			end

			local activatedConnection = nil
			local activatedConnection2 = nil
			activatedConnection = script.Parent.Popup2.Info.Frame.Equip.Activated:Connect(function()
				script.Parent.Popup2.Visible = false
				activatedConnection:Disconnect()
				activatedConnection2:Disconnect()
			end)
			activatedConnection2 = script.Parent.Popup2.Info.Frame.Exit.Activated:Connect(function()
				script.Parent.Popup.Visible = true
				script.Parent.Popup2.Visible = false
				activatedConnection:Disconnect()
				activatedConnection2:Disconnect()
			end)
		end)
	end

	for k, button in pairs(Buttons) do
		local v6 = k
		local v7 = button
		button.MouseEntered:Connect(function()
			if flag then
				return
			end

			local highlight = innerClock[v6]:FindFirstChild("Highlight") or Instance.new("Highlight", innerClock[v6])
			highlight.FillColor = Color3.fromRGB(255, 255, 255)
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			highlight.FillTransparency = 0.7
			highlight.OutlineTransparency = 0.85
			innerClock[v6].Highlight.Enabled = true
			script.Parent.Description.Title.Text = "<u>Gear " .. v7.Text .. "</u>"
			script.Parent.Description.Title.Title.Text = "<u>Gear " .. v7.Text .. "</u>"
			local A = 0

			if v7.GearType == "Alpha" then
				A = raceDetails.A
			elseif v7.GearType == "Omega" then
				A = raceDetails.B
			end

			if v4[v6] then
				script.Parent.Description.TextLabel.Text = v4[v6][2]

				if v6 == "Gear5" and raceDetails.C >= 1 then
					script.Parent.Description.Title.Text = "<u>" .. v4[v6][1] .. " (Tier " .. raceDetails.C .. ")</u>"
				else
					script.Parent.Description.Title.Text = "<u>" .. v4[v6][1] .. "</u>"
				end

				script.Parent.Description.Title.Title.Text = script.Parent.Description.Title.Text
			elseif v7.GearType and v4[v7.GearType] then
				script.Parent.Description.TextLabel.Text = v4[v7.GearType][2]

				if A == 2 then
					script.Parent.Description.TextLabel.Text = script.Parent.Description.TextLabel.Text .. "\n<font color=\"#e1ad01\">Upgrade:</font> " .. v4[v7.GearType][3]
				else
					script.Parent.Description.TextLabel.Text = script.Parent.Description.TextLabel.Text .. "\n<font color=\"#e1ad01\">Upgrade:</font> [LOCKED]"
				end

				script.Parent.Description.Title.Text = "<u>" .. v4[v7.GearType][1] .. " (Tier " .. A .. ")</u>"
				script.Parent.Description.Title.Title.Text = script.Parent.Description.Title.Text
			elseif v7.Unlocked then
				if v7.CanSelect then
					script.Parent.Description.TextLabel.Text = [[

<font color="#a7d6ff">Click to socket a new gear.</font>
]]
				else
					script.Parent.Description.TextLabel.Text = [[

<font color="#ff6164">You can socket this gear after beating the trials again.</font>
]]
				end
			else
				script.Parent.Description.TextLabel.Text = [[

Clear more trials to unlock this slot.
]]
			end

			if not v7.Unlocked then
				script.Parent.Description.Title.Text ..= " [LOCKED]"
				script.Parent.Description.Title.Title.Text ..= "<font color=\"#FF0000\"> [LOCKED]</font>"
			end

			script.Parent.Description.Visible = true
		end)
		local v8 = k
		local v9 = button
		button.MouseLeave:Connect(function()
			if flag then
				return
			end

			if not innerClock[v8]:FindFirstChild("Highlight") then
				Instance.new("Highlight", innerClock[v8])
			end

			if v9.Unlocked and v9.CanSelect then
				innerClock[v8].Highlight.FillTransparency = 1
				innerClock[v8].Highlight.OutlineTransparency = 0
				innerClock[v8].Highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
				innerClock[v8].Highlight.Enabled = true
			else
				innerClock[v8].Highlight.Enabled = false
			end

			script.Parent.Description.Visible = false
		end)
		local v10 = button
		local v11 = k
		button.Activated:Connect(function()
			if not (v10.Unlocked and v10.CanSelect) then
				return
			end

			flag = true
			v10.gear.Highlight.FillTransparency = 0.5
			v10.gear.Highlight.OutlineTransparency = 1
			v10.gear.Highlight.FillColor = Color3.fromRGB(255, 255, 255)
			v10.gear.Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			script.Parent.Description.Visible = false
			script.Parent.Skip.Visible = false

			for k2, button2 in pairs(Buttons) do
				button2.gear.Highlight.Enabled = false
			end

			v10.gear.Highlight.Enabled = true
			script.Parent.GearButtons.Visible = false
			local gearType = ShowPopup(v11, v10)

			if gearType then
				v10.GearType = gearType

				if gearType == "Blank" then
					v10.GearType = nil
				end

				v10.gear.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				v10.gear.Highlight.Enabled = false
				local TweenService = game:GetService("TweenService")
				TweenService:Create(innerClock.Model.Part, TweenInfo.new(0.6), {
					Color = Color3.fromRGB(0, 0, 0)
				}):Play()
				wait(0.2)
				local clone = v10.gear:Clone()
				clone.Parent = workspace
				clone.CFrame = v10.gear.CFrame
				v10.gear.Transparency = 1
				v10.gear.CFrame += createVector(0.35, 0, 0)
				local numberValue = Instance.new("NumberValue", clone)
				numberValue.Value = 1
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(numberValue, TweenInfo.new(1), {
					Value = 0
				}):Play()
				local clone2 = script.Gear2Negative:Clone()
				clone2.Parent = workspace
				clone2.CFrame = v10.gear.CFrame
				local cFrameChangedConnection = v10.gear:GetPropertyChangedSignal("CFrame"):Connect(function()
					clone2.CFrame = v10.gear.CFrame + Vector3.new(0.35 * numberValue.Value, 0, 0)
					clone.CFrame = v10.gear.CFrame - Vector3.new(0.35 * numberValue.Value, 0, 0)
				end)
				local color = Color3.fromRGB(126, 104, 63)
				local color2 = Color3.fromRGB(177, 137, 67)

				if v10.GearType == "Alpha" then
					color = v3.AlphaGear
					color2 = Color3.fromRGB(255, 0, 0)
				elseif v10.GearType == "Omega" then
					color = v3.OmegaGear
					color2 = Color3.fromRGB(1, 103, 255)
				elseif v10.GearType ~= "Default" then
					color = Color3.fromRGB(162, 162, 162)
					color2 = Color3.fromRGB(172, 172, 172)
				end

				Shatter(clone2, color2)
				v10.gear.Color = color
				UpdateBackground()
				cFrameChangedConnection:Disconnect()
				v10.gear.Transparency = 0
				v10.gear.Material = Enum.Material.Metal
				clone:Destroy()
				v10.gear.CFrame -= createVector(0.35, 0, 0)
				clone2:Destroy()
				local TweenService3 = game:GetService("TweenService")
				TweenService3:Create(innerClock.Model.Part, TweenInfo.new(0.2), {
					Color = Color3.fromRGB(88, 87, 89)
				}):Play()
				script.Parent.Title.TextLabel.Text = "Come back when you complete the trials again."
				script.Parent.Title.TextLabel.TextLabel.Text = "Come back when you complete the trials again."
				script.Parent.Skip.Visible = false
				wait(2.5)
				local v13 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("TempleClock", "Check")

				if v13 then
					race = v13.Race
					v = v13.HadPoint == true
					v2 = v13.RaceLevel >= 2
					raceDetails = v13.RaceDetails
				end

				script.Parent.Skip.Visible = true
				script.Parent.GearButtons.Visible = true
				flag = false

				for k2, button2 in pairs(Buttons) do
					button2.CanSelect = false
				end

				v = false
				script.Parent.Skip.Visible = true
			else
				script.Parent.GearButtons.Visible = true
				script.Parent.Skip.Visible = true
				flag = false
				local mouseEntered = nil

				for k2, button2 in pairs(Buttons) do
					if button2.__Hovered then
						mouseEntered = button2.MouseEntered
					else
						button2.MouseLeave:Fire()
					end
				end

				if mouseEntered then
					mouseEntered:Fire()
				end
			end
		end)
	end

	UpdateBackground()
	local triggeredConnection = nil
	script.Parent.Skip.TextButton.Activated:Connect(EaseOut)
	templeofTime.ChildAdded:Connect(function(child)
		if child.Name ~= "Prompt" then
			return
		end

		if triggeredConnection then
			triggeredConnection:Disconnect()
		end

		triggeredConnection = child:WaitForChild("ProximityPrompt").Triggered:Connect(EaseIn)
	end)
	local prompt = templeofTime:FindFirstChild("Prompt", true)

	if prompt then
		if prompt.Name ~= "Prompt" then
			return
		end

		if triggeredConnection then
			triggeredConnection:Disconnect()
		end

		triggeredConnection = prompt:WaitForChild("ProximityPrompt").Triggered:Connect(EaseIn)
	end
else
	local Global = require(game.ReplicatedStorage.Global)
	Global.TestGameWarn("LocalScriptTemple jumpout")
	script.Parent:Destroy()
end