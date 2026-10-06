local SoundService = game:GetService("SoundService")
local DuelAudioController = {}
DuelAudioController.__index = DuelAudioController
local object = setmetatable({}, {
	__mode = "k"
})
local object2 = setmetatable({}, {
	__mode = "k"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function assign(p, p2)
	if object2[p] then
		object2[p].assigned = p2
	else
		object2[p] = {
			group = p.SoundGroup,
			assigned = p2
		}
	end

	p.SoundGroup = p2
end

function DuelAudioController.prepare(p)
	local parent = p

	while parent do
		local v = object[parent]

		if v then
			assign(p, v) -- equivalent call inferred; original call site unknown
			break
		else
			parent = parent.Parent
		end
	end
end

function DuelAudioController.bindRoot(sound, instance)
	if not (instance and object[sound] ~= instance) then
		return
	end

	assert(object[sound] == nil, "战斗音效根节点不能重复归属")
	object[sound] = instance

	local function bind(sound2)
		if sound2:IsA("Sound") then
			assign(sound2, instance) -- equivalent call inferred; original call site unknown
		end
	end

	if sound:IsA("Sound") then
		assign(sound, instance) -- equivalent call inferred; original call site unknown
	end

	for _, sound2 in sound:GetDescendants() do
		if not sound2:IsA("Sound") then
			continue
		end

		assign(sound2, instance) -- equivalent call inferred; original call site unknown
	end

	local descendantAddedConnection = sound.DescendantAdded:Connect(bind)
	local destroyingConnection = nil
	local destroyingConnection2 = nil

	local function cleanup()
		object[sound] = nil
		descendantAddedConnection:Disconnect()

		if destroyingConnection then
			destroyingConnection:Disconnect()
		end

		if destroyingConnection2 then
			destroyingConnection2:Disconnect()
		end
	end

	destroyingConnection = sound.Destroying:Connect(cleanup)
	destroyingConnection2 = instance.Destroying:Connect(cleanup)
end

function DuelAudioController.new()
	return (setmetatable({
		groups = {},
		tableConnections = {},
		localSeatedTable = nil,
		destroyed = false
	}, DuelAudioController))
end

function DuelAudioController:setSeatedTable(localSeatedTable)
	if self.destroyed then
		return
	end

	self.localSeatedTable = localSeatedTable

	for k, group in self.groups do
		group.Volume = (localSeatedTable == nil or k == localSeatedTable) and 1 or 0
	end
end

function DuelAudioController:getGroup(instance)
	local group = self.groups[instance]

	if group then
		return group
	end

	assert(not self.destroyed, "DuelAudioController 已销毁")
	local soundGroup = Instance.new("SoundGroup")
	soundGroup.Name = "DuelAudio_" .. tostring(instance:GetAttribute("DuelTableId") or instance.Name)
	soundGroup.Volume = (self.localSeatedTable == nil or self.localSeatedTable == instance) and 1 or 0
	soundGroup.Parent = SoundService
	self.groups[instance] = soundGroup
	self.tableConnections[instance] = instance.Destroying:Connect(function()
		if self.localSeatedTable == instance then
			self:setSeatedTable(nil)
		end

		local tableConnection = self.tableConnections[instance]

		if tableConnection then
			tableConnection:Disconnect()
		end

		self.tableConnections[instance] = nil
	end)
	return soundGroup
end

function DuelAudioController:destroy()
	if self.destroyed then
		return
	end

	self:setSeatedTable(nil)
	self.destroyed = true
	local v = {}

	for _, group in self.groups do
		v[group] = true
	end

	for k, v2 in object2 do
		if not v[v2.assigned] then
			continue
		end

		if k.SoundGroup == v2.assigned then
			k.SoundGroup = v2.group
		end

		object2[k] = nil
	end

	for _, tableConnection in self.tableConnections do
		tableConnection:Disconnect()
	end

	for _, group in self.groups do
		group:Destroy()
	end

	table.clear(self.tableConnections)
	table.clear(self.groups)
end

return DuelAudioController