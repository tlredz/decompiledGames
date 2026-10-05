game:GetService("Players")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local modules = CAM.Client.Modules
local debree = workspace.Debree
local assets = script:FindFirstChild("Assets")
script:FindFirstChild("Sounds")
local DebrisModule = require(CAM.DebrisModule)
require(modules.Effects.Cam_Shaker)
require(modules.Effects.Craters.CraterHandler)
require(modules.Effects.BoatTween)
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local ParticleBudget = require(modules.Effects.ParticleBudget)
local _ = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera

function PlayAnimation(animator, childName: string, _: number?, onStopped)
	local child = assets:FindFirstChild(childName)

	if not (animator and child) then
		return
	end

	local track = animator:LoadAnimation(child)
	track:Play()

	if onStopped then
		track.Stopped:Once(onStopped)
	end

	return track
end

local function SwordTrail(instance, flag: boolean)
	local has_Blade = instance:FindFirstChild("Has_Blade", true)
	local blade

	if not (has_Blade == nil or has_Blade.Parent == nil) then
		blade = has_Blade.Parent:FindFirstChild("Blade")
	end

	if blade == nil then
		return
	end

	if flag == true or flag == nil then
		local clones = {}

		for _, child in pairs(script.Parent.SwordTrail:GetChildren()) do
			local clone = child:Clone()
			clone.Name = "bladetfftians##asd"
			clone.Enabled = not ParticleBudget.Muted(instance, clone)
			ParticleBudget.Rate(clone, instance)
			clone.Parent = blade
			table.insert(clones, clone)

			if not clone:IsA("Trail") then
				continue
			end

			clone.Attachment0 = blade:FindFirstChild("Sword_At_A")
			clone.Attachment1 = blade:FindFirstChild("Sword_At_B")
		end

		if clones ~= nil and clones[1] ~= nil then
			task.delay(5, function()
				if clones[1].Name ~= "--" then
					for _, v in ipairs(clones) do
						v:Destroy()
					end
				end
			end)
		end
	else
		local children = {}

		for _, child in pairs(blade:GetChildren()) do
			if child.Name ~= "bladetfftians##asd" then
				continue
			end

			child.Name = "--"
			child.Enabled = false
			table.insert(children, child)
		end

		if #children > 0 then
			task.delay(1.35, function()
				for _, v in ipairs(children) do
					v:Destroy()
				end
			end)
		end
	end
end

return function(instance, p, _)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil or p ~= "Cancel" and (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	local name = string.format("%s Whirl_Pool_Effects", instance.Name)
	local child = debree:FindFirstChild(name)

	if p == "Startup" then
		local clone = assets.Startup:Clone()
		clone.CFrame = humanoidRootPart.CFrame
		clone.Parent = workspace.Debree
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 3)
		local clone2 = script.Sounds.PS2WBwaterwheelSTART:Clone()
		clone2.Parent = clone
		clone2:Play()
	elseif p == "Cutscene" then
		if child ~= nil then
			child:Destroy()
		end

		local folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = debree
		folder:SetAttribute("Active", true)
		DebrisModule:AddItem(folder, 12)
		SwordTrail(instance)

		if not (folder:GetAttribute("Active") and folder:IsDescendantOf(workspace)) then
			return
		end

		local clone = assets.Startup:Clone()
		clone.CFrame = humanoidRootPart.CFrame
		clone.Parent = folder
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 3)

		if not folder then
			SwordTrail(instance, false)
			return
		end

		local clone2 = assets.DeadCalmVFX:Clone()
		clone2:PivotTo(humanoidRootPart.CFrame)
		clone2.Parent = folder
		vfxUtility.PlaySound(script.Sounds, "PS2WBdeadcalm", clone2.PrimaryPart, true)
		DebrisModule:AddItem(clone2, 15)
		vfxUtility.TweenLight(clone2, {
			Time = 0.3
		})
		clone2.Puddle.RootPart.CFrame = clone2.Puddle.RootPart.CFrame * CFrame.new(0, 0.25, 0)
		PlayAnimation(clone2.Puddle.AnimationController.Animator, "Puddle")
		PlayAnimation(clone2.Wave.AnimationController, "Wave")
		vfxUtility.EnableAll(clone2.Puddle, true, vfxUtility.Owned(instance))
		task.delay(7, function()
			if folder:GetAttribute("Active") and folder:IsDescendantOf(workspace) then
				vfxUtility.EnableAll(clone2.Puddle, false)
				vfxUtility.TweenLight(clone2, {
					Time = 0.3,
					Off = true
				})
			end
		end)
		task.wait(4.7)

		if not (folder:GetAttribute("Active") and folder:IsDescendantOf(workspace)) then
			return
		end

		vfxUtility.EnableAll(clone2["Mutli-Slash"], true, vfxUtility.Owned(instance))
		task.delay(0.15, function()
			if folder:GetAttribute("Active") and folder:IsDescendantOf(workspace) then
				vfxUtility.EmitAll(clone2.WaveAppear, vfxUtility.Owned(instance))
				vfxUtility.EnableAll(clone2.Wave, true, vfxUtility.Owned(instance))
			end
		end)
		task.wait(1.1)

		if not (folder:GetAttribute("Active") and folder:IsDescendantOf(workspace)) then
			return
		end

		vfxUtility.EnableAll(clone2["Mutli-Slash"], false)
		task.wait(0.4)

		if not (folder:GetAttribute("Active") and folder:IsDescendantOf(workspace)) then
			return
		end

		vfxUtility.EmitAll(clone2.Impact, vfxUtility.Owned(instance))
		vfxUtility.EnableAll(clone2.Wave, false)
		DebrisModule:AddItem(clone2, 2.1)
		task.wait(1.9)

		if not (folder:GetAttribute("Active") and folder:IsDescendantOf(workspace)) then
			return
		end

		for _, folder2 in { clone2.Puddle, clone2.Wave } do
			for _, part in folder2:GetDescendants() do
				if part:IsA("MeshPart") then
					TweenService:Create(part, TweenInfo.new(0.1), {
						Transparency = 1
					}):Play()
				end
			end
		end

		if folder then
			folder.Name = "_"
			folder:SetAttribute("Active", nil)
			DebrisModule:AddItem(folder, 2)
		end

		SwordTrail(instance, false)
	elseif p == "Cancel" then
		if child ~= nil then
			child.Name = "_"
			child:SetAttribute("Active", nil)
			DebrisModule:AddItem(child, 2.5)

			if child:FindFirstChild("DeadCalmVFX") ~= nil then
				local pS2WBdeadcalm = child.DeadCalmVFX.PrimaryPart:FindFirstChild("PS2WBdeadcalm")

				if pS2WBdeadcalm ~= nil then
					pS2WBdeadcalm:Destroy()
				end

				for _, descendant in ipairs(child.DeadCalmVFX:GetDescendants()) do
					if not (descendant:IsA("MeshPart") or descendant:IsA("Part") or descendant:IsA("Decal") or descendant:IsA("BasePart")) then
						continue
					end

					descendant.Transparency = 1
				end
			end

			vfxUtility.EnableAll(child, false)
			vfxUtility.TweenLight(child, {
				Time = 0.2,
				Off = true
			})
		end

		SwordTrail(instance, false)
	end
end