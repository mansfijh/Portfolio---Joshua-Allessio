clc 
%Load in data
joints=readmatrix('joints.txt');
members=readmatrix('members.txt');
loads=readmatrix('loads.txt');
supports=readmatrix('supports.txt');
%define characteristics of truss
NJCT = 3;                              %number of DOF for a free joint in a space truss
NR = height(supports);                 %number of reactions
NJ= height(joints);                    %nuber of joints in truss
NDOF=3*NJ-NR;                          %number of degrees of freedom
NM=height(members);                    %retrieve number of members in truss

%Calculate global stiffness matrix for each member and assemble [S]*
S_star=zeros(3*NJ,3*NJ);               %initialize Sstar matrix
for i=1:NM                             %loop for every single member
    %find member end coordinates
    b=members(i,2);  e=members(i,3);   %locate beginning joint
    Xb=joints(b,2);  Xe=joints(e,2);   %X coordinates for member ends (joints)
    Yb=joints(b,3);  Ye=joints(e,3);   %Y coordinates for member ends (joints)
    Zb=joints(b,4);  Ze=joints(e,4);   %Z coordinates for member ends (joints)
    E=members(i,4);  A=members(i,5);   %locate member material properties
    [K,T]=stiff_spacetruss(E,A,Xb,Yb,Zb,Xe,Ye,Ze);    %Calculate member stiffness matrix in GCS
    
    Index=[joints(b,5), joints(b,6), joints(b,7), joints(e,5), joints(e,6), joints(e,7)]; %create index codes for each code relating to the DOF's
    %Indexes, AKA code numbers, are the DOF's associated with the ends of each member. 
    S_star(Index,Index)=S_star(Index,Index)+K; %Assemble the S_star matrix    
end
S=S_star(1:NDOF,1:NDOF);                      %Extract the S matrix from S_star
Srf=S_star(NDOF+1:height(S_star),1:NDOF);     %Extract Srf matrix from S_star

%Create the P matrix from the 'loads' file
P=zeros(NDOF,1);                              %initialize matrix for loads
for i=1:height(loads)                         %create loop to iterate for each row of loads matrix
    if loads(i,3)~=0                          %detect whether there is a nonzero load in the y direction
        joint=loads(i,1);                     %determine what joint it is acting on
        DOF=joints(joint,6);                  %determine which DOF is the y-DOF at that joint
        P(DOF,1)=loads(i,3);                  %place load in the correct row of P
    else
    end 
    if loads(i,2)~=0                          %detect whether there is a nonzero load in the x direction
        joint=loads(i,1);                     %determine what joint it is acting on
        DOF=joints(joint,5);                  %determine which DOF is the x-DOF at that joint
        P(DOF,1)=loads(i,2);                  %place load in the correct row of P
    else
    end
    if loads(i,4)~=0                          %detect whether there is a nonzero load in the z direction
        joint=loads(i,1);                     %determine what joint it is acting on
        DOF=joints(joint,7);                  %determine which DOF is the z-DOF at that joint
        P(DOF,1)=loads(i,4);                  %place load in the correct row of P
    else
    end
end
d=inv(S)*P;                                    %joint displacement vector
R=Srf*d                                        %support reaction vector
%Calculate member forces
dstar=zeros(3*NJ,1);                           %initialize dstar vector
dstar(1:NDOF,1)=d;                             %load joint displacements into dstar
F=zeros(NM,1)                                  %initialize vector to store axial forces in
%calculate axial force
for i=1:NM
    %find member end coordinates
    b=members(i,2);  e=members(i,3);   %locate beginning joint
    Xb=joints(b,2);  Xe=joints(e,2);   %X coordinates for member ends (joints)
    Yb=joints(b,3);  Ye=joints(e,3);   %Y coordinates for member ends (joints)
    Zb=joints(b,4);  Ze=joints(e,4);   %Z coordinates for member ends (joints)
    E=members(i,4);  A=members(i,5);   %locate member material properties
    
    [K,T]=stiff_spacetruss(E,A,Xb,Yb,Zb,Xe,Ye,Ze);    %Calculate member stiffness matrix in GCS
    index=[joints(b,5), joints(b,6), joints(b,7), joints(e,5), joints(e,6), joints(e,7)]; %create index codes for each member, relating to the DOF's
    v=dstar(index);   %end displacements in global coordinate system
    Q=T*K*v;        
    F(i,1)=Q(4,1);  %vector storing axial forces with typical sign convention for compression and tension
end

d   %display joint displacements
R   %display reaction forces
F   %display axial forces