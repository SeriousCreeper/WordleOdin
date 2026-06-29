package seriousui

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

MAX_ANIMATIONS :: 64

AnimationData :: struct {
	timer: f32,
	from:  f32,
	to:    f32,
	cur:   f32,
}

@(private)
animations: [MAX_ANIMATIONS]AnimationData

get_animation :: proc(id: int) -> (AnimationData, bool) {
	if len(animations) <= id {
		return AnimationData{}, false
	}

	return animations[id], true
}

animate :: proc(id: int, from, to, speed, dt: f32) {
	if len(animations) <= id {
		fmt.println("animations: ", len(animations), " id: ", id)
		return
	}

	if animations[id].timer <= 0 {
		animations[id].timer = 1.0
		animations[id].from = from
	}

	animations[id].to = to
	animations[id].timer += dt * speed

	animations[id].cur = math.lerp(animations[id].from, animations[id].to, animations[id].timer)

	if animations[id].timer >= 1 {
		animations[id].timer = 1.0
	}
}
