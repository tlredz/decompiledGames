local Ripple = require(script.Parent.Ripple)
local useMotion = require(script.useMotion)
local useSpring = require(script.useSpring)
local useTween = require(script.useTween)
return {
	config = Ripple.config,
	easing = Ripple.easing,
	createMotion = Ripple.createMotion,
	createSpring = Ripple.createSpring,
	createTween = Ripple.createTween,
	useMotion = useMotion,
	useSpring = useSpring,
	useTween = useTween
}