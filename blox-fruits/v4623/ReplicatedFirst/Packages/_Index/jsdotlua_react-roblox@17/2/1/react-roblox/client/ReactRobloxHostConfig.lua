local function unimplemented(p: string)
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("UNIMPLEMENTED ERROR: " .. tostring(p))
	error("FIXME (roblox): " .. p .. " is unimplemented", 2)
end

local CollectionService = game:GetService("CollectionService")
local luaupolyfill = require(script.Parent.Parent.Parent:WaitForChild("luau-polyfill"))
local inspect = luaupolyfill.util.inspect
local shared = require(script.Parent.Parent.Parent:WaitForChild("shared"))
local console = shared.console
local object = luaupolyfill.Object
local setTimeout = luaupolyfill.setTimeout
local clearTimeout = luaupolyfill.clearTimeout
require(script.Parent:WaitForChild("ReactRobloxHostTypes.roblox"))
local ReactRobloxComponentTree = require(script.Parent:WaitForChild("ReactRobloxComponentTree"))
local precacheFiberNode = ReactRobloxComponentTree.precacheFiberNode
local uncacheFiberNode = ReactRobloxComponentTree.uncacheFiberNode
local updateFiberProps = ReactRobloxComponentTree.updateFiberProps
local ReactRobloxComponent = require(script.Parent:WaitForChild("ReactRobloxComponent"))
local setInitialProperties = ReactRobloxComponent.setInitialProperties
local diffProperties = ReactRobloxComponent.diffProperties
local updateProperties = ReactRobloxComponent.updateProperties
local cleanupHostComponent = ReactRobloxComponent.cleanupHostComponent
local shared2 = require(script.Parent.Parent.Parent:WaitForChild("shared"))
local enableCreateEventHandleAPI = shared2.ReactFeatureFlags.enableCreateEventHandleAPI

-- equivalent calls inferred from this helper; original call sites unknown
local function recursivelyUncacheFiberNode(folder)
	if typeof(folder) ~= "Instance" then
		return
	end

	uncacheFiberNode(folder)

	for _, descendant in folder:GetDescendants() do
		uncacheFiberNode(descendant)
	end
end

local ReactRobloxHostConfig = {}
local assign = object.assign
local shared3 = require(script.Parent.Parent.Parent:WaitForChild("shared"))
assign(ReactRobloxHostConfig, shared3.ReactFiberHostConfig.WithNoPersistence)

function ReactRobloxHostConfig.getRootHostContext(instance)
	return instance.ClassName
end

function ReactRobloxHostConfig.getChildHostContext(p, _: string, _)
	return p
end

function ReactRobloxHostConfig.getPublicInstance(p)
	return p
end

function ReactRobloxHostConfig.prepareForCommit(_)
	if not enableCreateEventHandleAPI then
		return nil
	end

	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("UNIMPLEMENTED ERROR: " .. tostring("enableCreateEventHandleAPI"))
	error("FIXME (roblox): enableCreateEventHandleAPI is unimplemented", 2)
	return nil
end

function ReactRobloxHostConfig.beforeActiveInstanceBlur()
	if enableCreateEventHandleAPI then
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		print("UNIMPLEMENTED ERROR: " .. tostring("enableCreateEventHandleAPI"))
		error("FIXME (roblox): enableCreateEventHandleAPI is unimplemented", 2)
	end
end

function ReactRobloxHostConfig.afterActiveInstanceBlur()
	if enableCreateEventHandleAPI then
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		print("UNIMPLEMENTED ERROR: " .. tostring("enableCreateEventHandleAPI"))
		error("FIXME (roblox): enableCreateEventHandleAPI is unimplemented", 2)
	end
end

function ReactRobloxHostConfig.resetAfterCommit(_) end

function ReactRobloxHostConfig.createInstance(className: string, p, _, _, p2)
	local instance = Instance.new(className)

	if p2.key then
		instance.Name = p2.key
	else
		local return_ = p2.return_

		while return_ do
			if return_.key then
				instance.Name = return_.key
				break
			else
				return_ = return_.return_
			end
		end
	end

	precacheFiberNode(p2, instance)
	updateFiberProps(instance, p)
	return instance
end

function ReactRobloxHostConfig.appendInitialChild(parent, p)
	p.Parent = parent
end

function ReactRobloxHostConfig.finalizeInitialChildren(p, p2: string, p3, p4, _)
	setInitialProperties(p, p2, p3, p4)
	return false
end

function ReactRobloxHostConfig.prepareUpdate(p, p2: string, p3, p4, p5, _)
	return diffProperties(p, p2, p3, p4, p5)
end

function ReactRobloxHostConfig.shouldSetTextContent(_: string, _)
	return false
end

function ReactRobloxHostConfig.createTextInstance(_: string, _, _, _)
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("UNIMPLEMENTED ERROR: " .. tostring("createTextInstance"))
	error("FIXME (roblox): createTextInstance is unimplemented", 2)
	return nil
end

ReactRobloxHostConfig.isPrimaryRenderer = true
ReactRobloxHostConfig.warnsIfNotActing = true
ReactRobloxHostConfig.scheduleTimeout = setTimeout
ReactRobloxHostConfig.cancelTimeout = clearTimeout
ReactRobloxHostConfig.noTimeout = -1
ReactRobloxHostConfig.supportsMutation = true

function ReactRobloxHostConfig.commitMount(_, _: string, _, _)
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("UNIMPLEMENTED ERROR: " .. tostring("commitMount"))
	error("FIXME (roblox): commitMount is unimplemented", 2)
end

function ReactRobloxHostConfig.commitUpdate(p, p2, _: string, p3, p4, _)
	updateFiberProps(p, p4)
	updateProperties(p, p2, p3)
end

local function checkTags(instance)
	if typeof(instance) ~= "Instance" then
		console.warn("Could not check tags on non-instance %s.", inspect(instance))
	elseif not instance:IsDescendantOf(game) and #CollectionService:GetTags(instance) > 0 then
		console.warn(
			"Tags applied to orphaned %s \"%s\" cannot be accessed via CollectionService:GetTagged. If you're relying on tag behavior in a unit test, consider mounting your test root into the DataModel.",
			instance.ClassName,
			instance.Name
		)
	end
end

function ReactRobloxHostConfig.appendChild(parent, p)
	p.Parent = parent

	if _G.__DEV__ then
		checkTags(p)
	end
end

function ReactRobloxHostConfig.appendChildToContainer(p, p2)
	ReactRobloxHostConfig.appendChild(p, p2)
end

function ReactRobloxHostConfig.insertBefore(parent, p, _)
	p.Parent = parent

	if _G.__DEV__ then
		checkTags(p)
	end
end

function ReactRobloxHostConfig.insertInContainerBefore(p, p2, p3)
	ReactRobloxHostConfig.insertBefore(p, p2, p3)
end

function ReactRobloxHostConfig.removeChild(_, instance)
	recursivelyUncacheFiberNode(instance) -- equivalent call inferred; original call site unknown
	cleanupHostComponent(instance)
	instance.Parent = nil
	instance:Destroy()
end

function ReactRobloxHostConfig.removeChildFromContainer(p, p2)
	ReactRobloxHostConfig.removeChild(p, p2)
end

function ReactRobloxHostConfig.clearSuspenseBoundary(_, _)
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("UNIMPLEMENTED ERROR: " .. tostring("clearSuspenseBoundary"))
	error("FIXME (roblox): clearSuspenseBoundary is unimplemented", 2)
end

function ReactRobloxHostConfig.clearSuspenseBoundaryFromContainer(_, _)
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("UNIMPLEMENTED ERROR: " .. tostring("clearSuspenseBoundaryFromContainer"))
	error("FIXME (roblox): clearSuspenseBoundaryFromContainer is unimplemented", 2)
end

function ReactRobloxHostConfig.hideInstance(_)
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("UNIMPLEMENTED ERROR: " .. tostring("hideInstance"))
	error("FIXME (roblox): hideInstance is unimplemented", 2)
end

function ReactRobloxHostConfig.hideTextInstance(_)
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("UNIMPLEMENTED ERROR: " .. tostring("hideTextInstance"))
	error("FIXME (roblox): hideTextInstance is unimplemented", 2)
end

function ReactRobloxHostConfig.unhideInstance(_, _)
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("UNIMPLEMENTED ERROR: " .. tostring("unhideInstance"))
	error("FIXME (roblox): unhideInstance is unimplemented", 2)
end

function ReactRobloxHostConfig.unhideTextInstance(_, _: string)
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("UNIMPLEMENTED ERROR: " .. tostring("unhideTextInstance"))
	error("FIXME (roblox): unhideTextInstance is unimplemented", 2)
end

function ReactRobloxHostConfig.clearContainer(instance)
	for _, child in instance:GetChildren() do
		ReactRobloxHostConfig.removeChild(instance, child)
	end
end

function ReactRobloxHostConfig.preparePortalMount(_) end

return ReactRobloxHostConfig