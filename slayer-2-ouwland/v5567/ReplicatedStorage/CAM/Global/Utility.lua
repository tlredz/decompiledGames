local createVector = vector.create
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))
local isStudio = RunService:IsStudio()
local isRunning = RunService:IsRunning()
local hitboxVisuals = workspace.Debree:FindFirstChild("HitboxVisuals")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local isServer = RunService:IsServer()
local humanoids = RaycastHelper.Humanoids
local overlapParams = OverlapParams.new()

function dotreefilter()
	local v = overlapParams
	local trees

	if workspace:FindFirstChild("Map") ~= nil then
		trees = workspace.Map:FindFirstChild("Trees") or nil
	end

	local trees2

	if not (workspace.Map:FindFirstChild("DetachedMaps") == nil or workspace.Map.DetachedMaps:FindFirstChild("ParkourTraining") == nil) then
		trees2 = workspace.Map.DetachedMaps.ParkourTraining:FindFirstChild("Trees") or nil
	end

	local v3

	if workspace.Map:FindFirstChild("Minigame Map") ~= nil then
		v3 = workspace.Map["Minigame Map"]:FindFirstChild("Trees") or nil
	end

	v.FilterDescendantsInstances = { trees, trees2, v3 }
end

if gameSettings.IsMinigame then
	task.spawn(function()
		workspace.Map:WaitForChild("Minigame Map")
		dotreefilter()
	end)
else
	dotreefilter()
end

overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.MaxParts = 20
local clock = os.clock
local clamp = math.clamp
local Utility = {
	Cancel_Values = {
		KnockedOut = true,
		Cancel = true,
		RagDoll = true,
		Stun = true,
		CombatStun = true,
		Strict_Stun = true
	}
}
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

function Utility.clean_part_before_air_combo(instance)
	if instance == nil then
		return
	end

	if instance:FindFirstChild("Velocity", true) ~= nil then
		for _, child in pairs(instance:GetChildren()) do
			if child:FindFirstChild("Velocity") then
				child:Destroy()
			end
		end
	end
end

function Utility.StreamingEnabledTeleport(cframe, value: number?)
	local localPlayer = Players.LocalPlayer
	local character = localPlayer.Character

	if character == nil or cframe == nil then
		return false
	end

	local v = value or 60
	local pivot = character:GetPivot()

	if typeof(cframe) == "Vector3" then
		cframe = CFrame.new(cframe) or cframe
	end

	local position = cframe.Position
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local anchored

	if humanoidRootPart == nil then
		anchored = false
	else
		anchored = humanoidRootPart.Anchored or false
	end

	character:PivotTo(cframe)

	if humanoidRootPart and humanoidRootPart.Parent then
		humanoidRootPart.Anchored = true
	end

	local v2 = Utility.Tick()
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character }
	raycastParams.RespectCanCollide = true
	pcall(function()
		localPlayer:RequestStreamAroundAsync(position, v)
	end)

	while true do
		local raycastResult = workspace:Raycast(
			position + createVector(0, 10, 0),
			createVector(0, -60, 0),
			raycastParams
		)

		if raycastResult and raycastResult.Instance then
			break
		end

		task.wait(0.1)

		if not (v < Utility.Tick() - v2) then
			continue
		end

		character:PivotTo(pivot)

		if humanoidRootPart and humanoidRootPart.Parent then
			humanoidRootPart.Anchored = anchored
		end

		return false
	end

	if humanoidRootPart and humanoidRootPart.Parent then
		humanoidRootPart.Anchored = anchored
	end

	return true
end

function Utility.ForceUnequip()
	local localPlayer = Players.LocalPlayer

	if localPlayer == nil then
		return
	end

	local items_Config = localPlayer:FindFirstChild("Items_Config")

	if items_Config == nil then
		return
	end

	local equipped = items_Config:FindFirstChild("Equipped")

	if equipped == nil then
		return
	end

	if equipped.Value ~= 0 then
		equipped.Value = 0
	end
end

function Utility.ForceEquip(p: number?)
	if p == nil or p < 1 or p > 5 then
		return
	end

	local localPlayer = Players.LocalPlayer

	if localPlayer == nil then
		return
	end

	local items_Config = localPlayer:FindFirstChild("Items_Config")

	if items_Config == nil then
		return
	end

	local equipped = items_Config:FindFirstChild("Equipped")

	if equipped == nil then
		return
	end

	if equipped.Value ~= p then
		equipped.Value = p
	end
end

function Utility.formatTime(p: number)
	local v = math.floor(p)

	if v <= 0 then
		return "0s"
	end

	if v < 60 then
		return (`{v}s`)
	end

	local v2 = v % 60

	if v < 3600 then
		return (`{math.floor(v / 60)}:{string.format("%02d", v2)}`)
	end

	local v3 = math.floor(v / 3600)
	local v4 = math.floor(v % 3600 / 60)
	return (`{v3}:{string.format("%02d", v4)}:{string.format("%02d", v2)}`)
end

local v = {
	{ "h", 3600 },
	{ "m", 60 },
	{ "s", 1 }
}

function Utility.formatTimeUnits(p: number, value: string?, value2: number?, flag: boolean?)
	local v2 = math.max(math.floor(p), 0)
	local v3 = math.clamp(value2 or 3, 1, 3)
	local v4 = not flag and 1 or 4 - v3
	local v5 = table.move(v, v4, v4 + v3 - 1, 1, {})
	local v6 = {}

	for k, v7 in v5 do
		local v8 = math.floor(v2 / v7[2])
		v2 %= v7[2]

		if v8 > 0 or #v6 == 0 and k == #v5 then
			table.insert(v6, (`{v8}{v7[1]}`))
		end
	end

	return table.concat(v6, value or "")
end

local v2 = {
	{ "d", 86400 },
	{ "h", 3600 },
	{ "m", 60 },
	{ "s", 1 }
}

function Utility.formatTimeVerbose(p: number)
	local v3 = math.max(math.floor(p), 0)
	local v4 = {}

	for k, v5 in v2 do
		local v6 = math.floor(v3 / v5[2])
		v3 %= v5[2]

		if v6 > 0 or #v4 == 0 and k == #v2 then
			table.insert(v4, (`{v6}{v5[1]}`))
		end
	end

	if #v4 <= 1 then
		return v4[1]
	end

	return (`{table.concat(v4, " ", 1, #v4 - 1)} and {v4[#v4]}`)
end

local v3 = {
	{ "year", 31536000 },
	{ "month", 2592000 },
	{ "week", 604800 },
	{ "day", 86400 },
	{ "hour", 3600 },
	{ "minute", 60 }
}

function Utility.formatTimeAgo(p: number)
	local v4 = math.max(os.time() - math.floor(p), 0)

	for _, v5 in v3 do
		local v6 = math.floor(v4 / v5[2])

		if v6 >= 1 then
			return (`{v6} {v5[1]}{v6 > 1 and "s" or ""} ago`)
		end
	end

	return "Just now"
end

function Utility.calcvel(p, p2, p3, p4)
	return (p - p2 - 0.5 * p3 * p4 * p4) / p4
end

local TextService = game:GetService("TextService")
game:GetService("Workspace")
local gameSettings2 = require(ReplicatedStorage.CAM.Global.gameSettings)

function Utility:AddTag(tag: string)
	self:AddTag(tag)
	return self
end

function Utility.CreatePrompt(instance)
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.ActionText = instance.ActionText or "Interact"
	proximityPrompt.ObjectText = instance.ObjectText or ""
	proximityPrompt.Name = instance.Name or (instance.ObjectText == nil or instance.ObjectText == "") and "ProximityPrompt" or instance.ObjectText or "ProximityPrompt"
	proximityPrompt.HoldDuration = instance.HoldDuration or 0
	proximityPrompt.MaxActivationDistance = instance.MaxActivationDistance or 8
	proximityPrompt.MaxIndicatorDistance = instance.MaxIndicatorDistance or proximityPrompt.MaxActivationDistance + gameSettings2.indicatorAdditionalDistance
	proximityPrompt.KeyboardKeyCode = instance.KeyboardKeyCode or Enum.KeyCode.T
	proximityPrompt.Style = instance.Style or Enum.ProximityPromptStyle.Custom
	proximityPrompt.RequiresLineOfSight = instance.RequiresLineOfSight ~= nil and instance.RequiresLineOfSight

	if instance.Enabled ~= nil then
		proximityPrompt.Enabled = instance.Enabled
	end

	if instance.Tags ~= nil then
		for _, tag in instance.Tags do
			proximityPrompt:AddTag(tag)
		end
	end

	if instance.Attributes ~= nil then
		for k, attribute in instance.Attributes do
			proximityPrompt:SetAttribute(k, attribute)
		end
	end

	proximityPrompt.Parent = instance.Parent
	return proximityPrompt
end

function Utility.CreateOuwWeld(parent, p2, offset: CFrame?, p3: number?)
	if parent == nil or p2 == nil then
		warn("Unable to create weld")
		return
	end

	local objectValue = Instance.new("ObjectValue")
	objectValue.Parent = parent
	objectValue.Value = p2

	if offset ~= nil then
		objectValue:SetAttribute("Offset", offset)
	end

	local objectValue2 = Instance.new("ObjectValue", objectValue)
	objectValue2.Name = "To"
	objectValue2.Value = parent
	task.defer(objectValue.AddTag, objectValue, "OuwWeld")

	if p3 ~= nil then
		DebrisModule:AddItem(objectValue, p3)
	end

	return objectValue
end

function Utility.filterText(p, value: string)
	if p == nil or typeof(value) ~= "string" or #value > 200 then
		return
	end

	local userId = p.UserId
	local nonChatStringForUserAsync = nil
	pcall(function()
		nonChatStringForUserAsync = TextService:FilterStringAsync(value, userId):GetNonChatStringForUserAsync(userId)
	end)
	return nonChatStringForUserAsync
end

function Utility.addCommasToNumber(p: number)
	local v4 = tostring(p)
	local v5 = v4:sub(1, 1) == "-"

	if v5 then
		v4 = v4:sub(2)
	end

	local match, v6 = v4:match("^(%d+)(%.%d*)$")
	local v7 = (match or v4):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")

	if v6 then
		v7 ..= v6
	end

	if v5 then
		return "-" .. v7
	end

	return v7
end

local v4 = {
	"One",
	"Two",
	"Three",
	"Four",
	"Five",
	"Six",
	"Seven",
	"Eight",
	"Nine",
	"Ten",
	"Eleven",
	"Twelve",
	"Thirteen",
	"Fourteen",
	"Fifteen",
	"Sixteen",
	"Seventeen",
	"Eighteen",
	"Nineteen"
}
local v5 = {
	"Twenty",
	"Thirty",
	"Forty",
	"Fifty",
	"Sixty",
	"Seventy",
	"Eighty",
	"Ninety"
}
local v6 = {
	"Thousand",
	"Million",
	"Billion",
	"Trillion"
}

function Utility.numberToWords(p: number)
	local v7 = math.round(p)

	if v7 == 0 then
		return "Zero"
	end

	local v8 = {}

	if v7 < 0 then
		table.insert(v8, "Negative")
		v7 = -v7
	end

	local function underThousand(p2: number)
		if p2 >= 100 then
			table.insert(v8, v4[math.floor(p2 / 100)])
			table.insert(v8, "Hundred")
			p2 %= 100
		end

		if p2 >= 20 then
			table.insert(v8, v5[math.floor(p2 / 10) - 1])
			p2 %= 10
		end

		if p2 > 0 then
			table.insert(v8, v4[p2])
		end
	end

	local v9 = {}

	while v7 > 0 do
		table.insert(v9, 1, v7 % 1000)
		v7 = math.floor(v7 / 1000)
	end

	for k, v10 in v9 do
		if not (v10 > 0) then
			continue
		end

		if v10 >= 100 then
			table.insert(v8, v4[math.floor(v10 / 100)])
			table.insert(v8, "Hundred")
			v10 %= 100
		end

		if v10 >= 20 then
			table.insert(v8, v5[math.floor(v10 / 10) - 1])
			v10 %= 10
		end

		if v10 > 0 then
			table.insert(v8, v4[v10])
		end

		local v11 = v6[#v9 - k]

		if v11 ~= nil then
			table.insert(v8, v11)
		end
	end

	return table.concat(v8, " ")
end

function Utility.Damagehighlight(p, p2)
	if p == nil or p.Parent == nil then
		return
	end

	if p.Parent:FindFirstChild("Hit_Highlight123asd") then
		p.Parent.Hit_Highlight123asd:Destroy()
	end

	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = p2 == -1 and 0.4 or -0.3
	highlight.Name = "Hit_Highlight123asd"
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.OutlineTransparency = 1
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.Parent = p.Parent
	DebrisModule:AddItem(highlight, 0.15)
	TweenService:Create(highlight, tweenInfo, {
		FillTransparency = 1
	}):Play()
end

function Utility.Tick()
	local serverTimeNow = workspace:GetServerTimeNow()

	if serverTimeNow < 1000000000 then
		return os.time()
	end

	return serverTimeNow
end

function Utility.GetPosInBeam(p, p2, p3, p4, p5)
	return (1 - p) ^ 3 * p2 + 3 * (1 - p) ^ 2 * p * p3 + 3 * (1 - p) * p ^ 2 * p4 + p ^ 3 * p5
end

function Utility.Bezier_Curve_beam_curve_calc(vector2: Vector3, vector3: Vector3, p: number)
	local midpoint = (vector2 + vector3) / 2
	local vector4 = Vector3.new(midpoint.x, midpoint.y + p, midpoint.z)
	return
		vector4 * 0.6666666666666666 + vector2 * 0.3333333333333333,
		vector4 * 0.6666666666666666 + vector3 * 0.3333333333333333
end

function Utility.ClearChildren(instance)
	if instance == nil then
		return
	end

	for _, child in ipairs(instance:GetChildren()) do
		child:Destroy()
	end
end

local v7 = {
	swimbv = true
}
local v8 = {
	air_combo_bp = true
}

function Utility:ClearMovers()
	if self == nil then
		return
	end

	for _, child in pairs(self:GetChildren()) do
		if v7[child.Name] == nil and (child:FindFirstChildOfClass("LinearVelocity") or v8[child.Name]) then
			child:Destroy()
		end
	end

	self.AssemblyLinearVelocity = createVector(0, 0, 0)
	self.Velocity = createVector(0, 0, 0)
end

local v9 = {
	combat_knockbackLast = "combat_knockback"
}

function Utility.IsMeshRig(model)
	if model == nil or not model:IsA("Model") then
		return false
	end

	local isMeshRig = model:GetAttribute("IsMeshRig")

	if isMeshRig ~= nil then
		return isMeshRig
	end

	local v10

	if model:FindFirstChild("Torso") == nil then
		v10 = model:FindFirstChild("UpperTorso") == nil
	else
		v10 = false
	end

	model:SetAttribute("IsMeshRig", v10 and true or nil)
	return v10
end

function Utility.bv(parent, vectorVelocity, duration, value)
	if parent == nil or (vectorVelocity.Magnitude ~= vectorVelocity.Magnitude or vectorVelocity.Magnitude == 1e999) then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(parent.Parent)

	if getvaluesfolder == nil or getvaluesfolder:FindFirstChild("Swapping") then
		return
	end

	local v10 = value or "regular_bv"
	local name = v9[v10] or v10

	if parent:FindFirstChild("dash_thang_123asd") ~= nil then
		parent.dash_thang_123asd:Destroy()
	end

	local Y = vectorVelocity.Y
	local v12 = true

	if value == "delete" then
		for _, child in pairs(parent:GetChildren()) do
			if not (v7[child.Name] == nil and child:FindFirstChild("Velocity") and child.Velocity:IsA("LinearVelocity")) then
				continue
			end

			child:Destroy()
		end
	else
		if parent:FindFirstChild(name) ~= nil then
			local v13 = true

			for _, child in pairs(parent:GetChildren()) do
				if child.Name ~= name then
					continue
				end

				local velocity = child:FindFirstChild("Velocity")
				local lineVelocity

				if velocity == nil then
					lineVelocity = 0
				elseif velocity.VelocityConstraintMode == Enum.VelocityConstraintMode.Line then
					lineVelocity = velocity.LineVelocity
				else
					lineVelocity = velocity.VectorVelocity.Magnitude
				end

				if lineVelocity <= vectorVelocity.Magnitude then
					child:Destroy()
				else
					v13 = false
				end
			end

			if v13 ~= true then
				v12 = false
			end
		end

		if v12 == true then
			local attachment = Instance.new("Attachment")
			attachment.Name = name
			attachment:SetAttribute("Added", clock())
			attachment:SetAttribute("Duration", duration)
			local linearVelocity = Instance.new("LinearVelocity")
			attachment.Parent = parent
			linearVelocity.Name = "Velocity"
			linearVelocity.Parent = attachment
			local v14 = clamp(parent.AssemblyMass / 2.2, 1, 999) * 20000

			if Utility.IsMeshRig(parent.Parent) then
				v14 = math.max(v14, 40000)
			end

			linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis

			if Y == 0 then
				linearVelocity.MaxAxesForce = Vector3.new(v14, 0, v14)
			else
				linearVelocity.MaxAxesForce = Vector3.new(v14, v14, v14)
			end

			linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
			linearVelocity.VectorVelocity = vectorVelocity
			linearVelocity.Attachment0 = attachment
			DebrisModule:AddItem(attachment, duration)
		end
	end
end

function Utility.SinglePartHitbox(data)
	if data == nil or data.Caster == nil or data.BoxSize == nil or data.ParamsName == nil then
		return
	end

	local dynamicOverlapParams, v10 = RaycastHelper.GetDynamicOverlapParams(data.ParamsName, 5)

	if v10 then
		dynamicOverlapParams.FilterDescendantsInstances = { data.Caster, workspace.Map, workspace.Debree }
		dynamicOverlapParams.FilterType = Enum.RaycastFilterType.Exclude
		dynamicOverlapParams.MaxParts = data.MaxParts or 16
	end

	local within = data.Within or { workspace:FindFirstChild("Humanoids") }

	if (gameSettings.hitboxVisualiserEnabled or data.Visualize) and isStudio then
		local part = Instance.new("Part")
		part.CanCollide = false
		part.Anchored = true
		part.Color = Color3.new(0, 1, 0)
		part.CanQuery = false
		part.CFrame = data.Origin
		part.Size = data.BoxSize
		part.Parent = workspace.Debree
		part.TopSurface = Enum.SurfaceType.SmoothNoOutlines
		part.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
		part.Transparency = 0.9
		local Debris = game:GetService("Debris")
		Debris:AddItem(part, 1)
	end

	local partBoundsInBox = workspace:GetPartBoundsInBox(data.Origin, data.BoxSize, dynamicOverlapParams)

	if within[1] == nil then
		return partBoundsInBox[1]
	end

	for _, v11 in partBoundsInBox do
		for _, ancestor in within do
			if v11:IsDescendantOf(ancestor) then
				return v11
			end
		end
	end

	return nil
end

function Utility:TreeDestruction()
	if not (self ~= nil and self.CFrame ~= nil and self.Size ~= nil) then
		return
	end

	self.Level = self.Level or 2
	local partBoundsInBox = workspace:GetPartBoundsInBox(self.CFrame, self.Size, overlapParams)
	local v10 = #partBoundsInBox > 0
	local v11, v12, parents

	if v10 then
		v11 = {}
		v12 = {}
		parents = {}
		task.delay(gameSettings.TreeDestructionRespawnTime, function()
			for k, parent in parents do
				if k.Parent == workspace.Debree and parent.Parent ~= nil then
					k.Parent = parent
				end
			end

			for _, v13 in v12 do
				if v13.Parent ~= nil then
					v13.CanCollide = true
				end
			end
		end)
	else
		parents = nil
		v12 = nil
	end

	for _, v13 in partBoundsInBox do
		if v13:GetAttribute("IsBush") then
			if v11.Bush == nil then
				v11.Bush = {}
			end

			if v13.CanCollide == true then
				table.insert(v12, v13)
				v13.CanCollide = false
			end

			parents[v13] = v13.Parent
			v13.Parent = workspace.Debree
			table.insert(v11.Bush, v13)
		else
			local parent = v13.Parent
			local flag = false

			for _, model in parent:GetChildren() do
				if not model:IsA("Model") then
					continue
				end

				flag = true
				break
			end

			if flag then
				if v13.Parent ~= workspace.Debree then
					if v11.Bush == nil then
						v11.Bush = {}
					end

					if v13.CanCollide == true then
						table.insert(v12, v13)
						v13.CanCollide = false
					end

					parents[v13] = v13.Parent
					v13.Parent = workspace.Debree
					table.insert(v11.Bush, v13)
				end
			elseif parent.Parent ~= workspace.Debree then
				if v11.Others == nil then
					v11.Others = {}
				end

				parents[parent] = parent.Parent
				parent.Parent = workspace.Debree
				table.insert(v11.Others, parent)

				for _, part in parent:GetDescendants() do
					if not (part:IsA("BasePart") and part.CanCollide == true) then
						continue
					end

					table.insert(v12, part)
					part.CanCollide = false
				end
			end
		end
	end

	if v10 and isServer and (v11.Bush ~= nil or v11.Others ~= nil) then
		EffectsEvent.ToAllInRange(self.CFrame, "TreeDestruction", v11)
	end
end

function Utility.ProcessHitboxTarget(data, instance)
	if instance == data.caster then
		return false, false
	end

	local humanoid = instance:FindFirstChild("Humanoid")
	local v10

	if humanoid ~= nil then
		v10 = humanoid.RootPart or nil
	end

	if not (humanoid and v10) then
		return false, false
	end

	local getvaluesfolder = Utility.getvaluesfolder(instance)
	local check_victim = data.checker.check_victim(script, data.caster, instance)

	if check_victim == nil then
		return false, false, getvaluesfolder
	end

	if data.hitPriorityHandler and data.hitPriorityHandler.callback(getvaluesfolder, data.hitPriorityHandler.data) == true or data.specificStateResult and check_victim ~= data.specificStateResult then
		return false, false, getvaluesfolder, check_victim
	end

	return
		true,
		data.hitDetected(instance, getvaluesfolder, check_victim, data.extraArgs or {}) == true,
		getvaluesfolder,
		check_victim
end

function Utility.ProcessHitboxTargets(data, targets)
	if data.targets then
		local targets2

		if typeof(data.targets) == "table" then
			targets2 = data.targets
		else
			targets2 = { data.targets }
		end

		local v10

		if game.Players:GetPlayerFromCharacter(data.caster) ~= nil and data.hitboxCFrame ~= nil and data.hitboxSize ~= nil then
			v10 = data.hitboxSize.Magnitude / 2 + 50
		end

		for _, target in targets2 do
			if table.find(targets, target) ~= nil then
				continue
			end

			if v10 ~= nil then
				local humanoid = target:FindFirstChild("Humanoid")
				local rootPart

				if humanoid ~= nil then
					rootPart = humanoid.RootPart
				end

				if rootPart == nil or v10 < (rootPart.Position - data.hitboxCFrame.Position).Magnitude then
					continue
				end
			end

			table.insert(targets, target)
		end
	end

	local result = {}

	for _, v10 in targets do
		local v11, v12, _, v13 = Utility.ProcessHitboxTarget(data, v10)

		if v11 and v13 == true then
			table.insert(result, v10)
		end

		if v12 then
			break
		end
	end

	local v10 = result[1] ~= nil

	if data.After ~= nil then
		data.After(v10, result)
	end

	return v10, result
end

function Utility.SnapAimToTarget(data)
	local singlePartHitbox = Utility.SinglePartHitbox({
		Caster = data.Caster,
		ParamsName = data.ParamsName,
		Origin = CFrame.new(data.Aim),
		BoxSize = createVector(1, 1, 1) * data.Radius
	})

	if singlePartHitbox == nil then
		return data.Aim, nil
	end

	local find_character_from_descendant = Utility.find_character_from_descendant(singlePartHitbox)

	if find_character_from_descendant == nil or find_character_from_descendant == data.Caster or data.Checker.check_can_select(
		script,
		data.Caster,
		find_character_from_descendant
	) ~= true then
		return data.Aim, nil
	end

	local humanoidRootPart = find_character_from_descendant:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return data.Aim, nil
	end

	if data.Feet == true then
		return
			humanoidRootPart.Position - Vector3.new(0, humanoidRootPart.Size.Y / 2, 0),
			find_character_from_descendant
	end

	return humanoidRootPart.Position, find_character_from_descendant
end

function Utility.CreateHitbox(data)
	if data.TreeDestructionLevel ~= nil or data.TreeDestruction then
		Utility.TreeDestruction({
			Level = data.TreeDestructionLevel or 2,
			CFrame = data.hitboxCFrame,
			Size = data.hitboxSize
		})
	end

	local modelInRegion = Utility.GetModelInRegion(
		data.hitboxCFrame,
		data.hitboxSize,
		data.customTagName,
		data.maxParts,
		data.visualize
	)
	return Utility.ProcessHitboxTargets(data, modelInRegion)
end

function Utility.lock(part, cframe: CFrame, p: number?, childName: string?)
	part:PivotTo(cframe)
	local clone = childName and workspace.Debree:FindFirstChild(childName)

	if not clone then
		clone = script.LOCK:Clone()
		clone.Name = childName or "LOCK"
		clone.Anchored = true
		clone.Parent = workspace.Debree
		clone.Transparency = 1
	end

	clone:PivotTo(cframe)

	if p then
		DebrisModule:AddItem(clone, p)
	end

	local weld = clone.Weld
	weld.Part0 = clone
	weld.Part1 = part
	return clone
end

function Utility.AddValue(parent, name: string, p: number?, className, p2)
	local instance = className and Instance.new(className) or Instance.new("BoolValue")
	instance.Name = name
	instance.Value = p2 or instance.ClassName == "BoolValue" or instance.Value
	instance.Parent = parent

	if p ~= nil then
		DebrisModule:AddItem(instance, p)
	end

	return instance
end

function Utility.AddTimedValue(p, p2: string, value: number?, p3: string?, p4)
	local v10 = Utility.AddValue(p, p2, value, p3, p4)
	v10:SetAttribute("_Started", workspace:GetServerTimeNow())
	v10:SetAttribute("_Duration", value or 0)
	return v10
end

Utility.DODGE_VALUE = "Dodge"

function Utility.AddDodges(character, p: number, p2: number?, flag: boolean?, skill: string?)
	if character == nil or p == nil or p <= 0 then
		return nil
	end

	if character:IsA("Player") then
		character = character.Character

		if character == nil then
			return nil
		end
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)

	if getvaluesfolder == nil then
		return nil
	end

	local v10 = Utility.AddTimedValue(getvaluesfolder, Utility.DODGE_VALUE, p2, "IntValue", p)
	v10:SetAttribute("Mode", flag == true and "All" or "Combat")

	if skill ~= nil then
		v10:SetAttribute("Skill", skill)
	end

	return v10
end

function Utility.bg(parent, cFrame: CFrame, p: number, responsiveness: number)
	local v10 = Utility.getvaluesfolder(parent.Parent) or parent.Parent
	Utility.AddValue(v10, "NR", p)

	if parent:FindFirstChild("rotremove123asdasd") ~= nil then
		for _, child in parent:GetChildren() do
			if child.Name == "rotremove123asdasd" then
				child:Destroy()
			end
		end
	end

	local attachment = Instance.new("Attachment", parent)
	local part = Instance.new("Part")
	part.Name = "P"
	part.Size = createVector(1, 1, 1)
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cFrame
	part.Parent = parent
	local alignOrientation = Instance.new("AlignOrientation")

	if responsiveness ~= nil then
		alignOrientation.Responsiveness = responsiveness
	end

	alignOrientation.Attachment0 = attachment
	DebrisModule:AddItem(alignOrientation, p)
	local attachment2 = Instance.new("Attachment", part)
	alignOrientation.Attachment1 = attachment2
	alignOrientation.Parent = parent
	DebrisModule:AddItem(attachment, p)
	DebrisModule:AddItem(attachment2, p)
	DebrisModule:AddItem(part, p)
	alignOrientation.Name = "rotremove123asdasd"
	attachment.Name = "rotremove123asdasd"
	attachment2.Name = "rotremove123asdasd"
	part.Name = "rotremove123asdasd"
end

function Utility.GetRoot(name, flag: boolean?)
	if typeof(name) == "Instance" then
		name = name.Name
	end

	if name == nil or name == "" then
		return nil
	end

	if isRunning == false then
		name ..= "-Studio"
	end

	local data = game.ReplicatedStorage.Player_Service.Data

	if flag == true then
		return (data:WaitForChild(name))
	end

	return (data:FindFirstChild(name))
end

function Utility.GetData(name, flag: boolean, p: string)
	if name == nil then
		if isRunning == false then
			local player_Service = game.ReplicatedStorage:FindFirstChild("Player_Service")
			local data

			if player_Service ~= nil then
				data = player_Service:FindFirstChild("Data")
			end

			if data == nil then
				return
			end

			for _, child in data:GetChildren() do
				if string.sub(child.Name, -7) == "-Studio" then
					return child
				end
			end
		end
	else
		if not p then
			name = name.Name or name
		end

		local child

		if isRunning == false then
			if flag == true then
				child = game.ReplicatedStorage.Player_Service.Data:WaitForChild(name .. "-Studio")
			else
				child = game.ReplicatedStorage.Player_Service.Data:FindFirstChild(name .. "-Studio")
			end
		elseif flag == true then
			child = game.ReplicatedStorage.Player_Service.Data:WaitForChild(name)
		else
			child = game.ReplicatedStorage.Player_Service.Data:FindFirstChild(name)
		end

		if not child then
			return
		end

		if flag == true then
			local slotEquipped = child:WaitForChild("slotEquipped")
			return child:WaitForChild("slots"):WaitForChild("Slot" .. slotEquipped.Value), child, slotEquipped
		end

		local slotEquipped = child:FindFirstChild("slotEquipped")
		local slots = child:FindFirstChild("slots")
		local child2

		if not (slotEquipped == nil or slots == nil) then
			child2 = slots:FindFirstChild("Slot" .. slotEquipped.Value)
		end

		if child2 == nil then
			return
		else
			return child2, child, slotEquipped
		end
	end
end

local v10 = nil

function Utility.ItemBag(instance, p: string)
	if instance == nil then
		return
	end

	v10 = v10 or require(ReplicatedStorage.CAM.Global.Collectibles.Items)
	local v11 = v10[p]
	local inventory

	if v11 == nil or v11.AccountWide ~= true then
		inventory = instance:FindFirstChild("Inventory")
	elseif instance.Parent == nil or instance.Parent.Parent == nil then
		inventory = false
	else
		inventory = instance.Parent.Parent:FindFirstChild("AccountItems")
	end

	if inventory then
		return (inventory:FindFirstChild("Inventory"))
	end

	return nil
end

function Utility.ItemBags(instance)
	local inventories = {}

	if instance == nil then
		return inventories
	end

	local inventory = instance:FindFirstChild("Inventory")
	local inventory2

	if inventory ~= nil then
		inventory2 = inventory:FindFirstChild("Inventory")
	end

	if inventory2 ~= nil then
		table.insert(inventories, inventory2)
	end

	local parent

	if instance.Parent ~= nil then
		parent = instance.Parent.Parent
	end

	local accountItems

	if parent ~= nil then
		accountItems = parent:FindFirstChild("AccountItems")
	end

	local inventory3

	if accountItems ~= nil then
		inventory3 = accountItems:FindFirstChild("Inventory")
	end

	if inventory3 ~= nil then
		table.insert(inventories, inventory3)
	end

	return inventories
end

function Utility.HeldEntries(p)
	local v11 = {}

	for _, v12 in Utility.ItemBags(p) do
		local children = v12:GetChildren()
		table.move(children, 1, #children, #v11 + 1, v11)
	end

	return v11
end

function Utility.HeldItem(p, childName: string)
	local itemBag = Utility.ItemBag(p, childName)

	if itemBag == nil then
		return nil
	end

	return (itemBag:FindFirstChild(childName))
end

function Utility.SafeLookAt(vector2: Vector3, vector3: Vector3, cframe: CFrame)
	local v11 = vector3 - vector2
	local magnitude = v11.Magnitude

	if magnitude ~= magnitude or magnitude < 0.05 then
		return cframe
	end

	if math.abs(v11.Unit.Y) > 0.999 then
		return CFrame.lookAt(vector2, vector3, cframe.RightVector)
	end

	return CFrame.lookAt(vector2, vector3)
end

function Utility.SafeMoverTarget(vector2: Vector3, vector3: Vector3)
	local magnitude = vector2.Magnitude

	if magnitude == magnitude and magnitude ~= 1e999 then
		return vector2
	end

	return vector3
end

function Utility.SafeDirection(vector2: Vector3, vector3: Vector3)
	local v11 = vector3 - vector2
	local magnitude = v11.Magnitude

	if magnitude == magnitude and magnitude ~= 1e999 and not (magnitude < 0.05) then
		return v11 / magnitude
	end

	return nil
end

function Utility.getvaluesfolder(instance, flag: boolean?)
	if instance == nil then
		return nil
	end

	local name = instance.Name or instance

	if not isRunning then
		name ..= "-Studio"
	end

	if name == nil then
		return
	end

	local child

	if flag then
		child = game.ReplicatedStorage.Player_Service.Values:WaitForChild(name)
	else
		child = game.ReplicatedStorage.Player_Service.Values:FindFirstChild(name) or instance
	end

	if instance.Parent ~= nil and instance:FindFirstChild("Clone_Owner") then
		child = instance
	end

	return child
end

function Utility.GetModelInRegion(cFrame: CFrame, size: Vector3, tag: string?, value: number?, flag: boolean?)
	local overlapParams2 = humanoids

	if tag ~= nil and tag ~= "Humanoids" then
		overlapParams2 = OverlapParams.new()
		overlapParams2.FilterType = Enum.RaycastFilterType.Include
		overlapParams2.FilterDescendantsInstances = CollectionService:GetTagged(tag)
		overlapParams2.MaxParts = value or 350
	end

	local partBoundsInBox = workspace:GetPartBoundsInBox(cFrame, size, overlapParams2)
	local parents = {}

	for _, v11 in partBoundsInBox do
		local parent = v11.Parent

		if not (parent:IsA("Model") and parent.PrimaryPart ~= nil and table.find(parents, parent) == nil) then
			continue
		end

		table.insert(parents, parent)
	end

	if gameSettings.hitboxVisualiserEnabled ~= true and flag ~= true or isStudio ~= true then
		return parents
	end

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CastShadow = false
	part.CanQuery = false
	part.TopSurface = Enum.SurfaceType.SmoothNoOutlines
	part.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
	part.Transparency = gameSettings.HitBoxTransparency or 0.85
	part.Color = Color3.fromRGB(255, 0, 0)
	part.Name = "HitboxVisual"
	part.Size = size
	part.CFrame = cFrame
	part.Parent = hitboxVisuals or workspace.Debree
	local Debris = game:GetService("Debris")
	Debris:AddItem(part, 1)
	return parents
end

function Utility.checkGamePassOwnership(_, p, p2)
	local success, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(p.UserId, p2)
	end)

	if success then
		return result
	end

	warn("Failed to check game pass ownership for player " .. p.Name)
	return false
end

local clamp2 = math.clamp
local new = Vector3.new
local floor = math.floor

function Utility.Lerp(_, p, p2, p3: number)
	return p + (p2 - p) * p3
end

function Utility.Lerp_Color(color: Color3, color2: Color3, p: number)
	local lerped = Utility:Lerp(
		Vector3.new(color.R * 255, color.G * 255, color.B * 255),
		Vector3.new(color2.R * 255, color2.G * 255, color2.B * 255),
		p
	)
	return (new(
		floor((clamp2(lerped.X, 0, 255))),
		floor((clamp2(lerped.Y, 0, 255))),
		(floor((clamp2(lerped.Z, 0, 255))))
	))
end

function Utility.Lerp_Color2(color: Color3, color2: Color3, p: number)
	local lerped = Utility:Lerp(
		Vector3.new(color.R * 255, color.G * 255, color.B * 255),
		Vector3.new(color2.R * 255, color2.G * 255, color2.B * 255),
		p
	)
	return Color3.fromRGB(
		floor((clamp2(lerped.X, 0, 255))),
		floor((clamp2(lerped.Y, 0, 255))),
		(floor((clamp2(lerped.Z, 0, 255))))
	)
end

function Utility.Add_No_GP(_, p, p2, p3: number)
	if p == nil or p2 == nil then
		return
	else
		return Utility.AddValue(p2, "pause_gameplay", p3)
	end
end

function Utility.StunClear(_, instance)
	if instance:FindFirstChild("SkillToggle") ~= nil then
		for _, child in pairs(instance:GetChildren()) do
			if child.Name == "SkillToggle" and child:GetAttribute("OnlySkill") == nil then
				child:Destroy()
			end
		end
	end
end

Utility.TEMPORARY_BOOST = "TemporaryBoost"
local v11 = nil

local function perHitShare(instance)
	if instance == nil then
		return 1
	end

	if v11 == nil then
		local SkillStats = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.StatsFetch.Modules.SkillStats)
		v11 = SkillStats
	end

	local v12

	if instance.Parent ~= nil then
		v12 = v11.Get(instance.Parent.Name) or nil
	end

	if v12 == nil then
		v12 = v11.Get(instance.Name)
	end

	return v12 and v12.additional_damage_scale or 1
end

function Utility.StunChainBoost(p, character, parent, p2: string)
	if not isServer or parent == nil then
		return
	end

	local stunChainBoost = gameSettings2.StunChainBoost

	if stunChainBoost == nil or stunChainBoost.Enabled ~= true then
		return
	end

	local player = Players:FindFirstChild(parent.Name)
	local v12

	if player == nil then
		v12 = false
	else
		v12 = player:IsA("Player")
	end

	if not v12 and stunChainBoost.Npcs ~= true then
		return
	end

	local v13 = stunChainBoost[p2] or 1

	if p2 == "Stun" then
		v13 = 1 + (v13 - 1) * perHitShare(p)
	end

	if v13 <= 1 then
		return
	end

	local v14 = nil

	for _, numberValue in parent:GetChildren() do
		if not (numberValue.Name == Utility.TEMPORARY_BOOST and numberValue:GetAttribute("Stat") == stunChainBoost.Stat and numberValue:IsA("NumberValue")) then
			continue
		end

		v14 = numberValue
		break
	end

	local serverTimeNow = workspace:GetServerTimeNow()

	if v14 == nil then
		v14 = Instance.new("NumberValue")
		v14.Name = Utility.TEMPORARY_BOOST
		v14.Value = math.min(v13, stunChainBoost.Cap)
		v14:SetAttribute("Stat", stunChainBoost.Stat)
		v14:SetAttribute("_Duration", stunChainBoost.Duration)
		v14:SetAttribute("_Started", serverTimeNow)
		v14:AddTag("OuwDebris")
		v14:SetAttribute("_OuwDebrisAt", serverTimeNow + stunChainBoost.Duration)
		v14.Parent = parent
	else
		v14.Value = math.min(v14.Value * v13, stunChainBoost.Cap)
		v14:SetAttribute("_Started", serverTimeNow)
		v14:SetAttribute("_OuwDebrisAt", serverTimeNow + stunChainBoost.Duration)
	end

	if v12 and character ~= nil and Players:GetPlayerFromCharacter(character) ~= nil then
		v14:SetAttribute("PvP", true)
	end

	task.delay(stunChainBoost.Duration, function()
		if v14.Parent ~= nil and v14:GetAttribute("_Started") == serverTimeNow then
			v14:Destroy()
		end
	end)
end

function Utility.TemporaryBoostOf(instance, p: string)
	if instance == nil then
		return 1
	end

	for _, numberValue in instance:GetChildren() do
		if numberValue.Name == Utility.TEMPORARY_BOOST and numberValue:GetAttribute("Stat") == p and numberValue:IsA("NumberValue") then
			return numberValue.Value
		end
	end

	return 1
end

function Utility.Add_Strict_Stun(p, p2, parent, p3, flag: boolean?)
	if p2 == nil or parent == nil then
		return
	end

	Utility.StunClear(p, parent)
	Utility.StunChainBoost(p, p2, parent, "StrictStun")
	local objectValue = Instance.new("ObjectValue")
	objectValue.Name = "Strict_Stun"
	objectValue.Value = p2

	if flag then
		objectValue:SetAttribute("PerfectBlock", true)
	end

	objectValue.Parent = parent
	DebrisModule:AddItem(objectValue, p3)
	return objectValue
end

function Utility.AddStun(p, p2, parent, p3)
	if p2 == nil or parent == nil then
		return
	end

	Utility.StunClear(p, parent)
	Utility.StunChainBoost(p, p2, parent, "Stun")
	local objectValue = Instance.new("ObjectValue")
	objectValue.Name = "Stun"
	objectValue.Value = p2
	objectValue.Parent = parent
	DebrisModule:AddItem(objectValue, p3)
	return objectValue
end

function Utility.AddCombatStun(p, p2, parent, p3)
	if p2 == nil or parent == nil then
		return
	end

	Utility.StunClear(p, parent)
	Utility.StunChainBoost(p, p2, parent, "CombatStun")
	local objectValue = Instance.new("ObjectValue")
	objectValue.Name = "CombatStun"
	objectValue.Value = p2
	objectValue.Parent = parent
	DebrisModule:AddItem(objectValue, p3)
	return objectValue
end

local v12 = {
	Mode = Enum.OrientationAlignmentMode.OneAttachment
}

function Utility.CreateAlignOrientationWithAttachment(parent, name: string, items)
	local attachment = Instance.new("Attachment")
	attachment.Name = name
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Name = name

	for k, v13 in pairs(v12) do
		alignOrientation[k] = v13
	end

	alignOrientation.Attachment0 = attachment

	for k, item in pairs(items) do
		alignOrientation[k] = item
	end

	alignOrientation.Parent = attachment
	attachment.Parent = parent
	return alignOrientation, attachment
end

function Utility.FindPlayerByTypedName(childName: string)
	if type(childName) ~= "string" or childName == "" then
		return nil
	end

	local player = Players:FindFirstChild(childName)

	if player ~= nil and player:IsA("Player") then
		return player
	end

	local v13 = string.lower(childName)

	for _, v14 in Players:GetPlayers() do
		if string.lower(v14.Name) == v13 then
			return v14
		end
	end

	local v14 = nil

	for _, v15 in Players:GetPlayers() do
		if string.lower(v15.DisplayName) ~= v13 then
			continue
		end

		if v14 ~= nil then
			return nil
		end

		v14 = v15
	end

	return v14
end

function Utility.NameTag(p: string, flag: boolean?)
	local richTextPopularConfigs = gameSettings.RichTextPopularConfigs

	if flag then
		return (`<font {string.lower(richTextPopularConfigs.SoroundColorRBX)}>'{p}'</font>`)
	end

	return (`['{p}']<{richTextPopularConfigs.SoroundColor}>`)
end

Utility.find_character_from_descendant = require(script.find_character_from_descendant)
return Utility