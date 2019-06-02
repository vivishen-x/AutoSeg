function [mu_tempo,sigma_tempo,c_tempo,mu_mfcc,sigma_mfcc,c_mfcc]=train_layer_2(GMM_com)
% GMM multi-layer 
% EX: Q1-Exuberance
% AF: Q2-Anxious/Frantic
% DP: Q3-Depression
% CT: Q4-Contentment

dir_train='training/';
trainData={'q1';'q2';'q3';'q4'};

training_count = 4; % 情感分类
training_num = 8;   % 各训练组样板数

mu_tempo = zeros(training_count, 1, GMM_com);
sigma_tempo = zeros(training_count, 1, GMM_com);
c_tempo = zeros(training_count, GMM_com, 1);
mu_mfcc = zeros(training_count, 13, GMM_com);
sigma_mfcc = zeros(training_count, 13, GMM_com);
c_mfcc = zeros(training_count, GMM_com, 1);

% 提取tempo、MFCC特征建立GMM
for n=1:training_count
    train_tempo = zeros(1,training_num);
    train_mfcc = zeros(13,training_num);
    dirname1=char(strcat(dir_train,trainData(n),'/*.wav'));
    d1=dir(dirname1);
    
    for num=1:training_num
        mwav=miraudio(strcat(dir_train,trainData(n),'/',d1(num).name));
        mtempo=mirtempo(mwav);
        train_tempo(num)=mirgetdata(mtempo);
        
        mmfcc=mirmfcc(mwav);
        train_mfcc(:,num)=mirgetdata(mmfcc)';
    end
    [mu_train1, sigma_train1, c_train1] = gmm_estimate(train_tempo,GMM_com);
    mu_tempo(n,:,:)=mu_train1;
    sigma_tempo(n,:,:)=sigma_train1;
    c_tempo(n,:,:)=c_train1;
    
    [mu_train2, sigma_train2, c_train2] = gmm_estimate(train_mfcc,GMM_com);
    mu_mfcc(n,:,:)=mu_train2;
    sigma_mfcc(n,:,:)=sigma_train2;
    c_mfcc(n,:,:)=c_train2;
    
end

end







