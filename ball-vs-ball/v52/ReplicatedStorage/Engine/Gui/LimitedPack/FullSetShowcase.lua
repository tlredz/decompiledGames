local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local service = ReplicatedStorage.Engine.Service
local EffectPlayer = require(service.EffectPlayer)
local EmoteMountService = require(service.EmoteMountService)
local LimitedPackService = require(service.LimitedPackService)
return {
	Start = function(folder, p)
		local folder2 = Instance.new("Folder")
		folder2.Name = "完整套装运行时"
		folder2.Parent = folder
		local lockedToPartsByEmitter = {}
		local localTransparencyModifiersByDescendant = {}
		local enabledsByDescendant = {}
		local flag = true

		for _, emitter in folder:GetDescendants() do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			lockedToPartsByEmitter[emitter] = emitter.LockedToPart
			emitter.LockedToPart = true
		end

		local v = nil
		local v2 = nil
		local clones = {}

		local function hide(folder3)
			for _, descendant in folder3:GetDescendants() do
				if descendant:IsA("BasePart") then
					localTransparencyModifiersByDescendant[descendant] = descendant.LocalTransparencyModifier
					descendant.LocalTransparencyModifier = 1
				elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") then
					enabledsByDescendant[descendant] = descendant.Enabled
					descendant.Enabled = false
				end
			end
		end

		local model = folder:FindFirstChild("爆炸特效")

		if model then
			local clone = model:Clone()
			table.insert(clones, clone)
			hide(model)
			task.delay(0.55, function()
				while flag do
					local clone2 = clone:Clone()
					clone2.Name = "爆炸特效播放"

					if clone2:IsA("Model") and model:IsA("Model") then
						clone2:PivotTo(model:GetPivot())
					end

					clone2.Parent = folder2
					local v3 = EffectPlayer.playLive(clone2)
					task.wait((math.max(v3, 0.1)))
					clone2:Destroy()

					if not flag then
						break
					end

					task.wait(1)
				end
			end)
		end

		local firstChild = folder:FindFirstChild("飞行器")
		local rig = firstChild and firstChild:FindFirstChild("Rig")
		local groupContents = LimitedPackService.getGroupContents(p)

		if rig and rig:IsA("Model") then
			task.spawn(function()
				local v3 = nil
				local success, result = pcall(function()
					local character = Players.LocalPlayer.Character
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")
					local v4

					if humanoid then
						v4 = humanoid:GetAppliedDescription()
					else
						v4 = Players:GetHumanoidDescriptionFromUserIdAsync(Players.LocalPlayer.UserId)
					end

					v3 = v4
					return Players:CreateHumanoidModelFromDescriptionAsync(v3, Enum.HumanoidRigType.R15)
				end)

				if v3 then
					v3:Destroy()
				end

				if success then
					if not flag then
						result:Destroy()
						return
					end

					local humanoidRootPart = result:FindFirstChild("HumanoidRootPart")
					local humanoidRootPart2 = rig:FindFirstChild("HumanoidRootPart")
					local humanoid = result:FindFirstChildOfClass("Humanoid")

					if not (humanoidRootPart and humanoidRootPart2 and humanoid) then
						result:Destroy()
						return
					end

					for _, descendant in result:GetDescendants() do
						if descendant:IsA("BaseScript") then
							descendant:Destroy()
						elseif descendant:IsA("BasePart") then
							descendant.Anchored = descendant == humanoidRootPart
							descendant.CanCollide = false
							descendant.CanTouch = false
							descendant.CanQuery = false
						end
					end

					humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
					humanoid.AutoRotate = false
					result.Name = "玩家展示"
					result:ScaleTo(rig:GetScale())
					result:PivotTo(humanoidRootPart2.CFrame * humanoidRootPart.CFrame:ToObjectSpace(result:GetPivot()))
					result.Parent = folder2

					if groupContents.flyer then
						v, v2 = EmoteMountService.client.mountLocal(result, groupContents.flyer)
					end

					if flag then
						for _, emitter in result:GetDescendants() do
							if emitter:IsA("ParticleEmitter") then
								emitter.LockedToPart = true
							end
						end

						hide(rig)
					else
						EmoteMountService.client.unmountLocal(v, v2)
						result:Destroy()
					end
				elseif flag then
					warn("[FullSetShowcase] 玩家外观加载失败: " .. tostring(result))
				end
			end)
		end

		return function()
			if not flag then
				return
			end

			flag = false
			EmoteMountService.client.unmountLocal(v, v2)
			folder2:Destroy()

			for _, v3 in clones do
				v3:Destroy()
			end

			for k, localTransparencyModifier in localTransparencyModifiersByDescendant do
				if k.Parent then
					k.LocalTransparencyModifier = localTransparencyModifier
				end
			end

			for k, enabled in enabledsByDescendant do
				if k.Parent then
					k.Enabled = enabled
				end
			end

			for k, lockedToPart in lockedToPartsByEmitter do
				if k.Parent then
					k.LockedToPart = lockedToPart
				end
			end
		end
	end
}