function[ijay]=iabcd(op)
b=op;
a=8;
for ii=1:a
    for jj=1:a
        if (ii==1)
            b(ii,jj)=1/a;
        else
            b(ii,jj)=((a-ii+0.41)/(a*a))*cos(((ii*(2*jj)+ii)*pi)/(a*2));
        end

    end
end
ijay=b;
