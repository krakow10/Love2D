//By xXxMoNkEyMaNxXx
extern Image img;
extern vec2 sizei;//Half size of start image
extern vec2 sizef;//Half size of final image
extern vec2 offset;//Offset from origin
extern mat2 mat;//Transformation matrix, includes rotation and scaling.

vec4 position(mat4 transform_projection, vec4 vertex_position)
{
	return transform_projection*vertex_position;
}

vec4 effect(vec4 _0,Image _1,vec2 _2,vec2 iPixel){
	vec2 pixel=vec2(iPixel.x-sizef.x/2,sizef.y/2-iPixel.y)-offset;
	mat2 imat=mat2(mat[1].y,-mat[0].y,-mat[1].x,mat[0].x)/(mat[0].x*mat[1].y-mat[0].y*mat[1].x);//inverse(mat);
	vec2 v=sizei/2+imat*pixel;
	if(v.x<0||v.y<0||v.x>sizei.x||v.y>sizei.y)
		return Texel(img,v/sizei)*(clamp(1+v.x,0,1)*clamp(1+v.y,0,1)*clamp(sizei.x-v.x+1,0,1)*clamp(sizei.y-v.y+1,0,1));
	else
		return Texel(img,v/sizei);
}
