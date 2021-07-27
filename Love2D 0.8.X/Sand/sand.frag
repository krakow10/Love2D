//By xXxMoNkEyMaNxXx
extern number delta;
extern vec2 gravity;

extern vec2 size;
extern vec4 Wall;
extern vec4 Empty;

extern Image Map;
extern Image data;
//r=% of cell filled with water
//g=% moved right
//b=% moved down
//a=100%

bool isWall(vec2 point){
	return dot(Texel(Map,point/size)-(Empty+Wall)/2,Wall-Empty)>0;
}

vec4 collect(vec2 point){
	vec4 sand=Texel(data,point/size);
	bvec4 closed=bvec4(isWall(point+vec2(1,0)),isWall(point+vec2(0,1)),isWall(point+vec2(-1,0)),isWall(point+vec2(0,-1)));
	int sides=4;
	if(closed.r)
		--sides;
	if(closed.g)
		--sides;
	if(closed.b)
		--sides;
	if(closed.a)
		--sides;
	number extra=0;
	vec4 water_out=vec4(0);
	vec2 momentum=sand.r*(2*sand.gb-vec2(1)+gravity);
	if(momentum.x>0){
		if(closed.r)
			extra+=momentum.x;
		else
			water_out.r=momentum.x;
	}else{
		if(closed.b)
			extra-=momentum.x;
		else
			water_out.b=-momentum.x;
	}
	if(momentum.y>0){
		if(closed.g)
			extra+=momentum.y;
		else
			water_out.g=momentum.y;
	}else{
		if(closed.a)
			extra-=momentum.y;
		else
			water_out.a=-momentum.y;
	}
	if(extra>0&&sides>0){
		if(closed.r)
			water_out.r+=extra/sides;
		if(closed.g)
			water_out.g+=extra/sides;
		if(closed.b)
			water_out.b+=extra/sides;
		if(closed.a)
			water_out.a+=extra/sides;
	}
	return water_out;
}
vec4 effect(vec4 _0,Image _1,vec2 _2, vec2 pixel){
	vec4 sand=Texel(data,pixel/size);
	vec4 here=delta*vec4(collect(pixel+vec2(1,0)).b,collect(pixel+vec2(0,1)).a,collect(pixel+vec2(-1,0)).r,collect(pixel+vec2(0,-1)).g)-collect(pixel);
	number newSand=sand.r+here.r+here.g+here.b+here.a;
	if(newSand>0)
		return vec4(newSand,(sand.r*sand.gb+vec2(here.b-here.r,here.a-here.g)/2)/newSand,1);
	else
		return vec4(0,0.5,0.5,1);
}
