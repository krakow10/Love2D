/*
mat3 quat2mat(vec4 q)
{
	return mat3(1-2*q.x*q.x-2*q.w*q.w,2*q.y*q.x-2*q.z*q.w,2*q.y*q.w+2*q.z*q.x,
				2*q.y*q.x+2*q.z*q.w,1-2*q.y*q.x-2*q.w^2,2*q.x*q.w-2*q.z*q.y,
				2*q.y*q.w-2*q.z*q.x,2*q.x*q.w+2*q.z*q.y,1-2*q.y*q.y-2*q.x*q.x)
}
*/

vec4 effect(vec4 colour, Image img, vec2 txy, vec2 sxy)
{
	return vec4(txy,sxy);
}
