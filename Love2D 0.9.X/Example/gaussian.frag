//By xXxMoNkEyMaNxXx
uniform float h;
/*
uniform vec2 Offset;
uniform vec2 View;
*/

uniform float k;
uniform vec2 mPos;

vec4 Colour0=vec4(0,0,0,1);//Black
vec4 Colour1=vec4(1,1,1,1);//White

vec4 effect(vec4 _0,sampler2D _1,vec2 _2,vec2 iPixel){
	vec2 pixel=vec2(iPixel.x,h-iPixel.y);
	vec2 diff=(mPos-pixel)/k;
	return mix(Colour0,Colour1,exp(-dot(diff,diff)));
}
