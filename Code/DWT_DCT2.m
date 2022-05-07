cover_object=imread("lena.bmp");
message=imread("_copyright_small.bmp");
pn_sequence_search='T';    

 
% k=input('Enter the value:');
blocksize=8;
midband=[   0,0,0,1,1,1,1,0;    % defines the mid-band frequencies of an 8x8 dct
            0,0,1,1,1,1,0,0;
            0,1,1,1,1,0,0,0;
            1,1,1,1,0,0,0,0;
            1,1,1,0,0,0,0,0;
            1,1,0,0,0,0,0,0;
            1,0,0,0,0,0,0,0;
            0,0,0,0,0,0,0,0 ];
% % read in the cover object
% file_name='low_key.jpg';
% cover_object=double(imread(file_name));
 
% determine size of watermarked image
Mc=size(cover_object,1);    %Height
Nc=size(cover_object,2);    %Width
 
max_message=Mc*Nc/(blocksize^2);
 message1=message;
% % read in the message image and reshape it into a vector
% file_name='_copyright_small.bmp';
% message1=(imread(file_name));
if (length(message1) > max_message)
    error('Message too large to fit in Cover Object')
end
 
Mm=size(message1,1);                         %Height
Nm=size(message1,2);                         %Width
message=round(reshape(message1,Mm*Nm,1)./256);
message_vector=ones(1,max_message);
message_vector(1:length(message))=message;
 
% read in key for PN generator
file_name='_key.bmp';
key=double(imread(file_name))./256;
 
% reset MATLAB's PN generator to state "key"
j = 1;
for i =1:length(key)
rand('state',key(i,j));
end
 
 
[cA1,cH1,cV1,cD1] = dwt2(cover_object,'haar');
[cA2, cH2, cV2, cD2] = dwt2(cA1, 'haar');
%................ perform DCT on cH2......................................
 % generate PN sequences for "1" and "0"
pn_sequence_one=round(2*(rand(1,sum(sum(midband)))-0.5));
pn_sequence_zero=round(2*(rand(1,sum(sum(midband)))-0.5));
 
% find two highly un-correlated PN sequences
if (pn_sequence_search=='T')
    while (corr2(pn_sequence_one,pn_sequence_zero) > -0.55)
        pn_sequence_one=round(2*(rand(1,sum(sum(midband)))-0.5));
        pn_sequence_zero=round(2*(rand(1,sum(sum(midband)))-0.5));
    end
end
% process the image in blocks
x=1;
y=1;
for kk = 1:length(message_vector)
     
    % transform block using DCT
    disp(x)
    disp(y)
    dct_block=dct2(cH2(y:y+blocksize-1,x:x+blocksize-1));
    
    % if message bit contains zero then embed pn_sequence_zero into the mid-band
    % componants of the dct_block
    ll=1;
    if (message_vector(kk)==0)
        for ii=1:blocksize
            for jj=1:blocksize
                if (midband(jj,ii)==1)
                    dct_block(jj,ii)=dct_block(jj,ii)+k*pn_sequence_zero(ll); 
                    ll=ll+1;
                end
            end
        end
   
     
    % otherwise, embed pn_sequence_one into the mid-band componants of dct_block    
    else
        for ii=1:blocksize
            for jj=1:blocksize
                if (midband(jj,ii)==1)
                    dct_block(jj,ii)=dct_block(jj,ii)+k*pn_sequence_one(ll);
                    ll=ll+1;
                end
            end
        end               
    end
 
    % transform block back into spatial domain
   cH2(y:y+blocksize-1,x:x+blocksize-1)=idct2(dct_block);    
   
    % move on to next block. At and of row move to next row
    if (x+blocksize) >= Nc/4
        x=1;
        y=y+blocksize;
        if y>=128
            break
        end
    else
        x=x+blocksize;
    end
end
 
x=1;
y=1;
for kk = 1:length(message_vector)
% ................ perform DCT on cV2......................................
    % transform block using DCT
     dct_block_1=dct2(cV2(y:y+blocksize-1,x:x+blocksize-1));
    
    % if message bit contains zero then embed pn_sequence_zero into the mid-band
    % componants of the dct_block
    ll=1;
    if (message_vector(kk)==0)
        for ii=1:blocksize
            for jj=1:blocksize
                if (midband(jj,ii)==1)
                    dct_block_1(jj,ii)=dct_block_1(jj,ii)+k*pn_sequence_zero(ll); 
                    ll=ll+1;
                end
            end
        end
    
     
    % otherwise, embed pn_sequence_one into the mid-band componants of dct_block    
    else
        for ii=1:blocksize
            for jj=1:blocksize
                if (midband(jj,ii)==1)
                    dct_block_1(jj,ii)=dct_block_1(jj,ii)+k*pn_sequence_one(ll);
                    ll=ll+1;
                end
            end
        end               
    end
    % transform block back into spatial domain
   cV2(y:y+blocksize-1,x:x+blocksize-1)=idct2(dct_block_1);    
    
    % move on to next block. At and of row move to next row
    if (x+blocksize) >= Nc/4
        x=1;
        y=y+blocksize;
        if y>=128
            break
        end
    else
        x=x+blocksize;
    end
end

xx=idwt2(cA2, cH2, cV2, cD2, 'haar', [Mc, Nc]);

watermarked_image = idwt2(xx,cH1,cV1,cD1,'haar',[Mc,Nc]); 
 
% convert back to uint8
watermarked_image_uint8=uint8(watermarked_image);
 
 
% % calculate the PSNR
I0     = double(cover_object);
I1     = double(watermarked_image_uint8);
Id     = (I0-I1);
signal = sum(sum(I0.^2));
noise  = sum(sum(Id.^2));
MSE  = noise./numel(I0);
peak = max(I0(:));
PSNR = 10*log10(peak^2/MSE(:,:,1))

% Image Fiedilty
IF = imfed(I0,Id);
IF = mean(IF);


watermrkd_img=watermarked_image_uint8;
% imshow(watermrkd_img)

[message_vector1,Mo,No] = retriv2(watermrkd_img,message1);
recmessage=reshape(message_vector1,Mo,No);

% figure
% imshow(recmessage,[])
% title('Recovered Watermark')
NCC1=ncc(double(message1),recmessage);

% 
% disp(NCC1);
% disp(MSE);


