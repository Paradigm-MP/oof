Vector3Math = class()
-- Static Vector3 class for vector3 math

function Vector3Math:Distance(position_a, position_b)
    return #(position_a - position_b)
end

function Vector3Math:RotationToDirection(rotation)
    local adjustedRotation = 
	{
		x = (math.pi / 180) * rotation.x, 
		y = (math.pi / 180) * rotation.y, 
		z = (math.pi / 180) * rotation.z 
	}
	local direction = 
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		z = math.sin(adjustedRotation.x)
    }
    
	return vector3(direction.x, direction.y, direction.z)
end

Vector3Math = Vector3Math()
