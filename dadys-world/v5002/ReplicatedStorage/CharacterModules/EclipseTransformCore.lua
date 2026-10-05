local EclipseTransformCore = {
	newRecord = function()
		return {
			generation = 0,
			phase = nil,
			transformed = false,
			applied = {}
		}
	end,
	isBusy = function(p)
		return p.phase ~= nil
	end
}

function EclipseTransformCore.canStart(p, p2: string)
	if EclipseTransformCore.isBusy(p) then
		return false
	end

	if p2 == "on" then
		return not p.transformed
	end

	return p.transformed
end

function EclipseTransformCore:begin(phase: string)
	self.generation += 1
	self.phase = phase
	return self.generation
end

function EclipseTransformCore.owns(p, p2: number)
	return p.phase ~= nil and p.generation == p2
end

function EclipseTransformCore.current(p, p2: number)
	return p.generation == p2
end

function EclipseTransformCore:finish(p2: number, transformed: boolean)
	if not EclipseTransformCore.owns(self, p2) then
		return false
	end

	self.phase = nil
	self.transformed = transformed
	return true
end

function EclipseTransformCore:cancel()
	self.generation += 1
	self.phase = nil
end

function EclipseTransformCore.mark(p, p2: string)
	if p.applied[p2] then
		return false
	end

	p.applied[p2] = true
	return true
end

function EclipseTransformCore.take(p, p2: string)
	if not p.applied[p2] then
		return false
	end

	p.applied[p2] = nil
	return true
end

function EclipseTransformCore.nextStep(p, flag: boolean)
	if EclipseTransformCore.isBusy(p) or p.transformed == flag then
		return nil
	end

	if flag then
		return "on"
	end

	return "off"
end

return EclipseTransformCore