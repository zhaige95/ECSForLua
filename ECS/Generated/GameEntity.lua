local GameEntity = class("GameEntity")

function GameEntity:ClearComponents()
    self.Test = nil
    self.Move = nil

end


--========= TestComponent ========================================================================
function GameEntity:AddTest(id, list)
    if self:HasComponent(GameComponentLookUp.TestComponent) == true then
        -- TODO 已存在组件触发replace
        return
    end
    self.Test = Context:_GetComponent(GameComponentLookUp.TestComponent)
    self.Test:Init(id, list)
    self:_OnAddComponent(self.Test)
    Context:_OnAddComponent(self, self.Test)
end

function GameEntity:RemoveTest()
    if self:HasComponent(GameComponentLookUp.TestComponent) == false then return end
    self:_OnRemoveComponent(self.Test)
    Context:_OnRemoveComponent(self, self.Test)
    self.Test = nil
end

function GameEntity:HasTest()
    return self:HasComponent(GameComponentLookUp.TestComponent)
end

--========= MoveComponent ========================================================================
function GameEntity:AddMove(direction, speed)
    if self:HasComponent(GameComponentLookUp.MoveComponent) == true then
        -- TODO 已存在组件触发replace
        return
    end
    self.Move = Context:_GetComponent(GameComponentLookUp.MoveComponent)
    self.Move:Init(direction, speed)
    self:_OnAddComponent(self.Move)
    Context:_OnAddComponent(self, self.Move)
end

function GameEntity:RemoveMove()
    if self:HasComponent(GameComponentLookUp.MoveComponent) == false then return end
    self:_OnRemoveComponent(self.Move)
    Context:_OnRemoveComponent(self, self.Move)
    self.Move = nil
end

function GameEntity:HasMove()
    return self:HasComponent(GameComponentLookUp.MoveComponent)
end

return GameEntity
