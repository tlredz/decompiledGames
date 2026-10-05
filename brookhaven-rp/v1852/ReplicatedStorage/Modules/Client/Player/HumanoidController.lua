local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local HumanoidController = {}

function HumanoidController.FrameworkInit() end

function HumanoidController.FrameworkStart()
	Remotes.connect("SetHumanoidState", function(p)
		local character = game.Players.LocalPlayer.Character

		if not character then
			return
		end

		local humanoid = character:FindFirstChild("Humanoid")

		if not humanoid then
			return
		end

		humanoid:ChangeState(p)
	end)
	local threads = {}
	Remotes.onInvoke("SetHumanoidStateAndApplyImpulse", function(p, vector2: Vector3, vector3: Vector3)
		local character = game.Players.LocalPlayer.Character

		if not character then
			return
		end

		local humanoid = character:FindFirstChild("Humanoid")

		if not humanoid then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local stateEnabled = humanoid:GetStateEnabled(p)
		humanoid:SetStateEnabled(p, true)
		humanoid:ChangeState(p)
		task.wait()

		if threads[p] then
			task.cancel(threads[p])
		end

		threads[p] = task.delay(5, function()
			humanoid:SetStateEnabled(p, stateEnabled)
		end)
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart:ApplyImpulse(vector2)

		if vector3 then
			humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
			humanoidRootPart:ApplyAngularImpulse(vector3)
		end
	end)
end

return HumanoidController