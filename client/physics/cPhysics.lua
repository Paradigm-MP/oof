Physics = class()

--[[
    Casts a ray from a point to another point.

    startpos - vector3
    endpos - vector3
    flags - intersection bit flags of what to hit. -1 presumably hits everything
        1: Intersect with map  
        2: Intersect with vehicles (used to be mission entities?) (includes train)  
        4: Intersect with peds? (same as 8)  
        8: Intersect with peds? (same as 4)  
        16: Intersect with objects  
        32: Water?  
        64: Unknown  
        128: Unknown  
        256: Intersect with vegetation (plants, coral. trees not included)  
        NOTE: Raycasts that intersect with mission_entites (flag = 2) has limited range and will not register for far away entites. 
        The range seems to be about 30 metres.  
    ignore_entity (optional) - an entity to ignore when raycasting
    
    returns - table containing:
                retval - (int)
                hit - (bool) whether it hit anything. False if it reached its destination
                position - (vector3) the position hit by the ray. if it does not hit anything, it will be equal to endpos
                normal - (vector3) surface normal coords of where the ray hit
                entity - (entity) handle of the entity hit by the ray

]]
function Physics:Raycast(startpos, endpos, flags, ignore_entity)
    TypeCheck:Position3D(startpos)
    TypeCheck:Position3D(endpos)
    
    local result = self:GetShapeTestResult(StartShapeTestRay(startpos.x, startpos.y, startpos.z, endpos.x, endpos.y, endpos.z, flags or -1, ignore_entity or 0, 1))
    result.hit = result.hit == 1
    
    if not result.hit then
        result.position = endpos
    end

    return result
end

--[[
    Casts a ray with radius from a point to another point. Basically a cylinder.

    
    startpos - vector3
    endpos - vector3
    flags - intersection bit flags of what to hit
        vehicles=10  
        peds =12  
        Iterating through flags yields many ped / vehicle/ object combinations   
    ignore_entity - an entity to ignore when raycasting
    radius - number of the radius of the ray
    
    returns - table containing:
                retval - (int)
                hit - (bool) whether it hit anything. False if it reached its destination
                position - (vector3) the position hit by the ray
                normal - (vector3) surface normal coords of where the ray hit
                entity - (entity) handle of the entity hit by the ray
]]
function Physics:RaycastWithRadius(startpos, endpos, flags, ignore_entity, radius)
    TypeCheck:Position(startpos)
    TypeCheck:Position(endpos)
    TypeCheck:Number(flags)
    TypeCheck:Number(radius)
    return self:GetShapeTestResult(StartShapeTestCapsule(startpos.x, startpos.y, startpos.z, endpos.x, endpos.y, endpos.z, radius, flags or -1, ignore_entity or 0, 7))
end

function Physics:GetShapeTestResult(handle)
    local retval, hit, position, normal, entity = GetShapeTestResult(handle)
    return {retval = retval, hit = hit, position = position, normal = normal, entity = entity}
end

Physics = Physics()