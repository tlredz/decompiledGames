local createVector = vector.create
return table.freeze({
	Damping = 0.1,
	Stiffness = 0.2,
	Inertia = 0,
	Elasticity = 3,
	AnchorDepth = 0,
	AnchorsRotate = false,
	Constraint = "Spring",
	Force = createVector(0, 0.2, 0),
	Gravity = createVector(-0, -25, -0),
	WindType = "Hybrid",
	MatchWorkspaceWind = true,
	WindInfluence = 1,
	WindStrength = 2,
	WindSpeed = 1,
	WindDirection = createVector(1, 0, 0),
	UpdateRate = 60,
	ActivationDistance = 45,
	ThrottleDistance = 15
})