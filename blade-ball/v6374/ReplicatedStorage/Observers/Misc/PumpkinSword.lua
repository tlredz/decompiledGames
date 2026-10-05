local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local _ = Players.LocalPlayer
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
local v = { workspace.Alive, workspace.Dead }
return Observers.observeTag("PumpkinSword", function(instance)
	if RunService:IsClient() then
		return nil
	end

	local sord = instance:WaitForChild("sord")
	local parent = instance.Parent
	local humanoid = parent:WaitForChild("Humanoid", 5)

	if not humanoid then
		return nil
	end

	local animator = humanoid:WaitForChild("Animator", 5)

	if not animator then
		return nil
	end

	local v2 = false

	for _, ancestor in v do
		if not instance:IsDescendantOf(ancestor) then
			continue
		end

		v2 = true
		break
	end

	if not v2 then
		return nil
	end

	local deadChangedConnection = parent:GetAttributeChangedSignal("Dead"):Connect(function()
		if parent:GetAttribute("Dead") then
			instance:RemoveTag("PumpkinSword")
		end
	end)
	local track = animator:LoadAnimation(script.Spin)
	local track2 = animator:LoadAnimation(script.Sneeze)
	local thread = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setIdle()
		if thread then
			Utils.Thread.SafeCancel(thread)
		end

		thread = task.delay(20, function()
			track2:Play()
			local clone = script.SneezeEmit:Clone()
			clone.Parent = sord
			local createWeld = Utils.Physics.CreateWeld(clone, sord)
			createWeld.C0 = CFrame.new(0.044, -1.765, -0.611) * CFrame.fromOrientation(0, 0, 3.141592653589793)
			task.delay(1.5, function()
				Utils.Visual:PlayEffects(clone)
			end)
			Debris:AddItem(clone, 2.5)
			local clone2 = script.SneezeSFX:Clone()
			clone2.Parent = sord
			clone2:Play()
			clone2.Ended:Once(function()
				clone2:Destroy()
			end)
		end)
	end

	local flag = true
	local connection = Utils.Thread.Every(120, function()
		if flag then
			flag = false
			return
		end

		track:Play()
		local clone = script.SpinSFX:Clone()
		clone.Parent = sord
		clone:Play()
		clone.Ended:Once(function()
			clone:Destroy()
		end)
	end)
	local parryingChangedConnection = parent:GetAttributeChangedSignal("Parrying"):Connect(function()
		setIdle() -- equivalent call inferred; original call site unknown
	end)
	local runningConnection = humanoid.Running:Connect(setIdle)
	return function()
		track:Stop()
		track:Destroy()
		track2:Stop()
		track2:Destroy()
		deadChangedConnection:Disconnect()
		connection:Disconnect()
		runningConnection:Disconnect()
		parryingChangedConnection:Disconnect()
	end
end, v)