function[jay]=abcd(yy)
b=yy;
for ii=1:8
    for jj=1:8
        if (jj==1)
            b(ii,jj)=(8-ii)/64;
        else
            b(ii,jj)=1/64*((8-ii)*cos((ii*jj*pi)/8)-((1/sin((jj*pi)/8))*sin((ii*jj*pi)/8)));
        end

    end
end
jay=b*yy*transpose(b);


        
