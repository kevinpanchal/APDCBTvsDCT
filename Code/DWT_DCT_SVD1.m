cover_object=imread("lena.bmp");
message=imread("pro.png");
message=rgb2gray(message);
message=imresize(message, 0.5, 'nearest');

[ll, lh, hl, hh] = dwt2(cover_object, 'haar');
dct_block = dct2(message);
dct_hh = dct2(hh);

[cu, cs, cv] = svd(dct_hh);
[wu, ws, wv] = svd(dct_block);

a = 1;

s = cs + a*ws;

[su, ss, sv] = svd(s);
m = cu*ss*cv;

idct_block = idct2(m);
idwt_block = idwt2(ll, lh, hl, idct_block, 'haar', [512, 512]);
% figure;
% imshow(uint8(idwt_block));

%EXTRACTION
[rll, rlh, rhl, rhh] = dwt2(idwt_block, 'haar');
rdct_block = dct2(rhh);

[ru, rs, rv] = svd(rdct_block);

b = (rs - cs)/a;
[rru, rrs, rrv] = svd(b);

rm = rrs*wu*wv;

idct_final = idct2(rm);

% figure;
% imshow(idct_final);

I0     = double(cover_object);
I1     = double(idwt_block);
Id     = (I0-I1);
signal = sum(sum(I0.^2));
noise  = sum(sum(Id.^2));
MSE  = noise./numel(I0);
peak = max(I0(:));
PSNR = 10*log10(peak^2/MSE(:,:,1))

NCC1=ncc(double(message1),recmessage);
disp(MSE);