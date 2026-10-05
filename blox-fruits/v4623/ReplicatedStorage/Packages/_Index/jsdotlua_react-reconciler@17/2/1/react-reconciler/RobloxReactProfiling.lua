local shared = require(script.Parent.Parent:WaitForChild("shared"))
local getComponentName = shared.getComponentName
local ReactWorkTags = require(script.Parent:WaitForChild("ReactWorkTags"))
require(script.Parent:WaitForChild("ReactInternalTypes"))
local __REACT_MICROPROFILER_LEVEL = _G.__REACT_MICROPROFILER_LEVEL or 0
local flag = false
local v = nil

function startTimerSampling(callback)
	if flag then
		warn("RobloxReactProfiling Timer Sampling already running.")
	end

	flag = true
	v = callback
end

function endTimerSampling()
	flag = false
	v = nil
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

		if v then
			v(p)
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

	local v2 = {
		id = name,
		startTime = 0,
		endTime = 0
	}
	startTimer(v2)
	debug.profilebegin(name)
	return v2
end

function profileRootAfterYielding(p)
	if p then
		endTimer(p)
		debug.profileend()
	end
end

function profileUnitOfWorkBefore(data)
	local componentName = getComponentName(data.type)

	if data.key then
		componentName = tostring(data.key) .. "=" .. (componentName or "?")
	end

	local v2 = nil

	if data.stateNode and (data.tag == ReactWorkTags.HostComponent or data.tag == ReactWorkTags.HostText) then
		local layerCollector = data.stateNode:FindFirstAncestorWhichIsA("LayerCollector")

		if layerCollector then
			v2 = "[" .. layerCollector:GetFullName() .. "] "
		end
	end

	if v2 then
		componentName = v2 .. " : " .. (componentName or "?")
	end

	if componentName == nil then
		return false
	end

	debug.profilebegin(componentName)
	return true
end

function profileUnitOfWorkAfter(flag2: boolean)
	if flag2 then
		debug.profileend()
	end
end

function profileCommitBefore()
	debug.profilebegin("Commit")
end

function profileCommitAfter()
	debug.profileend()
end

function noop(...) end

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

if __REACT_MICROPROFILER_LEVEL >= 1 then
	profileRootBeforeUnitOfWork2 = profileRootBeforeUnitOfWork
else
	profileRootBeforeUnitOfWork2 = noop
end

RobloxReactProfiling.profileRootBeforeUnitOfWork = profileRootBeforeUnitOfWork2
local profileRootAfterYielding2

if __REACT_MICROPROFILER_LEVEL >= 1 then
	profileRootAfterYielding2 = profileRootAfterYielding
else
	profileRootAfterYielding2 = noop
end

RobloxReactProfiling.profileRootAfterYielding = profileRootAfterYielding2
local profileUnitOfWorkBefore2

if __REACT_MICROPROFILER_LEVEL >= 10 then
	profileUnitOfWorkBefore2 = profileUnitOfWorkBefore
else
	profileUnitOfWorkBefore2 = noop
end

RobloxReactProfiling.profileUnitOfWorkBefore = profileUnitOfWorkBefore2
local profileUnitOfWorkAfter2

if __REACT_MICROPROFILER_LEVEL >= 10 then
	profileUnitOfWorkAfter2 = profileUnitOfWorkAfter
else
	profileUnitOfWorkAfter2 = noop
end

RobloxReactProfiling.profileUnitOfWorkAfter = profileUnitOfWorkAfter2
local profileCommitBefore2

if __REACT_MICROPROFILER_LEVEL >= 1 then
	profileCommitBefore2 = profileCommitBefore
else
	profileCommitBefore2 = noop
end

RobloxReactProfiling.profileCommitBefore = profileCommitBefore2
local profileCommitAfter2

if __REACT_MICROPROFILER_LEVEL >= 1 then
	profileCommitAfter2 = profileCommitAfter
else
	profileCommitAfter2 = noop
end

RobloxReactProfiling.profileCommitAfter = profileCommitAfter2
return RobloxReactProfiling