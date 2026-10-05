local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
require(ReplicatedStorage.Util)
local Global = require(ReplicatedStorage.Global)
local Notification = require(ReplicatedStorage.Notification)
local NotifierList = require(script.NotifierList)
require(script.Types)
local v = {
	Fruit = true,
	Egg = true
}
local v2 = {
	sources = {},
	root = nil,
	rootHost = nil,
	mountTarget = nil,
	radarConnection = nil,
	mountConnection = nil,
	stepThread = nil,
	running = false,
	eggEnabled = false,
	fruitModel = nil,
	fruitPosition = nil,
	fruitSpawnTime = nil
}
local v3 = {}
local FruitNotifier = {}

function v3:setText(currentText: string)
	if self.currentText == currentText then
		return
	end

	self.currentText = currentText
	self.setText(currentText)
end

function v3:setVisible(currentVisible: boolean)
	if self.currentVisible == currentVisible then
		return
	end

	self.currentVisible = currentVisible
	self.setVisible(currentVisible)
end

function v3.createSource(id: string, kind, layoutOrder: number, udim: UDim2)
	local binding, setText = React.createBinding("")
	local binding2, setVisible = React.createBinding(false)
	return {
		id = id,
		kind = kind,
		text = binding,
		setText = setText,
		visible = binding2,
		setVisible = setVisible,
		currentText = "",
		currentVisible = false,
		layoutOrder = layoutOrder,
		size = udim,
		position = nil,
		formatText = nil
	}
end

function v3.ensureSource(p: string, p2, p3: number, udim: UDim2)
	local source = v2.sources[p]

	if source then
		return source
	end

	local source2 = v3.createSource(p, p2, p3, udim)
	v2.sources[p] = source2
	return source2
end

function v3.ensureBuiltInSources()
	v3.ensureSource("Fruit", "BuiltIn", 96, UDim2.fromScale(1, 1))
	v3.ensureSource("Egg", "BuiltIn", 96.1, UDim2.fromScale(0.75, 0.75))
end

function v3.getSourceSnapshots()
	local result = {}

	for _, source in v2.sources do
		table.insert(result, {
			id = source.id,
			text = source.text,
			visible = source.visible,
			layoutOrder = source.layoutOrder,
			size = source.size
		})
	end

	table.sort(result, function(a, b)
		if a.layoutOrder == b.layoutOrder then
			return a.id < b.id
		end

		return a.layoutOrder < b.layoutOrder
	end)
	return result
end

function v3.renderSources()
	local root = v2.root
	local mountTarget = v2.mountTarget

	if root and mountTarget then
		root:render(ReactRoblox.createPortal(React.createElement(NotifierList, {
			sources = v3.getSourceSnapshots()
		}), mountTarget))
	end
end

function v3.getCharacterRootParts()
	local character = Players.LocalPlayer.Character

	if not character then
		return nil, nil
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	local v4

	if humanoid and humanoid.Health > 0 then
		v4 = humanoidRootPart
	end

	return humanoidRootPart, v4
end

function v3.updateFruit(p)
	local fruitModel = v2.fruitModel

	if not fruitModel then
		return
	end

	local fruit = v2.sources.Fruit

	if fruitModel:IsDescendantOf(workspace) then
		local fruitPosition = v2.fruitPosition
		local fruitSpawnTime = v2.fruitSpawnTime

		if not (fruitPosition and fruitSpawnTime and p) then
			return
		end

		local magnitude = (fruitPosition - p.Position).Magnitude
		local v4 = magnitude / 40 * ((0.8 + math.random() * 0.2) * math.max(1 - (tick() - fruitSpawnTime) * 0.2, 0))
		local v5 = math.floor(magnitude / 10 + v4)
		v3.setText(fruit, "FRUIT DETECTED: " .. v5 .. "m away." .. (v4 > 0 and " (Calibrating...)" or ""))
		v3.setVisible(fruit, true)
	else
		v2.fruitModel = nil
		v2.fruitPosition = nil
		v2.fruitSpawnTime = nil
		v3.setVisible(fruit, false)
		Notification.new("Blox Fruit despawned."):Display()
	end
end

function v3.updateEgg(p)
	if not v2.eggEnabled then
		return
	end

	local egg = v2.sources.Egg
	local v4 = false

	if p then
		for _, child in workspace:GetChildren() do
			local _PrimaryPart

			if child.Name == "" then
				_PrimaryPart = child:FindFirstChild("_PrimaryPart")
			end

			if not (_PrimaryPart and (_PrimaryPart.Position - p.Position).Magnitude < 250) then
				continue
			end

			v3.setText(egg, "EGG DETECTED NEARBY!")
			v3.setVisible(egg, true)
			v4 = true
			break
		end
	end

	if not v4 then
		v3.setVisible(egg, false)
	end
end

function v3.updateDistanceSources(p)
	for k, source in v2.sources do
		if v[k] or source.kind ~= "Distance" then
			continue
		end

		local position = source.position
		local formatText = source.formatText

		if p and position and formatText then
			local v4 = math.floor((position - p.Position).Magnitude / 10)
			v3.setText(source, formatText(v4))
			v3.setVisible(source, true)
		else
			v3.setVisible(source, false)
		end
	end
end

function v3.update()
	local characterRootParts, v4 = v3.getCharacterRootParts()
	v3.updateFruit(v4)
	v3.updateEgg(characterRootParts)
	v3.updateDistanceSources(v4)
end

function v3.handleRadarNotify(p, fruitPosition: Vector3?)
	if p == "Enabled" then
		v2.eggEnabled = true
		return
	end

	v2.fruitModel = Global.Encode(p)
	v2.fruitPosition = fruitPosition
	v2.fruitSpawnTime = tick()
	Notification.new("<Color=Green>A BLOX FRUIT HAS SPAWNED IN THE GAME!<Color=/>"):Display()
	Notification.new("Radar activated."):Display()
end

function v3.runUpdates()
	while v2.running and not Global.NPCReady do
		task.wait()
	end

	if not v2.running then
		return
	end

	task.wait(3)

	while v2.running do
		v3.update()
		task.wait(0.2)
	end
end

function v3.stopRuntime()
	v2.running = false

	if v2.stepThread then
		pcall(task.cancel, v2.stepThread)
		v2.stepThread = nil
	end

	if v2.radarConnection then
		v2.radarConnection:Disconnect()
		v2.radarConnection = nil
	end

	if v2.mountConnection then
		v2.mountConnection:Disconnect()
		v2.mountConnection = nil
	end

	if v2.root then
		pcall(function()
			v2.root:unmount()
		end)
		v2.root = nil
	end

	if v2.rootHost then
		v2.rootHost:Destroy()
		v2.rootHost = nil
	end

	v2.mountTarget = nil
end

function FruitNotifier.mount(instance)
	if v2.root and v2.mountTarget == instance and v2.rootHost and v2.rootHost.Parent then
		return
	end

	v3.stopRuntime()
	v3.ensureBuiltInSources()
	local radar = instance:FindFirstChild("Radar")

	if radar then
		radar:Destroy()
	end

	local eggRadar = instance:FindFirstChild("EggRadar")

	if eggRadar then
		eggRadar:Destroy()
	end

	local folder = Instance.new("Folder")
	folder.Name = "FruitNotifierReactRoot"
	folder.Parent = instance
	v2.rootHost = folder
	v2.mountTarget = instance
	v2.root = ReactRoblox.createRoot(folder)
	v3.renderSources()
	v2.radarConnection = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RadarNotify").OnClientEvent:Connect(v3.handleRadarNotify)
	v2.mountConnection = instance.Destroying:Connect(v3.stopRuntime)
	v2.running = true
	v2.stepThread = task.defer(v3.runUpdates)
end

function FruitNotifier.setDistanceSource(p: string, data)
	assert(p ~= "", "FruitNotifier sourceId must not be empty")
	assert(not v[p], (`FruitNotifier source "{p}" is reserved`))
	local layoutOrder = data.layoutOrder or 96.2
	local size = data.size or UDim2.fromScale(1, 1)
	local source = v2.sources[p]
	local v4 = source == nil

	if source then
		if source.layoutOrder ~= layoutOrder or source.size ~= size then
			v4 = true
		end
	else
		source = v3.createSource(p, "Distance", layoutOrder, size)
		v2.sources[p] = source
	end

	source.kind = "Distance"
	source.position = data.position
	source.formatText = data.formatText
	source.layoutOrder = layoutOrder
	source.size = size

	if v4 then
		v3.renderSources()
	end
end

function FruitNotifier.clearSource(p: string)
	assert(not v[p], (`FruitNotifier source "{p}" is reserved`))

	if not v2.sources[p] then
		return
	end

	v2.sources[p] = nil
	v3.renderSources()
end

function FruitNotifier.destroy()
	v3.stopRuntime()
	table.clear(v2.sources)
	v2.eggEnabled = false
	v2.fruitModel = nil
	v2.fruitPosition = nil
	v2.fruitSpawnTime = nil
end

return FruitNotifier