local localPlayer = game.Players.LocalPlayer
local PlayerModule = require(localPlayer.PlayerScripts:WaitForChild("PlayerModule"))
local controls = PlayerModule:GetControls()
local Util = require(game.ReplicatedStorage.Util)
local bodyMover = Util.BodyMover
return function(list)
	local v = unpack(list)
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid", 1)
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 1)
	controls:Disable()
	local v2 = bodyMover.new(character):Create("BodyGyro", {
		Duration = 5,
		CFrame = humanoidRootPart.CFrame
	})
	local v3 = bodyMover.new(character):Create("BodyPosition", {
		Duration = 5,
		Priority = 10000,
		Position = v.CFrame * Vector3.new(0, 0, -v.Size.Z)
	})
	local now = false

	while v and v.Parent do
		if not (now or v:IsDescendantOf(workspace)) then
			now = tick()
		end

		if now and tick() - now > 0.06 then
			break
		end

		humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
		local v4 = v.CFrame * Vector3.new(0, 0, -v.Size.Z)
		v2:Set(CFrame.new(v4, v.Position))
		v3:Set(v4)
		local RunService = game:GetService("RunService")
		RunService.RenderStepped:Wait()
	end

	controls:Enable()
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
	v3:Destroy()
	v2:Destroy()
end