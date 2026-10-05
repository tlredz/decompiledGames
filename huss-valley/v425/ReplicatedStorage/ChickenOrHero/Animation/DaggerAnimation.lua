local DaggerConfig = require(script.Parent.Parent.Weapons.DaggerConfig)
local AnimationConfig = require(script.Parent.AnimationConfig)
local ContactCatchConfig = require(script.Parent.Parent.Game.ContactCatchConfig)
local MeleeAttackTimeline = require(script.Parent.MeleeAttackTimeline)
local Players = game:GetService("Players")
local DaggerAnimation = {}
DaggerAnimation.__index = DaggerAnimation
local v = {
	Equip = "DaggerEquip",
	Hold = "DaggerHold",
	Windup = "DaggerWindup",
	Stab = "DaggerStab"
}

function DaggerAnimation.new(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if humanoid and not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	return (setmetatable({
		character = instance,
		animator = animator,
		tracks = {},
		assets = {},
		attempts = {},
		retryAt = {}
	}, DaggerAnimation))
end

function DaggerAnimation:ensure(p)
	for k, v2 in v do
		local track = self.tracks[k]

		if track and track.Length > 0 or p < (self.retryAt[k] or 0) then
			continue
		end

		local v3 = (self.attempts[k] or 0) + 1
		self.attempts[k] = v3
		self.retryAt[k] = p + math.min(60, v3 * 15)

		if track then
			track:Destroy()
		end

		if self.assets[k] then
			self.assets[k]:Destroy()
		end

		local animation = Instance.new("Animation")
		animation.Name = "CoH_" .. v2
		animation.AnimationId = AnimationConfig.PublishedIds[v2]
		self.assets[k] = animation
		local success, result = pcall(function()
			return self.animator:LoadAnimation(animation)
		end)

		if success then
			result.Name = animation.Name
			result.Looped = k == "Hold"
			result.Priority = k == "Hold" and Enum.AnimationPriority.Action or Enum.AnimationPriority.Action2
			self.tracks[k] = result
		else
			self.tracks[k] = nil
			warn("Dagger animation unavailable", v2, result)
		end
	end

	local v2 = true

	for k in v do
		local track = self.tracks[k]

		if not v2 then
			continue
		end

		if track == nil then
			v2 = false
		else
			v2 = track.Length > 0
		end
	end

	if self.character:GetAttribute("DaggerAnimationsReady") ~= v2 then
		self.character:SetAttribute("DaggerAnimationsReady", v2)
	end

	return v2
end

function DaggerAnimation:stop(p2, p3)
	local track = self.tracks[p2]

	if track and track.IsPlaying then
		track:Stop(p3 or DaggerConfig.FadeOut)
	end
end

function DaggerAnimation:play(p2, value)
	local track = self.tracks[p2]

	if not track or track.Length <= 0 then
		return false
	end

	track:Play(DaggerConfig.FadeIn, 1, value or 1)
	return true
end

function DaggerAnimation:reset()
	for k in v do
		self:stop(k)
	end

	self.preparing = false
	self.attackAt = nil
	self.stabUntil = nil
end

function DaggerAnimation:draw(drawingAt)
	self:reset()
	self.drawingAt = drawingAt
	self.drawPlayed = false
end

function DaggerAnimation:update(p, p2, p3, p4)
	self:ensure(p)
	local character = self.character

	if p2 then
		local hold = self.tracks.Hold

		if hold and hold.Length > 0 and not hold.IsPlaying then
			self:play("Hold")
		end

		if p3 then
			if not self.drawPlayed then
				self.drawPlayed = self:play("Equip")
			end
		else
			if self.drawingAt then
				local equip = self.tracks.Equip

				if equip then
					equip:Stop(DaggerConfig.FadeOut)
				end

				self.drawingAt = nil
			end

			if character:GetAttribute("TackleActive") then
				self:stop("Equip")
				self:stop("Windup")
				self:stop("Stab")
				self.preparing = false
				self.stabUntil = nil
				self.attackAt = character:GetAttribute("ReachStartedAt")
			else
				if p4 then
					return
				end

				if Players:GetPlayerFromCharacter(character) then
					self:stop("Windup", 0.035)
					self:stop("Stab", 0.035)
					self.preparing = false
					self.stabUntil = nil
				else
					local reachStartedAt = character:GetAttribute("ReachStartedAt")

					if type(reachStartedAt) == "number" then
						local sample, v2, v3 = MeleeAttackTimeline.sample(
							p - reachStartedAt,
							ContactCatchConfig,
							DaggerConfig
						)

						if sample == "Active" or sample == "Recovery" then
							local stab = self.tracks.Stab

							if reachStartedAt == self.attackAt then
								if self.strikePhase ~= sample and stab then
									stab:AdjustSpeed(v3)
								end
							elseif self:play("Stab", v3) then
								stab.TimePosition = math.min(v2, (math.max(0, stab.Length - 0.001)))
								self.attackAt = reachStartedAt
								self:stop("Windup", 0.035)
								self.preparing = false
							end

							self.strikePhase = sample
							return
						elseif sample == "Complete" then
							self.attackAt = reachStartedAt
						end
					end

					if self.stabUntil and p < self.stabUntil then
						return
					end

					self.stabUntil = nil
					local reachPhase = character:GetAttribute("ReachPhase")
					local v2

					if reachPhase == "Tracking" or reachPhase == "Windup" then
						v2 = not character:GetAttribute("MovementLocked")
					else
						v2 = false
					end

					if v2 then
						local windup = self.tracks.Windup

						if not self.preparing or windup and not windup.IsPlaying then
							self.preparing = self:play("Windup", DaggerConfig.WindupRate)
						end

						if windup and windup.IsPlaying and windup.TimePosition >= windup.Length - DaggerConfig.WindupHoldTail then
							windup:AdjustSpeed(0)
						end
					else
						self:stop("Windup")
						self.preparing = false
					end
				end
			end
		end
	else
		self:reset()
		self.drawingAt = nil
	end
end

function DaggerAnimation.destroy(p)
	for _, track in p.tracks do
		track:Stop(0.1)
		track:Destroy()
	end

	for _, asset in p.assets do
		asset:Destroy()
	end

	table.clear(p.tracks)
	table.clear(p.assets)
end

return DaggerAnimation