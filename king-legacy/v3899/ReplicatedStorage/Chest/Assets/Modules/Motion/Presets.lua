local createVector = vector.create
local Presets = {}

function Presets.Rise(p)
	p._Magnitude = 1
	p._Roughness = 2
	p._FadeIn = 0
	p._FadeOut = 0.25
	p._Duration = 0.25
	p._PositionInfluence = createVector(4, 1, 1)
	return p
end

function Presets.Roar(p)
	p._Magnitude = 3
	p._Roughness = 10
	p._FadeIn = 0.3
	p._FadeOut = 0.75
	p._Duration = 0.5
	p._PositionInfluence = createVector(1, 1, 1)
	return p
end

function Presets.Hit(p)
	p._Magnitude = 1.5
	p._Roughness = 10
	p._FadeIn = 0
	p._FadeOut = 0
	p._Duration = 0.25
	p._PositionInfluence = createVector(1, 1, 1)
	return p
end

function Presets.Stun(p)
	p._Magnitude = 2
	p._Duration = 3
	p._Roughness = 3.5
	p._FadeIn = 0.25
	p._FadeOut = 1
	p._PositionInfluence = createVector(1, 1, 1)
	return p
end

function Presets.Earthquake(p)
	p._Magnitude = 2
	p._Duration = 5
	p._Roughness = 80
	p._FadeIn = 1.5
	p._FadeOut = 0.5
	p._PositionInfluence = createVector(1, 1, 1)
	return p
end

function Presets.Explosion(p)
	p._Magnitude = 2
	p._Duration = 0.75
	p._Roughness = 10
	p._FadeIn = 0.1
	p._FadeOut = 0.5
	p._PositionInfluence = createVector(1.75, 1, 1)
	return p
end

function Presets.Bump(p)
	p._Magnitude = 1.5
	p._Duration = 1
	p._FadeOut = 0.75
	p._PositionInfluence = createVector(1, 1, 1)
	return p
end

return Presets