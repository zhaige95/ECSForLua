    local _Base = require('ECS.Framework.Component')
    local MoveComponent = class('MoveComponent', _Base)

    function MoveComponent:Init(direction, speed)
        self.speed = speed or 22

    end

    return MoveComponent
