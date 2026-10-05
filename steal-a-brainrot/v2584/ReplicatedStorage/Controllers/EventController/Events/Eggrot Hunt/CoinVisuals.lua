local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local MathUtils = require(ReplicatedStorage.Utils.MathUtils)
local Net = require(ReplicatedStorage.Packages.Net)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local remoteEvent = Net:RemoteEvent("EventService/EggrotHunt/SpawnCoin")
local remoteEvent2 = Net:RemoteEvent("EventService/EggrotHunt/ClaimCoin")
local remoteEvent3 = Net:RemoteEvent("EventService/EggrotHunt/DestroyCoin")
local remoteEvent4 = Net:RemoteEvent("EventService/EggrotHunt/GoldEggReward")
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
local clone = script.Drop:Clone()
local motor6D = Instance.new("Motor6D")
motor6D.Name = "CoinMotor"
motor6D.Parent = clone
local v2 = {}
local v3 = {}

local function AnimateLabel(data)
	local billboard = data.Billboard
	local textLabel = data.TextLabel
	local uIStroke = data.UIStroke
	billboard.StudsOffset = createVector(0, 0, 2.2)
	textLabel.TextTransparency = 0
	uIStroke.Transparency = 0
	textLabel.Size = UDim2.fromScale(1.3, 1.3)
	CreateTween(textLabel, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(1, 1)
	})
	CreateTween(billboard, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		StudsOffset = createVector(0, 2.5, 2.2)
	})
	CreateTween(textLabel, TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 1.5), {
		TextTransparency = 1
	})
	CreateTween(uIStroke, TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 1.5), {
		Transparency = 1
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SanitizeAmount(value)
	if type(value) == "number" and value == value and value ~= 1e999 and value ~= -1e999 then
		return (math.max(math.floor(value), 1))
	end

	return 1
end

local function createRewardBillboard(humanoidRootPart, value: number)
	local amount = SanitizeAmount(value) -- equivalent call inferred; original call site unknown
	local v5 = v3[humanoidRootPart]

	if v5 and v5.Billboard.Parent and os.clock() - v5.StartTime < 1.2000000000000002 then
		v5.Amount = SanitizeAmount(v5.Amount) + amount
		local textLabel = v5.TextLabel
		textLabel.Text = ("+%*"):format(SanitizeAmount(v5.Amount))
		v5.StartTime = os.clock()

		if v5.CleanupThread then
			task.cancel(v5.CleanupThread)
		end

		AnimateLabel(v5)
		v5.CleanupThread = task.delay(5, function()
			if v3[humanoidRootPart] == v5 then
				v3[humanoidRootPart] = nil
			end

			v5.Billboard:Destroy()
		end)
	else
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Size = UDim2.fromScale(4.5, 2)
		billboardGui.StudsOffset = createVector(0, 0, 2.2)
		billboardGui.LightInfluence = 1.5
		billboardGui.MaxDistance = 1e999
		billboardGui.ClipsDescendants = true
		billboardGui.ResetOnSpawn = false
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Amount"
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = ("+%*"):format(SanitizeAmount(amount))
		textLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
		textLabel.TextScaled = true
		textLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
		textLabel.Parent = billboardGui
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Color = Color3.fromRGB(100, 60, 20)
		uIStroke.Thickness = 2
		uIStroke.Parent = textLabel
		billboardGui.Parent = humanoidRootPart
		local v6 = {
			Billboard = billboardGui,
			TextLabel = textLabel,
			UIStroke = uIStroke,
			Amount = amount,
			StartTime = os.clock(),
			CleanupThread = nil
		}

		if v5 and v5.CleanupThread then
			task.cancel(v5.CleanupThread)
		end

		v3[humanoidRootPart] = v6
		AnimateLabel(v6)
		v6.CleanupThread = task.delay(5, function()
			if v3[humanoidRootPart] == v6 then
				v3[humanoidRootPart] = nil
			end

			billboardGui:Destroy()
		end)
	end
end

return table.freeze({
	OnLoad = function(_)
		remoteEvent2.OnClientEvent:Connect(function(p: string, player, p2: number)
			local v5 = v2[p]

			if not v5 then
				return
			end

			local lastCFrame = v5.LastCFrame
			v2[p] = nil
			local clone2 = v5.Model:Clone()
			v5.Model:Destroy()
			local coinMotor = clone2:FindFirstChild("CoinMotor")

			if coinMotor then
				coinMotor:Destroy()
			end

			clone2.Anchored = true
			clone2.CFrame = lastCFrame
			clone2.Parent = workspace
			local position = clone2:GetPivot().Position
			local total = 0
			local size = clone2.Size
			local postSimulationConnection = nil
			postSimulationConnection = RunService.PostSimulation:Connect(function(dt: number)
				total += dt
				local position2 = player.Character and player.Character:GetPivot().Position or createVector(0, 0, 0)
				local v6 = position + (position2 - position) * 0.25 + createVector(0, 10, 0)
				local value = TweenService:GetValue(total / 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
				clone2:PivotTo(CFrame.new(MathUtils.quadBezier(value, position, v6, position2)) * clone2:GetPivot().Rotation)
				clone2.Size = size * 0.5 + size * 0.5 * (1 - value)

				if value >= 1 and postSimulationConnection then
					postSimulationConnection:Disconnect()
					postSimulationConnection = nil
					clone2:Destroy()
					task.spawn(function()
						pcall(function()
							SoundController:PlaySound(
								ReplicatedStorage.Sounds.Events["St Patricks"].CoinPickup,
								position2
							)
						end)
					end)
					local character = player.Character
					local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart then
						createRewardBillboard(humanoidRootPart, p2)
					end
				end
			end)
		end)
		remoteEvent.OnClientEvent:Connect(function(name: string, position: Vector3, vector2: Vector3, spawnTime: number, tweenTime: number, flag: boolean?)
			local clone2 = clone:Clone()
			clone2.Name = name
			clone2.CFrame = CFrame.new(0, 10000, 0)
			clone2.Trail.Enabled = false
			clone2.Parent = workspace
			local coinMotor = clone2:FindFirstChild("CoinMotor")
			coinMotor.Part0 = workspace.Terrain
			coinMotor.Part1 = clone2
			clone2.Anchored = false
			local proximityPrompt = Instance.new("ProximityPrompt")
			proximityPrompt.ActionText = ""
			proximityPrompt.RequiresLineOfSight = flag == true
			proximityPrompt.Enabled = false
			proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
			proximityPrompt.MaxActivationDistance = 20
			proximityPrompt:SetAttribute("CustomStyleDisabled", true)
			proximityPrompt.Parent = clone2
			local raycastResult = workspace:Raycast(
				vector2 + createVector(0, 10, 0),
				createVector(0, -30, 0),
				raycastParams
			)

			if raycastResult then
				vector2 = raycastResult.Position + createVector(0, 2, 0) or vector2
			end

			local vector3 = Vector3.new(vector2.X, vector2.Y + 30, vector2.Z)
			local seed = math.random(0, 10000)
			local v6 = position
			local total = 0
			local arcLengths = { 0 }

			for i = 1, 20 do
				local cubicBezier = MathUtils.cubicBezier(i / 20, position, position, vector3, vector2)
				total += (cubicBezier - v6).Magnitude
				arcLengths[i + 1] = total
				v6 = cubicBezier
			end

			v2[name] = {
				Model = clone2,
				Motor = coinMotor,
				ProximityPrompt = proximityPrompt,
				SpawnTime = spawnTime,
				TweenTime = tweenTime,
				P0 = position,
				P1 = position,
				P2 = vector3,
				P3 = vector2,
				ArcLengths = arcLengths,
				ArcTotal = total,
				ArcSamples = 20,
				Seed = seed,
				Landed = false,
				PromptEnabled = false,
				IsPromptShowing = false,
				LastFire = 0,
				UpdateInterval = 0,
				LastUpdate = 0,
				LastCFrame = CFrame.new(position),
				TrailEnabled = false
			}
			proximityPrompt.PromptShown:Connect(function()
				if v2[name] then
					v2[name].IsPromptShowing = true
				end
			end)
			proximityPrompt.PromptHidden:Connect(function()
				if v2[name] then
					v2[name].IsPromptShowing = false
				end
			end)
			clone2.Destroying:Connect(function()
				v2[name] = nil
			end)
		end)
		remoteEvent3.OnClientEvent:Connect(function(p: string)
			local v5 = v2[p]

			if not v5 then
				return
			end

			v5.Model:Destroy()
			v2[p] = nil
		end)
		remoteEvent4.OnClientEvent:Connect(function(p: number)
			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				createRewardBillboard(humanoidRootPart, p)
			end
		end)
		RunService.PostSimulation:Connect(function(_: number)
			local now = os.clock()
			local cFrame = currentCamera.CFrame
			local position = cFrame.Position
			local lookVector = cFrame.LookVector
			local v5 = math.rad(currentCamera.FieldOfView / 2) + 0.20943951023931956

			for k, v6 in v2 do
				if v6.Landed then
					local v7 = position - v6.P3
					local magnitude = v7.Magnitude

					if magnitude > 5000 then
						v6.UpdateInterval = 60
					elseif magnitude < 300 then
						v6.UpdateInterval = 0
					elseif math.acos((math.clamp(lookVector:Dot(v7.Unit), -1, 1))) < v5 then
						v6.UpdateInterval = 0.5
					else
						v6.UpdateInterval = magnitude // 25 / 60
					end

					if v6.IsPromptShowing and now - v6.LastFire > 0.05 then
						v6.LastFire = now
						remoteEvent2:FireServer(k)
					end

					if not (now - v6.LastUpdate < v6.UpdateInterval) then
						v6.LastUpdate = now
						local v8 = now + v6.Seed
						local v9 = v6.P3 + Vector3.new(0, math.sin(v8 * 4) * 0.5 + 2, 0)
						local v10 = v8 * 1.5707963267948966
						local v11 = CFrame.new(v9) * CFrame.Angles(0, v10, 0)
						v6.Motor.Transform = v11
						v6.LastCFrame = v11
					end
				else
					local v7 = workspace:GetServerTimeNow() - v6.SpawnTime
					local value = TweenService:GetValue(
						v6.TweenTime == 0 and 1 or math.clamp(v7 / v6.TweenTime, 0, 1),
						Enum.EasingStyle.Quint,
						Enum.EasingDirection.Out
					)
					local v9 = value * v6.ArcTotal
					local P3 = v6.P3

					for i = 1, #v6.ArcLengths do
						local arcLength = v6.ArcLengths[i]

						if not (v9 <= arcLength) then
							continue
						end

						local arcLength2 = v6.ArcLengths[i - 1]
						local v10 = (v9 - arcLength2) / (arcLength - arcLength2)
						local v11 = (i - 2 + v10) / v6.ArcSamples
						P3 = MathUtils.cubicBezier(v11, v6.P0, v6.P1, v6.P2, v6.P3)
						break
					end

					local v10 = now + v6.Seed
					local v11 = P3 + Vector3.new(0, math.sin(v10 * 4) * 0.5 + 2, 0)
					local v12 = v10 * 1.5707963267948966
					local v13 = CFrame.new(v11) * CFrame.Angles(0, v12, 0)
					v6.Motor.Transform = v13
					v6.LastCFrame = v13

					if not v6.PromptEnabled and value >= 0.95 then
						v6.PromptEnabled = true
						v6.ProximityPrompt.Enabled = true
					end

					if not v6.TrailEnabled then
						v6.TrailEnabled = true
						local v14 = v6
						task.delay(0, function()
							v14.Model.Trail.Enabled = true
						end)
					end

					if value >= 1 then
						v6.Landed = true
					end
				end
			end
		end)
	end
})