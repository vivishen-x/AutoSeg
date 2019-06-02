function musicdata(fdname,pname)
% EX: Q1-Exuberance
% AF: Q2-Anxious/Frantic
% DP: Q3-Depression
% CT: Q4-Contentment

segment(fdname,pname);
gmm(fdname);

dir_t=char(strcat(fdname,'/*.wav'));
dt=dir(dir_t);
testing_count = length(dir(strcat(fdname,'/*.wav')));
h = zeros(testing_count,1);
s = zeros(testing_count,1);
v = zeros(testing_count,1);
tempo = zeros(testing_count,1);

%save as CSV files for visualization
fx=fopen(strcat('visualization/data/',fdname,'_inf.csv'),'wt');
fprintf(fx,'end,h,s,v,tempo\n');
for i=1:testing_count
    test_data=miraudio(strcat(fdname,'/',dt(i).name));
    [etm] = textread('segment.txt','%d',-1);
    [a,b,c,d]=textread('info.txt','%s%s%s%s',-1);
    time = char(d(i));
    switch time
        case 'q1'
            h(i)=45;    % �Ƴ�ɫ
        case 'q2'
            h(i)=0;     % ��ɫ
        case 'q3'
            h(i)=225;   % ����ɫ
        case 'q4'
            h(i)=120;   % ��ɫ
    end
    % RMS�뱥�Ͷ�����ع�ϵ
   rms = mirgetdata(mirrms(test_data));
   if (rms < 0.025)
       s(i)=0.25;
   elseif (rms < 0.05)
       s(i) = 0.5;
   elseif (rms < 0.075)
       s(i) = 0.75;
   elseif (rms < 0.1)
       s(i) = 1;
   end
   % tempo�����ȵ�V�ι�ϵ
   tmp = mirgetdata(mirtempo(test_data));
   tempo(i) = tmp;
   if (tmp<60)
       v(i)=0.25;
   elseif (tmp<80)
       v(i)=0.5;
   elseif (tmp<100)
       v(i) = 0.75;
   elseif (tmp<140)
       v(i) = 1;
   elseif (tmp<160)
       v(i) = 0.75;
   elseif (tmp<180)
       v(i) = 0.5;
   elseif (tmp<200)
       v(i) = 0.25;
   end
   % HSV��ɫ����
   clr = strcat(num2str(h(i)),',',num2str(s(i)),',',num2str(v(i)),',');
   fprintf(fx,strcat(num2str(etm(i)),',',clr,num2str(tempo(i)),'\n'));
end
fclose(fx);

% ���浽visualization���ļ�����
song=miraudio(strcat(pname,fdname,'.wav'));
fx=fopen(strcat('visualization/data/',fdname,'_rms.csv'),'wt');
fprintf(fx,'rms\n');
rms=mirrms(song,'Frame',1,'s',1);
rmsdata=mirgetdata(rms);
fprintf(fx,'%f\n',rmsdata);
fclose(fx);

ft = fopen('visualization/title.csv','wt');
fprintf(ft,'name\n');
fprintf(ft,fdname);

% create, resize and save the spectrum for visualization
song
imgdir=strcat('visualization/data/',fdname,'_spec');
saveas(gcf,imgdir,'png');
img1 = imread(strcat(imgdir,'.png'));
img1 = imcrop(img1,[158,80,930,725]);
imshow(img1);
imshow(img1,'border','tight','initialmagnification','fit');
set (gcf,'Position',[0,0,930,725]);
axis normal;
saveas(gcf,imgdir,'png');

% close all windows
close all;

end