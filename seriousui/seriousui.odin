package seriousui

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

MAX_UI_ELEMENTS :: 128

FontSetting :: struct {
	font:  rl.Font,
	size:  f32,
	color: rl.Color,
}

ContextData :: struct {
	id:             string,
	rect:           rl.Rectangle,
	text:           string,
	btn_col_normal: rl.Color,
	btn_col_hover:  rl.Color,
	rounding:       f32,
	corners:        i32,
}

contextData: map[string]ContextData

font_setting: FontSetting = FontSetting{rl.LoadFont("assets/GoogleSans_17pt-SemiBold.ttf"), 16, rl.BLACK}
is_hovering := false

begin :: proc() {
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

button_rect :: proc(
	id: string,
	rect: rl.Rectangle,
	text: string,
	btn_col_normal: rl.Color,
	btn_col_hover: rl.Color = rl.GRAY,
	rounding: f32 = 0.25,
	corners: i32 = 8,
) -> bool {
	contextData[id] = ContextData{id, rect, text, btn_col_normal, btn_col_hover, rounding, corners}

	is_hovering = rl.CheckCollisionPointRec(rl.GetMousePosition(), rect)

	return is_hovering && rl.IsMouseButtonPressed(.LEFT)
}

draw_buttons :: proc() {
	for id, data in contextData {
		text_size := rl.MeasureTextEx(font_setting.font, rl.TextFormat("%s", data.text), font_setting.size, 1)
		rl.DrawRectangleRounded(
			data.rect,
			data.rounding,
			data.corners,
			is_hovering ? data.btn_col_hover : data.btn_col_normal,
		)
		rl.DrawTextPro(
			font_setting.font,
			rl.TextFormat("%s", data.text),
			rl.Vector2{data.rect.x + data.rect.width / 2, data.rect.y + data.rect.height / 2},
			rl.Vector2{text_size.x / 2, text_size.y / 2},
			0,
			font_setting.size,
			1,
			font_setting.color,
		)
	}
}
