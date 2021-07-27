//By xXxMoNkEyMaNxXx
extern vec2 vs;

//Drawing colours
extern vec4 primary;//Alive Cell
extern vec4 secondary;//Dead Cell

int exists(Image img,vec2 pixel)
{
	vec4 p=Texel(img,pixel/vs);
	if(dot(p-(primary+secondary)/2,primary-secondary)>=0){return 1;}
	return 0;
}

vec4 effect(vec4 _0,Image canvas,vec2 _1,vec2 pixel)
{
	int neighbors=0;
	neighbors+=exists(canvas,pixel+vec2( 1, 0));
	neighbors+=exists(canvas,pixel+vec2( 1, 1));
	neighbors+=exists(canvas,pixel+vec2( 0, 1));
	neighbors+=exists(canvas,pixel+vec2(-1, 1));
	neighbors+=exists(canvas,pixel+vec2(-1, 0));
	neighbors+=exists(canvas,pixel+vec2(-1,-1));
	neighbors+=exists(canvas,pixel+vec2( 0,-1));
	neighbors+=exists(canvas,pixel+vec2( 1,-1));
	if(neighbors==3 || (exists(canvas,pixel)==1 && neighbors==2)){return primary;}
	return secondary;
}
