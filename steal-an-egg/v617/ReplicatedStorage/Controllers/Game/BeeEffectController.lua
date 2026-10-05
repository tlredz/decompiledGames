local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local localPlayer = Players.LocalPlayer
local playerScripts = localPlayer:WaitForChild("PlayerScripts")
local PlayerModule = require(playerScripts:WaitForChild("PlayerModule"))
local controls = PlayerModule:GetControls()
local v = nil
local flag = false
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function StopEffect(p)
	if v ~= p then
		return
	end

	v = nil
	p.Trove:Destroy()
end

function v2.Start()
	if flag then
		return
	end

	flag = true
	localPlayer.CharacterRemoving:Connect(function(character)
		local v3 = v

		if v3 and v3.Character == character then
			StopEffect(v3) -- equivalent call inferred; original call site unknown
		end
	end)
	localPlayer.CharacterAdded:Connect(function()
		local v3 = v

		if v3 and v3.Character ~= localPlayer.Character then
			StopEffect(v3) -- equivalent call inferred; original call site unknown
		end
	end)
end

function v2.Apply(instance, p: number)
	v2.Start()
	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if instance ~= localPlayer.Character or not instance:IsDescendantOf(Workspace) or not humanoid or humanoid.Health <= 0 or p <= 0 then
		return
	end

	local now = os.clock()
	local v3 = v

	if v3 and v3.Character == instance then
		v3.ExpiresAt = math.max(v3.ExpiresAt, now + p)
		v3.Timer:Stop()
		v3.Timer.Interval = v3.ExpiresAt - now
		v3.Timer:Start()
	else
		if v3 and v == v3 then
			v = nil
			v3.Trove:Destroy()
		end

		local maid = Trove.new()
		local timer = Timer.new(p)
		local v5 = {
			Character = instance,
			ExpiresAt = now + p,
			Timer = timer,
			Trove = maid
		}
		v = v5
		maid:Add(timer)
		maid:Connect(timer.Tick, function()
			if os.clock() >= v5.ExpiresAt then
				StopEffect(v5) -- equivalent call inferred; original call site unknown
			end
		end)
		maid:Connect(humanoid.Died, function()
			StopEffect(v5) -- equivalent call inferred; original call site unknown
		end)
		maid:Connect(instance.Destroying, function()
			StopEffect(v5) -- equivalent call inferred; original call site unknown
		end)
		local moveFunction = controls.moveFunction

		local function invertedMove(p2, vector: Vector3, flag2: boolean?)
			moveFunction(p2, -vector, flag2)
		end

		controls.moveFunction = invertedMove
		maid:Add(function()
			if controls.moveFunction == invertedMove then
				controls.moveFunction = moveFunction
			end
		end)
		local v6 = nil
		local fieldOfView = 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function restoreCamera()
			if v6 then
				v6.FieldOfView = fieldOfView
				v6 = nil
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateCamera()
			if v ~= v5 or Workspace.CurrentCamera == v6 then
				return
			end

			restoreCamera() -- equivalent call inferred; original call site unknown
			local currentCamera = Workspace.CurrentCamera
			v6 = currentCamera

			if currentCamera then
				fieldOfView = currentCamera.FieldOfView
				currentCamera.FieldOfView = fieldOfView / 2.4
			end
		end

		maid:Add(restoreCamera)
		maid:Connect(Workspace:GetPropertyChangedSignal("CurrentCamera"), updateCamera)
		updateCamera() -- equivalent call inferred; original call site unknown
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		maid:Add(colorCorrectionEffect)
		colorCorrectionEffect.Name = "BeeEffect"
		colorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 0)
		colorCorrectionEffect.Saturation = 0.5
		colorCorrectionEffect.Parent = Lighting
		local head = instance:FindFirstChild("Head")

		if head and head:IsA("BasePart") then
			local clone = ReplicatedStorage.Assets.ToolEffects.BeeToolEffect:Clone()
			maid:Add(clone)
			clone.CFrame = head.CFrame
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = head
			weldConstraint.Part1 = clone
			weldConstraint.Parent = clone
			clone.Parent = head
		end

		timer:Start()
	end
end

return table.freeze(v2)