local Ticker = require(script.Parent:WaitForChild("Ticker"))
local Store = require(script.Parent:WaitForChild("Store"))
local SpritePlayer = {}
local v = Store.new()
local class = {}
class.__index = class

local function readOpts(image, options)
	local v2 = options or {}
	local cells = v2.Cells or image:GetAttribute("Cells") or Vector2.new(1, 1)
	local FPS = v2.FPS or image:GetAttribute("FPS") or 15
	local loop = v2.Loop

	if loop == nil then
		loop = image:GetAttribute("Loop")
	end

	return
		cells,
		FPS,
		loop == nil or loop,
		math.max(1, v2.Frames or image:GetAttribute("Frames") or math.floor(cells.X * cells.Y)),
		v2.OnDone,
		v2.Keep == true
end

function class:_show(p)
	local offsets = self.offsets

	if not offsets then
		local X = self.cells.X
		local imageRectSize = self.image.ImageRectSize
		offsets = table.create(self.frames)

		for i = 0, self.frames - 1 do
			offsets[i + 1] = Vector2.new(imageRectSize.X * (i % X), imageRectSize.Y * math.floor(i / X))
		end

		self.offsets = offsets
	end

	self.image.ImageRectOffset = offsets[p + 1]
end

function class:_step(p)
	if self.paused then
		return
	end

	self.acc += p
	local v2 = 1 / self.fps

	if self.acc < v2 then
		return
	end

	local v3 = math.floor(self.acc / v2)
	self.acc -= v3 * v2
	local frame = self.frame + v3

	if self.frames <= frame then
		if self.loop then
			frame %= self.frames
		else
			self:_show(self.frames - 1)
			self.frame = self.frames - 1

			if self.keep then
				self.paused = true
			else
				self:Stop()
			end

			self.finished = true

			if self.onDone then
				task.spawn(self.onDone)
			end

			self.Done:Fire()
			return
		end
	end

	self.frame = frame
	self:_show(frame)
end

function class:Restart()
	self.frame = 0
	self.acc = 0
	self.finished = false
	self.paused = false
	self:_show(0)

	if not self.ticker then
		v[self.image] = self
		self.ticker = Ticker.whileVisible(self.image, function(p)
			self:_step(p)
		end)
	end
end

function class:Pause()
	self.paused = true
end

function class:Resume()
	self.paused = false
end

function class:Stop()
	if self.ticker then
		self.ticker:Stop()
		self.ticker = nil
	end

	if v[self.image] == self then
		v[self.image] = nil
	end
end

function class:Destroy()
	self:Stop()
	self.Done:Destroy()
end

function SpritePlayer.play(image, p)
	local v2 = v[image]

	if v2 then
		v2:Stop()
	end

	local self = setmetatable({}, class)
	self.image = image
	local cells, fps, loop, frames, onDone, keep = readOpts(image, p)
	self.cells = cells
	self.fps = fps
	self.loop = loop
	self.frames = frames
	self.onDone = onDone
	self.keep = keep
	self.Done = Instance.new("BindableEvent")
	self.frame = 0
	self.acc = 0
	v[image] = self
	self:Restart()
	return self
end

function SpritePlayer.attach(p)
	return SpritePlayer.play(p)
end

function SpritePlayer.attachAll(folder)
	local v2 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function try(guiObject)
		if (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) and guiObject:GetAttribute("Cells") then
			v2[#v2 + 1] = SpritePlayer.play(guiObject)
		end
	end

	try(folder) -- equivalent call inferred; original call site unknown

	for _, descendant in ipairs(folder:GetDescendants()) do
		try(descendant) -- equivalent call inferred; original call site unknown
	end

	return v2
end

function SpritePlayer.stop(p)
	local v2 = v[p]

	if v2 then
		v2:Stop()
	end
end

function SpritePlayer.once(p, options)
	local v2 = options or {}
	v2.Loop = false
	local v3 = SpritePlayer.play(p, v2)

	if not v3.finished then
		v3.Done.Event:Wait()
	end

	v3.Done:Destroy()
	return v3
end

function SpritePlayer.get(p)
	return v[p]
end

return SpritePlayer