local createVector = vector.create
local PartyPopperEffects = {}
game:GetService("TweenService")
game:GetService("Debris")
game:GetService("Players")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HighlightController = require(ReplicatedStorage.SharedUtils.HighlightController)
local v = {}
local v2 = {}
local v3 = nil

local function debugPrint(_) end

local function removeHighlight(p)
	local v4 = v[p]

	if v4 then
		if v4.highlight then
			pcall(function()
				v4.highlight:Destroy()
			end)
		end

		if v4.warningIcon then
			pcall(function()
				v4.warningIcon:Destroy()
			end)
		end

		v[p] = nil
	end
end

local function highlightMonster(model, _)
	if not (model and model.Parent and model.PrimaryPart) then
		return
	end

	local fullName = model:GetFullName()

	if v[fullName] then
		v[fullName].lastSeen = os.clock()
		return
	end

	local extentsOffset = model.Name == "AstroMonster" and createVector(0, 0.5, 0) or createVector(0, 1.5, 0)
	local highlight, warningIcon = HighlightController:PlayHighlight(model, "Threat", {
		FillColor = Color3.fromRGB(255, 132, 203),
		FillTransparency = 1,
		OutlineColor = Color3.fromRGB(255, 132, 203),
		OutlineTransparency = 0,
		Priority = HighlightController.Priority.TRINKET,
		Billboard = {
			Label = "TWISTED",
			Template = "WarningIcon",
			Size = UDim2.new(16, 0, 16, 0),
			ExtentsOffset = extentsOffset
		}
	})
	highlight.Name = "PartyPopperHighlight"
	v[fullName] = {
		highlight = highlight,
		warningIcon = warningIcon,
		lastSeen = os.clock()
	}
end

local function fn()
	for k, _ in pairs(v) do
		removeHighlight(k)
	end

	if workspace:FindFirstChild("CurrentRoom") then
		local model = workspace.CurrentRoom:FindFirstChildWhichIsA("Model")
		local monsters = model and model:FindFirstChild("Monsters")

		if monsters then
			for _, child in ipairs(monsters:GetChildren()) do
				local partyPopperHighlight = child:FindFirstChild("PartyPopperHighlight")

				if partyPopperHighlight then
					partyPopperHighlight:Destroy()
				end

				if not child.PrimaryPart then
					continue
				end

				for _, child2 in pairs(child.PrimaryPart:GetChildren()) do
					if child2.Name == "PartyPopperWarning" then
						child2:Destroy()
					end
				end
			end
		end
	end

	table.clear(v)
end

local function fn2(userId)
	if v2[userId] then
		v2[userId] = nil
		local _ = "Cleaned up player state for: " .. userId
	end
end

function PartyPopperEffects.ScanArea(_, instance)
	if not (instance and instance.Parent and instance.PrimaryPart) then
		return
	end

	local position = instance.PrimaryPart.Position
	local model = workspace.CurrentRoom:FindFirstChildWhichIsA("Model")

	if not (model and workspace.Info.FloorActive.Value) then
		return
	end

	local monsters = model:FindFirstChild("Monsters")

	if not monsters then
		return
	end

	for _, model2 in ipairs(monsters:GetChildren()) do
		if not model2:IsA("Model") or not model2.PrimaryPart or not model2:GetChildren()[1] or string.find(
			model2.Name,
			"Rodger"
		) then
			continue
		end

		local magnitude = (position - model2.PrimaryPart.Position).Magnitude
		local fullName = model2:GetFullName()

		if magnitude <= 100 then
			highlightMonster(model2, position)
		else
			removeHighlight(fullName)
		end
	end
end

local function startBuffHighlightSession(instance, instance2)
	if not (instance2 and instance2.Parent) then
		return
	end

	local userId = instance.UserId
	fn()
	fn2(userId)
	local now = os.clock()
	local highlightEndTime = now + 5
	v2[userId] = {
		highlightEndTime = highlightEndTime,
		lastActiveTime = now,
		wasExtracting = false
	}
	local v5 = {}
	v3 = v5
	task.spawn(function()
		while instance2 and instance2.Parent and v3 == v5 and os.clock() < highlightEndTime do
			PartyPopperEffects.ScanArea(instance, instance2)
			task.wait(0.5)
		end

		if v3 == v5 then
			v3 = nil
			fn()
			fn2(userId)
		end
	end)
end

function PartyPopperEffects.ClientAbility(instance, instance2, p)
	if p == "MachineBuff" then
		startBuffHighlightSession(instance, instance2)
		return
	end

	local connections = {}
	local v4 = false
	local userId = instance.UserId

	if not (instance2 and instance2:FindFirstChild("Stats")) then
		return
	end

	local _ = instance2.Stats
	local decoding = instance2:FindFirstChild("Decoding")

	if not decoding then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function immediateCleanup()
		v4 = false
		v3 = nil
		fn()
		fn2(userId)
	end

	local function startHighlightSession()
		immediateCleanup() -- equivalent call inferred; original call site unknown
		local now = os.clock()
		v2[userId] = {
			highlightEndTime = now + 5,
			lastActiveTime = now,
			wasExtracting = true
		}
		local v5 = now + 5
		local _ = "Starting new highlight session; will end at " .. v5
		local v6 = {}
		v3 = v6
		v4 = true
		task.spawn(function()
			while instance2 and instance2.Parent and v4 and v3 == v6 and os.clock() < v5 and decoding.Value ~= nil do
				PartyPopperEffects.ScanArea(instance, instance2)
				task.wait(0.5)
			end

			if v3 == v6 then
				immediateCleanup() -- equivalent call inferred; original call site unknown
			end
		end)
	end

	connections[1] = decoding.Changed:Connect(function()
		if decoding.Value then
			startHighlightSession()
			return
		end

		immediateCleanup() -- equivalent call inferred; original call site unknown
	end)

	if decoding.Value then
		startHighlightSession()
	end

	connections[2] = instance2.AncestryChanged:Connect(function(_, parent)
		if not parent then
			for _, connection in ipairs(connections) do
				if connection then
					connection:Disconnect()
				end
			end

			immediateCleanup() -- equivalent call inferred; original call site unknown
		end
	end)
	connections[3] = instance.AncestryChanged:Connect(function(_, parent)
		if not parent then
			for _, connection in ipairs(connections) do
				if connection then
					connection:Disconnect()
				end
			end

			immediateCleanup() -- equivalent call inferred; original call site unknown
		end
	end)
end

return PartyPopperEffects