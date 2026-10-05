local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
require(replicatedStorage.Modules.Icon)
local _ = replicatedStorage.Animations
local _ = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
require(replicatedStorage.Modules.CameraShaker)
local MVP = require(replicatedStorage.Modules.MVP)
require(game.ReplicatedStorage.Modules.CountryCodes)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "DuelController"
})
local v3 = {
	{
		Title = "Revealing one's hands",
		Name = "Reveal",
		Background = 81779608092469,
		Info = { "1.1x HP", "Cooldowns are shown next to you" }
	},
	{
		Title = "Overtime",
		Name = "Overtime",
		Background = 7061206855,
		Info = { "0.9x DMG for all but your last lives", "1.25x DMG your last life" }
	},
	{
		Title = "Taking a Gamble",
		Name = "Gamble",
		Background = 112774677152378,
		Info = { "1.2x DMG", "Lose one random skill every respawn" }
	},
	{
		Title = "Never Again",
		Name = "Never",
		Background = 81810628540744,
		Info = { "1.35x DMG", "Lose a skill once it's used twice" }
	},
	{
		Title = "True Love",
		Name = "True",
		Background = 74011425921907,
		Info = { "1.3x AWK", "Awakening automatically activates", "Death when awakening ends" }
	},
	{
		Title = "Enchain",
		Name = "Enchain",
		Background = 136074741603886,
		Info = {
			"1.3x AWK",
			"Instantly restore all health when activating awakening",
			"You can not harm anyone for the first 12 seconds"
		}
	}
}
local deepCopy

deepCopy = function(items)
	local result = {}

	for k, item in pairs(items) do
		if type(item) == "table" then
			item = deepCopy(item)
		end

		result[k] = item
	end

	return result
end

function controller.Start(_)
	local v4 = nil
	task.spawn(function()
		local ranked = localPlayer.PlayerGui:WaitForChild("Ranked")
		local sorcerers = game.Teams:WaitForChild("Sorcerers")
		local curses = game.Teams:WaitForChild("Curses")
		local uDim = UDim2.new(0, 0, 0.4, 0)
		ranked.NameL.Position -= uDim
		ranked.NameR.Position -= uDim
		ranked.StockL.Position -= uDim
		ranked.StockR.Position -= uDim
		ranked.Enabled = true

		for _ = 1, sorcerers:GetAttribute("Lives") or 3 do
			local clone = ranked.Preset.Stock:Clone()
			clone.Parent = ranked.StockL
		end

		sorcerers:GetAttributeChangedSignal("Lives"):Connect(function()
			for _, child in ranked.StockL:GetChildren() do
				if child.Name == "Stock" then
					child:Destroy()
				end
			end

			for _ = 1, sorcerers:GetAttribute("Lives") or 3 do
				local clone = ranked.Preset.Stock:Clone()
				clone.Parent = ranked.StockL
			end

			if workspace:GetAttribute("Match") ~= true then
				return
			end

			ranked.StockL.Position = game.StarterGui.Ranked.StockL.Position + UDim2.new(0, 0, 0, 20)
			TweenService:Create(
				ranked.StockL,
				TweenInfo.new(0.75, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
				{
					Position = game.StarterGui.Ranked.StockL.Position
				}
			):Play()
			v2:PlaySound(sounds.Misc.UI.StockLose, workspace, game.SoundService.Effect)
		end)

		for _ = 1, curses:GetAttribute("Lives") or 3 do
			local clone_2 = ranked.Preset.Stock2:Clone()
			clone_2.Parent = ranked.StockR
		end

		curses:GetAttributeChangedSignal("Lives"):Connect(function()
			for _, child in ranked.StockR:GetChildren() do
				if child.Name == "Stock2" then
					child:Destroy()
				end
			end

			for _ = 1, curses:GetAttribute("Lives") or 3 do
				local clone = ranked.Preset.Stock2:Clone()
				clone.Parent = ranked.StockR
			end

			if workspace:GetAttribute("Match") ~= true then
				return
			end

			ranked.StockR.Position = game.StarterGui.Ranked.StockR.Position + UDim2.new(0, 0, 0, 20)
			TweenService:Create(
				ranked.StockR,
				TweenInfo.new(0.75, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
				{
					Position = game.StarterGui.Ranked.StockR.Position
				}
			):Play()
			v2:PlaySound(sounds.Misc.UI.StockLose, workspace, game.SoundService.Effect)
		end)
		local players = sorcerers:GetPlayers()

		for k, player in players do
			players[k] = player.Name
		end

		ranked.NameL.Text = table.concat(players, ", ")
		local players2 = curses:GetPlayers()

		for k, player in players2 do
			players2[k] = player.Name
		end

		ranked.NameR.Text = table.concat(players2, ", ")
		workspace:GetAttributeChangedSignal("Match"):Connect(function()
			if workspace:GetAttribute("Match") == true then
				local tweenInfo = TweenInfo.new(1.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
				TweenService:Create(ranked.NameL, tweenInfo, {
					Position = game.StarterGui.Ranked.NameL.Position
				}):Play()
				TweenService:Create(ranked.NameR, tweenInfo, {
					Position = game.StarterGui.Ranked.NameR.Position
				}):Play()
				TweenService:Create(ranked.StockL, tweenInfo, {
					Position = game.StarterGui.Ranked.StockL.Position
				}):Play()
				TweenService:Create(ranked.StockR, tweenInfo, {
					Position = game.StarterGui.Ranked.StockR.Position
				}):Play()
			else
				local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.In)
				TweenService:Create(ranked.NameL, tweenInfo, {
					Position = game.StarterGui.Ranked.NameL.Position - uDim
				}):Play()
				TweenService:Create(ranked.NameR, tweenInfo, {
					Position = game.StarterGui.Ranked.NameR.Position - uDim
				}):Play()
				TweenService:Create(ranked.StockL, tweenInfo, {
					Position = game.StarterGui.Ranked.StockL.Position - uDim
				}):Play()
				TweenService:Create(ranked.StockR, tweenInfo, {
					Position = game.StarterGui.Ranked.StockR.Position - uDim
				}):Play()
			end
		end)

		if workspace:GetAttribute("Match") == true then
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
			TweenService:Create(ranked.NameL, tweenInfo, {
				Position = game.StarterGui.Ranked.NameL.Position
			}):Play()
			TweenService:Create(ranked.NameR, tweenInfo, {
				Position = game.StarterGui.Ranked.NameR.Position
			}):Play()
			TweenService:Create(ranked.StockL, tweenInfo, {
				Position = game.StarterGui.Ranked.StockL.Position
			}):Play()
			TweenService:Create(ranked.StockR, tweenInfo, {
				Position = game.StarterGui.Ranked.StockR.Position
			}):Play()
		end

		ranked.Menu.Rematch.MouseButton1Down:Connect(function()
			ranked.Menu.Rematch.Text = "Voted"
			v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Music)
			v2:PlaySound(sounds.Misc.UI.Switch, workspace, game.SoundService.Music)
			v.MatchEnd:Fire(1)
		end)
		ranked.Menu.Return.MouseButton1Down:Connect(function()
			v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Music)
			v.MatchEnd:Fire(2)
		end)
		ranked.Menu.Rematch.MouseEnter:Connect(function()
			v2:PlaySound(sounds.Misc.UI.Hover, workspace, game.SoundService.Effect)
		end)
		ranked.Menu.Return.MouseEnter:Connect(function()
			v2:PlaySound(sounds.Misc.UI.Hover, workspace, game.SoundService.Effect)
		end)
	end)
	local v5 = {
		Countdown = function()
			local WAIT_INTERVAL = 1
			local ranked = localPlayer.PlayerGui:WaitForChild("Ranked")

			for _, child in ranked.Vows:GetChildren() do
				child.Visible = false
			end

			v2:PlaySound(sounds.Misc.UI.Countdown, workspace, game.SoundService.Effect)
			local clone = ranked.Preset.Countdown:Clone()
			clone.Parent = ranked
			TweenService:Create(clone, TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Rotation = 0,
				Size = UDim2.new(0, 200, 0, 200)
			}):Play()
			task.wait(WAIT_INTERVAL)
			clone.Size = UDim2.new(0, 300, 0, 300)
			clone.Rotation = 25
			clone.Text = "<stroke> 2 </stroke>"
			TweenService:Create(clone, TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Rotation = 0,
				Size = UDim2.new(0, 200, 0, 200)
			}):Play()
			task.wait(WAIT_INTERVAL)
			clone.Size = UDim2.new(0, 300, 0, 300)
			clone.Rotation = 25
			clone.Text = "<stroke> 1 </stroke>"
			TweenService:Create(clone, TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Rotation = 0,
				Size = UDim2.new(0, 200, 0, 200)
			}):Play()
			task.wait(WAIT_INTERVAL)
			clone.Size = UDim2.new(0, 300, 0, 300)
			clone.Rotation = 25
			clone.Text = "<stroke> GO! </stroke>"
			TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Rotation = 0,
				Size = UDim2.new(0, 200, 0, 200)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
				TextTransparency = 1
			}):Play()
			Debris:AddItem(clone, 2)
			task.spawn(function()
				repeat
					clone.Text = "<stroke transparency=\"" .. clone.TextTransparency .. "\">GO!</stroke>"
					task.wait()
				until not clone.Parent
			end)
		end,
		Result = function(p, p2, value)
			local ranked = localPlayer.PlayerGui:WaitForChild("Ranked")
			local result = ranked:FindFirstChild("Result")

			if not result then
				result = game.StarterGui.Ranked.Result:Clone()
				result.Parent = ranked
			end

			v2:PlaySound(sounds.Misc.UI.DuelEnd, workspace, game.SoundService.Music)

			if p2 then
				if v4 then
					MVP:MVP_End(v4, true)
					v4 = nil
				end

				v4 = MVP:MVP_Play(p2, value or "King Of Curses")
			end

			if localPlayer.Team == p then
				v2:PlaySound(sounds.Misc.UI.Win, workspace, game.SoundService.Effect)
				result.Star.Visible = true
				result.Flash.Visible = true
				result.Fade.Visible = true
				TweenService:Create(
					result.Star,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = UDim2.new(0, 0, 0, 0),
						Rotation = 0
					}
				):Play()
				TweenService:Create(
					result.Flash,
					TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = UDim2.new(1, 0, 0.2, 0)
					}
				):Play()
				TweenService:Create(
					result.Fade,
					TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = UDim2.new(1, 0, 0.5, 0)
					}
				):Play()
				task.delay(2, function()
					local tweenInfo = TweenInfo.new(0.5)
					TweenService:Create(result.Star, tweenInfo, {
						ImageTransparency = 1
					}):Play()
					TweenService:Create(result.Flash, tweenInfo, {
						TextTransparency = 1
					}):Play()
					TweenService:Create(result.Fade, tweenInfo, {
						ImageTransparency = 1
					}):Play()
					Debris:AddItem(result, 0.5)

					repeat
						result.Flash.Text = "<stroke transparency=\"" .. result.Flash.TextTransparency .. "\">SHENANIGAN'ED!</stroke>"
						task.wait()
					until not result.Parent
				end)
			else
				v2:PlaySound(sounds.Misc.UI.Lose, workspace, game.SoundService.Effect)
				result.Flash.TextColor3 = Color3.fromRGB(171, 171, 255)
				result.Fade.ImageColor3 = Color3.fromRGB(85, 85, 127)
				result.Flash.Visible = true
				result.Fade.Visible = true
				TweenService:Create(
					result.Flash,
					TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = UDim2.new(1, 0, 0.2, 0)
					}
				):Play()
				TweenService:Create(
					result.Fade,
					TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = UDim2.new(1, 0, 0.5, 0)
					}
				):Play()
				task.delay(2, function()
					local tweenInfo = TweenInfo.new(0.5)
					TweenService:Create(result.Flash, tweenInfo, {
						TextTransparency = 1
					}):Play()
					TweenService:Create(result.Fade, tweenInfo, {
						ImageTransparency = 1
					}):Play()
					Debris:AddItem(result, 0.5)

					repeat
						result.Flash.Text = "<stroke transparency=\"" .. result.Flash.TextTransparency .. "\">SHENANIGAN'ED!</stroke>"
						task.wait()
					until not result.Parent
				end)
			end
		end,
		Vows = function()
			local ranked = localPlayer.PlayerGui:WaitForChild("Ranked")
			local vows = ranked.Vows
			vows.TextLabel.Visible = true
			v2:PlaySound(sounds.Misc.UI.VowChoose, workspace, game.SoundService.Effect)
			local v6 = deepCopy(v3)
			local total = 0
			local v7 = {}

			for i = 1, 3 do
				local v8 = vows["Vow" .. i]
				local v9 = i
				task.delay(total, function()
					v2:PlaySound(sounds.Misc.UI.CardFlip, workspace, game.SoundService.Effect)
					v8.Position -= UDim2.new(0, 0, 1, 0)
					TweenService:Create(v8, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
						Position = v8.Position + UDim2.new(0, 0, 1, 0)
					}):Play()
					v8.AnchorPoint = Vector2.new(0.5, 0.5)
					v8.Size = UDim2.new(0, 200, 0, 250)
					local v11 = math.random(1, #v6)
					local v12 = v6[v11]
					v8.Title.Text = v12.Title
					v8.BG.Image = "rbxassetid://" .. v12.Background

					for k, v13 in v12.Info do
						local clone = ranked.Preset.Info:Clone()
						clone.Text = "• " .. v13
						clone.Parent = v8.Info
					end

					local mouseEnterConnection = v8.TextButton.MouseEnter:Connect(function()
						v2:PlaySound(sounds.Misc.UI.Hover, workspace, game.SoundService.Effect)
						TweenService:Create(v8, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
							Size = UDim2.new(0, 205, 0, 255),
							AnchorPoint = Vector2.new(0.5, 0.525)
						}):Play()
					end)
					local mouseLeaveConnection = v8.TextButton.MouseLeave:Connect(function()
						TweenService:Create(v8, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
							Size = UDim2.new(0, 200, 0, 250),
							AnchorPoint = Vector2.new(0.5, 0.5)
						}):Play()
					end)
					local mouseButton1DownConnection = v8.TextButton.MouseButton1Down:Connect(function()
						v.Vows:Fire(v12.Name)
						v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
						v2:PlaySound(sounds.Misc.UI.Switch, workspace, game.SoundService.Effect)

						for i2, frame in vows:GetChildren() do
							if not frame:IsA("Frame") then
								continue
							end

							local color = frame == v8 and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
							frame.UIStroke.Color = color
							frame.Title.TextColor3 = color

							for i3, label in frame.Info:GetChildren() do
								if label:IsA("TextLabel") then
									label.TextColor3 = color
								end
							end
						end
					end)
					v8.Visible = true
					table.insert(v7, mouseEnterConnection)
					table.insert(v7, mouseLeaveConnection)
					table.insert(v7, mouseButton1DownConnection)
					table.remove(v6, v11)

					if v9 == 1 then
						repeat
							for i2 = 1, 3 do
								local v13 = math.random(100, 200) / 100
								local tweenInfo = TweenInfo.new(v13, Enum.EasingStyle.Linear)
								local v14 = math.random(40, 80) / 100
								local clone = ranked.Preset.Particle:Clone()
								clone.Position = UDim2.new(math.random(0, 100) / 100, 0, 1.3, 0)
								clone.Size = UDim2.new(v14, 0, v14, 0)
								clone.Parent = vows["Vow" .. i2].Effect
								TweenService:Create(clone, tweenInfo, {
									Position = clone.Position - UDim2.new(0, 0, 1.6, 0)
								}):Play()
								Debris:AddItem(clone, v13)
							end

							task.wait(0.1)
						until vows.Vow1.Visible == false
					end
				end)
				total += 0.15
			end

			for i = 10, 1, -1 do
				vows.TextLabel.Text = "Choose a binding vow (" .. i .. "):"
				task.wait(1)
			end

			for _, child in ranked.Vows:GetChildren() do
				child.Visible = false
			end

			for _, connection in v7 do
				connection:Disconnect()
			end

			for _, frame in vows:GetChildren() do
				if not frame:IsA("Frame") then
					continue
				end

				local color = Color3.new(0, 0, 0)
				frame.UIStroke.Color = color
				frame.Title.TextColor3 = color

				for _, label in frame.Info:GetChildren() do
					if label:IsA("TextLabel") then
						label:Destroy()
					end
				end
			end
		end,
		Teleport = function(text)
			local ranked = localPlayer.PlayerGui:WaitForChild("Ranked")
			local clone = ranked.Preset.Teleport:Clone()
			clone.Parent = ranked.Parent
			clone.TextLabel.Text = text
			clone.Sound.SoundGroup = game.SoundService.Effect
			clone.Sound:Play()
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(clone.Frame, TweenInfo.new(0.3), {
				BackgroundTransparency = 0.5
			}):Play()
			local TweenService3 = game:GetService("TweenService")
			TweenService3:Create(clone.TextLabel, TweenInfo.new(0.3), {
				TextTransparency = 0
			}):Play()
		end,
		Menu = function(p, options)
			local ranked = localPlayer.PlayerGui:WaitForChild("Ranked")
			ranked.Menu.Visible = true
			ranked.Menu.Rematch.Text = "Rematch (" .. p .. " Left)"
			ranked.Menu.Rematch.Visible = true
			ranked.Menu.Return.Visible = true
			TweenService:Create(ranked.Menu, TweenInfo.new(0.3), {
				GroupTransparency = 0.5
			}):Play()

			for k, text in options or {} do
				local clone = ranked.Parent.Roulette.Preset.Rewards:Clone()
				clone.Parent = ranked.Stats
				clone.Text = text
				clone.Visible = false
				task.delay(0.3 + k * 0.075, function()
					if not clone.Parent then
						return
					end

					clone.Visible = true
					v2:PlaySound(sounds.Misc.UI.Coin, workspace, game.SoundService.Effect)
				end)
			end

			ranked.Stats.Visible = true
		end,
		MenuClose = function()
			local ranked = localPlayer.PlayerGui:WaitForChild("Ranked")
			TweenService:Create(ranked.Menu, TweenInfo.new(0.3), {
				GroupTransparency = 1
			}):Play()
			task.wait(0.3)
			ranked.Menu.Visible = false

			for _, uIListLayout in ranked.Stats:GetChildren() do
				if not uIListLayout:IsA("UIListLayout") then
					uIListLayout:Destroy()
				end
			end

			ranked.Stats.Visible = false
		end,
		Rematch = function()
			local clone = localPlayer.PlayerGui:WaitForChild("Ranked").Preset.Teleport:Clone()
			Debris:AddItem(clone, 1.5)
			clone.Parent = localPlayer.PlayerGui
			clone.TextLabel.Text = "REMATCHING!"
			v2:PlaySound(sounds.Misc.UI.Gamemode, workspace, game.SoundService.Effect)
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(clone.Frame, TweenInfo.new(0.3), {
				BackgroundTransparency = 0.5
			}):Play()
			local TweenService3 = game:GetService("TweenService")
			TweenService3:Create(clone.TextLabel, TweenInfo.new(0.3), {
				TextTransparency = 0
			}):Play()
			task.wait(0.3)
			local TweenService4 = game:GetService("TweenService")
			TweenService4:Create(clone.Frame, TweenInfo.new(0.7), {
				BackgroundTransparency = 0
			}):Play()
			task.wait(0.7)
			local TweenService5 = game:GetService("TweenService")
			TweenService5:Create(clone.Frame, TweenInfo.new(0.5), {
				BackgroundTransparency = 1
			}):Play()
			local TweenService6 = game:GetService("TweenService")
			TweenService6:Create(clone.TextLabel, TweenInfo.new(0.5), {
				TextTransparency = 1
			}):Play()

			if v4 then
				MVP:MVP_End(v4, true)
				v4 = nil
			end
		end
	}
	v.Effects:Connect(function(p, ...)
		local v6 = v5[p]

		if not v6 then
			return
		end

		v6(...)
	end)
end

function controller.KnitStart(_) end

function controller.KnitInit(_)
	v = Knit.GetService("DuelService")
	v2 = Knit.GetController("FXController")
end

return controller