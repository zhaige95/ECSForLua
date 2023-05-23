-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- 实体基类
-- Date - 2023-5-22
-- by - 良人
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

local _Base = require("ECS.Generated.GameEntity")

local Entity = class("Entity", _Base)

function Entity:ctor()
    self.__component_indexer = {}
    self.mUID = 0
end

function Entity:_OnAddComponent(comp)
    if not self.__component_indexer[comp.__id] then
        self.__component_indexer[comp.__id] = comp
    end
end

function Entity:_OnRemoveComponent(comp)
    if self.__component_indexer[comp.__id] then
        self.__component_indexer[comp.__id] = nil
    end
end

function Entity:HasComponent(id)
    if self.__component_indexer[id] then
        return true
    end
    return false
end

return Entity
