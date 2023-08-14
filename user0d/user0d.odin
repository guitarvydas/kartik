package user0d

import "core:fmt"

import reg "../registry0d"
import zd "../0d"
import leaf "../leaf0d"

start_logger :: proc () -> bool {
    return true
}

components :: proc (leaves: ^[dynamic]reg.Leaf_Initializer) {
    append(leaves, reg.Leaf_Instantiator { name = "panic", init = leaf.panic_instantiate })
    append(leaves, reg.Leaf_Instantiator { name = "?", init = leaf.probe_instantiate })
    append(leaves, reg.Leaf_Instantiator { name = "render", init = leaf.panic_instantiate })
    append(leaves, reg.Leaf_Instantiator { name = "Image Cache", init = leaf.panic_instantiate })
}



