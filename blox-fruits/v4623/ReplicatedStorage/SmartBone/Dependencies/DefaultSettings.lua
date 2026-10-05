local createVector = vector.create
return {
	Damping = 0.1,
	Stiffness = 0.2,
	Inertia = 0,
	Elasticity = 0.5,
	BlendWeight = 1,
	Radius = 0.2,
	AnchorDepth = 0,
	Force = createVector(0, 0.2, 0),
	Gravity = createVector(-0, -1, -0),
	WindDirection = createVector(-1, -0, -0),
	WindSpeed = 8,
	WindStrength = 1,
	WindInfluence = 1,
	AnchorsRotate = false,
	UpdateRate = 60,
	ActivationDistance = 45,
	ThrottleDistance = 15
}