    local _Base = require('ECS.Framework.Component')
    local MoveComponent = class('MoveComponent', _Base)

    function MoveComponent:Init(speed, direction, isMoving)
        self.speed = speed or 22
        self.direction = direction or {x=0,y=0,z=0}
        self.isMoving = isMoving == nil and false or false

    end

    return MoveComponent
