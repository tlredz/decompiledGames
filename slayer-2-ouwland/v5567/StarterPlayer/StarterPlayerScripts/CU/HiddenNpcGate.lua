local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local child = ReplicatedStorage.Player_Service.Values:WaitForChild(Players.LocalPlayer.Name)
local folder = Instance.new("Folder")
local parents = {}
local v = {}
local v2 = {}
local transparencies = {}
local v3 = {}

local function facesOf(object)
	local result = {}

	for _, v4 in object:QueryDescendants("BasePart:not([$SetTransparency]),Decal:not([$SetTransparency])") do
		if transparencies[v4] == nil then
			transparencies[v4] = v4.Transparency
		end

		table.insert(result, v4)
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function write(items, p: number)
	for _, item in items do
		local v4 = transparencies[item]
		item.Transparency = v4 + (1 - v4) * p
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setAlpha(p, p2: number)
	v2[p] = p2
	write(facesOf(p), p2) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function suppress(object, flag: boolean)
	for _, v4 in object:QueryDescendants("ProximityPrompt,BillboardGui") do
		if flag then
			if v3[v4] == nil then
				v3[v4] = v4.Enabled
				v4.Enabled = false
			end
		elseif v3[v4] ~= nil then
			v4.Enabled = v3[v4]
			v3[v4] = nil
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelFade(p)
	local v4 = v[p]

	if v4 ~= nil then
		v4.conn:Disconnect()
		v[p] = nil
	end
end

local function fadeTo(instance, target: number, callback)
	cancelFade(instance) -- equivalent call inferred; original call site unknown
	local v4 = v2[instance] or 0
	local v5 = math.abs(target - v4)

	if v5 <= 0.01 then
		setAlpha(instance, target) -- equivalent call inferred; original call site unknown

		if callback then
			callback()
		end
	else
		local v6 = facesOf(instance)
		local lastTime = os.clock()
		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local v7 = math.clamp((os.clock() - lastTime) / (v5 * 0.5), 0, 1)
			local v8 = v7 * v7 * (3 - v7 * 2)
			v2[instance] = v4 + (target - v4) * v8
			write(v6, v2[instance]) -- equivalent call inferred; original call site unknown

			if v7 >= 1 then
				renderSteppedConnection:Disconnect()
				v[instance] = nil

				if callback then
					callback()
				end
			end
		end)
		v[instance] = {
			conn = renderSteppedConnection,
			target = target
		}
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function park(object)
	if object.Parent ~= nil and object.Parent ~= folder then
		parents[object] = object.Parent
		object.Parent = folder
		setAlpha(object, 0) -- equivalent call inferred; original call site unknown
	end

	suppress(object, false) -- equivalent call inferred; original call site unknown
end

local function apply(instance, flag: boolean?)
	local child2 = child:FindFirstChild("HiddenNpc_" .. instance.Name)
	local v4

	if child2 == nil then
		v4 = false
	else
		v4 = child2.Value == true
	end

	if CollectionService:HasTag(instance, "HideableNpc") then
		v4 = not v4
	end

	local v5 = v[instance]
	local v6

	if v5 == nil then
		v6 = false
	else
		v6 = v5.target == 1
	end

	if instance.Parent == folder then
		if not v4 then
			return
		end

		instance.Parent = parents[instance]

		if flag then
			setAlpha(instance, 0) -- equivalent call inferred; original call site unknown
		else
			setAlpha(instance, 1) -- equivalent call inferred; original call site unknown
			suppress(instance, true) -- equivalent call inferred; original call site unknown
			fadeTo(instance, 0, function()
				suppress(instance, false) -- equivalent call inferred; original call site unknown
			end)
		end
	elseif v4 then
		if v6 then
			fadeTo(instance, 0, function()
				suppress(instance, false) -- equivalent call inferred; original call site unknown
			end)
		end
	elseif instance.Parent ~= nil and not v6 then
		if flag then
			cancelFade(instance)
			park(instance) -- equivalent call inferred; original call site unknown
		else
			suppress(instance, true) -- equivalent call inferred; original call site unknown
			fadeTo(instance, 1, function()
				park(instance) -- equivalent call inferred; original call site unknown
			end)
		end
	end
end

local v4 = {}

local function track(instance)
	if not v4[instance] then
		if instance:IsDescendantOf(ReplicatedStorage) then
			return
		end

		v4[instance] = true
		instance:GetPropertyChangedSignal("Parent"):Connect(function()
			apply(instance, true)
		end)
	end

	apply(instance, true)
end

for _, tag in { "HiddenNpc", "HideableNpc" } do
	for _, v5 in CollectionService:GetTagged(tag) do
		track(v5)
	end

	CollectionService:GetInstanceAddedSignal(tag):Connect(track)
end

CollectionService:GetInstanceAddedSignal("FadeInOnSpawn"):Connect(function(instance)
	if instance:IsDescendantOf(ReplicatedStorage) then
		return
	end

	setAlpha(instance, 1) -- equivalent call inferred; original call site unknown
	fadeTo(instance, 0)
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function refresh()
	for k in v4 do
		apply(k)
	end
end

child.ChildAdded:Connect(function(child2)
	if child2.Name:sub(1, 10) ~= "HiddenNpc_" then
		return
	end

	child2.Changed:Connect(refresh)
	refresh() -- equivalent call inferred; original call site unknown
end)
child.ChildRemoved:Connect(function(child2)
	if child2.Name:sub(1, 10) ~= "HiddenNpc_" then
		return
	end

	task.defer(refresh)
end)

for _, child2 in child:GetChildren() do
	if child2.Name:sub(1, 10) == "HiddenNpc_" then
		child2.Changed:Connect(refresh)
	end
end