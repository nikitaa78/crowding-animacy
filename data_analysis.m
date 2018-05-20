names = {'SHL', 'MED','ALD', 'WXZ', 'WENQI SHI' };
%names = {'RV', 'JL'};
%all_finished = [];   
for i = 1:length(names) 
    
cd('Participant_Data');
%cd('pilot_data');
cd(names{i});
load('Results.mat')
data_1 = cell2mat(result(:,1));
data_2 = cell2mat(result(:,3));
data_3 = cell2mat(result(:,2)); 

%face_data = cell2mat(result(:,6));
%new_diff = data_2-face_data;

%new_diff(new_diff < 0) = new_diff(new_diff < 0) + 147;
%new_diff(new_diff > floor(147/2)) = new_diff(new_diff > floor(147/2)) -147;


difference = data_1 - data_2;

difference(difference < 0) = difference(difference < 0) + 147;
difference(difference > floor(147/2)) = difference(difference > floor(147/2)) -147;
 

all_data = horzcat(difference,data_3); 
sorted_data = sortrows(all_data,2);

%new_sorted_data = sortrows(horzcat(new_diff,data_3),2);
one = abs(sorted_data(1:67,1));
%new_one = abs(sorted_data(1:67,1));
four = abs(sorted_data(68:134,1));
eighteen = abs(sorted_data(135:201,1));

%four = abs(sorted_data(1:100,1));
%eighteen = abs(sorted_data(101:200,1));

%mean_new_one = sum(new_one)/length(new_one);
mean_one = sum(one)/length(one);
mean_four = sum(four)/length(four);
mean_eighteen = sum(eighteen)/length(eighteen);

finished(i,1:3) = {mean_one, mean_four,mean_eighteen};

%xlswrite('Ensemble_Error', finished)
 save 'Ensemble_Error.mat' finished;   
    cd ..
    cd ..
end
names = reshape(names,[length(names),1]);

all_data = horzcat(names, finished);
%save 'All_Participant_Data' all_data;
