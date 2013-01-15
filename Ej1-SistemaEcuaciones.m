%%Solución de sistema de ecuaciones con 3 incognitas
%Ejemplo 3
A = [1  4 -1 1; 2 7 1 -2; 1 4 -1 2; 3 -10 -2 5]
B = [2;15;1;-15]
%Primer Método
X = A\B

%Segundo Método
X1 = inv(A)*B



