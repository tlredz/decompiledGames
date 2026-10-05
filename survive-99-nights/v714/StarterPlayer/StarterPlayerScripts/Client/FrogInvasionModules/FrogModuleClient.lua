local createVector = vector.create
local FrogModuleClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
game:GetService("RunService")

function PullPlayer(player, p, _)
	local humanoidRootPart = player.Character.HumanoidRootPart
	local humanoid = localPlayer.Character.Humanoid
	local _ = humanoidRootPart.AssemblyMass

	if humanoid:GetState() ~= Enum.HumanoidStateType.Running then
		return
	end

	local v = (p * createVector(1, 0, 1)).Unit * 500 + createVector(0, 250, 0)
	humanoid:ChangeState(Enum.HumanoidStateType.Flying)

	for _, part in pairs(localPlayer.Character:GetChildren()) do
		if part:IsA("BasePart") then
			part.Velocity = createVector(0, 0, 0)
		end
	end

	humanoidRootPart.AssemblyLinearVelocity = Vector3.new()
	humanoidRootPart:ApplyImpulse(v)
end

function RunFrogAttackAnimation(parent, player, options)
	print("attack anim", player)

	if not parent.Parent or not player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		return
	end

	local clone = game.ReplicatedStorage.Assets.NpcAssets.FrogTongues:FindFirstChild(parent.Name):Clone()
	local tongue = clone.Tongue
	local tongueEnd = clone:FindFirstChild("TongueEnd")

	if (options or {}).Poison then
		for _, part in pairs(clone:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Color = Color3.fromRGB(97, 255, 62)
			end
		end
	end

	local NPC = parent.NPC
	local frogAttack = parent.Animations.FrogAttack
	local track = NPC.Animator:LoadAnimation(frogAttack)
	local tongue2 = parent.Tongue
	local humanoidRootPart = player.Character.HumanoidRootPart
	local tonguePullForce = parent:GetAttribute("TonguePullForce")
	local flag = false
	track:Play()

	local function setTongueLength(p, p2, p3)
		if not clone.Parent then
			return true
		end

		local v2 = p2 or humanoidRootPart.Position
		local v3 = v2 - tongue2.Position
		local v4 = v3.Magnitude * p
		local unit = v3.Unit
		local cframe = CFrame.lookAt(tongue2.Position, v2)
		local v5 = cframe * CFrame.new(0, 0, -v4)
		tongue.Size = Vector3.new(tongue.Size.X, tongue.Size.Y, v4)
		tongue.CFrame = cframe * CFrame.new(0, 0, -v4 / 2)

		if tongueEnd then
			tongueEnd:PivotTo(v5)
		end

		clone.Parent = parent

		if player == localPlayer and p3 and tonguePullForce then
			if 1 - p < tonguePullForce then
				local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
				local v6 = -unit * 40
				humanoidRootPart.AssemblyLinearVelocity = Vector3.new(v6.X, assemblyLinearVelocity.Y, v6.Z)
				flag = true
			elseif flag then
				humanoidRootPart.AssemblyLinearVelocity = createVector(0, 30, 0)
				flag = false
			end
		end
	end

	clone.Parent = parent
	Client.TweenModule.new(function(p)
		setTongueLength(p)
	end, 0.15):Play()
	task.wait(0.15)
	local position = humanoidRootPart.Position
	Client.TweenModule.new(function(p)
		setTongueLength(1 - p, position, true)
	end, 0.15):Play()
	task.wait(0.15)
	clone:Destroy()
	track:Stop()
end

function Preload()
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://101155170229514"
	Client.UtilityAlec.preload({ animation })
end

Client.Events.NPCAttackAnimation:Connect(function(instance, ...)
	if instance:GetAttribute("NPCType") == "Frog" then
		RunFrogAttackAnimation(instance, ...)
	end
end)

function FrogModuleClient.Init()
	task.spawn(function()
		Preload()
	end)
end

return FrogModuleClient