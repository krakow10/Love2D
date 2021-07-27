//Magnification By xXxMoNkEyMaNxXx

//Screen size
extern vec2 vs;

//Cursor position
extern vec2 icentre;

//Magnification level
extern number mag;

//Magnification radius inner and outer
extern number radius0;//Inner
extern number radius1;//Outer

number pi2=1.57079632679;
vec2 fuckinghalf=vec2(0.5);//"half" is reserved

vec4 effect(vec4 _0,Image canvas,vec2 regular,vec2 pixel)
{
	//Actual centre
	vec2 centre=vec2(icentre.x,vs.y-icentre.y);

	vec2 diff=pixel-centre;
	number dlen=length(diff);
	if(dlen<radius0){
		return Texel(canvas,(centre+floor(diff/mag)+fuckinghalf)/vs);
	}
	if(dlen<radius1){
		return Texel(canvas,(centre+diff/(mag+(1-mag)*pow(sin(pi2*(dlen-radius0)/(radius1-radius0)),2)))/vs);
	}
	return Texel(canvas,regular);
}
