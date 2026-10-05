local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local v = require3(ReplicatedStorage2.Common.Utils)
local isClient = RunService:IsClient()

local function getVFX(folder)
	local descendants = {}

	for _, descendant in folder:GetDescendants() do
		if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("BillboardGui") or descendant:IsA("Sound")) then
			continue
		end

		table.insert(descendants, descendant)
	end

	return descendants
end

return {
	getVFX = getVFX,
	play = function(parent, maid, parent2, instance)
		local clone = instance:Clone()
		local torso = parent:FindFirstChild("Torso")
		v.Physics.ResizePart(clone, parent:GetAttribute("EmoteScale") or 1)

		for _, child in clone:GetChildren() do
			if child.Name == "Ignore" then
				continue
			end

			if child:FindFirstChild("sord") or child:FindFirstChild("sordz2") then
				local parent3 = v.Inst.findOrCreate("SwordParts", "Folder", child)
				local torso2 = child:FindFirstChild("Torso") or v.Inst.new("Part", {
					Name = "Torso",
					Size = createVector(2, 2, 2),
					Transparency = 1,
					CanCollide = false,
					CanQuery = false,
					CanTouch = false,
					Massless = true,
					Anchored = false
				}, child)

				for _, child2 in child:GetChildren() do
					if not (child2.Name == "sord" or child2.Name == "sordz2") then
						continue
					end

					child2.Parent = parent3
					local motor = v.Physics.CreateMotor(torso2, child2, {
						Name = child2.Name == "sordz2" and "Motor6D2" or "Motor6D"
					})
					local C0 = child2:FindFirstChild("C0")

					if C0 then
						motor.C0 = C0.CFrame
					end

					local C1 = child2:FindFirstChild("C1")

					if C1 then
						motor.C1 = C1.CFrame
					end
				end
			elseif child.Name == "Accessories" then
				if torso then
					for _, v2 in child:QueryDescendants("BasePart [$Animatable = true]") do
						maid:Add(v.Physics.CreateMotor(torso, v2))
					end
				end

				for _, child2 in child:GetChildren() do
					if torso then
						maid:Add(child2)
						child2.Parent = parent
					else
						child2:Destroy()
					end
				end
			end

			for _, part in child:GetChildren() do
				local v2 = part

				local function getCharacterObj()
					if v2.Name == "acc" then
						local accessory = v2:GetAttribute("Accessory")
						local root = v2:GetAttribute("Root")

						if accessory and root then
							return parent:QueryDescendants((`#{accessory} > #{root}`))[1]
						end
					else
						local bone = v2:GetAttribute("Bone")

						if not bone then
							return (parent:FindFirstChild(v2.Name))
						end

						local v3 = parent:QueryDescendants((`Bone[Name="{bone}"]`))[1]
						local attachment = v3 and v3:FindFirstChild("Attachment")
						return attachment or parent:FindFirstChild(v2.Name)
					end
				end

				local maid2 = maid:Extend()
				local v3 = part

				local function updatePivot(attachment)
					maid2:Clean()
					v3.CanCollide = false
					v3.Anchored = false
					v3.CanQuery = false
					v3.CanTouch = false
					v3.Massless = true
					v3.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0, 0)
					v3.Transparency = 1

					if attachment:IsA("Attachment") then
						local attPose = v3:FindFirstChild("AttPose")

						if attPose then
							maid2:Add(v.Physics.CreateRigidWeld(attachment, attPose))
						end
					else
						local v4 = maid2:Add(v.Physics.CreateWeld(attachment, v3))
						local C0 = v3:FindFirstChild("C0")

						if C0 then
							v4.C0 = C0.CFrame
						end

						local C1 = v3:FindFirstChild("C1")

						if C1 then
							v4.C1 = C1.CFrame
						end
					end
				end

				local characterObj = getCharacterObj()

				if characterObj and part:IsA("BasePart") then
					updatePivot(characterObj)
				end
			end

			child.Parent = parent2
			maid:Add(child)
		end

		clone:Destroy()

		for _, v2 in parent2:QueryDescendants("BasePart") do
			v2.Massless = true
			v2.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0, 0)
			v2.RootPriority = -1
			v2.CanCollide = false
			local parent3 = v2.Parent
			v2.Anchored = v2.Name == "RenderTemplate" and parent3 ~= nil and parent3:GetAttribute("Transformed") == true
		end

		for _, child in parent2:GetChildren() do
			if string.find(child.Name, "Enable") and not child:GetAttribute("IgnoreEnable") then
				for _, instance2 in getVFX(child) do
					if instance2:IsA("ParticleEmitter") or instance2:IsA("Trail") or instance2:IsA("PointLight") then
						instance2.Enabled = false
						local v2 = instance2
						maid:Add(task.delay((child:GetAttribute("EnableFrame") or 0) / 60, function()
							v2.Enabled = true
						end))
					elseif instance2:IsA("Beam") then
						instance2.Enabled = true
						instance2:SetAttribute("TargetWidth0", instance2.Width0)
						instance2:SetAttribute("TargetWidth1", instance2.Width1)
						instance2.Width0 = 0
						instance2.Width1 = 0
						local v2 = instance2
						maid:Add(task.delay((child:GetAttribute("EnableFrame") or 0) / 60, function()
							v2:AddTag("BeamTweenWidth")
						end))
					elseif instance2:IsA("Sound") and (Players:GetPlayerFromCharacter(parent) and (parent.Parent == workspace.Dead or parent.Parent == workspace.Alive) or isClient and parent:IsDescendantOf(workspace.CurrentCamera) or instance2:GetAttribute("ForcePlay")) then
						local v2 = instance2
						maid:Add(task.delay((child:GetAttribute("EnableFrame") or 0) / 60, function()
							if v2:GetAttribute("PlayGeral") then
								local clone2 = v2:Clone()
								clone2.Parent = SoundService
								clone2:Play()
								maid:Add(function()
									clone2:Stop()
									clone2:Destroy()
								end)
							else
								v2:AddTag("EmoteSFX")
								v2:Play()
								maid:Add(function()
									v2:Stop()
									v2:Destroy()
								end)
							end
						end))
					end

					local disableFrame = child:GetAttribute("DisableFrame")

					if not disableFrame then
						continue
					end

					local instance3 = instance2
					maid:Add(task.delay(disableFrame / 60, function()
						if instance3:IsA("ParticleEmitter") or instance3:IsA("Trail") or instance3:IsA("PointLight") then
							instance3.Enabled = false
						elseif instance3:IsA("Beam") then
							instance3:RemoveTag("BeamTweenWidth")
							instance3.Width0 = instance3:GetAttribute("TargetWidth0") or 0
							instance3.Width1 = instance3:GetAttribute("TargetWidth1") or 0
							instance3:SetAttribute("TargetWidth0", 0)
							instance3:SetAttribute("TargetWidth1", 0)
							instance3:AddTag("BeamTweenWidth")
							maid:Add(task.delay(0.3, function()
								instance3.Enabled = false
							end))
						elseif instance3:IsA("Sound") then
							instance3:Stop()
						end
					end))
				end
			end

			if not string.find(child.Name, "Emit") or child:GetAttribute("IgnoreEmit") then
				continue
			end

			if string.find(child.Name, "LoopedEmit") and child:GetAttribute("LoopDuration") then
				local v2 = getVFX(child)
				local v3 = child
				maid:Add(task.delay((child:GetAttribute("LoopDelay") or 0) / 60, function()
					while true do
						for k, instance2 in v2 do
							if not (instance2:IsA("ParticleEmitter") or instance2:IsA("Sound")) then
								continue
							end

							if instance2:IsA("ParticleEmitter") then
								instance2:Emit(instance2:GetAttribute("EmitCount"))
							elseif instance2:IsA("Sound") and (Players:GetPlayerFromCharacter(parent) and (parent.Parent == workspace.Dead or parent.Parent == workspace.Alive) or isClient and parent:IsDescendantOf(workspace.CurrentCamera) or instance2:GetAttribute("ForcePlay")) then
								instance2:AddTag("EmoteSFX")
								instance2.Looped = false
								instance2:Play()

								if instance2:GetAttribute("PlayGeral") then
									local clone2 = instance2:Clone()
									clone2.Parent = SoundService
									clone2.Looped = false
									clone2:Play()
									maid:Add(clone2)
								else
									instance2.Looped = false
									instance2:Play()
								end
							end
						end

						task.wait(v3:GetAttribute("LoopDuration") / 60)
					end
				end))
			else
				local attributes = child:GetAttributes()

				for _, instance2 in getVFX(child) do
					if not (instance2:IsA("ParticleEmitter") or instance2:IsA("Sound")) then
						continue
					end

					for k, attribute in attributes do
						if not string.find(k, "EmitFrame") then
							continue
						end

						local instance3 = instance2
						maid:Add(task.delay(attribute / 60 + (instance2:GetAttribute("EmitDelay") or 0), function()
							if instance3:IsA("ParticleEmitter") then
								instance3:Emit(instance3:GetAttribute("EmitCount"))
							elseif instance3:IsA("Sound") and (Players:GetPlayerFromCharacter(parent) and (parent.Parent == workspace.Dead or parent.Parent == workspace.Alive) or isClient and parent:IsDescendantOf(workspace.CurrentCamera)) then
								instance3:AddTag("EmoteSFX")
								instance3.Looped = false
								instance3:Play()
							end
						end))
					end
				end
			end
		end
	end
}