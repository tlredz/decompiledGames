local v = {
	Objects = {}
}
v.__index = v
v.Owner = game.Players.LocalPlayer
local modulesByName = {}
local v2 = {}

for _, moduleScript in script:GetChildren() do
	local module = require(moduleScript)
	module.Name = moduleScript.Name
	modulesByName[moduleScript.Name] = module
end

function v.SetupAll()
	for _, v3 in modulesByName do
		table.insert(v2, v3)
	end

	table.sort(v2, function(a, b)
		return a.__loadOrder < b.__loadOrder
	end)

	for _, v3 in v2 do
		v3.__state = v.state
		v3.Setup()
	end
end

function v:Get(p2: string, p3)
	if self.Objects[p2] or p3 then
		return self.Objects[p2]
	end

	local Maid = require(game.ReplicatedStorage.Util.Maid)
	local maid = Maid.new()
	self.Objects[p2] = modulesByName[p2].Construct({
		__maid = maid,
		__state = v.state,
		__components = self,
		Owner = self.Owner,
		observer = self.Owner ~= game.Players.LocalPlayer
	})
	local object = self.Objects[p2]
	maid:GiveTask(function()
		if self.Objects[p2] == object then
			self.Objects[p2] = nil
		end
	end)
	return self.Objects[p2]
end

function v.GetById(_, _: string, _: number) end

function v:Destroy(p2)
	if self.Objects[p2] then
		self.Objects[p2].__maid:Destroy()
		self.Objects[p2] = nil
	end
end

local v3 = {}

function v.Bucket(owner)
	if v3[owner] then
		return v3[owner]
	end

	local v4 = {
		Objects = {}
	}
	setmetatable(v4, v)
	v3[owner] = v4
	v4.Owner = owner
	local ancestryChangedConnection = nil
	ancestryChangedConnection = owner.AncestryChanged:Once(function(_, parent)
		if not parent then
			ancestryChangedConnection:Disconnect()

			for _, object in v4.Objects do
				object.__maid:Destroy()
				object.Destroyed = true
			end

			v4.Objects = {}
		end
	end)
	return v4
end

task.spawn(function()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function onPlayer(p)
		v.Bucket(p):Get("RodController")
	end

	game.Players.PlayerAdded:Connect(onPlayer)

	for _, v4 in game.Players:GetPlayers() do
		onPlayer(v4) -- equivalent call inferred; original call site unknown
	end
end)
return v.Bucket(game.Players.LocalPlayer)