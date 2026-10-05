local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local CharacterController = require(ReplicatedStorage.Controllers.CharacterController)
local ServerAuthority = require(ReplicatedStorage.Shared.ServerAuthority)
local RagdollController = {
	ToggleControls = function(self, flag: boolean)
		if flag == true then
			CharacterController.Controls:Enable()
		elseif flag == false then
			CharacterController.Controls:Disable()
		end
	end,
	IsInRagdoll = function(_)
		local serverTimeNow = workspace:GetServerTimeNow()
		return math.clamp((localPlayer:GetAttribute("RagdollEndTime") or serverTimeNow) - serverTimeNow, 0, 1e999) > 0
	end
}

function RagdollController.Start(_)
	local thread = nil

	local function toggleControls()
		if thread and coroutine.status(thread) ~= "dead" then
			task.cancel(thread)
		end

		thread = task.spawn(function()
			local serverTimeNow = workspace:GetServerTimeNow()
			local v = math.clamp(
				(localPlayer:GetAttribute("RagdollEndTime") or serverTimeNow) - serverTimeNow,
				0,
				1e999
			)

			if v < 0 then
				RagdollController:ToggleControls(true)
				return
			end

			RagdollController:ToggleControls(false)
			thread = coroutine.running()
			task.wait(v)
			RagdollController:ToggleControls(true)
		end)
	end

	localPlayer:GetAttributeChangedSignal("RagdollEndTime"):Connect(toggleControls)
	Net:RemoteEvent("Ragdoll").OnClientEvent:Connect(function(p)
		local character = localPlayer.Character

		if not character then
			return
		end

		local humanoid = character:FindFirstChildWhichIsA("Humanoid")

		if not humanoid then
			return
		end

		if p then
			if not ServerAuthority.isEnabled() then
				humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			end

			local character2 = localPlayer.Character
			local head = character2 and character2:FindFirstChild("Head")

			if head then
				currentCamera.CameraSubject = head
			end
		else
			if not ServerAuthority.isEnabled() then
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end

			currentCamera.CameraSubject = humanoid
		end
	end)
end

return RagdollController