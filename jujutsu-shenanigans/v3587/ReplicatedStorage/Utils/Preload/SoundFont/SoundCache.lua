local SoundCache = {
	_sounds = {},
	CreateSound = function(self)
		return (Instance.new("Sound"))
	end,
	GetSound = function(self)
		if #self._sounds == 0 then
			for _ = 1, 5 do
				table.insert(self._sounds, self:CreateSound())
			end
		end

		local _sound = self._sounds[#self._sounds]
		self._sounds[#self._sounds] = nil
		return _sound
	end,
	ReturnSound = function(p, object)
		if object.Playing then
			object:Stop()
		end

		object.SoundGroup = nil
		object.Parent = nil
		task.delay(0.03333333333333333, function()
			table.insert(p._sounds, object)
		end)
	end
}

for _ = 1, 50 do
	table.insert(SoundCache._sounds, SoundCache:CreateSound())
end

return SoundCache