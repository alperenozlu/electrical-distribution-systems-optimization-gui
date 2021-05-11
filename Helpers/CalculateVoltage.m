function voltage = CalculateVoltage(Py,Qy, BR,TapPositions)

Zbase=12660^2/10000;
m=Zbase;

BR(:,3)=BR(:,3)./m;
BR(:,4)=BR(:,4)./m;
N_br=length(BR); 
N_nd=N_br+1;

Voltbase=1;
V_nd0=1.0*zeros(N_nd,1);
V_nd0(1)=Voltbase;
I_br=zeros(N_br,1);

Nd_br=zeros(N_nd,1);

V_nd0(1)=Voltbase;

for zzz=1:20
	V_nd0(1)=Voltbase;

	for n = 2 : N_nd
		y = n - 1;
		connectedNextNode = BR(y,1);

		if length(TapPositions) > 0 && any(TapPositions(:,1) == n)
			index = find(TapPositions(:,1) == n);
			currentTapValue = TapPositions(index,2);
			V_nd0(n)=((1+0.00625*currentTapValue))*V_nd0(connectedNextNode)-(BR(y,3)+1j*BR(y,4))*I_br(y);
		else
			V_nd0(n)=V_nd0(connectedNextNode)-(BR(y,3)+1j*BR(y,4))*I_br(y);
		end

	end


	for n = N_nd : -1:2
		y = n - 1;
        connectedNodes = (find(BR(:,1) == n));
		connectedNextNode = BR(y,1);
 		
		I_nd(n)=conj((Py(n)+1j*Qy(n))./V_nd0(n));
       
        % TODO: This code can be written in a loop.
		if length(connectedNodes) == 0
			I_br(y)=-I_nd(n);
		elseif length(connectedNodes) == 1
			I_br(y)=-I_nd(n)+I_br(connectedNodes(1));
        elseif length(connectedNodes) == 2
			I_br(y)=-I_nd(n)+I_br(connectedNodes(1))+I_br(connectedNodes(2));
        else
			I_br(y)=-I_nd(n)+I_br(connectedNodes(1))+I_br(connectedNodes(2))+I_br(connectedNodes(3));
		end
		
		
		if length(TapPositions) > 0 && any(TapPositions(:,1) == n)
			index = find(TapPositions(:,1) == n);
			currentTapValue = TapPositions(index,2);
			V_nd0(connectedNextNode)=(1/(1+0.00625*currentTapValue))*V_nd0(n)+(BR(y,3)+1j*BR(y,4))*I_br(y);
		else
			V_nd0(connectedNextNode)=V_nd0(n)+(BR(y,3)+1j*BR(y,4))*I_br(y);
		end

	end

	V_ogu(1,1)=Voltbase;
	difference=(abs(V_ogu(1)-V_nd0(1)));
    
	if difference<0.000001
		break
	end
end
voltage = abs(V_nd0);
end