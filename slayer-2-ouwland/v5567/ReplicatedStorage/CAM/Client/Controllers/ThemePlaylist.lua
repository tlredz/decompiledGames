local ReplicatedStorage = game:GetService("ReplicatedStorage")
task.wait()
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local TweenService = game:GetService("TweenService")
local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local SettingsKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
local v = DataValue.new(SettingsKeys.ThemeVolume.Path, SettingsKeys.ThemeVolume.Default, SettingsKeys.Scope)

-- equivalent calls inferred from this helper; original call sites unknown
local function volumeShare()
	local v2 = v:Get()

	if type(v2) == "number" then
		return (math.clamp(v2, 0, 1))
	end

	return 1
end

local ThemePlaylist = {
	UpdStatus = simplesignal.new(),
	currentSong = 0,
	Playing = true,
	currentPlayList = {}
}
local v2 = 0
local insert = table.insert
local v3 = {}
local v4 = nil
v.Changed:Connect(function()
	local v5 = #ThemePlaylist.currentPlayList > 0 and ThemePlaylist.currentPlayList[ThemePlaylist.currentSong] or nil

	if v5 ~= nil and v5.IsPlaying then
		local DV = v5:GetAttribute("DV")
		local v6 = DV or v5.Volume

		if DV == nil then
			v5:SetAttribute("DV", v5.Volume)
		end

		v5.Volume = v6 * volumeShare()
	end
end)

function ThemePlaylist:PauseOrUnPause()
	for _, connection in pairs(v3) do
		connection:Disconnect()
	end

	v3 = {}
	local v5 = math.random(1, 999)
	v2 = v5
	local v6 = #ThemePlaylist.currentPlayList > 0 and ThemePlaylist.currentPlayList[ThemePlaylist.currentSong] or nil

	if v4 ~= nil and v4 ~= v6 then
		local v7 = v4
		task.spawn(function()
			if v7:GetAttribute("DV") == nil then
				v7:SetAttribute("DV", v7.Volume)
			end

			TweenService:Create(v7, TweenInfo.new(1), {
				Volume = 0
			}):Play()
			task.wait(1)

			if v2 == v5 then
				v7:Stop()
			end
		end)
	end

	if self == nil then
		if v6 == nil then
			ThemePlaylist.Playing = not ThemePlaylist.Playing
			ThemePlaylist.UpdStatus:Fire()
		end
	elseif ThemePlaylist.Playing then
		ThemePlaylist.Playing = false
		ThemePlaylist.UpdStatus:Fire()
	end

	if v6 then
		if ThemePlaylist.Playing then
			ThemePlaylist.Playing = false
			ThemePlaylist.UpdStatus:Fire()

			if v6.IsPlaying == true then
				if v6:GetAttribute("DV") == nil then
					v6:SetAttribute("DV", v6.Volume)
				end

				TweenService:Create(v6, TweenInfo.new(1), {
					Volume = 0
				}):Play()
				task.wait(1)

				if v2 == v5 then
					v6:Pause()
				end
			end
		else
			ThemePlaylist.Playing = true
			ThemePlaylist.UpdStatus:Fire()
			v6:Resume()
			v4 = v6
			local DV = v6:GetAttribute("DV")
			local v7 = DV or v6.Volume

			if DV == nil then
				v6:SetAttribute("DV", v6.Volume)
			end

			v6.Volume = 0
			TweenService:Create(v6, TweenInfo.new(1), {
				Volume = v7 * volumeShare()
			}):Play()
			local endedConnection = v6.Ended:Once(function()
				if v2 == v5 then
					ThemePlaylist:Skip()
				end
			end)
			insert(v3, endedConnection)
		end
	end
end

function ThemePlaylist.Skip()
	if ThemePlaylist.currentSong < #ThemePlaylist.currentPlayList then
		ThemePlaylist.currentSong += 1
	else
		ThemePlaylist.currentSong = 1
	end

	ThemePlaylist.Playing = false
	ThemePlaylist:PauseOrUnPause()
end

function ThemePlaylist.Rewind()
	if ThemePlaylist.currentSong > 1 and #ThemePlaylist.currentPlayList > 1 then
		ThemePlaylist.currentSong -= 1
	else
		ThemePlaylist.currentSong = math.max(#ThemePlaylist.currentPlayList, 1)
	end

	ThemePlaylist.Playing = false
	ThemePlaylist:PauseOrUnPause()
end

function ThemePlaylist.SetPlaylist(currentPlayList)
	ThemePlaylist.currentPlayList = currentPlayList

	for _, v5 in pairs(currentPlayList) do
		v5:Stop()
	end

	ThemePlaylist.currentSong = math.clamp(ThemePlaylist.currentSong, 1, (math.max(#currentPlayList, 1)))

	if ThemePlaylist.Playing == true then
		ThemePlaylist.Playing = false
	else
		ThemePlaylist.Playing = true
	end

	ThemePlaylist:PauseOrUnPause(true)
end

return ThemePlaylist