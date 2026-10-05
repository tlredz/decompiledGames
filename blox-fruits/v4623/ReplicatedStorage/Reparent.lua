local Reparent = {}
local RunService = game:GetService("RunService")
local v = {
	TouchTransmitter = true
}
local v2 = {
	Script = true,
	LocalScript = true
}
local count = 0
local renderStepped = RunService.RenderStepped
local generateInstanceMap

generateInstanceMap = function(model)
	local children = model:GetChildren()

	for k, v3 in children do
		if v[v3.ClassName] then
			children[k] = nil
		else
			children[k] = generateInstanceMap(v3)
		end
	end

	return {
		Root = model,
		RootParent = model.Parent,
		Children = children,
		ClassName = model.ClassName,
		PrimaryPart = model:IsA("Model") and model.PrimaryPart or nil
	}
end

local function getFrameTime(value)
	if type(value) == "number" then
		return value, false
	end

	return value(), true
end

local function setParent(p, parent)
	p.Parent = parent
end

local function setPrimaryPart(p, primaryPart)
	p.PrimaryPart = primaryPart
end

function Reparent.CreateMap(p)
	return (generateInstanceMap(p))
end

function Reparent:Parent(value, callback)
	self.ActionId = count
	local actionId = self.ActionId
	count += 1
	local lastTime = os.clock()
	local v3, flag

	if type(value) == "number" then
		v3 = value
		flag = false
	else
		v3 = value()
		flag = true
	end

	local flag2 = true
	local rootParentsByRoot = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function check()
		local v4 = os.clock() - lastTime

		if v3 <= v4 then
			if flag then
				local v5 = value

				if type(v5) ~= "number" then
					v5 = v5()
				end

				v3 = v5
			end

			renderStepped:Wait()
			lastTime = os.clock()
		end
	end

	local parent

	parent = function(instance)
		if self.ActionId ~= actionId then
			flag2 = false
			return
		end

		if instance.Root.Parent ~= instance.RootParent then
			if v2[instance.ClassName] then
				rootParentsByRoot[instance.Root] = instance.RootParent
			else
				pcall(setParent, instance.Root, instance.RootParent)
			end
		end

		check() -- equivalent call inferred; original call site unknown

		for _, v4 in instance.Children do
			parent(v4)

			if self.ActionId ~= actionId then
				flag2 = false
				return
			end

			if v4.Root.Parent ~= instance.Root then
				pcall(setParent, v4.Root, instance.Root)
			end

			check() -- equivalent call inferred; original call site unknown
		end

		if instance.PrimaryPart ~= nil then
			pcall(setPrimaryPart, instance.Root, instance.PrimaryPart)
		end
	end

	parent(self)

	if flag2 then
		for k, v4 in rootParentsByRoot do
			pcall(setParent, k, v4)
		end
	end

	if callback then
		callback(flag2)
	end
end

function Reparent:Unparent(value, callback)
	self.ActionId = count
	local actionId = self.ActionId
	count += 1
	local lastTime = os.clock()
	local v3, flag

	if type(value) == "number" then
		v3 = value
		flag = false
	else
		v3 = value()
		flag = true
	end

	local flag2 = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function check()
		local v4 = os.clock() - lastTime

		if v3 <= v4 then
			if flag then
				local v5 = value

				if type(v5) ~= "number" then
					v5 = v5()
				end

				v3 = v5
			end

			renderStepped:Wait()
			lastTime = os.clock()
		end
	end

	local unparent

	unparent = function(p2)
		if self.ActionId ~= actionId then
			flag2 = false
			return
		end

		for _, v4 in p2.Children do
			unparent(v4)

			if self.ActionId ~= actionId then
				flag2 = false
				return
			end

			if v4.Root.Parent ~= nil then
				pcall(setParent, v4.Root, nil)
			end

			check() -- equivalent call inferred; original call site unknown
		end

		if p2.Root.Parent ~= nil then
			pcall(setParent, p2.Root, nil)
		end

		check() -- equivalent call inferred; original call site unknown
	end

	unparent(self)

	if callback then
		callback(flag2)
	end
end

return Reparent