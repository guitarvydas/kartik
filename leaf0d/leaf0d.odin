package leaf0d

import "core:fmt"
import "core:log"
import "core:strings"
import "core:slice"
import "core:os"
import "core:unicode/utf8"

import reg "../registry0d"
import "../process"
import "../syntax"
import zd "../0d"

////////

panic_instantiate :: proc(name: string) -> ^zd.Eh {
    @(static) counter := 0
    counter += 1
    name_with_id := fmt.aprintf("panic (ID:%d)", counter)
    return zd.make_leaf_with_no_instance_data (name_with_id,  panic_proc)
}

panic_proc :: proc(eh: ^zd.Eh, msg: zd.Message) {
    fmt.assertf (false, "%v %v %v\n", eh.name, msg, msg.datum)
}

////////

render_instantiate :: proc(name: string) -> ^zd.Eh {
    @(static) counter := 0
    counter += 1
    name_with_id := fmt.aprintf("render (ID:%d)", counter)
    return zd.make_leaf_with_no_instance_data (name_with_id, render_proc)
}

render_proc :: proc(eh: ^zd.Eh, msg: zd.Message) {
    fmt.printf ("@@@ render invoked with message (%v,%v)\n", msg.port, msg.datum) // stubbed out for now
}

/////////

probe_instantiate :: proc(name: string) -> ^zd.Eh {
    return zd.make_leaf_with_no_instance_data(name, probe_proc)
}

probe_proc :: proc(eh: ^zd.Eh, msg: zd.Message) {
    fmt.println (eh.name, msg.datum)
}

/////////

Faker_Instance_Data :: struct {
    counter : int
}

fake_image_instantiate :: proc(name: string) -> ^zd.Eh {
    inst := new (Faker_Instance_Data)
    inst.counter = 42
    return zd.make_leaf (name, inst, fake_image_proc)
}

fake_image_proc :: proc(eh: ^zd.Eh, msg: zd.Message, inst : ^Faker_Instance_Data) {
    zd.send (eh, "output", fmt.aprintf ("Fake Image[%v]", inst.counter))
    inst.counter += 1
}
///

ImageCache_States :: enum { empty, fresh, stale, void }
// .void state means that the ImageCache is transitioning between states - void is an illegal state
Image_Type :: string // stubbed out as a 'string' for now

ImageCache_Instance_Data :: struct {
    state : ImageCache_States,
    image : Image_Type
}

imagecache_instantiate :: proc(name: string) -> ^zd.Eh {
    @(static) counter := 0
    counter += 1
    name_with_id := fmt.aprintf("imagecache (ID:%d)", counter)
    inst := new (ImageCache_Instance_Data)
    eh := zd.make_leaf(name_with_id, inst, imagecache_proc)
    imagecache_enter (eh, inst, .empty, zd.Message {})
    return eh
}

imagecache_proc :: proc(eh: ^zd.Eh, msg: zd.Message, inst: ^ImageCache_Instance_Data) {
    switch inst.state {
    case .empty:
	switch msg.port {
	case "image update":
	    inst.image = msg.datum.(Image_Type)
	    imagecache_exit (eh, inst, msg)
	    imagecache_enter (eh, inst, .fresh, msg)
        case "force rendering": // noop
        case:
	    fmt.assertf (false, "Illegal message port %v for ImageCache in state %v\n", inst.state, msg.port)
	}
    case .fresh:
	switch msg.port {
	case "image update":
	    imagecache_exit (eh, inst, msg)
	    imagecache_enter (eh, inst, .fresh, msg)
        case "force rendering":
	    imagecache_exit (eh, inst, msg)
	    imagecache_enter (eh, inst, .stale, msg)
        case:
	    fmt.assertf (false, "Illegal message port %v for ImageCache in state %v\n", inst.state, msg.port)
	}
    case .stale:
	switch msg.port {
	case "image update":
	    inst.image = msg.datum.(Image_Type)
	    imagecache_exit (eh, inst, msg)
	    imagecache_enter (eh, inst, .fresh, msg)
        case "force rendering": // noop
        case:
	    fmt.assertf (false, "Illegal message port %v for ImageCache in state %v\n", inst.state, msg.port)
	}
    case .void:
	fmt.assertf (false, "Illegal state for ImageCache %v\n", inst.state)
    case:
	fmt.assertf (false, "Illegal state for ImageCache %v\n", inst.state)
    }
}

imagecache_enter :: proc(eh: ^zd.Eh, inst: ^ImageCache_Instance_Data, next_state : ImageCache_States, msg: zd.Message) {
    switch next_state {
    case .empty:
    case .fresh:
	inst.image = msg.datum.(Image_Type)
    case .stale:
    case .void: assert (false)
    case:       assert (false)
    }
    inst.state = next_state
}

imagecache_exit :: proc(eh: ^zd.Eh, inst: ^ImageCache_Instance_Data, msg: zd.Message) {
    switch inst.state {
    case .empty:
    case .fresh:
	zd.send (eh, "render", inst.image)
    case .stale:
    case .void: assert (false)
    case:       assert (false)
    }
    inst.state = .void
}


