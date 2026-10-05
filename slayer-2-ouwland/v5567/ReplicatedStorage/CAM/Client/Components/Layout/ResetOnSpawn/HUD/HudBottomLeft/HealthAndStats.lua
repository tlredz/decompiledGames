local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = require(script.Parent.Stats)
local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local SettingsKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local localPlayer = Players.LocalPlayer
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.35, Enum.EasingStyle.Sine)
local info2 = faye.Info(2, Enum.EasingStyle.Quad)
local TweenService = game:GetService("TweenService")
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local tweenInfo = TweenInfo.new(gameSettings.lifeLostFadeTime)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local LivesBars = require(script.Parent.LivesBars)
return function(maid, _)
	local value = maid:Value(UDim2.fromScale(1, 1))
	local value2 = maid:Value(1)
	local text = maid:Value("100 / 100")
	local textColor = maid:Value(Color3.new())
	local connections = {}

	local function bindHumanoid(humanoid)
		local v = 0
		local v2 = -1
		local v3 = -1

		local function updHealth(flag: boolean?)
			local health = humanoid.Health
			local maxHealth = humanoid.MaxHealth

			if maxHealth <= 0 then
				return
			end

			local v4 = health / maxHealth
			local v5 = v2 ~= v4
			local v6 = v3 ~= maxHealth

			if v5 or v6 then
				if not v5 or v6 then
					v3 = maxHealth
				end

				local v7 = math.random(1, 999)
				value:Set(UDim2.fromScale(v4, 1))
				text:Set((`{math.floor(health)} / {maxHealth}`))
				textColor:Set(Utility.Lerp_Color2(Color3.new(0.95, 0, 0), textColor.Initial, v4))

				if v4 < v2 and not flag then
					local imageLabel = Instance.new("ImageLabel")
					imageLabel.Image = "rbxassetid://101053692073571"
					imageLabel.BackgroundTransparency = 1
					imageLabel.Size = UDim2.fromScale(1, 1)
					imageLabel.ImageColor3 = Color3.new(1)
					imageLabel.Parent = localPlayer.PlayerGui.Misc
					TweenService:Create(imageLabel, tweenInfo, {
						ImageTransparency = 1
					}):Play()
					DebrisModule:AddItem(imageLabel, 0.3)
					v = v7
					value2:Set(0)
					maid:Schedule(0.5, function()
						if v == v7 then
							value2:Reset()
						end
					end)
				end

				v2 = v4
			end
		end

		updHealth(true)
		table.insert(connections, maid:Connect(humanoid:GetPropertyChangedSignal("Health"), updHealth))
		table.insert(connections, maid:Connect(humanoid:GetPropertyChangedSignal("MaxHealth"), updHealth))
	end

	local function bindCharacter(character)
		for _, connection in connections do
			maid:Remove(connection)
			connection:Disconnect()
		end

		table.clear(connections)
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid == nil then
			table.insert(connections, maid:Connect(character.ChildAdded, function(humanoid2)
				if humanoid2:IsA("Humanoid") then
					bindHumanoid(humanoid2)
				end
			end))
		else
			bindHumanoid(humanoid)
		end
	end

	if localPlayer.Character ~= nil then
		bindCharacter(localPlayer.Character)
	end

	local v = DataValue.new(SettingsKeys.HealthStats.Path, SettingsKeys.HealthStats.Default, SettingsKeys.Scope)
	local value5 = maid:Value(v:Get())
	maid:Add(v.Changed:Connect(function(p)
		value5:Set(p)
	end))
	maid:Add(v)
	maid:Connect(localPlayer.CharacterAdded, bindCharacter)
	return maid:Create("Frame")({
		Name = "Health",
		Size = UDim2.fromScale(1, 0.35),
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),
		LivesBars(maid),
		maid:State(function(callback, p)
			if callback(value5) == true then
				return Stats(p)
			end

			return nil
		end),
		maid:Create("TextLabel")({
			Name = "TextEffectholder",
			Size = UDim2.fromScale(0.5, 0.5),
			TextXAlignment = Enum.TextXAlignment.Right,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.fromScale(1, 0.15),
			BackgroundTransparency = 1,
			Text = text,
			FontFace = Font.new(
				"rbxasset://fonts/families/GothamSSm.json",
				Enum.FontWeight.ExtraBold,
				Enum.FontStyle.Normal
			),
			TextScaled = true,
			TextColor3 = textColor,
			TextStrokeTransparency = 0.85,
			TextStrokeColor3 = Color3.new(1, 1, 1)
		}),
		maid:Create("ImageLabel")({
			Name = "Bg",
			ZIndex = -1,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = "rbxassetid://118898045858643",
			ImageColor3 = Color3.new(),
			ImageTransparency = 0.25
		}),
		maid:Create("Frame")({
			Name = "BarHolder",
			Size = UDim2.fromScale(0.75, 0.35),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.485),
			maid:Create("UICorner")({
				CornerRadius = UDim.new(0.15)
			}),
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(),
			maid:Create("UIStroke")({
				Color = Color3.new(0.5, 0.5, 0.5),
				Transparency = 0.85
			}),
			maid:Create("ImageLabel")({
				Name = "Whitebar",
				Size = maid:Animation(value, info2),
				maid:Create("UICorner")({
					CornerRadius = UDim.new(0.15)
				}),
				BackgroundColor3 = Color3.new(0.784314, 0.807843, 0.729412),
				ImageColor3 = Color3.new(),
				Image = "rbxassetid://114647244875648",
				ScaleType = Enum.ScaleType.Tile,
				TileSize = UDim2.new(0, 50, 0, 50)
			}),
			maid:Create("Frame")({
				Name = "RedBar",
				Size = maid:Animation(value, info),
				ZIndex = 2,
				BackgroundColor3 = Color3.new(0.854902, 0.0901961, 0.0352941),
				maid:Create("UICorner")({
					CornerRadius = UDim.new(0.15)
				}),
				maid:Create("Frame")({
					Name = "ChangeEffect",
					Size = UDim2.new(0, 15, 1.2, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(1, 0.5),
					BackgroundTransparency = maid:Animation(value2, info),
					maid:Create("UIGradient")({
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(0.5, 0),
							NumberSequenceKeypoint.new(1, 1)
						})
					})
				})
			})
		})
	})
end