local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local BuildInfo = require(game.ReplicatedStorage.BuildInfo)
local LineUtils = require(script.LineUtils)
local Maid = require(script.Parent.Maid)
require(script.Types)
local isServer = RunService:IsServer()
local IrisLogServer

if isServer then
	IrisLogServer = require(game.ServerScriptService.Services.IrisLogService.IrisLogServer)
else
	IrisLogServer = nil
end

local ClientRuntime

if not isServer then
	ClientRuntime = require(script.ClientRuntime)
end

local IrisLog = {}
IrisLog.__index = IrisLog
IrisLog.Lines = false
local object = setmetatable({}, {
	__mode = "k"
})
local object2 = setmetatable({}, {
	__mode = "k"
})
local object3 = setmetatable({}, {
	__mode = "k"
})
local v = {
	Red = "<font color=\"rgb(255,150,150)\">",
	VeryRed = "<font color=\"rgb(255,50,50)\">",
	Blue = "<font color=\"rgb(150,150,255)\">",
	Orange = "<font color=\"rgb(255,107,35)\">",
	Green = "<font color=\"rgb(150,255,150)\">",
	Purple = "<font color=\"rgb(164,99,255)\">",
	Gold = "<font color=\"rgb(255,215,0)\">",
	Pink = "<font color=\"rgb(255,182,193)\">",
	Cyan = "<font color=\"rgb(0,255,255)\">",
	Yellow = "<font color=\"rgb(255,255,0)\">",
	Magenta = "<font color=\"rgb(255,0,255)\">",
	Lime = "<font color=\"rgb(50,205,50)\">",
	Teal = "<font color=\"rgb(0,128,128)\">",
	Indigo = "<font color=\"rgb(75,0,130)\">",
	Coral = "<font color=\"rgb(255,127,80)\">",
	Crimson = "<font color=\"rgb(220,20,60)\">",
	Navy = "<font color=\"rgb(0,0,128)\">",
	Maroon = "<font color=\"rgb(128,0,0)\">",
	Olive = "<font color=\"rgb(128,128,0)\">",
	Silver = "<font color=\"rgb(192,192,192)\">",
	Turquoise = "<font color=\"rgb(64,224,208)\">",
	Violet = "<font color=\"rgb(238,130,238)\">",
	Rose = "<font color=\"rgb(255,20,147)\">",
	Mint = "<font color=\"rgb(152,251,152)\">",
	Peach = "<font color=\"rgb(255,218,185)\">",
	Lavender = "<font color=\"rgb(230,230,250)\">",
	Sky = "<font color=\"rgb(135,206,235)\">",
	Forest = "<font color=\"rgb(34,139,34)\">",
	Amber = "<font color=\"rgb(255,191,0)\">"
}
local count = 0
local v2 = {}
local v3 = nil
local logAuthority = {
	Tester = 1,
	Admin = 2,
	Developer = 3,
	Never = 4,
	None = 4
}
local irisLogs = {}
local sortedLogArray = {}

for k, v7 in v do
	count += 1
	table.insert(v2, v7)
	local v8 = v7

	IrisLog[k] = function(p, ...)
		return {
			v8,
			{ ... },
			"</font>"
		}
	end
end

local v7 = {
	warn = 1,
	error = 2
}

local function strongerSeverity(p: string?, p2)
	if p2 ~= "warn" and p2 ~= "error" or p and not (v7[p2] > v7[p]) then
		return p
	end

	return p2
end

local detectValueSeverity

detectValueSeverity = function(p)
	if typeof(p) ~= "table" then
		return nil
	end

	local irisLogSeverity = p.IrisLogSeverity

	if irisLogSeverity ~= "warn" and irisLogSeverity ~= "error" then
		irisLogSeverity = nil
	end

	for _, v8 in p do
		local v9 = detectValueSeverity(v8)

		if (v9 == "warn" or v9 == "error") and (not irisLogSeverity or v7[v9] > v7[irisLogSeverity]) then
			irisLogSeverity = v9
		end
	end

	return irisLogSeverity
end

local function detectLineSeverity(...)
	local v8 = nil

	for i = 1, select("#", ...) do
		local v9 = detectValueSeverity(select(i, ...))

		if (v9 == "warn" or v9 == "error") and (not v8 or v7[v9] > v7[v8]) then
			v8 = v9
		end
	end

	return v8
end

local function hashColor(name: string)
	local total = 0

	for i = 1, name:len() do
		total += string.byte(name:sub(i, i))
	end

	return v2[Random.new(total):NextInteger(1, count)] .. name .. "</font>"
end

local function normalizeCategory(value)
	if typeof(value) == "string" and value ~= "" then
		return value
	end

	return nil
end

local function assignCategory(state, category)
	if typeof(category) ~= "string" or category == "" then
		category = nil
	end

	if state.Category == category and state.IrisLogSettings.Category == category then
		return false
	end

	state.Category = category
	state.IrisLogSettings.Category = category
	return true
end

local function replicateCategoryChanged(object4)
	if not (isServer and typeof(object4.can_player_receive_log) == "function") then
		return
	end

	for _, v8 in game.Players:GetPlayers() do
		local v9 = v8
		task.spawn(function()
			if object4:can_player_receive_log(v9) then
				v3.Script.event:FireClient(v9, "SetCategory", object4.Name, object4.Category)
			end
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function notifyCategoryChanged(p)
	local _onCategoryChanged = IrisLog._onCategoryChanged

	if _onCategoryChanged then
		_onCategoryChanged(p)
	end

	replicateCategoryChanged(p)
end

local function createBaseLog(name: string, authority: number, p3)
	local v8 = {
		Lines = {},
		Threads = {},
		HeaderLines = {},
		Name = name,
		Category = nil,
		New = 0,
		NewSeverity = nil,
		LastAppend = tick(),
		Id = HttpService:GenerateGUID(),
		Authority = authority,
		Tabs = {},
		IrisLogSettings = {},
		ButtonCallbacks = {},
		ReplicatedObjectHandles = {},
		InlineLogHandles = {},
		ReplicatedHandleValues = {},
		ReplicatedHandleKinds = {},
		_maid = Maid.new()
	}
	IrisLog._mergeSettings(v8, p3)
	table.insert(v8.Tabs, {
		Name = "Log",
		Lines = v8.Lines
	})
	return v8
end

function IrisLog:_mergeSettings(items)
	local v8 = false

	if not items then
		return false
	end

	for k, item in items do
		if k == "Hidden" then
			self.IrisLogSettings.Hidden = self.IrisLogSettings.Hidden == true or item == true
		elseif k == "Category" then
			if typeof(item) ~= "string" or item == "" then
				item = nil
			end

			local v9

			if self.Category == item and self.IrisLogSettings.Category == item then
				v9 = false
			else
				self.Category = item
				self.IrisLogSettings.Category = item
				v9 = true
			end

			v8 = v9 or v8
		else
			self.IrisLogSettings[k] = item
		end
	end

	return v8
end

function IrisLog:SetCategory(category: string?)
	if typeof(category) ~= "string" or category == "" then
		category = nil
	end

	local flag

	if self.Category == category and self.IrisLogSettings.Category == category then
		flag = false
	else
		self.Category = category
		self.IrisLogSettings.Category = category
		flag = true
	end

	if flag then
		notifyCategoryChanged(self) -- equivalent call inferred; original call site unknown
	end

	return self
end

IrisLog.setCategory = IrisLog.SetCategory

function IrisLog.new(name: string, value, p2)
	if typeof(value) == "string" then
		value = logAuthority[value]
	end

	local v8 = irisLogs[name]

	if v8 then
		if IrisLog._mergeSettings(v8, p2) then
			notifyCategoryChanged(v8) -- equivalent call inferred; original call site unknown
		end

		return v8
	else
		local baseLog = createBaseLog(name, value or logAuthority.Admin, p2)
		irisLogs[name] = baseLog
		table.insert(sortedLogArray, 1, baseLog)
		setmetatable(baseLog, IrisLog)

		if isServer then
			IrisLogServer.onLogCreated(baseLog)
		end

		return baseLog
	end
end

function IrisLog:getMaid()
	local _maid = self._maid

	if not (_maid and Maid.isMaid(_maid)) then
		_maid = Maid.new()
		self._maid = _maid
	end

	return _maid
end

function IrisLog:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true

	if irisLogs[self.Name] == self then
		irisLogs[self.Name] = nil
	end

	for i = #sortedLogArray, 1, -1 do
		if sortedLogArray[i] ~= self then
			continue
		end

		table.remove(sortedLogArray, i)
		break
	end

	local remoteEvent = self.RemoteEvent
	self.RemoteEvent = nil

	if remoteEvent then
		remoteEvent:Destroy()
	end

	local _maid = self._maid
	self._maid = nil

	if _maid then
		_maid:Destroy()
	end
end

IrisLog.destroy = IrisLog.Destroy

function IrisLog.createLogForPlayer(targetPlayer, name: string)
	assert(isServer, "IrisLog.createLogForPlayer can only be called from the server")
	assert(targetPlayer)
	assert(targetPlayer.Parent == game.Players)
	local baseLog = createBaseLog(name, logAuthority.None, nil)
	baseLog.TargetPlayer = targetPlayer
	setmetatable(baseLog, IrisLog)
	IrisLogServer.onTargetLogCreated(baseLog, targetPlayer)
	return baseLog
end

function IrisLog:_getLogColorFormatted(p)
	local color = self.IrisLogSettings.Color

	if color then
		return self:Color3(color, (`[{p.Name}]: `))
	end

	return self:HashColor((`[{p.Name}]: `))
end

function IrisLog:getLogPcallWrapper(p)
	local _getLogColorFormatted = self:_getLogColorFormatted(p)
	return function(callback, ...)
		local v8 = { pcall(callback, ...) }

		if table.remove(v8, 1) then
			return true, unpack(v8)
		end

		warn(unpack(v8), debug.traceback())
		self:Append(_getLogColorFormatted, self:ErrorAt(3, unpack(v8)))
		return false
	end
end

function IrisLog:getLogAppendWrapper(p, _: boolean?)
	local formatted = `[{p.Name}]:`
	local _getLogColorFormatted = self:_getLogColorFormatted(p)
	return function(...)
		if RunService:IsStudio() then
			warn(formatted, ...)
		end

		self:Append(_getLogColorFormatted, ...)
	end
end

function IrisLog.Color(_, p, ...)
	return {
		v[p],
		{ ... },
		"</font>"
	}
end

function IrisLog:Color3(color: Color3, ...)
	return {
		`<font color="rgb({math.floor(color.R * 255)},{math.floor(color.G * 255)},{math.floor(color.B * 255)})">`,
		{ ... },
		"</font>"
	}
end

function IrisLog:HashColor(value: string, ...)
	local total = 0

	for i = 1, value:len() do
		total += string.byte(value:sub(i, i))
	end

	return {
		v2[Random.new(total):NextInteger(1, count)],
		{ value, ... },
		"</font>"
	}
end

function IrisLog.Warn(_, ...)
	return {
		v.Orange,
		{ ... },
		"</font>",
		IrisLogSeverity = "warn"
	}
end

function IrisLog:Text(...)
	return {
		nil,
		{ ... },
		"</text>"
	}
end

function IrisLog:Error(...)
	return {
		v.VeryRed,
		{
			"Error: ",
			self:Text(...),
			"\n",
			debug.traceback(nil, 2)
		},
		"</font>",
		IrisLogSeverity = "error"
	}
end

function IrisLog:ErrorAt(p, ...)
	return {
		v.VeryRed,
		{
			"Error: ",
			self:Text(...),
			"\n",
			debug.traceback(nil, p)
		},
		"</font>",
		IrisLogSeverity = "error"
	}
end

function IrisLog.Red(_, ...)
	return {
		v.Red,
		{ ... },
		"</font>"
	}
end

function IrisLog.Tree(_, p, ...)
	return {
		p,
		{ ... },
		"</tree>"
	}
end

function IrisLog.Divider(_, p, ...)
	return {
		p,
		{ ... },
		"</div>"
	}
end

function IrisLog.CollapsableDivider(_, p, ...)
	return {
		p,
		{ ... },
		"</cdiv>"
	}
end

IrisLog.CollapsibleDivider = IrisLog.CollapsableDivider

function IrisLog.AlignedGrid(_, p: number, p2: number, ...)
	return {
		p,
		p2,
		"</agrid>",
		{ ... }
	}
end

function IrisLog.AlignedList(_, p: number, ...)
	return {
		p,
		nil,
		"</alist>",
		{ ... }
	}
end

function IrisLog.BubbleFrame(_, p: number, p2: number, ...)
	return {
		p,
		p2,
		"</bubble>",
		{ ... }
	}
end

function IrisLog.CenterAligned(_, ...)
	return {
		nil,
		{ ... },
		"</center>"
	}
end

function IrisLog.SizeGroup(_, ...)
	return {
		nil,
		{ ... },
		"</sizegroup>"
	}
end

function IrisLog.MakeLineUnclearable(_)
	return { nil, nil, "</stay>" }
end

function IrisLog.NewLine(_)
	return { nil, nil, "</br>" }
end

function IrisLog:EnsureTab(name: string)
	for _, tab in self.Tabs do
		if tab.Name == name then
			return tab
		end
	end

	local v8 = {
		Name = name,
		Lines = {}
	}
	table.insert(self.Tabs, v8)
	return v8
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findTab(p, p2: string)
	for _, tab in p.Tabs do
		if tab.Name == p2 then
			return tab
		end
	end

	return nil
end

local valueContainsTag

valueContainsTag = function(list, p: string, p2)
	if typeof(list) ~= "table" then
		return false
	end

	if list[3] == p then
		return true
	end

	if p2[list] then
		return false
	end

	p2[list] = true

	for _, v8 in list do
		if not valueContainsTag(v8, p, p2) then
			continue
		end

		p2[list] = nil
		return true
	end

	p2[list] = nil
	return false
end

local function lineContainsStay(p)
	return (valueContainsTag(p, "</stay>", {}))
end

local function clearLines(lines)
	for i = #lines, 1, -1 do
		if not valueContainsTag(lines[i], "</stay>", {}) then
			table.remove(lines, i)
		end
	end
end

function IrisLog:GetNotifText()
	local color = self.IrisLogSettings.Color
	local v8

	if color then
		v8 = self:Color3(color, (`[{script.Name}]: `))
	else
		v8 = hashColor(self.Name)
	end

	local v9 = self.NewSeverity == "error" and "rgb(248,113,113)" or self.NewSeverity == "warn" and "rgb(250,204,21)" or "rgb(86,196,240)"
	return (`{self.Pinned and "📌 " or ""}{v8} {not (self.New > 0) and "" or `(<font color="{v9}">{self.New}</font>)`}`)
end

function IrisLog:GetNotifObj()
	if self._notifobj then
		return self._notifobj
	end

	self._notifobj = setmetatable({}, {
		__tostring = function()
			return self:GetNotifText()
		end
	})
	return self._notifobj
end

function IrisLog.Tooltip(_, p)
	return { p, nil, "</tip>" }
end

v3 = {
	Script = script,
	IrisLogs = irisLogs,
	SortedLogArray = sortedLogArray,
	LogAuthority = logAuthority,
	BuildInfo = BuildInfo,
	ServerLinesSaved = 1000,
	ClientLinesSaved = 1000,
	LineRenderLimit = 100,
	ServerContextText = "/<font color=\"rgb(150,255,150)\">Server</font>: ",
	ClientContextText = "/<font color=\"rgb(150,150,255)\">Client</font>:  ",
	LogContextText = isServer and "/<font color=\"rgb(150,255,150)\">Server</font>: " or "/<font color=\"rgb(150,150,255)\">Client</font>:  ",
	CompareLine = LineUtils.compareLine,
	IncrementNumRepeatsForLine = LineUtils.incrementNumRepeatsForLine,
	DetectLineSeverity = detectLineSeverity
}
local v8 = {}
local v9 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function createGuid()
	return HttpService:GenerateGUID(false)
end

local function handleLookupKey(value)
	if value == nil then
		return nil
	end

	assert(typeof(value) == "string", "IrisLog handle id must be a string")
	return value
end

local rootLogFor

rootLogFor = function(parentLog)
	local v10 = object3[parentLog]

	if v10 and v10.ParentLog then
		return rootLogFor(v10.ParentLog)
	end

	if parentLog and parentLog.IsInlineLog and parentLog.ParentLog then
		return rootLogFor(parentLog.ParentLog)
	end

	return parentLog
end

local function ensureHandleTables(state)
	if not state.ReplicatedObjectHandles then
		state.ReplicatedObjectHandles = {}
	end

	if not state.InlineLogHandles then
		state.InlineLogHandles = {}
	end

	if not state.ReplicatedHandleValues then
		state.ReplicatedHandleValues = {}
	end

	if not state.ReplicatedHandleKinds then
		state.ReplicatedHandleKinds = {}
	end
end

local function rememberHandleValue(data, p: string, kind: string, p3)
	local v10 = object3[data]

	if v10 and v10.ParentLog then
		data = rootLogFor(v10.ParentLog)
	elseif data and data.IsInlineLog and data.ParentLog then
		data = rootLogFor(data.ParentLog)
	end

	ensureHandleTables(data)
	data.ReplicatedHandleValues[p] = {
		Kind = kind,
		Value = p3
	}
	data.ReplicatedHandleKinds[p] = kind
end

local function notifyHandleUpdated(p, p2: string, kind: string, p4)
	local v10 = object3[p]

	if v10 and v10.ParentLog then
		p = rootLogFor(v10.ParentLog)
	elseif p and p.IsInlineLog and p.ParentLog then
		p = rootLogFor(p.ParentLog)
	end

	local v11 = object3[p]
	local v12

	if v11 and v11.ParentLog then
		v12 = rootLogFor(v11.ParentLog)
	elseif p and p.IsInlineLog and p.ParentLog then
		v12 = rootLogFor(p.ParentLog)
	else
		v12 = p
	end

	ensureHandleTables(v12)
	v12.ReplicatedHandleValues[p2] = {
		Kind = kind,
		Value = p4
	}
	v12.ReplicatedHandleKinds[p2] = kind
	local _onReplicatedHandleUpdated = IrisLog._onReplicatedHandleUpdated

	if _onReplicatedHandleUpdated then
		_onReplicatedHandleUpdated(p, p2, kind, p4)
	end
end

local function snapshotInlineLogState(data)
	local tabs = {}

	for _, tab in data.Tabs do
		table.insert(tabs, {
			Name = tab.Name,
			Lines = tab.Lines,
			LINE_RENDER_START = tab.LINE_RENDER_START
		})
	end

	return {
		Name = data.Name,
		HeaderLines = data.HeaderLines,
		Tabs = tabs,
		Lines = data.Lines
	}
end

local function refreshInlineLogHandle(p, flag: boolean?)
	local v10 = object3[p]
	assert(v10, "InlineLogHandle is missing its backing log state")
	local v11 = object2[p] or rawget(p, 1)
	local v12 = object[p] or v10.ParentLog
	local v13 = snapshotInlineLogState(v10)
	rawset(p, 4, v13)

	if not (v12 and v11) then
		return v13
	end

	if flag == false then
		local v14 = object3[v12]

		if v14 and v14.ParentLog then
			v12 = rootLogFor(v14.ParentLog)
		elseif v12 and v12.IsInlineLog and v12.ParentLog then
			v12 = rootLogFor(v12.ParentLog)
		end

		ensureHandleTables(v12)
		v12.ReplicatedHandleValues[v11] = {
			Kind = "inline-log",
			Value = v13
		}
		v12.ReplicatedHandleKinds[v11] = "inline-log"
		return v13
	else
		local v14 = object3[v12]

		if v14 and v14.ParentLog then
			v12 = rootLogFor(v14.ParentLog)
		elseif v12 and v12.IsInlineLog and v12.ParentLog then
			v12 = rootLogFor(v12.ParentLog)
		end

		local v15 = object3[v12]
		local v16

		if v15 and v15.ParentLog then
			v16 = rootLogFor(v15.ParentLog)
		elseif v12 and v12.IsInlineLog and v12.ParentLog then
			v16 = rootLogFor(v12.ParentLog)
		else
			v16 = v12
		end

		ensureHandleTables(v16)
		v16.ReplicatedHandleValues[v11] = {
			Kind = "inline-log",
			Value = v13
		}
		v16.ReplicatedHandleKinds[v11] = "inline-log"
		local _onReplicatedHandleUpdated = IrisLog._onReplicatedHandleUpdated

		if _onReplicatedHandleUpdated then
			_onReplicatedHandleUpdated(v12, v11, "inline-log", v13)
		end

		return v13
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getInlineLogState(p)
	local v10 = object3[p]
	assert(v10, "InlineLogHandle is missing its backing log state")
	return v10
end

local function trimInlineMainLog(inlineLogState)
	local v10

	if isServer then
		v10 = v3.ServerLinesSaved
	else
		v10 = v3.ClientLinesSaved
	end

	while v10 < #inlineLogState.Lines do
		table.remove(inlineLogState.Lines, 1)
	end
end

function v8.Update(p, ...)
	local v10 = object[p]
	local v11 = object2[p] or rawget(p, 1)
	assert(v10 and v11, "ReplicatedObjectHandle is missing its owner")
	local v12 = { ... }
	rawset(p, 4, v12)
	local v13 = object3[v10]

	if v13 and v13.ParentLog then
		v10 = rootLogFor(v13.ParentLog)
	elseif v10 and v10.IsInlineLog and v10.ParentLog then
		v10 = rootLogFor(v10.ParentLog)
	end

	local v14 = object3[v10]
	local v15

	if v14 and v14.ParentLog then
		v15 = rootLogFor(v14.ParentLog)
	elseif v10 and v10.IsInlineLog and v10.ParentLog then
		v15 = rootLogFor(v10.ParentLog)
	else
		v15 = v10
	end

	ensureHandleTables(v15)
	v15.ReplicatedHandleValues[v11] = {
		Kind = "object",
		Value = v12
	}
	v15.ReplicatedHandleKinds[v11] = "object"
	local _onReplicatedHandleUpdated = IrisLog._onReplicatedHandleUpdated

	if _onReplicatedHandleUpdated then
		_onReplicatedHandleUpdated(v10, v11, "object", v12)
	end

	return p
end

function v9.Update(p, ...)
	local inlineLogState = getInlineLogState(p) -- equivalent call inferred; original call site unknown
	table.clear(inlineLogState.Lines)
	inlineLogState.LastAppend = tick()

	if select("#", ...) > 0 then
		table.insert(inlineLogState.Lines, { ... })
	end

	local inlineLogState2 = getInlineLogState(p) -- equivalent call inferred; original call site unknown
	local v10 = object2[p] or rawget(p, 1)
	local v11 = object[p] or inlineLogState2.ParentLog
	local v12 = snapshotInlineLogState(inlineLogState2)
	rawset(p, 4, v12)

	if not (v11 and v10) then
		return p
	end

	local v13 = object3[v11]

	if v13 and v13.ParentLog then
		v11 = rootLogFor(v13.ParentLog)
	elseif v11 and v11.IsInlineLog and v11.ParentLog then
		v11 = rootLogFor(v11.ParentLog)
	end

	local v14 = object3[v11]
	local v15

	if v14 and v14.ParentLog then
		v15 = rootLogFor(v14.ParentLog)
	elseif v11 and v11.IsInlineLog and v11.ParentLog then
		v15 = rootLogFor(v11.ParentLog)
	else
		v15 = v11
	end

	ensureHandleTables(v15)
	v15.ReplicatedHandleValues[v10] = {
		Kind = "inline-log",
		Value = v12
	}
	v15.ReplicatedHandleKinds[v10] = "inline-log"
	local _onReplicatedHandleUpdated = IrisLog._onReplicatedHandleUpdated

	if _onReplicatedHandleUpdated then
		_onReplicatedHandleUpdated(v11, v10, "inline-log", v12)
	end

	return p
end

function v9.AppendHeader(p, ...)
	table.insert((getInlineLogState(p)).HeaderLines, { ... })
	local inlineLogState = getInlineLogState(p) -- equivalent call inferred; original call site unknown
	local v10 = object2[p] or rawget(p, 1)
	local v11 = object[p] or inlineLogState.ParentLog
	local v12 = snapshotInlineLogState(inlineLogState)
	rawset(p, 4, v12)

	if v11 and v10 then
		local v13 = object3[v11]

		if v13 and v13.ParentLog then
			v11 = rootLogFor(v13.ParentLog)
		elseif v11 and v11.IsInlineLog and v11.ParentLog then
			v11 = rootLogFor(v11.ParentLog)
		end

		local v14 = object3[v11]
		local v15

		if v14 and v14.ParentLog then
			v15 = rootLogFor(v14.ParentLog)
		elseif v11 and v11.IsInlineLog and v11.ParentLog then
			v15 = rootLogFor(v11.ParentLog)
		else
			v15 = v11
		end

		ensureHandleTables(v15)
		v15.ReplicatedHandleValues[v10] = {
			Kind = "inline-log",
			Value = v12
		}
		v15.ReplicatedHandleKinds[v10] = "inline-log"
		local _onReplicatedHandleUpdated = IrisLog._onReplicatedHandleUpdated

		if _onReplicatedHandleUpdated then
			_onReplicatedHandleUpdated(v11, v10, "inline-log", v12)
		end
	end
end

function v9.AppendToTab(p, p2: string, ...)
	table.insert((getInlineLogState(p)):EnsureTab(p2).Lines, { ... })
	local inlineLogState = getInlineLogState(p) -- equivalent call inferred; original call site unknown
	local v10 = object2[p] or rawget(p, 1)
	local v11 = object[p] or inlineLogState.ParentLog
	local v12 = snapshotInlineLogState(inlineLogState)
	rawset(p, 4, v12)

	if v11 and v10 then
		local v13 = object3[v11]

		if v13 and v13.ParentLog then
			v11 = rootLogFor(v13.ParentLog)
		elseif v11 and v11.IsInlineLog and v11.ParentLog then
			v11 = rootLogFor(v11.ParentLog)
		end

		local v14 = object3[v11]
		local v15

		if v14 and v14.ParentLog then
			v15 = rootLogFor(v14.ParentLog)
		elseif v11 and v11.IsInlineLog and v11.ParentLog then
			v15 = rootLogFor(v11.ParentLog)
		else
			v15 = v11
		end

		ensureHandleTables(v15)
		v15.ReplicatedHandleValues[v10] = {
			Kind = "inline-log",
			Value = v12
		}
		v15.ReplicatedHandleKinds[v10] = "inline-log"
		local _onReplicatedHandleUpdated = IrisLog._onReplicatedHandleUpdated

		if _onReplicatedHandleUpdated then
			_onReplicatedHandleUpdated(v11, v10, "inline-log", v12)
		end
	end
end

function v9.RawAppend(p, ...)
	local inlineLogState = getInlineLogState(p) -- equivalent call inferred; original call site unknown
	inlineLogState.LastAppend = tick()
	table.insert(inlineLogState.Lines, { ... })
	trimInlineMainLog(inlineLogState)
	local inlineLogState2 = getInlineLogState(p) -- equivalent call inferred; original call site unknown
	local v10 = object2[p] or rawget(p, 1)
	local v11 = object[p] or inlineLogState2.ParentLog
	local v12 = snapshotInlineLogState(inlineLogState2)
	rawset(p, 4, v12)

	if v11 and v10 then
		local v13 = object3[v11]

		if v13 and v13.ParentLog then
			v11 = rootLogFor(v13.ParentLog)
		elseif v11 and v11.IsInlineLog and v11.ParentLog then
			v11 = rootLogFor(v11.ParentLog)
		end

		local v14 = object3[v11]
		local v15

		if v14 and v14.ParentLog then
			v15 = rootLogFor(v14.ParentLog)
		elseif v11 and v11.IsInlineLog and v11.ParentLog then
			v15 = rootLogFor(v11.ParentLog)
		else
			v15 = v11
		end

		ensureHandleTables(v15)
		v15.ReplicatedHandleValues[v10] = {
			Kind = "inline-log",
			Value = v12
		}
		v15.ReplicatedHandleKinds[v10] = "inline-log"
		local _onReplicatedHandleUpdated = IrisLog._onReplicatedHandleUpdated

		if _onReplicatedHandleUpdated then
			_onReplicatedHandleUpdated(v11, v10, "inline-log", v12)
		end
	end
end

function v9:AppendWithTime(...)
	local inlineLogState = getInlineLogState(self) -- equivalent call inferred; original call site unknown
	inlineLogState.LastAppend = tick()
	local line = inlineLogState.Lines[#inlineLogState.Lines]
	local v10 = { os.date("%H:%M:%S", os.time()), ... }

	if v3.CompareLine(v10, line) then
		v3.IncrementNumRepeatsForLine(line)
	else
		table.insert(inlineLogState.Lines, v10)
		trimInlineMainLog(inlineLogState)
	end

	local inlineLogState2 = getInlineLogState(self) -- equivalent call inferred; original call site unknown
	local v11 = object2[self] or rawget(self, 1)
	local v12 = object[self] or inlineLogState2.ParentLog
	local v13 = snapshotInlineLogState(inlineLogState2)
	rawset(self, 4, v13)

	if v12 and v11 then
		local v14 = object3[v12]

		if v14 and v14.ParentLog then
			v12 = rootLogFor(v14.ParentLog)
		elseif v12 and v12.IsInlineLog and v12.ParentLog then
			v12 = rootLogFor(v12.ParentLog)
		end

		local v15 = object3[v12]
		local v16

		if v15 and v15.ParentLog then
			v16 = rootLogFor(v15.ParentLog)
		elseif v12 and v12.IsInlineLog and v12.ParentLog then
			v16 = rootLogFor(v12.ParentLog)
		else
			v16 = v12
		end

		ensureHandleTables(v16)
		v16.ReplicatedHandleValues[v11] = {
			Kind = "inline-log",
			Value = v13
		}
		v16.ReplicatedHandleKinds[v11] = "inline-log"
		local _onReplicatedHandleUpdated = IrisLog._onReplicatedHandleUpdated

		if _onReplicatedHandleUpdated then
			_onReplicatedHandleUpdated(v12, v11, "inline-log", v13)
		end
	end
end

function v9:Append(...)
	self:AppendWithTime(v3.LogContextText, ...)
end

function v9.ClearTab(p, p2: string)
	local tab = findTab(getInlineLogState(p), p2) -- equivalent call inferred; original call site unknown

	if not tab then
		return
	end

	clearLines(tab.Lines)
	local inlineLogState = getInlineLogState(p) -- equivalent call inferred; original call site unknown
	local v10 = object2[p] or rawget(p, 1)
	local v11 = object[p] or inlineLogState.ParentLog
	local v12 = snapshotInlineLogState(inlineLogState)
	rawset(p, 4, v12)

	if v11 and v10 then
		local v13 = object3[v11]

		if v13 and v13.ParentLog then
			v11 = rootLogFor(v13.ParentLog)
		elseif v11 and v11.IsInlineLog and v11.ParentLog then
			v11 = rootLogFor(v11.ParentLog)
		end

		local v14 = object3[v11]
		local v15

		if v14 and v14.ParentLog then
			v15 = rootLogFor(v14.ParentLog)
		elseif v11 and v11.IsInlineLog and v11.ParentLog then
			v15 = rootLogFor(v11.ParentLog)
		else
			v15 = v11
		end

		ensureHandleTables(v15)
		v15.ReplicatedHandleValues[v10] = {
			Kind = "inline-log",
			Value = v12
		}
		v15.ReplicatedHandleKinds[v10] = "inline-log"
		local _onReplicatedHandleUpdated = IrisLog._onReplicatedHandleUpdated

		if _onReplicatedHandleUpdated then
			_onReplicatedHandleUpdated(v11, v10, "inline-log", v12)
		end
	end
end

function v9.Thread(p, p2, p3)
	local inlineLogState_2 = getInlineLogState(p)
	inlineLogState_2.Threads[p2] = { p3, tick() }
	local inlineLogState = getInlineLogState(p) -- equivalent call inferred; original call site unknown
	local v10 = object2[p] or rawget(p, 1)
	local v11 = object[p] or inlineLogState.ParentLog
	local v12 = snapshotInlineLogState(inlineLogState)
	rawset(p, 4, v12)

	if v11 and v10 then
		local v13 = object3[v11]

		if v13 and v13.ParentLog then
			v11 = rootLogFor(v13.ParentLog)
		elseif v11 and v11.IsInlineLog and v11.ParentLog then
			v11 = rootLogFor(v11.ParentLog)
		end

		local v14 = object3[v11]
		local v15

		if v14 and v14.ParentLog then
			v15 = rootLogFor(v14.ParentLog)
		elseif v11 and v11.IsInlineLog and v11.ParentLog then
			v15 = rootLogFor(v11.ParentLog)
		else
			v15 = v11
		end

		ensureHandleTables(v15)
		v15.ReplicatedHandleValues[v10] = {
			Kind = "inline-log",
			Value = v12
		}
		v15.ReplicatedHandleKinds[v10] = "inline-log"
		local _onReplicatedHandleUpdated = IrisLog._onReplicatedHandleUpdated

		if _onReplicatedHandleUpdated then
			_onReplicatedHandleUpdated(v11, v10, "inline-log", v12)
		end
	end
end

function v9.MarkAsRead(p)
	local inlineLogState = getInlineLogState(p) -- equivalent call inferred; original call site unknown
	inlineLogState.New = 0
	inlineLogState.NewSeverity = nil
	local inlineLogState2 = getInlineLogState(p) -- equivalent call inferred; original call site unknown
	local v10 = object2[p] or rawget(p, 1)
	local v11 = object[p] or inlineLogState2.ParentLog
	local v12 = snapshotInlineLogState(inlineLogState2)
	rawset(p, 4, v12)

	if v11 and v10 then
		local v13 = object3[v11]

		if v13 and v13.ParentLog then
			v11 = rootLogFor(v13.ParentLog)
		elseif v11 and v11.IsInlineLog and v11.ParentLog then
			v11 = rootLogFor(v11.ParentLog)
		end

		local v14 = object3[v11]
		local v15

		if v14 and v14.ParentLog then
			v15 = rootLogFor(v14.ParentLog)
		elseif v11 and v11.IsInlineLog and v11.ParentLog then
			v15 = rootLogFor(v11.ParentLog)
		else
			v15 = v11
		end

		ensureHandleTables(v15)
		v15.ReplicatedHandleValues[v10] = {
			Kind = "inline-log",
			Value = v12
		}
		v15.ReplicatedHandleKinds[v10] = "inline-log"
		local _onReplicatedHandleUpdated = IrisLog._onReplicatedHandleUpdated

		if _onReplicatedHandleUpdated then
			_onReplicatedHandleUpdated(v11, v10, "inline-log", v12)
		end
	end
end

function v9.Show(p)
	local inlineLogState = getInlineLogState(p) -- equivalent call inferred; original call site unknown
	inlineLogState.Visible = true
	local inlineLogState2 = getInlineLogState(p) -- equivalent call inferred; original call site unknown
	local v10 = object2[p] or rawget(p, 1)
	local v11 = object[p] or inlineLogState2.ParentLog
	local v12 = snapshotInlineLogState(inlineLogState2)
	rawset(p, 4, v12)

	if v11 and v10 then
		local v13 = object3[v11]

		if v13 and v13.ParentLog then
			v11 = rootLogFor(v13.ParentLog)
		elseif v11 and v11.IsInlineLog and v11.ParentLog then
			v11 = rootLogFor(v11.ParentLog)
		end

		local v14 = object3[v11]
		local v15

		if v14 and v14.ParentLog then
			v15 = rootLogFor(v14.ParentLog)
		elseif v11 and v11.IsInlineLog and v11.ParentLog then
			v15 = rootLogFor(v11.ParentLog)
		else
			v15 = v11
		end

		ensureHandleTables(v15)
		v15.ReplicatedHandleValues[v10] = {
			Kind = "inline-log",
			Value = v12
		}
		v15.ReplicatedHandleKinds[v10] = "inline-log"
		local _onReplicatedHandleUpdated = IrisLog._onReplicatedHandleUpdated

		if _onReplicatedHandleUpdated then
			_onReplicatedHandleUpdated(v11, v10, "inline-log", v12)
		end
	end
end

function v9.Hide(p)
	local inlineLogState = getInlineLogState(p) -- equivalent call inferred; original call site unknown
	inlineLogState.Visible = false
	local inlineLogState2 = getInlineLogState(p) -- equivalent call inferred; original call site unknown
	local v10 = object2[p] or rawget(p, 1)
	local v11 = object[p] or inlineLogState2.ParentLog
	local v12 = snapshotInlineLogState(inlineLogState2)
	rawset(p, 4, v12)

	if v11 and v10 then
		local v13 = object3[v11]

		if v13 and v13.ParentLog then
			v11 = rootLogFor(v13.ParentLog)
		elseif v11 and v11.IsInlineLog and v11.ParentLog then
			v11 = rootLogFor(v11.ParentLog)
		end

		local v14 = object3[v11]
		local v15

		if v14 and v14.ParentLog then
			v15 = rootLogFor(v14.ParentLog)
		elseif v11 and v11.IsInlineLog and v11.ParentLog then
			v15 = rootLogFor(v11.ParentLog)
		else
			v15 = v11
		end

		ensureHandleTables(v15)
		v15.ReplicatedHandleValues[v10] = {
			Kind = "inline-log",
			Value = v12
		}
		v15.ReplicatedHandleKinds[v10] = "inline-log"
		local _onReplicatedHandleUpdated = IrisLog._onReplicatedHandleUpdated

		if _onReplicatedHandleUpdated then
			_onReplicatedHandleUpdated(v11, v10, "inline-log", v12)
		end
	end
end

v9.Print = v9.Append
local v10 = {
	__index = function(p, p2)
		local v11 = v9[p2]

		if v11 ~= nil then
			return v11
		end

		local v12 = object3[p]

		if v12 then
			return v12[p2]
		end

		return nil
	end,
	__newindex = function(p, value, p2)
		if typeof(value) == "number" then
			rawset(p, value, p2)
			return
		end

		local v11 = object3[p]

		if v11 then
			v11[value] = p2
		else
			rawset(p, value, p2)
		end
	end
}

function IrisLog.ReplicatedObjectHandle(p, value: string?)
	ensureHandleTables(p)

	if value == nil then
		value = nil
	else
		assert(typeof(value) == "string", "IrisLog handle id must be a string")
	end

	local v11 = value and p.ReplicatedObjectHandles[value]

	if v11 then
		return v11
	end

	local guid = createGuid() -- equivalent call inferred; original call site unknown
	local v12 = { guid, "object", "</robj>" }
	object[v12] = p
	object2[v12] = guid
	setmetatable(v12, {
		__index = v8
	})

	if value then
		p.ReplicatedObjectHandles[value] = v12
	end

	return v12
end

function IrisLog.InlineLogHandle(parentLog, value: string?)
	ensureHandleTables(parentLog)

	if value == nil then
		value = nil
	else
		assert(typeof(value) == "string", "IrisLog handle id must be a string")
	end

	local v11 = value and parentLog.InlineLogHandles[value]

	if v11 then
		return v11
	end

	local guid = createGuid() -- equivalent call inferred; original call site unknown
	local name = tostring(parentLog.Name or "Log")
	local v13

	if value then
		v13 = `{name}.{value}`
	else
		v13 = `InlineLog:{guid}`
	end

	local v14 = createBaseLog(v13, parentLog.Authority, nil)
	v14.Id = parentLog.Id
	v14.RemoteEvent = parentLog.RemoteEvent
	v14.TargetPlayer = parentLog.TargetPlayer
	v14.ButtonCallbacks = parentLog.ButtonCallbacks
	v14.IsInlineLog = true
	v14.ParentLog = parentLog
	v14.ParentHandleGuid = guid
	v14.ReplicatedHandleValues = parentLog.ReplicatedHandleValues
	v14.ReplicatedHandleKinds = parentLog.ReplicatedHandleKinds
	setmetatable(v14, IrisLog)
	local v15 = { guid, "inline-log", "</ilog>" }
	object[v15] = parentLog
	object2[v15] = guid
	object3[v15] = v14
	setmetatable(v15, v10)
	local inlineLogState = getInlineLogState(v15) -- equivalent call inferred; original call site unknown
	local v16 = object2[v15] or rawget(v15, 1)
	local v17 = object[v15] or inlineLogState.ParentLog
	local v18 = snapshotInlineLogState(inlineLogState)
	rawset(v15, 4, v18)

	if v17 and v16 then
		local v19 = object3[v17]

		if v19 and v19.ParentLog then
			v17 = rootLogFor(v19.ParentLog)
		elseif v17 and v17.IsInlineLog and v17.ParentLog then
			v17 = rootLogFor(v17.ParentLog)
		end

		ensureHandleTables(v17)
		v17.ReplicatedHandleValues[v16] = {
			Kind = "inline-log",
			Value = v18
		}
		v17.ReplicatedHandleKinds[v16] = "inline-log"
	end

	if value then
		parentLog.InlineLogHandles[value] = v15
	end

	return v15
end

if isServer then
	IrisLogServer.install(IrisLog, v3)

	function IrisLog._onReplicatedHandleUpdated(object4, p: string, p2: string, p3)
		for _, v11 in game.Players:GetPlayers() do
			local v12 = v11
			task.spawn(function()
				if object4:can_player_receive_log(v12) then
					v3.Script.event:FireClient(v12, "UpdateReplicatedObject", object4.Name, p, p2, p3)
				end
			end)
		end
	end

	function IrisLog:ReplicateClearTab(p: string)
		for _, v11 in game.Players:GetPlayers() do
			local v12 = v11
			task.spawn(function()
				if self:can_player_receive_log(v12) then
					v3.Script.event:FireClient(v12, "ClearTab", self.Name, p)
				end
			end)
		end
	end

	function IrisLog:ClearTab(p: string)
		local tab = findTab(self, p) -- equivalent call inferred; original call site unknown

		if not tab then
			return
		end

		clearLines(tab.Lines)
		self:ReplicateClearTab(p)
	end
else
	ClientRuntime.install(IrisLog, v3)
end

return IrisLog