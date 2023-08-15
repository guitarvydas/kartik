package user0d

import "core:fmt"

import reg "../registry0d"
import zd "../0d"
import leaf "../leaf0d"

start_logger :: proc () -> bool {
    return false
}

components :: proc (leaves: ^[dynamic]reg.Leaf_Initializer) {
    append(leaves, reg.Leaf_Instantiator { name = "panic", init = leaf.panic_instantiate })
    append(leaves, reg.Leaf_Instantiator { name = "Fake Image", init = leaf.fake_image_instantiate })
    append(leaves, reg.Leaf_Instantiator { name = "render", init = leaf.render_instantiate })
    append(leaves, reg.Leaf_Instantiator { name = "Image Cache", init = leaf.imagecache_instantiate })
}



