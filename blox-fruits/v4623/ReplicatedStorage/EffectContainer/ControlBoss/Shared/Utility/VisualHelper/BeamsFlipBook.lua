require(script.Bezier)
require(script.Trove)
local BeamsFlipBook = {}
BeamsFlipBook.__index = BeamsFlipBook

function BeamsFlipBook.new(value: number?, value2: number?, flag: boolean?, texture: string?)
	return (setmetatable({
		Beams = {},
		Frames = value or 16,
		Fps = value2 or 24,
		Looped = flag or false,
		Texture = texture
	}, BeamsFlipBook))
end

function BeamsFlipBook.Insert(p, _)
	return p
end

function BeamsFlipBook.Remove(p, _)
	return p
end

function BeamsFlipBook.Play(p)
	return p
end

function BeamsFlipBook.Stop(p)
	return p
end

function BeamsFlipBook.IsPlaying(p)
	return p
end

function BeamsFlipBook.Freeze(p)
	return p
end

function BeamsFlipBook.UnFreeze(p)
	return p
end

function BeamsFlipBook.GetBeams(p)
	return p
end

function BeamsFlipBook.ToggleBeams(p, _: boolean)
	return p
end

function BeamsFlipBook.Destroy(p)
	return p
end

return BeamsFlipBook