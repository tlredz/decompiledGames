local createVector = vector.create
local RunService = game:GetService("RunService")
local Config = require(script.Parent.Config)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local LocationUtil = require(script.Parent.LocationUtil)
local v = {}
local Scene = {}
Scene.__index = Scene
local v2 = {
	"MansionKey",
	"MansionDoor",
	"TesterDoor",
	"DeveloperDoor",
	"TesterSign"
}

function v.getBasePart(instance)
	if not instance then
		return nil
	end

	if instance:IsA("BasePart") then
		return instance
	end

	if instance:IsA("Model") and instance.PrimaryPart then
		return instance.PrimaryPart
	end

	return instance:FindFirstChildWhichIsA("BasePart", true)
end

function v:preparePart()
	self.Anchored = true
	self.CanCollide = false
	self.CanTouch = false
	self.CanQuery = false
end

function v.prepareVisual(part)
	if part:IsA("BasePart") then
		v.preparePart(part)
	end

	for _, descendant in part:GetDescendants() do
		if descendant:IsA("BasePart") then
			v.preparePart(descendant)
		elseif descendant:IsA("LuaSourceContainer") then
			descendant:Destroy()
		end
	end
end

function v.cloneVisual(p, cFrame: CFrame, parent)
	if p.UseMarkerVisual or not p.TemplateName then
		return nil
	end

	local assets = script.Parent:FindFirstChild("Assets")
	local child

	if assets then
		child = assets:FindFirstChild(p.TemplateName)
	end

	if not child then
		return nil
	end

	local clone = child:Clone()

	if clone:IsA("Model") or clone:IsA("BasePart") then
		v.prepareVisual(clone)

		if clone:IsA("Model") then
			clone:PivotTo(cFrame)
		elseif clone:IsA("BasePart") then
			clone.CFrame = cFrame
		end

		clone.Parent = parent
		return clone
	else
		warn((`[{script.Parent.Parent.Name}] asset {p.TemplateName} must be a Model or BasePart`))
		clone:Destroy()
		return nil
	end
end

function v.placeholderSize(p: string)
	if p == "MansionKey" then
		return createVector(1.5, 0.5, 0.75)
	end

	return createVector(6, 9, 1)
end

function v.createPlaceholder(p: string, cFrame: CFrame, parent)
	local part = Instance.new("Part")
	part.Name = `{p}Placeholder`
	part.Size = v.placeholderSize(p)
	part.CFrame = cFrame
	part.Color = Config.PLACEHOLDER_COLORS[p]
	part.Material = Enum.Material.Neon
	part.Transparency = 0.35
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Parent = parent
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "PlaceholderLabel"
	billboardGui.Size = UDim2.fromOffset(220, 40)
	billboardGui.StudsOffsetWorldSpace = Vector3.new(0, part.Size.Y / 2 + 1, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Parent = part
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = `EARLY ACCESS: {p}`
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextStrokeTransparency = 0
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = billboardGui
	return part
end

function v.createAnchor(p: string, cFrame: CFrame, parent)
	local part = Instance.new("Part")
	part.Name = `{p}PromptAnchor`
	part.Size = createVector(1, 1, 1)
	part.CFrame = cFrame
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Parent = parent
	return part
end

function v.resolvePlacement(p)
	return LocationUtil.resolve(p.MarkerName, true)
end

function v.createRecord(p, p2: string, data, callback)
	local placement, v3 = v.resolvePlacement(data)

	if not v3 then
		warn((`[{script.Parent.Parent.Name}] missing interaction marker {data.MarkerName}`))
		return nil
	end

	local visual = v.cloneVisual(data, v3, p)

	if not visual and RunService:IsStudio() and not data.UseMarkerVisual then
		visual = v.createPlaceholder(p2, v3, p)
	end

	local parent = v.getBasePart(visual) or v.getBasePart(placement)
	local ownedAnchor

	if not parent then
		parent = v.createAnchor(p2, v3, p)
		ownedAnchor = parent
	end

	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt:AddTag("ProximityPrompt")
	proximityPrompt.Name = `EarlyAccess{p2}Prompt`
	proximityPrompt.ActionText = data.ActionText
	proximityPrompt.ObjectText = data.ObjectText
	proximityPrompt.HoldDuration = data.HoldDuration
	proximityPrompt.MaxActivationDistance = Config.PROMPT_DISTANCE
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Enabled = false
	proximityPrompt.Parent = parent
	return {
		prompt = proximityPrompt,
		connection = proximityPrompt.Triggered:Connect(function()
			callback(p2)
		end),
		ownedAnchor = ownedAnchor,
		visual = visual,
		auraSound = nil
	}
end

function v:setAura(flag: boolean)
	if flag then
		local basePart = v.getBasePart(self.visual)

		if self.auraSound or not basePart then
			return
		end

		local auraSound = Sound:Play(Config.KEY_AURA_SOUND, basePart)
		auraSound.Looped = true
		self.auraSound = auraSound
	else
		local auraSound = self.auraSound

		if auraSound then
			self.auraSound = nil
			Sound:FadeOut(auraSound, Config.KEY_AURA_FADE)
		end
	end
end

function v.setVisualParent(p, parent, flag: boolean)
	if p.visual then
		local visual = p.visual

		if not flag then
			parent = nil
		end

		visual.Parent = parent
	end
end

function Scene.new(callback)
	local self = setmetatable({
		_root = Instance.new("Folder"),
		_records = {},
		_stage = Config.STAGES.UNSTARTED,
		_questGiverVisible = true
	}, Scene)
	self._root.Name = "EarlyAccessLocalScene"
	self._root.Parent = workspace

	for _, v3 in v2 do
		local INTERACTIONS = Config.INTERACTIONS
		local record = v.createRecord(self._root, v3, INTERACTIONS[v3], callback)

		if record then
			self._records[v3] = record
		end
	end

	return self
end

function v:refresh()
	local STAGES = Config.STAGES
	local _stage = self._stage

	for k, _record in self._records do
		local enabled

		if k == "MansionKey" and _stage == STAGES.FIND_KEY or k == "MansionDoor" and _stage < STAGES.RETURN_TO_DEVELOPER or k == "TesterDoor" or k == "DeveloperDoor" then
			enabled = true
		elseif k == "TesterSign" then
			enabled = not self._questGiverVisible
		else
			enabled = false
		end

		_record.prompt.Enabled = enabled
		local v4 = k == "MansionDoor" or k == "MansionKey" and _stage == STAGES.FIND_KEY or k == "TesterDoor" or k == "DeveloperDoor" or k == "TesterSign"
		v.setVisualParent(_record, self._root, v4)

		if k == "MansionKey" then
			v.setAura(_record, v4)
		end
	end
end

function Scene:setStage(stage: number)
	self._stage = stage
	v.refresh(self)
end

function Scene:setQuestGiverVisible(questGiverVisible: boolean)
	self._questGiverVisible = questGiverVisible
	v.refresh(self)
end

function Scene:destroy()
	for _, _record in self._records do
		v.setAura(_record, false)
		_record.connection:Disconnect()
		_record.prompt:Destroy()

		if _record.visual then
			_record.visual:Destroy()
		end

		if _record.ownedAnchor then
			_record.ownedAnchor:Destroy()
		end
	end

	table.clear(self._records)
	self._root:Destroy()
end

return Scene