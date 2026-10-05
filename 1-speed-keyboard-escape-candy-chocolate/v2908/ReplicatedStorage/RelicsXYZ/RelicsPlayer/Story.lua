local Story = {}
local parent = script.Parent
local components = parent.Components
local parent2 = parent.Parent
local shared2 = parent2.Shared
local storyCache = shared.StoryCache
local State = require(parent.State)
local React = require(shared2.React)
local ReactRoblox = require(shared2.ReactRoblox)
local hooks = parent.Hooks
require(hooks.useChild)
require(hooks.useTagged)

if not storyCache then
	storyCache = {}
	shared.StoryCache = storyCache
end

local class = {}
class.__index = class
require(parent2)
local require2 = require

function class.AddCallback(p, p2: string, callback)
	p.callbacks[p2] = callback
end

function class.__call(data, instance)
	local name = data.name
	local story = data.story
	local props = data.props
	local root = ReactRoblox.createRoot(instance)
	local ports = State.CreatePorts()
	local v = storyCache[name] or {}

	local function update()
		local attributes = instance:GetAttributes()
		storyCache[name] = table.clone(attributes)

		for k, callback in data.callbacks do
			attributes[k] = callback()
		end

		root:render((React.createElement(State.Driver, {
			Ports = ports
		}, {
			Story = React.createElement(story, attributes)
		})))

		if attributes.AutoPlay then
			task.delay(0, function()
				ports.SetPlaying:Fire(true)
			end)
		end
	end

	local v2 = {}

	for k, v3 in pairs(props) do
		local v4 = k
		local success, result = pcall(function(...)
			local attributeChangedSignal = instance:GetAttributeChangedSignal(v4)

			if v[v4] ~= nil then
				v3 = v[v4]
			end

			instance:SetAttribute(v4, v3)
			return attributeChangedSignal:Connect(update)
		end)

		if success then
			table.insert(v2, result)
		end
	end

	update()
	return function()
		for _, connection in ipairs(v2) do
			connection:Disconnect()
		end

		root:unmount()
	end
end

function Story.Create(p, options)
	local v = p.Name:gsub("%.story$", "")
	local moduleScript = v and components:FindFirstChild(v)
	assert(moduleScript and moduleScript:IsA("ModuleScript"), "Invalid story target provided!")
	local props = options or {}
	local callbacks = {}

	for k, v4 in pairs(props) do
		if typeof(v4) ~= "function" then
			continue
		end

		callbacks[k] = v4
		props[k] = nil
	end

	return (setmetatable({
		name = moduleScript:GetFullName(),
		story = require2(moduleScript),
		callbacks = callbacks,
		props = props
	}, class))
end

function Story.Custom(story, options)
	local props = options or {}
	local name = debug.info(2, "s")
	local callbacks = {}

	for k, v4 in pairs(props) do
		if typeof(v4) ~= "function" then
			continue
		end

		callbacks[k] = v4
		props[k] = nil
	end

	return (setmetatable({
		name = name,
		story = story,
		callbacks = callbacks,
		props = props
	}, class))
end

return Story