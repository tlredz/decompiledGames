local Effects = {}
local Players = game:GetService("Players")
local parent = script.Parent.Parent
local packages = parent.Parent.Packages
local Attachments = require(parent.Attachments)
local ServerAudio = require(parent.ServerAudio)
local RunContext = require(packages.RunContext)
require(parent.Trove)
local Tags = require(packages.Tags)
local v = {
	Bass = true,
	Treble = true,
	Percussion = true,
	Loudness = true
}
local v2 = {}

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function lerp(p, p2, p3: number)
	return p * (1 - p3) + p2 * p3
end

local function findCharacterAndPlayer(parent2)
	while parent2 and parent2 ~= workspace do
		if parent2:IsA("Model") then
			local userId = tonumber(parent2:GetAttribute("UserId"))
			local playerByUserId = userId and Players:GetPlayerByUserId(userId)

			if playerByUserId then
				return parent2, playerByUserId
			end

			local playerFromCharacter = Players:GetPlayerFromCharacter(parent2)

			if playerFromCharacter then
				return parent2, playerFromCharacter
			end
		end

		parent2 = parent2.Parent
	end

	return nil
end

local function onEffectAdded(folder)
	local class = folder:GetAttribute("Class")

	if type(class) ~= "string" then
		return
	end

	local class2

	if class == "Bass" then
		class2 = "Bass"
	elseif class == "Treble" then
		class2 = "Treble"
	elseif class == "Percussion" then
		class2 = "Percussion"
	else
		class2 = "Loudness"
	end

	local characterAndPlayer, owner = findCharacterAndPlayer(folder)
	local v5 = owner and ServerAudio.Await(owner.UserId, 3)
	local bin = v5 and v5.Bin
	local basePart = folder:FindFirstAncestorWhichIsA("BasePart")
	local audioAnalyzer = basePart and basePart:FindFirstChildWhichIsA("AudioAnalyzer", true)
	local audioPlayer = bin and bin:FindFirstChildOfClass("AudioPlayer")
	local audioAnalyzer2 = bin and bin:FindFirstChild(class2)
	local clientAnalyzer = nil
	local clientPlayer = nil

	if owner == Players.LocalPlayer then
		local audioPlayer2 = Tags.FindFirstTagged("RelicsClientAudioPlayer")
		local audioAnalyzer3 = Tags.FindFirstTagged((`RelicsAudioAnalyzer_{class2}`))

		if audioAnalyzer3 and audioAnalyzer3:IsA("AudioAnalyzer") then
			clientAnalyzer = audioAnalyzer3
		end

		if audioPlayer2 and audioPlayer2:IsA("AudioPlayer") then
			clientPlayer = audioPlayer2
		end
	end

	if audioPlayer and audioAnalyzer2 and audioAnalyzer2:IsA("AudioAnalyzer") then
		local v8 = nil

		if folder:IsA("ParticleEmitter") then
			local size = folder.Size
			local emitCount = tonumber(folder:GetAttribute("EmitCount"))
			local originalRate = tonumber(folder:GetAttribute("OriginalRate")) or folder.Rate
			local originalBrightness = tonumber(folder:GetAttribute("OriginalBrightness")) or folder.Brightness
			folder.LockedToPart = true
			v8 = {
				ServerAnalyzer = audioAnalyzer2,
				ClientAnalyzer = clientAnalyzer,
				RootAnalyzer = audioAnalyzer,
				ServerPlayer = audioPlayer,
				ClientPlayer = clientPlayer,
				Type = "Particle",
				Class = class2,
				Ref = folder,
				Data = {
					OriginalBrightness = originalBrightness,
					OriginalRate = originalRate,
					EmitCount = emitCount,
					BaseSize = size,
					Size = size
				},
				Owner = owner,
				MemoryCache = {}
			}
		elseif folder:IsA("Beam") then
			local width0 = folder.Width0
			local width1 = folder.Width1
			local originalTextureSpeed = tonumber(folder:GetAttribute("OriginalTextureSpeed")) or folder.TextureSpeed
			v8 = {
				ServerAnalyzer = audioAnalyzer2,
				ClientAnalyzer = clientAnalyzer,
				RootAnalyzer = audioAnalyzer,
				ServerPlayer = audioPlayer,
				ClientPlayer = clientPlayer,
				Type = "Beam",
				Class = class2,
				Ref = folder,
				Data = {
					BaseTextureSpeed = originalTextureSpeed,
					BaseWidth0 = width0,
					BaseWidth1 = width1,
					Width0 = width0,
					Width1 = width1
				},
				Owner = owner,
				MemoryCache = {}
			}
		elseif folder:IsA("Trail") then
			local widthScale = folder.WidthScale
			v8 = {
				ServerAnalyzer = audioAnalyzer2,
				ClientAnalyzer = clientAnalyzer,
				RootAnalyzer = audioAnalyzer,
				ServerPlayer = audioPlayer,
				ClientPlayer = clientPlayer,
				Type = "Trail",
				Class = class2,
				Ref = folder,
				Data = {
					BaseWidthScale = widthScale,
					WidthScale = widthScale
				},
				Owner = owner,
				MemoryCache = {}
			}
		elseif folder:IsA("Bone") then
			local rotSpeed = folder:GetAttribute("RotSpeed")
			v8 = typeof(rotSpeed) == "CFrame" and {
				ServerAnalyzer = audioAnalyzer2,
				ClientAnalyzer = clientAnalyzer,
				RootAnalyzer = audioAnalyzer,
				ServerPlayer = audioPlayer,
				ClientPlayer = clientPlayer,
				Type = "Bone",
				Class = class2,
				Ref = folder,
				Data = {
					RotSpeed = rotSpeed
				},
				Owner = owner,
				MemoryCache = {}
			} or v8
		end

		if v8 then
			local parent2 = folder

			while parent2 and parent2 ~= characterAndPlayer do
				local parentPart = parent2:GetAttribute("ParentPart")
				local parentAttachment = parent2:GetAttribute("ParentAttachment")
				local parentSize = parent2:GetAttribute("ParentSize")

				if type(parentPart) == "string" and type(parentAttachment) == "string" then
					local part = characterAndPlayer and characterAndPlayer:FindFirstChild(parentPart)
					local attachment = part and part:FindFirstChild(parentAttachment)

					if part and part:IsA("BasePart") and attachment and attachment:IsA("Attachment") then
						if parent2.Parent == attachment then
							break
						end

						folder:SetAttribute("ParentPart", nil)
						folder:SetAttribute("ParentSize", nil)
						folder:SetAttribute("ParentAttachment", nil)
						local v9 = parentSize
						local v10 = part
						local parent4 = attachment
						task.defer(function()
							if typeof(v9) == "Vector3" then
								local v12 = v10.Size / v9

								if folder:IsA("Attachment") then
									folder.Position *= v12
								end

								for i, descendant in folder:GetDescendants() do
									if descendant:IsA("BasePart") then
										descendant.Size *= v12
									elseif descendant:IsA("Attachment") then
										descendant.Position *= v12
									end
								end
							end

							local parent3 = parent2.Parent
							parent2.Parent = parent4

							if parent3 then
								parent3.Destroying:Once(function()
									folder:Destroy()
								end)
							end
						end)
						break
					end
				end

				parent2 = parent2.Parent
			end

			v2[folder] = v8
		end
	end
end

local function onEffectRemoved(p)
	v2[p] = nil
end

function Effects.Update(enabled: boolean, p: number)
	local localPlayer = Players.LocalPlayer
	local v3 = 0
	local v4 = 0
	local v5 = 0
	local v6 = 0

	for k, v7 in pairs(v2) do
		local owner = v7.Owner
		local rootAnalyzer = v7.RootAnalyzer

		if not (not owner or owner == localPlayer or v7.Enabled or v7.Enabled == nil or enabled) then
			continue
		end

		local serverAnalyzer = v7.ServerAnalyzer
		local clientAnalyzer = v7.ClientAnalyzer
		local serverPlayer = v7.ServerPlayer
		local clientPlayer = v7.ClientPlayer
		local rmsLevel

		if rootAnalyzer then
			rmsLevel = rootAnalyzer.RmsLevel
		elseif clientAnalyzer then
			rmsLevel = math.max(serverAnalyzer.RmsLevel, clientAnalyzer.RmsLevel)
		else
			rmsLevel = serverAnalyzer.RmsLevel
		end

		local parent2 = k.Parent
		local flag = false

		while parent2 do
			if parent2:GetAttribute("EmoteEffect") then
				flag = true
				break
			else
				parent2 = parent2.Parent
			end
		end

		if not flag then
			rmsLevel /= 2
		end

		local isPlaying

		if clientPlayer then
			isPlaying = serverPlayer.IsPlaying or clientPlayer.IsPlaying
		else
			isPlaying = serverPlayer.IsPlaying
		end

		if not enabled then
			isPlaying = false
		end

		local timeScale = not (isPlaying or rootAnalyzer) and (flag and 0 or 0.2) or rmsLevel
		local prev = v7.Prev or 0
		local v9 = 0

		if v7.Class == "Bass" then
			v9 = math.max(v6, timeScale)
			v6 = v9
		elseif v7.Class == "Treble" then
			v9 = math.max(v5, timeScale)
			v5 = v9
		elseif v7.Class == "Loudness" then
			v9 = math.max(v4, timeScale)
			v4 = v9
		elseif v7.Class == "Percussion" then
			v9 = math.max(v3, timeScale)
			v3 = v9
		end

		local v10 = timeScale + 1
		rawset(v7, "Prev", timeScale)
		local v11 = math.round(v10 * 40) / 40

		if v7.Type == "Particle" then
			local ref = v7.Ref
			local data = v7.Data

			if flag then
				if v7.Class == "Loudness" then
					ref.Rate = data.OriginalRate
					ref.Enabled = enabled

					if v6 > 0 and math.abs(v6 - (v7.BassPrev or 0)) > 0.2 then
						if enabled and data.EmitCount then
							ref:Emit((math.clamp(data.EmitCount, 0, 3)))
						end

						rawset(v7, "BassPrev", v6)
					end
				elseif math.abs(timeScale - prev) > 0.05 then
					if enabled then
						ref:Emit((math.clamp(data.EmitCount or 1, 0, 3)))
					end
				else
					local originalRate = data.OriginalRate
					ref.Rate = math.min(originalRate * v11 / v9, originalRate)
					ref.Enabled = enabled
				end
			elseif v7.Class ~= "Loudness" then
				if math.abs(timeScale - prev) > 0.25 then
					if enabled then
						ref:Emit((math.clamp(data.EmitCount or 1, 0, 3)))
					end
				else
					local originalRate = data.OriginalRate
					ref.Rate = math.min(originalRate * v11 / v9, originalRate)
					ref.Enabled = enabled
				end
			end

			if enabled then
				local originalBrightness = data.OriginalBrightness

				if flag then
					local v12

					if v7.Class == "Loudness" then
						local wasPlaying = v7.WasPlaying

						if isPlaying and not wasPlaying then
							v12 = math.max(timeScale, 0.5)
						else
							v12 = timeScale
						end
					else
						v12 = timeScale
					end

					v11 = v12 + 1
					ref.Brightness = math.min(originalBrightness * v11 / v9, originalBrightness)

					if v7.Class == "Loudness" then
						local parent3 = v7.ServerPlayer.Parent
						local bass = parent3 and parent3:FindFirstChild("Bass")
						local v13 = not (isPlaying and bass and bass:IsA("AudioAnalyzer")) and 0 or bass.RmsLevel
						local wasPlaying = v7.WasPlaying

						if isPlaying and not wasPlaying then
							v7.LoudnessSpeed = 1
						end

						v7.WasPlaying = isPlaying
						local v14 = v13 * 2.8 + 0.2
						local loudnessSpeed = v7.LoudnessSpeed or 1
						local loudnessSpeed2 = lerp(loudnessSpeed, v14, loudnessSpeed < v14 and 0.15 or 0.7)
						v7.LoudnessSpeed = loudnessSpeed2
						ref.TimeScale = 0.5 + loudnessSpeed2
					elseif v7.Class == "Bass" then
						ref.TimeScale = 0.5 + timeScale * 1
					else
						ref.TimeScale = timeScale
					end
				else
					ref.Brightness = math.min(originalBrightness * v11 / v9 / 4, originalBrightness)
					ref.TimeScale = math.max(timeScale, 0.2)
				end

				local v12 = v7.Class == "Bass" and 6 or 10
				local baseSize = data.BaseSize
				local size = data.Size
				local keypoints = baseSize.Keypoints
				local keypoints2 = size.Keypoints
				local v13 = not flag and 0.34 or v7.Class == "Bass" and 0.5 or 0.7

				for i, keypoint in ipairs(keypoints2) do
					local v14 = math.min(keypoints[i].Value * v11, v12)
					local v15 = keypoint.Value * (1 - v13) + v14 * v13
					keypoints2[i] = NumberSequenceKeypoint.new(keypoint.Time, v15)
				end

				data.Size = NumberSequence.new(keypoints2)
				ref.Size = data.Size
			else
				ref:Clear()
			end
		elseif v7.Type == "Beam" then
			local ref = v7.Ref
			local data = v7.Data
			local v12 = flag and 0.7 or 0.34
			local width0 = data.Width0
			local v13 = math.min(data.BaseWidth0 * v11, 10)
			local width = not enabled and 0 or lerp(width0, v13, v12) or 0
			ref.Width0 = width
			data.Width0 = width
			local width1 = data.Width1
			local v15 = math.min(data.BaseWidth1 * v11, 10)
			local width2 = enabled and lerp(width1, v15, v12) or 0
			ref.Width1 = width2
			data.Width1 = width2
			ref.TextureSpeed = math.sign(data.BaseTextureSpeed) * math.abs(timeScale * 2)
		elseif v7.Type == "Bone" then
			local ref = v7.Ref
			local rotSpeed = v7.Data.RotSpeed
			ref.CFrame *= CFrame.identity:Lerp(rotSpeed, p * timeScale)
		end

		v7.Enabled = enabled
	end
end

function Effects:BindEffect()
	local v3 = Attachments.FindFirstCharacterAttachment(self)

	if not (v3 and v3:IsA("Attachment")) then
		v3 = Instance.new("Attachment")
		v3.CFrame = self.PivotOffset
		v3.Name = "RootAttachment"
		v3.Parent = self
	end

	self.Massless = true
	self.CanQuery = false
	self.CanTouch = false
	self.Anchored = false
	self.CanCollide = false
	self.AudioCanCollide = false
	self.EnableFluidForces = false
	self.Transparency = 1
	self.Name = "Aura"

	for _, descendant in self:GetDescendants() do
		if not descendant:IsA("Attachment") then
			continue
		end

		descendant:AddTag("RelicsAuraAtt")
		local name = descendant.Name
		local v4 = not v[name] and "Loudness" or name

		if descendant:IsA("Bone") then
			descendant:SetAttribute("Class", v4)
			descendant:AddTag("RelicsAuraFx")
		end

		for _, descendant2 in descendant:GetDescendants() do
			if not (descendant2:IsA("ParticleEmitter") or descendant2:IsA("Trail") or descendant2:IsA("Beam") or descendant2:IsA("Bone")) then
				continue
			end

			descendant2:SetAttribute("Class", v4)
			descendant2:AddTag("RelicsAuraFx")
		end
	end

	for _, part in self:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.EnableFluidForces = false
		part.AudioCanCollide = false
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Anchored = false
		part.Massless = true
	end

	return v3
end

if RunContext.IsClient then
	task.delay(1, function()
		Tags.Bind("RelicsAuraFx", onEffectAdded, onEffectRemoved)
	end)
end

return Effects