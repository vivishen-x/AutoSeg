function gmm(fdname)
% GMM multi-layer 
% EX: Q1-Exuberance
% AF: Q2-Anxious/Frantic
% DP: Q3-Depression
% CT: Q4-Contentment

GMM_com = 16;

dir_train='training/';
dir_test = strcat(fdname,'/');
trainData={'q1';'q2';'q3';'q4'};

training_count = 4; %情感分类个数
training_num = 8;   %每组训练样本数
testing_count = length(dir(strcat(fdname,'/*.wav')));   %测试样本个数

mu_train = zeros(training_count, 1, GMM_com);
sigma_train = zeros(training_count, 1, GMM_com);
c_train = zeros(training_count, GMM_com, 1);


for n=1:2:training_count  %Group1: Exuberance+Anxious/Frantic ; Group2: Depression+Contentment
    train_feature1 = zeros(1,training_num*2);
    % file / directory
    dirname1=char(strcat(dir_train,trainData(n),'/*.wav'));
    d1=dir(dirname1);
    dirname2=char(strcat(dir_train,trainData(n+1),'/*.wav'));
    d2=dir(dirname2);
    % 建立GMM模型
    for num=1:training_num
        mwav1=miraudio(strcat(dir_train,trainData(n),'/',d1(num).name));
        mrms1=mirrms(mwav1);
        train_feature1(num)=mirgetdata(mrms1);
        
        mwav2=miraudio(strcat(dir_train,trainData(n+1),'/',d2(num).name));
        mrms2=mirrms(mwav2);
        train_feature1(num+training_num)=mirgetdata(mrms2);
    end
    [mu_train1, sigma_train1, c_train1] = gmm_estimate(train_feature1,GMM_com);
    mu_train(n,:,:)=mu_train1;
    sigma_train(n,:,:)=sigma_train1;
    c_train(n,:,:)=c_train1;
end

score=zeros(testing_count,training_count);
dir_t=char(strcat(dir_test,'/*.wav'));
dt=dir(dir_t);
% 训练组建立第二层节奏/音色的GMM模型
[mu_tempo,sigma_tempo,c_tempo,mu_mfcc,sigma_mfcc,c_mfcc]=train_layer_2(GMM_com);

fp=fopen('info.txt','wt');

for o=1:testing_count
    % 提取测试样本相应特征
    test_data=miraudio(strcat(dir_test,dt(o).name));
    test_rms=mirrms(test_data);
    test_feature=mirgetdata(test_rms);
    for n =1:2:training_count
        sigma_train1 = zeros(1, GMM_com);
        mu_train1 = zeros(1, GMM_com);
        c_train1 = zeros(GMM_com, 1);
        for t=1:1
            for k=1:GMM_com
                sigma_train1(t,k)=sigma_train(n,t,k);
                mu_train1(t,k)=mu_train(n,t,k);
            end
        end
        for t=1:GMM_com
            c_train1(t,1)=c_train(n,t,1);
        end
        % 计算对数似然比
      [lYM,lY]=lmultigauss(test_feature,mu_train1,sigma_train1,c_train1);
      [score(o,n)]=mean(lY);

    end
    
    fprintf(fp,strcat(dt(o).name,'\t'));
    if score(o,1)>score(o,3)    % 高能量组
       fprintf(fp,'Group 1\t');
       % 确定情感标记
      class=gmm_layer_2(test_data,1,mu_tempo,sigma_tempo,c_tempo,mu_mfcc,sigma_mfcc,c_mfcc);
      fprintf(fp,char(strcat(class,'\n')));
    elseif score(o,1)<score(o,3)    % 低能量组
       fprintf(fp,'Group 2\t');
      class=gmm_layer_2(test_data,2,mu_tempo,sigma_tempo,c_tempo,mu_mfcc,sigma_mfcc,c_mfcc);
      fprintf(fp,char(strcat(class,'\n')));
    end 
end

fclose(fp);
clear all;
end



