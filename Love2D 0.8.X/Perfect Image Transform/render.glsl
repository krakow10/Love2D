//#extension GL_ARB_gpu_shader5:enable
//By xXxMoNkEyMaNxXx
extern Image img;
extern vec2 sizei;//Half size of start image
extern vec2 sizef;//Half size of final image
extern vec2 offset;//Offset from origin
extern mat2 mat;//Transformation matrix, includes rotation and scaling.

vec4 effect(vec4 _0,Image _1,vec2 _2,vec2 iPixel){
	vec2 pixel=vec2(iPixel.x-sizef.x/2,sizef.y/2-iPixel.y)-offset;

	//Calculate where this pixel is on the original image (pretending it's already rotated and working backwards.)
	number det=mat[0].x*mat[1].y-mat[0].y*mat[1].x;//determinant(mat);
	mat2 imat=mat2(mat[1].y,-mat[0].y,-mat[1].x,mat[0].x)/det;//inverse(mat);
	vec2 v=sizei/2+imat*pixel;
	vec2 v00=sizei/2+imat*vec2(pixel.x-0.5,pixel.y-0.5);
	vec2 v01=sizei/2+imat*vec2(pixel.x-0.5,pixel.y+0.5);
	vec2 v10=sizei/2+imat*vec2(pixel.x+0.5,pixel.y-0.5);
	vec2 v11=sizei/2+imat*vec2(pixel.x+0.5,pixel.y+0.5);

	//Organize.
	vec2 _min=min(min(v00,v01),min(v10,v11));
	vec2 _max=max(max(v00,v01),max(v10,v11));

	vec2 x_min,x_max,y_min,y_max;

	if(_min.x==v00.x)
		x_min=v00;
	if(_min.x==v01.x)
		x_min=v01;
	if(_min.x==v10.x)
		x_min=v10;
	if(_min.x==v11.x)
		x_min=v11;

	if(_min.y==v00.y)
		y_min=v00;
	if(_min.y==v01.y)
		y_min=v01;
	if(_min.y==v10.y)
		y_min=v10;
	if(_min.y==v11.y)
		y_min=v11;

	if(_max.x==v00.x)
		x_max=v00;
	if(_max.x==v01.x)
		x_max=v01;
	if(_max.x==v10.x)
		x_max=v10;
	if(_max.x==v11.x)
		x_max=v11;

	if(_max.y==v00.y)
		y_max=v00;
	if(_max.y==v01.y)
		y_max=v01;
	if(_max.y==v10.y)
		y_max=v10;
	if(_max.y==v11.y)
		y_max=v11;

	//Have floored values ready in case we need to compare it to an integer
	ivec2 ix_min=ivec2(floor(x_min));
	ivec2 ix_max=ivec2(floor(x_max));
	ivec2 iy_min=ivec2(floor(y_min));
	ivec2 iy_max=ivec2(floor(y_max));

	vec4 colour=vec4(0);
	number idet=0.5/det;

	//int count=0;
	number Total=0;
	//Now we want to find all the pixels that have any area in common with this unrendered pixel area v00-v10-v11-v01.
	for(int x=max(-1,ix_min.x);x<=min(sizei.x,ix_max.x);++x){
		int yinit,ystop;
		//Use the stuff organized earlier to find which pixels are relevant.
		if(x==iy_min.x)
			yinit=iy_min.y;
		else if(x<iy_min.x)
			yinit=int(floor(x_min.y+(x-x_min.x+1)*(y_min.y-x_min.y)/(y_min.x-x_min.x)));
		else if(x>iy_min.x)
			yinit=int(floor(y_min.y+(x-y_min.x)*(x_max.y-y_min.y)/(x_max.x-y_min.x)));

		if(x==iy_max.x)
			ystop=iy_max.y;
		else if(x<iy_max.x)
			ystop=int(floor(x_min.y+(x-x_min.x+1)*(y_max.y-x_min.y)/(y_max.x-x_min.x)));
		else if(x>iy_max.x)
			ystop=int(floor(y_max.y+(x-y_max.x)*(x_max.y-y_max.y)/(x_max.x-y_max.x)));
		//Fine?

		for(int y=max(-1,yinit);y<=min(sizei.y,ystop);++y){
			//AVERT YOUR EYES
			number Area=0;

			//*/Right side of pixel being added
			number c0x_min,c0x_max,c0y_min,c0y_max;
			if(imat[0].y<0){
				c0x_min=(idet-dot(vec2(x+1,y)-v,imat[0]))/imat[0].y;
				c0x_max=(-idet-dot(vec2(x+1,y)-v,imat[0]))/imat[0].y;
			}else{
				c0x_min=(-idet-dot(vec2(x+1,y)-v,imat[0]))/imat[0].y;
				c0x_max=(idet-dot(vec2(x+1,y)-v,imat[0]))/imat[0].y;
			}
			if(imat[1].y<0){
				c0y_min=(idet-dot(vec2(x+1,y)-v,imat[1]))/imat[1].y;
				c0y_max=(-idet-dot(vec2(x+1,y)-v,imat[1]))/imat[1].y;
			}else{
				c0y_min=(-idet-dot(vec2(x+1,y)-v,imat[1]))/imat[1].y;
				c0y_max=(idet-dot(vec2(x+1,y)-v,imat[1]))/imat[1].y;
			}
			number c0_min=max(0,max(c0x_min,c0y_min));
			number c0_max=min(1,min(c0x_max,c0y_max));
			if(c0_max>c0_min)
				Area+=c0_max-c0_min;
			//*/

			//Side v00->v10
			vec2 d1=v10-v00;
			number c1x_min,c1x_max,c1y_min,c1y_max;
			if(d1.x<0){
				c1x_min=(x+1-v00.x)/d1.x;
				c1x_max=(x-v00.x)/d1.x;
			}else{
				c1x_min=(x-v00.x)/d1.x;
				c1x_max=(x+1-v00.x)/d1.x;
			}
			if(d1.y<0){
				c1y_min=(y+1-v00.y)/d1.y;
				c1y_max=(y-v00.y)/d1.y;
			}else{
				c1y_min=(y-v00.y)/d1.y;
				c1y_max=(y+1-v00.y)/d1.y;
			}
			number c1_min=max(0,max(c1x_min,c1y_min));
			number c1_max=min(1,min(c1x_max,c1y_max));
			if(c1_max>c1_min){
				vec2 v0=v00+(v10-v00)*c1_min;
				vec2 v1=v00+(v10-v00)*c1_max;
				Area+=(v1.y-v0.y)*((v1.x+v0.x)/2-x);
			}

			//Side v10->v11
			vec2 d2=v11-v10;
			number c2x_min,c2x_max,c2y_min,c2y_max;
			if(d2.x<0){
				c2x_min=(x+1-v10.x)/d2.x;
				c2x_max=(x-v10.x)/d2.x;
			}else{
				c2x_min=(x-v10.x)/d2.x;
				c2x_max=(x+1-v10.x)/d2.x;
			}
			if(d2.y<0){
				c2y_min=(y+1-v10.y)/d2.y;
				c2y_max=(y-v10.y)/d2.y;
			}else{
				c2y_min=(y-v10.y)/d2.y;
				c2y_max=(y+1-v10.y)/d2.y;
			}
			number c2_min=max(0,max(c2x_min,c2y_min));
			number c2_max=min(1,min(c2x_max,c2y_max));
			if(c2_max>c2_min){
				vec2 v0=v10+(v11-v10)*c2_min;
				vec2 v1=v10+(v11-v10)*c2_max;
				Area+=(v1.y-v0.y)*((v1.x+v0.x)/2-x);
			}

			//Side v11->v01
			vec2 d3=v01-v11;
			number c3x_min,c3x_max,c3y_min,c3y_max;
			if(d3.x<0){
				c3x_min=(x+1-v11.x)/d3.x;
				c3x_max=(x-v11.x)/d3.x;
			}else{
				c3x_min=(x-v11.x)/d3.x;
				c3x_max=(x+1-v11.x)/d3.x;
			}
			if(d3.y<0){
				c3y_min=(y+1-v11.y)/d3.y;
				c3y_max=(y-v11.y)/d3.y;
			}else{
				c3y_min=(y-v11.y)/d3.y;
				c3y_max=(y+1-v11.y)/d3.y;
			}
			number c3_min=max(0,max(c3x_min,c3y_min));
			number c3_max=min(1,min(c3x_max,c3y_max));
			if(c3_max>c3_min){
				vec2 v0=v11+(v01-v11)*c3_min;
				vec2 v1=v11+(v01-v11)*c3_max;
				Area+=(v1.y-v0.y)*((v1.x+v0.x)/2-x);
			}

			//Side v01->v00
			vec2 d4=v00-v01;
			number c4x_min,c4x_max,c4y_min,c4y_max;
			if(d4.x<0){
				c4x_min=(x+1-v01.x)/d4.x;
				c4x_max=(x-v01.x)/d4.x;
			}else{
				c4x_min=(x-v01.x)/d4.x;
				c4x_max=(x+1-v01.x)/d4.x;
			}
			if(d4.y<0){
				c4y_min=(y+1-v01.y)/d4.y;
				c4y_max=(y-v01.y)/d4.y;
			}else{
				c4y_min=(y-v01.y)/d4.y;
				c4y_max=(y+1-v01.y)/d4.y;
			}
			number c4_min=max(0,max(c4x_min,c4y_min));
			number c4_max=min(1,min(c4x_max,c4y_max));
			if(c4_max>c4_min){
				vec2 v0=v01+(v00-v01)*c4_min;
				vec2 v1=v01+(v00-v01)*c4_max;
				Area+=(v1.y-v0.y)*((v1.x+v0.x)/2-x);
			}
			//mabey we calacalatezd teh area?

			Total+=Area;
			//++count;

			//Outside the image will have the same colour as the closest point on the image, but 0 opacity.
			//This makes a perfect transition from image to no image.
			if(x<0||y<0||x>sizei.x-1||y>sizei.y-1)
				colour+=vec4(Texel(img,vec2(x+0.5,y+0.5)/sizei).rgb*Area,0);
			else
				colour+=Texel(img,vec2(x+0.5,y+0.5)/sizei)*Area;
		}
	}

	if(det<2)
		return colour*det;
	else//Keeps it good for longer with a large determinant (scale)
		return colour/Total;
}
