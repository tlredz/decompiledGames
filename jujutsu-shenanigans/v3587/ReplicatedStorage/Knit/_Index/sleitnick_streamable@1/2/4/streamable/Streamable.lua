local Trove = require(script.Parent.Parent.Trove)
local Signal = require(script.Parent.Parent.Signal)
local Streamable = {}
Streamable.__index = Streamable

function Streamable.new(instance, childName: string)
	local v = {}
	setmetatable(v, Streamable)
	v._trove = Trove.new()
	v._shown = v._trove:Construct(Signal)
	v._shownTrove = Trove.new()
	v._trove:Add(v._shownTrove)
	v.Instance = instance:FindFirstChild(childName)

	local function OnInstanceSet()
		local instance2 = v.Instance

		if typeof(instance2) == "Instance" then
			v._shown:Fire(instance2, v._shownTrove)
			v._shownTrove:Connect(instance2:GetPropertyChangedSignal("Parent"), function()
				if not instance2.Parent then
					v._shownTrove:Clean()
				end
			end)
			v._shownTrove:Add(function()
				if v.Instance == instance2 then
					v.Instance = nil
				end
			end)
		end
	end

	local function OnChildAdded(instance2)
		if instance2.Name == childName and not v.Instance then
			v.Instance = instance2
			OnInstanceSet()
		end
	end

	v._trove:Connect(instance.ChildAdded, OnChildAdded)

	if v.Instance then
		OnInstanceSet()
	end

	return v
end

function Streamable.primary(instance)
	local v = {}
	setmetatable(v, Streamable)
	v._trove = Trove.new()
	v._shown = v._trove:Construct(Signal)
	v._shownTrove = Trove.new()
	v._trove:Add(v._shownTrove)
	v.Instance = instance.PrimaryPart

	-- equivalent calls inferred from this helper; original call sites unknown
	local function OnPrimaryPartChanged()
		local primaryPart = instance.PrimaryPart
		v._shownTrove:Clean()
		v.Instance = primaryPart

		if primaryPart then
			v._shown:Fire(primaryPart, v._shownTrove)
		end
	end

	v._trove:Connect(instance:GetPropertyChangedSignal("PrimaryPart"), OnPrimaryPartChanged)

	if v.Instance then
		OnPrimaryPartChanged() -- equivalent call inferred; original call site unknown
	end

	return v
end

function Streamable:Observe(on_shown)
	if self.Instance then
		task.spawn(on_shown, self.Instance, self._shownTrove)
	end

	return self._shown:Connect(on_shown)
end

function Streamable:Destroy()
	self._trove:Destroy()
end

return Streamable