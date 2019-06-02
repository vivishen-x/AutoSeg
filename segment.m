function segment(fdname,pname)
if ~exist(fdname,'dir')
    mkdir(fdname)
end
fname = strcat(pname,fdname,'.wav');

length=mirlength(fname);
T=floor(mirgetdata(length));          %duration of the music clip
t0=0;           %onset
t1=0;           %offset of a cluster
key=zeros(1,T/2);
cluster = zeros(1,T/2);
clusterCount = zeros(1,T/2);  %�þ����е�֡��
stime=zeros(1,T/2);

count = 0;
threshold = 0.25;
clucentroid = zeros(1,T/2);
maxDistance = 0;

count = count+1;

f = miraudio(fname,'Extract',t0,t0+4);
pre = mircentroid(f);
clucentroid(1) = mirgetdata(pre);

cluster(1) = 1;
id = cluster(1);
clusterCount(1) = clusterCount(1) +1;
tt=0;   %start of a certain cluster
clusterGroupId=1;

fp=fopen('segment.txt','wt');

for k=1:T/2
    t0 = t0+2;
    f = miraudio(fname,'Extract',t0,t0+4);
    tmp = mircentroid(f);    
    dist = mirdist(tmp,pre);
    maxDistance = mirgetdata(dist)/min(mirgetdata(pre),mirgetdata(tmp));
    
    % rmsֵ��̫��ʱ����Ϊsilent
    mrms=mirrms(f);
    rvalue=mirgetdata(mrms);
    if (maxDistance<threshold) || (rvalue<0.008)||(t0-tt<10)
        %���ƶȴ� ��������ľ���С || ����silent��Ƭ�ι���ͬһ������
        f = miraudio(fname,'Extract',tt,t0);
        pre = mircentroid(f);   % ��������
        clucentroid(k)=mirgetdata(pre);
        clusterCount(clusterGroupId)=clusterCount(clusterGroupId)+2;
        cluster(k)=clusterGroupId;

    else
        % ����� ������ ����ָ�λ��
        maxd=0;
        t1=t0;
        for ii=t1:t1+3
            ff=miraudio(fname,'Extract',ii,ii+1);
            cctmp=mircentroid(ff);
            dd=mirgetdata(mirdist(cctmp,pre));
            if dd>maxd
                maxd=dd;
                keytime=ii;     %return the key time
            end
        end
        % To save the music piece
        note=mirgetdata(mironsets(miraudio(fname,'Extract',keytime,keytime+1),'SpectroFrame'));
        stime(count)=note(1);
        if count==1
            sg=miraudio(fname,'Extract',0,stime(count));
        else
            sg=miraudio(fname,'Extract',stime(count-1),stime(count));
        end
        mirsave(sg,strcat(fdname,'/',num2str(count,'%02d')));
        
        % �¾��� ����һ����������
        count=count+1;
        clusterCount(count)=clusterCount(count)+2;
        clucentroid(k)=mirgetdata(tmp);
        pre = tmp;
        
        cluster(k)=count;
        tt=t0;  %new start
        key(k)=t0;  %return the key time
        
        fprintf(fp,strcat(num2str(t0),'\n'));
    end
end

fprintf(fp,strcat(num2str(T),'\n'));

if count>1 
    sg=miraudio(fname,'Extract',stime(count-1),T);
    mirsave(sg,strcat(fdname,'/',num2str(count,'%02d')));
else
    % ����1������û�зָ������������ԭ�ֶ�
    mirsave(fname,strcat(fdname,'/',num2str(count,'%02d')));
end
fclose(fp);

end


