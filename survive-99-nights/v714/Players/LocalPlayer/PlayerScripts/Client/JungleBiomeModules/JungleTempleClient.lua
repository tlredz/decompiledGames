local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JungleTempleClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Client.Events.UnlockJungleTempleAnimation:Connect(function(instance)
	if not instance or (workspace.CurrentCamera.Focus.Position - instance:GetPivot().Position).Magnitude > 400 then
		return
	end

	local center = instance:WaitForChild("Functional"):WaitForChild("Center")
	Client.Sound.Play("StoneMechanism", {
		Volume = 1,
		Position = center.Position
	})
	task.delay(1, function()
		Client.Events.StopSound:Fire("StoneMechanism", {
			FadeTime = 1
		})
	end)
	Client.CamShake.ShakeOnce(1.2, 22, 0.5, 8)
end)

function AnimateJungleTempleStairs(instance, flag: boolean)
	if not instance or (workspace.CurrentCamera.Focus.Position - instance:GetPivot().Position).Magnitude > 400 then
		return
	end

	local moving = instance:WaitForChild("Functional", 2):WaitForChild("Stairwell", 2):WaitForChild("Moving", 2)

	if not moving then
		return
	end

	Client.Sound.Play("HeavyStoneSliding", {
		Volume = 0.3
	})
	local v = 0

	for _, child in pairs(moving:GetChildren()) do
		local name = tonumber(child.Name)

		if not (name > 0) then
			continue
		end

		local origHeight = child:GetAttribute("OrigHeight")
		local origY = child:GetAttribute("OrigY")

		if flag then
			origHeight += name
		end

		local Y = child.Size.Y
		local v2 = name / 5
		local v4 = child
		local tweenModule = Client.TweenModule.new(function(p)
			local v6 = Y + (origHeight - Y) * p
			v4.Size = Vector3.new(v4.Size.X, v6, v4.Size.Z)
			local v7 = origY + v6 / 2
			v4.CFrame = v4.CFrame - v4.Position + Vector3.new(v4.Position.X, v7, v4.Position.Z)
		end, v2)

		if v < v2 then
			v = v2
		end

		tweenModule:Play()
	end

	task.delay(v, function()
		Client.Sound.Play("HeavyStoneHit", {
			Volume = 0.3,
			Duplicate = true
		})
		Client.Events.StopSound:Fire("HeavyStoneSliding", {
			FadeTime = 0.15
		})
	end)
end

Client.Events.AnimateJungleTempleStairs:Connect(AnimateJungleTempleStairs)
Client.Events.JungleTempleCollapsing:Connect(function(p)
	local shakeOnce = Client.CamShake.ShakeOnce(3, 20, 2, 4)
	local v = localPlayer.Character:GetPivot() + createVector(0, 40, 0)
	Client.Utility.SpawnParticles("RocksRaining", v, {
		Duration = 4
	})
	task.spawn(function()
		ReplicatedStorage.Core.Sounds.TempleRumbling:Play()
		local total = 0

		while total < 5 do
			total += task.wait(0.1)

			if not (localPlayer.Character and localPlayer.Character:GetPivot().Y > p.Y) then
				continue
			end

			print("LEFT CAVE")
			shakeOnce:StartFadeOut(0.1)
			break
		end

		ReplicatedStorage.Core.Sounds.TempleRumbling:Stop()
	end)
end)

function AddPodium(instance)
	local touchZone = instance:WaitForChild("TouchZone")
	local jungleKey = instance:WaitForChild("Jungle Key")
	local flag = false
	instance:GetAttributeChangedSignal("GemAdded"):Connect(function()
		local gemAdded = instance:GetAttribute("GemAdded")

		for _, part in pairs(jungleKey:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "Main" then
				part.Transparency = gemAdded and 0.2 or 1
			end
		end

		if gemAdded and not instance:GetAttribute("LocalAdded") then
			for _, child in pairs(instance.PrimaryPart.ItemAttach:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount") or 1)
			end

			Client.Utility.SpawnParticles("TempleSkullPlaced", jungleKey:GetPivot())
		else
			instance:SetAttribute("LocalAdded", nil)
			flag = false
		end
	end)
	touchZone.Touched:Connect(function(otherPart)
		local parent = otherPart.Parent

		if flag or parent:GetAttribute("BeingUsed") or instance:GetAttribute("GemAdded") or parent:GetAttribute("Destroyed") then
			return
		end

		if instance:GetAttribute("LocalAdded") then
			return
		end

		if parent:HasTag("JungleKey") then
			local function undo()
				instance:SetAttribute("LocalAdded", nil)
				parent:SetAttribute("BeingUsed", nil)
				parent.Parent = workspace.Items

				if not instance:GetAttribute("GemAdded") then
					for _, descendant in pairs(jungleKey:GetDescendants()) do
						if descendant:IsA("BasePart") or descendant:IsA("Decal") then
							descendant.Transparency = 1
						end
					end
				end
			end

			flag = true
			parent:SetAttribute("BeingUsed", true)
			instance:SetAttribute("LocalAdded", true)
			parent.Parent = game.ReplicatedStorage.TempStorage

			for _, part in pairs(jungleKey:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "Main" then
					part.Transparency = 0.2
				end
			end

			for _, child in pairs(instance.PrimaryPart.ItemAttach:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount") or 1)
			end

			Client.Utility.SpawnParticles("TempleSkullPlaced", jungleKey:GetPivot())
			Client.Sound.Play("SkullPlaced", {
				Volume = 0.55,
				Replicate = true,
				Duplicate = true,
				ReplicationProperties = {
					Instance = localPlayer.Character.Head,
					Volume = 0.4
				}
			})
			local v = Client.Events.RequestAddJungleTempleGem:InvokeServer(parent, instance)

			if not (v and v.Success) then
				task.spawn(function()
					wait(0.5)
					undo()
					wait(1)
					flag = false
				end)
			end
		end
	end)
end

function TemplePodiumAdded(instance)
	if not instance:IsDescendantOf(workspace) then
		return
	end

	local functional = instance:WaitForChild("Functional")

	for _, child in pairs(functional:WaitForChild("Podiums"):GetChildren()) do
		AddPodium(child)
	end
end

function JungleTempleClient.Init()
	Client.Utility.ForAllTagged("JungleTemplePodium", TemplePodiumAdded)
end

return JungleTempleClient