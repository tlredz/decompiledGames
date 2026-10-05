local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Stretchify = require(ReplicatedStorage.Modules.Stretchify)
require(ReplicatedStorage.Modules.Tool)
local localPlayer = Players.LocalPlayer
local stretchifySounds = ReplicatedStorage.Assets.Tools.StretchifySounds
local _ = {
	MaxSelectDistance = 36
}
local Stretchify_2 = {}

function Stretchify_2:UpdateHoverHighlight()
	if not self:IsEquipped() then
		Stretchify:SetHoveredLimb(nil, nil)
		return
	end

	local _, v, v2 = Stretchify:GetMouseHit("Player")

	if v and v2 and v2:IsDescendantOf(v) then
		Stretchify:SetHoveredLimb(v, Stretchify:GetLimbFromPart(v, v2))
	else
		Stretchify:SetHoveredLimb(nil, nil)
	end
end

function Stretchify_2:SyncPlacingFromTool()
	local stretchPlacing = self.Tool:GetAttribute("StretchPlacing")
	local v = nil

	if stretchPlacing then
		local v2 = nil
		local limb = nil

		if typeof(stretchPlacing) == "string" then
			local v4 = string.find(stretchPlacing, ":")

			if v4 then
				v2 = string.sub(stretchPlacing, 1, v4 - 1)
				limb = string.sub(stretchPlacing, v4 + 1)
			end
		end

		local player = v2 and Players:FindFirstChild(v2)
		v = v2 and limb and player and player:IsA("Player") and player.Character and {
			Victim = player.Character,
			Limb = limb
		} or v
	end

	if v and not self:IsEquipped() then
		v = nil
	end

	stretchifySounds.Stretch:Stop()

	if v then
		local formatted = `{v.Victim.Name}:{v.Limb}`
		self.PlacingStates[formatted] = v
		self.ActivePlacing = formatted

		for k, placingState in self.PlacingStates do
			if k == formatted then
				continue
			end

			Stretchify:SetPreview(placingState.Victim, placingState.Limb, nil)
			self.PlacingStates[k] = nil
		end

		if not self.DragConnection then
			self.DragConnection = RunService.RenderStepped:Connect(function()
				if not self:IsEquipped() then
					return
				end

				local activePlacing = self.ActivePlacing
				local v2 = activePlacing and self.PlacingStates[activePlacing]

				if not v2 then
					return
				end

				local mouseHit = Stretchify:GetMouseHit("Surface", {
					ExcludeInstances = { v2.Victim }
				})

				if not mouseHit then
					return
				end

				local clampStretchPosition = Stretchify:ClampStretchPosition(v2.Victim, v2.Limb, mouseHit)

				if clampStretchPosition ~= self.LastPosition then
					self.LastPosition = clampStretchPosition
					self.LastPositionUpdate = os.clock()

					if not stretchifySounds.Stretch.Playing then
						stretchifySounds.Stretch:Play()
					end
				elseif stretchifySounds.Stretch.Playing and os.clock() - self.LastPositionUpdate > 0.025 then
					stretchifySounds.Stretch:Stop()
				end

				Stretchify:SetPreview(v2.Victim, v2.Limb, clampStretchPosition)
				self.Tool.StretchifyPosition:FireServer(v2.Victim, v2.Limb, clampStretchPosition)
			end)
		end
	else
		self.ActivePlacing = nil

		if self.DragConnection then
			self.DragConnection:Disconnect()
			self.DragConnection = nil
		end

		stretchifySounds.Stretch:Stop()

		for _, placingState in self.PlacingStates do
			Stretchify:SetPreview(placingState.Victim, placingState.Limb, nil)
		end
	end
end

function Stretchify_2:IsEquipped()
	return self and self.Tool and self.Tool.Parent == self.Character
end

function Stretchify_2:SelectLimb(p)
	if not self:IsEquipped() then
		return false
	end

	local mouseHit, v, v2 = Stretchify:GetMouseHit("Player")

	if not (v and mouseHit and v2 and v2:IsDescendantOf(v)) then
		return false
	end

	local stretchify = v:GetAttribute("Stretchify")

	if stretchify and stretchify ~= localPlayer.Name or Stretchify:HasActiveStretch(v) and stretchify ~= localPlayer.Name then
		stretchifySounds.FailToCreateRope:Play()
		return true
	end

	if localPlayer:DistanceFromCharacter(mouseHit) > 36 then
		return false
	end

	local limbFromPart = Stretchify:GetLimbFromPart(v, v2)

	if not limbFromPart then
		return false
	end

	if p and p.Victim == v and p.Limb == limbFromPart then
		return true
	end

	if self.Tool.StretchifyFunction:InvokeServer(v, limbFromPart) then
		stretchifySounds.CreateRope:Play()
	else
		stretchifySounds.FailToCreateRope:Play()
	end

	return true
end

function Stretchify_2:PlaceActiveLimb()
	if not self:IsEquipped() then
		return false
	end

	local activePlacing = self.ActivePlacing
	local v = activePlacing and self.PlacingStates[activePlacing]

	if not v then
		return false
	end

	local mouseHit, _, v2 = Stretchify:GetMouseHit("Surface", {
		ExcludeInstances = { v.Victim }
	})

	if not (mouseHit and v2) then
		return false
	end

	local clampStretchPosition = Stretchify:ClampStretchPosition(v.Victim, v.Limb, mouseHit)
	Stretchify:SetPreview(v.Victim, v.Limb, clampStretchPosition)
	self.Tool.StretchifyPosition:FireServer(v.Victim, v.Limb, clampStretchPosition, true)
	Stretchify:SetPreview(v.Victim, v.Limb, nil)
	stretchifySounds.CreateRope:Play()
	return true
end

function Stretchify_2:Initialize()
	self.PlacingStates = {}
	self.LastPositionUpdate = 0
	self.LastPosition = createVector(0, 0, 0)
	self.Tool:GetAttributeChangedSignal("StretchPlacing"):Connect(function()
		self:SyncPlacingFromTool()
	end)
	self:SyncPlacingFromTool()
end

function Stretchify_2:Activated()
	local activePlacing = self.ActivePlacing
	local v = activePlacing and self.PlacingStates[activePlacing]

	if not v then
		self:SelectLimb()
		return
	end

	if self:SelectLimb(v) then
		return
	end

	if self:PlaceActiveLimb() then
	end
end

function Stretchify_2:Equipped()
	if self.HoverConnection then
		self.HoverConnection:Disconnect()
	end

	self.HoverConnection = RunService.RenderStepped:Connect(function()
		self:UpdateHoverHighlight()
	end)
end

function Stretchify_2.Unequipped(state)
	state.ActivePlacing = nil
	state.PlacingStates = {}

	if state.DragConnection then
		state.DragConnection:Disconnect()
		state.DragConnection = nil
	end

	if state.HoverConnection then
		state.HoverConnection:Disconnect()
		state.HoverConnection = nil
	end

	Stretchify:SetHoveredLimb(nil, nil)
	stretchifySounds.Stretch:Stop()
	Stretchify:ClearPreviews()
end

return Stretchify_2