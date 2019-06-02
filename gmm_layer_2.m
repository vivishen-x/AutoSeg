function class = gmm_layer_2(test_data,group,mu_tempo,sigma_tempo,c_tempo,mu_mfcc,sigma_mfcc,c_mfcc)
% test_data: the music file
% o: number of the file
% Group: 1: exburence/anxious; Group 2: depression/contentment

GMM_com=16;

training_count_2=2;
r1=0.8;
r2=0.5;

% EX: Q1-Exuberance
% AF: Q2-Anxious/Frantic
% DP: Q3-Depression
% CT: Q4-Contentment

trainData={'q1';'q2';'q3';'q4'};
if group==1         % High Energy
    trainClass=[1,2];
elseif group==2     % Low Energy
    trainClass=[3,4];
end

score_total=zeros(1,training_count_2);
score_tempo=zeros(1,training_count_2);
score_mfcc=zeros(1,training_count_2);

test_tempo=mirgetdata(mirtempo(test_data));
test_mfcc=mirgetdata(mirmfcc(test_data));

for n=1:training_count_2
        sigma_tempo1=zeros(1,GMM_com);
        mu_tempo1=zeros(1,GMM_com);
        c_tempo1=zeros(GMM_com,1);
        
        sigma_mfcc1=zeros(13,GMM_com);
        mu_mfcc1=zeros(13,GMM_com);
        c_mfcc1=zeros(GMM_com,1);
        % score of tempo
        for k=1:GMM_com
            sigma_tempo1(1,k)=sigma_tempo(trainClass(n),1,k);
            mu_tempo1(1,k)=mu_tempo(trainClass(n),1,k);
        end
        for t=1:GMM_com
            c_tempo1(t,1)=c_tempo(trainClass(n),t,1);
        end
        [lYM,lY]=lmultigauss(test_tempo,mu_tempo1,sigma_tempo1,c_tempo1);
      [score_tempo(1,n)]=mean(lY);
      
        %score of mfcc
        for t=1:13
          for k=1:GMM_com
            sigma_mfcc1(t,k)=sigma_mfcc(trainClass(n),t,k);
            mu_mfcc1(t,k)=mu_mfcc(trainClass(n),t,k);
           end
        end
        for t=1:GMM_com
            c_mfcc1(t,1)=c_mfcc(trainClass(n),t,1);
        end
        [lYM,lY]=lmultigauss(test_mfcc,mu_mfcc1,sigma_mfcc1,c_mfcc1);
      [score_mfcc(1,n)]=mean(lY);

      % calculate the total score
      if group==1
        score_total(1,n)=r1*score_tempo(1,n) + (1-r1)*score_mfcc(1,n);
      elseif group==2
         score_total(1,n)=r2*score_tempo(1,n) + (1-r2)*score_mfcc(1,n);
      end
end
    % 判断情感标记
    if score_total(1)>score_total(2)
        class=trainData(trainClass(1));
        
    elseif score_total(1)<score_total(2)
        class=trainData(trainClass(2));
        
    end 
    
end    

