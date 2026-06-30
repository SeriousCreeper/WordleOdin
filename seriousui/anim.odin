package seriousui

import "core:container/topological_sort"
import "core:encoding/varint"
import "core:fmt"
import "core:math"
import rl "vendor:raylib"

AnimationType :: enum {
	COLOR,
	SCALE,
}

AnimationId :: struct {
	id:   string,
	type: AnimationType,
}

AnimationData :: struct {
	speed:     f32,
	progress:  f32,
	startVal:  f32,
	targetVal: f32,
	startCol:  rl.Color,
	targetCol: rl.Color,
	type:      AnimationType,
}

@(private)
animations: map[AnimationId]AnimationData

move_towards :: proc(current, target, speed, dt: f32) -> f32 {
	diff := target - current
	max_step := speed * dt

	if math.abs(diff) <= max_step {
		return target
	}

	return current + math.sign(diff) * max_step
}

animate :: proc(id: string, type: AnimationType, targetVal: f32 = 0, targetCol: rl.Color = rl.WHITE, speed: f32 = 1) {
	animId := AnimationId{id, type}

	if animId not_in animations {
		animations[animId] = AnimationData {
			startVal = targetVal,
			startCol = targetCol,
		}
	}

	anim, exists := &animations[animId]

	if anim.startVal != targetVal || anim.startCol != targetCol {
		anim.startVal = targetVal
		anim.startCol = targetCol
		anim.progress = 1 - anim.progress
	}

	anim.speed = speed
	anim.type = type
	anim.targetVal = targetVal
	anim.targetCol = targetCol

	if (anim.progress >= 1) {
		anim.progress = 1
	} else {
		anim.progress += rl.GetFrameTime() * speed
	}
}

animateColor :: proc(id: string, targetColor: rl.Color) {
	animId := AnimationId{id, .COLOR}

	if animId not_in animations {
		return
	}

	anim := &animations[animId]
}

/* Animation system to modify one specific value
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
*/
