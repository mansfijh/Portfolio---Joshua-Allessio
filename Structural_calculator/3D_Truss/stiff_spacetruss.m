%Space Truss Stiffness Matrix
function [K,T]=stiff_spacetruss(E,A,Xb,Yb,Zb,Xe,Ye,Ze)
L=sqrt((Xe-Xb)^2+(Ye-Yb)^2+(Ze-Zb)^2);
cx=(Xe-Xb)/L;
cy=(Ye-Yb)/L;
cz=(Ze-Zb)/L;
R=[cx cy cz;0 0 0;0 0 0];
T=zeros(6,6);
T(1:3,1:3)=R; T(4:6,4:6)=R;
k=zeros(6,6);
k([1 4],[1 4])=E*A/L*[1 -1;-1 1];
K=T'*k*T;

