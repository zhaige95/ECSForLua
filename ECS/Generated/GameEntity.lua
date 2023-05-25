local GameEntity = class("GameEntity")

function GameEntity:ClearComponents()
    self.Test = nil
    self.Move = nil

end


--========= TestComponent ========================================================================
function GameEntity:AddTest(id, list)
    if self:HasComponent(GameComponentLookUp.TestComponent) == true then
        self:UpdateTest(id, list)
        return
    end
    self.Test = Context:_GetComponent(GameComponentLookUp.TestComponent)
    self.Test:Init(id, list)
    self:_OnAddComponent(self.Test)
    Context:_OnAddComponent(self, self.Test)
end

function GameEntity:UpdateTest(id, list)
    if self:HasComponent(GameComponentLookUp.TestComponent) == false then
        self:AddTest(id, list)
        return
    end
    self.Test:SetData(id, list)
    Context:_OnUpdateComponent(self, self.Test)
end

function GameEntity:RemoveTest()
    if self:HasComponent(GameComponentLookUp.TestComponent) == false then return end
    Context:_OnRemoveComponent(self, self.Test)
    self:_OnRemoveComponent(self.Test)
    self.Test = nil
end

function GameEntity:HasTest()
    return self:HasComponent(GameComponentLookUp.TestComponent)
end

--========= MoveComponent ========================================================================
function GameEntity:AddMove(speed, direction, isMoving)
    if self:HasComponent(GameComponentLookUp.MoveComponent) == true then
        self:UpdateMove(speed, direction, isMoving)
        return
    end
    self.Move = Context:_GetComponent(GameComponentLookUp.MoveComponent)
    self.Move:Init(speed, direction, isMoving)
    self:_OnAddComponent(self.Move)
    Context:_OnAddComponent(self, self.Move)
end

function GameEntity:UpdateMove(speed, direction, isMoving)
    if self:HasComponent(GameComponentLookUp.TestComponent) == false then
        self:AddMove(speed, direction, isMoving)
        return
    end
    self.Move:SetData(speed, direction, isMoving)
    Context:_OnUpdateComponent(self, self.Move)
end

function GameEntity:RemoveMove()
    if self:HasComponent(GameComponentLookUp.MoveComponent) == false then return end
    Context:_OnRemoveComponent(self, self.Move)
    self:_OnRemoveComponent(self.Move)
    self.Move = nil
end

function GameEntity:HasMove()
    return self:HasComponent(GameComponentLookUp.MoveComponent)
end

return GameEntity
