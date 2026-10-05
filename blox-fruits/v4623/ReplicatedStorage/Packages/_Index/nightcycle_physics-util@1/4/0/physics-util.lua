local Conversions = require(script.Conversions)
local PhysicsUtil = {}
PhysicsUtil.__index = PhysicsUtil
PhysicsUtil.C = 299792458
PhysicsUtil.R = 8.314
PhysicsUtil.GravityAcceleration = 9.8
PhysicsUtil.Avogadro = 6.0221417900000006e23
PhysicsUtil.Conversions = Conversions

function PhysicsUtil.getVelocityAtTime(p, p2, p3)
	return p + p2 * p3
end

function PhysicsUtil.getInitialVelocity(p, p2, p3)
	return p - p2 * p3
end

function PhysicsUtil.getAcceleration(p, p2, p3)
	return (p2 - p) / p3
end

function PhysicsUtil.getTimeSinceInitialVelocity(p, p2, p3)
	return (p2 - p) / p3
end

function PhysicsUtil.getDistanceAtTime(p, p2, p3)
	return p3 * (p + p2) / 2
end

function PhysicsUtil.getTimeAtDistance(p, p2, p3)
	return p3 / ((p + p2) / 2)
end

function PhysicsUtil.getInitialVelocityFromDistance(p, p2, p3)
	return p3 * p * 2 - p2
end

function PhysicsUtil.getVelocityFromDistance(p, p2, p3)
	return p3 * p * 2 - p2
end

function PhysicsUtil.getDistanceAtTimeFromInitialVelocityAndAcceleration(p, p2, p3)
	return p2 * p + 0.5 * p3 * p ^ 2
end

function PhysicsUtil.getInitialVelocityAtTimeFromDistanceAndAcceleration(p, p2, p3)
	return (p2 - 0.5 * p3 * p ^ 2) / p
end

function PhysicsUtil.getTimeAtDistanceFromInitialVelocityAndAcceleration(p, p2, p3)
	return (p2 - p) * 2 / p3
end

function PhysicsUtil.getAccelerationAtDistanceFromInitialVelocityAndTime(p, p2, p3)
	return (p2 - p * p3) * 2 / p3 ^ 2
end

function PhysicsUtil.getVelocityAtDistanceFromInitialVelocityAndAcceleration(p, p2, p3)
	return (p ^ 2 + 2 * p3 * p2) ^ 0.5
end

function PhysicsUtil.getInitialVelocityAtDistanceFromVelocityAndAcceleration(p, p2, p3)
	return (p ^ 2 - 2 * p3 * p2) ^ 0.5
end

function PhysicsUtil.getDistanceAtVelocityFromInitialVelocityAndAcceleration(p, p2, p3)
	return (p ^ 2 - p2 ^ 2) / (2 * p3)
end

function PhysicsUtil.getAccelerationAtVelocityFromInitialVelocityAndDistance(p, p2, p3)
	return (p ^ 2 - p2 ^ 2) / (2 * p3)
end

function PhysicsUtil.getForce(p, p2)
	return p * p2
end

function PhysicsUtil.getMassFromForce(p, p2)
	return p / p2
end

function PhysicsUtil.getAccelerationFromForce(p, p2)
	return p / p2
end

function PhysicsUtil.getKineticEnergy(p, p2)
	return 0.5 * p * p2 ^ 2
end

function PhysicsUtil.getMassFromKineticEnergyAndVelocity(p, p2)
	return 2 * p2 / p ^ 2
end

function PhysicsUtil.getVelocityFromKineticEnergyAndMass(p, p2)
	return (p2 * 2 / p) ^ 0.5
end

function PhysicsUtil.getMomentum(p, p2)
	return p * p2
end

function PhysicsUtil.getVelocityFromMomentumAndMass(p, p2)
	return p2 / p
end

function PhysicsUtil.getMassFromMomentumAndVelocity(p, p2)
	return p2 / p
end

function PhysicsUtil.getWork(p, p2)
	return p * p2
end

function PhysicsUtil.getForceFromWorkAndDistance(p, p2)
	return p / p2
end

function PhysicsUtil.getDistanceFromWorkAndForce(p, p2)
	return p / p2
end

function PhysicsUtil.getPower(p, p2)
	return p / p2
end

function PhysicsUtil.getPowerFromForceAndVelocity(p, p2)
	return p * p2
end

function PhysicsUtil.getVelocityFromPowerAndForce(p, p2)
	return p2 / p
end

function PhysicsUtil.getForceFromPowerAndVelocity(p, p2)
	return p2 / p
end

function PhysicsUtil.getWorkFromPowerAndTime(p, p2)
	return p * p2
end

function PhysicsUtil.getTimeFromPowerAndWork(p, p2)
	return p2 / p
end

function PhysicsUtil.getVoltage(p, p2)
	return p * p2
end

function PhysicsUtil.getResistance(p, p2)
	return p / p2
end

function PhysicsUtil.getCurrent(p, p2)
	return p / p2
end

function PhysicsUtil.getDragEnergy(p, p2, p3, p4: number)
	return 0.5 * p * p2 ^ 2 * p4 * p3
end

function PhysicsUtil.getDragCoefficient(p, p2, p3, p4)
	return p4 / (0.5 * p * p2 ^ 2 * p3)
end

function PhysicsUtil.getDragArea(p, p2, p3: number, p4)
	return p4 / (0.5 * p * p2 ^ 2 * p3)
end

function PhysicsUtil.getDragVelocity(p, p2, p3: number, p4)
	return (p4 / (0.5 * p * p3 * p2)) ^ 0.5
end

function PhysicsUtil.getDragFluidDensity(p, _, p2: number, p3)
	return p3 / (p2 * 0.5 * p ^ 2 * p2)
end

function PhysicsUtil.getFrictionForce(p, p2: number)
	return p * p2
end

function PhysicsUtil.getFrictionCoefficient(p, p2)
	return p / p2
end

function PhysicsUtil.getFrictionNormalForce(p, p2: number)
	return p / p2
end

function PhysicsUtil.getPressureFromAreaAndForce(p, p2)
	return p / p2
end

function PhysicsUtil.getPressureFromVolumeAndTemperatureAndAtoms(p, p2: number, p3)
	return p2 * PhysicsUtil.R * p3 / p
end

function PhysicsUtil.getTemperatureFromVolumeAndPressureAndAtoms(p, p2: number, p3)
	return p3 * p / (p2 * PhysicsUtil.R)
end

function PhysicsUtil.getVolumeFromTemperatureAndPressureAndAtoms(p: number, p2, p3)
	return p * PhysicsUtil.R * p3 / p2
end

function PhysicsUtil.getAtomCountFromTemperatureAndPressureAndVolume(p, p2, p3)
	return p2 * p / (PhysicsUtil.R * p3)
end

function PhysicsUtil.getHeatEnergy(p, p2: number, p3)
	return p * p2 * p3
end

function PhysicsUtil.getHeatCapacity(p, p2, p3)
	return p2 / (p * p3)
end

function PhysicsUtil.getDeltaTemperature(p, p2, p3: number)
	return p2 / (p * p3)
end

function PhysicsUtil.getMassFromDeltaTemperatureAndHeatEnergyAndHeatCapacity(p, p2, p3: number)
	return p2 / (p * p3)
end

function PhysicsUtil.getTorque(p, p2)
	return p * p2
end

function PhysicsUtil.getTangentialForce(p, p2)
	return p / p2
end

function PhysicsUtil.getRadiusFromForce(p, p2)
	return p / p2
end

function PhysicsUtil.getAngularMomentum(p, p2)
	return p * p2
end

function PhysicsUtil.getTangentialMomentum(p, p2)
	return p2 / p
end

function PhysicsUtil.getRadiusFromMomentum(p, p2)
	return p2 / p
end

return PhysicsUtil