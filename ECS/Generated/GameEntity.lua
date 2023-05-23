local GameEntity = class("GameEntity")


--========= TestComponent ========================================================================
function GameEntity:AddTest(list, id)
    self.Test = Context:_GetComponent(GameComponentLookUp.TestComponent)
    self.Test:Init(list, id)
    self:_OnAddComponent(self.Test)
    Context:_OnAddComponent(self, self.Test)
end

function GameEntity:RemoveTest()
    self:_OnRemoveComponent(self.Test)
    Context:_OnRemoveComponent(self, self.Test)
    self.Test = nil
end

function GameEntity:HasTest()
    return self:HasComponent(GameComponentLookUp.TestComponent)
end

--========= MoveComponent ========================================================================
function GameEntity:AddMove(speed)
    self.Move = Context:_GetComponent(GameComponentLookUp.MoveComponent)
    self.Move:Init(speed)
    self:_OnAddComponent(self.Move)
    Context:_OnAddComponent(self, self.Move)
end

function GameEntity:RemoveMove()
    self:_OnRemoveComponent(self.Move)
    Context:_OnRemoveComponent(self, self.Move)
    self.Move = nil
end

function GameEntity:HasMove()
    return self:HasComponent(GameComponentLookUp.MoveComponent)
end

return GameEntity
