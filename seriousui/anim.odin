package seriousui

import "core:container/topological_sort"
import "core:encoding/varint"
import "core:fmt"
import "core:math"
import rl "vendor:raylib"

Animation_F32 :: struct {
	cur: f32,
	to:  f32,
}

Animation_Color :: struct {
	cur: rl.Color,
	to:  rl.Color,
}

AnimationType :: union {
	Animation_F32,
	Animation_Color,
}

AnimationData :: struct {
	id:    string,
	speed: f32,
	anims: []AnimationType,
}

@(private)
animations: map[string]AnimationData

get_animation :: proc(id: string) -> AnimationData {
	return animations[id]
}

move_towards :: proc(current, target, speed, dt: f32) -> f32 {
	diff := target - current
	max_step := speed * dt

	if math.abs(diff) <= max_step {
		return target
	}

	return current + math.sign(diff) * max_step
}

processAnimations :: proc(dt: f32) {
	for index in animations {
		data := &animations[index]

		for type, _ in data.anims {
			switch &anim in type {
			case Animation_F32:
				anim.cur = move_towards(anim.cur, anim.to, data.speed, dt)
				break

			case Animation_Color:
				anim.cur = rl.ColorLerp(anim.cur, anim.to, 1 - math.exp(-10.0 * dt))
				break
			}
		}
	}
}

animate :: proc(id: string, speed: f32, anims: []AnimationType) {
	anim, exists := &animations[id]

	if !exists {
		for &type in anims {
			switch &anim in type {
			case Animation_F32:
				anim.cur = 1
			case Animation_Color:
				anim.cur = 1
			}
		}

		animations[id] = {
			id    = id,
			speed = speed,
			anims = anims,
		}
	} else {
		anim.speed = speed
		anim.anims = anims
	}
}


NewAnim :: struct {
	startTime:  f32,
	changeTime: f32,
	startValue: f32,
	endValue:   f32,
	progress:   f32,
}

newAnims: map[^f32]NewAnim


animate_f32 :: proc(value: ^f32, from, to: f32) {
	if value not_in newAnims {
		newAnims[value] = {
			startTime  = 0,
			changeTime = 0,
			startValue = from,
			endValue   = to,
			progress   = 0,
		}
	}

	anim, existed := &newAnims[value]

	if math.abs(anim.startValue - from) >= 0.1 {
		//anim.progress = 1 - anim.progress
	}

	if anim.progress < 1 {
		anim.progress += rl.GetFrameTime()
	}

	anim.progress = math.clamp(anim.progress, 0, 1)

	fmt.println(value^)

	value^ = math.lerp(from, to, anim.progress)
}
