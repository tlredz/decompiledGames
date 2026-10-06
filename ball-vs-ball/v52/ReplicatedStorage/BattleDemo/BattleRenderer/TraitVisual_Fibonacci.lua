local TraitVisualFibonacci = {}
TraitVisualFibonacci.__index = TraitVisualFibonacci

function TraitVisualFibonacci.new(ctx)
	local self = setmetatable({}, TraitVisualFibonacci)
	self._ctx = ctx
	return self
end

function TraitVisualFibonacci:resolveTemplateName(p2: number)
	if p2 <= 3 then
		local fibonacci = self._ctx.config.traits and self._ctx.config.traits.Fibonacci
		local assetName = fibonacci and fibonacci.assetName

		if type(assetName) == "string" and assetName ~= "" and assetName ~= "x" then
			return assetName
		end

		return "斐波那契撞击特效_一阶"
	elseif p2 <= 6 then
		return "斐波那契撞击特效_二阶"
	else
		return "斐波那契撞击特效_三阶"
	end
end

function TraitVisualFibonacci:playImpact(p)
	local templateName = self:resolveTemplateName(p.hitIndex or 1)
	self._ctx.playOneShotModelEffect(templateName, p.position)
end

function TraitVisualFibonacci.cleanupBall(_, _: string) end

function TraitVisualFibonacci.reset(_) end

return TraitVisualFibonacci