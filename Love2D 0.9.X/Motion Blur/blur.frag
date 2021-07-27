//By xXxMoNkEyMaNxXx aka Rhys

/*
The MIT License (MIT) obtained from http://choosealicense.com/licenses/mit/

Copyright (c) 2014 Rhys Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

uniform vec2 CanvasSize;//Size of canvas being operated on
uniform vec2 Offset;//directed blur in pixels

float solvedIntegral(vec2 dp,float dt)
{
	return abs(dt*(dt*(dt*Offset.x*Offset.y/3+dot(Offset,dp.yx)/2)+dp.x*dp.y));
}

vec4 effect(vec4 _0,sampler2D image,vec2 _2,vec2 iPixel)
{
	vec2 p=vec2(iPixel.x-0.5,CanvasSize.y-iPixel.y-0.5);
	vec2 ip=p;
	//*
	if(Offset.x>0)
		++ip.x;
	if(Offset.y>0)
		++ip.y;
	//*/
	vec4 c00=texture2D(image,(ip-vec2(1,1))/CanvasSize);
	vec4 c10=texture2D(image,(ip-vec2(0,1))/CanvasSize);
	vec4 c01=texture2D(image,(ip-vec2(1,0))/CanvasSize);
	vec4 c11=texture2D(image,(ip-vec2(0,0))/CanvasSize);
	float t=0;
	float w=0;//This variable will divide colour at the end, and it will be 1.  However, due to hardware specific problems, (I'm looking at you, AMD) sometimes it's huge, so it will stabilize the colours.
	vec4 colour=vec4(0);
	int i=0;
	while(t<1&&i<1000){
		vec2 dp=ip-(p+Offset*t);
		float dtx=2;
		if(Offset.x>0)
			dtx=dp.x/Offset.x;
		else if(Offset.x<0)
			dtx=(dp.x-1)/Offset.x;
		float dty=2;
		if(Offset.y>0)
			dty=dp.y/Offset.y;
		else if(Offset.y<0)
			dty=(dp.y-1)/Offset.y;
		float dtmax=1-t;
		float dt=min(dtmax,min(dtx,dty));
		float w00=solvedIntegral(vec2(0,0)-dp,dt);
		float w10=solvedIntegral(vec2(1,0)-dp,dt);
		float w01=solvedIntegral(vec2(0,1)-dp,dt);
		float w11=solvedIntegral(vec2(1,1)-dp,dt);
		colour+=
			c00*w00+
			c10*w10+
			c01*w01+
			c11*w11;
		w+=w00+w10+w01+w11;
		/*
		if(dt<0)
			return vec4(1,0,0,1);
		else */if(dt>=dtmax)
			break;
		else{
			t+=dt;
			++i;
		}
		//Pass colours to save texture lookups
		if(dt==dtx){
			if(Offset.x>0){
				++ip.x;
				c00=c10;
				c01=c11;
				c10=texture2D(image,(ip-vec2(0,1))/CanvasSize);
				c11=texture2D(image,(ip-vec2(0,0))/CanvasSize);
			}else{
				--ip.x;
				c10=c00;
				c11=c01;
				c00=texture2D(image,(ip-vec2(1,1))/CanvasSize);
				c01=texture2D(image,(ip-vec2(1,0))/CanvasSize);
			}
		}
		if(dt==dty){
			if(Offset.y>0){
				++ip.y;
				c00=c01;
				c10=c11;
				c01=texture2D(image,(ip-vec2(1,0))/CanvasSize);
				c11=texture2D(image,(ip-vec2(0,0))/CanvasSize);
			}else{
				--ip.y;
				c01=c00;
				c11=c10;
				c00=texture2D(image,(ip-vec2(1,1))/CanvasSize);
				c10=texture2D(image,(ip-vec2(0,1))/CanvasSize);
			}
		}
	}
	return colour/w;
}
