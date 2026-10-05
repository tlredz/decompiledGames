local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local DoubleJump = {
	Id = 0
}
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
game.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Animations"):WaitForChild("Dashes"):WaitForChild("Air")
game.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Animations"):WaitForChild("Dashes"):WaitForChild("Land")
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local PlayerStatResolver = require(ReplicatedStorage.CAM.Global.PlayerStatResolver)

function DoubleJump.Hold(player)
	if player ~= nil and player.Character ~= nil then
		local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
		local v = game.ReplicatedStorage.Player_Service.Values:FindFirstChild(player.Name) or player.Character

		if player.Character:FindFirstChild("SHC") ~= nil and v ~= nil and humanoidRootPart ~= nil and player.Character:FindFirstChild("Humanoid") ~= nil then
			if humanoidRootPart:FindFirstChild("combat_knockback") or humanoidRootPart:FindFirstChild("combat_knockbackLast") then
				for _, child in pairs(humanoidRootPart:GetChildren()) do
					if child.Name == "combat_knockback" or child.Name == "combat_knockbackLast" then
						child:Destroy()
					end
				end
			end

			local lineVelocity = 50 * PlayerStatResolver.GetMovementMultiplier(player)

			if v:FindFirstChild("Blocking") then
				lineVelocity *= gameSettings.BlockingSpeedMult
			end

			local upVector = humanoidRootPart.CFrame.UpVector
			local attachment = Instance.new("Attachment")
			local linearVelocity = Instance.new("LinearVelocity")
			linearVelocity.Parent = attachment
			attachment.Name = "dash_thang_123asd"
			linearVelocity.Attachment0 = attachment
			linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
			linearVelocity.MaxForce = 20000
			linearVelocity.LineDirection = upVector
			linearVelocity.LineVelocity = lineVelocity
			attachment.Parent = humanoidRootPart
			DebrisModule:AddItem(attachment, 0.165)
			game.ReplicatedStorage.Communication.CnC.ClientEffects:Fire(
				"Double_Jump_Effect",
				humanoidRootPart,
				upVector
			)
			local position = humanoidRootPart.Position
			local raycastResult = workspace:Raycast(position, createVector(0, -10, 0), RaycastHelper.Crater)
			local v3 = (raycastResult == nil or raycastResult.Instance == nil) and "Air" or "Land"
			Combat_presets.stop_extra_anims(player.Character.Humanoid, { "Swing_6", "Swing_7" })
			local v4 = Character_info_provider.get_core_anim(player, "double_jump") or game.ReplicatedStorage.Assets.Animations.Dashes[v3]:FindFirstChild("Dash_Space")
			player.Character.Humanoid.Animator:LoadAnimation(v4):Play()
		end
	end
end

function DoubleJump.UnHold(_) end

function DoubleJump.Cancel(_) end

return DoubleJump