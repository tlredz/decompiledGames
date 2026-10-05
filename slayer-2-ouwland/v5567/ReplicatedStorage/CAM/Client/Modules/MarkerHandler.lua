local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local Players = game:GetService("Players")
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local localPlayer = Players.LocalPlayer

-- equivalent calls inferred from this helper; original call sites unknown
local function playerGui()
	return localPlayer:FindFirstChildOfClass("PlayerGui")
end

local markerType2 = {
	Regular = 1,
	PointerMarker = 2
}
local offScreenMode = {
	Bounded = 1,
	Compass = 2
}
local v3 = {
	[markerType2.Regular] = {
		markerType = markerType2.Regular,
		transparency = 0.35,
		outline = Color3.new(1, 1, 1),
		displayDistance = true,
		color = Color3.new(0.25, 0.25, 0.25),
		offScreenMode = offScreenMode.Compass
	},
	[markerType2.PointerMarker] = {
		markerType = markerType2.PointerMarker,
		in3DSpace = false
	}
}
local MarkerHandler = {
	Styles = {},
	markerType = markerType2,
	offScreenMode = offScreenMode,
	currentMarkers = {},
	markerCount = {
		value = 0,
		Changed = simplesignal.new()
	},
	disabledTags = {},
	allDisabled = false,
	tagDisabled = {
		Changed = simplesignal.new()
	}
}

for _, moduleScript in script.Styles:GetDescendants() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local styles = MarkerHandler.Styles
	local name = moduleScript.Name
	local module = require(moduleScript)
	styles[name] = module
end

local function cleanupVisuals(childName: string)
	local child = workspace:FindFirstChild("marker3DFolder") and workspace.marker3DFolder:FindFirstChild(childName)

	if child then
		TweenService:Create(child, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
			Size = createVector(0, 0.02, 0)
		}):Play()
		DebrisModule:AddItem(child, 0.15)
	end

	local v4 = playerGui() -- equivalent call inferred; original call site unknown
	local markergui

	if v4 ~= nil then
		markergui = v4:FindFirstChild("markergui") or nil
	end

	local child2 = markergui ~= nil and markergui:FindFirstChild(childName)

	if child2 then
		TweenService:Create(child2, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
			Size = UDim2.new()
		}):Play()
		DebrisModule:AddItem(child2, 0.15)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tearDownMarker(k: string, currentMarker)
	cleanupVisuals(k)
	currentMarker._posX = nil
	currentMarker._posY = nil
	currentMarker._compassX = nil
	currentMarker._inCompass = nil
	currentMarker._lerpTimer = nil
	currentMarker.currenttransparencyvalue = nil
end

local v4 = {}
local v5 = {}

local function refreshMapFlags(p: string)
	local v6 = v4[p]
	local currentMarker = MarkerHandler.currentMarkers[p]

	if v6 == nil or currentMarker == nil then
		return
	end

	local ping = nil
	local kind = nil
	local onMap = nil

	for i = #v6, 1, -1 do
		local data = v6[i].data
		onMap = data.onMap == true or onMap

		if ping == nil and data.ping ~= nil then
			ping = data.ping
		end

		if kind == nil and data.kind ~= nil then
			kind = data.kind
		end
	end

	currentMarker.onMap = onMap
	currentMarker.ping = ping
	currentMarker.kind = kind
	MarkerHandler.markerCount.Changed:Fire()
end

local function addSingle(source: string, p2)
	local useName = p2.useName or source
	local markerType = p2.markerType or markerType2.Regular
	local v6 = v3[markerType]

	if not v6 then
		return
	end

	local style = p2.style
	local v7 = style ~= nil and style ~= "Default" and {} or table.clone(v6)

	for k, v8 in p2 do
		v7[k] = v8
	end

	v7.count = nil
	v7.tag = v7.tag or "Default"
	v5[source] = useName
	local v8 = v4[useName]

	if v8 == nil then
		v4[useName] = {
			{
				source = source,
				data = v7
			}
		}
		MarkerHandler.currentMarkers[useName] = v7
		MarkerHandler.markerCount.value += 1
		MarkerHandler.markerCount.Changed:Fire()
	else
		table.insert(v8, {
			source = source,
			data = v7
		})
		MarkerHandler.currentMarkers[useName].count = #v8
		refreshMapFlags(useName)
	end
end

local function removeSingle(p: string)
	local v6 = v5[p] or p
	local v7 = v4[v6]

	if v7 == nil then
		return
	end

	local v8 = nil

	for i = #v7, 1, -1 do
		if v7[i].source ~= p then
			continue
		end

		v8 = i
		break
	end

	local v9 = table.remove(v7, v8 or #v7)
	local v10 = false

	for _, v12 in v7 do
		if v12.source ~= v9.source then
			continue
		end

		v10 = true
		break
	end

	if not v10 then
		v5[v9.source] = nil
	end

	if #v7 == 0 then
		v4[v6] = nil
		MarkerHandler.currentMarkers[v6] = nil
		cleanupVisuals(v6)

		if MarkerHandler.markerCount.value > 0 then
			MarkerHandler.markerCount.value -= 1
			MarkerHandler.markerCount.Changed:Fire()
		end
	else
		local data = v7[1].data
		data.count = #v7 > 1 and #v7 or nil

		if MarkerHandler.currentMarkers[v6] ~= data then
			MarkerHandler.currentMarkers[v6] = data
			cleanupVisuals(v6)
		end

		refreshMapFlags(v6)
	end
end

function MarkerHandler.addMarker(source: string, p2)
	addSingle(source, p2)
end

function MarkerHandler.removeMarker(p: string)
	removeSingle(p)
end

function MarkerHandler.isTagDisabled(p: string)
	return MarkerHandler.disabledTags[p] == true
end

function MarkerHandler.disableTag(p: string)
	if MarkerHandler.disabledTags[p] then
		return
	end

	MarkerHandler.disabledTags[p] = true

	if not MarkerHandler.allDisabled then
		for k, currentMarker in MarkerHandler.currentMarkers do
			if currentMarker.tag ~= p then
				continue
			end

			tearDownMarker(k, currentMarker) -- equivalent call inferred; original call site unknown
		end
	end

	MarkerHandler.tagDisabled.Changed:Fire(p, true)
end

function MarkerHandler.enableTag(p: string)
	if not MarkerHandler.disabledTags[p] then
		return
	end

	MarkerHandler.disabledTags[p] = nil
	MarkerHandler.tagDisabled.Changed:Fire(p, false)
end

function MarkerHandler.disableAll()
	if MarkerHandler.allDisabled then
		return
	end

	MarkerHandler.allDisabled = true

	for k, currentMarker in MarkerHandler.currentMarkers do
		tearDownMarker(k, currentMarker) -- equivalent call inferred; original call site unknown
	end

	MarkerHandler.tagDisabled.Changed:Fire("*", true)
end

function MarkerHandler.enableAll()
	if not MarkerHandler.allDisabled then
		return
	end

	MarkerHandler.allDisabled = false
	MarkerHandler.tagDisabled.Changed:Fire("*", false)
end

task.spawn(function()
	local markers = ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Components"):WaitForChild("Layout"):WaitForChild("Visibility"):WaitForChild("Markers")

	local function bind(boolValue)
		if not boolValue:IsA("BoolValue") then
			return
		end

		if boolValue.Name == "AllMarkers" then
			-- equivalent calls inferred from this helper; original call sites unknown
			local function applyAll()
				if boolValue.Value then
					MarkerHandler.enableAll()
				else
					MarkerHandler.disableAll()
				end
			end

			applyAll() -- equivalent call inferred; original call site unknown
			boolValue.Changed:Connect(applyAll)
		else
			-- equivalent calls inferred from this helper; original call sites unknown
			local function apply()
				if boolValue.Value then
					MarkerHandler.enableTag(boolValue.Name)
				else
					MarkerHandler.disableTag(boolValue.Name)
				end
			end

			apply() -- equivalent call inferred; original call site unknown
			boolValue.Changed:Connect(apply)
		end
	end

	for _, child in markers:GetChildren() do
		bind(child)
	end

	markers.ChildAdded:Connect(bind)
end)
return MarkerHandler