local Animator = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Janitor = require(ReplicatedStorage.Modules.Janitor)
local Animations = require(script.Parent.Animations)
local v = {}
local isClient = RunService:IsClient()

local function isVisible(parent)
	while parent and parent ~= game do
		if parent:IsA("GuiObject") and not parent.Visible then
			return false
		end

		if parent:IsA("LayerCollector") and not parent.Enabled then
			return false
		else
			parent = parent.Parent
		end
	end

	return parent == game
end

local function watchVisibility(instance, fn)
	local v2 = Janitor.new()
	local connections = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clearPropertyConnections()
		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)
	end

	local function rebuildPropertyConnections()
		clearPropertyConnections() -- equivalent call inferred; original call site unknown
		local parent = instance

		while parent and parent ~= game do
			if parent:IsA("GuiObject") then
				table.insert(connections, parent:GetPropertyChangedSignal("Visible"):Connect(fn))
			elseif parent:IsA("LayerCollector") then
				table.insert(connections, parent:GetPropertyChangedSignal("Enabled"):Connect(fn))
			end

			parent = parent.Parent
		end
	end

	rebuildPropertyConnections()
	local ancestryChangedConnection = instance.AncestryChanged:Connect(function()
		rebuildPropertyConnections()
		fn()
	end)
	v2:Add(clearPropertyConnections)
	v2:Add(ancestryChangedConnection)
	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeActiveAnimation(p)
	local v2 = v[p]

	if not v2 then
		return
	end

	if v2:Get("AnimationObject") then
		v2:Remove("AnimationObject")
	end

	task.wait()
end

local function setActiveAnimation(instance, p)
	local v2 = v[instance]

	if not v2 then
		return
	end

	removeActiveAnimation(instance) -- equivalent call inferred; original call site unknown

	if not (p and Animations[p]) then
		return
	end

	local title = instance:FindFirstChild("Title", true)
	local text

	if title and title:IsA("TextLabel") then
		text = title.Text
	else
		text = nil
	end

	local maid = Janitor.new()
	local v3 = nil
	local v4 = false

	local function startAnimation()
		if v4 or v3 then
			return
		end

		if title and title:IsA("TextLabel") and text ~= nil then
			title.Text = text
			local animationStroke = title:FindFirstChild("AnimationStroke")

			for _, uIGradient in title:GetChildren() do
				if uIGradient:IsA("UIGradient") and uIGradient.Name ~= "TitleGradient" then
					uIGradient:Destroy()
				end
			end

			if animationStroke then
				animationStroke:Destroy()
			end
		end

		v3 = Animations[p](instance)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stopAnimation()
		if not v3 then
			return
		end

		v3:Destroy()
		v3 = nil
	end

	maid:Add(function()
		v4 = true
		stopAnimation() -- equivalent call inferred; original call site unknown
	end)
	maid:Add(watchVisibility(instance, function()
		if isVisible(instance) then
			startAnimation()
			return
		end

		stopAnimation() -- equivalent call inferred; original call site unknown
	end), "Destroy")

	if isVisible(instance) then
		startAnimation()
	end

	v2:Add(maid, "Destroy", "AnimationObject")
end

local function registerDisplayName(instance)
	if v[instance] or not instance:IsDescendantOf(game) then
		return
	end

	local maid = Janitor.new()
	maid:LinkToInstance(instance)
	maid:Add(function()
		v[instance] = nil
	end)
	v[instance] = maid
end

function Animator.SetTitleAnimation(_, p, p2)
	if isClient then
		registerDisplayName(p)
		setActiveAnimation(p, p2)
	end
end

function Animator.RemoveTitleAnimation(_, p)
	if isClient then
		removeActiveAnimation(p) -- equivalent call inferred; original call site unknown
	end
end

return Animator