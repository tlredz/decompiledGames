local createVector = vector.create
local LifestealClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- equivalent calls inferred from this helper; original call sites unknown
local function Tween(attachment, tweenInfo, p)
	local tween = TweenService:Create(attachment, tweenInfo, p)
	tween:Play()
	tween:Destroy()
end

function RandomNumber(p, p2)
	return math.random(p * 1000, p2 * 1000) / 1000
end

local v = {
	Red = game.ReplicatedStorage.Assets.Particles.HealProjectileParticles_Red:GetChildren()
}

local function SpawnHealParticles(humanoidRootPart, p: string, p2: number)
	local v2 = v[p]

	if v2 == nil then
		warn("Particle color does not exist")
		return
	end

	for _ = 1, p2 do
		task.delay(0, function()
			local attachment = Instance.new("Attachment")
			game.Debris:AddItem(attachment, 10)
			attachment.Position = CFrame.Angles(
				math.rad((RandomNumber(-90, 90))),
				math.rad((RandomNumber(-90, 90))),
				(math.rad((RandomNumber(-90, 90))))
			).UpVector * RandomNumber(2, 4)
			local clones = {}

			for _, v3 in pairs(v2) do
				local clone = v3:Clone()
				table.insert(clones, clone)
				clone.Parent = attachment
			end

			for _, v3 in pairs(clones) do
				if string.find(v3.Name, "Spawn_") ~= nil then
					v3:Emit(v3:GetAttribute("EmitCount"))
				end

				if string.find(v3.Name, "Ambient_") ~= nil then
					v3.Enabled = true
				end
			end

			attachment.Parent = humanoidRootPart
			task.wait(0.25)
			Tween(attachment, TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0), {
				Position = createVector(0, 0, 0)
			}) -- equivalent call inferred; original call site unknown
			task.wait(0.75)

			for _, v3 in pairs(clones) do
				if string.find(v3.Name, "Impact_") ~= nil then
					v3:Emit(v3:GetAttribute("EmitCount"))
				end

				if string.find(v3.Name, "Ambient_") ~= nil then
					v3.Enabled = false
				end
			end

			task.wait(1)
		end)
	end
end

Client.Events.LifestealHealParticles:Connect(function()
	if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
		SpawnHealParticles(localPlayer.Character.HumanoidRootPart, "Red", 5)
		Client.Sound.Play("LifestealHeal", {
			Duplicate = true,
			Replicate = true,
			ReplicationProperties = {
				Instance = localPlayer.Character.Head,
				Volume = 0.4
			}
		})
	end
end)
local flag = false
local count = 0

function FullBar()
	flag = true
	count += 1
	local v2 = count
	task.spawn(function()
		local lifestealBar = Client.Interface.StatBars.ExtraBars.LifestealBar
		lifestealBar.Bar.Size = UDim2.new(1, 0, 1, 0)
		local TweenService2 = game:GetService("TweenService")
		local bar = lifestealBar.Bar
		local backgroundColor3 = bar.BackgroundColor3
		local color = Color3.fromRGB(247, 191, 192)
		local color2 = Color3.fromRGB(122, 32, 40)
		local tweenInfo = TweenInfo.new(0.16, Enum.EasingStyle.Linear)
		local tweenInfo2 = TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService2:Create(bar, tweenInfo, {
			BackgroundColor3 = color
		})
		local tween2 = TweenService2:Create(bar, tweenInfo, {
			BackgroundColor3 = backgroundColor3
		})
		local tween3 = TweenService2:Create(bar, tweenInfo, {
			BackgroundColor3 = color
		})
		local tween4 = TweenService2:Create(bar, tweenInfo, {
			BackgroundColor3 = backgroundColor3
		})
		local tween5 = TweenService2:Create(bar, tweenInfo2, {
			BackgroundColor3 = color2
		})
		tween:Play()

		if v2 == count then
			tween.Completed:Once(function()
				if v2 == count then
					tween2:Play()
				end
			end)
		end

		if v2 == count then
			tween2.Completed:Once(function()
				if v2 == count then
					tween3:Play()
				end
			end)
		end

		if v2 == count then
			tween3.Completed:Once(function()
				if v2 == count then
					tween4:Play()
				end
			end)
		end

		if v2 == count then
			tween4.Completed:Once(function()
				if v2 == count then
					tween5:Play()
				end
			end)
		end

		if v2 == count then
			tween5.Completed:Once(function()
				bar.Size = UDim2.new(0, 0, 1, 0)
				bar.BackgroundColor3 = Color3.fromRGB(247, 34, 55)
			end)
		end

		if v2 == count then
			flag = false
		end
	end)
end

function LifestealClient.EnableBar()
	Client.Interface.StatBars.ExtraBars.LifestealBar.Visible = true
end

function UpdateLifestealBar(p)
	if flag then
		return
	end

	Client.Interface.StatBars.ExtraBars.LifestealBar.Bar.Size = UDim2.new(p / 100, 0, 1, 0)
end

function LifestealClient.Init()
	local lifestealEnergy = localPlayer:GetAttribute("LifestealEnergy") or 0
	localPlayer:GetAttributeChangedSignal("LifestealEnergy"):Connect(function()
		local lifestealEnergy2 = localPlayer:GetAttribute("LifestealEnergy") or 0
		UpdateLifestealBar(lifestealEnergy2)

		if lifestealEnergy2 >= 100 then
			FullBar()
		end
	end)
	UpdateLifestealBar(lifestealEnergy)
end

return LifestealClient