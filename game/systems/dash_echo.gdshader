shader_type canvas_item;
uniform vec4 echo_color : source_color = vec4(0.90, 0.66, 0.46, 0.28);
void fragment() {
	float silhouette = texture(TEXTURE, UV).a;
	COLOR = vec4(echo_color.rgb, silhouette * echo_color.a * COLOR.a);
}
