local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local animations = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local controller = Knit.CreateController({
	Name = "ShadowSwarmController"
})
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }

local function wallCheck(p, p2)
	for _, v6 in { CFrame.new(1, 1, -1), CFrame.new(-1, -1, -1) } do
		local v7 = CFrame.new(p, p + p2) * v6

		if not workspace:Raycast(v7.Position, -p2 * 3, raycastParams) then
			return false
		end
	end

	return true
end

function controller.KnitStart(_)
	local v5 = {
		Domain = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v4:PlaySound(sounds.Megumi.Voice, humanoidRootPart, game.SoundService.Voice)
			v4:DomainBurst(humanoidRootPart)
		end,
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v4:PlaySound(sounds.Megumi.ShadowGarden.Start, humanoidRootPart, game.SoundService.Effect)
		end,
		Summon = function(instance, folder)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = instance:Clone()
			local clone2 = instance:Clone()
			clone.Parent = folder
			clone2.Parent = folder

			for _, part in folder:GetDescendants() do
				if not part:IsA("BasePart") then
					continue
				end

				if part.Name == "HumanoidRootPart" or part.Name == "Torso" then
					part.CollisionGroup = "Effects"
				else
					part.CollisionGroup = "NoCollision"
				end

				part.Massless = true
			end

			local weld = Instance.new("Weld", clone)
			weld.C0 = CFrame.new(-6, 0, -3)
			weld.Name = "FolderWeld"
			local weld2 = Instance.new("Weld", clone2)
			weld2.C0 = CFrame.new(6, 0, -2)
			weld2.Name = "FolderWeld"
			weld:GetPropertyChangedSignal("Enabled"):Connect(function()
				clone.HumanoidRootPart.Anchored = weld.Enabled
			end)
			weld2:GetPropertyChangedSignal("Enabled"):Connect(function()
				clone2.HumanoidRootPart.Anchored = weld2.Enabled
			end)
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if not (weld.Parent and weld2.Parent) then
					steppedConnection:Disconnect()
					return
				end

				if weld.Enabled == true then
					clone.HumanoidRootPart.CFrame = humanoidRootPart.CFrame * weld.C0
				end

				if weld2.Enabled == true then
					clone2.HumanoidRootPart.CFrame = humanoidRootPart.CFrame * weld2.C0
				end
			end)
			TweenService:Create(weld, TweenInfo.new(3, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {
				C0 = CFrame.new(-6, 0, 4)
			}):Play()
			TweenService:Create(weld2, TweenInfo.new(3, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {
				C0 = CFrame.new(6, 0, 4)
			}):Play()
			v4:Flash(clone, Color3.new(0, 0, 0), 1.5)
			v4:Flash(clone2, Color3.new(0, 0, 0), 1.5)
			v3:Tilt(clone)
			v3:Tilt(clone2)
			v4:PlaySound(sounds.Megumi.ShadowEnter, humanoidRootPart, game.SoundService.Effect)
			local track = clone.Humanoid:LoadAnimation(animations.Megumi.ShadowSwarmRun)
			local track2 = clone2.Humanoid:LoadAnimation(animations.Megumi.ShadowSwarmRun)
			track:Play(0, nil, 1.2000000000000002)
			track2:Play(0, nil, 1.5)
			track2.TimePosition = 4.2
			local clone3 = utils.Megumi.Shadow:Clone()
			local clone4 = utils.Megumi.Shadow:Clone()
			clone3.Shadow.Enabled = false
			clone4.Shadow.Enabled = false
			clone3.Parent = clone
			clone4.Parent = clone2
			task.delay(0.2, function()
				clone3.Dive.Enabled = false
				clone4.Dive.Enabled = false
				task.wait(0.8)
				track:AdjustSpeed(0.8)
				track2:AdjustSpeed(1)
			end)
			local highlight = Instance.new("Highlight")
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.FillTransparency = 0
			highlight.FillColor = Color3.new(0, 0, 0)
			highlight.OutlineColor = Color3.new(0, 0, 0)
			highlight.Parent = clone
			local clone5 = highlight:Clone()
			clone5.Parent = clone2
			TweenService:Create(highlight, TweenInfo.new(1), {
				OutlineTransparency = 0,
				FillTransparency = 0.5
			}):Play()
			TweenService:Create(clone5, TweenInfo.new(1), {
				OutlineTransparency = 0,
				FillTransparency = 0.5
			}):Play()
			local raycastResult = workspace:Raycast(
				clone.HumanoidRootPart.Position,
				createVector(0, -8, 0),
				raycastParams
			)
			local raycastResult2 = workspace:Raycast(
				clone2.HumanoidRootPart.Position,
				createVector(0, -8, 0),
				raycastParams
			)

			if raycastResult then
				clone3.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal)
				clone3.Shadow:Emit(20)
			else
				clone3.CFrame = clone2.HumanoidRootPart.CFrame
				clone3.ShadowAir:Emit(20)
			end

			if raycastResult2 then
				clone4.CFrame = CFrame.new(raycastResult2.Position, raycastResult2.Position + raycastResult2.Normal)
				clone4.Shadow:Emit(20)
			else
				clone4.CFrame = clone2.HumanoidRootPart.CFrame
				clone4.ShadowAir:Emit(20)
			end

			folder.Destroying:Connect(function()
				clone.Parent = workspace.Effects
				clone2.Parent = workspace.Effects
				Debris:AddItem(clone, 1)
				Debris:AddItem(clone2, 1)
				weld:Destroy()
				weld2:Destroy()
				clone.HumanoidRootPart.Anchored = true
				clone2.HumanoidRootPart.Anchored = true
				TweenService:Create(clone.HumanoidRootPart, TweenInfo.new(0.5), {
					CFrame = clone.HumanoidRootPart.CFrame - createVector(0, 4, 0)
				}):Play()
				TweenService:Create(clone2.HumanoidRootPart, TweenInfo.new(0.5), {
					CFrame = clone2.HumanoidRootPart.CFrame - createVector(0, 4, 0)
				}):Play()
				local raycastResult3 = workspace:Raycast(
					clone.Torso.Position + createVector(0, 3, 0),
					createVector(0, -8, 0),
					raycastParams
				)
				local raycastResult4 = workspace:Raycast(
					clone2.Torso.Position + createVector(0, 3, 0),
					createVector(0, -8, 0),
					raycastParams
				)

				if raycastResult3 then
					clone3.CFrame = CFrame.new(raycastResult3.Position, raycastResult3.Position + raycastResult3.Normal)
					clone3.Shadow:Emit(20)
				else
					clone3.CFrame = clone2.HumanoidRootPart.CFrame
					clone3.ShadowAir:Emit(20)
				end

				if raycastResult4 then
					clone4.CFrame = CFrame.new(raycastResult4.Position, raycastResult4.Position + raycastResult4.Normal)
					clone4.Shadow:Emit(20)
				else
					clone4.CFrame = clone2.HumanoidRootPart.CFrame
					clone4.ShadowAir:Emit(20)
				end

				v4:PlaySound(sounds.Megumi.Rabbit.Despawn, humanoidRootPart, game.SoundService.Effect)
				task.wait(0.5)

				for _, descendant in clone:GetDescendants() do
					if descendant:IsA("BasePart") or descendant:IsA("Decal") then
						descendant.Transparency = 1
					end
				end

				for _, descendant in clone2:GetDescendants() do
					if descendant:IsA("BasePart") or descendant:IsA("Decal") then
						descendant.Transparency = 1
					end
				end
			end)
		end,
		Shadow = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Megumi.Shadow:Clone()
			clone.Dive.Enabled = false
			clone.Shadow.Enabled = false
			clone.Parent = workspace.Effects
			clone.Dive:Emit(5)
			v4:PlaySound(sounds.Megumi.ShadowEnter, humanoidRootPart, game.SoundService.Effect)
			local raycastResult = workspace:Raycast(
				instance.Torso.Position + createVector(0, 3, 0),
				createVector(0, -8, 0),
				raycastParams
			)

			if raycastResult then
				clone.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal)
				clone.Shadow:Emit(10)
			else
				clone.CFrame = instance.Torso.CFrame
				clone.ShadowAir:Emit(10)
			end

			Debris:AddItem(clone, 1)
		end,
		Dash = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v6 = { 0, 6, -6 }

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end

			for _, child in instance2:GetChildren() do
				local folderWeld = child:FindFirstChild("FolderWeld")

				if folderWeld then
					folderWeld.Enabled = false
				end

				local v7 = child
				task.spawn(function()
					v7.Humanoid.WalkSpeed = 48

					repeat
						v7.Humanoid:Move(humanoidRootPart.CFrame.LookVector)
						task.wait()
					until folderWeld.Enabled == true or v7.HumanoidRootPart.Anchored == true or not instance2.Parent
				end)
			end

			for i = 1, 3 do
				v4:PlaySound(sounds.Itadori.Rush.Rush, humanoidRootPart, game.SoundService.Effect)
				local model = Instance.new("Model")
				local clone = replicatedStorage.Utils.Itadori.RushWind:Clone()
				clone.CFrame = humanoidRootPart.CFrame * CFrame.new(v6[i], -1, 0)
				clone.Parent = model
				model.Parent = workspace.Effects
				model:ScaleTo(0.6)
				clone.Ring:Emit(7)
				clone.Dash1.Dash:Emit(1)
				clone.Dash2.Dash:Emit(1)
				Debris:AddItem(clone, 2)
				task.wait(0.1)
			end
		end,
		Grab = function(p, instance, instance2, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v4:Flash(instance, Color3.new(1, 1, 1))
			v4:PlaySound(sounds.Gojo.LapseBlue.Grab, humanoidRootPart, game.SoundService.Effect)

			for i, child in instance2:GetChildren() do
				for _, v6 in child.Humanoid:GetPlayingAnimationTracks() do
					v6:Stop(0)
				end

				child.Humanoid:LoadAnimation(animations.Megumi["ShadowSwarm" .. i]):Play(0)
				child.HumanoidRootPart.CollisionGroup = "NoCollision"
				local folderWeld = child:FindFirstChild("FolderWeld")

				if not folderWeld then
					continue
				end

				local humanoidRootPart2 = child.HumanoidRootPart
				humanoidRootPart2.Anchored = true
				local v6 = folderWeld
				task.spawn(function()
					TweenService:Create(v6, TweenInfo.new(0), {
						C0 = CFrame.new()
					}):Play()

					for i2 = 1, 20 do
						humanoidRootPart2.CFrame = humanoidRootPart2.CFrame:Lerp(humanoidRootPart.CFrame, 0.2)
						task.wait()
					end

					v6.Enabled = true
				end)
			end

			if localPlayer == p then
				local _ = workspace.CurrentCamera
				local character = localPlayer.Character
				local humanoid = character.Humanoid
				character.Head.CollisionGroup = "NoCollision"
				character.Torso.CollisionGroup = "NoCollision"
				RunService:BindToRenderStep("Cam2", Enum.RenderPriority.Camera.Value + 2, function()
					if humanoid.Parent and p2.Parent then
						local pointToObjectSpace = (character.HumanoidRootPart.CFrame + character.HumanoidRootPart.CFrame.UpVector * 1.5):PointToObjectSpace(character.Head.Position)
						humanoid.CameraOffset = Vector3.new(pointToObjectSpace.X, 0, pointToObjectSpace.Z)
					else
						RunService:UnbindFromRenderStep("Cam2")
						character.Head.CollisionGroup = "Default"
						character.Torso.CollisionGroup = "Default"
					end
				end)
			end
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.Twofold.Sparks:Clone()
			clone.Parent = instance.Torso
			clone:Emit(20)
			Debris:AddItem(clone, 0.4)
			v4:Flash(instance, Color3.new(1, 1, 1))
			v4:PlaySound(
				sounds.Gojo.M1:FindFirstChild("Hit" .. math.random(1, 4)),
				humanoidRootPart,
				game.SoundService.Effect
			)
		end,
		Swing = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and p.Parent) then
				return
			end

			local attachment = p.Attachment
			attachment.Parent = humanoidRootPart
			attachment.Ring:Emit(15)
			TweenService:Create(
				attachment.Ring,
				TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
				{
					TimeScale = 1
				}
			):Play()
			Debris:AddItem(attachment, 1)
		end,
		FinalHit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v4:Flash(instance, Color3.new(1, 1, 1))
			v4:PlaySound(
				sounds.Gojo.M1:FindFirstChild("Hit" .. math.random(1, 4)),
				humanoidRootPart,
				game.SoundService.Effect
			)
			CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			task.wait(0.15)
			v4:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Wep = function(instance)
			instance.Destroying:Connect(function()
				local clone = utils.Megumi.Wep:Clone()
				clone.CFrame = instance.CFrame
				clone.CanCollide = true
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 2)
			end)
		end,
		ForceFix = function(instance, instance2, p, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			repeat
				if instance2 and (humanoidRootPart.Position - p).Magnitude > 100 then
					instance2:Destroy()
				end

				task.wait()
			until not p2.Parent
		end
	}
	v.Effects:Connect(function(p, ...)
		local v6 = v5[p]

		if not v6 then
			return
		end

		v6(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("ShadowSwarmService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("MovementController")
	v4 = Knit.GetController("FXController")
end

return controller