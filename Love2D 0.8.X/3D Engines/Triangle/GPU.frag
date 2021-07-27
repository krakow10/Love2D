//By xXxMoNkEyMaNxXx
#define MAX_POLY 100
extern int NUM_POLY=0;

extern vec3[MAX_POLY*3] vert;
extern vec2[MAX_POLY*3] t_vert;
extern ivec3[MAX_POLY] poly_v;//Vertices of the triangle
extern number[MAX_POLY] poly_n0={1.0003};//Refractive index outside
extern number[MAX_POLY] poly_n1={1.4};//Refractive index inside
extern number[MAX_POLY] poly_r={0.1};//Reflectance, Opacity is given by the texture.
extern ivec3[MAX_POLY] poly_texture_v;//Vertex numbers that describe the texture's position on a texture sheet

//p=perpendicular
//s=parallel

mat3 fresnel()
