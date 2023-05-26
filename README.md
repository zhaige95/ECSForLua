# ECS For Lua

![输入图片说明](https://foruda.gitee.com/images/1685002685471243675/ea7d602a_5549484.png "GSZ6)J0]NG`({ARVYHKY412.png")

## 初始化 Context

```
Context:Init()
```

## 使用匹配器Matcher和过滤组Group

#### （Matcher）匹配器：用来定义一个实体匹配规则

比如：

    实体拥有Move组件：NewMatcher():AllOf(EMatcher.Move)

    实体拥有Move组件但是不能有Stun组件：NewMatcher():AllOf(EMatcher.Move):Noneof(EMatcher.Stun)

支持规则：

    AllOf(...)：必须拥有组件

    NoneOf(...)：不包含组件
    
    AnyOf(...)：包含任意组件，和AllOf规则互斥

    Added()：组件添加时

    Removed()：组件移除时

    Updated()：组件更新数据时，需要使用实体上的UpdateXXX(...)方法才能触发

#### （Group）过滤组：用来管理匹配到规则的实体

获取一个group：

```
self.group = Context:GetGroup(NewMatcher():AllOf(EMatcher.Test))
```

可以这样处理group匹配到的实体：

```
for key, entity in pairs(self.group:GetEntities()) do
    -- do something
end
```


## 创建 Component：

空数据组件：
```
return {}
```

带数据的组件

```
return {
    speed = 22,
    direction = {x = 0, y = 0, z = 0},
    isMoving = true
}
```


## 生成代码

创建完组件后在 ECS\Framework\Generator.lua 的process表中加入组件代码的相对路径：

```
local process = {
    TestComponent = "ECS\\Game\\Test\\TestComponent.lua",
    MoveComponent = "ECS\\Game\\Move\\MoveComponent.lua",
    Camp1Component = "ECS\\Game\\Camp1Component.lua"
}
```

运行Generator.lua脚本，生成GameComponent类和Entity扩展方法

> **如果要删除旧组件，需要手动清空一下生成的组件代码，然后运行生成脚本，代码文件夹位置：ECS\Generated\Components** 


## 创建System

继承System.lua，
重写ctor和Execute方法


```
local _Base = require("ECS.Framework.System")
local MoveSystem = class("MoveSystem", _Base)

function MoveSystem:ctor()
    self.group = Context:GetGroup(NewMatcher():AllOf(EMatcher.Test))
end

function MoveSystem:Execute(dt)
    for key, entity in pairs(self.group:GetEntities()) do
        print("move system execute ", entity:HasTest())
    end
end

return MoveSystem

```

## 创建Feature

继承Feature.lua，
重写ctor方法，
在ctor方法中加入System

```
local _Base = require("ECS.Framework.Feature")
local FeatureUpdate = class("FeatureUpdate", _Base)

function FeatureUpdate:ctor()
    self.super:ctor()
    -- 添加system
    self:Add(require("ECS.Game.Move.MoveSystem"))
end

return FeatureUpdate
```

## 使用Feature

    在Update中调用Feature:Execute(dt)

## 使用Entity

**创建Entity**

```
local e = Context:CreateEntity()
e:AddTest("new  test", { 523 })  -- 执行代码生成后可以使用添加某组件的扩展方法
```

**销毁Entity**


```
e:Destroy()
```


