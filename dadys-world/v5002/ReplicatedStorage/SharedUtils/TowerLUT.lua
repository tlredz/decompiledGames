local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = {}
local childrenByChildName = {}
local v2 = {}
local towerData = ReplicatedStorage:WaitForChild("TowerData")
local towerData2 = ReplicatedStorage:WaitForChild("SharedData"):WaitForChild("TowerData")
local skins = ReplicatedStorage:WaitForChild("Skins")
local skinData = ReplicatedStorage:WaitForChild("SharedData"):WaitForChild("SkinData")
local SimulatedTime = require(ReplicatedStorage.SharedUtils.SimulatedTime)
local skinModelStorage, towers

if RunService:IsServer() then
	local ServerStorage = game:GetService("ServerStorage")
	skinModelStorage = ServerStorage:WaitForChild("SkinModelStorage")
	towers = ServerStorage:WaitForChild("Towers")

	if not script:GetAttribute("Server_Init") then
		script:SetAttribute("Server_Init", true)
		local folder = Instance.new("Folder")
		folder.Name = "HiddenSkins"
		folder.Parent = ServerStorage
		local v3 = {}

		local function is_skin_visible(p, p2: number)
			if p2 < (not p.Unlocks and 0 or p.Unlocks.UnixTimestamp or 0) then
				return false
			end

			local availability = p.Availability

			if not availability then
				return true
			end

			if p2 < (not availability.From and 0 or availability.From.UnixTimestamp or 0) then
				return false
			end

			local unixTimestamp = availability.To and availability.To.UnixTimestamp or nil
			return not (unixTimestamp and unixTimestamp <= p2)
		end

		local function refresh_skin_visibility(unixTimestamp: number, flag: boolean)
			local v4 = false

			for k, v5 in pairs(v3) do
				local data = v5.data
				local v6

				if unixTimestamp < (not data.Unlocks and 0 or data.Unlocks.UnixTimestamp or 0) then
					v6 = false
				else
					local availability = data.Availability

					if availability then
						if unixTimestamp < (not availability.From and 0 or availability.From.UnixTimestamp or 0) then
							v6 = false
						else
							local unixTimestamp2 = availability.To and availability.To.UnixTimestamp or nil
							v6 = not (unixTimestamp2 and unixTimestamp2 <= unixTimestamp)
						end
					else
						v6 = true
					end
				end

				if v6 == (k.Parent ~= folder) then
					continue
				end

				if v6 then
					k.Parent = v5.home
				else
					v2[k.Name] = nil
					k.Parent = folder
				end

				v4 = true
			end

			if v4 and flag then
				skinData:SetAttribute("Refreshed", unixTimestamp)
			end
		end

		for _, child in pairs(skinData:GetChildren()) do
			for _, moduleScript in pairs(child:GetChildren()) do
				if not moduleScript:IsA("ModuleScript") then
					continue
				end

				local success, result = pcall(require, moduleScript)

				if success then
					if result.Unlocks or result.Availability then
						v3[moduleScript] = {
							data = result,
							home = child
						}
					end
				else
					warn("Failed to load skin module: " .. tostring(moduleScript))
				end
			end
		end

		refresh_skin_visibility(SimulatedTime.now().UnixTimestamp, false)
		SimulatedTime:Subscribe(function(p)
			refresh_skin_visibility(p.UnixTimestamp, true)
		end)
	end
else
	skinModelStorage = nil
	towers = nil
end

function v.GetMonster(_, childName: string)
	if not childName then
		return
	end

	local monsterData = ReplicatedStorage:FindFirstChild("MonsterData")
	local moduleScript = monsterData and monsterData:FindFirstChild(childName)

	if not (moduleScript and moduleScript:IsA("ModuleScript")) then
		return
	end

	local success, result = pcall(require, moduleScript)

	if success then
		return result
	end
end

function v:GetTower(childName: string, flag: boolean?)
	if not flag and childrenByChildName[childName] then
		return childrenByChildName[childName]
	end

	local child = towerData2:FindFirstChild(childName)

	if child then
		childrenByChildName[childName] = child
		return child
	end

	local child2 = towerData:FindFirstChild(childName)
	childrenByChildName[childName] = child2
	return child2
end

function v:GetEffectiveTower(instance)
	if not instance then
		return nil, false
	end

	local config = instance:FindFirstChild("Config")
	local moduleName = config and config:FindFirstChild("ModuleName")
	local value = moduleName and moduleName.Value or nil
	local maskToon = instance:GetAttribute("MaskToon")
	local tower = type(maskToon) == "string" and maskToon ~= "" and instance:GetAttribute("MaskStatsOnly") ~= true and self:GetTower(maskToon)

	if tower then
		return tower, true
	end

	if value then
		return self:GetTower(value), false
	end

	return nil, false
end

function v:GetPassiveToon(instance)
	if not instance then
		return nil
	end

	local maskToon = instance:GetAttribute("MaskToon")

	if type(maskToon) == "string" and maskToon ~= "" and instance:GetAttribute("MaskStatsOnly") ~= true then
		local maskPassive = instance:GetAttribute("MaskPassive")

		if type(maskPassive) == "string" and maskPassive ~= "" then
			return maskPassive
		end

		return nil
	else
		local config = instance:FindFirstChild("Config")
		local moduleName = config and config:FindFirstChild("ModuleName")
		return moduleName and moduleName.Value or nil
	end
end

function v:HasPassive(p, p2: string)
	return self:GetPassiveToon(p) == p2
end

function v:GetPassiveTower(p)
	local passiveToon = self:GetPassiveToon(p)
	return passiveToon and self:GetTower(passiveToon) or nil
end

function v.GetSkinAbilityModule(_, childName: string, childName2: string?)
	if type(childName2) ~= "string" or childName2 == "" or childName2 == "Default" then
		return nil
	end

	local v3 = skinData:FindFirstChild(childName) or skins:FindFirstChild(childName)
	local moduleScript = v3 and v3:FindFirstChild(childName2)

	if not (moduleScript and moduleScript:IsA("ModuleScript")) then
		return nil
	end

	local success, result = pcall(require, moduleScript)

	if success and type(result) == "table" then
		return result
	end

	return nil
end

function v.GetSkinModuleFolder(_)
	return skinData
end

function v:GetSkin(childName: string, childName2: string)
	if v2[childName2] then
		return v2[childName2]
	end

	local child = skinData:FindFirstChild(childName)
	local child2 = skins:FindFirstChild(childName)
	local v3 = child or child2

	if not v3 then
		return nil
	end

	local child3 = v3:FindFirstChild(childName2)

	if not child3 then
		if child2 == v3 then
			child3 = false
		else
			child3 = child2 and child2:FindFirstChild(childName2)
		end
	end

	if not child3 then
		return nil
	end

	v2[childName2] = child3
	return child3
end

function v.GetSkinModel(_, childName: string, childName2: string)
	if RunService:IsClient() then
		return
	end

	local child = skinModelStorage and skinModelStorage:FindFirstChild(childName)
	local child2 = child and child:FindFirstChild(childName2)
	local child3 = child2 and child2:FindFirstChild(childName2)

	if child3 then
		return child3:Clone()
	end

	warn("COULD NOT FIND SKIN MODEL FOR " .. tostring(childName) .. " -> " .. tostring(childName2))
end

function v:GetDefaultModelTemplate(childName: string)
	if RunService:IsClient() then
		return
	else
		return towers and towers:FindFirstChild(childName)
	end
end

function v:GetTowerScripts(p: string)
	local defaultModelTemplate = self:GetDefaultModelTemplate(p)

	if not defaultModelTemplate then
		return {}
	end

	local clones = {}

	for _, script2 in pairs(defaultModelTemplate:GetDescendants()) do
		if script2:IsA("Script") then
			clones[#clones + 1] = script2:Clone()
		end
	end

	return clones
end

function v.ApplySkinBase(_, instance, p)
	local config = instance:FindFirstChild("Config")

	if p.FaceTextures then
		local blinkTexture = config and config:FindFirstChild("BlinkTexture")
		local hurtTexture = config and config:FindFirstChild("HurtTexture")
		local normalTexture = config and config:FindFirstChild("NormalTexture")

		if blinkTexture and hurtTexture and normalTexture then
			blinkTexture.Texture = p.FaceTextures.Blink
			hurtTexture.Texture = p.FaceTextures.Hurt
			normalTexture.Texture = p.FaceTextures.Normal
		else
			warn(("[ApplySkinBase] %s: rig has no Config face textures - skipping FaceTextures"):format(instance.Name))
		end
	end

	if p.OverwriteAnimations then
		local animations = instance:FindFirstChild("Animations")

		if animations then
			for childName, overwriteAnimation in pairs(p.OverwriteAnimations) do
				local animation = animations:FindFirstChild(childName)

				if animation and animation:IsA("Animation") then
					animation.AnimationId = overwriteAnimation
				end
			end
		else
			warn(("[ApplySkinBase] %s: rig has no Animations folder - skipping OverwriteAnimations"):format(instance.Name))
		end
	end
end

function v:OnLoad(p: string, p2, p3)
	if not (p3 and p3.Name and p) then
		return
	end

	local tower = self:GetTower(p)
	local module = tower and require(tower)
	local onLoad = module and module.OnLoad
	local onLoad2 = p2 and p2.OnLoad

	if onLoad2 then
		onLoad2(onLoad or function() end, p3)
	elseif onLoad then
		onLoad(p3)
	end
end

function v:FindOrCreateLatchedAttachment(folder)
	if not (folder and folder.Parent) then
		return nil
	end

	for _, attachment in pairs(folder:GetDescendants()) do
		if attachment:IsA("Attachment") and attachment.Name == "LatchedAttachment" then
			return attachment
		end
	end

	local toonName = folder:GetAttribute("ToonName")

	if type(toonName) ~= "string" or toonName == "" then
		warn(("[FindOrCreateLatchedAttachment] %s: missing ToonName attribute"):format(folder.Name))
		return nil
	end

	local rightHandBone = nil
	local latchedBoneOffset = nil
	local currentSkin = folder:GetAttribute("CurrentSkin")

	if type(currentSkin) == "string" and currentSkin ~= "" and currentSkin ~= "Default" then
		local skin = self:GetSkin(toonName, currentSkin)

		if skin then
			local success, result = pcall(require, skin)

			if success and type(result) == "table" and type(result.RightHandBone) == "string" then
				rightHandBone = result.RightHandBone

				if result.LatchedBoneOffset then
					latchedBoneOffset = result.LatchedBoneOffset
				end
			end
		end
	end

	if not rightHandBone then
		local tower = self:GetTower(toonName)

		if tower then
			local success, result = pcall(require, tower)

			if success and type(result) == "table" and type(result.RightHandBone) == "string" then
				rightHandBone = result.RightHandBone

				if result.LatchedBoneOffset then
					latchedBoneOffset = result.LatchedBoneOffset
				end
			end
		end
	end

	if not rightHandBone then
		warn(("[FindOrCreateLatchedAttachment] %s (toon=%s, skin=%s): RightHandBone not declared in skin or tower data"):format(
			folder.Name,
			tostring(toonName),
			(tostring(currentSkin))
		))
		return nil
	end

	local parent = nil

	for _, descendant in pairs(folder:GetDescendants()) do
		if not (descendant.Name == rightHandBone and (descendant:IsA("Bone") or descendant:IsA("BasePart"))) then
			continue
		end

		parent = descendant
		break
	end

	if not parent then
		warn(("[FindOrCreateLatchedAttachment] %s (toon=%s): bone '%s' not found in rig"):format(
			folder.Name,
			tostring(toonName),
			(tostring(rightHandBone))
		))
		return nil
	end

	if not RunService:IsServer() then
		return nil
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "LatchedAttachment"
	attachment.Parent = parent

	if latchedBoneOffset and typeof(latchedBoneOffset) == "CFrame" then
		attachment.CFrame = latchedBoneOffset
	end

	return attachment
end

function v.TransferContents(_, folder, folder2, data)
	if data.Particles then
		for _, emitter in pairs(folder:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") or emitter:FindFirstAncestorWhichIsA("Bone") then
				continue
			end

			local basePart = emitter:FindFirstAncestorWhichIsA("BasePart")
			local child = basePart and folder2:FindFirstChild(basePart.Name)

			if not child then
				continue
			end

			local clone_2 = (emitter.Parent == basePart and emitter or emitter.Parent):Clone()
			clone_2.Parent = child
		end

		for _, emitter in pairs(folder2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if emitter:HasTag("SkinParticle") then
				if not emitter.Enabled or emitter.Name == "ParticleThing" then
					emitter:RemoveTag("SkinParticle")
				end
			elseif emitter.Enabled then
				emitter:AddTag("SkinParticle")
			end
		end
	end

	if data.Animations then
		local animations = folder2:FindFirstChild("Animations")
		local animations2 = folder:FindFirstChild("Animations")

		if animations and animations2 then
			for _, child in pairs(animations2:GetChildren()) do
				if animations:FindFirstChild(child.Name) then
					continue
				end

				local clone_3 = child:Clone()
				clone_3.Parent = animations
			end
		else
			warn(("[TransferContents] %s -> %s: missing Animations folder - skipping animation transfer"):format(
				folder.Name,
				folder2.Name
			))
		end
	end

	if data.Trails then
		for _, trail in pairs(folder:GetDescendants()) do
			if not (trail:IsA("Trail") and trail.Attachment0 and trail.Attachment1) then
				continue
			end

			local basePart = trail:FindFirstAncestorWhichIsA("BasePart")
			local child = basePart and folder2:FindFirstChild(basePart.Name)

			if not child then
				continue
			end

			local clone = trail:Clone()
			local clone2 = trail.Attachment0:Clone()
			local clone3 = trail.Attachment1:Clone()
			clone.Parent = child
			clone2.Parent = child
			clone3.Parent = child
			clone.Attachment0 = clone2
			clone.Attachment1 = clone3
		end

		for _, trail in pairs(folder2:GetDescendants()) do
			if trail:IsA("Trail") and trail.Enabled then
				trail:AddTag("SkinTrail")
			end
		end
	end

	if data.Lights then
		local toonLight = folder.HumanoidRootPart:FindFirstChild("ToonLight")

		if toonLight and not folder2.HumanoidRootPart:FindFirstChild("ToonLight") then
			local clone_4 = toonLight:Clone()
			clone_4.Parent = folder2.HumanoidRootPart
		end

		local extraLight = folder.HumanoidRootPart:FindFirstChild("ExtraLight")

		if extraLight and not folder2.HumanoidRootPart:FindFirstChild("ExtraLight") then
			local clone_5 = extraLight:Clone()
			clone_5.Parent = folder2.HumanoidRootPart
		end
	end

	if data.HeadAttachments then
		local v3 = false
		local bubbleChat = folder:FindFirstChild("BubbleChat", true)
		local stickerOverride = folder:FindFirstChild("StickerOverride", true)
		local parent = bubbleChat and bubbleChat.Parent or stickerOverride and stickerOverride.Parent
		local head = folder2:FindFirstChild("Head") or folder2:FindFirstChild(parent.Name)
		local blinkingParts = folder2:FindFirstChild("BlinkingParts")

		if not head and blinkingParts and blinkingParts:FindFirstChild("Head") and blinkingParts.Head.Value and blinkingParts.Head.Value:IsA("BasePart") then
			head = blinkingParts.Head.Value
		end

		local v4

		if bubbleChat and bubbleChat.Parent == folder.PrimaryPart then
			head = folder2:FindFirstChild(parent.Name) or folder2.PrimaryPart
			v4 = true
		else
			v4 = false
		end

		if parent and parent:IsA("BasePart") and head and head:IsA("BasePart") and (bubbleChat and bubbleChat:IsA("Attachment") or stickerOverride and stickerOverride:IsA("Attachment")) then
			local nameTagOverride = nil

			for _, attachment in pairs(parent:GetChildren()) do
				if not attachment:IsA("Attachment") then
					continue
				end

				local clone = head:FindFirstChild(attachment.Name)

				if not clone then
					clone = attachment:Clone()
					clone.Parent = head
				end

				if not (nameTagOverride or v4) then
					nameTagOverride = clone:FindFirstChild("NameTagOverride")
				end
			end

			if nameTagOverride and nameTagOverride:IsA("ObjectValue") then
				local bubbleChat2 = head:FindFirstChild("BubbleChat", true)
				local stickerOverride2 = head:FindFirstChild("StickerOverride", true)
				nameTagOverride.Value = head:FindFirstChild("NameTag") or bubbleChat2 or stickerOverride2
			end

			v3 = true
		end

		if not v3 then
			warn("Unable to transfer head attachments to skin!")
			print(v4)
			print(bubbleChat, stickerOverride)
			print(parent, head, blinkingParts)
		end
	end
end

function v.FindFirstSkin(_, childName: string, flag: boolean)
	local v3 = flag == true

	if v3 and v2[childName] then
		return v2[childName]
	end

	local child = skinData:FindFirstChild(childName, v3)
	local child2 = skins:FindFirstChild(childName, v3)
	return child or child2
end

function v:FindFirstChild(p: string)
	return self:GetTower(p)
end

function v:WaitForChild(p: string)
	local tower = self:GetTower(p, true)

	while not tower and task.wait(1) do
		tower = self:GetTower(p, true)
	end

	return tower
end

function v:GetChildren()
	local v3 = {}
	local children = {}

	local function scan(towerData3)
		for _, child in pairs(towerData3:GetChildren()) do
			if v3[child.Name] then
				continue
			end

			v3[child.Name] = true
			children[#children + 1] = child
		end
	end

	scan(towerData2)
	scan(towerData)
	return children
end

function v.GetAllSkinModules(_)
	local v3 = {}
	local children = {}

	local function scan(instance)
		for _, child in pairs(instance:GetChildren()) do
			if v3[child.Name] then
				continue
			end

			v3[child.Name] = true
			children[#children + 1] = child
		end
	end

	scan(skinData)
	scan(skins)
	return children
end

return (setmetatable(v, {
	__index = function(instance, childName: string)
		local v3 = rawget(instance, childName)

		if v3 then
			return v3
		end

		return instance:FindFirstChild(childName)
	end
}))