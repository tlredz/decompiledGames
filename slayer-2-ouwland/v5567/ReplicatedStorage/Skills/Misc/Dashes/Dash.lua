local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local Dash = {
	Id = 0
}
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local currentCamera = workspace.CurrentCamera
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Combat_presets"))
game.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Animations"):WaitForChild("Dashes"):WaitForChild("Air")
game.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Animations"):WaitForChild("Dashes"):WaitForChild("Land")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
local Combat_presets = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Combat_presets"))
local v = false
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local PlayerStatResolver = require(ReplicatedStorage.CAM.Global.PlayerStatResolver)
local Config = require(script.Parent.Config)

function Dash.Hold(player)
	if player ~= nil and player.Character ~= nil then
		local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
		local parent = game.ReplicatedStorage.Player_Service.Values:FindFirstChild(player.Name) or player.Character
		local SHC = player.Character:FindFirstChild("SHC")

		if SHC ~= nil and parent ~= nil and humanoidRootPart ~= nil and player.Character:FindFirstChild("Humanoid") ~= nil then
			if humanoidRootPart:FindFirstChild("combat_knockback") then
				for _, child in pairs(humanoidRootPart:GetChildren()) do
					if child.Name == "combat_knockback" then
						child:Destroy()
					end
				end
			end

			local attribute = SHC:GetAttribute(not SHC:GetAttribute("LastCkType") and "CK" or SHC:GetAttribute("LastCkType"))
			Checker.Dashing = true
			local boolValue = Instance.new("BoolValue")
			boolValue.Name = "NR"
			boolValue.Parent = parent
			local movementMultiplier = PlayerStatResolver.GetMovementMultiplier(player)
			local v3 = math.max(
				0.1,
				1 + (PlayerStatResolver.GetStat(player, "Dash Speed Factor") or 0) * Config.DASH_FACTOR_SCALE
			)
			local lineVelocity = Config.DASH_SPEED * movementMultiplier * v3
			local DASH_FORCE_DURATION = Config.DASH_FORCE_DURATION
			local v5 = DASH_FORCE_DURATION + (Config.DASH_DURATION - DASH_FORCE_DURATION) / v3

			if parent:FindFirstChild("Blocking") then
				lineVelocity *= gameSettings.BlockingSpeedMult
			end

			DebrisModule:AddItem(boolValue, v5)
			local position = humanoidRootPart.Position
			local v6 = humanoidRootPart.Position + currentCamera.CFrame.LookVector * 5
			local vector2 = Vector3.new(v6.X, position.Y, v6.Z)
			humanoidRootPart.CFrame = CFrame.new(position, vector2)
			local attachment = Instance.new("Attachment", humanoidRootPart)
			DebrisModule:AddItem(attachment, v5)
			local alignOrientation = Instance.new("AlignOrientation")
			alignOrientation.MaxTorque = 10000
			alignOrientation.Responsiveness = 30
			alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
			alignOrientation.Attachment0 = attachment
			alignOrientation.CFrame = CFrame.new(position, vector2)
			alignOrientation.Parent = attachment
			local lookVector = humanoidRootPart.CFrame.lookVector

			if attribute == "S" then
				lookVector *= -1
			end

			if attribute == "A" then
				lookVector = humanoidRootPart.CFrame.rightVector * -1
			end

			if attribute == "D" then
				lookVector = humanoidRootPart.CFrame.rightVector
			end

			local attachment2 = Instance.new("Attachment")
			local linearVelocity = Instance.new("LinearVelocity")
			linearVelocity.Parent = attachment2
			attachment2.Name = "dash_thang_123asd"
			linearVelocity.Attachment0 = attachment2
			linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
			linearVelocity.MaxForce = 10000
			linearVelocity.LineDirection = lookVector
			linearVelocity.LineVelocity = lineVelocity
			attachment2.Parent = humanoidRootPart
			DebrisModule:AddItem(attachment2, DASH_FORCE_DURATION)
			local position2 = humanoidRootPart.Position
			local raycastResult = workspace:Raycast(position2, createVector(0, -10, 0), raycastParams)
			local v7

			if raycastResult == nil or raycastResult.Instance == nil then
				local boolValue2 = Instance.new("BoolValue")
				boolValue2.Name = "AIRDASHASD123"
				boolValue2.Parent = parent
				DebrisModule:AddItem(boolValue2, Config.AIR_DASH_FLAG_DURATION)
				v7 = "Air"
			else
				v7 = "Land"
			end

			game.ReplicatedStorage.Communication.CnC.ClientEffects:Fire(
				"dash_effect",
				humanoidRootPart,
				lookVector,
				v7 == "Air",
				Config.ResolveCustomDash(player)
			)

			if os.clock() - Combat_presets.lastRunHit > Combat_presets.slow_walk_duration then
				local dash_W_Inverted = Character_info_provider.get_core_anim(player, "Dash_" .. attribute) or game.ReplicatedStorage.Assets.Animations.Dashes[v7]:FindFirstChild("Dash_" .. attribute)

				if v7 == "Land" and attribute == "W" and dash_W_Inverted.Parent.Parent.Name == "Dashes" then
					v = not v

					if v == true then
						dash_W_Inverted = game.ReplicatedStorage.Assets.Animations.Dashes.Land.Dash_W_Inverted
					end
				end

				local track = nil

				if player.Character and player.Character:FindFirstChild("Accessories") and player.Character.Accessories:FindFirstChild("CustomRig") then
					local animController = player.Character.Accessories.CustomRig:FindFirstChild("AnimController")

					if animController then
						Combat_presets.stop_extra_anims(animController, { "Swing_6", "Swing_7" })
						track = animController.Animator:LoadAnimation(dash_W_Inverted)
					end
				else
					Combat_presets.stop_extra_anims(player.Character.Humanoid, { "Swing_6", "Swing_7" })
					track = player.Character.Humanoid.Animator:LoadAnimation(dash_W_Inverted)
				end

				if track ~= nil then
					track:Play()

					if v3 ~= 1 then
						track:AdjustSpeed(v3)
					end
				end
			end

			task.delay(v5, function()
				Checker.Dashing = false
			end)
		end
	end
end

function Dash.UnHold(_) end

function Dash.Cancel(_) end

return Dash