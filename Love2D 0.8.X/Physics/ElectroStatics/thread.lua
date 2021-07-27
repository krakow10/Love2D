--By xXxMoNkEyMaNxXx
require'vec'
local self=love.thread.getThread()

local num=0
local positions={}
local charges={}

local vadd=vec.add
local vsub=vec.sub
local vdot=vec.dot
local vlen=vec.length
local vmul=vec.mulNum
local vdiv=vec.divNum

local function go(w)
	--
	for d=1,options.lines do
		local angle=tau*d/options.lines
		data.points[#data.points+1]=vec.add(particles.positions[particle],vec.mulNum({cos(angle),sin(angle)},options.partSize))
	end

		local qlines={}
		local qc=sign(particles.charges[q.n])
		local lmul=0.5+0.5*qc
		for pn=1,#q.points do
			local finish
			local pos=q.points[pn]
			local line={pos}
			for i=1,iterations do
				local a={0,0}
				for n=1,particles.num do
					local diff=vsub(pos,particles.positions[n])--Move away from same charge
					local dis=vlen(diff)
					local charge=particles.charges[n]
					if charge~=0 then
						a=vadd(a,vmul(vdiv(diff,dis),qc*k*charge/vdot(diff,diff)))
						local sc=sign(charge)
						if dis<options.partSize and sc==-qc then
							finish=sc--This should really help things along.
						end
					end
				end
				pos=vadd(pos,vmul(vdiv(a,vlen(a)),dt))
				insert(line,lmul*#line+1,pos)
				if finish then
					break
				end
			end
			if not(finish==1 and qc==-1) then
				qlines[#qlines+1]=line
			end
		end

		renderedLines[#renderedLines+1]={n=q.n,stamp0=q.stamp,stamp1=tick(),lines=qlines,polys=}

	for l=1,#data.lines do
		local points={}
		local lineL=data.lines[l]
		local arrz=#lineL/floor(#lineL/options.arrowSpacing+1)
		for i=1,#lineL do
			points[2*i-1],points[2*i]=unpack(vec.add(vmul(vsub(lineL[i],lines[n].worldPos),ar),vdiv(lines[n].rasterSize,2)))
			if #points>10 and i==floor((floor(i/arrz)+0.5)*arrz+0.5) then
				local p1,p0={points[2*i-1],points[2*i]},{points[2*i-11],points[2*i-10]}
				local diff=vmul(vsub(p1,p0),r303)
				poly("fill",p0[1]-diff[2],p0[2]+diff[1],p1[1],p1[2],p0[1]+diff[2],p0[2]-diff[1])
			end
		end
end
