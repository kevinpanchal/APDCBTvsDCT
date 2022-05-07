cover_object=imread("lena.bmp");

message=imread("pro.png");

message=rgb2gray(message);

message=imresize(message, 0.5, 'nearest');
[ll, lh, hl, hh] = dwt2(cover_object, 'haar');

blocksize=8;

x=1;
dct_block2lh = hh;
dct_block2hl = hl;
y=1;
for kk = 1:32
    x=1;
    for jj = 1:32
        yy=hh(y:y+blocksize-1,x:x+blocksize-1);
        [jay]=abcd(yy);
        dct_block2lh(y:y+blocksize-1,x:x+blocksize-1)=jay;

        yy=hl(y:y+blocksize-1,x:x+blocksize-1);
        [jay]=abcd(yy);
        dct_block2hl(y:y+blocksize-1,x:x+blocksize-1)=jay;

        x=x+blocksize;
    end    
    y=y+blocksize;
end

[ulh,slh,vlh]=svd(dct_block2lh);
[uhl,shl,vhl]=svd(dct_block2hl);
a=1.0;
%message=double(message);
dct_message=dct2(message);
[mu, ms, mv] = svd(dct_message);

% for ii=1:256
%     for jj=1:256
%         message(ii,jj)=25.1;
%     end
% end    
slhw=slh+a*ms;
[ulhw,slhww,vlhw]=svd(slhw);
op=ulh*slhww*vlh;
[ijay]=iabcd(op);
final=idwt2(ll,lh,hl,op,'haar',[512,512]);
% imshow(uint8(final));

I0     = double(cover_object);
I1     = double(final);
Id     = (I0-I1);
signal = sum(sum(I0.^2));
noise  = sum(sum(Id.^2));
MSE  = noise./numel(I0);
peak = max(I0(:));
PSNR = 10*log10(peak^2/MSE(:,:,1))

% disp(PSNR);
disp(MSE);
