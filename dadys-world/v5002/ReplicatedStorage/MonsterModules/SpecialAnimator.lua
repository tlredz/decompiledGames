local SpecialAnimator = {}
SpecialAnimator.__index = SpecialAnimator
local v = {
	passive = {
		sa = "Passive",
		texture = "PassiveTexture",
		blink = true
	},
	normal = {
		sa = "Normal",
		texture = "NormalTexture",
		blink = true
	},
	angry = {
		sa = "Angry",
		texture = "AngryTexture",
		blink = false
	},
	attack = {
		sa = "Attack",
		texture = "AttackTexture",
		blink = false
	}
}

function SpecialAnimator.new(character, config)
	local object = setmetatable({}, SpecialAnimator)
	object.character = character
	object.config = config
	object.isBlinking = false
	object.blinkCoroutine = nil
	object.attackFaceDebounce = false
	object.currentState = "normal"
	object.blinkRestoreState = "Normal"
	object.blinkRestoreTexture = config.NormalTexture
	object.currentGlistenState = nil
	object.heads = {}

	if character:GetAttribute("HasHeadReference") then
		local headPart = character:WaitForChild("HeadPart", 5)

		if headPart and headPart.Value then
			object.heads = { headPart.Value }
		end
	elseif config.HeadComponentNames then
		for _, childName in ipairs(config.HeadComponentNames) do
			local child = character:WaitForChild(childName, 10)

			if child then
				table.insert(object.heads, child)
			end
		end
	elseif config.HeadComponentName then
		local child = character:WaitForChild(config.HeadComponentName, 10)

		if child then
			object.heads = { child }
		end
	else
		local head = character:FindFirstChild("Head")

		if head then
			object.heads = { head }
		else
			for _, childName in ipairs({ "LeftHead", "RightHead" }) do
				local child = character:FindFirstChild(childName)

				if child then
					table.insert(object.heads, child)
				end
			end

			if #object.heads == 0 then
				local head2 = character:WaitForChild("Head", 5)

				if head2 then
					object.heads = { head2 }
				end
			end
		end
	end

	if #object.heads == 0 then
		warn("SpecialAnimator: Failed to find Head (tried:", config.HeadComponentName or "Head/LeftHead/RightHead", ")")
		return nil
	end

	object.head = object.heads[1]
	object.saHeads = nil
	object.saStash = nil
	object.hasPosterSA = false
	object.emissiveBlink = false

	if not object:setupSALayer() then
		task.delay(0.3, function()
			if object.character and object.character.Parent and object:setupSALayer() then
				object:updateFace()
			end
		end)
	end

	object:setupConnections()
	object:updateFace()
	return object
end

function SpecialAnimator:setupSALayer()
	if self.saHeads then
		return true
	end

	local config = self.character:FindFirstChild("Config")
	local normalSAName = self.config.NormalSAName or "Normal"
	local attackSAName = self.config.AttackSAName or "Attack"
	local surfaceAppearance = config and config:FindFirstChild(normalSAName)

	if not (surfaceAppearance and surfaceAppearance:IsA("SurfaceAppearance")) then
		return false
	end

	self.saStash = config

	local function resolveSource(childName)
		local surfaceAppearance2 = config:FindFirstChild(childName)

		if surfaceAppearance2 and surfaceAppearance2:IsA("SurfaceAppearance") then
			return surfaceAppearance2
		end

		return nil
	end

	local blink = config:FindFirstChild("Blink")
	local surfaceAppearance2 = config:FindFirstChild(attackSAName)
	local blink2

	if blink and blink:IsA("SurfaceAppearance") then
		blink2 = blink or surfaceAppearance
	else
		blink2 = surfaceAppearance
	end

	local surfaceAppearancesByChildName = {
		Normal = surfaceAppearance,
		Blink = blink2,
		Attack = 0
	}

	if surfaceAppearance2 and surfaceAppearance2:IsA("SurfaceAppearance") then
		surfaceAppearance = surfaceAppearance2 or surfaceAppearance
	end

	surfaceAppearancesByChildName.Attack = surfaceAppearance
	local posterReactiveEmissive = config:FindFirstChild("PosterReactiveEmissive")

	if not (posterReactiveEmissive and posterReactiveEmissive:IsA("SurfaceAppearance")) then
		posterReactiveEmissive = nil
	end

	surfaceAppearancesByChildName.PosterReactiveEmissive = posterReactiveEmissive
	self.hasPosterSA = surfaceAppearancesByChildName.PosterReactiveEmissive ~= nil

	if self.config.PosterReactionTexture then
		local posterReactiveEmissive2 = surfaceAppearancesByChildName.PosterReactiveEmissive
		local emissiveStrength = "n/a"

		if posterReactiveEmissive2 then
			pcall(function()
				emissiveStrength = tostring(posterReactiveEmissive2.EmissiveStrength)
			end)
		end

		local names = {}

		for _, surfaceAppearance3 in config:GetChildren() do
			if surfaceAppearance3:IsA("SurfaceAppearance") then
				table.insert(names, surfaceAppearance3.Name)
			end
		end

		warn(string.format(
			"[SproutGlowDBG] %s setupSALayer: hasPosterSA=%s (looking for '%s') EmissiveStrength=%s | Config SAs present: {%s}",
			self.character.Name,
			tostring(self.hasPosterSA),
			"PosterReactiveEmissive",
			emissiveStrength,
			table.concat(names, ", ")
		))
	end

	if self.config.EmissiveBlink then
		local blinkEmissive = config:FindFirstChild("BlinkEmissive")

		if not (blinkEmissive and blinkEmissive:IsA("SurfaceAppearance")) then
			blinkEmissive = nil
		end

		if blinkEmissive then
			surfaceAppearancesByChildName.Blink = blinkEmissive
		end

		self.emissiveBlink = true
		print(string.format(
			"[SpecialAnimator] %s EmissiveBlink ON -> %s",
			self.character.Name,
			blinkEmissive and "authored BlinkEmissive SA" or "Blink/Normal fallback (keeps normal glow)"
		))
	end

	if self.config.ExtraSAStates then
		for _, childName in ipairs(self.config.ExtraSAStates) do
			local surfaceAppearance3 = config:FindFirstChild(childName)

			if not (surfaceAppearance3 and surfaceAppearance3:IsA("SurfaceAppearance")) then
				surfaceAppearance3 = nil
			end

			surfaceAppearancesByChildName[childName] = surfaceAppearance3
		end
	end

	local v3 = { "Normal", "Blink", "Attack" }

	if surfaceAppearancesByChildName.PosterReactiveEmissive then
		table.insert(v3, "PosterReactiveEmissive")
	end

	if self.config.ExtraSAStates then
		for _, extraSAState in ipairs(self.config.ExtraSAStates) do
			if surfaceAppearancesByChildName[extraSAState] then
				table.insert(v3, extraSAState)
			end
		end
	end

	self.saHeads = {}

	for i, head in ipairs(self.heads) do
		for _, surfaceAppearance3 in head:GetChildren() do
			if surfaceAppearance3:IsA("SurfaceAppearance") then
				surfaceAppearance3.Parent = config
			end
		end

		local v4 = {
			head = head,
			active = nil
		}

		for _, name in ipairs(v3) do
			local v6 = i == 1 and surfaceAppearancesByChildName[name] or surfaceAppearancesByChildName[name]:Clone()

			if i > 1 then
				v6.Name = name
				v6.Parent = config
			end

			v4[name] = v6
		end

		table.insert(self.saHeads, v4)
	end

	return true
end

function SpecialAnimator:applySA(p2)
	if not self.saHeads then
		return
	end

	for _, saHead in ipairs(self.saHeads) do
		local active

		if p2 then
			active = saHead[p2] or nil
		end

		if saHead.active == active then
			continue
		end

		if active then
			active.Parent = saHead.head
		end

		if saHead.active and saHead.active ~= active then
			saHead.active.Parent = self.saStash
		end

		saHead.active = active
	end
end

function SpecialAnimator:setHeadsTexture(textureID)
	for _, head in ipairs(self.heads) do
		head.TextureID = textureID
	end
end

function SpecialAnimator:setNormalFace()
	if not self.isBlinking and self.currentState == "normal" then
		self:setHeadsTexture(self.config.NormalTexture)
		self:applySA("Normal")
	end
end

function SpecialAnimator:setAttackFace()
	if self.currentState ~= "attack" then
		self:setHeadsTexture(self.config.AttackTexture)
		self:applySA("Attack")
		self.currentState = "attack"
	end
end

function SpecialAnimator:setStoryFace(p)
	local currentState = "story:" .. p

	if self.currentState == currentState then
		return
	end

	self:setHeadsTexture(self.config[p .. "Texture"])
	self:applySA(p)
	self.currentState = currentState
	self.currentGlistenState = nil
end

function SpecialAnimator:setPosterReactionFace()
	if self.config.PosterReactionTexture and self.currentState ~= "posterReaction" then
		self:setHeadsTexture(self.config.PosterReactionTexture)

		if self.hasPosterSA then
			self:applySA("PosterReactiveEmissive")
			local posterReactiveEmissive = self.saHeads and self.saHeads[1] and self.saHeads[1].PosterReactiveEmissive
			local emissiveStrength = "?"
			local name

			if posterReactiveEmissive then
				pcall(function()
					emissiveStrength = tostring(posterReactiveEmissive.EmissiveStrength)
				end)
				name = posterReactiveEmissive.Parent and posterReactiveEmissive.Parent.Name or "nil"
			else
				name = "?"
			end

			warn(string.format(
				"[SproutGlowDBG] %s posterReaction -> applied emissive SA. EmissiveStrength=%s parent=%s (glows only if strength>0)",
				self.character.Name,
				emissiveStrength,
				name
			))
		else
			self:applySA(nil)
			warn(string.format(
				"[SproutGlowDBG] %s posterReaction -> NO poster SA resolved; showing FLAT decal (never glows). Art/name issue.",
				self.character.Name
			))
		end

		self.currentState = "posterReaction"
	end
end

function SpecialAnimator:setHowlFace()
	if self.currentState ~= "howl" then
		self:setHeadsTexture(self.config.HowlTexture)
		self:applySA(nil)
		self.currentState = "howl"
		print(string.format(
			"[HOWL-DBG] %s howl face applied -> head.TextureID=%s",
			self.character.Name,
			(tostring(self.head and self.head.TextureID))
		))
	end
end

function SpecialAnimator:stopBlinking()
	if self.blinkCoroutine then
		coroutine.close(self.blinkCoroutine)
		self.blinkCoroutine = nil
	end

	self.isBlinking = false
end

function SpecialAnimator:startBlinking()
	if self.blinkCoroutine then
		self:stopBlinking()
	end

	local v2 = self.character and self.character.Name and self.character.Name:find("Blot") ~= nil
	self.blinkCoroutine = coroutine.create(function()
		while true do
			wait(math.random(3, 6))

			if v2 then
				print(string.format(
					"[BLOT-BLINK-DBG] tick | aggressive=%s currentState=%s isBlinking=%s",
					tostring(self:isInAggressiveState()),
					tostring(self.currentState),
					(tostring(self.isBlinking))
				))
			end

			if self:isInAggressiveState() then
				continue
			end

			self.isBlinking = true
			self:setHeadsTexture(self.config.BlinkTexture)

			if self.emissiveBlink then
				self:applySA("Blink")
			else
				self:applySA(nil)
			end

			if v2 then
				local head = self.head
				local active = self.saHeads and self.saHeads[1] and self.saHeads[1].active
				print(string.format(
					"[BLOT-BLINK-DBG] BLINK FRAME | head.TextureID=%s activeSA=%s (nil=SA removed, so flat BlinkTexture should be visible)",
					tostring(head and head.TextureID),
					(tostring(active and (active:GetFullName() or active)))
				))
			end

			wait(self.config.BlinkHoldTime or 0.15)
			self.isBlinking = false

			if self:isInAggressiveState() then
				continue
			end

			self:setHeadsTexture(self.blinkRestoreTexture or self.config.NormalTexture)
			self:applySA(self.blinkRestoreState or "Normal")

			if v2 then
				print("[BLOT-BLINK-DBG] blink END | restored base face SA", self.blinkRestoreState)
			end
		end
	end)
	coroutine.resume(self.blinkCoroutine)
end

function SpecialAnimator:isInAggressiveState()
	return self.character:GetAttribute("Chasing") or self.character:GetAttribute("Attacking") or self.character:GetAttribute("LostInterest") or self.character:GetAttribute("ForceAggressiveFace")
end

function SpecialAnimator:updateGlistenFace()
	if self.character:GetAttribute("GlistenActivated") then
		if self.character:GetAttribute("Chasing") or self.character:GetAttribute("Attacking") then
			self:setGlistenState("attack")
		else
			self:setGlistenState("angry")
		end
	elseif self.character:GetAttribute("GlistenRageTier") == "normal" then
		self:setGlistenState("normal")
	else
		self:setGlistenState("passive")
	end
end

function SpecialAnimator:setGlistenState(currentGlistenState)
	if self.currentGlistenState == currentGlistenState then
		return
	end

	local v2 = v[currentGlistenState]

	if not v2 then
		return
	end

	self.currentGlistenState = currentGlistenState
	self:setHeadsTexture(self.config[v2.texture])
	self:applySA(v2.sa)
	self.blinkRestoreState = v2.sa
	self.blinkRestoreTexture = self.config[v2.texture]

	if v2.blink then
		self:startBlinking()
	else
		self:stopBlinking()
	end
end

function SpecialAnimator:updateFace()
	local _StoryFace = self.character:GetAttribute("_StoryFace")

	if _StoryFace ~= nil then
		local v2 = tostring(_StoryFace)

		if self.config[v2 .. "Texture"] then
			self:stopBlinking()
			self:setStoryFace(v2)
			return
		else
			warn(string.format(
				"[SpecialAnimator] %s: _StoryFace %q has no %sTexture in config; ignoring",
				self.character.Name,
				v2,
				v2
			))
		end
	end

	if self.config.GlistenFaceStates then
		self:updateGlistenFace()
	elseif self.config.HowlTexture and self.character:GetAttribute("_Howling") then
		self:stopBlinking()
		self:setHowlFace()
	elseif self:isInAggressiveState() then
		self:stopBlinking()
		self:setAttackFace()
		self.attackFaceDebounce = true
	elseif self.config.PosterReactionTexture and self.character:GetAttribute("_PosterReacting") then
		self:stopBlinking()
		self:setPosterReactionFace()
	elseif self.attackFaceDebounce then
		self.attackFaceDebounce = false
		task.delay(0.5, function()
			if not self:isInAggressiveState() and self.character:GetAttribute("_StoryFace") == nil then
				self.currentState = "normal"
				self:setNormalFace()
				self:startBlinking()
			end
		end)
	else
		self.currentState = "normal"
		self:setNormalFace()
		self:startBlinking()
	end
end

function SpecialAnimator:setupConnections()
	self.character:GetAttributeChangedSignal("Chasing"):Connect(function()
		self:updateFace()
	end)
	self.character:GetAttributeChangedSignal("Attacking"):Connect(function()
		self:updateFace()
	end)
	self.character:GetAttributeChangedSignal("LostInterest"):Connect(function()
		self:updateFace()
	end)
	self.character:GetAttributeChangedSignal("Wandering"):Connect(function()
		self:updateFace()
	end)
	self.character:GetAttributeChangedSignal("ForceAggressiveFace"):Connect(function()
		self:updateFace()
	end)
	self.character:GetAttributeChangedSignal("_PosterReacting"):Connect(function()
		self:updateFace()
	end)
	self.character:GetAttributeChangedSignal("_Howling"):Connect(function()
		self:updateFace()
	end)
	self.character:GetAttributeChangedSignal("_StoryFace"):Connect(function()
		self:updateFace()
	end)

	if self.config.GlistenFaceStates then
		self.character:GetAttributeChangedSignal("GlistenActivated"):Connect(function()
			self:updateFace()
		end)
		self.character:GetAttributeChangedSignal("GlistenRageTier"):Connect(function()
			self:updateFace()
		end)
	end

	self.character.Destroying:Connect(function()
		self:destroy()
	end)
end

function SpecialAnimator:destroy()
	self:stopBlinking()
end

return SpecialAnimator