local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Log = require(ReplicatedStorage.Packages.Log)
require(script.Parent.Types.Interface)
local v = Log.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function clearSlot(p)
	p.Frame:Pause()
	p.Frame.TimePosition = 0
	p.Frame.Volume = 0
	p.Frame.Visible = false
	p.Frame.Video = ""
	p.MediaIndex = nil
	p.VideoUri = nil
end

local function assignSlot(state, mediaIndex: number, p)
	if state.MediaIndex == mediaIndex and state.VideoUri == p.Video then
		return
	end

	clearSlot(state) -- equivalent call inferred; original call site unknown
	state.MediaIndex = mediaIndex
	state.VideoUri = p.Video
	state.Frame.Video = p.Video
end

local function primeHiddenSlot(state, mediaIndex: number, mediaEntry)
	if state.MediaIndex ~= mediaIndex or state.VideoUri ~= mediaEntry.Video then
		clearSlot(state) -- equivalent call inferred; original call site unknown
		state.MediaIndex = mediaIndex
		state.VideoUri = mediaEntry.Video
		state.Frame.Video = mediaEntry.Video
	end

	state.Frame.Visible = false
	state.Frame.Volume = 0
	state.Frame.TimePosition = 0
	local success, result = pcall(function()
		state.Frame:Play()
		state.Frame:Pause()
		state.Frame.TimePosition = 0
	end)

	if success then
		return true
	end

	v:AtWarning():Log((`Failed to prime treadmill VideoFrame {mediaEntry.Video}: {result}`))
	return false
end

local function createCloneSlot(instance, p: number)
	local clone = instance:Clone()
	clone.Name = `MainVideoPreload{p}`
	clone.Visible = false
	clone.Video = ""
	clone.Volume = 0
	clone.TimePosition = 0
	clone.Parent = instance.Parent
	return {
		Frame = clone,
		MediaIndex = nil,
		VideoUri = nil
	}
end

return {
	new = function(self)
		self.Looped = false
		local v2 = {
			{
				Frame = self,
				MediaIndex = nil,
				VideoUri = nil
			}
		}
		local v3 = nil
		local flag = false
		local clone = self:Clone()
		clone.Name = `MainVideoPreload{2}`
		clone.Visible = false
		clone.Video = ""
		clone.Volume = 0
		clone.TimePosition = 0
		clone.Parent = self.Parent
		table.insert(v2, {
			Frame = clone,
			MediaIndex = nil,
			VideoUri = nil
		})
		local clone2 = self:Clone()
		clone2.Name = `MainVideoPreload{3}`
		clone2.Visible = false
		clone2.Video = ""
		clone2.Volume = 0
		clone2.TimePosition = 0
		clone2.Parent = self.Parent
		table.insert(v2, {
			Frame = clone2,
			MediaIndex = nil,
			VideoUri = nil
		})

		-- equivalent calls inferred from this helper; original call sites unknown
		local function findSlotByMediaIndex(p: number)
			for _, v4 in v2 do
				if v4.MediaIndex == p then
					return v4
				end
			end

			return nil
		end

		local function acquireInactiveSlot(mediaIndex: number)
			local slotByMediaIndex = findSlotByMediaIndex(mediaIndex) -- equivalent call inferred; original call site unknown

			if slotByMediaIndex ~= nil then
				return slotByMediaIndex
			end

			for _, v4 in v2 do
				if v4 ~= v3 and v4.MediaIndex == nil then
					return v4
				end
			end

			for _, v4 in v2 do
				if v4 == v3 then
					continue
				end

				clearSlot(v4) -- equivalent call inferred; original call site unknown
				return v4
			end

			error("Treadmill VideoFrame pool has no inactive slot available")
		end

		local function getActiveFrame()
			local v4 = v3

			if v4 == nil then
				return self
			end

			return v4.Frame
		end

		local function clearActive()
			local v4 = v3
			v3 = nil

			if v4 == nil then
				return
			end

			clearSlot(v4) -- equivalent call inferred; original call site unknown
		end

		local function preload(list)
			if flag then
				return
			end

			local v4 = v3 == nil and 3 or 2
			local count = 0
			local mediaEntriesByMediaIndex = {}

			for _, v5 in ipairs(list) do
				if v4 <= count then
					break
				end

				mediaEntriesByMediaIndex[v5.MediaIndex] = v5.MediaEntry
				count += 1
			end

			for _, v5 in v2 do
				if not (v5 ~= v3 and v5.MediaIndex ~= nil and mediaEntriesByMediaIndex[v5.MediaIndex] == nil) then
					continue
				end

				clearSlot(v5) -- equivalent call inferred; original call site unknown
			end

			for _, v5 in ipairs(list) do
				if mediaEntriesByMediaIndex[v5.MediaIndex] == nil then
					break
				else
					local v6 = v5
					task.spawn(function()
						if flag then
							return
						end

						primeHiddenSlot(acquireInactiveSlot(v6.MediaIndex), v6.MediaIndex, v6.MediaEntry)
					end)
				end
			end
		end

		local function activate(mediaIndex: number, p)
			if flag then
				return self
			end

			local slotByMediaIndex = findSlotByMediaIndex(mediaIndex) -- equivalent call inferred; original call site unknown
			local v4 = slotByMediaIndex or acquireInactiveSlot(mediaIndex)

			if v4.MediaIndex ~= mediaIndex or v4.VideoUri ~= p.Video then
				clearSlot(v4) -- equivalent call inferred; original call site unknown
				v4.MediaIndex = mediaIndex
				v4.VideoUri = p.Video
				v4.Frame.Video = p.Video
			end

			for _, v5 in v2 do
				v5.Frame.Visible = v5 == v4

				if v5 == v4 then
					continue
				end

				v5.Frame:Pause()
				v5.Frame.Volume = 0
				v5.Frame.TimePosition = 0
			end

			v3 = v4
			v4.Frame.Volume = p.Volume or 1
			v4.Frame.TimePosition = 0
			return v4.Frame
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function clearAll()
			v3 = nil

			for _, v4 in v2 do
				clearSlot(v4) -- equivalent call inferred; original call site unknown
			end
		end

		local function destroy()
			flag = true
			clearAll() -- equivalent call inferred; original call site unknown

			for i = 2, #v2 do
				v2[i].Frame:Destroy()
			end
		end

		return {
			Activate = activate,
			ClearActive = clearActive,
			ClearAll = clearAll,
			Destroy = destroy,
			GetActiveFrame = getActiveFrame,
			Preload = preload
		}
	end
}