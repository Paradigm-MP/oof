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

function Vector3Math:RadToDeg(rad)
	return rad * 180 / math.pi
end

-- Adapted from https://github.com/citizenfx/fivem/blob/master/code/client/clrcore/Math/GameMath.cs
function Vector3Math:RotationToDirection2(dir, roll)
	dir = dir / Vector3Math:Length(dir)
	local rotval_z = -Vector3Math:RadToDeg(math.atan2(dir.x, dir.y));
	local rotpos = vector3(dir.z, Vector3Math:Length(vector3(dir.x, dir.y, 0.0)), 0.0)
	rotpos = rotpos / Vector3Math:Length(rotpos)
	local rotval_x = Vector3Math:RadToDeg(math.atan2(rotpos.x, rotpos.y))
	local rotval_y = roll or 0
	return vector3(rotval_x, rotval_y, rotval_z)
end

function Vector3Math:Lerp(a, b, factor)
	local diff = b - a
	return a + factor * diff
end

function Vector3Math:Length(a)
	return math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
end

function Vector3Math:LerpOverTime(a, b, time, callback)
	local timer = Timer()
	Citizen.CreateThread(function()
		local ms = timer:GetMilliseconds()
		while ms < time do
			ms = timer:GetMilliseconds()
			callback(Vector3Math:Lerp(a, b, ms / time), false)
			Wait(1)
		end
		callback(Vector3Math:Lerp(a, b, ms / time), true)
	end)
end

Vector3Math = Vector3Math()
