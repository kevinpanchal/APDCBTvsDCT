cover_object=imread("lena.bmp");
message=imread("pro.png");
message=rgb2gray(message);
k=1;
message=imresize(message, 0.25, 'nearest');

[ll, lh, hl, hh] = dwt2(cover_object, 'haar');

[ll2, lh2, hl2, hh2] = dwt2(ll, 'haar');

blocksize=4;

x=1;
dct_block2 = hh2;
y=1;
for kk = 1:32
    x=1;
    for jj = 1:32
        dct_block2(y:y+blocksize-1,x:x+blocksize-1)=dct2(dct_block2(y:y+blocksize-1,x:x+blocksize-1));
        x=x+blocksize;
    end    
    y=y+blocksize;
end
% dct_block2=dct2(hh2(1:128, 1:128));
[u1, s1, v1] = svd(dct_block2);

message=double(message);


% for kk=1:128
%     for jj = 1:128
%         message(kk, jj)=105.0;
%     end
% end
% imshow(uint8(message));
[wu, ws, wv] = svd(message);

s=s1+k*ws;
% u=u1+k*wu;
% v=v1+k*wv;

m=u1*s*v1;
llhh=idct2(m);
lll=idwt2(ll2, lh2, hl2, llhh, 'haar', [256, 256]);
final=idwt2(lll, lh, hl, hh, 'haar', [512, 512]);
% % 
%  figure;
%  imshow(uint8(final));

[rll, rlh, rhl, rhh] = dwt2(final, 'haar');
[rll2, rlh2, rhl2, rhh2] = dwt2(rll, 'haar');

x=1;
rdct_block2 = rhh2;
y=1;
for kk = 1:32
    x=1;
    for jj = 1:32
        rdct_block2(y:y+blocksize-1,x:x+blocksize-1)=dct2(rdct_block2(y:y+blocksize-1,x:x+blocksize-1));
        x=x+blocksize;
    end    
    y=y+blocksize;
end

% rdct_block2=dct2(rhh2);
[ru, rs, rv] = svd(rdct_block2);

% rru = (u-ru)/k;
% rrv = (v-rv)/k;
rrs = (s-rs)/k;

temp=ru*rrs*rv;
% 
% for ii = 1:128
%     for jj = 1:128
%         if(temp(jj, ii)<=2.0)
%             temp(jj, ii)=0.0;
%         else
%             temp(jj, ii) = 254.9;
%         end
%     end
% end
% figure;
% imshow(uint8(temp));



I0     = double(cover_object);
I1     = double(final);
Id     = (I0-I1);
signal = sum(sum(I0.^2));
noise  = sum(sum(Id.^2));
MSE  = noise./numel(I0);
peak = max(I0(:));
PSNR = 10*log10(peak^2/MSE(:,:,1))
NCC1=ncc(double(cover_object),final);
disp(MSE);
