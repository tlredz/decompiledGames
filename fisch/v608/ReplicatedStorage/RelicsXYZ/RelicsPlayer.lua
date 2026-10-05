local RunService = game:GetService("RunService")
local class = {}
class.__index = class
local Enums = require(script.Enums)
local State = require(script.State)
local shared = script.Parent.Shared
local React = require(shared.React)
local ReactRoblox = require(shared.ReactRoblox)
local Tags = require(shared.Tags)
require(shared.Signal)
local components = script.Components
local MainWindow = require(components.MainWindow)
local EquipWheelController = require(components.EquipWheelController)
local v = {
	{
		sheet = "MainWindow",
		derives = {
			"CollectPage",
			"LibraryPage",
			"Player",
			"CustomizePage",
			"ItemViewerPage",
			"StartCollectPage",
			"LibraryPage",
			"EquipWheel"
		}
	}
}

local function App(p)
	return React.createElement(State.Driver, {
		Ports = p.Ports
	}, {
		RelicsPlayer = p.Enabled and React.createElement(MainWindow),
		EquipWheelController = p.Enabled and React.createElement(EquipWheelController)
	})
end

function class.refreshStyleSheets()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function reload(p)
		local parent = p.Parent
		p.Parent = nil
		RunService.Heartbeat:Wait()
		p.Parent = parent
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function reloadByTag(p: string)
		local v2 = nil
		v2 = Tags.Bind(p, function(instance)
			task.spawn(function()
				for _, v3 in v do
					local child = instance:FindFirstChild(v3.sheet)

					if not child then
						continue
					end

					if v3.derives then
						for _, childName in v3.derives do
							local child2 = child:FindFirstChild(childName)

							if not child2 then
								continue
							end

							reload(child2) -- equivalent call inferred; original call site unknown
						end
					else
						for _, styleDerive in child:GetChildren() do
							if not styleDerive:IsA("StyleDerive") then
								continue
							end

							reload(styleDerive) -- equivalent call inferred; original call site unknown
						end
					end
				end

				if v2 and typeof(v2) == "table" and v2.Destroy then
					v2:Destroy()
				end
			end)
		end)
	end

	reloadByTag("RelicsDesign") -- equivalent call inferred; original call site unknown
	reloadByTag("StyleSheetOption") -- equivalent call inferred; original call site unknown
end

function class:SetEnabled(enabled: boolean)
	if self._enabled == enabled then
		return
	end

	local element = React.createElement(App, {
		Ports = self._internal,
		Enabled = enabled
	})
	self._root:render(element)
	self._enabled = enabled
end

function class:SetVolume(value: number)
	local volume = math.clamp(value, 0, 1)

	if self._enabled then
		self._internal.SetVolume:Fire(volume)
	else
		self._internal.Volume = volume
	end
end

function class:SetWindowTab(p2)
	local windowTab = Enums.WindowTab[p2]

	if not windowTab then
		return false
	end

	local _internal = self._internal

	if self._enabled then
		_internal.SetWindowTab:Fire(windowTab)
	else
		_internal.WindowTab = windowTab
	end

	_internal.SetWindowTab:Fire(windowTab)
	return true
end

function class:SetWindowState(p2)
	local windowState = Enums.WindowState[p2]

	if not windowState then
		return false
	end

	local _internal = self._internal

	if self._enabled then
		_internal.SetWindowState:Fire(windowState)
	else
		_internal.WindowState = windowState
	end

	return true
end

function class:SetVolumeMod(p2, p3: number?)
	self._internal.SetVolumeMod:Fire(p2, p3)
end

function class:SetPlaying(playing: boolean)
	self._internal.Playing = playing
	self._internal.SetPlaying:Fire(playing)
end

function class:SetSong(song: string)
	if self._enabled then
		self._internal.SetSong:Fire(song)
	else
		self._internal.Song = song
	end
end

function class:SetQueue(queue)
	if self._enabled then
		self._internal.SetQueue:Fire(queue)
	else
		self._internal.Queue = queue
	end
end

function class:GetSongList(_)
	return self._internal.SongList or {}
end

function class:SetSongList(songList)
	if self._enabled then
		self._internal.SetSongList:Fire(songList)
	else
		self._internal.SongList = songList
	end
end

function class:SetLooping(looped: boolean)
	if self._enabled then
		self._internal.SetLooped:Fire(looped)
	else
		self._internal.Looped = looped
	end
end

function class:GetShuffled()
	return self._internal.Shuffled or false
end

function class:SetShuffled(shuffled: boolean)
	if self._enabled then
		self._internal.SetShuffled:Fire(shuffled)
	else
		self._internal.Shuffled = shuffled
	end
end

function class:UserHasBoombox()
	return self._internal.HasBoombox or false
end

function class:GetWindowTab()
	local windowTab = self._internal.WindowTab

	if windowTab then
		return (Enums.GetName(Enums.WindowTab, windowTab))
	end

	return "Collect"
end

function class:GetWindowState()
	local windowState = self._internal.WindowState

	if windowState then
		return (Enums.GetName(Enums.WindowState, windowState))
	end

	return "Hidden"
end

function class:GetSong()
	return self._internal.Song
end

function class:GetVolume()
	return self._internal.Volume or 0
end

function class:IsLooping()
	return self._internal.Looped or false
end

function class:IsPlaying()
	return self._internal.Playing or false
end

function class:GetQueue()
	return self._internal.Queue or {}
end

function class:SetPosition(position: UDim2)
	if self._enabled then
		self._internal.SetPosition:Fire(position)
	else
		self._internal.Position = position
	end
end

function class:SetEquipWheelOpen(equipWheelOpen: boolean)
	if self._enabled then
		self._internal.SetEquipWheelOpen:Fire(equipWheelOpen)
	else
		self._internal.EquipWheelOpen = equipWheelOpen
	end
end

function class:GetEquipWheelOpen()
	return self._internal.EquipWheelOpen or false
end

return table.freeze({
	new = function(p)
		local ports = State.CreatePorts()
		local self = setmetatable({
			_root = ReactRoblox.createRoot(p, {
				hydrate = true
			}),
			_enabled = false,
			_internal = ports,
			SongChanged = ports.SongChanged,
			QueueChanged = ports.QueueChanged,
			VolumeChanged = ports.VolumeChanged,
			PlayingChanged = ports.PlayingChanged,
			ShuffledChanged = ports.ShuffledChanged,
			WindowTabChanged = ports.WindowTabChanged,
			HasBoomboxChanged = ports.HasBoomboxChanged,
			WindowStateChanged = ports.WindowStateChanged,
			EquipWheelOpenChanged = ports.EquipWheelOpenChanged
		}, class)
		class.refreshStyleSheets()
		return self
	end
})