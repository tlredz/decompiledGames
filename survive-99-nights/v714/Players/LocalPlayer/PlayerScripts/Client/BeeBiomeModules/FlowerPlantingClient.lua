local FlowerPlantingClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")
local v = { 0, 15, 40 }
local v2 = { Color3.fromRGB(255, 230, 44), Color3.fromRGB(255, 94, 0), Color3.fromRGB(193, 0, 0) }
local animation = nil
local count = 0
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}
local flag = false

function GetBeehiveFromPrompt(instance)
	if instance.Name ~= "ProximityInteraction" then
		return
	end

	local parent = instance.Parent
	local parent2 = parent and parent.Parent
	local parent3 = parent2 and parent2.Parent

	if parent3 and (parent3:HasTag("Beehive") or parent3:HasTag("BeeBox")) then
		return parent3
	end
end

function GetBeehivePrompt(instance)
	local primaryPart = instance.PrimaryPart or instance:FindFirstChild("Main")
	local proximityAttachment = primaryPart and primaryPart:FindFirstChild("ProximityAttachment")
	return proximityAttachment and proximityAttachment:FindFirstChild("ProximityInteraction")
end

function NudgeBeehive(instance)
	if v4[instance] then
		return
	end

	v4[instance] = true
	local pivot = instance:GetPivot()
	Client.UtilityAlec.tweenModel(
		instance,
		pivot * CFrame.new(0, -0.3, 0),
		0.08,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)
	task.delay(0.09, function()
		Client.UtilityAlec.tweenModel(instance, pivot, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	end)
	task.delay(0.22, function()
		v4[instance] = nil
	end)
end

function StartPlantingLoop(p)
	count += 1
	local v8 = count
	v3[p] = v8

	if (localPlayer:GetAttribute("Flowers") or 0) <= 0 then
		Client.PopUpUI.AddPopUp("you don't have any flowers", "warning")
		ShowHoneyBillboard(p)
		v3[p] = nil
	else
		local v9 = GetBeehivePrompt(p)

		while v3[p] == v8 and p.Parent and v9 and v9.Parent and v9.Enabled do
			local v10 = Client.Events.RequestPlantBeehiveFlower:InvokeServer(p)

			if v10 and v10.Success then
				NudgeBeehive(p)
				task.wait(0.2)
			else
				if not v10 or v10.Reason ~= "NoFlowers" then
					break
				end

				Client.PopUpUI.AddPopUp("you don't have any flowers", "warning")
				break
			end
		end

		if v3[p] == v8 then
			v3[p] = nil
		end
	end
end

function GrowFlower(folder)
	if not (folder and folder.Parent) or folder:GetAttribute("GrowPlayed") then
		return
	end

	folder:SetAttribute("GrowPlayed", true)
	local animationController = folder:FindFirstChild("AnimationController")
	local animator = animationController and animationController:FindFirstChild("Animator")

	if animator and animation then
		task.spawn(function()
			local track = animator:LoadAnimation(animation)
			local v8 = os.clock() + 3

			while track.Length == 0 and os.clock() < v8 do
				task.wait()
			end

			if track.Length > 0 then
				local motor6D = folder:FindFirstChild("HRP") and folder.HRP:FindFirstChildOfClass("Motor6D")

				if motor6D then
					local steppedConnection = RunService.Stepped:Connect(function()
						motor6D.Transform = CFrame.new()
					end)
					task.delay(track.Length / 2 + 0.5, function()
						steppedConnection:Disconnect()
					end)
				end

				track:Play(0, 1, 0)
				track.TimePosition = math.max(track.Length - 0.05 - 1, 0)
				track:AdjustSpeed(-2)
				local timePosition = track.TimePosition
				local v9 = os.clock() + 1

				while timePosition <= track.TimePosition and os.clock() < v9 do
					RunService.PostSimulation:Wait()
				end
			end

			for _, part in pairs(folder:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Transparency = part:GetAttribute("BaseTransparency") or part.Transparency
				end
			end
		end)
	end
end

function CheckGrowFlower(instance)
	local plantedAt = instance:GetAttribute("PlantedAt")

	if plantedAt and workspace:GetServerTimeNow() - plantedAt < 3 then
		GrowFlower(instance)
	end
end

function PreloadBeehiveParticles(instance)
	task.spawn(function()
		if flag then
			return
		end

		local main = instance:WaitForChild("Main", 30)

		if main == nil or flag then
			return
		end

		local emitters = {}

		for _, emitter in pairs(main:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				table.insert(emitters, emitter)
			end
		end

		if #emitters > 0 then
			flag = true
			Client.UtilityAlec.preload(emitters)
		end
	end)
end

function GetBeehiveBillboard(instance)
	local main = instance:FindFirstChild("Main")
	return main and main:FindFirstChild("HoneyBillboard")
end

function IsBeehiveMaxLevel(instance)
	return (instance:GetAttribute("Level") or 1) >= #v
end

function UpdateHoneyBillboard(instance, data)
	local level = instance:GetAttribute("Level") or 1
	local numberFlowers = instance:GetAttribute("NumberFlowers") or 0
	local honey = instance:GetAttribute("Honey") or 0
	local maxHoney = instance:GetAttribute("MaxHoney") or 0
	local textColor = v2[level] or v2[1]
	data.Rate.RateAmount.Text = "+ " .. (instance:GetAttribute("HoneyPerMinute") or 1)
	data.Rate.RateAmount.TextColor3 = textColor
	data.Rate.TextLabel.TextColor3 = textColor
	data.CurrentAmount.Text = tostring((math.floor(honey)))

	if maxHoney > 0 and maxHoney <= honey then
		data.CurrentAmount.TextColor3 = v2[3]
	else
		data.CurrentAmount.TextColor3 = v2[1]
	end

	local v9 = v[level + 1]
	local v10 = not v9 and 1 or math.clamp((numberFlowers - v[level]) / (v9 - v[level]), 0, 1)
	data.LevelBar.Fill.Size = UDim2.new(v10, 0, 1, 0)
end

function ShowHoneyBillboard(instance)
	local v8 = GetBeehiveBillboard(instance)

	if v8 == nil then
		return
	end

	if (instance:GetAttribute("Level") or 0) < 1 then
		v8.Enabled = false
		return
	end

	UpdateHoneyBillboard(instance, v8)
	v8.Enabled = true
	local visible = IsBeehiveMaxLevel(instance)
	v8.LevelBar.Visible = not visible
	v8.MaxLevel.Visible = visible
	v6[instance] = true
	v5[instance] = (v5[instance] or 0) + 1
	local v10 = v5[instance]
	task.delay(7, function()
		if v5[instance] == v10 then
			v6[instance] = nil
			v8.LevelBar.Visible = false
			v8.MaxLevel.Visible = false
		end
	end)
end

function SetupBeehiveBillboard(instance)
	if v7[instance] then
		return
	end

	v7[instance] = true

	local function refresh()
		local v8 = GetBeehiveBillboard(instance)

		if v8 == nil then
			return
		end

		if (instance:GetAttribute("Level") or 0) < 1 then
			v8.Enabled = false
			return
		end

		UpdateHoneyBillboard(instance, v8)
		v8.Enabled = true
		local v9 = v6[instance] == true
		local v10 = IsBeehiveMaxLevel(instance)
		v8.LevelBar.Visible = v9 and not v10
		v8.MaxLevel.Visible = v9 and v10
	end

	for _, v8 in pairs({ "Honey", "Level", "NumberFlowers" }) do
		instance:GetAttributeChangedSignal(v8):Connect(refresh)
	end

	refresh()
end

function CleanupBeehiveBillboard(p)
	v7[p] = nil
	v5[p] = nil
	v6[p] = nil
end

function FlowerPlantingClient.Init()
	animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://105026852273857"
	Client.UtilityAlec.preload({ animation })

	local function beginPlanting(p, p2)
		if p2 ~= "Prompt" then
			return
		end

		task.spawn(function()
			StartPlantingLoop(p)
		end)
	end

	Client.InteractionHandler.RegisterInteraction("Beehive", beginPlanting)
	Client.InteractionHandler.RegisterInteraction("BeeBox", beginPlanting)
	ProximityPromptService.PromptTriggerEnded:Connect(function(p)
		local v8 = GetBeehiveFromPrompt(p)

		if v8 then
			v3[v8] = nil
		end
	end)
	Client.Events.BeehiveFlowerPlanted:Connect(function(p, p2)
		GrowFlower(p)

		if p2 then
			ShowHoneyBillboard(p2)
			PreloadBeehiveParticles(p2)
		end
	end)
	Client.Events.EmitBeehiveParticles:Connect(function(instance)
		local instanceMain = instance and instance:FindFirstChild("Main")

		if instanceMain then
			Client.Utility.RunParticles(instanceMain)
		end
	end)
	Client.Utility.ForAllTagged("BeehiveFlower", CheckGrowFlower)
	Client.Utility.ForAllTagged("Beehive", SetupBeehiveBillboard, CleanupBeehiveBillboard)
end

return FlowerPlantingClient