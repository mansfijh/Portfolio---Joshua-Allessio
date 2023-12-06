clc 
%Load in data
joints=readmatrix('joints.txt');
members=readmatrix('members.txt');
loads=readmatrix('loads.txt');
supports=readmatrix('supports.txt');
%define characteristics of truss
NJCT = 2;                              %number of DOF for a free joint in a plane truss
NR = height(supports);                 %number of reactions
NJ= height(joints);                    %nuber of joints in truss
NDOF=2*NJ-NR;                          %number of degrees of freedom
NM=height(members);                    %retrieve number of members in truss
%Calculate global stiffness matrix for each member and assemble [S]*
S_star=zeros(2*NJ,2*NJ);               %initialize Sstar matrix
for i=1:NM                            %loop for every single member
    %find member end coordinates
    Bjoint=members(i,2);              %Index beginning joint for member
    Bcoords=joints(Bjoint,2:3);       %index coordinates for beginning joint
    Ejoint=members(i,3);              %Index end joint for member
    Ecoords=joints(Ejoint,2:3);       %Index coordinates for end joint
                                      %call truss_stiff function to calculate local and global stiffness matrix
    [k,K,T]=truss_stiff(Bcoords(1,1),Bcoords(1,2),Ecoords(1,1),Ecoords(1,2),members(i,4),members(i,5)); %calculate local and global member stiffness matrices
    Index=[joints(Bjoint,4) joints(Bjoint,5) joints(Ejoint,4) joints(Ejoint,5)]; %create index codes for each code relating to the DOF's
    %Once again, indexs, AKA code numbers, are the DOF's associated with
    %the ends of each member. 
    S_star(Index,Index)=S_star(Index,Index)+K; %Assemble the S_star matrix    
end
S=S_star(1:NDOF,1:NDOF);                      %Extract the S matrix from S_star
Srf=S_star(NDOF+1:height(S_star),1:NDOF);     %Extract Srf matrix from S_star
%Create the P matrix from the 'loads' file
P=zeros(NDOF,1);                           %initialize matrix for loads
for i=1:height(loads)                         %create loop to iterate for each row of loads matrix
    if loads(i,3)~=0                          %detect whether there is a nonzero load in the y direction
       P(joints(loads(i,1),5))=loads(i,3);    %Locate DOF of y-load, assign that load to that DOF in P
    else
    end 
    if loads(i,2)~=0                          %detect whether there is a nonzero load in the x direction
         P(joints(loads(i,1),4))=loads(i,2);  %Locate DOF of x-load, assign that load to that DOF in P
    else
    end
end
d=inv(S)*P;                                   %joint displacement vector
R=Srf*d                                       %support reaction vector
%Calculate member forces
dstar=zeros(2*NJ,1);                          %initialize dstar vector
dstar(1:NDOF,1)=d;                            %load joint displacements into dstar
%calculate member forces
F=zeros(NM,1);                               %initialize F vector
mem_force_stress=zeros(NM,2);                %initialize data display for member force and stress
%calculate stress and axial force
for i=1:NM
    Bjoint=members(i,2);              %Index beginning joint for member
    Bcoords=joints(Bjoint,2:3);       %index coordinates for beginning joint
    Ejoint=members(i,3);              %Index end joint for member
    Ecoords=joints(Ejoint,2:3);       %Index coordinates for end joint
    [k,K,T]=truss_stiff(Bcoords(1,1),Bcoords(1,2),Ecoords(1,1),Ecoords(1,2),members(i,4),members(i,5));
     Index=[joints(Bjoint,4) joints(Bjoint,5) joints(Ejoint,4) joints(Ejoint,5)];
    v=dstar(Index);
    Q=T*K*v;                          %Calculate member end forces
    F(i,1)=Q(3,1);
    mem_force_stress(i,1)=Q(3,1);        %store axial member force value
    mem_force_stress(i,2)=mem_force_stress(i,1)/members(i,5); %store member stress value
end
mem_force_stress               %display member force and stress table
F                              %display member force vector