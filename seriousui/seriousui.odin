package seriousui

DEBUG_ENABLED :: false

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

MAX_UI_ELEMENTS :: 128

FontSetting :: struct {
	font:  rl.Font,
	size:  f32,
	color: rl.Color,
}

UIVisual :: struct {
	rect:        rl.Rectangle,
	text:        string,
	colorButton: rl.Color,
	rounding:    f32,
	corners:     i32,
}

UIData :: struct {
	id:          string,
	startVisual: UIVisual,
	curVisual:   UIVisual,
}

UIContext :: struct {
	hot:    string,
	active: string,
}

elements: map[string]UIData
uiContext: UIContext

font_setting: FontSetting = FontSetting{rl.LoadFont("assets/GoogleSans_17pt-SemiBold.ttf"), 16, rl.BLACK}

begin :: proc() {
	uiContext.hot = ""
	uiContext.active = ""
}

clean :: proc() {
	delete(elements)
	delete(animations)
}

set_font :: proc(font: rl.Font) {
	font_setting.font = font
}

set_font_size :: proc(size: f32) {
	font_setting.size = size
}

set_font_color :: proc(color: rl.Color) {
	font_setting.color = color
}

processVisual :: proc(id: string) -> UIVisual {
	element, exists := elements[id]
	if !exists {
		return UIVisual{}
	}

	newVisual := &element.curVisual

	for type in AnimationType {
		animId := AnimationId{id, type}

		if animId not_in animations {
			continue
		}

		anim := animations[animId]

		#partial switch type {
		case .COLOR:
			//newVisual.btn_col_normal = rl.ColorLerp(anim.startCol, anim.targetCol, anim.progress)
			break
		}
	}

	return newVisual^
}

button_rect :: proc(
	id: string,
	rect: rl.Rectangle,
	text: string,
	btn_col_normal: rl.Color = rl.GRAY,
	btn_col_hover: rl.Color = rl.DARKGRAY,
	rounding: f32 = 0.25,
	corners: i32 = 8,
) -> (
	^UIData,
	bool,
) {
	startVisual := UIVisual{rect, text, btn_col_normal, rounding, corners}
	elements[id] = UIData{id, startVisual, startVisual}
	element := &elements[id]

	if uiContext.hot == "" && rl.CheckCollisionPointRec(rl.GetMousePosition(), element.curVisual.rect) {
		uiContext.hot = id
		element.startVisual.colorButton = btn_col_hover
	}

	if DEBUG_ENABLED {
		rl.DrawRectangleLines(
			i32(element.curVisual.rect.x),
			i32(element.curVisual.rect.y),
			i32(element.curVisual.rect.width),
			i32(element.curVisual.rect.height),
			rl.RED,
		)
	}

	drawElement(id, element.startVisual)

	// TODO: This should happen on release, not on click
	return element, uiContext.hot == id && rl.IsMouseButtonPressed(.LEFT)
}

drawElement :: proc(id: string, visual: UIVisual) {
	rl.DrawRectangleRounded(visual.rect, visual.rounding, visual.corners, visual.colorButton)

	if len(visual.text) > 0 {
		text_size := rl.MeasureTextEx(font_setting.font, rl.TextFormat("%s", visual.text), font_setting.size, 1)

		rl.DrawTextPro(
			font_setting.font,
			rl.TextFormat("%s", visual.text),
			rl.Vector2{visual.rect.x + visual.rect.width / 2, visual.rect.y + visual.rect.height / 2},
			rl.Vector2{text_size.x / 2, text_size.y / 2},
			0,
			font_setting.size,
			1,
			font_setting.color,
		)
	}
}
