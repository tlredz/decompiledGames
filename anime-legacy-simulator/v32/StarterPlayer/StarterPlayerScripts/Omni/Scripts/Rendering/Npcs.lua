local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local interface = module.Assets:WaitForChild("Interface")
local npc = interface:WaitForChild("HUD"):WaitForChild("Npc")
local npcMarker = interface:WaitForChild("Templates"):WaitForChild("NpcMarker")
local npcZone = module.Assets:WaitForChild("Effects"):WaitForChild("NpcZone")
local v = {}
local Npcs = {}

local function IsSettled(cframe: CFrame, cframe2: CFrame)
	local DISTANCE_EPSILON = 0.001

	if (cframe.Position - cframe2.Position).Magnitude > DISTANCE_EPSILON or (cframe.LookVector - cframe2.LookVector).Magnitude > DISTANCE_EPSILON then
		return false
	end

	return (cframe.UpVector - cframe2.UpVector).Magnitude <= DISTANCE_EPSILON
end

local function GetFacingCFrame(cframe: CFrame, vector: Vector3)
	local vector2 = Vector3.new(vector.X, 0, vector.Z)

	if vector2.Magnitude <= 0.001 then
		return cframe
	end

	local position = cframe.Position
	return CFrame.new(position, position + vector2)
end

local function ApplyTransparency(effect, transparency: number)
	local numberSequence = NumberSequence.new(transparency)
	effect.Outline.Transparency = transparency
	effect.Center.Transparency = transparency * 0.1 + 0.9

	for _, child in effect.Beams:GetChildren() do
		child.Transparency = numberSequence
		child.Enabled = transparency < 1
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopFade(p)
	if not p.Scope then
		return
	end

	p.Scope:doCleanup()
	p.Scope = nil
	p.Transparency = nil
	p.TransparencySpring = nil
end

local function StartFade(state, p: number)
	if not state.Scope then
		local scope = fusion.scoped(fusion)
		local transparency = scope:Value(1)
		local spring = scope:Spring(transparency, 10, 1)
		scope:Observer(spring):onChange(function()
			ApplyTransparency(state.Effect, scope.peek(spring))
		end)
		state.Scope = scope
		state.Transparency = transparency
		state.TransparencySpring = spring
	end

	state.Transparency:set(p)
end

function Npcs.Create(model)
	if not (model and model:IsA("Model")) or v[model] then
		return
	end

	local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local head = model:FindFirstChild("Head")

	if not head then
		return
	end

	local leftLowerLeg = model:FindFirstChild("LeftLowerLeg") or model:FindFirstChild("RightLowerLeg")
	local leftUpperLeg = model:FindFirstChild("LeftUpperLeg") or model:FindFirstChild("RightUpperLeg")
	local v2 = (leftLowerLeg and leftLowerLeg.Size.Y or 0) + (leftUpperLeg and leftUpperLeg.Size.Y or 0)
	local name = model.Name
	local npc2 = module.Npcs[name]
	local scale = model:GetScale()
	local color = model:GetAttribute("Color") or Color3.fromRGB(255, 255, 255)
	local track = nil
	local proximityPrompt = nil
	local characterAnimation = module.Utils.Characters.GetCharacterAnimation(name, "Idle")

	if characterAnimation then
		local humanoid = model:FindFirstChildOfClass("Humanoid")

		if humanoid then
			local v3 = humanoid:FindFirstChildOfClass("Animator")

			if not v3 then
				v3 = Instance.new("Animator")
				v3.Parent = humanoid
			end

			track = v3:LoadAnimation(characterAnimation)
			track.Priority = Enum.AnimationPriority.Action4
			track.Looped = true
			track:Play()
		end
	end

	local clone = npcZone:Clone()
	clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -v2, 0))
	clone.Parent = model
	local clone2 = npc:Clone()
	clone2.Name = name
	clone2.Title.Text = name
	clone2.StudsOffset = Vector3.new(0, npc.StudsOffset.Y * scale, 0)

	if npc2 then
		if npc2.AreaColor then
			color = npc2.AreaColor
		end

		if npc2.Markers then
			for k, marker in npc2.Markers do
				local clone3 = npcMarker:Clone()
				clone3.Name = k
				clone3.Title.Text = k
				clone3.UIStroke.Color = marker
				clone3.Title.UIStroke.Color = marker
				clone3.Title.UIGradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, module.Utils.Colors:Lighten(marker, 0.5)),
					ColorSequenceKeypoint.new(0.5, marker),
					ColorSequenceKeypoint.new(1, module.Utils.Colors:Darken(marker, 0.5))
				})
				clone3.LayoutOrder += 0
				clone3.Parent = clone2
			end
		end

		if npc2.Dialog then
			proximityPrompt = Instance.new("ProximityPrompt")
			proximityPrompt.Name = `{name} Dialog`
			proximityPrompt.ActionText = "Talk to"
			proximityPrompt.ObjectText = name
			proximityPrompt.RequiresLineOfSight = false
			proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
			proximityPrompt.Parent = humanoidRootPart
		end
	end

	clone2.Parent = head

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Color = color
		elseif descendant:IsA("Beam") then
			descendant.Color = ColorSequence.new(color)
		end
	end

	for _, part in model:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CollisionGroup = "Fighters"
	end

	local v3 = {
		Instance = model,
		HRP = humanoidRootPart,
		IdleTrack = track,
		Effect = clone,
		HUD = clone2,
		Prompt = proximityPrompt,
		IsOpen = false,
		Settled = false,
		OriginalPosition = humanoidRootPart.CFrame
	}
	local numberSequence = NumberSequence.new(1)
	clone.Outline.Transparency = 1
	clone.Center.Transparency = 1

	for _, child in clone.Beams:GetChildren() do
		child.Transparency = numberSequence
		child.Enabled = false
	end

	v3.Connections = {}
	v3.Connections.Destroyed = model.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			for _, connection in v3.Connections do
				connection:Disconnect()
			end

			table.clear(v3.Connections)
			StopFade(v3) -- equivalent call inferred; original call site unknown

			if v3.IdleTrack then
				v3.IdleTrack:Stop(0)
				v3.IdleTrack:Destroy()
			end

			v3.Effect:Destroy()
			v3.HUD:Destroy()

			if v3.Prompt then
				v3.Prompt:Destroy()
			end

			v[model] = nil
		end
	end)
	v[model] = v3
	return v3
end

module.Utils.Instance:ObserveTaggedObject("Npc", function(model)
	if model and model:IsA("Model") then
		Npcs.Create(model)
	end
end)
module.Services.RunService.Heartbeat:Connect(function()
	local DISTANCE_EPSILON = 0.001
	local HRP = module:GetHRP()

	if not HRP then
		return
	end

	local position = HRP.Position

	for _, v2 in v do
		local HRP2 = v2.HRP
		local cFrame = HRP2.CFrame
		local v3 = position - cFrame.Position
		local isOpen = v3.Magnitude <= 10
		local cframe

		if isOpen then
			local vector = Vector3.new(v3.X, 0, v3.Z)

			if vector.Magnitude <= DISTANCE_EPSILON then
				cframe = cFrame
			else
				local position2 = cFrame.Position
				cframe = CFrame.new(position2, position2 + vector)
			end

			if not cframe then
				cframe = v2.OriginalPosition
			end
		else
			cframe = v2.OriginalPosition
		end

		if HRP2.Anchored then
			local v5

			if (cFrame.Position - cframe.Position).Magnitude > DISTANCE_EPSILON or (cFrame.LookVector - cframe.LookVector).Magnitude > DISTANCE_EPSILON then
				v5 = false
			else
				v5 = (cFrame.UpVector - cframe.UpVector).Magnitude <= DISTANCE_EPSILON
			end

			if v5 then
				if not v2.Settled then
					HRP2.CFrame = cframe
					v2.Settled = true
				end
			else
				HRP2.CFrame = cFrame:Lerp(cframe, 0.1)
				v2.Settled = false
			end
		else
			HRP2.CFrame = cFrame:Lerp(cframe, 0.1)
			v2.Settled = false
		end

		if isOpen ~= v2.IsOpen then
			v2.IsOpen = isOpen
			StartFade(v2, isOpen and 0 or 1)
		end

		if isOpen or not v2.Scope or not (v2.Scope.peek(v2.TransparencySpring) >= 1) then
			continue
		end

		StopFade(v2) -- equivalent call inferred; original call site unknown
	end
end)
return Npcs