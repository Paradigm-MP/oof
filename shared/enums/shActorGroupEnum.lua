ActorGroupEnum = immediate_class(Enum)

function ActorGroupEnum:__init()
    self:EnumInit()

    -- NPC groups must have different player models
    -- sheriff NPC model overrides relationship group and will attack players (friendly & enemy sheriff at same time results in two enemy sheriffs)
    self.EnemyGroup = 1
    self:SetDescription(self.EnemyGroup, "Enemy Group")

    self.PlayerGroup = 2
    self:SetDescription(self.PlayerGroup, "Player Group")

    self.DownedPlayerGroup = 3
    self:SetDescription(self.DownedPlayerGroup, "Downed Player Group")

    self.FriendlyGroup = 4
    self:SetDescription(self.FriendlyGroup, "Friendly Group")

    if IsClient then
        local function val(a, b) return b end
        self.group_hashes = {
            [self.EnemyGroup] = val(AddRelationshipGroup("EnemyGroup")),
            [self.PlayerGroup] = val(AddRelationshipGroup("PlayerGroup")),
            [self.DownedPlayerGroup] = val(AddRelationshipGroup("DownedPlayerGroup")),
            [self.FriendlyGroup] = val(AddRelationshipGroup("FriendlyPlayerGroup"))
        }
    end

    if IsClient then
        -- set the relationships between the groups (mutual relationships)
        self:SetRelationshipBetweenGroups(self.EnemyGroup, self.PlayerGroup, 5)
        self:SetRelationshipBetweenGroups(self.EnemyGroup, self.DownedPlayerGroup, 0)
        self:SetRelationshipBetweenGroups(self.PlayerGroup, self.DownedPlayerGroup, 0)
        self:SetRelationshipBetweenGroups(self.PlayerGroup, self.FriendlyGroup, 0)
        self:SetRelationshipBetweenGroups(self.FriendlyGroup, self.DownedPlayerGroup, 0)
        self:SetRelationshipBetweenGroups(self.FriendlyGroup, self.EnemyGroup, 5)

        --[[
            0 = Companion  
            1 = Respect  
            2 = Like  
            3 = Neutral  
            4 = Dislike  
            5 = Hate  
            255 = Pedestrians
        ]]
    end
end

if IsClient then
    function ActorGroupEnum:GetGroupHash(actor_group_enum)
        return self.group_hashes[actor_group_enum]
    end

    function ActorGroupEnum:GetFromHash(hash)
        for enum_value, group_hash in ipairs(self.group_hashes) do
            if hash == group_hash then
                return enum_value
            end
        end

        return nil
    end

    function ActorGroupEnum:SetRelationshipBetweenGroups(group_a, group_b, relationship)
        -- group_a could have a different relationship with group_b than group_b has with group_a
        -- however this code below enforces mutual relationships (groups have same relationship to each other)
        SetRelationshipBetweenGroups(relationship, ActorGroupEnum:GetGroupHash(group_a), ActorGroupEnum:GetGroupHash(group_b))
        SetRelationshipBetweenGroups(relationship, ActorGroupEnum:GetGroupHash(group_b), ActorGroupEnum:GetGroupHash(group_a))
    end
end

ActorGroupEnum = ActorGroupEnum()