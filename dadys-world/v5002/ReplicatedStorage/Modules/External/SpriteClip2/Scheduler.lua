local Scheduler = {}
local parent = script:FindFirstChild("PreRenderSignals")
local parent2 = script:FindFirstChild("OnRenderSignals")
local parent3 = script:FindFirstChild("PostRenderSignals")

if not parent2 then
	parent = Instance.new("Folder")
	parent.Name = "PreRenderSignals"
	parent.Parent = script
	parent2 = Instance.new("Folder")
	parent2.Name = "OnRenderSignals"
	parent2.Parent = script
	parent3 = Instance.new("Folder")
	parent3.Name = "OnRenderSignals"
	parent3.Parent = script
end

function Scheduler.GetSignal(_, p: number)
	return Scheduler:GetOnRenderSignal(p)
end

function Scheduler.GetPreRenderSignal(_, p: number)
	local name = tostring(p)
	local v5 = parent:FindFirstChild(name)

	if not v5 then
		v5 = Instance.new("BindableEvent")
		v5.Name = name
		v5.Parent = parent
	end

	return v5.Event
end

function Scheduler:GetOnRenderSignal(p: number)
	local name = tostring(p)
	local v5 = parent2:FindFirstChild(name)

	if not v5 then
		v5 = Instance.new("BindableEvent")
		v5.Name = name
		v5.Parent = parent2
	end

	return v5.Event
end

function Scheduler.GetPostRenderSignal(_, p: number)
	local name = tostring(p)
	local v5 = parent3:FindFirstChild(name)

	if not v5 then
		v5 = Instance.new("BindableEvent")
		v5.Name = name
		v5.Parent = parent3
	end

	return v5.Event
end

function Scheduler.Pause(_)
	script.__bind_Pause:Invoke()
end

function Scheduler.Resume(_)
	script.__bind_Resume:Invoke()
end

function Scheduler.IsPaused(_)
	return (script:GetAttribute("IsPaused"))
end

if script:GetAttribute("paracheck") ~= nil then
	return Scheduler
end

local now = os.clock()
local v4 = {}
local v5 = {}
local v6 = {}
local nows = {}
local v7 = {}
local flag = false
script:SetAttribute("IsPaused", false)
local bindableFunction = Instance.new("BindableFunction")
bindableFunction.Name = "__bind_Pause"
bindableFunction.Parent = script

function bindableFunction.OnInvoke()
	flag = true
	script:SetAttribute("IsPaused", true)
end

local bindableFunction2 = Instance.new("BindableFunction")
bindableFunction2.Name = "__bind_Resume"
bindableFunction2.Parent = script

function bindableFunction2.OnInvoke()
	flag = false
	script:SetAttribute("IsPaused", false)
end

local function LoadGroup(instance)
	if instance.Parent == parent2 then
		local name = instance.Name
		v5[name] = instance
		local v8 = 1 / tonumber(name)
		nows[name] = os.clock()
		v7[name] = v8
	elseif instance.Parent == parent3 then
		local name = instance.Name
		v6[name] = instance
	else
		local name = instance.Name
		v4[name] = instance
	end
end

for _, child in ipairs(parent:GetChildren()) do
	if child.Parent == parent2 then
		local name = child.Name
		v5[name] = child
		local v8 = 1 / tonumber(name)
		nows[name] = os.clock()
		v7[name] = v8
	elseif child.Parent == parent3 then
		v6[child.Name] = child
	else
		v4[child.Name] = child
	end
end

for _, child in ipairs(parent2:GetChildren()) do
	if child.Parent == parent2 then
		local name = child.Name
		v5[name] = child
		local v8 = 1 / tonumber(name)
		nows[name] = os.clock()
		v7[name] = v8
	elseif child.Parent == parent3 then
		v6[child.Name] = child
	else
		v4[child.Name] = child
	end
end

for _, child in ipairs(parent3:GetChildren()) do
	if child.Parent == parent2 then
		local name = child.Name
		v5[name] = child
		local v8 = 1 / tonumber(name)
		nows[name] = os.clock()
		v7[name] = v8
	elseif child.Parent == parent3 then
		v6[child.Name] = child
	else
		v4[child.Name] = child
	end
end

parent.ChildAdded:Connect(LoadGroup)
parent2.ChildAdded:Connect(LoadGroup)
parent3.ChildAdded:Connect(LoadGroup)
local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function(dt)
	now += dt

	if flag then
		return
	end

	local v8 = {}

	for k, _ in pairs(v5) do
		local v9 = nows[k]
		local v10 = v7[k]

		if now - v9 < v10 then
			continue
		end

		nows[k] = now
		table.insert(v8, k)
		local v11 = v4[k]

		if v11 then
			v11:Fire(v10)
		end
	end

	for _, v9 in ipairs(v8) do
		v5[v9]:Fire(v7[v9])
	end

	for _, v9 in ipairs(v8) do
		local v10 = v6[v9]

		if v10 then
			v10:Fire(v7[v9])
		end
	end
end)
return Scheduler