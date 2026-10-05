local DungeonHighlighter = {}
local Maid = require(game.ReplicatedStorage.Util.Maid)
local v = {}
local RunService = game:GetService("RunService")

if not (RunService:IsClient() and workspace:GetAttribute("MAP") == "Dungeons") then
	return DungeonHighlighter
end

local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character
localPlayer.CharacterAdded:Connect(function(character2)
	character = character2
end)

local function getHighlight(instance, p)
	local v2 = p.Highlight

	if v2 then
		return v2
	end

	v2 = Instance.new("Highlight")
	assert(v2)
	v2.Archivable = false
	v2.Name = "DungeonHighlight"
	v2.Parent = instance
	v2.Adornee = instance
	v2.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	v2.FillTransparency = 1
	v2.OutlineTransparency = 0.35
	p.Maid.ObservationHighlightWatcher = instance.ChildAdded:Connect(function(highlight)
		p.Maid.delayedObservationWatch = task.defer(function()
			if highlight:IsA("Highlight") and highlight ~= v2 then
				v2.Parent = nil
				p.Maid:GiveTask(highlight.AncestryChanged:Connect(function(_, parent)
					if not parent then
						v2.Parent = instance
					end
				end))
			end
		end)
	end)
	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateHighlight(p, instance)
	local highlight = p.Highlight
	local pivot = instance:GetPivot()
	local magnitude = (character:GetPivot().Position - pivot.Position).Magnitude

	if magnitude <= 100 then
		highlight.FillTransparency = 1
	else
		highlight.FillTransparency = 1 - math.clamp((magnitude - 100) / 100, 0, 0.75)
	end
end

local function updateColor(p)
	local HSV, v2, v3 = p.Color:ToHSV()
	local color = Color3.fromHSV(HSV, math.clamp(v2 + 0.25, 0, 1), (math.clamp(v3 + 0.25, 0, 1)))
	p.Highlight.OutlineColor = color
	local color2 = Color3.fromHSV(HSV, math.clamp(v2 - 0.15, 0, 1), (math.clamp(v3 - 0.25, 0, 1)))
	p.Highlight.FillColor = color2
end

local function registerObject(instance)
	if not v[instance] then
		v[instance] = {
			Highlight = nil,
			Color = Color3.new(1, 1, 1),
			Maid = Maid.new()
		}
		v[instance].Highlight = getHighlight(instance, v[instance])
	end

	return v[instance]
end

local function init()
	local characters = workspace:WaitForChild("Characters")
	local enemies = workspace:WaitForChild("Enemies")

	local function tryRegisterEnemyOrCharacter(child, color: Color3)
		task.wait(0.1)

		if v[child] then
			return
		end

		local playerFromCharacter = game.Players:GetPlayerFromCharacter(child)

		if playerFromCharacter == localPlayer then
			return
		end

		local playerColor = playerFromCharacter and playerFromCharacter:GetAttribute("PlayerColor")
		local v2 = registerObject(child)
		v2.Color = playerColor or color

		function v2.Maid.cleanupHighlighter()
			if v2.Highlight then
				v2.Highlight:Destroy()
			end
		end

		v2.Maid.objectDestroyedHandler = child.AncestryChanged:Connect(function(_, parent)
			if not parent then
				v2.Maid:DoCleaning()
				v[child] = nil
			end
		end)
		v2.Maid.playerColorChangedHandler = playerFromCharacter and playerFromCharacter:GetAttributeChangedSignal("PlayerColor"):Connect(function()
			v2.Color = playerFromCharacter:GetAttribute("PlayerColor") or color
			updateColor(v2)
		end) or child:GetAttributeChangedSignal("Color"):Connect(function()
			v2.Color = child:GetAttribute("Color") or color
			updateColor(v2)
		end)
		task.spawn(updateColor, v2)
	end

	for _, child in characters:GetChildren() do
		tryRegisterEnemyOrCharacter(child, Color3.new(0.384314, 1, 0.384314))
	end

	for _, child in enemies:GetChildren() do
		tryRegisterEnemyOrCharacter(child, child:GetAttribute("Color") or Color3.new(1, 0, 0))
	end

	characters.ChildAdded:Connect(function(child)
		task.wait(0.1)
		tryRegisterEnemyOrCharacter(child, Color3.new(0.384314, 1, 0.384314))
	end)
	enemies.ChildAdded:Connect(function(child)
		task.wait(0.1)

		if not child:FindFirstChild("Summoner") then
			tryRegisterEnemyOrCharacter(child, child:GetAttribute("Color") or Color3.new(1, 0, 0))
			return
		end

		local value = child:FindFirstChild("Summoner").Value

		if value then
			tryRegisterEnemyOrCharacter(child, value:GetAttribute("Color") or Color3.new(1, 0, 0))
		end
	end)
	local RunService2 = game:GetService("RunService")
	RunService2.Heartbeat:Connect(function(_)
		for k, v2 in v do
			updateHighlight(v2, k) -- equivalent call inferred; original call site unknown
		end
	end)
end

task.defer(init)
return DungeonHighlighter