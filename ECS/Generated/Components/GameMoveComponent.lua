local _Base = require('ECS.Framework.Component')
local MoveComponent = class('MoveComponent', _Base)

function MoveComponent:Init(speed, direction, isMoving)
        self.speed = speed
        self.direction = direction or {x=0,y=0,z=0}
        self.isMoving = isMoving == nil and false or true

end

function MoveComponent:SetData(speed, direction, isMoving)
        self.speed = speed or self.speed
        self.direction = direction or self.direction
        self.isMoving = isMoving == nil and self.isMoving or isMoving

end

return MoveComponent
