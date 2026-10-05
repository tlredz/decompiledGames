local FireflyHandler = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local RunService = game:GetService("RunService")
game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
FireflyHandler.FireFlyRegions = {}
local flag = true
local v = {}

local function isNearAnyFireflyRegion(position)
	local result = nil

	for k, _ in pairs(FireflyHandler.FireFlyRegions) do
		if k:GetAttribute("Spotted") or not ((k.Position - position).Magnitude <= 20) then
			continue
		end

		if result then
			table.insert(result, k)
		else
			result = { k }
		end
	end

	return result
end

function ParticlesPlayer(p)
	if p or localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local parent = p or localPlayer.Character.HumanoidRootPart
		local center = ReplicatedStorage.Assets.Particles.Fireflies.Center

		for _, emitter in pairs(center:GetChildren()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local clone = emitter:Clone()
			clone.Parent = parent
			task.spawn(function()
				wait(clone:GetAttribute("EmitDelay") or 0)
				clone:Emit(clone:GetAttribute("EmitCount") or 1)
				wait(10)
				clone:Destroy()
			end)
		end
	end
end

function moveFirefly(instance, p, p2)
	local total = 0
	local v2 = 0.01
	task.spawn(function()
		local v3, position, position2
		local controlFlowState = 11

		while true do
			if controlFlowState == 0 then
				if p and instance then
					controlFlowState = 2
				else
					controlFlowState = 1
				end

				continue
			elseif controlFlowState == 1 then
				if instance then
					controlFlowState = 3
				else
					controlFlowState = 4
				end

				continue
			elseif controlFlowState == 2 then
				v3 = RunService.RenderStepped:Wait()
				total += v3
				position = instance.Position
				position2 = p.Position

				if (position2 - position).Magnitude <= 1.5 or total >= 10 then
					controlFlowState = 5
				else
					controlFlowState = 6
				end

				continue
			else
				if controlFlowState == 3 then
					disappearFirefly(instance)
					break
				end

				if controlFlowState == 4 then
					break
				end

				if controlFlowState == 5 then
					if instance and localPlayer.Character and localPlayer.Character:FindFirstChild("Head") then
						controlFlowState = 7
					else
						controlFlowState = 4
					end

					continue
				elseif controlFlowState == 6 then
					local lerped = position:Lerp(position2, v2 * v3)
					instance:PivotTo(CFrame.new(lerped) * (instance.CFrame - instance.Position))
					v2 *= 1.1
					controlFlowState = 0
					continue
				elseif controlFlowState == 7 then
					Client.Sound.Play("FlashlightFirefly", {
						Volume = 0.6,
						Replicate = true,
						Duplicate = true,
						ReplicationProperties = {
							Instance = localPlayer.Character.Head,
							Volume = 0.3
						}
					})

					if p2 then
						controlFlowState = 8
					else
						controlFlowState = 9
					end

					continue
				elseif controlFlowState == 8 then
					Client.Events.ChargeFireflyEgg:FireServer(instance, p2)
					controlFlowState = 10
					continue
				elseif controlFlowState == 9 then
					Client.Events.ConsumeFirefly:FireServer(instance)
					controlFlowState = 10
					continue
				elseif controlFlowState == 10 then
					disappearFirefly(instance)
					ParticlesPlayer(p)
					break
				else
					if controlFlowState ~= 11 then
						break
					end

					controlFlowState = 0
					continue
				end
			end
		end
	end)
end

Client.Events.FireflyApproved:Connect(function(p, instance)
	if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and p and p.Parent then
		if instance and instance.PrimaryPart then
			moveFirefly(p, instance.PrimaryPart, instance)
		else
			moveFirefly(p, localPlayer.Character.HumanoidRootPart)
		end
	end
end)

function addFireFlyRegion(instance)
	FireflyHandler.FireFlyRegions[instance] = {}

	if flag then
		local pointLight = instance:FindFirstChildOfClass("PointLight")

		if pointLight then
			pointLight.Brightness = 0
		end

		if instance:FindFirstChild("Bug_Simple") then
			instance.Bug_Simple:Clear()
			instance.Bug_Simple.Enabled = false
		end

		if instance:FindFirstChild("Bug_Detail") then
			instance.Bug_Detail:Clear()
			instance.Bug_Detail.Enabled = false
		end
	else
		appearFirefly(instance)
	end

	instance.CanTouch = true
	task.spawn(function()
		wait(5)

		if flag then
			local pointLight = instance:FindFirstChildOfClass("PointLight")

			if pointLight then
				pointLight.Brightness = 0
			end

			if instance:FindFirstChild("Bug_Simple") then
				instance.Bug_Simple:Clear()
				instance.Bug_Simple.Enabled = false
			end

			if instance:FindFirstChild("Bug_Detail") then
				instance.Bug_Detail:Clear()
				instance.Bug_Detail.Enabled = false
			end
		else
			appearFirefly(instance)
		end
	end)
	v[instance] = instance.CFrame
	instance:SetAttribute("OrigPosition", instance.CFrame)
end

function removeFireFlyRegion(p)
	if FireflyHandler.FireFlyRegions[p] then
		for _, v2 in pairs(FireflyHandler.FireFlyRegions[p]) do
			v2.part:Destroy()
		end
	end

	FireflyHandler.FireFlyRegions[p] = nil
	v[p] = nil
end

function getRandomGoal(p, p2)
	local v2 = math.random() * 3.141592653589793 * 2
	local v3 = math.random() * 3.141592653589793
	local v4 = math.random() * p2
	return p + Vector3.new(math.sin(v3) * math.cos(v2) * v4, math.cos(v3) * v4, math.sin(v3) * math.sin(v2) * v4)
end

function disappearFirefly(instance)
	for k, _ in pairs(FireflyHandler.FireFlyRegions) do
		if instance ~= k then
			continue
		end

		k.Transparency = 1
		local pointLight = k:FindFirstChildOfClass("PointLight")

		if pointLight then
			pointLight.Enabled = false
		end

		if k:FindFirstChild("Bug_Simple") then
			k.Bug_Simple.Enabled = false
			k.Bug_Simple:Clear()
		end

		if k:FindFirstChild("Bug_Detail") then
			k.Bug_Detail.Enabled = false
			k.Bug_Detail:Clear()
		end

		if v[instance] then
			instance:PivotTo(v[instance])
		end
	end
end

Client.Events.DisappearFirefly:Connect(disappearFirefly)

function appearFirefly(instance)
	for k, _ in pairs(FireflyHandler.FireFlyRegions) do
		if instance ~= k then
			continue
		end

		k.Transparency = 0.8
		local pointLight = k:FindFirstChildOfClass("PointLight")

		if pointLight then
			pointLight.Enabled = true
		end

		if k:FindFirstChild("Bug_Simple") then
			k.Bug_Simple.Enabled = true
		end

		if k:FindFirstChild("Bug_Detail") then
			k.Bug_Detail.Enabled = true
		end

		if v[instance] then
			instance:PivotTo(v[instance])
		end
	end
end

Client.Events.DisableFirefly:Connect(function(p, p2)
	if p and p2 then
		disappearFirefly(p2)
	end
end)
Client.Events.EnableFirefly:Connect(function(p, p2)
	if p and p2 then
		appearFirefly(p2)
	end
end)

function onDayTime()
	local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

	for k, fireFlyRegion in pairs(FireflyHandler.FireFlyRegions) do
		TweenService:Create(k, TweenInfo.new(2, Enum.EasingStyle.Linear), {
			Transparency = 1
		}):Play()
		local pointLight = k:FindFirstChildOfClass("PointLight")

		if pointLight then
			TweenService:Create(pointLight, tweenInfo, {
				Brightness = 0
			}):Play()
		end

		for _, v2 in pairs(fireFlyRegion) do
			TweenService:Create(v2.part, tweenInfo, {
				Transparency = 1
			}):Play()
		end

		if k:FindFirstChild("Bug_Simple") then
			k.Bug_Simple.Enabled = false
		end

		if k:FindFirstChild("Bug_Detail") then
			k.Bug_Detail.Enabled = false
		end
	end
end

function onNightTime()
	local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

	for k, fireFlyRegion in pairs(FireflyHandler.FireFlyRegions) do
		if k:GetAttribute("Spotted") then
			continue
		end

		TweenService:Create(k, TweenInfo.new(5, Enum.EasingStyle.Linear), {
			Transparency = 0.8
		}):Play()
		local pointLight = k:FindFirstChildOfClass("PointLight")

		if pointLight then
			TweenService:Create(pointLight, tweenInfo, {
				Brightness = 10
			}):Play()
		end

		for _, v2 in pairs(fireFlyRegion) do
			TweenService:Create(v2.part, tweenInfo, {
				Transparency = 0
			}):Play()
		end

		if k:FindFirstChild("Bug_Simple") then
			k.Bug_Simple.Enabled = true
		end

		if k:FindFirstChild("Bug_Detail") then
			k.Bug_Detail.Enabled = true
		end
	end
end

function Connections()
	Client.Utility.ForAllTagged("FireflyRegion", addFireFlyRegion, removeFireFlyRegion)
	Client.Events.ChangeColorCorrection:Connect(function(p, _)
		if p == "Night" then
			flag = false
			onNightTime()
		else
			flag = true
			onDayTime()
		end
	end)
end

function FireflyHandler.Init()
	Connections()
	task.spawn(function()
		while true do
			local character = localPlayer.Character
			local v2 = nil
			local v3 = localPlayer:GetAttribute("Battery") and localPlayer:GetAttribute("MaxBattery") and localPlayer:GetAttribute("Battery") < localPlayer:GetAttribute("MaxBattery") - 5 and true or false
			local draggingItem = Client.InteractionHandler.GetDraggingItem()

			if draggingItem and draggingItem:GetAttribute("EasterEggId") == "Egg12" and draggingItem:GetAttribute("EggLocked") then
				v2 = draggingItem
			end

			if not flag and character and (v3 or v2) then
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				local v4 = humanoidRootPart and isNearAnyFireflyRegion(humanoidRootPart.Position)

				if v4 then
					local v5 = humanoidRootPart
					table.sort(v4, function(a, b)
						return (a.Position - v5.Position).Magnitude < (b.Position - v5.Position).Magnitude
					end)

					for _, v6 in pairs(v4) do
						if v2 then
							v6:SetAttribute("Spotted", true)
							Client.Events.FireflyToEgg:FireServer(v6, v2)
						else
							Client.Events.FireflyToPlayer:FireServer(v6)
						end
					end
				end
			end

			task.wait(0.5)
		end
	end)
end

return FireflyHandler