local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
require(replicatedStorage.Modules.Icon)
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local PlayerModule = require(localPlayer.PlayerScripts.PlayerModule)
local MVP = require(replicatedStorage.Modules.MVP)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "RouletteController"
})

function controller.Start(_)
	task.spawn(function()
		local roulette = localPlayer.PlayerGui:WaitForChild("Roulette")
		roulette.Enabled = true
		workspace:GetAttributeChangedSignal("Timer"):Connect(function()
			if workspace:GetAttribute("Timer") == nil then
				roulette.Time.Visible = false
				return
			end

			roulette.Time.Text = workspace:GetAttribute("Timer")
			roulette.Time.Size = UDim2.new(1, 0, 0.15, 0)
			roulette.Time.AnchorPoint = Vector2.new(0.5, 0.2)
			roulette.Time.Rotation = 5
			roulette.Time.Visible = true
			TweenService:Create(roulette.Time, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.new(1, 0, 0.1, 0),
				AnchorPoint = Vector2.new(0.5, 0),
				Rotation = 0
			}):Play()
		end)
		local buttons = localPlayer.PlayerGui.Roulette.Gamemode_Items.Buttons
		RunService.RenderStepped:Connect(function(dt)
			roulette.Load.WaitSpin.Rotation += 30 * dt
			local v4

			if localPlayer.Team and localPlayer.Team.Name == "Lobby" and not (localPlayer.Character and localPlayer.Character:GetAttribute("Dead")) then
				localPlayer.PlayerGui.Main.Enabled = false

				if _G.MVP_PLAYING == true then
					buttons.Visible = false
				else
					buttons.Visible = true
				end

				v4 = _G.Crow and true or false
			else
				localPlayer.PlayerGui.Main.Enabled = true
				buttons.Visible = false
				v4 = true
			end

			if workspace.Effects:FindFirstChild("WaitAmbience") then
				if v4 == false then
					workspace.Effects.WaitAmbience.Volume = workspace.Effects.WaitAmbience.Vol.Value
					workspace.Effects.Music.Volume = 0
				else
					workspace.Effects.WaitAmbience.Volume = 0
					workspace.Effects.Music.Volume = workspace.Effects.Music.Vol.Value
				end
			end
		end)
		buttons.Spectate.MouseButton1Down:Connect(function()
			v3:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
			v3:PlaySound(sounds.Misc.UI.Switch, workspace, game.SoundService.Effect)
			v.Spectate:Fire()
		end)
		local v4 = false
		buttons.AFK.MouseButton1Down:Connect(function()
			v3:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
			v3:PlaySound(sounds.Misc.UI.Switch, workspace, game.SoundService.Effect)
			v4 = not v4
			buttons.AFK.BackgroundColor3 = v4 == true and Color3.fromRGB(255, 152, 152) or Color3.fromRGB(170, 255, 127)
			buttons.AFK.Text = v4 == true and "AFK" or "PLAYING"
			v.Spectate:Fire(v4)
		end)
	end)
	local v4 = {
		Transition = function(text)
			local load = localPlayer.PlayerGui:WaitForChild("Roulette"):WaitForChild("Load")
			load.Gamemode.Text = text
			load.WaitTime.Size = UDim2.new(0, 0, 0, 10)
			v3:PlaySound(sounds.Misc.UI.Load1, workspace, game.SoundService.Effect)
			local tweenInfo = TweenInfo.new(0.5)
			TweenService:Create(load, tweenInfo, {
				BackgroundTransparency = 0,
				ImageTransparency = 0
			}):Play()
			TweenService:Create(load.WaitSpin, tweenInfo, {
				ImageTransparency = 0
			}):Play()
			TweenService:Create(load.WaitTime, tweenInfo, {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(load.WaitTime, TweenInfo.new(1), {
				Size = UDim2.new(1, 0, 0, 10)
			}):Play()
			TweenService:Create(load.Gamemode, tweenInfo, {
				TextTransparency = 0
			}):Play()

			repeat
				task.wait()
			until not workspace:GetAttribute("Loading")

			local tweenInfo2 = TweenInfo.new(1)
			v3:PlaySound(sounds.Misc.UI.Load2, workspace, game.SoundService.Effect)
			TweenService:Create(load, tweenInfo2, {
				BackgroundTransparency = 1,
				ImageTransparency = 1
			}):Play()
			TweenService:Create(load.WaitSpin, tweenInfo2, {
				ImageTransparency = 1
			}):Play()
			TweenService:Create(load.WaitTime, tweenInfo2, {
				BackgroundTransparency = 1
			}):Play()
			TweenService:Create(load.Gamemode, tweenInfo2, {
				TextTransparency = 1
			}):Play()
		end,
		Result = function(items)
			local roulette = localPlayer.PlayerGui:WaitForChild("Roulette")
			v3:PlaySound(sounds.Misc.UI.DuelEnd, workspace, game.SoundService.Music)
			local v5 = 0
			local v6 = {}
			local v7 = nil
			local v8 = nil

			for k, item in items do
				local child = game.Players:FindFirstChild(item[3])

				if child then
					if child == localPlayer then
						v8 = item[2]
					end

					if v5 <= item[1] then
						v5 = item[1]
						v7 = child
					end

					table.insert(v6, { child.UserId, child.DisplayName or child.Name, item[1] })
				else
					items[k] = nil
				end
			end

			table.sort(v6, function(a, b)
				return a[3] > b[3]
			end)
			local v9 = nil

			if v7 then
				v9 = MVP:MVP_Play(v7, v7:GetAttribute("MVP") or "King of Curses")
			else
				task.wait(8.5)
			end

			local clone = roulette.Preset.Winner:Clone()
			clone.Parent = roulette.Result
			TweenService:Create(clone, TweenInfo.new(1), {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(clone.Total, TweenInfo.new(1), {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(clone.Title, TweenInfo.new(1), {
				TextTransparency = 0
			}):Play()
			TweenService:Create(clone.Total.Title, TweenInfo.new(1), {
				TextTransparency = 0
			}):Play()
			task.wait(1)
			clone.Flash.BackgroundTransparency = 0
			TweenService:Create(clone.Flash, TweenInfo.new(0.5), {
				BackgroundTransparency = 1
			}):Play()
			clone.Single.Visible = true

			for k, v10 in v6 do
				local clone2 = roulette.Preset.PlaceLead:Clone()
				clone2.Title.Text = "#" .. k .. " " .. v10[2]
				clone2.Score.Text = v10[3]
				clone2.LayoutOrder = k
				clone2.Parent = clone.Single

				if k <= 3 then
					clone2.BackgroundTransparency = 0

					if k == 1 then
						clone2.First.Enabled = true
					elseif k == 2 then
						clone2.Second.Enabled = true
					else
						clone2.Third.Enabled = true
					end
				end

				local v11 = v10
				task.spawn(function()
					local userThumbnailAsync = game.Players:GetUserThumbnailAsync(
						v11[1],
						Enum.ThumbnailType.AvatarBust,
						Enum.ThumbnailSize.Size150x150
					)
					clone2.UserIcon.Image = userThumbnailAsync
				end)
			end

			task.spawn(function()
				if not v8 then
					return
				end

				local total = 0

				for k, v10 in v8 do
					if math.ceil(v10) <= 0 then
						continue
					end

					task.wait(0.6)
					total += math.ceil(v10)
					local clone2 = roulette.Preset.Rewards:Clone()
					clone2.Text = k .. " (" .. math.ceil(v10) .. "$)"
					clone2.Parent = clone.Rewards
					clone.Total.Total.Text = math.clamp(total, 0, 50) .. "$"
					v3:PlaySound(sounds.Misc.UI.Coin, workspace, game.SoundService.Effect)
				end

				clone.Total.Total.Text = math.clamp(total, 0, 50) .. "$"

				if total <= 0 then
					local clone2 = roulette.Preset.Rewards:Clone()
					clone2.Text = "NOTHING??????? (0$)"
					clone2.Parent = clone.Rewards
					v3:PlaySound(sounds.Misc.UI.CoinZero, workspace, game.SoundService.Music)
					v3:PlaySound(sounds.Misc.UI.CoinZero2, workspace, game.SoundService.Effect)
					v2.Give:Fire("Poor Performance")
				else
					v3:PlaySound(sounds.Misc.UI.CoinTotal, workspace, game.SoundService.Music)
					task.wait(0.5)
					v3:PlaySound(sounds.Misc.UI.CoinTotal2, workspace, game.SoundService.Effect)
				end
			end)
			task.wait(5.5)
			task.wait(0.5)
			clone:Destroy()

			if v9 then
				MVP:MVP_End(v9, true)
			end
		end,
		ResultTeam = function(items, p, p2, p3)
			local roulette = localPlayer.PlayerGui:WaitForChild("Roulette")
			v3:PlaySound(sounds.Misc.UI.DuelEnd, workspace, game.SoundService.Music)
			local v5 = 0
			local v6 = {}
			local v7 = 0
			local v8 = {}
			local v9 = nil
			local v10 = nil
			local v11 = nil

			for k, item in items do
				local child = game.Players:FindFirstChild(item[3])

				if child then
					if child == localPlayer then
						v10 = item[2]
					end

					if child.Team == p then
						if v5 <= item[1] then
							v5 = item[1]
							v9 = child
						end

						table.insert(v6, { child.UserId, child.DisplayName or child.Name, item[1] })
					else
						if v7 <= item[1] then
							v7 = item[1]
							v11 = child
						end

						table.insert(v8, { child.UserId, child.DisplayName or child.Name, item[1] })
					end
				else
					items[k] = nil
				end
			end

			table.sort(v6, function(a, b)
				return a[3] > b[3]
			end)
			table.sort(v8, function(a, b)
				return a[3] > b[3]
			end)

			if p3 == p then
				v11 = nil
			else
				v9 = nil
			end

			local v12 = nil

			if v9 or v11 then
				v12 = MVP:MVP_Play(v9 or v11, (v9 or v11):GetAttribute("MVP") or "King of Curses")
			else
				task.wait(8.5)
			end

			local clone = roulette.Preset.Winner:Clone()
			clone.Parent = roulette.Result
			TweenService:Create(clone, TweenInfo.new(1), {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(clone.Total, TweenInfo.new(1), {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(clone.Title, TweenInfo.new(1), {
				TextTransparency = 0
			}):Play()
			TweenService:Create(clone.Total.Title, TweenInfo.new(1), {
				TextTransparency = 0
			}):Play()
			task.wait(1)
			clone.Flash.BackgroundTransparency = 0
			TweenService:Create(clone.Flash, TweenInfo.new(0.5), {
				BackgroundTransparency = 1
			}):Play()
			clone.Team.Visible = true
			clone.Team.Win.UIStroke.Color = p.TeamColor.Color
			clone.Team.Lose.UIStroke.Color = p2.TeamColor.Color

			for k, v13 in v6 do
				local clone2 = roulette.Preset.PlaceLead:Clone()
				clone2.Title.Text = "#" .. k .. " " .. v13[2]
				clone2.Score.Text = v13[3]
				clone2.LayoutOrder = k
				clone2.Size = UDim2.new(1, -10, 0.2, 0)
				clone2.Parent = clone.Team.Win
				local v14 = v13
				task.spawn(function()
					local userThumbnailAsync = game.Players:GetUserThumbnailAsync(
						v14[1],
						Enum.ThumbnailType.AvatarBust,
						Enum.ThumbnailSize.Size150x150
					)
					clone2.UserIcon.Image = userThumbnailAsync
				end)
			end

			for k, v13 in v8 do
				local clone2 = roulette.Preset.PlaceLead:Clone()
				clone2.Title.Text = "#" .. k .. " " .. v13[2]
				clone2.Score.Text = v13[3]
				clone2.LayoutOrder = k
				clone2.Size = UDim2.new(1, -10, 0.2, 0)
				clone2.Parent = clone.Team.Lose
				local v14 = v13
				task.spawn(function()
					local userThumbnailAsync = game.Players:GetUserThumbnailAsync(
						v14[1],
						Enum.ThumbnailType.AvatarBust,
						Enum.ThumbnailSize.Size150x150
					)
					clone2.UserIcon.Image = userThumbnailAsync
				end)
			end

			task.spawn(function()
				if not v10 then
					return
				end

				local total = 0

				for k, v13 in v10 do
					if math.ceil(v13) <= 0 then
						continue
					end

					task.wait(0.6)
					total += math.ceil(v13)
					local clone2 = roulette.Preset.Rewards:Clone()
					clone2.Text = k .. " (" .. math.ceil(v13) .. "$)"
					clone2.Parent = clone.Rewards
					clone.Total.Total.Text = math.clamp(total, 0, 50) .. "$"
					v3:PlaySound(sounds.Misc.UI.Coin, workspace, game.SoundService.Effect)
				end

				clone.Total.Total.Text = math.clamp(total, 0, 50) .. "$"

				if total <= 0 then
					local clone2 = roulette.Preset.Rewards:Clone()
					clone2.Text = "NOTHING??????? (0$)"
					clone2.Parent = clone.Rewards
					v3:PlaySound(sounds.Misc.UI.CoinZero, workspace, game.SoundService.Music)
					v3:PlaySound(sounds.Misc.UI.CoinZero2, workspace, game.SoundService.Effect)
					v2.Give:Fire("Poor Performance")
				else
					v3:PlaySound(sounds.Misc.UI.CoinTotal, workspace, game.SoundService.Music)
					task.wait(0.5)
					v3:PlaySound(sounds.Misc.UI.CoinTotal2, workspace, game.SoundService.Effect)
				end
			end)
			task.wait(5.5)
			task.wait(0.5)
			clone:Destroy()

			if v12 then
				MVP:MVP_End(v12, true)
			end
		end,
		Announce = function(p, p2)
			local gamemode = localPlayer.PlayerGui:WaitForChild("Roulette").Gamemode
			v3:PlaySound(sounds.Misc.UI.Gamemode, workspace, game.SoundService.Effect)
			gamemode.Text = p .. "\n<font size=\"30\">" .. p2 .. "</font>"
			gamemode.Gamemode.Text = gamemode.Text
			TweenService:Create(gamemode, TweenInfo.new(1), {
				TextTransparency = 0
			}):Play()
			TweenService:Create(gamemode.Gamemode, TweenInfo.new(1), {
				TextTransparency = 0
			}):Play()
			task.wait(5)
			TweenService:Create(gamemode, TweenInfo.new(5), {
				TextTransparency = 1
			}):Play()
			TweenService:Create(gamemode.Gamemode, TweenInfo.new(5), {
				TextTransparency = 1
			}):Play()
		end,
		Credits = function(text, p)
			local roulette = localPlayer.PlayerGui:WaitForChild("Roulette")
			local clone = roulette.Preset.MapCredits:Clone()
			clone.Text = text
			clone.Creators.Text = "By " .. p
			clone.Parent = roulette
			TweenService:Create(clone, TweenInfo.new(2.5, Enum.EasingStyle.Exponential), {
				Position = UDim2.new(0, 20, 0, 100),
				TextTransparency = 0,
				TextStrokeTransparency = 0
			}):Play()
			TweenService:Create(clone.Creators, TweenInfo.new(2.5, Enum.EasingStyle.Exponential), {
				TextTransparency = 0,
				TextStrokeTransparency = 0
			}):Play()
			task.wait(2.5)
			local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			TweenService:Create(clone, tweenInfo, {
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}):Play()
			TweenService:Create(clone.Creators, tweenInfo, {
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}):Play()
			Debris:AddItem(clone, 1.5)
		end,
		Crow = function(instance)
			local crowUpd = instance:WaitForChild("CrowUpd", 0.5)

			if not crowUpd then
				return
			end

			_G.Crow = crowUpd
			local clone = game.ReplicatedStorage.Utils.Todo.Clap:Clone()
			clone.Position = instance.HumanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1.5)
			clone.Attachment.Sparks:Emit(20)
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(0, 0, 0),
				Transparency = 1
			}):Play()
			v3:PlaySound(sounds.Todo.Clap, clone, game.SoundService.Effect)
			local cFrame = instance.HumanoidRootPart.CFrame
			local cFrame2 = instance.HumanoidRootPart.CFrame
			workspace.CurrentCamera.CameraSubject = instance.Head
			local total = 1

			while true do
				local v5 = RunService.Heartbeat:Wait()

				if not instance.Parent then
					break
				end

				local cFrame3 = workspace.CurrentCamera.CFrame
				local moveVector = PlayerModule:GetControls():GetMoveVector()
				local v6 = cFrame3.RightVector * moveVector.X + -cFrame3.LookVector * moveVector.Z
				local lookVector = cFrame3.LookVector

				if not _G.Shift then
					if moveVector == createVector(0, 0, 0) then
						lookVector = cFrame.LookVector
						total = 1
					else
						total += 0.4 * v5
						lookVector = v6
					end
				end

				cFrame2 = CFrame.lookAlong(cFrame2.Position + v6 * v5 * 20 * total, lookVector)
				cFrame = cFrame:Lerp(cFrame2, (math.clamp(10 * v5, 0, 1)))
				crowUpd:FireServer(cFrame)
				instance.HumanoidRootPart.CFrame = cFrame

				if not instance.Parent then
					break
				end
			end

			_G.Crow = nil
			local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
			workspace.CurrentCamera.CameraSubject = character:WaitForChild("Humanoid", 1)
		end,
		ClapSpawn = function(position)
			local clone = game.ReplicatedStorage.Utils.Todo.Clap:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1.5)
			clone.Attachment.Sparks:Emit(20)
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(0, 0, 0),
				Transparency = 1
			}):Play()
			v3:PlaySound(sounds.Todo.Clap, clone, game.SoundService.Effect)
		end,
		CrowExplode = function(position)
			local clone = game.ReplicatedStorage.Utils.Damage.CrowExplode:Clone()
			clone.Position = position
			Debris:AddItem(clone, 1.5)
			clone.Parent = workspace.Effects
			clone.Sparks:Emit(20)
			clone.Feathers:Emit(12)
			clone.FeathersVariant:Emit(12)
			clone.ParticleEmitter:Emit(15)
			v3:PlaySound(sounds.Misc.Crow, clone, game.SoundService.Effect)
			v3:PlaySound(sounds.Mahito.Soulfire.Hit, clone, game.SoundService.Effect)
		end,
		CrowMad = function(instance)
			local position = instance.HumanoidRootPart.Position
			v3:PlaySound(sounds.Misc.CrowMad, instance.Torso, game.SoundService.Effect)
			local clone = utils.Damage.Flames:Clone()
			clone.Parent = instance.Torso
			clone:Emit(30)
			task.wait(1)
			v3:PlaySound(sounds.Misc.CrowMad2, instance.Torso, game.SoundService.Effect)
			v3:PlaySound(sounds.Naoya.TopSpeed.SonicBoom, instance.Torso, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 100 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			task.wait(0.1)

			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local clone2 = utils.Choso.CounterSwing.Shock:Clone()
			clone2.Size = createVector(6, 30, 6)
			clone2.CFrame = instance.HumanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.2)
			TweenService:Create(clone2, TweenInfo.new(0.2), {
				Size = createVector(25, 0, 25),
				Transparency = 1,
				Position = clone2.Position + instance.HumanoidRootPart.CFrame.LookVector * 10
			}):Play()
		end,
		CaptureRealm = function(cFrame, folder)
			local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and cFrame) then
				return
			end

			local folder2 = Instance.new("Folder", workspace.Effects)
			Debris:AddItem(folder2, 2)
			local attachment = Instance.new("Attachment", folder.Torso)
			Debris:AddItem(attachment, 2)
			local random = Random.new()

			for _ = 1, 10 do
				local clone = utils.Misc.Items.Prison.PrisonCap:Clone()
				clone.Beam.Attachment1 = attachment
				clone.CFrame = cFrame
				clone.Parent = folder2
				clone.Beam.CurveSize0 = math.random(-10, 10)
				clone.Beam.CurveSize1 = math.random(-10, 10)
				TweenService:Create(
					clone.Beam,
					TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
					{
						CurveSize0 = 0,
						CurveSize1 = 0
					}
				):Play()
				local cframe = CFrame.lookAlong(cFrame.Position, random:NextUnitVector())
				TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					CFrame = cFrame + cframe.LookVector * math.random(10, 20)
				}):Play()
				task.delay(0.3, function()
					local cFrame2 = clone.CFrame
					TweenService:Create(
						clone.Close,
						TweenInfo.new(0.45, Enum.EasingStyle.Circular, Enum.EasingDirection.In),
						{
							Value = 1
						}
					):Play()

					repeat
						clone.CFrame = cFrame2:Lerp(humanoidRootPart.CFrame, clone.Close.Value)
						task.wait()
					until not (clone.Parent and humanoidRootPart.Parent)

					clone:Destroy()
				end)
			end

			task.wait(0.75)

			if not (humanoidRootPart.Parent and folder.Parent) then
				return
			end

			local clone = utils.Misc.Items.Prison.PrisonSeal:Clone()
			clone.Weld.Part0 = humanoidRootPart
			clone.Parent = folder2

			for _, descendant in folder:GetDescendants() do
				if descendant:IsA("BasePart") or descendant:IsA("Decal") then
					descendant.Transparency = 1
				end
			end

			local clone2 = utils.Megumi.Mahoraga.WorldSlash.mesh:Clone()
			clone2.Position = clone.Position - createVector(0, 2, 0)
			clone2.Decal.Transparency = 0
			clone2.Mesh.Scale = createVector(2, -5, 2)
			clone2.Decal.Transparency = 0.4
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(2, Enum.EasingStyle.Exponential), {
				CFrame = clone2.CFrame * CFrame.Angles(0, -3.12413936106985, 0)
			}):Play()
			TweenService:Create(clone2.Mesh, TweenInfo.new(2, Enum.EasingStyle.Exponential), {
				Scale = createVector(15, 25, 15)
			}):Play()
			TweenService:Create(clone2.Decal, TweenInfo.new(2, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
			Debris:AddItem(clone2, 2)

			for _ = 1, 4 do
				local v5 = math.random(300, 500) / 10
				local clone3 = utils.Gojo.LapseBlue.Throw:Clone()
				clone3.Transparency = 0.7
				clone3.Position = folder.Head.Position
				clone3.Orientation = Vector3.new(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))
				clone3.Size = createVector(0, 0, 7)
				clone3.Parent = workspace.Effects
				TweenService:Create(clone3, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {
					Size = Vector3.new(v5, v5, 0),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone3, 0.7)
				task.wait(0.025)
			end

			if (workspace.CurrentCamera.CFrame.Position - clone.Position).Magnitude < 120 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
			end

			task.wait(1)
			local clone3 = game.ReplicatedStorage.Utils.Todo.Clap:Clone()
			clone3.Position = clone.Position
			clone3.Parent = workspace.Effects
			Debris:AddItem(clone3, 1.5)
			clone3.Attachment.Sparks:Emit(20)
			TweenService:Create(clone3, TweenInfo.new(0.3), {
				Size = createVector(0, 0, 0),
				Transparency = 1
			}):Play()
			v3:PlaySound(sounds.Todo.Clap, clone3, game.SoundService.Effect)
			clone.Transparency = 1
		end,
		Kit = function(instance, p)
			local clone = utils.Misc.RouletteKit:Clone()
			clone.Parent = localPlayer.PlayerGui
			instance.AncestryChanged:Once(function()
				clone:Destroy()
			end)
			local total = 0

			for i = 1, 3 do
				local v5 = clone.Vows["Vow" .. i]
				local v6 = i
				task.delay(total, function()
					v3:PlaySound(sounds.Misc.UI.CardFlip, workspace, game.SoundService.Effect)
					v5.Position -= UDim2.new(0, 0, 1, 0)
					TweenService:Create(v5, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
						Position = v5.Position + UDim2.new(0, 0, 1, 0)
					}):Play()
					v5.AnchorPoint = Vector2.new(0.5, 0.5)
					v5.Size = UDim2.new(0, 200, 0, 250)
					v5.Title.Text = p[v6].Title

					for k, text in p[v6].Moveset do
						local clone2 = clone.Preset.Info:Clone()
						clone2.Text = text
						clone2.Parent = v5.Info
						clone2.LayoutOrder = k
					end

					if p[v6].Health then
						local clone2 = clone.Preset.SubInfo:Clone()
						clone2.Text = `Max health : {p[v6].Health}`
						clone2.Parent = v5.Info
						clone2.LayoutOrder = 100
					end

					if p[v6].Author then
						local clone2 = clone.Preset.SubInfo:Clone()
						clone2.Text = `Author : {p[v6].Author}`
						clone2.Parent = v5.Info
						clone2.LayoutOrder = 101
					end

					if p[v6].Rarity == 2 then
						v5.Basic.Enabled = false
						v5.Rare.Enabled = true
					elseif p[v6].Rarity == 3 then
						v5.Basic.Enabled = false
						v5.Legendary.Enabled = true
					end

					v5.Visible = true
					v5.TextButton.MouseEnter:Connect(function()
						v3:PlaySound(sounds.Misc.UI.Hover, workspace, game.SoundService.Effect)
						TweenService:Create(v5, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
							Size = UDim2.new(0, 205, 0, 255),
							AnchorPoint = Vector2.new(0.5, 0.525)
						}):Play()
					end)
					v5.TextButton.MouseLeave:Connect(function()
						TweenService:Create(v5, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
							Size = UDim2.new(0, 200, 0, 250),
							AnchorPoint = Vector2.new(0.5, 0.5)
						}):Play()
					end)
					v5.TextButton.MouseButton1Down:Connect(function()
						instance:FireServer(p[v6].Index)
						v3:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
						v3:PlaySound(sounds.Misc.UI.Switch, workspace, game.SoundService.Effect)
					end)
				end)
				total += 0.1
			end
		end
	}
	v.Effects:Connect(function(p, ...)
		local v5 = v4[p]

		if not v5 then
			return
		end

		v5(...)
	end)
end

function controller.KnitStart(_)
	local TextChatService = game:GetService("TextChatService")
	TextChatService.MessageReceived:Connect(function(p)
		if not workspace:GetAttribute("Roulette") then
			return
		end

		local text = p.Text
		local textSource = p.TextSource

		if not textSource then
			return
		end

		local child = workspace.Effects.Crows:FindFirstChild(textSource.Name)

		if not child then
			return
		end

		TextChatService:DisplayBubble(child.Head, text)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("RouletteService")
	v2 = Knit.GetService("AchievementService")
	v3 = Knit.GetController("FXController")
end

return controller