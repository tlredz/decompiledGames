local parent = script.Parent.Parent
local Shared = require(parent.Shared)
local getComponentName = Shared.getComponentName
local ReactWorkTags = require(script.Parent.ReactWorkTags)
require(script.Parent.ReactInternalTypes)
local success, result = pcall(function()
	return game:DefineFastInt("ReactMicroprofilerLevel5", 0)
end)
local v = not success and 0 or result

function noop(...) end

local flag = false
local v2 = nil
local v3 = 0

if v >= 5 then
	local RunService = game:GetService("RunService")
	RunService.Heartbeat:Connect(function()
		v3 = 0
	end)
end

local v4

if v >= 5 then
	v4 = {
		profilebegin = function(...)
			debug.profilebegin(...)
			v3 += 1
		end,
		profileend = function()
			if v3 > 0 then
				debug.profileend()
				v3 -= 1
			end
		end
	}
else
	v4 = {
		profilebegin = noop,
		profileend = noop
	}
end

function startTimerSampling(callback)
	if flag then
		warn("RobloxReactProfiling Timer Sampling already running.")
	end

	flag = true
	v2 = callback
end

function endTimerSampling()
	flag = false
	v2 = nil
end

function getFirstStringKey(items)
	for k, _ in items do
		if type(k) == "string" then
			return k
		end
	end

	return nil
end

function startTimer(p)
	if flag then
		p.startTime = os.clock()
	end
end

function endTimer(p)
	if flag then
		p.endTime = os.clock()

		if v2 then
			v2(p)
		end
	end
end

function profileRootBeforeUnitOfWork(p)
	local current = p.current
	local name = nil

	if current then
		if current.memoizedProps then
			name = getFirstStringKey(current.memoizedProps)
		end

		if name == nil and current.stateNode and current.stateNode.containerInfo then
			name = current.stateNode.containerInfo.Name
		end
	end

	if name == "Folder" and current.child then
		local child = current.child
		local name2

		if child.memoizedProps then
			name2 = getFirstStringKey(child.memoizedProps)
		end

		if name2 == nil and child.stateNode and child.stateNode.containerInfo then
			name2 = child.stateNode.containerInfo.Name
		end

		if name2 ~= nil then
			name = name2
		end
	end

	if name == nil then
		return nil
	end

	local v5 = {
		id = name,
		startTime = 0,
		endTime = 0
	}
	startTimer(v5)
	v4.profilebegin(name)
	return v5
end

function profileRootAfterYielding(p)
	if p then
		endTimer(p)
		v4.profileend()
	end
end

function profileUnitOfWorkBefore(data)
	local componentName = getComponentName(data.type)

	if data.key then
		componentName = tostring(data.key) .. "=" .. (componentName or "?")
	end

	local v5 = nil

	if data.stateNode and (data.tag == ReactWorkTags.HostComponent or data.tag == ReactWorkTags.HostText) then
		local layerCollector = data.stateNode:FindFirstAncestorWhichIsA("LayerCollector")

		if layerCollector then
			v5 = "[" .. layerCollector:GetFullName() .. "] "
		end
	end

	if v5 then
		componentName = v5 .. " : " .. (componentName or "?")
	end

	if componentName == nil then
		return false
	end

	v4.profilebegin(componentName)
	return true
end

function profileUnitOfWorkAfter(flag2: boolean)
	if flag2 then
		v4.profileend()
	end
end

function profileCommitBefore()
	v4.profilebegin("Commit")
end

function profileCommitAfter()
	v4.profileend()
end

local RobloxReactProfiling = {
	startTimerSampling = startTimerSampling,
	endTimerSampling = endTimerSampling,
	profileRootBeforeUnitOfWork = 0,
	profileRootAfterYielding = 0,
	profileUnitOfWorkBefore = 0,
	profileUnitOfWorkAfter = 0,
	profileCommitBefore = 0,
	profileCommitAfter = 0
}
local profileRootBeforeUnitOfWork2

if v >= 1 then
	profileRootBeforeUnitOfWork2 = profileRootBeforeUnitOfWork
else
	profileRootBeforeUnitOfWork2 = noop
end

RobloxReactProfiling.profileRootBeforeUnitOfWork = profileRootBeforeUnitOfWork2
local profileRootAfterYielding2

if v >= 1 then
	profileRootAfterYielding2 = profileRootAfterYielding
else
	profileRootAfterYielding2 = noop
end

RobloxReactProfiling.profileRootAfterYielding = profileRootAfterYielding2
local profileUnitOfWorkBefore2

if v >= 10 then
	profileUnitOfWorkBefore2 = profileUnitOfWorkBefore
else
	profileUnitOfWorkBefore2 = noop
end

RobloxReactProfiling.profileUnitOfWorkBefore = profileUnitOfWorkBefore2
local profileUnitOfWorkAfter2

if v >= 10 then
	profileUnitOfWorkAfter2 = profileUnitOfWorkAfter
else
	profileUnitOfWorkAfter2 = noop
end

RobloxReactProfiling.profileUnitOfWorkAfter = profileUnitOfWorkAfter2
local profileCommitBefore2

if v >= 5 then
	profileCommitBefore2 = profileCommitBefore
else
	profileCommitBefore2 = noop
end

RobloxReactProfiling.profileCommitBefore = profileCommitBefore2
local profileCommitAfter2

if v >= 5 then
	profileCommitAfter2 = profileCommitAfter
else
	profileCommitAfter2 = noop
end

RobloxReactProfiling.profileCommitAfter = profileCommitAfter2
return RobloxReactProfiling