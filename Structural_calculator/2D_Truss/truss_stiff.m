function [k,K,T]=truss_stiff(Xb,Yb,Xe,Ye,E,A)
%calculate length of member
delX=Xe-Xb; 
delY=Ye-Yb;
L=sqrt(delX^2+delY^2); 
% compute cos theta  = c
% compute sin theta  = s
c=delX/L;
s=delY/L;
k=zeros(4,4);  %initialize local member stiffness matrix
%Assemble local stiffness matrix
k(1,1)=E*A/L;
k(3,3)=E*A/L;
k(1,3)=-E*A/L;
k(3,1)=-E*A/L;

T=zeros(4,4); %initialize transformation matrix
R=[c s;-s c];
T(1:2,1:2)=R;
T(3:4,3:4)=R;
K=T'*k*T; %Calculate global stiffness matrix
