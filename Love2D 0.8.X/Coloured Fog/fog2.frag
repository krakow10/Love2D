//By xXxMoNkEyMaNxXx
extern mat2 View;
extern vec3 pos;
extern mat3 rot;

extern Image ground;

extern number maxd;
extern number dx;

//COPIED CODE BELOW
//
// Description : Array and textureless GLSL 2D/3D/4D simplex
//               noise functions.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
     return mod289(((x*34.0)+1.0)*x);
}

float snoise(vec3 v)
  {
  const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
  const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

// First corner
  vec3 i  = floor(v + dot(v, C.yyy) );
  vec3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min( g.xyz, l.zxy );
  vec3 i2 = max( g.xyz, l.zxy );

  //   x0 = x0 - 0.0 + 0.0 * C.xxx;
  //   x1 = x0 - i1  + 1.0 * C.xxx;
  //   x2 = x0 - i2  + 2.0 * C.xxx;
  //   x3 = x0 - 1.0 + 3.0 * C.xxx;
  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
  vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

// Permutations
  i = mod289(i);
  vec4 p = permute( permute( permute(
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 ))
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

// Gradients: 7x7 points over a square, mapped onto an octahedron.
// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
  float n_ = 0.142857142857; // 1.0/7.0
  vec3  ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = y_ *ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4( x.xy, y.xy );
  vec4 b1 = vec4( x.zw, y.zw );

  //vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
  //vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
  vec4 s0 = floor(b0)*2.0 + 1.0;
  vec4 s1 = floor(b1)*2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

  vec3 p0 = vec3(a0.xy,h.x);
  vec3 p1 = vec3(a0.zw,h.y);
  vec3 p2 = vec3(a1.xy,h.z);
  vec3 p3 = vec3(a1.zw,h.w);

//Normalise gradients
  vec4 norm = inversesqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

// Mix final noise value
  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m;
  return 0.5+20.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), dot(p2,x2), dot(p3,x3) ) );
}
//End of copied code

number erf(number x)//good to at least two decimal places, (minimum accuracy at about x=1.76140821)
{
	number xx=x*x;
	/*
	if(xx<3.1025589)
		return x*(1+xx*(-1/3.+xx*(0.1+xx*(-1/42.+xx*(1/216.+xx*(-1/1320.+xx*(1/9360.+xx*(-1/75600.+xx*(1/685440.+xx*(-1/6894720.+xx/76204800.))))))))));
	else if(x>0)
		return 0.886226925452758-exp(-xx)/(2*x)*(1+(-0.5+(0.75-1.875/xx)/xx)/xx);
	else
		return -0.886226925452758-exp(-xx)/(2*x)*(1+(-0.5+(0.75-1.875/xx)/xx)/xx);
	*/
	if(x>0)//erf approximaiton 4 kool ppl only
		return 0.886226925452758*sqrt(1-exp(-xx*(1.2739713145354559+0.1438929263017658*xx)/(1+0.1452127874845694*xx)));
	else
		return -0.886226925452758*sqrt(1-exp(-xx*(1.2739713145354559+0.1438929263017658*xx)/(1+0.1452127874845694*xx)));
}
number erfi(number x)
{
	number xx=x*x;//reciprocals of 1,3,10,42,216,1320,9360,75600,685440,6894720,76204800
	return x*(1+xx*(0.333333333333333333+xx*(0.1+xx*(2.380952380952380952e-2+xx*(4.629462946294629463e-3+xx*(7.575757575757575758e-4+xx*(1.068376106837610684e-4+xx*(1.322751322751322751e-5+xx*(1.458916900093370682e-6+xx*(1.450385222315046876e-7+xx*1.312253296380280507e-8))))))))));
}
vec4 continuous(vec4 c0,vec4 c1,number s)
{
	number s2=s/2;
	number sr=sqrt(s2);
	number l0=log(c0.a),l1=log(c1.a);
	number gms=pow(c0.a*c1.a,s2);
	if(c0.a>c1.a+0.01){
		number l=sqrt(l0-l1);
		return vec4(c0.rgb-c1.rgb*gms+(c1.rgb-c0.rgb)*((exp(s2*l0*l0/(l0-l1))*erf(sr*l0/l)-exp(s2*l1*l1/(l0-l1))*erf(sr*l1/l)*gms)/(sr*l)),gms);
	}else if(c0.a+0.05<c1.a){
		number l=sqrt(l1-l0);
		return vec4(c0.rgb-c1.rgb*gms-(c1.rgb-c0.rgb)*((exp(s2*l0*l0/(l0-l1))*erfi(sr*l0/l)-exp(s2*l1*l1/(l0-l1))*erfi(sr*l1/l)*gms)/(sr*l)),gms);
	}
	return vec4(c0.rgb-c1.rgb*gms+(c1.rgb-c0.rgb)*(gms-1)/(s2*(l0+l1)),gms);
}

vec4 fog(vec3 x)//The rgb and transmittance (1-Transparency) of the fog at a point x
{
	return vec4(snoise(x+vec3(0,1.5,1.5)),snoise(x+vec3(1.5,0,1.5)),snoise(x+vec3(1.5,1.5,0)),snoise(x));
	//return vec4(0.5+0.5*cos(x),0.5+0.25*sin(length(x))+0.25*sin(length(x)/3.3745288374682345));
}

vec4 effect(vec4 _0,Image _1,vec2 _3, vec2 pixel){
	vec3 dir=rot*normalize(vec3(pixel.x-View[0].x,pixel.y-View[0].y,View[1].y)-vec3(View[1]/2,0));
	number p=1;
	vec3 c=vec3(0);
	vec4 c0=fog(pos);
	number s;
	number sdx=dx;
	number sPlane=maxd;
	if(dir.y<0)
		sPlane=min(sPlane,-pos.y/dir.y);
	for(s=sdx;p>0.005;s+=sdx){
		bool omg=s>sPlane;
		vec3 point=(pos+dir*s);
		if(omg){
			sdx+=sPlane-s;
			point=pos+dir*sPlane;
		}
		vec4 c1=fog(point);
		vec4 cc=continuous(c0,c1,sdx);
		c+=cc.rgb*p;
		p*=cc.a;
		if(omg||point.y<0)
			break;
		sdx=dx*exp(-distance(c1,c0)/sdx);
		c0=c1;
	}
	if(dir.y<0&&s>=-pos.y/dir.y){
		vec4 tColour=Texel(ground,mod((pos.xz+dir.xz*sPlane)/2,1));
		return vec4(mix(c,tColour.rgb,p),1-p*(1-tColour.a));
	}else
		return vec4(c,1-p);
}
