clear all;
close all;

% Doc for Variables ==> https://docs.google.com/document/d/1twHFrzTCC3lNVrpElxPSZa5FQENvILDO8FvAdgH95Wk/edit?usp=sharing

%% KUDOS TO WHOLE TEAM FOR DOING THEIR PART 🙌🏼

nameID = 'person'; %set nameID for subject

try
    %define screen
    Screen('Preference', 'SkipSyncTests', 1);
    RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));
    [window, rect] = Screen('OpenWindow', 0); %opening the screen
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); %allowing transparency in the photos
    
    HideCursor();
    window_w = rect(3); % defining size of screen
    window_h = rect(4);
    
    %define midpoints of the screen
    xmid = window_w/2; 
    ymid = window_h/2;
            
    KbName('UnifyKeyNames'); % Unify keynames on all platforms
    
    Screen('DrawText', window, 'Loading... 0 out of 8', xmid-128, ymid-25); % Write text to confirm loading of images
    Screen('Flip', window); % Display text

    %% loading stimuli
    cd('EXStimuli/targets'); %go into stimuli & targets folder
    allPics=zeros(2, 4, 200); %setup array to store texture IDs
    orient1 = {'right'; 'left'; 'right'; 'left'}; %array for first word of folder names
    anim = {'animate';'animate';'inanimate';'inanimate'}; %array for second word of folder names
    %loading target images
    for i = 1:4 %4 different target folders
        cd( [char(orient1(i)) ' ' char(anim(i))] ); %go into folder
        for n = 1:100 %100 images in each folder
            tmp_bmp = imread(['resized' num2str(n) '.jpg']);%Get images
            tmp_bmp = imresize(tmp_bmp,0.5); %scale image down to 1/2 so it's reasonably sized
            allPics(1, i, n) = Screen('MakeTexture', window, tmp_bmp); %store texture id into allPics
        end 
        cd ..; %back out of folder
        Screen('DrawText', window, ['Loading...  ' num2str(i) ' out of 8'], xmid-128, ymid-25); % Write text to confirm loading of images
        Screen('Flip',window); %Show amount out of 8 done
    end
    addon = [0; 100; 0; 100]; %index to show whether or not to add 100 to index because we don't need flankers split up into left and right, only animate and inanimate
    curr = [1; 1; 2; 2]; %index for storing images
    cd ..; %exit folder: target
    cd('flankers');
    %loading flanker images
    for i = 1:4 %four folders
        cd( [char(orient1(i)) ' ' char(anim(i))] ); %changes directory into folders within flankers such as right animate, left animate,..
        for n = 1:100 %100 images in each folder
            tmp_bmp = imread(['resized' num2str(n) '.jpg']);%Get images
            tmp_bmp = imresize(tmp_bmp,0.5); %resize image to reasonable size
            allPics(2, curr(i), addon(i) + n) = Screen('MakeTexture', window, tmp_bmp);%Sets imgHolder's value i as tmp_bmp
        end
        cd ..; %back out of folder
        Screen('DrawText', window, ['Loading...  ' num2str(i+4) ' out of 8'], xmid-128, ymid-25); % Write text to confirm loading of images
        Screen('Flip',window); %flip around Loading screen
    end
    %input white image
    cd ..; %img-thing.jpg should be in the EXStimuli folder
    A = imread('img-thing.jpg');
    white_img = Screen('MakeTexture', window, imresize(A,2)); %resize white_img
    cd ..; %back out of EXStimuli folder
    w_img = size(tmp_bmp, 2); %width of pictures
    h_img = size(tmp_bmp, 1); %height of pictures
   
    answers=zeros(120, 3); %define empty answers matrix
    
    % generate conditions matrix
    % COLUMN 1: TARGET CONDIIONS
    % 1 = right animated
    % 2 = left animated
    % 3 = right inanimated
    % 4 = left inanimated
    rep1 = ones(6,1); %generate six 1s
    rep2 = repmat( 2, 1, 6); %generate six 2s
    rep3 = repmat( 3, 1, 6 ); %generate six 3s
    rep4 = repmat( 4, 1, 6 ); %generate six 4s
    %vertically concatenate the four different columns into 1 column below
    column1 = vertcat( vertcat( rep1, rep2' ), vertcat( rep3',rep4'));  
    column2 = repmat( [1 2 3], 1, 8 ); %repeating 1 2 3 eight times
    column2 = column2'; %invert column 2 so it is vertical
    column3 = repmat( [ 1 1 1 2 2 2 ], 1, 4); %repeating 1 1 1 2 2 2 
    column3 = column3'; %invert column 3 so it is vertical
    %horizontally concatenate the 3 different columns
    conditions = horzcat( horzcat(column1, column2), column3); 
    
    %generate order matrix
    order = (1:120); %120 trials, each has a different condition
    order = Shuffle(order); %shuffle conditions
     
    nRows = 3; %number of rows in grid
    nCols = 3; %number of columns in grid
    
    %%PREPARATION FOR FIXATION CROSS
    [X,Y] = RectCenter(rect);
    FixCross = [X-1,Y-40,X+1,Y+40;X-40,Y-1,X+40,Y+1];
    
    
    % Get the centre coordinate of the window
    [xCenter, yCenter] = RectCenter(rect);

    % Here we set the size of the arms of our fixation cross
    fixCrossDimPix = 20;

    % Now we set the coordinates (these are all relative to zero we will let
    % the drawing routine center the cross in the center of our monitor for us)
    xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
    yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
    allCoords = [xCoords; yCoords];

    % Set the line width for our fixation cross
    lineWidthPix = 4;
    
    %Draw the fixation cross
    % Get the screen numbers
    screens = Screen('Screens');
    screenNumber = max(screens);
    black = BlackIndex(window);
    
    
    %%Setup ISI Jitter
    possible_ISI_Times = [ 1.0, 1.1, 1.2, 1.3, 1.4, 1.5 ];
    ISI_Order = 1:6;
    ISI_Order = repmat(ISI_Order,20);
    ISI_Order = Shuffle(ISI_Order);

    %DRAWS THE INSTRUCTIONS
    Screen('DrawText', window, 'There will be 120 trials. Please press any key to continue.',xmid-300,ymid+75); 
    Screen('DrawText', window, 'Remain fixated on the + in the center.', xmid-300, ymid); 
    Screen('DrawText', window, 'You will be asked the orientation and the animacy of the middle picture.', xmid-300, ymid-75);
    Screen('Flip', window); %show text
    KbWait; %wait for keyboard input
    
     %RAND SELECTION OF TARGETS
    rand_target = vertcat(randperm(100), randperm(100), randperm(100), randperm(100)); %different column for each condition
    target_indices = [1 1 1 1]; %to be incremented
    
    %RANDOM SELECTION OF ANIMATE FLANKERS
    flank_animate = randperm(200,200);
    index_animate = 1;
    
    
    %RANDON SELECTION OF INANIMATE FLANKERSs
    flank_inanimate = randperm(200,200);
    index_inanimate = 1;
        
    
    %%BEGINNING OF TRIALS
    for i = 1:120 %120 trials
        
        %DRAWS THE FIXATION CROSS
        Screen('DrawLines', window, allCoords, lineWidthPix, [0,0,0], [xCenter yCenter], 2);
        
        %%VARIABLES
        chosen = mod(order(i),24)+1; %OUT OF THE 24 TREATMENTS, WHICH TREATMENT IS CHOSEN?
        
        %%TO DECIDE IF PICTURES ARE TO BE POSITIONED ON THE RIGHT AND LEFT%%%
        if  conditions(chosen, 3) == 1
            xStart = window_w*0.25-w_img;
            xEnd = window_w*0.25+w_img;
            yStart = window_h*0.5+h_img;
            yEnd = window_h*0.5-h_img;
         elseif conditions(chosen, 3) == 2
            xStart = window_w*0.75-w_img;
            xEnd = window_w*0.75+w_img;
            yStart = window_h*0.5+h_img;
            yEnd = window_h*0.5-h_img;
        end
        
        %INITIALIZES THE SELECTED_STIMULI TO BE ZERO
        selected_stimuli = NaN(1,9); %3x3 grid
        for l = 1:9 %3x3 grid
             selected_stimuli(l) =  white_img; %set all squares to white
        end
        
         %%SELECTION OF TARGETS AND ASSIGNING OF THE CHOSEN TARGET TEXTURE TO SELECTED_STIMULI
        rand_treatments = rand_target(conditions(chosen), :); %chooses what type of picture -- left animate, right animate, left inanimate, right inanimate
        selected_stimuli(5) = allPics(1, conditions(chosen, 1), rand_treatments(target_indices(conditions(chosen)))); % selects the random pic of the 100
        target_indices(conditions(chosen)) = target_indices(conditions(chosen))  + 1; % increases the index
      
        %%SELECTION OF FLANKERS AND ASSIGNING OF THE CHOSEN FLANKER TEXTURES TO SELECTED_STIMULI
        for j = 1:4   
            if conditions(chosen, 2) == 1  %determines what type of picture --  animate, inanimate
                selected_stimuli(2*j) = allPics(2, conditions(chosen,2), flank_animate(index_animate));
                index_animate = index_animate + 1;   % increases the index
            elseif conditions(chosen, 2) == 2    %determines what type of picture --  animate, inanimate
                selected_stimuli(2*j) = allPics(2, conditions(chosen,2), flank_inanimate(index_inanimate));
                index_inanimate = index_inanimate + 1;   % increases the index
            end    
        end
        
        % This will output the x & y coordinates in a symmetrical grid pattern
        [x,y]=meshgrid(linspace(xStart,xEnd,nCols),linspace(yStart,yEnd,nRows));
        
        
        % Getting coordinates of rectangle regions of stimuli while combining all
        % the positions into one matrix. This will be used later as input to the 
        % "DrawTextures" function.
        xy_rect = [x(:)'-w_img/2; y(:)'-h_img/2; x(:)'+w_img/2; y(:)'+h_img/2];
            
        %%drawing stuff
        %%DRAWING OF THE STIMULI
        
        
        %checks to see if there's an existing texture within the vector selected_stimuli and if yes, draws the texture
        for thing = 1:9 
            if ~isnan(selected_stimuli(thing ))
             Screen('DrawTextures', window, selected_stimuli(thing), [], xy_rect(:,thing))
            end
        end
        
         
        %VARIABLES FOR THE FRAMRECT 
        baseRect = [0,0,w_img,h_img]; %determines the dimensions of the rectangles
        allRects = NaN(4,9); %initializes the rectangle coordinates to NaN
        allColors = [1,1,1]; %chooses the color of the borders
        
        squareXposL = [xStart (xStart+xEnd)/2 xEnd]; %finds the 3 midpoints of the 3 squares in the second row of the grid
        numSquaresL = length(squareXposL); %gets the length of the xpositions of the squares on the left side
        
        squareXposR = abs(window_w-squareXposL); %finds the 3 midpoints on the other side of the screen
        numSquaresR = length(squareXposR);%gets the length of the xposition of the sqaures on the right side
        
        for p = 1:numSquaresL %assigns the allRects(:,4:6) to have coordinates for their rectangles
             allRectsL(:, p+3) = CenterRectOnPointd(baseRect, squareXposL(p), yCenter);
        end
        
        for p = 1:numSquaresR  %assigns the allRects(:,4:6) to have coordinates for their rectangles
             allRectsR(:, p+3) = CenterRectOnPointd(baseRect, squareXposR(p), yCenter);
        end
        
         %assigns the allRects(:,2 & 8) to have coordinates for their rectangles
        allRectsL(:,2) = CenterRectOnPointd(baseRect, squareXposL(2), yCenter+h_img);
        allRectsL(:,8) = CenterRectOnPointd(baseRect, squareXposL(2), yCenter-h_img);
        allRectsR(:,2) = CenterRectOnPointd(baseRect, squareXposR(2), yCenter+h_img);
        allRectsR(:,8) = CenterRectOnPointd(baseRect, squareXposR(2), yCenter-h_img);
        
        
        
         
        %draws the grids on both sides of the screen
        Screen('FrameRect', window, allColors, allRectsL, 5); 
        Screen('FrameRect', window, allColors, allRectsR, 5); 
        
        Screen('Flip', window);
        WaitSecs(2);
        
        
        %%CHECKS IF TARGET STIMULI IS ANIMATE OR INANIMATE
        %Instructions for the first prompt
        Screen('DrawText', window, 'Press F if the center image is animate.', xmid-256, ymid-40); 
        Screen('DrawText', window, 'Press J if the center image is inanimate.', xmid-256, ymid+40); 
        Screen('Flip', window);

        [keyIsDown, seconds, keyCode] = KbCheck();  % Check you keyboard responses

        % when key 'f'and'j' are not pressed, keep checking keyboard responses until they are pressed.
        % F: Animate, J: Inanimate
        while ~keyCode(KbName('f')) && ~keyCode(KbName('j'))
            [ keyIsDown, seconds, keyCode] = KbCheck();
            if keyCode(KbName('escape')) %temp way for us to test and exit our trials
                Screen('CloseAll');
                error('Left trials');
                break;
            end
        end
       
        %checks to see if the button that was pressed correctly corresponded to the characteristics of the stimuli (either animate or inanimate)
        % F: Animate, J: Inanimate
       if keyCode(KbName('f'))&&(conditions(chosen, 1) == 1||conditions(chosen, 1) == 2) % if 'f' is pressed, and the stimuli is animate (any row column 1~values of 1 and 2 are animate), then return 1
          answers(i,1)=1;
        elseif keyCode(KbName('j'))&&(conditions(chosen, 1)==3||conditions(chosen, 1) ==4) % if 'j' is pressed, and the stimuli is inanimate (any row column 1~ values of 3 and 4 are inanimate), then return 1
           answers(i,1)=1;        
        elseif keyCode(KbName('f'))&&(conditions(chosen, 1)==3||conditions(chosen, 1)==4)   % if 'f' is pressed, and the stimuli is inanimate (any row column 1~ vales of 1 and 2 are animate), then return 0
           answers(i,1)=0;
        elseif keyCode(KbName('j'))&&(conditions(chosen, 1)==1||conditions(chosen, 1) ==2) % if 'j' is pressed, and the stimuli is animate (any row column 1~ values of 3 and 4 are inanimate), then return 0
           answers(i,1)=0;
       else answers(i,1)=NaN;
       end
       
    
        %%CHECKS IF TARGET STIMULI IS LEFT OR RIGHT
        %Instructions for the second prompt
        Screen('DrawText', window, 'Press D if the center image is facing to the left.', xmid-256, ymid-40); 
        Screen('DrawText', window, 'Press K if the center image is facing to the right.', xmid-256, ymid+40); 
        Screen('Flip', window); %Show text

        [keyIsDown, seconds, keyCode] = KbCheck();  % Check you keyboard responses

        % when key 'd'and'k' are not pressed, keep checking keyboard responses until they are pressed.
        % D: LEFT, k: right
        while ~keyCode(KbName('d')) && ~keyCode(KbName('k')) 
            [ keyIsDown, seconds, keyCode] = KbCheck();
            if keyCode(KbName('escape')) %escape option, esp for testing
                Screen('CloseAll'); %Close screen
                error('did not want to go through all trials'); %give error
            end
        end
        
        %% Check to see if the percieved orientation is correct
        if keyCode(KbName('d'))&&(conditions(chosen, 1)==2||conditions(chosen, 1) == 4) % if 'd' is pressed, and the stimuli is left, then return 1
            answers(i, 2)=1;
        elseif keyCode(KbName('k'))&&(conditions(chosen, 1)==1||conditions(chosen, 1) ==3) % if 'k' is pressed, and the stimuli is right, then return 1
            answers(i, 2)=1;
        elseif keyCode(KbName('d'))&&(conditions(chosen, 1)==1||conditions(chosen, 1)==3) % if 'd' is pressed, and the stimuli is right, then return 0
            answers(i, 2)=0;
        elseif keyCode(KbName('k'))&&(conditions(chosen, 1)==2||conditions(chosen, 1) ==4) % if 'k' is pressed, and the stimuli is left, then return 0
            answers(i, 2)=0;
        else answers(i, 2)=NaN; 
        end;
        
        
        %% Store the current conditions
        answers(i, 3) = chosen;
        
        %Jitter ISI
        Screen('Flip', window);
        WaitSecs(possible_ISI_Times(ISI_Order(i)));
    end
    
    Screen('CloseAll'); %Close the screen
    
    if ~isdir('Experiment_4') %if no directory called Experiment 4
        mkdir('Experiment_4');   %make directory
    end
    
    cd('Experiment_4'); %entter directory experiment 4
    save([nameID '.mat'],'answers'); %store answers into file named after person
catch
    rethrow(lasterror); 
end
      