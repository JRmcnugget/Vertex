<div align="center">
  <h1><strong>Vertex v0.10</strong></h1>
  
  cool bean approved
</div>

Vertex is a decoupled, state and component driven framework for Roblox player character creation. 
It is designed to alleviate the burden of how character scripts intertwine, allowing developers to focus on gameplay depth instead of technical debt.

## Features
* **Dynamic Module Discovery**

Gif should go here

Vertex will automatically load any state or component modulescripts, creating instant functionality with minimal adjustments to how it works with other scripts. Want to add functionality for running or crouching? Just add a State, Component, or multiple, whichever suits your needs best!

* **Automatic keybinding**

Gif should go here

Vertex will automatically bind any specificed Component functions to their respective keybinds, eliminating the overhead of managing input connections manually.

* **Customizable API & architecture**

Vertex is designed from the ground up to be transparent with how it functions, enabling developers to modify its contents to better fit there own needs.

## Quick Start Guide
<div align="center">
For a complete implementation example, including multiple state transitions, use of components, and abilities, explore the Vertex Demo place, uncopylocked on Roblox or available for download in the releases tab.

(Link should go here).
</div>

* **Installation**

  * Download Vertex

  You can download Vertex through the releases tab, or alternatively, edit the uncopylocked demo on the Roblox website (link should be here). 

  * Setup


  Place the VertexLib folder within ReplicatedStorage, and the Vertex localscript within StarterPlayerScripts.

  Modify VertexConfig's initalState line, replacing "Grounded" with the string of the state's name the player should begin in.

  You should be ready to go!

<hr />
  
* **Creating a State**

State modules follow the format of:
```lua
-- Required for proper metatable inheritance. Should not be deleted. 
local State = {}
State.__index = State

-- Returns the contents of the state to be loaded into memory by Vertex.
function State.new(Manager)
    local self = {
        Manager = Manager, -- links back to Vertex. Generally should not be modified
        Name = "ExampleState", -- The name of the state as a string. 
        interruptable = true, -- Identifies whether the state can be cancelled or not.
    }
    return self
end

-- Triggers upon the state being swapped to from another state. Should be used for any state specific initalization
-- State:onUpdate() will not run until this returns true.
function State:onEnter(dt)
    return true
end

-- Ran every frame while this state is active.
function State:onUpdate(dt)
end

-- Triggers upon the state being swapped out of. Should be used for any state specific cleanup.
-- The state that is being swapped to will not have its onEnter() run until this function returns true.
function State:onExit(dt)
    return true
end

return State
```
Both ```State:onEnter()``` and ```State:onExit()``` are not necessary for a state to function, but is it recommened to leave them blank regardless of their utilization.

States waiting until ```State:onEnter()``` or ```State:onExit()``` has completed allows developers to utilize asynchronous transitions. If you need to wait for an animation, a sound, or something else to finish before the state offically begins or ends, you can postpone the return utilizing a ```task.wait()```.

Inside any state hook, you have full access to the Vertex API through self.Manager. For example:
* Referencing the player: ```self.Manager.Player```
* Accessing a shared variable: ```self.Manager.Shared.isCool = true```
* Requesting to change a state: ```self.Manager:changeState("Jumping")```

States are referenced in code by their name variable. They will default to the filename of the modulescript unless specified in their self table. For example:

* A state with the line ```Name = "epicState"``` will be referenced as ```epicState```.
  
  * eg. ```self.Manager:changeState("epicState")``` or ```self.Manager.States["epicState"]```

 * A state with no line for name, but has the file name "ExampleState" will be refenced as ```ExampleState```.

States inherit default variables written in ```VertexManager.StateDefaults```. You are able to overwrite the default by writing the new value within the State's ```self```, within ```State.new()```. For example:

* For:
  ```lua
  VertexManager.StateDefaults = {
    isEpic = false,
    canJump = false
  }
  
  &
  
  function State.new(Manager)
    local self = {
        Manager = Manager,
        Name = "ExampleState",
        isEpic = true
    }
    return self
  end
  ```
  
  * ```self.isEpic``` will print ```true```
  * ```self.canJump```will print ```false```

<hr />

* **Creating a Component**

Component modules follow the format of:

```lua
local Component = {}
Component.__index = Component

function Component.new(Manager)
    local self = {
        Manager = Manager,
        Name = "ExampleComponent",
        updateFrequency = nil,
        accumulator = 0,
        bindableEvents = {
            ["Example"] = {functionName = "exampleEvent", keybinds = {Enum.KeyCode.Q}, mobileButton = false}
        }
    }
    return self
end

function Component:onUpdate()
end

function Component:exampleEvent(inputType, inputObj)
end

return Component
```

* **Advanced Functionality**

tutorial goes here
  
## Documentation

* VertexManager
* State
* Component
* VertexConfig

<hr />

Built using Rojo
